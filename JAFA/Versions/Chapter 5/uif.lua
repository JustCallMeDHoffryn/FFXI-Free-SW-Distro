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

    imgui.PushStyleColor(ImGuiCol_WindowBg, 		{0.3, 0.2, 0.1, .75})
	imgui.PushStyleColor(ImGuiCol_TitleBg,  		{0, 0.05, 0.10, .7})
	imgui.PushStyleColor(ImGuiCol_TitleBgActive, 	{0, 0.15, 0.25, .9})
	imgui.PushStyleColor(ImGuiCol_TitleBgCollapsed, {0, 0.25, 0.50, .4})
    imgui.PushStyleColor(ImGuiCol_Text, 			{0, 0.90, 0.90, 0.90})

    imgui.SetNextWindowSizeConstraints({ 320 , 200, }, { 320, 400, })

	if (imgui.Begin('JAFA', UIF.is_open)) then

		imgui.TextColored( { 0.9, 0.9, 0.9, 1.0 }, 'Hello Vana\'diel (Chapter 5)' )

		local entity = AshitaCore:GetMemoryManager():GetEntity()
		local party  = AshitaCore:GetMemoryManager():GetParty()
		local index  = party:GetMemberTargetIndex(0)

		imgui.SetCursorPosY(80)
		imgui.TextColored({ 0.7, 0.7, 0.7, 1.0 }, 'X:')
		imgui.SameLine()
		imgui.SetCursorPosX(40)
		imgui.TextColored({ 1.0, 1.0, 1.0, 1.0 }, ('%.4f'):fmt(entity:GetLocalPositionX(index)))
	
		imgui.SetCursorPosY(110)
		imgui.TextColored({ 0.7, 0.7, 0.7, 1.0 }, 'Y:')
		imgui.SameLine()
		imgui.SetCursorPosX(40)
		imgui.TextColored({ 1.0, 1.0, 1.0, 1.0 }, ('%.4f'):fmt(entity:GetLocalPositionY(index)))
	
		imgui.SetCursorPosY(140)
		imgui.TextColored({ 0.7, 0.7, 0.7, 1.0 }, 'Z:')
		imgui.SameLine()
		imgui.SetCursorPosX(40)
		imgui.TextColored({ 1.0, 1.0, 1.0, 1.0 }, ('%.4f'):fmt(entity:GetLocalPositionZ(index)))

		--	Player target

		imgui.SetCursorPosY(200)
		imgui.TextColored({ 0.7, 0.7, 0.7, 1.0 }, 'Target:')
		imgui.SameLine()
		imgui.SetCursorPosX(80)

		index = AshitaCore:GetMemoryManager():GetTarget():GetTargetIndex(0)
		name  = AshitaCore:GetMemoryManager():GetEntity():GetName(index)

		if nil ~= name then
			imgui.TextColored({ 1.0, 0.6, 0.0, 1.0 }, ('%s'):fmt(name) )
		else
			imgui.TextColored({ 1.0, 0.2, 0.2, 1.0 }, ('No Target') )
		end

		--	Job Names

		imgui.SetCursorPosY(260)

		for i = 1, 22 do

			local Job = AshitaCore:GetResourceManager():GetString('jobs.names', i)

			if nil ~= Job then
				imgui.TextColored({ 1.0, 1.0, 1.0, 1.0 }, ('Job: %.2d'):fmt(i) )
				imgui.SameLine()
				imgui.TextColored({ 0.0, 1.0, 0.75, 1.0 }, ('%s'):fmt(Job) )
			end

		end

		local resource = AshitaCore:GetResourceManager():GetItemById(19321)

		imgui.TextColored({ 1.0, 1.0, 1.0, 1.0 }, ('') )

		if nil ~= resource then
			imgui.TextColored({ 1.0, 1.0, 1.0, 1.0 }, ('Item 19321:') )
			imgui.SameLine()
			imgui.TextColored({ 0.0, 1.0, 0.0, 1.0 }, ('%s'):fmt(resource.Name[1]) )		
		end

		imgui.End()

	end

    imgui.PopStyleColor(5)

end

-- Return the UIF object

return UIF
