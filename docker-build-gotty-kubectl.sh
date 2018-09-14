#!/usr/bin/env bash
docker build -f Dockerfile-gotty-kubectl-2 --build-arg http_proxy=http://192.168.147.1:8118 --build-arg https_proxy=http://192.168.147.1:8118 -t cwocwo/alpine-kubectl-with-gotty:1.0.0   .
