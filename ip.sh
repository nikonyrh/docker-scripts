#!/bin/bash

prefix=$1
n=$2

REGEX="[^:]+:[ \t]*([0-9\.:a-f\/]+).+"

if [[ -z "$prefix" ]] ; then
    prefix="(192\.168|10\.0\.)"
fi

if [ "$prefix" == "--all" ] ; then
    ifconfig | grep 'addr:' | grep -v 'Scope:Link' | sed -r "s/$REGEX/\1/"
    exit 0
fi

if [[ -z "$n" ]] ; then
    n=1
fi

ifconfig | grep -E "addr:$prefix" | head "-n$n" | sed -r "s/$REGEX/\1/"

