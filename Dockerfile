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
RUN GOOS=$(echo $TARGETPLATFORM | cut -f1 -d/) && \
    GOARCH=$(echo $TARGETPLATFORM | cut -f2 -d/) && \
    GOARM=$(echo $TARGETPLATFORM | cut -f3 -d/ | sed "s/v//" ) && \
    GO111MODULE=on && \
    CGO_ENABLED=0 GOOS=${GOOS} GOARCH=${GOARCH} GOARM=${GOARM} go build -ldflags '-X main.version=${VERSION}' -o ghostunnel && \
    cp ghostunnel /usr/bin/ghostunnel




# Create a multi-stage build with the binary
FROM alpine

RUN apk add --no-cache --update libtool curl
COPY --from=build /usr/bin/ghostunnel /usr/bin/ghostunnel

ENTRYPOINT ["/usr/bin/ghostunnel"]

