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
    x = 200,
    y = 200,
    show = true,
}

local ui = {
	
	FishThisZone	= T{},	--	Fish table (in the current zone)
	AllFish			= T{},	--	All Fish table
	
    data			= T{},     -- Raw data loaded from /data/spells.json..
    spells			= T{},   -- List of spells with proper data from resources..
    zone			= T{},     -- List of spells available in the current zone..

    -- Main Window

    is_open = { false, },

    -- "Fish in THIS zone" Tab
	
    Tab_ThisZone = {
	
		active   = 0,
        selected = { -1, },
    },

    -- "All Fish" Tab
	
    Tab_AllFish = {
	
		active   = 0,
        selected = { -1, },
    },

    settings = settings.load(defaults),
};

--	---------------------------------------------------------------------------
--	Called when we want to force a save of the settings
--	---------------------------------------------------------------------------

function ui.SaveState(state)
	
	ui.settings.show = state

	print(chat.header(addon.name):append(chat.message('New State: (%d, %d) %s'):fmt(ui.settings.x, ui.settings.y, tostring(ui.settings.show))))

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
					ui.FishThisZone:append(fishTable[i]);
				end
			end
		end

		-- Sort the "Zone Fish" list

		ui.FishThisZone:sort(function (a, b)
			return (AllFishPlus[a][1] < AllFishPlus[b][1])
		end);
		
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
        ui.settings = s;
    end

	print(chat.header(addon.name):append(chat.message('Update: (%d, %d) %s'):fmt(ui.settings.x, ui.settings.y, tostring(ui.settings.show))))

    --	Save the current settings..
    
	settings.save()
	
end

--	---------------------------------------------------------------------------
--	Registers a callback for the settings to monitor for character switches.
--	---------------------------------------------------------------------------

settings.register('settings', 'settings_update', UpdateSettings);

--	---------------------------------------------------------------------------
--	Loads the ui
--	---------------------------------------------------------------------------

function ui.load()

	print(chat.header(addon.name):append(chat.message('Show: (%d, %d) %s'):fmt(ui.settings.x, ui.settings.y, tostring(ui.settings.show))))
	
	ui.is_open[1] = ui.settings.show
	
	--	Load the fish list for the active zone (may be empty)
	
    ui.getZoneFish(AshitaCore:GetMemoryManager():GetParty():GetMemberZone(0));

	--	Build the local "All Fish" table
	
	ui.AllFish = T{}	-- Empty the table before we start

	for key, FishOrObject in pairs(AllFishPlus) do
		
		ui.AllFish:append(T{
			index   = key,
			name    = FishOrObject[1],
			object	= FishOrObject[2],
		});
		
	end	

	--	Sort the fish by name
	
	ui.AllFish:sort(function (a, b)
		return (a.name < b.name)
		end)

end

--	---------------------------------------------------------------------------
--	Handle the zone in/out packets 
--	Packet = The packet object.
--	---------------------------------------------------------------------------

