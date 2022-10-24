# syntax=docker/dockerfile:1.4

ARG BUILDER_BASE=rust:bullseye
ARG RUNTIME_BASE=debian:bullseye

FROM --platform=${TARGETPLATFORM} ${BUILDER_BASE} AS builder

RUN apt-get update \
  && apt-get install -y \
  clang \
  && rm -rf /var/lib/apt/lists/*

FROM --platform=${TARGETPLATFORM} ${RUNTIME_BASE} AS runtime

RUN apt-get update \
  && apt-get install -y \
  ca-certificates \
  jq \
  curl \
  && rm -rf /var/lib/apt/lists/*

FROM --platform=${TARGETPLATFORM} builder AS build

WORKDIR /build

# Build the binaries.
RUN \
  --mount=type=bind,target=.,readwrite \
  --mount=type=cache,target=/usr/local/rustup,id=${TARGETPLATFORM} \
  --mount=type=cache,target=/usr/local/cargo/registry,id=${TARGETPLATFORM} \
  --mount=type=cache,target=target,id=${TARGETPLATFORM} \
  RUST_BACKTRACE=1 \
  cargo build --release --workspace

# Copy the binaries out.
RUN --mount=type=cache,target=target,id=${TARGETPLATFORM} \
  mkdir -p /artifacts \
  && cd target/release \
  && cp -t /artifacts \
  gitget \
  && ls -la /artifacts

FROM --platform=${TARGETPLATFORM} runtime AS gitget
COPY --from=build /artifacts/gitget /usr/local/bin
RUN ldd /usr/local/bin/gitget
CMD ["gitget"]

FROM --platform=${TARGETPLATFORM} scratch
# We put the dummy image last to force users to
# use the `docker build . --target <build stage>` invocation.
