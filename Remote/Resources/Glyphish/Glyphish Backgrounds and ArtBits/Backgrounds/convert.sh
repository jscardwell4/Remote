#!/bin/bash

for file in $@; do
    #statements
    convert $file png/$file.png
done
