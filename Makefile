# Copyright (C) 2024 iProgramInCpp

AS = ca65
CC = cc65
LD = ld65

#DEBUGSW=
DEBUGSW=-DDEBUG

.PHONY: clean

build: celeste.nes

%.o: src/%.asm
	$(AS) -g --create-dep "$@.dep" --debug-info $< -o $@ --listing "$(notdir $@).lst" $(DEBUGSW)

celeste.nes: layout celeste.o
	$(LD) --dbgfile $@.dbg -C $^ -o $@ -m $@.map

clean:
	rm -f celeste.nes *.dep *.o *.dbg

include $(wildcard *.dep)
