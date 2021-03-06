# SPDX-License-Identifier: MIT
#
# Copyright 2021 Joseph Kroesche
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# set your ORGNAME and GITHUB_USERNAME
ORGNAME?=sectioncritical
GITHUB_USERNAME?=$(USERNAME)

# PROJECT_ROOT is used with the "run" target to determine how the
# /project path in the container is mapped to your file system.
# This is intended to be used for testing the container with your
# project files. Override this with the actual location of your project.
PROJECT_ROOT?=$(CURDIR)

TAG=avr-build
FULLTAG=$(TAG):latest
REMOTE_TAG=ghcr.io/$(ORGNAME)/$(FULLTAG)

all: build

.PHONY: help
help:
	@echo ""
	@echo "AVR Tools Docker Image Maintenance"
	@echo "----------------------------------"
	@echo "login       - login to github registry (asks for github access token)"
	@echo "build       - build the avr docker image"
	@echo "push        - push the avr docker image to github"
	@echo "run         - run container for local testing (PROJECT_ROOT)"
	@echo "images      - list local images"
	@echo "containers  - list local containers"
	@echo ""

.PHONY: build
build:
	docker build --progress=plain -t $(TAG) .
	docker tag $(FULLTAG) $(REMOTE_TAG)

.PHONY: login
login:
	docker login -u $(GITHUB_USERNAME) ghcr.io

.PHONY: push
push:
	docker push $(REMOTE_TAG)

.PHONY: containers
containers:
	docker container list --all

.PHONY: images
images:
	docker image list --all

.PHONY: run
run:
	cd $(PROJECT_ROOT); docker run -it -v $$(pwd):/project $(TAG) /bin/bash
