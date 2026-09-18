# Makefile for Dungeon Bash

CC ?= cc

GAME = dungeonbash

OS ?= $(shell uname -s)

MAJVERS = 1
MINVERS = 7

# Flags shared by every platform
COMMON_CFLAGS = -g -Wall -Wstrict-prototypes -Wwrite-strings \
                -Wmissing-prototypes -Wredundant-decls -Wunreachable-code \
                -DMAJVERS=$(MAJVERS) -DMINVERS=$(MINVERS)

COMMON_LDLIBS = -lpanel -lncurses

ifeq ($(OS),Linux)
	CFLAGS = $(COMMON_CFLAGS)
	LDLIBS = $(COMMON_LDLIBS)
else ifeq ($(OS),Darwin)
	CFLAGS = $(COMMON_CFLAGS)
	LDLIBS = $(COMMON_LDLIBS)
else
	$(error Unsupported OS "$(OS)". Add a branch for it above.)
endif

SRCS = $(wildcard *.c)
OBJS = $(SRCS:.c=.o)

.PHONY: all run clean archive

all: $(GAME)

.DELETE_ON_ERROR:

$(GAME): $(OBJS)
	$(CC) $(OBJS) $(LDLIBS) -o $@

%.o: %.c
	$(CC) $(CFLAGS) -MMD -MP -c $< -o $@

-include $(OBJS:.o=.d)

run: $(GAME)
	./$(GAME)

ARCHIVE_DIR = dungeonbash-$(MAJVERS).$(MINVERS)-$(OS)

archive: clean
	mkdir -p /tmp/$(ARCHIVE_DIR) \
		&& cp -R . /tmp/$(ARCHIVE_DIR) \
		&& tar cvzf $(ARCHIVE_DIR).tar.gz -C /tmp $(ARCHIVE_DIR) \
		&& rm -rf /tmp/$(ARCHIVE_DIR)

clean:
	rm -f *.o *.d $(GAME) dunbash.log dunbash.sav.gz
