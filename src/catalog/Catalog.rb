# --------------------------------------------------------------------------
# Copyright 2002-2011, OpenNebula Project Leads (OpenNebula.org)
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# --------------------------------------------------------------------------

require 'OpenNebula'
require 'CommandManager'
require 'yaml'

class Catalog
    SCRIPTS_PATH = File.dirname(__FILE__) + '/scripts'

    def initialize
        update_catalogs
    end

    def list
        output = ""
        return output unless @catalogs

        @catalogs.each { |key, value|
            credentials = retrieve_credentials(key)
            cmd = "#{SCRIPTS_PATH}/#{value['scripts']}/list #{key} \
                   #{credentials}"
            list = NonBlockingLocalCommand.run(cmd)
            if list.code != 0
                return [false,list.stderr]
            else
                output << list.stdout
            end
        }

        return [true,output]
    end

    def import(catalog, resource_id, template, opts={})
        download_dir=generate_download_dir(catalog, resource_id)
        download_dir="/tmp/one/ec2dsa/1306139035ami-40f50b29/"
        puts "Working directory: #{download_dir}" if opts[:verbose]

        log_file = File.new("#{download_dir}/log", 'a')
        scripts_catalog = scripts_catalog(catalog)

        # Download the resource from the catalog
        puts "Downloading #{resource_id} from #{catalog}" if opts[:verbose]
        credentials = retrieve_credentials(catalog)
        cmd = "#{scripts_catalog}/download #{download_dir} #{resource_id} \
               #{credentials}"
        download = NonBlockingLocalCommand.run(cmd,log_method(log_file))
        if download.code != 0
            log_file.close
            return [false, download.stderr]
        else
            image_file = download.stdout.strip
        end

        if opts[:contextualize]
            # Prepare image file to be included in OpenNebula
            puts "Contextualizing #{image_file}" if opts[:verbose]
            cmd = "sudo #{SCRIPTS_PATH}/common/contextualize #{image_file}"
            contextualize = NonBlockingLocalCommand.run(cmd,log_method(log_file))
            if contextualize.code != 0
                log_file.close
                return [false, contextualize.stderr]
            else
                disk_file = contextualize.stdout.strip
            end
        else
            disk_file = image_file
        end

        # Generate OpenNebula Image template
        puts "Generating Image template" if opts[:verbose]
        image_template = nil
        File.open("#{download_dir}/image.one", 'w') do |f|
            image_template = <<EOT
NAME="#{File.basename(download_dir)}"
TYPE=OS
PATH=#{disk_file}
CATALOG=#{catalog}
CATALOG_RESOURCE=#{resource_id}
EOT
            f.puts image_template
        end
        puts `cat #{download_dir}/image.one"` if opts[:verbose] 

        # Add Image to OpenNebula
        client = OpenNebula::Client.new
        image  = OpenNebula::Image.new(OpenNebula::Image.build_xml, client)
        result = image.allocate(image_template)
        if OpenNebula.is_error?(result)
            log_file.close
            return [false, result.to_str]
        end

        # Generate OpenNebula Virtual Machine template
        puts "Generating Virtual Machine template" if opts[:verbose]
        cmd = "#{scripts_catalog}/toone #{download_dir} #{image.id} \
               #{template}"
        toone = NonBlockingLocalCommand.run(cmd,log_method(log_file))
        if toone.code != 0
            log_file.close
            return [false, toone.stderr]
        else
            one_template = toone.stdout
        end
        puts `cat #{one_template}` if opts[:verbose] 

        log_file.close
        return [true, "#{image_id},#{one_template}"]
    end

    private

    def update_catalogs
        conf = YAML.load_file(CONFIGURATION_FILE)
        @catalogs = conf['catalogs']
        @download_dir = conf['download_dir']
    end

    def generate_download_dir(catalog, resource_id)
        timestamp=Time.now.to_i
        download_dir="#{@download_dir}/#{catalog}/#{timestamp}#{resource_id}"
        `mkdir -p #{download_dir}`
        download_dir
    end

    def scripts_catalog(catalog)
        if catalog = @catalogs[catalog.to_s]
            if cmd = catalog['scripts']
                return "#{SCRIPTS_PATH}/#{cmd}"
            end
        end

        return nil
    end

    def retrieve_credentials(catalog)
        catalog = @catalogs[catalog.to_s]
        catalog ? catalog['credentials'] : nil
    end

    def log(file, message)
        msg=message.strip
        time=Time.now.strftime("%a %b %d %H:%M:%S %Y")        
        msg.each_line {|line|
            l=line.strip
            file.puts "#{time} [Cat][D]: #{l}"
            file.flush
        }
    end

    def log_method(file)
        lambda {|message|
            log(file, message)
        }
    end
end

