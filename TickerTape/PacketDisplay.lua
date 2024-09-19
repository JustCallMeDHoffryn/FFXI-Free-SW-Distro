--	---------------------------------------------------------------------------
--	This file contains the data processing for TickerTap
--	---------------------------------------------------------------------------

--	---------------------------------------------------------------------------

require('common')

local chat	= require('chat')
local imgui	= require('imgui')

local ETC			= require('ETC')			--	Our global data (brushes etc)
local XFunc			= require('XFunc')			--	Our global support functions
local X64			= require('X64Reg')			--	Our 64 bit register
local CentralData	= require('CentralData')
local Decode		= require('decode')
local DataProc		= require('DataProc')

local PacketDisplay = {

	ShowRaw		= T{true},

	functions	= T{	{ 	cmd = 'time',		func = Decode.Time, 		param = 1 },
						{ 	cmd = 'mstime',		func = Decode.MSTime, 		param = 1 },
						{	cmd = 'xyz',		func = Decode.XYZ,			param = 2 },
						{	cmd = 'dir',		func = Decode.Direction,	param = 1 },
						{	cmd = 'psize',		func = Decode.PSize,		param = 1 },
						{	cmd = 'eid',		func = Decode.EID,			param = 1 },
						{	cmd = 'entity',		func = Decode.Entity,		param = 1 },
						{	cmd = 'raw',		func = Decode.RAW,			param = 1 },
						{	cmd = 'string',		func = Decode.String,		param = 2 },
						{	cmd = 'music',		func = Decode.Music,		param = 1 },
						{	cmd = 'weather',	func = Decode.Weather,		param = 1 },
						{	cmd = 'zone',		func = Decode.Zone,			param = 1 },
						{	cmd = 'house',		func = Decode.MHouse,		param = 1 },
						{	cmd = 'bitflag',	func = Decode.BitFlag,		param = 2 },
						{	cmd = 'ip',			func = Decode.IP,			param = 2 },
						{	cmd = 'store',		func = Decode.Store,		param = 1 },
						{	cmd = 'item',		func = Decode.Item,			param = 1 },
						{	cmd = 'exdata',		func = Decode.EXData,		param = 2 },
						{	cmd = 'ability',	func = Decode.Ability,		param = 1 },
						{	cmd = 'info',		func = Decode.Info,			param = 1 },
						{	cmd = 'vdate',		func = Decode.VDate,		param = 1 },
						{	cmd = 'jpoint',		func = Decode.JobPoints,	param = 2 },
						{	cmd = 'merit',		func = Decode.MeritPoints,	param = 1 },
						{	cmd = 'geo',		func = Decode.GEO,			param = 1 },
						{	cmd = 'job',		func = Decode.JobByte,		param = 1 },
						{	cmd = 'bluspell',	func = Decode.BLUSpell,		param = 1 },
						{	cmd = 'attach',		func = Decode.Attach,		param = 1 },
						{	cmd = 'puppet',		func = Decode.Puppet,		param = 1 },
						{	cmd = 'status',		func = Decode.Status,		param = 1 },
						{	cmd = 'spell',		func = Decode.Spell,		param = 1 },
						{	cmd = 'action',		func = Decode.Action,		param = 1 },
						{	cmd = 'wskill',		func = Decode.WSkill,		param = 1 },
						{	cmd = 'craft',		func = Decode.Craft,		param = 1 },
						{	cmd = 'dbox',		func = Decode.DBox,			param = 1 },

					}
}

--	---------------------------------------------------------------------------
--	Render the raw data table
--	---------------------------------------------------------------------------

function PacketDisplay.RenderRawData(Packet)

	--	Show the raw data
	
	local	row = 0
	local	col = 0
	local	idx = 0
	
	for byte = 1, Packet.size do
	
		if col == 0 then

			imgui.SetCursorPosX(imgui.GetCursorPosX()+5)		
			imgui.TextColored({ 0.9, 0.9, 0.0, 1.0 }, ('0x%.3X : '):fmt(row * 16) )
			imgui.SameLine()

		end
		
		--	We toggle blue and white to make it easier to count the bytes in the packet

		local blue = false

		if (byte-1) % 4 > 1 then blue = true end
		if row % 2 == 1 then blue = not blue end

		if blue == true then
			imgui.TextColored({ 0.8, 0.8, 1.00, 1.0 }, ('%c%c'):fmt( Packet.data:byte((idx*2)+1, (idx*2)+1), Packet.data:byte((idx*2)+2, (idx*2)+2) ) )
		else
			imgui.TextColored({ 0.9,  0.9,  0.6,  1.0 }, ('%c%c'):fmt( Packet.data:byte((idx*2)+1, (idx*2)+1), Packet.data:byte((idx*2)+2, (idx*2)+2) ) )
		end

		idx = idx + 1
		col = col + 1
		
		if col < 16 then
			if idx < Packet.size then
				imgui.SameLine()
			end
		else
			col = 0
			row = row + 1
		end

	end
	
