#!/bin/bash

set -e

sudo docker build \
    -t cnode \
    .
