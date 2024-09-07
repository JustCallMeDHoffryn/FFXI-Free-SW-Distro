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

    imgui.PushStyleColor(ImGuiCol_WindowBg, 		{0.4, 0.4, 0.4, .5})
	imgui.PushStyleColor(ImGuiCol_TitleBg,  		{0, 0.05, 0.10, .7})
	imgui.PushStyleColor(ImGuiCol_TitleBgActive, 	{0, 0.15, 0.25, .9})
	imgui.PushStyleColor(ImGuiCol_TitleBgCollapsed, {0, 0.25, 0.50, .4})
    imgui.PushStyleColor(ImGuiCol_Text, 			{0, 0.90, 0.90, 0.90})

    imgui.SetNextWindowSizeConstraints({ 640 , 400, }, { 640, 400, })

    if (imgui.Begin('JAFA', UIF.is_open, ImGuiWindowFlags_NoResize)) then

		imgui.TextColored( { 0.9, 0.9, 0.9, 1.0 }, 'Hello Vana\'diel (Chapter 7)' )

		imgui.PushStyleColor(ImGuiCol_ChildBg, 	{0.5, 0.5, 0.5, 0.50})
		imgui.BeginChild('Table holder', { 0, 0, }, true)

		if imgui.BeginTable("table1", 3, ImGuiTableFlags_Borders + ImGuiTableFlags_RowBg) then

			imgui.TableSetupColumn("1", ImGuiTableColumnFlags_WidthFixed, 125)
			imgui.TableSetupColumn("2", ImGuiTableColumnFlags_WidthFixed, 125)

			for i = 1, 9 do

				imgui.TableNextRow()

				imgui.TableSetColumnIndex(0)
				imgui.TextColored({ 0.9, 0.9, 0.9, 1.0 }, ('%d x 1'):fmt(i) )
		  
				imgui.TableSetColumnIndex(1)
				imgui.TextColored({ 0.9, 0.9, 0.9, 1.0 }, ('%d x 2'):fmt(i) )
		  
				imgui.TableSetColumnIndex(2)
				imgui.TextColored({ 0.9, 0.9, 0.9, 1.0 }, ('%d x 3'):fmt(i) )
		  
			end

			imgui.EndTable()

		end

		imgui.EndChild()
		imgui.PopStyleColor()

	end

    imgui.PopStyleColor(5)

end

-- Return the UIF object

return UIF
