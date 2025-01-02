# protobuf-linux-container

A containerized environment for developing [protocolbuffers/protobuf](https://github.com/protocolbuffers/protobuf) and
[shopify/protoboeuf](https://github.com/shopify/protoboeuf).

## Setup

0) Ensure you have `podman` and `shadowenv` installed
1) If need be, modify the environent variables in `.shadowenv.d/000_env.lisp`
2) `bin/build`

Everything in `bin` is meant to run on the host machine.  Everything in `script` will be mounted to `/home/dev/script`
and will end up in `PATH` in the container.

## Run

`bin/shell`
