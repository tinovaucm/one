/* -------------------------------------------------------------------------- */
/* Copyright 2002-2011, OpenNebula Project Leads (OpenNebula.org)             */
/*                                                                            */
/* Licensed under the Apache License, Version 2.0 (the "License"); you may    */
/* not use this file except in compliance with the License. You may obtain    */
/* a copy of the License at                                                   */
/*                                                                            */
/* http://www.apache.org/licenses/LICENSE-2.0                                 */
/*                                                                            */
/* Unless required by applicable law or agreed to in writing, software        */
/* distributed under the License is distributed on an "AS IS" BASIS,          */
/* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   */
/* See the License for the specific language governing permissions and        */
/* limitations under the License.                                             */
/* -------------------------------------------------------------------------- */

#ifndef REQUEST_MANAGER_ENABLE_H_
#define REQUEST_MANAGER_ENABLE_H_

#include "Request.h"
#include "Nebula.h"
#include "AuthManager.h"

using namespace std;

/* ------------------------------------------------------------------------- */
/* ------------------------------------------------------------------------- */
/* ------------------------------------------------------------------------- */

class RequestManagerEnable: public Request
{
protected:
    RequestManagerEnable(const string& method_name,
                          const string& help)
        :Request(method_name,"A:sib",help)
    {
        auth_op = AuthRequest::MANAGE;
    }

    ~RequestManagerEnable(){};

    /* -------------------------------------------------------------------- */

    void request_execute(xmlrpc_c::paramList const& _paramList,
                         RequestAttributes& att);

    virtual int enable(PoolObjectSQL *object, bool eflag) = 0;
};

/* ------------------------------------------------------------------------- */
/* ------------------------------------------------------------------------- */

class TemplateEnable : public RequestManagerEnable
{
public:
    TemplateEnable():
        RequestManagerEnable("TemplateEnable",
                             "Enables or disables a virtual machine template")
    {    
        Nebula& nd  = Nebula::instance();
        pool        = nd.get_tpool();
        auth_object = AuthRequest::TEMPLATE;
    };

    ~TemplateEnable(){};

    int enable(PoolObjectSQL *object, bool eflag)
    {
        VMTemplate * robject;

        robject = static_cast<VMTemplate *>(object);

        return robject->enable(eflag);
    }
};

/* ------------------------------------------------------------------------- */
/* ------------------------------------------------------------------------- */

class HostEnable : public RequestManagerEnable
{
public:
    HostEnable():
        RequestManagerEnable("HostEnable",
                             "Enables or disables a host")
    {    
        Nebula& nd  = Nebula::instance();
        pool        = nd.get_hpool();
        auth_object = AuthRequest::HOST;
    };

    ~HostEnable(){};

    int enable(PoolObjectSQL *object, bool eflag)
    {
        Host * robject;

        robject = static_cast<Host *>(object);

        return robject->enable(eflag);
    }
};

/* ------------------------------------------------------------------------- */
/* ------------------------------------------------------------------------- */

class UserEnable : public RequestManagerEnable
{
public:
    UserEnable():
        RequestManagerEnable("UserEnable",
                             "Enables or disables a user")
    {    
        Nebula& nd  = Nebula::instance();
        pool        = nd.get_upool();
        auth_object = AuthRequest::USER;
    };

    ~UserEnable(){};

    int enable(PoolObjectSQL *object, bool eflag)
    {
        User * robject;

        robject = static_cast<User *>(object);

        return robject->enable(eflag);
    }
};

/* -------------------------------------------------------------------------- */
/* -------------------------------------------------------------------------- */
/* -------------------------------------------------------------------------- */

#endif
