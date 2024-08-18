--	---------------------------------------------------------------------------
--	This file contains most of the logic for Almanac, it makes use of IMGUI to
--	render the various panels that display the fish information
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

require('common')

local chat			= require('chat')
local imgui			= require('imgui')
local settings 		= require('settings')

local ZoneFish  	= require('data/FishByZone')		--	Table of fish per zone
local AllFishPlus	= require('data/AllFish')			--	Table of all fish
local AllRods		= require('data/Rods')				--	Table of fishing rods by item
local AllBait		= require('data/Bait')				--	Table of bait/lure by item

--	---------------------------------------------------------------------------
--	Almanac UI Variables
--	---------------------------------------------------------------------------

local defaults = T{
    x = 100,
    y = 500,
    show = true,
}

local ui = {
	
	FishThisZone	= T{},	--	Fish table (in the current zone)
	ZonesThisFish	= T{},	--	Zone table (for the current fish)
	AllFish			= T{},	--	All Fish table
	LocalRods		= T{},	--	Local rod table
	LocalBait		= T{},	--	Local bait table
	ZoneNames		= T{},	--	Zones as text

    -- Main Window

    is_open = { false, },

    -- "Fish in THIS zone" Tab
	
    Tab_ThisZone = {
	
		active   = 0,
        selected = -1,
    },

    -- "All Fish" Tab
	
    Tab_AllFish = {
	
		active   = 0,
        selected = -1,
    },

    settings = settings.load(defaults),
}

--	---------------------------------------------------------------------------
--	Called when we want to force a save of the settings
--	---------------------------------------------------------------------------

function ui.SaveState(state)
	
	ui.settings.show = state
	settings.save()

end

--	---------------------------------------------------------------------------
--	Builds a list of fish available in the current zone
--	---------------------------------------------------------------------------

function ui.getZoneFish(ZoneID)

	ui.FishThisZone = T{}		--	Start with an empty table
	
	if ZoneID ~= 0 and #ZoneFish ~= 0 then
	
		for key, fishTable in pairs(ZoneFish) do
			if key == ZoneID then
				for i, fishId in pairs(fishTable) do
					ui.FishThisZone:append(fishTable[i])
				end
			end
		end

		-- Sort the "Zone Fish" list

		ui.FishThisZone:sort(function (a, b)
			return (AllFishPlus[a][1] < AllFishPlus[b][1])
		end)
		
	end
	
end

--	---------------------------------------------------------------------------
--	Updates the addon settings.
--
--	{table} s - The new settings table to use for the addon settings.
--	---------------------------------------------------------------------------


local function UpdateSettings(s)
    
	--	Update the settings table..
    
	if (s ~= nil) then
        ui.settings = s
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

function ui.load()

	ui.is_open[1] = ui.settings.show
	
	--	Load the fish list for the active zone (may be empty)
	
    ui.getZoneFish(AshitaCore:GetMemoryManager():GetParty():GetMemberZone(0))

	--	Build the local "All Fish" table
	
	ui.AllFish = T{}	-- Empty the table before we start

	for key, FishOrObject in pairs(AllFishPlus) do
		
		ui.AllFish:append(T{
			index   = key,
			name    = FishOrObject[1],
			object	= FishOrObject[2],
		})
		
	end	

	--	Sort the fish by name
	
	ui.AllFish:sort(function (a, b)
		return (a.name < b.name)
		end)

	--	Build a table of zone names for speed

	for i=1, 300 do
	
		ui.ZoneNames:append(T{
			ZoneID  = i,
			name    = AshitaCore:GetResourceManager():GetString('zones.names', i),
		})

	end

	print(chat.header(addon.name):append(chat.message('Ready to go fishing .. use /faf (Find A Fish) to toggle the interface ...')))
	
end

--	---------------------------------------------------------------------------
--	Handle the zone in/out packets 
--	Packet = The packet object.
--	---------------------------------------------------------------------------