end

--	---------------------------------------------------------------------------
--	This executes a single rule 
--	---------------------------------------------------------------------------

function PacketDisplay.ExecuteRule(Packet, RuleTable, UI)

	X64.ExtractFromPacket(Packet, RuleTable)

	PacketDisplay.ExecuteDecode(UI, Packet, RuleTable, RuleTable.Decode1)
	PacketDisplay.ExecuteDecode(UI, Packet, RuleTable, RuleTable.Decode2)
	PacketDisplay.ExecuteDecode(UI, Packet, RuleTable, RuleTable.Decode3)
	PacketDisplay.ExecuteDecode(UI, Packet, RuleTable, RuleTable.Decode4)

end

--	---------------------------------------------------------------------------
--	Called to verify that a rule exists in the correct table
--	---------------------------------------------------------------------------

function PacketDisplay.VerifyPacketRule(direction, target)

	local found = false

	if 1 == direction then

		if nil ~= CentralData.PktDspRulesIN then

			for Group, RuleTable in pairs(CentralData.PktDspRulesIN) do

				if nil ~= RuleTable and Group == target then
					found = true
				end
			end

		end

	else

		if nil ~= CentralData.PktDspRulesOUT then

			for Group, RuleTable in pairs(CentralData.PktDspRulesOUT) do

				if nil ~= RuleTable and Group == target then
					found = true
				end
			end

		end
		
	end

	return found

end

--	---------------------------------------------------------------------------
--	This sets the command flags
--	---------------------------------------------------------------------------

