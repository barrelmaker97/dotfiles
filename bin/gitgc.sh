#!/bin/bash

 echo "Running 'git gc' for $1"
 cd "$1"
 git gc --quiet --auto
