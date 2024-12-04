
odd=0
bk=0

function cb(addr, value)
	if odd == 1 then
		emu.log('sine: ' .. tostring(bk) .. ': ' .. tostring(value))
		odd = 0
	else
		bk = value
		odd = 1
	end
end


emu.addMemoryCallback(cb, 1, 0xFF)
