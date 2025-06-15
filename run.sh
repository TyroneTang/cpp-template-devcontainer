#!/bin/bash

docker build --network=host \
             --target base \
             --tag localhost/cpp_base:latest \
             --file Dockerfile .