function ui.packet_in(Packet)

    --	Packet: Zone Enter
    
	if (Packet.id == 0x000A) then

		ui.Tab_ThisZone.selected = -1
		ui.Tab_AllFish.selected  = -1

        --	We are not interested in the Mog House
		
        if (struct.unpack('b', Packet.data_modified, 0x80 + 0x01) == 1) then return end

        --	Extract the new Zone ID
		
        local zone = struct.unpack('H', Packet.data_modified, 0x30 + 1)
        
		if (zone == 0) then
            zone = struct.unpack('H', Packet.data_modified, 0x42 + 1)
        end

        --	Refresh the "local" fish table
		
		ui.getZoneFish(zone)

        return
		
    end

    --	Packet: Zone Leave

    if (Packet.id == 0x000B) then

		ui.Tab_ThisZone.selected = -1
		ui.Tab_AllFish.selected  = -1

        ui.FishThisZone = T{}

        return
		
    end

end

--	---------------------------------------------------------------------------
--	Renders the right-hand panel (This Zone)
--	
--	index = The index in the table
--	---------------------------------------------------------------------------

function ui.render_RodAndBait(index)

    if (index == -1) then

		imgui.TextColored({ 0.7, 0.7, 0.7, 1.0 }, '<- Select a fish for details')

	else

		local ItemID = 0
		local Object = 0
		
		ItemID = ui.FishThisZone[index]
		
		if 0 ~= ItemID then
			Object = AllFishPlus[ItemID][2]
			end
			
		imgui.TextColored({ 1.0, 1.0, 1.0, 1.0 }, ('Item'))
		imgui.SameLine()
		imgui.TextColored({ 0.7, 0.7, 0.7, 1.0 }, ('(%d)'):fmt(ItemID))
		imgui.SameLine()

		if 1 == Object then
			imgui.TextColored({ 0.1, 0.1, 0.1, 1.0 }, ('Object'))
		else
			imgui.TextColored({ 0.0, 0.9, 0.0, 1.0 }, ('Fish'))
			imgui.SameLine()
			imgui.TextColored({ 0.1, 0.1, 0.1, 1.0 }, ('|'))
			imgui.SameLine()
			
			if 1 == AllFishPlus[ItemID][7] then
				imgui.TextColored({ 0.6, 0.0, 0.0, 1.0 }, ('Legendary'))
			else
				if 1 == AllFishPlus[ItemID][6] then
					imgui.TextColored({ 1.0, 0.6, 0.0, 1.0 }, ('Large'))
				else
					imgui.TextColored({ 0.0, 0.9, 0.0, 1.0 }, ('Small'))
				end
			end
		end

		imgui.PushStyleColor(ImGuiCol_Separator, { 0.0, 0.0, 0.0, 1.0 })
		imgui.Separator()
		imgui.PopStyleColor()
		
		--	Build a local bait table so that we can sort it based on catch luck
		
		ui.LocalBait = T{}
		
		for key, BaitOrLure in pairs(AllBait) do

			if key == ItemID then

				for bait, BaitObject in pairs(BaitOrLure) do

					ui.LocalBait:append(T{	index	= bait,
											name	= BaitObject[1],
											luck	= BaitObject[2],	}	)

				end
			end
		end
		
		ui.LocalBait:sort(function (a, b)
			return ((a.luck > b.luck) or ((a.luck == b.luck) and (a.name < b.name)))
			end)			
		
		for bait, BaitObject in pairs(ui.LocalBait) do
		
			imgui.TextColored({ 1.0, 1.0, 0.4, 1.0 }, ('%s'):fmt(BaitObject.name))
			imgui.SameLine(260)
			imgui.TextColored({ 0.0, 0.0, 0.0, 1.0 }, ('|'))
			imgui.SameLine()
			
			if 0 == BaitObject.luck then
				imgui.TextColored({ 0.7, 0.7, 0.7, 1.0 }, (' NA'))
			else
				if (BaitObject.luck % 10) ~= 0 then
					imgui.TextColored({ 0.0, 0.9, 0.0, 1.0 }, ('%.1f'):fmt(BaitObject.luck / 10.0))
				else					
					imgui.TextColored({ 0.0, 0.9, 0.0, 1.0 }, ('%.0f'):fmt(BaitObject.luck / 10.0))
				end
				
				imgui.SameLine()
				imgui.TextColored({ 0.0, 0.9, 0.0, 1.0 }, ('%%'))
			end
		
		end
		
		imgui.PushStyleColor(ImGuiCol_Separator, { 0.0, 0.0, 0.0, 1.0 })
		imgui.Separator()
		imgui.PopStyleColor()
		
		--	Build a local rod table so that we can sort it based on break percentage
		
		ui.LocalRods = T{}
		
		for key, FishOrObject in pairs(AllRods) do

			if key == ItemID then
			
				for rod, RodObject in pairs(FishOrObject) do

					ui.LocalRods:append(T{	index	= rod,
											name	= RodObject[1],
											snap	= RodObject[3],	}	)
				end
			end
		end

		ui.LocalRods:sort(function (a, b)
			return ((a.snap < b.snap) or ((a.snap == b.snap) and (a.name < b.name)))
			end)			

		for rod, RodObject in pairs(ui.LocalRods) do

			if 0 == RodObject.snap then
				imgui.TextColored({ 0.0, 0.9, 0.0, 1.0 }, ('%s'):fmt(RodObject.name))
			else
				imgui.TextColored({ 0.5, 0.1, 0.1, 1.0 }, ('%s'):fmt(RodObject.name))
			end
			
			imgui.SameLine(260)
			imgui.TextColored({ 0.0, 0.0, 0.0, 1.0 }, ('|'))
			imgui.SameLine()
			
			if 0 == RodObject.snap then
				imgui.TextColored({ 0.7, 0.7, 0.7, 1.0 }, ('None'))
			else
				imgui.TextColored({ 0.5, 0.1, 0.1, 1.0 }, ('%.0f'):fmt(RodObject.snap / 10.0))
				imgui.SameLine()
				imgui.TextColored({ 0.5, 0.1, 0.1, 1.0 }, ('%%'))
			end
			
		end
		
		imgui.PushStyleColor(ImGuiCol_Separator, { 0.0, 0.0, 0.0, 1.0 })
		imgui.Separator()
		imgui.PopStyleColor()
		
	end
	
