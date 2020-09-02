#!/bin/bash

while true; do
    /usr/bin/python3 manage.py pruneflips
    ret=$?
    if [ $ret -ne 0 ]; then
        exit $ret
    fi
    sleep $1
done
