FROM --platform=linux ubuntu:22.04
ARG BUILDARCH

# Change your versions here
ENV GO_VERSION=1.18.3
ENV IGNITE_VERSION=0.22.1
ENV NODE_VERSION=18.x

ENV LOCAL=/usr/local
ENV GOROOT=$LOCAL/go
ENV HOME=/root
ENV GOPATH=$HOME/go
ENV PATH=$GOROOT/bin:$GOPATH/bin:$PATH

RUN mkdir -p $GOPATH/bin

ENV PACKAGES curl gcc jq
RUN apt-get update
RUN apt-get install -y $PACKAGES

# Install Go
RUN curl -L https://go.dev/dl/go${GO_VERSION}.linux-$BUILDARCH.tar.gz | tar -C $LOCAL -xzf -

# Install Ignite
RUN curl -L https://get.ignite.com/cli@v${IGNITE_VERSION}! | bash

# Install Node
RUN curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION} | bash -
RUN apt-get install -y nodejs

EXPOSE 1317 4500 5000 26657

WORKDIR /checkers

COPY go.mod /checkers/go.mod
RUN go mod download
RUN rm /checkers/go.mod

# Create the image
# $ docker build -f Dockerfile-ubuntu . -t checkers_i
# To test only 1 command
# $ docker run --rm -it -v $(pwd):/checkers -w /checkers checkers_i go test github.com/b9lab/checkers/x/checkers/keeper
# To build container
# $ docker create --name checkers -i -v $(pwd):/checkers -w /checkers -p 1317:1317 -p 3000:3000 -p 4500:4500 -p 5000:5000 -p 26657:26657 checkers_i
# $ docker start checkers
# To run server on it
# $ docker exec -it checkers ignite chain serve --reset-once
# In other shell, to query it
# $ docker exec -it checkers checkersd query checkers list-stored-game