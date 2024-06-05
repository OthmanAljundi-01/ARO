#!/bin/bash

az extension list -o table
mkdir aro-extension-wheel-file
cd aro-extension-wheel-file
wget https://arosvc.blob.core.windows.net/azext/aro-1.0.9-py2.py3-none-any.whl
ls -lrt
az extension add --upgrade -s aro-1.0.9-py2.py3-none-any.whl
az extension list -o table


# You will have the Following Output in your Azure CLI Shell :

# Experimental    ExtensionType    Name               Path                                          Preview    Version
# --------------  ---------------  -----------------  --------------------------------------------  ---------  ---------
# 
# False           whl              aro                /root/.azure/cliextensions/aro                True       1.0.9


