GULP=./node_modules/.bin/gulp
VERSION?=$(shell git rev-parse --verify HEAD --short=6)
DOCSITE=cmpnt.vistarmedia.com
BUILD_DIR=./build
DOCSITE_DIR=./demo/build

ifeq "$(ENVIRONMENT)" "production"
AUTOVERSION=$(shell $(GULP) autoversion --silent)
endif


publish_docs: build
	s3cmd sync --acl-public $(DOCSITE_DIR)/ s3://$(DOCSITE)

update:
	@npm install

clean_build_package_json:
	@git checkout $(BUILD_DIR)/package.json

clean: clean_build_package_json
	@find ./build ! -iname package.json -type f -delete
	@rm -rf $(DOCSITE_DIR)/*

test:
	@$(GULP) test

build: clean update
	@$(GULP) project
	@$(GULP) default

autoversion: clean_build_package_json
	@sed -i \
	  's/CMPNT_VERSION/$(AUTOVERSION)/g' \
		build/package.json

publish: autoversion
	cd $(BUILD_DIR) && npm publish .

tag:
	@git tag $(AUTOVERSION) HEAD
	@git push origin --tags

release: build publish tag publish_docs

link: build
	cd $(BUILD_DIR) && npm link .


.PHONY: test build tag
