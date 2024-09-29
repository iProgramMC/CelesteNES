--This is an example Lua (https://www.lua.org) script to give a general idea of how to build scripts
--Press F5 or click the Run button to execute it
--Type "emu." to show a list of all available API function

function printInfo()
  --Get the emulation state
  state = emu.getState()
  
  ishigh=emu.read(0x19,emu.memType.nesDebug)
  xscr = emu.read(0x14, emu.memType.nesDebug)
  
  col=0x00FFFF
  if ishigh ~= 0 then
  	col=0xFF00FF
  end
  
  emu.drawLine(-xscr+255, 0, -xscr+255, 240, col)
end

--Register some code (printInfo function) that will be run at the end of each frame
emu.addEventCallback(printInfo, emu.eventType.endFrame);

--Display a startup message
emu.displayMessage("Script", "Example Lua script loaded.")