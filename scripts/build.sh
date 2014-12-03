#!/usr/bin/env bash
set -ex

OWNER=ninjasphere
BIN_NAME=sphere-factory-reset
PROJECT_NAME=sphere-factory-reset


# Get the parent directory of where this script is.
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ] ; do SOURCE="$(readlink "$SOURCE")"; done
DIR="$( cd -P "$( dirname "$SOURCE" )/.." && pwd )"

GIT_COMMIT="$(git rev-parse HEAD)"
GIT_DIRTY="$(test -n "`git status --porcelain`" && echo "+CHANGES" || true)"
VERSION="$(grep "const Version " version.go | sed -E 's/.*"(.+)"$/\1/' )"

PRIVATE_PKG="ninjasphere/go-ninja ninjasphere/sphere-setup-assistant ninjasphere/sphere-go-led-controller ninjasphere/driver-go-blecombined ninjasphere/sphere-factory-test"

# remove working build
# rm -rf .gopath
if [ ! -d ".gopath" ]; then
	mkdir -p .gopath/src/github.com/${OWNER}
	ln -sf ../../../.. .gopath/src/github.com/${OWNER}/${PROJECT_NAME}
fi

export GOPATH="$(pwd)/.gopath"

for p in $PRIVATE_PKG; do
    if [ ! -d $GOPATH/src/github.com/$p ]; then
		git clone git@github.com:${p}.git $GOPATH/src/github.com/$p
    fi
done

# move the working path and build
cd .gopath/src/github.com/${OWNER}/${PROJECT_NAME}
go get -d -v ./...

make deps
