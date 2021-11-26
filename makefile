NAME=hocus
SRC=src/*.swift
PLATFORM=x86_64-apple-macosx
BUILD=.build/$(PLATFORM)/debug
SUPPORT=SupportFiles
PACKAGE=$(NAME).app/Contents/MacOS/

install: build $(PACKAGE)

build:
	swift build

$(PACKAGE):
	mkdir -p $(PACKAGE) &&\
	cp -R $(SUPPORT)/* $(NAME).app/Contents &&\
	cp $(BUILD)/$(NAME) $(PACKAGE)

run: install
	open $(NAME).app

clean:
	rm -rf .buid
	rm -rf $(NAME).app

re: clean install

.PHONY: install build clean re run
