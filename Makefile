GULP=@./node_modules/.bin/gulp
VERSION?=$(shell git rev-parse --verify HEAD --short=6)
PUBLISHED_VERSION=$(shell npm view cmpnt version | sed ':a;N;$!ba;s/\n/ /g')
DOCSITE=cmpnt.vistarmedia.com
BUILD_DIR=./build
DOCSITE_DIR=./demo/build


publish_docs: build
	s3cmd sync --acl-public $(DOCSITE_DIR)/ s3://$(DOCSITE)

update:
	@npm install

clean:
	git checkout $(BUILD_DIR)/package.json
	@find ./build ! -iname package.json -type f -delete
	@rm -rf $(DOCSITE_DIR)/*

test:
	$(GULP) test

build: clean update
	$(GULP) project
	$(GULP) default

publish:
	cd $(BUILD_DIR) && npm publish .

prerelease_version:
	sed -i s/$(PUBLISHED_VERSION)/$(PUBLISHED_VERSION)-pre-$(VERSION)/g \
		$(BUILD_DIR)/package.json

prerelease: build prerelease_version publish publish_docs

release: build publish publish_docs

link: build
	cd $(BUILD_DIR) && npm link .


.PHONY: test build
