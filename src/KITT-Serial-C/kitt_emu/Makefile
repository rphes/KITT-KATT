# General flags
CC      := gcc
CFLAGS  := -Wall -Wextra -Wno-unused-parameter
LDFLAGS :=

# Additional settings
DIRS    := ../libs
BIN     := ../bin/kitt

# Get data
CFLAGS  += $(foreach dir, $(DIRS), -I$(dir))
SRCF    := $(wildcard *.c) $(foreach dir, $(DIRS), $(wildcard $(dir)/*.c))
OBJF    := $(SRCF:%.c=%.o)

EBIN    := $(filter $(BIN), $(wildcard $(BIN)))
EOBJF   := $(wildcard *.o) $(foreach dir, $(DIRS), $(wildcard $(dir)/*.o))

# Object files to binary
$(BIN): $(OBJF) $(filter $(BIN).h, $(wildcard *.h))
	@echo Linking $(BIN)
	$(CC) $(CFLAGS) $(OBJF) $(LDFLAGS) -o $(BIN)

# Source files to object files
%.o: %.c %.h
	@echo Compiling $<
	$(CC) $(CFLAGS) -c -o $@ $<

# Cleaning
.phony: clean

clean:
ifneq '$(EOBJF: =)' ''
	@echo Removing all object files
	rm $(EOBJF)
endif