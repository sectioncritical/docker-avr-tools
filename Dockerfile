# This container provides tools for AVR microcontroller development.

# The tool bloaty must be built from source. The process of building it
# adds a lot of large libraries and other packages that are not needed
# to run the final binary. This layer is just for building the bloaty
# binary which is copied out later.

FROM debian:latest AS bloaty
RUN apt-get update          \
    && apt-get install -y   \
        build-essential     \
        cmake               \
        git                 \
        make                \
        pkg-config          \
        unzip zip           \
        zlib1g-dev          \
    && rm -rf /var/lib/apt/lists/*

# build bloaty - need to build from source
# using a recent commit instead of released to get AVR support
RUN git clone https://github.com/google/bloaty.git \
    && cd bloaty \
    && git checkout 472f139f3cc2b1e5c7b95b9a3fa9ba8a00e49743 \
    && cmake -B build -G "Unix Makefiles" -S . \
    && cmake --build build \
    && cmake --build build --target install \
    && cd .. \
    && rm -rf bloaty \
    && strip /usr/local/bin/bloaty

# Layer for git-cliff tool

FROM debian:latest AS gitcliff
RUN apt-get update          \
    && apt-get install -y   \
        binutils            \
        curl                \
        gnupg               \
    && rm -rf /var/lib/apt/lists/*

# add git-cliff tool for generating changelogs
# binary is downloaded from github
RUN mkdir git-cliff \
    && cd git-cliff \
    && curl -OL https://github.com/orhun/git-cliff/releases/download/v0.4.2/git-cliff-0.4.2-x86_64-unknown-linux-gnu.tar.gz \
    && curl -OL https://github.com/orhun/git-cliff/releases/download/v0.4.2/git-cliff-0.4.2-x86_64-unknown-linux-gnu.tar.gz.sig \
    && curl -OL https://github.com/orhun/git-cliff/releases/download/v0.4.2/git-cliff-0.4.2-x86_64-unknown-linux-gnu.tar.gz.sha512 \
    && gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys 1D2D410A741137EBC544826F4A92FA17B6619297 \
    && gpg --verify git-cliff-0.4.2-x86_64-unknown-linux-gnu.tar.gz.sig \
    && sha512sum --check git-cliff-0.4.2-x86_64-unknown-linux-gnu.tar.gz.sha512 \
    && tar -zxvf git-cliff-0.4.2-x86_64-unknown-linux-gnu.tar.gz \
    && cp git-cliff-0.4.2/git-cliff /usr/local/bin/. \
    && cd .. \
    && rm -rf git-cliff \
    && strip /usr/local/bin/git-cliff

# This is the image that will have all the AVR build tools

FROM python:3.10-slim-bullseye
WORKDIR /project

# base tools
RUN apt-get update          \
    && apt-get install -y   \
        avr-libc            \
        cppcheck            \
        curl                \
        doxygen             \
        gcc-avr             \
        git                 \
        make                \
        pkg-config          \
        unzip zip           \
    && rm -rf /var/lib/apt/lists/*

# copy the git-cliff utility from the earlier image
COPY --from=gitcliff /usr/local/bin/git-cliff /usr/local/bin/.

# copy the bloaty utility from the earlier image
COPY --from=bloaty /usr/local/bin/bloaty /usr/local/bin/.

CMD ["/bin/bash"]
