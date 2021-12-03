Docker Image for AVR Projects
=============================

This is a custom Docker image I created for use with AVR microcontroller
projects. It contains the tools needed for CI operations on Github and Gitlab.

**LICENSE** The license for this project is the
[MIT License](https://opensource.org/licenses/MIT).

What is this for?
-----------------

In order to run the build and test operations for this my AVR projects, a
certain set of utilities are needed in a docker image. There is no pre-existing
image that has everything I need. To resolve this I can:

- break up CI pipeline into steps with each step using a different image
- add extra `apt-get install` commands in the pipeline script (takes longer)
- prepare my own docker image that has exactly the tools needed

The Dockerfile here can be used to build an image that is used with CI
operations for an AVR project.

The image, once built, needs to be pushed to the github container registry
(or the Gitlab equivalent). These are the steps to follow for Github:

### Login

Using your github credentials:

    (sudo) docker login ghcr.io -u <username>

you will be prompted for the password, which is a Github personal access
token. You can also pass the token on the command line through an environment
variable.

    export GITHUB_PERSONAL_TOKEN=(the token value)
    echo $GITHUB_PERSONAL_TOKEN | docker login ghcr.io -u USERNAME --password-stdin

### Build

    (sudo) docker build -t ghcr.io/ORGNAME/avr-build .

ORGNAME is a Github user name or organization name.

### Push

    (sudo) docker push ghcr.io/ORGNAME/avr-build:latest

### Usage

In the Github workflow file, use this container:

    ghcr.io/ORGNAME/avr-build:latest

Included Tools
--------------

It includes the AVR GCC compiler, tools like GNU Make, python3, and tools for
code-checking and testing. Take a look at the Dockerfile for the complete
list.

Makefile
--------

There is a Makefile to help with all of the above steps. Try `make help`.

Notes
-----

- I have deliberately not placed this on Dockerhub. Instead I use the container
  registry of the CI vendor, such as Github or Gitlab.
- Depending on your docker setup, you may or may not need `sudo`.
- After the build step, it is a good idea to run it locally and exercise the
  container to make sure it has all the packages you need and executes the
  build correctly (`make run`).
- If you have 2FA enabled on the account you will need to set up a personal
  access token for authentication.
- For more info, google `github ci container registry`
- Possible TODO: set up automation so that this image is built and tested on
  a push. With automated releases that upload the container to the registry.
