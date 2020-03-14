FROM --platform=$BUILDPLATFORM golang:1.13-alpine AS build


ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG version="v1.5.2"

# Dependencies
RUN apk add --no-cache --update gcc musl-dev libtool make git

# Clone source
WORKDIR /src
RUN git clone https://github.com/square/ghostunnel.git

WORKDIR /src/ghostunnel
RUN git checkout ${version}


# Build
RUN GO111MODULE=on make clean ghostunnel && \
    cp ghostunnel /usr/bin/ghostunnel




# Create a multi-stage build with the binary
FROM alpine

RUN apk add --no-cache --update libtool curl
COPY --from=build /usr/bin/ghostunnel /usr/bin/ghostunnel

ENTRYPOINT ["/usr/bin/ghostunnel"]

