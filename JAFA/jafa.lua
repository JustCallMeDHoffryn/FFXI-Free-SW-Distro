--	---------------------------------------------------------------------------
--	This file contains the outer core of JAFA
--	---------------------------------------------------------------------------
--
--	---------------------------------------------------------------------------
	addon.name      = 'jafa'
	addon.author    = 'DHoffryn'
	addon.version   = '0.1'
	addon.desc      = 'Teaching Tool'
--	---------------------------------------------------------------------------

require('common')
local UIF = require('uif')

--	---------------------------------------------------------------------------
-- 	event: load
-- 	 desc: Event called when the addon is being loaded.
--	---------------------------------------------------------------------------

ashita.events.register('load', 'load_cb', UIF.load)

--	---------------------------------------------------------------------------
--	event: command
--	 desc: Event called when the addon is processing a command.
--	---------------------------------------------------------------------------

ashita.events.register('command', 'command_cb', function (event)
    
	--	Parse the command arguments..
	
    local args = event.command:args()
    
	if (#args == 0 or not args[1]:any('/jafa')) then
        return
    end

    --	Block all related commands..
	
    event.blocked = true

    --	Handle: /jafa
	
    if (#args >= 1) then
  
		if (args[1] == '/jafa') then

			UIF.is_open[1] = not UIF.is_open[1]
			UIF.SaveState(UIF.is_open[1])

		end

		return
    end

end)

--	---------------------------------------------------------------------------
--	event: packet_in
--	 desc: Event called when the addon is processing incoming packets.
--	---------------------------------------------------------------------------

ashita.events.register('packet_in', 'packet_in_cb', UIF.packet_in);

--	---------------------------------------------------------------------------
--	event: packet_out
--	 desc: Event called when the addon is processing outbound packets.
--	---------------------------------------------------------------------------

ashita.events.register('packet_out', 'packet_out_cb', UIF.packet_out);

--	---------------------------------------------------------------------------
--	event: d3d_present
--	 desc: Event called when the Direct3D device is presenting a scene.
--	---------------------------------------------------------------------------

ashita.events.register('d3d_present', 'present_cb', UIF.render)

--	---------------------------------------------------------------------------
