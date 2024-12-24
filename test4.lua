function test()
  --Get the emulation state
  state = emu.getState()
  
  --Get the mouse's state (x, y, left, right, middle)
  mouseState = emu.getMouseState()  
  
  if emu.isKeyPressed("Left Shift") then
  	emu.write(0x00, 0xC0, emu.memType.nesMemory);
  else
  	emu.write(0x00, 0x00, emu.memType.nesMemory);
  end
end

--Register some code (printInfo function) that will be run at the end of each frame
emu.addEventCallback(test, emu.eventType.endFrame);

--Display a startup message
emu.displayMessage("Script", "Example Lua script loaded.")