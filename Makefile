# Makefile for Dungeon Bash

PATHU = unity/src/
PATHS = src/
PATHT = test/
PATHB = build/
PATHD = build/depends/
PATHO = build/objs/
PATHR = build/results/

BUILD_PATHS = $(PATHB) $(PATHD) $(PATHO) $(PATHR)

OBJS = \
	$(PATHB)bmagic.o \
	$(PATHB)combat.o \
	$(PATHB)display.o \
	$(PATHB)main.o \
	$(PATHB)map.o \
	$(PATHB)misc.o \
	$(PATHB)monsters.o \
	$(PATHB)mon2.o \
	$(PATHB)objects.o \
	$(PATHB)permobj.o \
	$(PATHB)permons.o \
	$(PATHB)pmon2.o \
	$(PATHB)rng.o \
	$(PATHB)u.o \
	$(PATHB)vector.o

# objects used when linking tests.  We used to drop the
# game `main` object because Unity provides its own `main()` but
# the helper routines such as `dice()` and `convert_range()` live in
# main.c.  Excluding $(PATHB)main.o left tests with lots of
# undefined symbols.  Instead we leave all objects in and prevent the
# real `main()` from ever being compiled when building tests (see
# `main.c` change).  The variable remains for backwards compatibility
# but now equals all objects.
PROJECT_OBJS := $(OBJS)  # include main.o; `main()` is suppressed under TEST


GAME=dungeonbash

OS ?= $(shell uname -s)

MAJVERS=1
MINVERS=7
ifeq ($(OS),Linux)
	CFLAGS=-c -g -Wall -Wstrict-prototypes -Wwrite-strings \
	-Wmissing-prototypes -Wredundant-decls -Wunreachable-code \
	-DMAJVERS=$(MAJVERS) -DMINVERS=$(MINVERS) -MMD -MP\
	-I. -I$(PATHU) -I$(PATHS) -DTEST
else ifeq ($(OS), Darwin)
	CFLAGS=-c -g -Wall -Wstrict-prototypes -Wwrite-strings \
	-Wmissing-prototypes -Wredundant-decls -Wunreachable-code \
	-DMAJVERS=$(MAJVERS) -DMINVERS=$(MINVERS) -MMD -MP\
	-I. -I$(PATHU) -I$(PATHS) -DTEST
else
	$(error "Unsupported OS: $(OS)")
endif
LINKFLAGS=-lpanel -lncurses -g

# helper target to create build directories
.PHONY: dirs
dirs:
	@mkdir -p $(BUILD_PATHS)

all: dirs $(GAME)

.DELETE_ON_ERROR:
$(GAME): $(OBJS)
	$(CC) $(OBJS) $(LINKFLAGS) -o $(GAME)

$(PATHB)%.o: $(PATHS)%.c
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) $< -o $@

# look for any test sources under $(PATHT)
TESTSRC := $(wildcard $(PATHT)*.c)
# corresponding object files in build directory
TESTOBJS := $(patsubst $(PATHT)%.c,$(PATHB)test_%.o,$(TESTSRC))

.PHONY: test
# run unit tests if any exist; otherwise just print a message
test: $(GAME) $(TESTOBJS)
	@if [ -n "$(TESTSRC)" ]; then \
		$(CC) $(TESTOBJS) $(PATHU)unity.c $(OBJS) $(LINKFLAGS) -o $(PATHR)test_runner && \
		mkdir -p $(PATHR) && \
		./$(PATHR)test_runner 2>&1 | tee $(PATHR)test_output.txt; \
		echo "-----------------------\nIGNORES:\n-----------------------"; \
		grep -s IGNORE $(PATHR)test_output.txt || true; \
		echo "-----------------------\nFAILURES:\n-----------------------"; \
		grep -s FAIL $(PATHR)test_output.txt || true; \
		echo "\nDONE"; \
	else \
		echo "No tests found in $(PATHT)"; \
	fi

$(PATHB)test_%.o: $(PATHT)%.c
	$(CC) $(CFLAGS) $< -o $@

.PHONY: archive
archive: clean
	(cd .. && tar cvzf dungeonbash-$(MAJVERS).$(MINVERS).tar.gz dungeonbash-$(MAJVERS).$(MINVERS))

.PHONY: run
run: $(GAME)
	./$(GAME)

.PHONY: clean
clean:
	-rm -f $(PATHB)*.o $(GAME) dunbash.log dunbash.sav.gz
	-rm -f $(PATHB)*.d

-include $(OBJS:.o=.d)
-include $(TESTOBJS:.o=.d)