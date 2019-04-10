#!/bin/bash -xv

echo $TRAVIS_BRANCH

if [[ $TRAVIS_BRANCH =~ (^one-) ]]; then
    export PREVIOUS_ONE=~/previous.one
    export CURRENT_ONE=../../
    git clone https://github.com/tinova/one $PREVIOUS_ONE
    (cd $PREVIOUS_ONE ; git checkout $TRAVIS_BRANCH^)
    diff $PREVIOUS_ONE/share/etc/oned.conf $CURRENT_ONE/share/etc/oned.conf
fi

exit -1
