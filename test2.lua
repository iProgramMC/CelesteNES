--This is an example Lua (https://www.lua.org) script to give a general idea of how to build scripts
--Press F5 or click the Run button to execute it
--Type "emu." to show a list of all available API function

transition_startcyc = 0
transition_endcyc = 0
regframe_startcyc = 0
regframe_endcyc = 0
palflush_startcyc = 0
palflush_endcyc = 0
colflush_startcyc = 0
colflush_endcyc = 0
nmi_startcyc = 0
nmi_endcyc = 0
nmibetween_startcyc = 0
nmibetween_endcyc = 0
colloadthisframe = 0

function mc()
	return emu.getState()["masterClock"]
end

function cb_f9(address, value)
-----------------------
	if value == 0x1 then
		-- end frame
		transition_endcyc = mc()
		diff = transition_endcyc - transition_startcyc
		
		emu.log('TR diff: ' .. tostring(diff))	
	elseif value == 0x0 then
		transition_startcyc = mc()
-----------------------
	elseif value == 0x2 then
		-- end frame
		regframe_endcyc = mc()
		diff = regframe_endcyc - regframe_startcyc
		emu.log('RG diff: ' .. tostring(diff) .. ', colload this frame: ' .. tostring(colloadthisframe))
		colloadthisframe = 0
	elseif value == 0x3 then
		regframe_startcyc = mc()
	elseif value == 0x4 then
		colloadthisframe = 1
-----------------------
	elseif value == 0x5 then
		colflush_startcyc = mc()
	elseif value == 0x6 then
		colflush_endcyc = mc()
		diff = colflush_endcyc - colflush_startcyc
		emu.log('CF diff: ' .. tostring(diff))
-----------------------
	elseif value == 0x7 then
		palflush_startcyc = mc()
	elseif value == 0x8 then
		palflush_endcyc = mc()
		diff = palflush_endcyc - palflush_startcyc
		emu.log('PF diff: ' .. tostring(diff))
-----------------------
	elseif value == 0x9 then
		nmi_startcyc = mc()
		nmibetween_endcyc = mc()
		diff = nmibetween_endcyc - nmibetween_startcyc
		emu.log('nb diff: ' .. tostring(diff))
	elseif value == 0xA then
		nmi_endcyc = mc()
		nmibetween_startcyc = mc()
		diff = nmi_endcyc - nmi_startcyc
		nmi_startcyc = mc()
		emu.log('nm diff: ' .. tostring(diff))
	end
end


function printInfo()
  --Get the emulation state
  state = emu.getState()
  
end

emu.addMemoryCallback(cb_f9, 1, 0xFA)
