#!/bin/bash
#
# Installs any dependencies from the ubuntu repos that are passed in as
# arguments.
#
# Make sure that the repositories are up to date
apt-get update

DEBIAN_FRONTEND=noninteractive apt-get install -y "$@"

# Clean up so that running this script doesn't needlessly increase the layer
# size of the docker image.
#
# Note: This does make each individual call to the script slower as both the
# apt-get update and the cleanup needs to run for every call

rm -rf /var/lib/apt/lists/*
apt-get autoremove --purge
apt-get clean all
