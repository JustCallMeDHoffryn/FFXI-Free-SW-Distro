--	---------------------------------------------------------------------------
--	This file contains the outer core of TickerTape, it handles the globals
--	---------------------------------------------------------------------------
--
--	This code is FREE to use as you want, just please don't claim credit 
--	for my work (such as it is)
--
--	---------------------------------------------------------------------------

--	---------------------------------------------------------------------------
	addon.name      = 'tickertape'
	addon.author    = 'DHoffryn'
	addon.version   = '0.1'
	addon.desc      = 'Packet Monitor'
--	---------------------------------------------------------------------------

require('common')
local UI = require('ui')

--	---------------------------------------------------------------------------
-- 	event: load
-- 	 desc: Event called when the addon is being loaded.
--	---------------------------------------------------------------------------

ashita.events.register('load', 'load_cb', UI.load)

--	---------------------------------------------------------------------------
--	event: command
--	 desc: Event called when the addon is processing a command.
--	---------------------------------------------------------------------------

ashita.events.register('command', 'command_cb', function (event)
    
	-- Parse the command arguments..
	
    local args = event.command:args()
    
	if (#args == 0 or not args[1]:any('/tt')) then
        return
    end

    -- Block all related commands..
	
    event.blocked = true

    -- Handle: /tt
	
    if (#args >= 1) then
        
		if (args[1] == '/tt') then
		
			UI.is_open[1] = not UI.is_open[1]
			UI.SaveState(UI.is_open[1])

			end
			
		return
    end

end)

--	---------------------------------------------------------------------------
--	event: packet_in/out
--	 desc: Events called when the addon is processing either an incoming 
--		   or an outgoing packet
--	---------------------------------------------------------------------------

ashita.events.register('packet_in',  'packet_in_cb',  UI.packet_in)
ashita.events.register('packet_out', 'packet_out_cb', UI.packet_out)

--	---------------------------------------------------------------------------
--	event: d3d_present
--	 desc: Event called when the Direct3D device is presenting a scene
--	---------------------------------------------------------------------------

ashita.events.register('d3d_present', 'present_cb', UI.Render)

--	---------------------------------------------------------------------------
