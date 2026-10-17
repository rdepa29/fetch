CC ?= cc
CFLAGS ?= -O2
PREFIX ?= /usr/local
LDFLAGS ?=
LDLIBS = -lm
VERSION := $(shell cat VERSION)
CODENAME ?= Overclocked ASCII
RM ?= rm -f

ifeq ($(OS),Windows_NT)
  EXEEXT := .exe
  UNAME_S := Windows
  ifeq ($(PROCESSOR_ARCHITECTURE),AMD64)
    UNAME_M := x86_64
  else ifeq ($(PROCESSOR_ARCHITECTURE),ARM64)
    UNAME_M := aarch64
  else
    UNAME_M := $(PROCESSOR_ARCHITECTURE)
  endif
  LDLIBS += -lws2_32 -liphlpapi -lpsapi
  ifdef HOME
    BINDIR := $(HOME)/bin
  else
    BINDIR := $(USERPROFILE)/bin
  endif
else
  EXEEXT :=
  UNAME_S := $(shell uname -s)
  UNAME_M := $(shell uname -m)
  ifeq ($(UNAME_S),Darwin)
    LDLIBS += -framework IOKit -framework CoreFoundation
  endif
  BINDIR := $(PREFIX)/bin
endif

TARGET := fetch$(EXEEXT)

$(TARGET): fetch.c
	$(CC) $(CFLAGS) $(LDFLAGS) -DFETCH_VERSION='"$(VERSION)"' -DFETCH_CODENAME='"$(CODENAME)"' -DFETCH_ARCH='"$(UNAME_M)"' -DFETCH_OS='"$(UNAME_S)"' -o $@ $< $(LDLIBS)

install: $(TARGET)
	install -d $(DESTDIR)$(BINDIR)
	install -m 755 $(TARGET) $(DESTDIR)$(BINDIR)/fetch$(EXEEXT)

clean:
	$(RM) $(TARGET) tests/shared$(EXEEXT)

tests/shared$(EXEEXT): tests/shared.c fetch.c
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $< $(LDLIBS)

test: $(TARGET) tests/shared$(EXEEXT)
	./tests/shared$(EXEEXT)
	python3 tests/posix.py

.PHONY: install clean test