end

--	---------------------------------------------------------------------------
--	Renders the right-hand panel (All Fish)
--	
--	index = The index in the table
--	---------------------------------------------------------------------------

function ui.render_FishGlobal(index)

    if (index == -1) then

		imgui.TextColored({ 0.7, 0.7, 0.7, 1.0 }, '<- Select a fish for details')

	else

		ui.ZonesThisFish = T{}		--	Start with an empty table
		
		if ZoneID ~= 0 and #ZoneFish ~= 0 then
		
			for key, fishTable in pairs(ZoneFish) do
				for i, fishId in pairs(fishTable) do
					if fishId == ui.AllFish[index].index then
					
						ui.ZonesThisFish:append(T{	Zone	= key,
													Name	= ui.ZoneNames[key].name	}	)
					
					
					end
				end		
			end

			-- Sort the "Fish Zone" list

			ui.ZonesThisFish:sort(function (a, b)
				return (a.Name < b.Name)
			end)
			
		end
		
		for i, Fish in pairs(ui.ZonesThisFish) do

			imgui.TextColored({ 0.0, 0.9, 0.0, 1.0 }, ('%s'):fmt(ui.ZonesThisFish[i].Name))
			
			imgui.SameLine(260)
			imgui.TextColored({ 0.0, 0.0, 0.0, 1.0 }, ('|'))
			imgui.SameLine()
			
			imgui.TextColored({ 0.7, 0.7, 0.7, 1.0 }, ('(%d)'):fmt(ui.ZonesThisFish[i].Zone))
			
		end

    end

end

--	---------------------------------------------------------------------------
--	Gets objects that provide access to the Player data
--	---------------------------------------------------------------------------

local get_player_entity_data = function()

    local party  = AshitaCore:GetMemoryManager():GetParty()
    local player = AshitaCore:GetMemoryManager():GetPlayer()

    local playerZoneID = party:GetMemberZone(0)

    local playerEntityData =
    {
        zoneID   = playerZoneID,
        zoneName = AshitaCore:GetResourceManager():GetString('zones.names', playerZoneID),
    }
	
    return playerEntityData
	
end

