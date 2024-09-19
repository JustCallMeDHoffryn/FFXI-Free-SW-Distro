--	---------------------------------------------------------------------------
--	This file contains the outer core of TickerTape, it handles the basics
--	---------------------------------------------------------------------------
--
--	This code is FREE to use as you want, just please don't claim credit 
--	for my work (such as it is)
--
--	While I have written my own code rather than C&P modules from other Addons
--  many of the ideas used in this Addon were learnt from the work of 
--	the following coders ...
--
--		atom0s			..	blumon
--		zach2good		..	Captain
--		atom0s & Thorny	..	autojoin
--		Sippius			..	Chains
--	
--		Huge respect to "Team HXUI" (Tirem, Shuu, colorglut, RheaCloud)
--
--	A BIG thank you to the above for paving the way
--	---------------------------------------------------------------------------
--
--  Use ..  /tt show    .. toggle the (show .. hide) state
--          /tt run     .. toggle the (run .. pause) state
--          /tt save    .. toggle the (save .. stop) state
--
--	---------------------------------------------------------------------------
--
--  Platform:   Ahshit v4 (ONLY)
--       Ver:   1.0
--      Date:   2025-VIII-25
--
--	---------------------------------------------------------------------------

require('common')
local UI = require('ui')

--	---------------------------------------------------------------------------
-- 	event: load
-- 	 desc: Event called when the addon is being loaded.
--	---------------------------------------------------------------------------

ashita.events.register('load', 'load_cb', UI.load)

--	---------------------------------------------------------------------------
--  event: command
--	 desc: Event called when the addon is processing a command.
--	---------------------------------------------------------------------------

ashita.events.register('command', 'command_cb', function (event)

    --  Parse the command arguments..
	
    local args = event.command:args()
    
    if (#args == 0 or not args[1]:any('/tt')) then
        return
    end

    --  If we cannot see our data, we need to leave ...

    if nill == UI then
        return
    end

    -- Block all related commands..
	
    event.blocked = true

    --  Handle: /tt
	
    if (#args >= 1) then
        
	    if (args[1] == '/tt') then

        --  -------------------------------------------------------------------
        --  Toggle show / hide
        --  -------------------------------------------------------------------

        if (args[2] == 'show') then

            if UI.ShowMain[1] then 
                UI.ShowMain[1] = false
            else
                UI.ShowMain[1] = true
            end

		end
      
        --  -------------------------------------------------------------------
        --  Toggle run / pause
        --  -------------------------------------------------------------------

        if (args[2] == 'run') then

            if UI.SeqRun[1] then 
                UI.SeqRun[1] = false
                UI.LineSel   = -1
            else
                UI.SeqRun[1] = true
            end

        end
			
        --  -------------------------------------------------------------------
        --  Toggle save / stop
        --  -------------------------------------------------------------------

        if (args[2] == 'save') then

            if UI.SeqSave[1] then 
                UI.SeqSave[1] = false
				UI.SaveLog    = false
            else
				UI.StartCap()
                UI.SeqSave[1] = true
            end

        end

        --  -------------------------------------------------------------------

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