function ui.packet_in(Packet)

    --	Packet: Zone Enter
    
	if (Packet.id == 0x000A) then

		ui.Tab_ThisZone.selected[1] = -1
		ui.Tab_AllFish.selected[1]  = -1

        --	We are not interested in the Mog House
		
        if (struct.unpack('b', Packet.data_modified, 0x80 + 0x01) == 1) then return end

        --	Extract the new Zone ID
		
        local zone = struct.unpack('H', Packet.data_modified, 0x30 + 1);
        
		if (zone == 0) then
            zone = struct.unpack('H', Packet.data_modified, 0x42 + 1);
        end

        --	Refresh the "local" fish table
		
		ui.getZoneFish(zone);

        return
		
    end

    --	Packet: Zone Leave

    if (Packet.id == 0x000B) then

		ui.Tab_ThisZone.selected[1] = -1
		ui.Tab_AllFish.selected[1]  = -1

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

		imgui.TextColored({ 0.7, 0.7, 0.7, 1.0 }, '<- Select a fish for details');

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
			imgui.TextColored({ 0.1, 0.1, 0.1, 1.0 }, ('Object'));
		else
			imgui.TextColored({ 0.0, 0.9, 0.0, 1.0 }, ('Fish'));
			imgui.SameLine()
			imgui.TextColored({ 0.1, 0.1, 0.1, 1.0 }, ('|'));
			imgui.SameLine()
			
			if 1 == AllFishPlus[ItemID][7] then
				imgui.TextColored({ 0.6, 0.0, 0.0, 1.0 }, ('Legendary'));
			else
				if 1 == AllFishPlus[ItemID][6] then
					imgui.TextColored({ 1.0, 0.6, 0.0, 1.0 }, ('Large'));
				else
					imgui.TextColored({ 0.0, 0.9, 0.0, 1.0 }, ('Small'));
				end
			end
		end

		imgui.PushStyleColor(ImGuiCol_Separator, { 0.0, 0.0, 0.0, 1.0 })
		imgui.Separator();
		imgui.PopStyleColor()
		
		for key, BaitOrLure in pairs(AllBait) do

			if key == ItemID then
			
				for rod, BaitObject in pairs(BaitOrLure) do
					imgui.TextColored({ 1.0, 1.0, 0.4, 1.0 }, ('%s'):fmt(BaitObject[1]))
					imgui.SameLine(240)
					imgui.TextColored({ 0.0, 0.0, 0.0, 1.0 }, ('|'))
					imgui.SameLine()
					
					if 0 == BaitObject[2] then
						imgui.TextColored({ 0.7, 0.7, 0.7, 1.0 }, (' NA'))
					else
						if (BaitObject[2] % 10) ~= 0 then
							imgui.TextColored({ 0.0, 0.9, 0.0, 1.0 }, ('%.1f'):fmt(BaitObject[2] / 10.0))
						else					
							imgui.TextColored({ 0.0, 0.9, 0.0, 1.0 }, ('%.0f'):fmt(BaitObject[2] / 10.0))
						end
						
						imgui.SameLine()
						imgui.TextColored({ 0.0, 0.9, 0.0, 1.0 }, ('%%'))
					end
				end
				
			end
			
		end	

		imgui.PushStyleColor(ImGuiCol_Separator, { 0.0, 0.0, 0.0, 1.0 })
		imgui.Separator();
		imgui.PopStyleColor()
		
		for key, FishOrObject in pairs(AllRods) do

			if key == ItemID then
			
				for rod, RodObject in pairs(FishOrObject) do
					imgui.TextColored({ 1.0, 1.0, 0.4, 1.0 }, ('%s'):fmt(RodObject[1]));
					imgui.SameLine(240)
					imgui.TextColored({ 0.0, 0.0, 0.0, 1.0 }, ('|'))
					imgui.SameLine()
					
					if 0 == RodObject[3] then
						imgui.TextColored({ 0.7, 0.7, 0.7, 1.0 }, ('None'))
					else
						imgui.TextColored({ 0.4, 0.1, 0.1, 1.0 }, ('%.0f'):fmt(RodObject[3] / 10.0))
						imgui.SameLine()
						imgui.TextColored({ 0.4, 0.1, 0.1, 1.0 }, ('%%'))
					end
					
				end
				
			end
			
		end	

		imgui.PushStyleColor(ImGuiCol_Separator, { 0.0, 0.0, 0.0, 1.0 })
		imgui.Separator();
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

		imgui.TextColored({ 0.7, 0.7, 0.7, 1.0 }, '<- Select a fish for details');

	else

		imgui.TextColored({ 0.7, 0.7, 0.7, 1.0 }, ('Mode = Global'));
		imgui.TextColored({ 0.7, 0.7, 0.7, 1.0 }, ('Selected = %d'):fmt(index));
		imgui.TextColored({ 0.7, 0.7, 0.7, 1.0 }, ('%s (%d)'):fmt(ui.AllFish[index].name, ui.AllFish[index].index));
	
		--[[
        local spell = lst[index];
        local res   = AshitaCore:GetResourceManager():GetSpellById(spell.index);

        if (res == nil) then
            imgui.TextColored({ 1.0, 0.0, 0.0, 1.0 }, 'Failed to obtain spell information.');
        else
            -- Displays a stat value with some color.
            
			local function showStat(header, value)
                imgui.TextColored({ 1.0, 1.0, 1.0, 1.0 }, header);
                imgui.SameLine();
                imgui.TextColored({ 0.2, 0.7, 1.0, 1.0 }, tostring(value));
            end

            imgui.PushTextWrapPos(imgui.GetFontSize() * 23.0);
            imgui.TextColored({ 1.0, 0.2, 0.5, 1.0 }, res.Name[1]);
            imgui.TextColored({ 1.0, 0.5, 0.2, 1.0 }, res.Description[1]);
            imgui.PopTextWrapPos();
            imgui.Separator();

            showStat('Index        :', res.Index);
            --showStat('Element      :', ui.get_spell_element(res.Element));
            --showStat('Mana Cost    :', res.ManaCost);
            --showStat('Cast Time    :', ('%.2f sec'):fmt(res.CastTime / 4.0));
            --showStat('Recast Delay :', ('%.2f sec'):fmt(res.RecastDelay / 4.0));
            --showStat('Level Needed :', res.LevelRequired[16 + 1]);
            --showStat('Range        :', ('%d yalms'):fmt(AshitaCore:GetResourceManager():GetSpellRange(res.Index, false)));
            --showStat('Area Range   :', ('%d yalms'):fmt(AshitaCore:GetResourceManager():GetSpellRange(res.Index, true)));

            --imgui.TextColored({ 1.0, 1.0, 1.0, 1.0 }, 'Known        :');
            --imgui.SameLine();
            --if (spell.known) then
              --  imgui.TextColored({ 0.0, 1.0, 0.0, 1.0 }, 'Yes');
            --else
                --imgui.TextColored({ 1.0, 0.0, 0.0, 1.0 }, 'No');
            --end

            --imgui.Separator();
            --imgui.TextColored({ 1.0, 1.0, 0.4, 1.0 }, 'Learned From The Following');
            --imgui.Separator();

			--[[
            if (spell.zones:len() > 0) then
                spell.zones:each(function (v, k)
                    imgui.TextColored({ 1.0, 0.0, 1.0, 1.0 }, AshitaCore:GetResourceManager():GetString('zones.names', tonumber(k)));
                    imgui.Indent();
                    for _, vv in pairs(v) do
                        imgui.TextColored({ 1.0, 1.0, 1.0, 1.0 }, tostring(vv));
                    end
                    imgui.Unindent();
                end);
            else
                imgui.TextColored({ 1.0, 0.0, 1.0, 1.0 }, 'No data available.');
            end
			]]--
        --end
		
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

    imgui.TextColored({ 0.0, 0.65, 1.00, 1.0 }, 'Zone:');
    imgui.SameLine();
    imgui.TextColored({ 0.9, 0.9, 0.9, 1.0 }, ('%s'):fmt(playerData.zoneName));
    imgui.SameLine();
    imgui.TextColored({ 0.7, 0.7, 0.7, 1.0 }, ('(%03d)'):fmt(playerData.zoneID));
	
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
        imgui.BeginChild('leftpane', { 330, 294, }, true)

			local	pushed = 0
			
			for i, fishId in pairs(ui.FishThisZone) do

				--	The local table gives us the ID that is used to get the data from the AllFish table
				
				if ui.Tab_ThisZone.selected[1] == i then
                    imgui.PushStyleColor(ImGuiCol_Text, { 1.00, 0.5, 0.0, 1.0 })
					pushed = 1
				end

				if (imgui.Selectable(('%s'):fmt(AllFishPlus[fishId][1]), ui.Tab_ThisZone.selected[1] == i)) then
                    ui.Tab_ThisZone.selected[1] = i;
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
            ui.render_RodAndBait(ui.Tab_ThisZone.selected[1])
        
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

		imgui.PushStyleColor(ImGuiCol_ChildBg, { 0.42, 0.42, 0.5, 1.0 });
	
        imgui.TextColored({ 0.0, 0.65, 1.00, 1.0 }, 'All Fish');
        imgui.BeginChild('leftpane', { 330, 294, }, true);
       
			local index = 1;		
			
			for key, FishOrObject in pairs(ui.AllFish) do

				if (imgui.Selectable(('%s'):fmt(ui.AllFish[index].name), ui.Tab_AllFish.selected[1] == index)) then
                    ui.Tab_AllFish.selected[1] = index;
                end

				index = index + 1

			end	
	
		imgui.EndChild();
        imgui.SameLine();

        imgui.PopStyleColor();

    imgui.EndGroup();
    imgui.SameLine();

	--	-----------------------------------------------------------------------
    --	Right Side (Zone list for selecte fish)
	--	-----------------------------------------------------------------------
	
    imgui.BeginGroup();
        
		imgui.TextColored({ 0.0, 0.65, 1.00, 1.0 }, 'Global Fish Information');
		
        imgui.BeginChild('rightpane', { 0, 294, }, true);
            ui.render_FishGlobal(ui.Tab_AllFish.selected[1]);
        
		imgui.EndChild();
    
	imgui.EndGroup();

	--	-----------------------------------------------------------------------
end

--	---------------------------------------------------------------------------
--	Renders the ui.
--	---------------------------------------------------------------------------

function ui.render()
    
	--	Don't waste time rendering if closed
    
	if (not ui.is_open[1]) then return end

    --	Render (if we get this far)

    imgui.PushStyleColor(ImGuiCol_WindowBg, 		{0, 0.25, 0.50, .75});
	imgui.PushStyleColor(ImGuiCol_TitleBg,  		{0, 0.05, 0.10, .7});
	imgui.PushStyleColor(ImGuiCol_TitleBgActive, 	{0, 0.15, 0.25, .9});
	imgui.PushStyleColor(ImGuiCol_TitleBgCollapsed, {0, 0.25, 0.50, .4});
    imgui.PushStyleColor(ImGuiCol_Header, 			{0, 0.06, .16,  .7});
    imgui.PushStyleColor(ImGuiCol_HeaderHovered, 	{0, 0.06, .16,  .9});
    imgui.PushStyleColor(ImGuiCol_HeaderActive, 	{0, 0.06, .16,   1});
    imgui.PushStyleColor(ImGuiCol_FrameBg, 			{0, 0.06, .16,   1});
    imgui.PushStyleColor(ImGuiCol_TabActive,		{0, 0.50, 0.75,  1});
    imgui.PushStyleColor(ImGuiCol_TabHovered,		{0, 0.40, 0.65,  1});

    imgui.PushStyleColor(ImGuiCol_Text, 			{0, 0.90, 0.90, 0.90});
		
	imgui.SetNextWindowSize({ 684, 407, })
    imgui.SetNextWindowSizeConstraints({ 684 , 407, }, { FLT_MAX, FLT_MAX, })

	if (imgui.Begin('Almanac', ui.is_open, ImGuiWindowFlags_NoResize)) then
        
		imgui.PopStyleColor()
		
		ui.renderTitleInfo();
        
		if (imgui.BeginTabBar('##almanac_tabbar', ImGuiTabBarFlags_NoCloseWithMiddleMouseButton)) then
            
			--	We have 2 modes, left tab selected = Fish in this zone
			
			if (imgui.BeginTabItem('Fish in this zone', nil)) then
                ui.render_Tab_ThisZone();
                imgui.EndTabItem()
            end
		
			--	We swap modes if there is a click in the tab that is NOT selected
			
			if ((imgui.IsItemClicked()) and (0 == ui.Tab_ThisZone.active)) then 

				-- print(chat.header(addon.name):append(chat.message('Left Tab: Clicked (2)')))

				if ui.Tab_AllFish.active then

					ui.Tab_ThisZone.active = 1
					ui.Tab_AllFish.active  = 0

					ui.Tab_ThisZone.selected[1] = -1
					ui.Tab_AllFish.selected[1]  = -1

				end
				
			end

			--	Right tab selected = All Fish
			
            if (imgui.BeginTabItem('Fish locations (by zone)', nil)) then
                ui.render_Tab_AllFish();
                imgui.EndTabItem();
            end

			--	We swap modes if there is a click in the tab that is NOT selected

			if ((imgui.IsItemClicked()) and (0 == ui.Tab_AllFish.active)) then 

				-- print(chat.header(addon.name):append(chat.message('Right Tab: Clicked (2)')))

				if ui.Tab_ThisZone.active then
				
					ui.Tab_ThisZone.active = 0
					ui.Tab_AllFish.active  = 1
					
					ui.Tab_ThisZone.selected[1] = -1
					ui.Tab_AllFish.selected[1]  = -1
				
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