--	---------------------------------------------------------------------------
--	Renders the titles
--	---------------------------------------------------------------------------

function ui.renderTitleInfo()

    local playerData = get_player_entity_data()

    if playerData == nil then return end

    imgui.TextColored({ 0.0, 0.65, 1.00, 1.0 }, 'Zone:')
    imgui.SameLine()
    imgui.TextColored({ 0.9, 0.9, 0.9, 1.0 }, ('%s'):fmt(playerData.zoneName))
    imgui.SameLine()
    imgui.TextColored({ 0.7, 0.7, 0.7, 1.0 }, ('(%03d)'):fmt(playerData.zoneID))
	
	local count = 0
	for _ in pairs(ui.FishThisZone) do count = count + 1 end

    imgui.SameLine()
    imgui.TextColored({ 1.0, 0.5, 0.0, 1.0 }, ('|'))
    imgui.SameLine()
    imgui.TextColored({ 0.0, 0.65, 1.0, 1.0 }, ('%d'):fmt(count))
    imgui.SameLine()
    imgui.TextColored({ 0.9, 0.9, 0.9, 1.0 }, 'Items in this zone')

end

--	---------------------------------------------------------------------------
--	Renders the "Fish in this Zone" table
--	---------------------------------------------------------------------------

function ui.render_Tab_ThisZone()

	--	NOTE .. Indents reflect the window object level in IMGUI

	imgui.BeginGroup()
	
		imgui.PushStyleColor(ImGuiCol_ChildBg, { 0.42, 0.42, 0.5, 1.0 })
	
        imgui.TextColored({ 0.0, 0.65, 1.00, 1.0 }, 'Fish Available Here')
        imgui.BeginChild('leftpane', { 220, 294, }, true)

			local	pushed = 0
			
			for i, fishId in pairs(ui.FishThisZone) do

				--	The local table gives us the ID that is used to get the data from the AllFish table
				
				if ui.Tab_ThisZone.selected == i then
                    imgui.PushStyleColor(ImGuiCol_Text, { 1.00, 0.5, 0.0, 1.0 })
					pushed = 1
				end

				if (imgui.Selectable(('%s'):fmt(AllFishPlus[fishId][1]), ui.Tab_ThisZone.selected == i)) then
                    ui.Tab_ThisZone.selected = i
                end

				if pushed == 1 then
					imgui.PopStyleColor()
					pushed = 0
				end

			end
        
		imgui.EndChild()

        imgui.PopStyleColor()

    imgui.EndGroup()
    imgui.SameLine()

	--	-----------------------------------------------------------------------
    --	Right Side (Bait & Rod data)
	--	-----------------------------------------------------------------------
	
    imgui.BeginGroup()
    
   		imgui.PushStyleColor(ImGuiCol_ChildBg, { 0.42, 0.42, 0.5, 1.0 })

		imgui.TextColored({ 0.0, 0.65, 1.00, 1.0 }, 'Rod & Bait Information')
        
		imgui.BeginChild('rightpane', { 0, 294, }, true)
            ui.render_RodAndBait(ui.Tab_ThisZone.selected)
        
		imgui.EndChild()

        imgui.PopStyleColor()

	imgui.EndGroup()

	--	-----------------------------------------------------------------------
end

--	---------------------------------------------------------------------------
--	Renders the "All Fish" table
--	---------------------------------------------------------------------------

function ui.render_Tab_AllFish()

	--	NOTE .. Indents reflect the window object level in IMGUI

    imgui.BeginGroup()

		imgui.PushStyleColor(ImGuiCol_ChildBg, { 0.42, 0.42, 0.5, 1.0 })
	
        imgui.TextColored({ 0.0, 0.65, 1.00, 1.0 }, 'All Fish')
        imgui.BeginChild('leftpane', { 220, 294, }, true)
       
			local index = 1		
			
			for key, FishOrObject in pairs(ui.AllFish) do

				if (imgui.Selectable(('%s'):fmt(ui.AllFish[index].name), ui.Tab_AllFish.selected == index)) then
                    ui.Tab_AllFish.selected = index
                end

				index = index + 1

			end	
	
		imgui.EndChild()
        imgui.SameLine()

        imgui.PopStyleColor()

    imgui.EndGroup()
    imgui.SameLine()

	--	-----------------------------------------------------------------------
    --	Right Side (Zone list for selecte fish)
	--	-----------------------------------------------------------------------
	
    imgui.BeginGroup()
        
		imgui.TextColored({ 0.0, 0.65, 1.00, 1.0 }, 'Global Fish Information')
		
        imgui.BeginChild('rightpane', { 0, 294, }, true)
            ui.render_FishGlobal(ui.Tab_AllFish.selected)
        
		imgui.EndChild()
    
	imgui.EndGroup()

	--	-----------------------------------------------------------------------
