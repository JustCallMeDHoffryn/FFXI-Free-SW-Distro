--	---------------------------------------------------------------------------
--	This file contains most of the logic for JAFA, it makes use of IMGUI to
--	render any various panels
--	---------------------------------------------------------------------------

require('common')

local chat			= require('chat')
local imgui			= require('imgui')
local settings 		= require('settings')

--	---------------------------------------------------------------------------
--	JAFA UI Variables
--	---------------------------------------------------------------------------

local defaults = T{
    x = 100,
    y = 500,
    show = true,
}

local UIF = {

    --	Main Window state

    is_open  = { true, },
    settings = settings.load(defaults),
}

--	---------------------------------------------------------------------------
--	Called when we want to force a save of the settings
--	---------------------------------------------------------------------------

function UIF.SaveState(state)

	UIF.settings.show = state
	settings.save()

end

--	---------------------------------------------------------------------------
--	Updates the addon settings.
--
--	{table} s - The new settings table to use for the addon settings.
--	---------------------------------------------------------------------------

local function UpdateSettings(s)

	--	Update the settings table..

	if (s ~= nil) then
        UIF.settings = s
    end

    --	Save the current settings..

	settings.save()

end

--	---------------------------------------------------------------------------
--	Registers a callback for the settings to monitor for character switches.
--	---------------------------------------------------------------------------

settings.register('settings', 'settings_update', UpdateSettings)

--	---------------------------------------------------------------------------
--	Loads the ui
--	---------------------------------------------------------------------------

function UIF.load()

	UIF.is_open[1] = UIF.settings.show

	print(chat.header(addon.name):append(chat.message('loaded and ready to go .. use /jafa to toggle the interface ...')))

end

--	---------------------------------------------------------------------------
--	Handle the in packets 
--	Packet = The packet object.
--	---------------------------------------------------------------------------

function UIF.packet_in(Packet)

end

--	---------------------------------------------------------------------------
--	Handle the out packets 
--	Packet = The packet object.
--	---------------------------------------------------------------------------

function UIF.packet_out(Packet)

end

--	---------------------------------------------------------------------------
--	Renders the ui.
--	---------------------------------------------------------------------------

function UIF.render()

	--	Don't waste time rendering if closed

	if (not UIF.is_open[1]) then return end

    --	Render (if we get this far)

    imgui.PushStyleColor(ImGuiCol_WindowBg, 		{0, 0.25, 0.50, .75})
	imgui.PushStyleColor(ImGuiCol_TitleBg,  		{0, 0.05, 0.10, .7})
	imgui.PushStyleColor(ImGuiCol_TitleBgActive, 	{0, 0.15, 0.25, .9})
	imgui.PushStyleColor(ImGuiCol_TitleBgCollapsed, {0, 0.25, 0.50, .4})
    imgui.PushStyleColor(ImGuiCol_Text, 			{0, 0.90, 0.90, 0.90})

	if (imgui.Begin('JAFA', UIF.is_open)) then

		imgui.TextColored( { 0.9, 0.9, 0.9, 1.0 }, 'Hello Vana\'diel' )
		imgui.TextColored( { 0.0, 0.9, 0.0, 1.0 }, 'You can log out any time you like,' )
		imgui.SameLine()
		imgui.TextColored( { 0.9, 0.0, 0.0, 1.0 }, 'but you can never leave.' )

		imgui.TextColored( { 0.9, 0.9, 0.9, 1.0 }, 'Line 3' )
		imgui.SameLine()
		imgui.SetCursorPosX(imgui.GetCursorPosX()+100)
		imgui.TextColored( { 0.9, 0.9, 0.9, 1.0 }, 'Also Line 3' )

		imgui.TextColored( { 0.9, 0.9, 0.9, 1.0 }, 'Line f' )
		imgui.SameLine()
		local space = imgui.CalcTextSize(' ')
		imgui.SetCursorPosX(imgui.GetCursorPosX()-space)
		imgui.TextColored( { 0.9, 0.9, 0.9, 1.0 }, 'our' )

		imgui.SetCursorPosX(200)
		imgui.SetCursorPosY(200)
		imgui.TextColored( { 0.9, 0.9, 0.9, 1.0 }, 'Somewhere in space ...' )

		imgui.End()

	end

    imgui.PopStyleColor(5)

end

-- Return the UIF object

return UIF
