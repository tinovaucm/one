#!/bin/bash -xv

if [[ $TRAVIS_BRANCH =~ (^one-) ]]; then
    export PREVIOUS_ONE=~/previous.one
    export CURRENT_ONE=../../
    git clone https://github.com/tinova/one $PREVIOUS_ONE
    (cd $PREVIOUS_ONE ; git checkout $TRAVIS_BRANCH)
    # In a PR we compare with the head of $TRAVIS_BRANCH
    # Otherwise, we want to check with the previous commit
    if [[ $TRAVIS_PULL_REQUEST == false ]]; then
        (cd $PREVIOUS_ONE ; git checkout $HEAD~1)
    fi
    diff $PREVIOUS_ONE/share/etc/oned.conf $CURRENT_ONE/share/etc/oned.conf
fi

exit -1
