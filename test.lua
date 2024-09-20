y = 0

currra = 0
currx  = 0
curry  = 0
currrv = 0

local function wr_0(addr,sz,val)
	currx = val
	
	sp = 0x101 + memory.getregister('s')
	currra = memory.readbyte(sp) + memory.readbyte(sp + 1) * 256 - 2
end
local function wr_1(addr,sz,val)
	curry = val
end
local function wr_2(addr,sz,val)
	currrv = val
	
	gui.text(0, y, 'x: ' .. tostring(currx) .. ', y: ' .. tostring(curry) .. ', res: ' .. tostring(currrv) .. ', ra: ' .. tostring(currra))
	y = y + 10
end

memory.register(0x80, wr_0)
memory.register(0x81, wr_1)
memory.register(0x82, wr_2)

while true do
	y = 0
	emu.frameadvance()
end