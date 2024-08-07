.PHONY: all
all:  pull images build

.PHONY: images
images:
	docker build -f Dockerfile-20.04 -t apt-build-20.04 .
	docker build -f Dockerfile-22.04 -t apt-build-22.04 .
	docker build -f Dockerfile-24.04 -t apt-build-24.04 .

.PHONY: pull
pull:
	docker pull ubuntu:20.04
	docker pull ubuntu:22.04
	docker pull ubuntu:24.04

.PHONY: build
build: build20.04 build22.04 build24.04

.PHONY: build20.04
build20.04:
	docker run -it --rm -v $(HOME)/.gnupg/pubring.gpg:/root/.gnupg/pubring.gpg \
		-v $(HOME)/.gnupg/secring.gpg:/root/.gnupg/secring.gpg \
		apt-build-20.04 \
		/build-all.sh

.PHONY: run20.04
run20.04:
	docker run -it --rm -v $(HOME)/.gnupg/pubring.gpg:/root/.gnupg/pubring.gpg \
		-v $(HOME)/.gnupg/secring.gpg:/root/.gnupg/secring.gpg \
		apt-build-20.04

.PHONY: build22.04
build22.04:
	docker run -it --rm -v $(HOME)/.gnupg/pubring.gpg:/root/.gnupg/pubring.gpg \
		-v $(HOME)/.gnupg/secring.gpg:/root/.gnupg/secring.gpg \
		apt-build-22.04 \
		/build-all.sh

.PHONY: run22.04
run22.04:
	docker run -it --rm -v $(HOME)/.gnupg/pubring.gpg:/root/.gnupg/pubring.gpg \
		-v $(HOME)/.gnupg/secring.gpg:/root/.gnupg/secring.gpg \
		apt-build-22.04

.PHONY: build24.04
build24.04:
	docker run -it --rm -v $(HOME)/.gnupg/pubring.gpg:/root/.gnupg/pubring.gpg \
		-v $(HOME)/.gnupg/secring.gpg:/root/.gnupg/secring.gpg \
		apt-build-24.04 \
		/build-all.sh
