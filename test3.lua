--This is an example Lua (https://www.lua.org) script to give a general idea of how to build scripts
--Press F5 or click the Run button to execute it
--Type "emu." to show a list of all available API function

nmi_startcyc = 0
nmi_endcyc = 0

function mc()
	return emu.getState()["masterClock"]
end

function cb_nmi(address, value)
	nmi_startcyc = nmi_endcyc
	nmi_endcyc = mc()
	diff = nmi_endcyc - nmi_startcyc
	emu.log('nmi: ' .. tostring(diff))
end

function cb_fd(address, value)
	if value == 0x9 then
		nmi_startcyc = mc()
	elseif value == 0xA then
		nmi_endcyc = mc()
		diff = nmi_endcyc - nmi_startcyc
		emu.log('nm diff: ' .. tostring(diff))
	end
end


function printInfo()
  --Get the emulation state
  state = emu.getState()
  
end

-- emu.addMemoryCallback(cb_fd, 1, 0xFD)
emu.addMemoryCallback(cb_nmi, 2, 0x81DE)
