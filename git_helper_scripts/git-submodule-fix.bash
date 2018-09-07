#!/bin/bash 

for arg 
do 
  echo $arg 
  find . -name "`basename $arg`" | grep "$arg\$" | xargs rm -fr
done
