# See: http://clarkgrubb.com/makefile-style-guide
SHELL             := bash
.SHELLFLAGS       := -eu -o pipefail -c
.DEFAULT_GOAL     := default
.DELETE_ON_ERROR  :
.SUFFIXES         :

PROJECT   := vamp-gateway-agent
TARGET    := $(CURDIR)/target

# Determine which version we're building
ifeq ($(shell git describe --tags),$(shell git describe --abbrev=0 --tags))
	export VERSION := $(shell git describe --tags)
else
	ifeq ($(VAMP_GIT_BRANCH), $(filter $(VAMP_GIT_BRANCH), master ""))
		export VERSION := katana-$$(git describe --tags)
	else
		export VERSION := $(subst /,_,$(VAMP_GIT_BRANCH))-$$(git describe --tags)
	endif
endif

# if Makefile.local exists, include it.
ifneq ("$(wildcard Makefile.local)", "")
	include Makefile.local
endif

.PHONY: version
version:
	@echo $(VERSION)

.PHONY: clean
clean:
	rm -Rf $(TARGET)

.PHONY: purge
purge:
	docker rmi -f magneticio/$(PROJECT):$(VERSION)

.PHONY: build
build:
	mkdir -p $(TARGET) || true
	@echo "Creating docker build context"
	cp $(CURDIR)/Dockerfile $(TARGET)/Dockerfile
	cp -Rf $(CURDIR)/files $(TARGET)
	echo $(VERSION) > $(TARGET)/version
	cd $(TARGET) && \
	docker build -t magneticio/$(PROJECT):$(VERSION) .

.PHONY: default
default: clean build
