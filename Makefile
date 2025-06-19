# Makefile for RV1106 SDK cross-compilation environment

# Configuration
IMAGE_NAME := rv1106-sdk
IMAGE_TAG := latest
CONTAINER_NAME := rv1106-build
CONTAINER_MOUNT_POINT := /opt/rv1106_firmware

# Default host mount path (can be overridden via command line)
HOST_MOUNT_PATH ?= $(shell pwd)/rv1106_firmware

REPO_URL ?= git@github.com:frodobots-org/RV1106_1.8.3.git
BRANCH_NAME ?= ethan-dev

.PHONY: check-repo
check-repo:
	@if [ ! -d "$(HOST_MOUNT_PATH)" ]; then \
		echo "rv1106_firmware directory not found，start to clone..."; \
		git clone -b $(BRANCH_NAME) $(REPO_URL) $(HOST_MOUNT_PATH); \
	else \
		echo "rv1106_firmware directory has already exsit, skip clone..."; \
	fi

# Targets
.PHONY: all build run exec clean distclean compile dtb

all: check-repo
	echo "check-repo done."

prepare:
	cd $(HOST_MOUNT_PATH) && git submodule update --init --recursive
	cd $(HOST_MOUNT_PATH)/frodobots && git submodule update --init --recursive
	docker run --rm \
		-v $(HOST_MOUNT_PATH):$(CONTAINER_MOUNT_POINT) \
		-w $(CONTAINER_MOUNT_POINT) \
		$(IMAGE_NAME):$(IMAGE_TAG) \
		bash -c "cd frodobots && ./scripts/build-third-party.sh cross-compile"

# Build Docker image
build:
	docker build -t $(IMAGE_NAME):$(IMAGE_TAG) .

# Run SDK container with volume mount
run:
	docker run -it --rm \
		--name $(CONTAINER_NAME) \
		-v $(HOST_MOUNT_PATH):$(CONTAINER_MOUNT_POINT) \
		-w $(CONTAINER_MOUNT_POINT) \
		$(IMAGE_NAME):$(IMAGE_TAG)

# Execute command in running container
exec:
	docker exec -it $(CONTAINER_NAME) bash

# Clean intermediate build files (adjust according to SDK)
clean:
	@echo "Cleaning SDK build artifacts..."
	@# Add SDK-specific clean commands here

# Remove Docker image
distclean: clean
	docker rmi -f $(IMAGE_NAME):$(IMAGE_TAG)

# Example: Build SDK project (customize based on your SDK)
compile-mini:
	docker run --rm \
		-v $(HOST_MOUNT_PATH):$(CONTAINER_MOUNT_POINT) \
		-w $(CONTAINER_MOUNT_POINT) \
		$(IMAGE_NAME):$(IMAGE_TAG) \
		bash -c "echo '9' | ./build.sh lunch && ./build.sh all mini"

compile-miniplus:
	docker run --rm \
		-v $(HOST_MOUNT_PATH):$(CONTAINER_MOUNT_POINT) \
		-w $(CONTAINER_MOUNT_POINT) \
		$(IMAGE_NAME):$(IMAGE_TAG) \
		bash -c "echo '9' | ./build.sh lunch && ./build.sh all miniplus"
