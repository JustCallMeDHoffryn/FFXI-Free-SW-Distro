--	---------------------------------------------------------------------------
--	This file contains the outer core of Almanac, it handles the global tables
--	---------------------------------------------------------------------------
--
--	This code is FREE to use as you want, just please don't claim credit 
--	for my work (such as it is)
--
--	Many of the ideas used in this Addon were learnt from the work of 
--	the following coders ...
--
--		atom0s			..	blumon
--		zach2good		..	Captain
--		atom0s & Thorny	..	autojoin
--		Sippius			..	Chains
--	
--		Team HXUI (Tirem, Shuu, colorglut, RheaCloud
--
--	A BIG thank you to the above for paving the way
--
--	---------------------------------------------------------------------------

--	---------------------------------------------------------------------------
	addon.name      = 'almanac'
	addon.author    = 'DHoffryn'
	addon.version   = '0.1'
	addon.desc      = 'Fish hunters almanac'
--	---------------------------------------------------------------------------

require('common')
local ui = require('ui')

--	---------------------------------------------------------------------------
-- 	event: load
-- 	 desc: Event called when the addon is being loaded.
--	---------------------------------------------------------------------------

ashita.events.register('load', 'load_cb', ui.load)

--	---------------------------------------------------------------------------
--	event: command
--	 desc: Event called when the addon is processing a command.
--	---------------------------------------------------------------------------

ashita.events.register('command', 'command_cb', function (event)
    
	-- Parse the command arguments..
	
    local args = event.command:args()
    
	if (#args == 0 or not args[1]:any('/faf')) then
        return
    end

    -- Block all related commands..
	
    event.blocked = true

    -- Handle: /faf
	
    if (#args >= 1) then
        
		if (args[1] == '/faf') then
		
			ui.is_open[1] = not ui.is_open[1]
			ui.SaveState(ui.is_open[1])

			end
			
		return
    end

end)

--	---------------------------------------------------------------------------
--	event: packet_in
--	 desc: Event called when the addon is processing incoming packets.
--	---------------------------------------------------------------------------

ashita.events.register('packet_in', 'packet_in_cb', ui.packet_in);

--	---------------------------------------------------------------------------
--	event: d3d_present
--	 desc: Event called when the Direct3D device is presenting a scene.
--	---------------------------------------------------------------------------

ashita.events.register('d3d_present', 'present_cb', ui.render)

--	---------------------------------------------------------------------------
