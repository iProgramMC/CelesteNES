
odd=0
bk=0

function cb(addr, value)
	if odd == 1 then
		val = (value * 0x100) + bk
		entid = emu.getState()["cpu.y"]
		emu.log('offscreen pos for ' .. tostring(entid) .. ': ' .. tostring(val))
		odd = 0
	else
		bk = value
		odd = 1
	end
end


emu.addMemoryCallback(cb, 1, 0xFC)