end

--	---------------------------------------------------------------------------
--	Renders the ui.
--	---------------------------------------------------------------------------

function ui.render()
    
	--	Don't waste time rendering if closed
    
	if (not ui.is_open[1]) then return end

    --	Render (if we get this far)

    imgui.PushStyleColor(ImGuiCol_WindowBg, 		{0, 0.25, 0.50, .75})
	imgui.PushStyleColor(ImGuiCol_TitleBg,  		{0, 0.05, 0.10, .7})
	imgui.PushStyleColor(ImGuiCol_TitleBgActive, 	{0, 0.15, 0.25, .9})
	imgui.PushStyleColor(ImGuiCol_TitleBgCollapsed, {0, 0.25, 0.50, .4})
    imgui.PushStyleColor(ImGuiCol_Header, 			{0, 0.06, .16,  .7})
    imgui.PushStyleColor(ImGuiCol_HeaderHovered, 	{0, 0.06, .16,  .9})
    imgui.PushStyleColor(ImGuiCol_HeaderActive, 	{0, 0.06, .16,   1})
    imgui.PushStyleColor(ImGuiCol_FrameBg, 			{0, 0.06, .16,   1})
    imgui.PushStyleColor(ImGuiCol_TabActive,		{0, 0.50, 0.75,  1})
    imgui.PushStyleColor(ImGuiCol_TabHovered,		{0, 0.40, 0.65,  1})

    imgui.PushStyleColor(ImGuiCol_Text, 			{0, 0.90, 0.90, 0.90})
		
	imgui.SetNextWindowSize({ 594, 407, })
    imgui.SetNextWindowSizeConstraints({ 594 , 407, }, { FLT_MAX, FLT_MAX, })

	if (imgui.Begin('Almanac', ui.is_open, ImGuiWindowFlags_NoResize)) then
        
		imgui.PopStyleColor()
		
		ui.renderTitleInfo()
        
		if (imgui.BeginTabBar('##almanac_tabbar', ImGuiTabBarFlags_NoCloseWithMiddleMouseButton)) then
            
			--	We have 2 modes, left tab selected = Fish in this zone
			
			if (imgui.BeginTabItem('Fish in this zone', nil)) then
                ui.render_Tab_ThisZone()
                imgui.EndTabItem()
            end
		
			--	We swap modes if there is a click in the tab that is NOT selected
			
			if ((imgui.IsItemClicked()) and (0 == ui.Tab_ThisZone.active)) then 

				if ui.Tab_AllFish.active then

					ui.Tab_ThisZone.active = 1
					ui.Tab_AllFish.active  = 0

					ui.Tab_ThisZone.selected = -1
					ui.Tab_AllFish.selected  = -1

				end
				
			end

			--	Right tab selected = All Fish
			
            if (imgui.BeginTabItem('Fish locations (by zone)', nil)) then
                ui.render_Tab_AllFish()
                imgui.EndTabItem()
            end

			--	We swap modes if there is a click in the tab that is NOT selected

			if ((imgui.IsItemClicked()) and (0 == ui.Tab_AllFish.active)) then 

				if ui.Tab_ThisZone.active then
				
					ui.Tab_ThisZone.active = 0
					ui.Tab_AllFish.active  = 1
					
					ui.Tab_ThisZone.selected = -1
					ui.Tab_AllFish.selected  = -1
				
				end

            end
			
			imgui.EndTabBar()
        
		end
    end
	
    imgui.PopStyleColor(10)
    imgui.End()

end

-- Return the ui object

return ui
