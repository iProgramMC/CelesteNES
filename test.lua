while true do
	pos = memory.readbyte(0x53)   -- read temp5
	gui.line(0, pos, 256, pos, 0x00FF00FF)
	pos = memory.readbyte(0x54)   -- read temp6
	gui.line(0, pos, 256, pos, 0x00FFFFFF)
	pos = memory.readbyte(0x60)   -- read address $60
	gui.line(0, pos, 256, pos, 0xFF00FFFF)
	pos = memory.readbyte(0x61)   -- read address $61
	gui.line(0, pos, 256, pos, 0xFFFF00FF)
	emu.frameadvance()
end