function PacketDisplay.CheckForCommands(RuleTable, Packet, ExecuteThis, ThisIsCommand)

	if ((nil ~= RuleTable.Command) and (#RuleTable.Command > 0)) then

		if 'ifnot' == RuleTable.Command then				--	IF A BYTE IS NOT ...
			
			local Value = XFunc.GetValueByType(Packet, RuleTable)
			local Skip  = 1

			if 0 ~= RuleTable.CMDOpt2 then Skip = RuleTable.CMDOpt2 end

			if Value == RuleTable.CMDOpt1 then 
				CentralData.IDX	= CentralData.IDX + Skip
				ExecuteThis		= false
			end

			--print(string.format('%s -> V: %d (%d,%d), T: %d', RuleTable.Command, Value, RuleTable.Offset, RuleTable.Bytes, RuleTable.CMDOpt1))

		elseif 'if' == RuleTable.Command then				--	IF A BYTE IS ...

			local Value = XFunc.GetValueByType(Packet, RuleTable)
			local Skip  = 1

			if 0 ~= RuleTable.CMDOpt2 then Skip = RuleTable.CMDOpt2 end

			if Value ~= RuleTable.CMDOpt1 then
				CentralData.IDX	= CentralData.IDX + Skip
				ExecuteThis		= false
			end

			--print(string.format('%s -> V: %d (%d,%d), T: %d', RuleTable.Command, Value, RuleTable.Offset, RuleTable.Bytes, RuleTable.CMDOpt1))

		elseif 'flag' == RuleTable.Command then				--	IF A FLAG IS ...
		
			local Value = CentralData.Flags[RuleTable.CMDOpt1]
			local Skip  = 1

			if 0 ~= RuleTable.CMDOpt2 then Skip = RuleTable.CMDOpt2 end

			if Value ~= 0 then 
				CentralData.IDX	= CentralData.IDX + Skip
				ExecuteThis		= false
			end

		elseif 'flagnot' == RuleTable.Command then			--	IF A FLAG IS NOT ...
		
			local Value = CentralData.Flags[RuleTable.CMDOpt1]
			local Skip  = 1

			if 0 ~= RuleTable.CMDOpt2 then Skip = RuleTable.CMDOpt2 end

			if Value == 0 then 
				CentralData.IDX	= CentralData.IDX + Skip
				ExecuteThis		= false
			end
	
		--	We need an exception for '@' and 'flag' commands but everthing else is a COMMAND

		elseif ('useflag' == RuleTable.Command) then
			ThisIsCommand = false
			ExecuteThis	  = true
		elseif ('setflag' == RuleTable.Command) or ('incflag' == RuleTable.Command) or ('decflag' == RuleTable.Command) then
			ThisIsCommand = true
			ExecuteThis	  = false
		else
			ThisIsCommand = true
		end

	end
	
	return ExecuteThis, ThisIsCommand
	
end

--	---------------------------------------------------------------------------
--	Called when we want to decode a packet into a series of text lines
--	---------------------------------------------------------------------------

function PacketDisplay.ShowPacket(Packet, UI, ThisSlice)

	--	Always ZERO the stack at this point

	CentralData.ZERO()

	--	Allow the user to toggle raw
	
	if (imgui.Checkbox('Raw', PacketDisplay.ShowRaw)) then
	end

	imgui.SameLine()

	--	Time of packet				
				
	imgui.TextColored({ 0.9, 0.9, 0.9, 1.0 }, Packet.now)
	imgui.SameLine()

	local xPos = imgui.GetCursorPosX()

	if nil ~= UI then
		if 1 == Packet.direction then
			imgui.TextColored({ 0.2, 1.0, 0.2, 1.0 }, UI.GetPacketName(ThisSlice))
		else
			imgui.TextColored({ 0.6, 0.6, 1.0, 1.0 }, UI.GetPacketName(ThisSlice))
		end
	end
	
	imgui.SameLine()
	imgui.SetCursorPosX(xPos+260)

	if ((imgui.Button('<<')) and (-1 ~= UI.LineSel)) then
		
		if 1 == UI.LineSel then
			UI.LineSel = UI.StackSize
		else
			UI.LineSel = UI.LineSel - 1
		end

	end

	imgui.SameLine()

	if ((imgui.Button('>>')) and (-1 ~= UI.LineSel)) then		--	Show next
	
		if UI.LineSel == UI.StackSize then
			UI.LineSel = 1
		else
			UI.LineSel = UI.LineSel + 1
		end

	end

	imgui.SameLine()

	if imgui.Button('X64') then		--	Show diagnostics
		UI.ShowDiagnostics[1] = not UI.ShowDiagnostics[1]
	end

	XFunc.Divide(65)

	--	Show the raw data

	if PacketDisplay.ShowRaw[1] then 
		imgui.SetCursorPosY(imgui.GetCursorPosY()+10)
		PacketDisplay.RenderRawData(Packet)	
	end

	imgui.SetCursorPosY(imgui.GetCursorPosY()+7)

	if PacketDisplay.ShowRaw[1] then 
		XFunc.Divide(imgui.GetCursorPosY())
	end

	--	-----------------------------------------------------------------------
	--	Now try and unpack it
	--	-----------------------------------------------------------------------

	local found = false

	CentralData.PacketRules = T{}

	if 1 == Packet.direction then

		for Group, RuleTable in pairs(CentralData.PktDspRulesIN) do

			if nil ~= RuleTable and Group == Packet.packet then
				found = true
				DataProc.DecodeRuleTable(RuleTable)
			end
		end

	else

		for Group, RuleTable in pairs(CentralData.PktDspRulesOUT) do

			if nil ~= RuleTable and Group == Packet.packet then
				found = true
				DataProc.DecodeRuleTable(RuleTable)
			end
		end

	end

	--	-----------------------------------------------------------------------
	--	If we found rules for this packet then decode it ...
	--	-----------------------------------------------------------------------

	if found then

		--	All flags are off by default
		
		CentralData.IDX = 1

		for i=1, 1024 do CentralData.Flags[i] = 0 end

		-- Sort and re-index the rules, we want them in numerical order

		CentralData.PacketRules:sort(function (a, b)
			return (a.Index < b.Index)
		end)

		local RuleSize = 0

		for Rule, RuleTable in pairs(CentralData.PacketRules) do
			RuleSize = RuleSize + 1
			RuleTable.Index = RuleSize
		end

		imgui.SetCursorPosY(imgui.GetCursorPosY()+20)

		if imgui.BeginTable("table1", 3, ImGuiTableFlags_Borders + ImGuiTableFlags_RowBg) then

			imgui.TableSetupColumn("1", ImGuiTableColumnFlags_WidthFixed, 45)
			imgui.TableSetupColumn("2", ImGuiTableColumnFlags_WidthFixed, 125)

			--	---------------------------------------------------------------
			--	Execute the rules, one at a time
			--	---------------------------------------------------------------

			while RuleSize > 0 and CentralData.IDX > 0 and CentralData.IDX <= RuleSize do

				RuleSize = 0

				for Rule, RuleTable in pairs(CentralData.PacketRules) do
					RuleSize = RuleSize + 1
				end
					
				RuleTable = CentralData.PacketRules[CentralData.IDX]

				local	ThisIsCommand 	= false
				local	ExecuteThis		= true

				--	-----------------------------------------------------------
				--	We have an outer test before we process a line
				--	-----------------------------------------------------------

				ExecuteThis, ThisIsCommand = PacketDisplay.CheckForCommands(RuleTable, Packet, ExecuteThis, ThisIsCommand)

				--	-----------------------------------------------------------
				--	Handle commands before anything else
				--	-----------------------------------------------------------

				if ThisIsCommand == true then

					if DataProc.ProcessCommand(PacketDisplay, RuleTable, Packet) then
						CentralData.IDX = CentralData.IDX + 1
					else

						--	If we DON'T step we could be in a new rule, so 
						--	rebuild what we know
						
						RuleSize = 0

						for Rule, RuleTable in pairs(CentralData.PacketRules) do
							RuleSize = RuleSize + 1
						end
		
						RuleTable = CentralData.PacketRules[CentralData.IDX]

					end

				else

					if ExecuteThis == true then

						--	-------------------------------------------------------
						--	If we get here then it is a normal decode line
						--	-------------------------------------------------------

						imgui.TableNextRow()
						imgui.TableSetColumnIndex(0)
						
						if RuleTable.Offset >= 0 then
							local Byte = RuleTable.Offset + CentralData.PlusByte
							imgui.TextColored({ 0.9, 0.9, 0.9, 1.0 }, ('0x%.3X'):fmt(Byte) )
						end

						imgui.TableSetColumnIndex(1)
						
						local TextWidth = imgui.CalcTextSize(RuleTable.Caption)
						imgui.SetCursorPosX(imgui.GetCursorPosX()+((imgui.GetColumnWidth() - TextWidth)/2))
						
						if RuleTable.Offset >= 0 then
							imgui.TextColored({ 0.9, 0.9, 0.0, 1.0 }, ('%s'):fmt(RuleTable.Caption) )
						else
							imgui.TextColored({ 0.0, 1.0, 0.0, 1.0 }, ('%s'):fmt(RuleTable.Caption) )
						end

						imgui.TableSetColumnIndex(2)

						--	Now, finally, execute the rule ...

						PacketDisplay.ExecuteRule(Packet, RuleTable, UI)

						CentralData.IDX = CentralData.IDX + 1
						
					end

				end

			end

			--	---------------------------------------------------------------
			--	END of rules loop
			--	---------------------------------------------------------------

			imgui.EndTable()

		end

	else
		imgui.TextColored({ 0.9, 0.9, 0.0, 1.0 }, ('No Rules') )	
	end

end

--	---------------------------------------------------------------------------
--	This executes a single decode by calling each decode function
--	---------------------------------------------------------------------------

function PacketDisplay.ExecuteDecode(UI, Packet, RuleTable, Command)

	if nil ~= Command and Command ~= '' then

		--	Function look-up table (enable the debug to see what is being accessed)

		for _, Cmd in pairs(PacketDisplay.functions) do
			if Cmd.cmd == Command then

				--imgui.TextColored( ETC.Brown, ('%d %d %d %d'):fmt(RuleTable.Offset, RuleTable.Bytes, RuleTable.Bit, RuleTable.Len) )

				if Cmd.param == 1 then
					Cmd.func(RuleTable)
				else
					Cmd.func(RuleTable, Packet)
				end
			
			end
		end

	end

end

-- Return the object

return PacketDisplay
