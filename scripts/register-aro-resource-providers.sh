#!/bin/bash

# This script to confirm that all needed Azure Resource Providers are registered
# Reference Link : https://learn.microsoft.com/en-us/azure/openshift/tutorial-create-cluster#register-the-resource-providers

az provider register -n Microsoft.RedHatOpenShift --wait
az provider register -n Microsoft.Compute --wait
az provider register -n Microsoft.Storage --wait
az provider register -n Microsoft.Authorization --wait
