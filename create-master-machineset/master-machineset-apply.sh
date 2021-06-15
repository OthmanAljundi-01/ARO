#!/bin/bash

for i in `cat masternodes.txt`
do
echo Applying $i.yaml
oc apply -f $i.yaml
done

