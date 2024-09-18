while true do
	pos = memory.readbyte(0x53)   -- read address $53
	gui.line(0, pos, 256, pos)
	emu.frameadvance()
end