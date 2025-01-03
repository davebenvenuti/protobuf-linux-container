FROM ubuntu:noble

RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    unzip \
    curl \
    # The following are required for Ruby
    zlib1g-dev \
    libffi-dev \
    libyaml-dev \
    # Required for YJIT specifically
    rustc

ARG GOOGLE_PROTOBUF_CONTAINER_DIR
ENV GOOGLE_PROTOBUF_CONTAINER_DIR ${GOOGLE_PROTOBUF_CONTAINER_DIR}
ARG SHOPIFY_PROTOBOEUF_CONTAINER_DIR
ENV SHOPIFY_PROTOBOEUF_CONTAINER_DIR ${SHOPIFY_PROTOBOEUF_CONTAINER_DIR}

# Install Ruby via rbenv
ARG RUBY_VERSION
ENV RUBY_VERSION ${RUBY_VERSION}

ENV RBENV_ROOT "/opt/rbenv"

RUN git clone https://github.com/rbenv/rbenv.git /opt/rbenv
ENV PATH "/opt/rbenv/bin:${PATH}"
RUN git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build
RUN rbenv init - --no-rehash bash > /etc/profile.d/02-rbenv.sh
RUN ["bash", "-c", ". /etc/profile.d/02-rbenv.sh && rbenv install ${RUBY_VERSION} -- --enable-yjit"]
RUN ["bash", "-c", "rbenv global ${RUBY_VERSION}"]

## Install protoc
ARG PROTOC_VERSION
ENV PROTOC_VERSION ${PROTOC_VERSION}

ENV PROTOC_RELEASE_BASE_URL "https://github.com/protocolbuffers/protobuf/releases/download"
ENV PROTOC_ZIP "protoc-${PROTOC_VERSION}-linux-x86_64.zip"
ENV PROTOC_FULL_DOWNLOAD_URL "${PROTOC_RELEASE_BASE_URL}/v${PROTOC_VERSION}/${PROTOC_ZIP}"

RUN mkdir -p /opt/protoc

RUN echo "Downloading ${PROTOC_FULL_DOWNLOAD_URL}" && \
    curl -L ${PROTOC_FULL_DOWNLOAD_URL} -o /tmp/${PROTOC_ZIP}

RUN unzip /tmp/${PROTOC_ZIP} -d /opt/protoc

ENV PATH "/opt/protoc/bin:${PATH}"

## Setup the dev user
RUN useradd -ms /bin/bash dev

RUN chown -R dev:dev /opt/rbenv /opt/protoc

USER dev
WORKDIR /home/dev

RUN mkdir -p ${GOOGLE_PROTOBUF_CONTAINER_DIR} ${SHOPIFY_PROTOBOEUF_CONTAINER_DIR} /home/dev/script
ENV PATH "/home/dev/script:${PATH}"

RUN ["bash", "--login", "-c", "gem install syntax_tree"]

CMD ["sleep", "infinity"]
