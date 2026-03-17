FROM alpine:3.22 AS builder

RUN apk update && apk add \
    build-base \
    musl-dev \
    pkgconf \
    linux-headers \
    gmp-dev \
    gmp-static \
    curl \
    git \
    bash \
    ;

# Install Dune
RUN curl -fsSL https://get.dune.build/install | sh -s - --release latest
ENV DUNE_PROFILE=static

RUN mkdir /app
WORKDIR /app
COPY --chmod=0755 src src
COPY --chmod=0755 bin bin
COPY --chmod=0755 dune.lock dune.lock
COPY --chmod=0755 dune-project container-image.opam .

RUN mkdir /out
RUN PATH=$HOME/.local/bin:$PATH dune build @install --only-packages container-image --display=short
RUN PATH=$HOME/.local/bin:$PATH dune install --prefix=/out container-image

FROM scratch
COPY --from=builder /out .
RUN /out/bin/image --help
