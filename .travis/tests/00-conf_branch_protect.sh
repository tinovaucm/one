#!/bin/bash -xv

echo $TRAVIS_BRANCH

# In a PR we compare with the head of $TRAVIS_BRANCH
# Otherwise, we want to check with the previous commit
if [[ $TRAVIS_PULL_REQUEST != false ]]; then
    export BRANCH_TO_CHECKOUT = $TRAVIS_BRANCH
else
    export BRANCH_TO_CHECKOUT = $TRAVIS_BRANCH^
fi


if [[ $TRAVIS_BRANCH =~ (^one-) ]]; then
    export PREVIOUS_ONE=~/previous.one
    export CURRENT_ONE=../../
    git clone https://github.com/tinova/one $PREVIOUS_ONE
    (cd $PREVIOUS_ONE ; git checkout $BRANCH_TO_CHECKOUT^)
    diff $PREVIOUS_ONE/share/etc/oned.conf $CURRENT_ONE/share/etc/oned.conf
fi

exit -1
