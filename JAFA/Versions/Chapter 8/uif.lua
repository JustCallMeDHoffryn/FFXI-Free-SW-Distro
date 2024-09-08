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

	CfgActive = false,
	OurToggle = T{false},

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

    imgui.PushStyleColor(ImGuiCol_WindowBg, 		{0.4, 0.4, 0.4, .5})
	imgui.PushStyleColor(ImGuiCol_TitleBg,  		{0, 0.05, 0.10, .7})
	imgui.PushStyleColor(ImGuiCol_TitleBgActive, 	{0, 0.15, 0.25, .9})
	imgui.PushStyleColor(ImGuiCol_TitleBgCollapsed, {0, 0.25, 0.50, .4})
    imgui.PushStyleColor(ImGuiCol_Text, 			{0, 0.90, 0.90, 0.90})

    imgui.SetNextWindowSizeConstraints({ 640 , 400, }, { 640, 400, })

    if (imgui.Begin('JAFA', UIF.is_open, ImGuiWindowFlags_NoResize)) then

		imgui.TextColored( { 0.9, 0.9, 0.9, 1.0 }, 'Hello Vana\'diel (Chapter 8)' )

		if (imgui.Button('Configure')) then
			UIF.CfgActive = not UIF.CfgActive
		end

	end

    imgui.PopStyleColor(5)

	if UIF.CfgActive then

		imgui.SetNextWindowSizeConstraints({ 320 , 200, }, { 320, 400, })

		if (imgui.Begin('Config', 1, ImGuiWindowFlags_NoResize)) then

			imgui.TextColored({ 0.9, 0.9, 0.9, 1.0 }, ('For all your configuration needs') )

			imgui.PushStyleColor(ImGuiCol_Separator, { 0.0, 0.0, 0.0, 1.0 })
			imgui.Separator()
			imgui.PopStyleColor()
		  
			imgui.SetCursorPosY(100)

			if (imgui.Checkbox('Toggle', UIF.OurToggle)) then
				imgui.SameLine()
				imgui.TextColored({ 1.0, 1.0, 0.0, 1.0 }, (' ... ACTIONED') )
			end

			imgui.SetCursorPosY(170)

			if UIF.OurToggle[1] then
				imgui.TextColored({ 0.0, 0.9, 0.0, 1.0 }, ('Toggle is ON') )
			else
				imgui.TextColored({ 1.0, 0.4, 0.4, 1.0 }, ('Toggle is OFF') )
			end

		end
	end

end

-- Return the UIF object

return UIF
