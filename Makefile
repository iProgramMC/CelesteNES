# Copyright (C) 2024 iProgramInCpp

AS = ca65
CC = cc65
LD = ld65

#DEBUGSW=
DEBUGSW=-DDEBUG

.PHONY: clean

build: main.nes

%.o: src/%.asm
	$(AS) -g --create-dep "$@.dep" --debug-info $< -o $@ --listing "$(notdir $@).lst" $(DEBUGSW)

main.nes: layout main.o
	$(LD) --dbgfile $@.dbg -C $^ -o $@ -m $@.map

clean:
	rm -f main.nes *.dep *.o *.dbg

include $(wildcard *.dep)
