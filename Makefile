
all:
	scripts/build.sh

clean:
	rm -f bin/* || true
	rm -rf .gopath || true

test:
	go test -v ./...

vet:
	go vet ./...

deps:
	go get -d github.com/ninjasphere/sphere-factory-test/sphere-io
	cd $(GOPATH)/src/github.com/ninjasphere/sphere-factory-test/sphere-io && go install
	go get -d github.com/ninjasphere/sphere-setup-assistant
	cd $(GOPATH)/src/github.com/ninjasphere/sphere-setup-assistant && make iwlib29

.PHONY: all	dist clean test
