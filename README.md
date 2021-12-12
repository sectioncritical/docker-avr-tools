Docker Image for AVR Projects
=============================

This is a custom Docker image I created for use with AVR microcontroller
projects. It contains the tools needed for CI operations on Github and Gitlab.

**LICENSE:** The license for this project is the
[MIT License](https://opensource.org/licenses/MIT).

What is this for?
-----------------

In order to run the build and test operations for my AVR projects, a
certain set of utilities are needed in a docker image. There is no pre-existing
image that has everything I need. To resolve this I can:

- break up CI pipeline into steps with each step using a different image
- add extra `apt-get install` commands in the pipeline script (takes longer)
- prepare my own docker image that has exactly the tools needed

The Dockerfile here can be used to build an image that is used with CI
operations for an AVR project.

Makefile
--------

There is a Makefile to help with maintenance. Try:

```
$ make help


AVR Tools Docker Image Maintenance
----------------------------------
login       - login to github registry (asks for github access token)
build       - build the avr docker image
push        - push the avr docker image to github
run         - run container for local testing (PROJECT_ROOT)
images      - list local images
containers  - list local containers
```

Maintenance
-----------

Here are common maintenance steps:

### Build

    (sudo) docker build -t ghcr.io/ORGNAME/avr-build .

ORGNAME is a Github user name or organization name.

If you don't care about pushing it to a registry, then the tag can be anything.

**NOTE:** The first time you build it will take a long time. It builds bloaty
from source and this takes a long time. Once you build it once, it does not
have to be built again as long as you dont change that layer in the Dockerfile
or delete the image. If you dont care about bloaty, you can delete the bloaty
steps from the Dockerfile.

### Login

Using your github credentials:

    (sudo) docker login ghcr.io -u <username>

you will be prompted for the password, which is a Github personal access
token. You can also pass the token on the command line through an environment
variable.

    export GITHUB_PERSONAL_TOKEN=(the token value)
    echo $GITHUB_PERSONAL_TOKEN | docker login ghcr.io -u USERNAME --password-stdin

### Push

Push the image to Github so it can be used for workflow automation.

    (sudo) docker push ghcr.io/ORGNAME/avr-build:latest

### CI Usage

In the Github workflow file, use this container:

    ghcr.io/ORGNAME/avr-build:latest

### Local Testing

It can be useful to run the container locally to test your builds.

    docker run -it -v $(PROJECT_ROOT):/project $(TAG) /bin/bash

`PROJECT_ROOT` is the path on your local system that want to be mapped to
`/project` inside the container. It is probably the root directory of your
AVR project. It needs to be absolute path.

`TAG` is whatever tag was used in the build step (above).

Included Tools
--------------

- AVR toolchain
- [cppcheck] - code linter
- curl
- [doxygen] - for projects that generate docs during build
- git
- make
- python3
- zip/unzip
- [bloaty] - ELF image size analyzer
- [git-cliff] - release notes generator

[cppcheck]: https://github.com/danmar/cppcheck
[doxygen]: https://www.doxygen.nl/index.html
[bloaty]: https://github.com/google/bloaty
[git-cliff]: https://github.com/orhun/git-cliff

Notes
-----

- I have deliberately not placed this on Dockerhub. Instead I use the container
  registry of the CI vendor, such as Github or Gitlab.
- Depending on your docker setup, you may or may not need `sudo`.
- If you have 2FA enabled on the account you will need to set up a personal
  access token for authentication.
- For more info, google `github ci container registry`
- Possible TODO: set up automation so that this image is built and tested on
  a push. With automated releases that upload the container to the registry.
- Possible TODO: make bloaty optional part of the build.
