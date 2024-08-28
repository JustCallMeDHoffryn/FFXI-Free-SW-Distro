--	---------------------------------------------------------------------------
--	This file contains the data processing for TickerTap
--	---------------------------------------------------------------------------

--	---------------------------------------------------------------------------

require('common')

local chat	= require('chat')
local imgui	= require('imgui')

local PktDspRulesIN		= require('data/RulesIn')	--	Table of IN  display rules
local PktDspRulesOUT	= require('data/RulesOut')	--	Table of OUT display rules

local CentralData		= require('CentralData')
local Decode			= require('decode')
local DataProc			= require('DataProc')

local PacketDisplay = {

	ShowRaw		= T{true},
	Flags		= T{},

}

--	---------------------------------------------------------------------------
--	Found on the internet, open source code (not mine)
--	---------------------------------------------------------------------------

function PacketDisplay.BinToFloat32(bin1, bin2, bin3, bin4)

  local sig = bin3 % 0x80 * 0x10000 + bin2 * 0x100 + bin1
  local exp = bin4 % 0x80 * 2 + math.floor(bin3 / 0x80) - 0x7F
  
	if exp == 0x7F then 
		return 0 
	end
  
  return math.ldexp(math.ldexp(sig, -23) + 1, exp) * (bin4 < 0x80 and 1 or -1)

end

--	---------------------------------------------------------------------------
--	Extract a single byte from the data
--	---------------------------------------------------------------------------

function PacketDisplay.ExtractByte(Packet, Offset)

	local C1 = Packet.data:byte((Offset*2)+1, (Offset*2)+1)
	local C2 = Packet.data:byte((Offset*2)+2, (Offset*2)+2)

	local Value1 = 0
	local Value2 = 0
	
	if C1 >= 48 and C1 <= 57 then
		Value1 = C1 - 48
	else
		Value1 = C1 - 65 + 10
	end
	
	if C2 >= 48 and C2 <= 57 then
		Value2 = C2 - 48
	else
		Value2 = C2 - 65 + 10
	end

	return (Value1 * 16) + Value2
	
end

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
		
		imgui.TextColored({ 0.9, 0.9, 0.9, 1.0 }, ('%c%c'):fmt( Packet.data:byte((idx*2)+1, (idx*2)+1), Packet.data:byte((idx*2)+2, (idx*2)+2) ) )
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
--	This returns a byte, word, dword etc
--	---------------------------------------------------------------------------

function PacketDisplay.GetValueByType(Packet, RuleTable)

	local value = 0

	if 'byte' == RuleTable.Format then
		value = PacketDisplay.ExtractByte(Packet, RuleTable.Offset)
	elseif 'word' == RuleTable.Format then
		value = PacketDisplay.ExtractByte(Packet, RuleTable.Offset + 1) + (256 * PacketDisplay.ExtractByte(Packet, RuleTable.Offset))
	elseif 'rword' == RuleTable.Format then
		value = PacketDisplay.ExtractByte(Packet, RuleTable.Offset) + (256 * PacketDisplay.ExtractByte(Packet, RuleTable.Offset + 1))
	elseif 'dword' == RuleTable.Format then
		for i = 0, 3 do
			value = (value * 256) + PacketDisplay.ExtractByte(Packet, RuleTable.Offset + i)
		end
	elseif 'rdword' == RuleTable.Format then
		for i = 0, 3 do
			value = (value * 256) + PacketDisplay.ExtractByte(Packet, RuleTable.Offset + 3 - i)
		end
	end

	--	Whatever we have, even if it is zero, pass it back

	return value

end

--	---------------------------------------------------------------------------
--	This executes a single rule 
--	---------------------------------------------------------------------------

function PacketDisplay.ExecuteRule(Packet, RuleTable, UI)

	--	-----------------------------------------------------------------------
	--	Set a BOOL flag we may use later MUST be a single BYTE
	--	-----------------------------------------------------------------------

	if 'bool' == RuleTable.Decode then
	
		local Byte = PacketDisplay.ExtractByte(Packet, RuleTable.Offset)
		local Flag = RuleTable.Bit
		local BAND = bit.band(Byte, Flag)

		imgui.SetCursorPosX(imgui.GetCursorPosX()+10)

		if BAND ~= 0 then
			PacketDisplay.Flags[RuleTable.Flag] = 1
			imgui.TextColored( { 0.0, 1.0, 0.0, 1.0 }, ('%s'):fmt(RuleTable.Info) )
		else
			PacketDisplay.Flags[RuleTable.Flag] = 0
			imgui.TextColored( { 0.5, 0.5, 0.5, 1.0 }, ('%s'):fmt(RuleTable.Info) )
		end

		return	--	We don't want to exectute anything else ...
		
	end

	--	-----------------------------------------------------------------------
	--	Player action
	--	-----------------------------------------------------------------------

	if 'action' == RuleTable.Decode then

		local action = PacketDisplay.GetValueByType(Packet, RuleTable)

		imgui.SetCursorPosX(imgui.GetCursorPosX()+10)

		if (('use' == RuleTable.Logic) and (0 == PacketDisplay.Flags[RuleTable.Flag])) then
			imgui.TextColored({ 0.4, 0.4, 0.4, 1.0 }, ('%s'):fmt(Decode.Actions[action]) )
		else
			imgui.TextColored({ 0.9, 0.9, 0.0, 1.0 }, ('%s'):fmt(Decode.Actions[action]) )
		end
	
		return	--	We don't want to exectute anything else ...

	end

	--	-----------------------------------------------------------------------
	--	XYZ - May have more than one format, so check
	--	-----------------------------------------------------------------------

	if 'xyz' == RuleTable.Decode then
		if '12bytes' == RuleTable.Format then
			Decode.XYZ_12Bytes(Packet, PacketDisplay, RuleTable)
			return
		end
	end
	
	--	-----------------------------------------------------------------------
	--	Entity - This is a FULL ID, converted into a local index before display
	--	-----------------------------------------------------------------------
	
	if 'entity' == RuleTable.Decode then

		local value = PacketDisplay.GetValueByType(Packet, RuleTable)
		local party = AshitaCore:GetMemoryManager():GetParty()
		local zone	= party:GetMemberZone(0)
		local base	= 0x1001000 + ((zone - 1) * 4096)
		local npc	= value - base
		local name	= AshitaCore:GetMemoryManager():GetEntity():GetName(npc)
		local Brush = UI.Yellow

		imgui.SetCursorPosX(imgui.GetCursorPosX()+10)

		if (('use' == RuleTable.Logic) and (0 == PacketDisplay.Flags[RuleTable.Flag])) then
			Brush = UI.Grey1
		end

		if nil == name then
			name  = "Cannot Identify Entity"
			Brush = UI.Dirty
		end
	
		imgui.TextColored(Brush, ('%s'):fmt(name) )

		--	NOTE .. we allow 'fall through' as we want the core to show the number

	end

	--	-----------------------------------------------------------------------
	--	Entity ID - This is just the index, so we can find what this is
	--	without having to know thw zone etc.. this may be a player so check
	--	-----------------------------------------------------------------------

	if 'eid' == RuleTable.Decode then
					
		local EID = PacketDisplay.GetValueByType(Packet, RuleTable)
		
		imgui.SetCursorPosX(imgui.GetCursorPosX()+10)

		if 0 == EID then
			imgui.TextColored({ 0.4, 0.4, 0.4, 1.0 }, ('- - -') )
		else
		
			local name = AshitaCore:GetMemoryManager():GetEntity():GetName(EID)

			if (('use' == RuleTable.Logic) and (0 == PacketDisplay.Flags[RuleTable.Flag])) then
				imgui.TextColored({ 0.4, 0.4, 0.4, 1.0 }, ('%s'):fmt(name) )
			else
				imgui.TextColored({ 0.9, 0.9, 0.0, 1.0 }, ('%s'):fmt(name) )
			end
		
		end					
		
	end

	--	-----------------------------------------------------------------------
	--	Job (from table)
	--	-----------------------------------------------------------------------

	if 'job' == RuleTable.Decode then
		Decode.JobByte(PacketDisplay, RuleTable, Packet, PacketDisplay.GetValueByType(Packet, RuleTable))
		return
	end

	--	-----------------------------------------------------------------------
	--	Direction (this is WRONG in every packet viewer I have seen)
	--	-----------------------------------------------------------------------

	if 'dir' == RuleTable.Decode then
		Decode.Direction(UI, PacketDisplay, RuleTable, Packet, PacketDisplay.GetValueByType(Packet, RuleTable))
		return
	end

	--	-----------------------------------------------------------------------
	--	Bit extraction
	--	-----------------------------------------------------------------------

	if 'bits' == RuleTable.Decode then
		Decode.Bits(UI, PacketDisplay, RuleTable, Packet, PacketDisplay.GetValueByType(Packet, RuleTable))
		return
	end

	--	-----------------------------------------------------------------------
	--	String (usually a name)
	--	-----------------------------------------------------------------------

	if 'string' == RuleTable.Decode then
		Decode.String(PacketDisplay, RuleTable, Packet)
		return
	end

	--	-----------------------------------------------------------------------
	--	Time is shown as D, H, M, S and MS
	--	-----------------------------------------------------------------------
	
	if 'time' == RuleTable.Decode then
	
		local value = PacketDisplay.GetValueByType(Packet, RuleTable)

		local ms    = value % 1000
		local value = value / 1000
		local sec   = value % 60
		local value = value / 60
		local min   = value % 60
		local value = value / 60
		local hour  = value % 24
		local value = value / 24
		
		imgui.SetCursorPosX(imgui.GetCursorPosX()+10)

		if (('use' == RuleTable.Logic) and (0 == PacketDisplay.Flags[RuleTable.Flag])) then
			imgui.TextColored({ 0.4, 0.4, 0.4, 1.0 }, ('%d days  %.2d:%.2d:%.2d  %d ms'):fmt(value, hour, min, sec, ms) )
		else
			imgui.TextColored({ 0.9, 0.9, 0.0, 1.0 }, ('%d days  %.2d:%.2d:%.2d  %d ms'):fmt(value, hour, min, sec, ms) )
		end

		return

	end

	--	-----------------------------------------------------------------------
	--	If we get here then any special cases have been processed so we just
	--	dump the data we have. Flags can be used in all cases
	--	-----------------------------------------------------------------------

	if 'byte' == RuleTable.Format then

		imgui.SetCursorPosX(imgui.GetCursorPosX()+10)

		local value = PacketDisplay.ExtractByte(Packet, RuleTable.Offset)

		if (('use' == RuleTable.Logic) and (0 == PacketDisplay.Flags[RuleTable.Flag])) then
			imgui.TextColored({ 0.5, 0.5, 0.5, 1.0 }, ('%d'):fmt(value) )
			imgui.SameLine()
			imgui.TextColored({ 0.4, 0.4, 0.4, 1.0 }, ('(0x%.2X)'):fmt(value) )
		else
			imgui.TextColored({ 0.9, 0.9, 0.9, 1.0 }, ('%d'):fmt(value) )
			imgui.SameLine()
			imgui.TextColored({ 0.7, 0.7, 0.7, 1.0 }, ('(0x%.2X)'):fmt(value) )
		end

		Decode.CheckForTable(UI, RuleTable, value)

	end

	--	-----------------------------------------------------------------------
	--	Reverse WORD (2 bytes in reverse)
	--	-----------------------------------------------------------------------
	
	if 'rword' == RuleTable.Format or 'word' == RuleTable.Format then

		imgui.SetCursorPosX(imgui.GetCursorPosX()+10)
		
		local value = PacketDisplay.GetValueByType(Packet, RuleTable)
	
		if (('use' == RuleTable.Logic) and (0 == PacketDisplay.Flags[RuleTable.Flag])) then
			imgui.TextColored({ 0.5, 0.5, 0.5, 1.0 }, ('%d'):fmt(value) )
			imgui.SameLine()
			imgui.TextColored({ 0.4, 0.4, 0.4, 1.0 }, ('(0x%.4X)'):fmt(value) )
		else
			imgui.TextColored({ 0.9, 0.9, 0.9, 1.0 }, ('%d'):fmt(value) )
			imgui.SameLine()
			imgui.TextColored({ 0.7, 0.7, 0.7, 1.0 }, ('(0x%.4X)'):fmt(value) )
		end

		Decode.CheckForTable(UI, RuleTable, value)

	end

	--	-----------------------------------------------------------------------
	--	Reverse DWORD (4 bytes in reverse)
	--	-----------------------------------------------------------------------

	if 'rdword' == RuleTable.Format then

		imgui.SetCursorPosX(imgui.GetCursorPosX()+10)

		local value = PacketDisplay.GetValueByType(Packet, RuleTable)

		if (('use' == RuleTable.Logic) and (0 == PacketDisplay.Flags[RuleTable.Flag])) then
			imgui.TextColored({ 0.4, 0.4, 0.4, 1.0 }, ('%d'):fmt(value) )
			imgui.SameLine()
			imgui.TextColored({ 0.4, 0.4, 0.4, 1.0 }, ('  ..  0x%.8X'):fmt(value) )
		else
			imgui.TextColored({ 0.9, 0.9, 0.9, 1.0 }, ('%d'):fmt(value) )
			imgui.SameLine()
			imgui.TextColored({ 0.7, 0.7, 0.7, 1.0 }, ('  ..  0x%.8X'):fmt(value) )
		end

		Decode.CheckForTable(UI, RuleTable, value)

	end

end

--	---------------------------------------------------------------------------
--	Called to verify that a rule exists in the correct table
--	---------------------------------------------------------------------------

function PacketDisplay.VerifyPacketRule(direction, target)

	local found = false

	if 1 == direction then

		for Group, RuleTable in pairs(PktDspRulesIN) do

			if nil ~= RuleTable and Group == target then
				found = true
			end
		end

	else

		for Group, RuleTable in pairs(PktDspRulesOUT) do

			if nil ~= RuleTable and Group == target then
				found = true
			end
		end

	end

	return found

end

--	---------------------------------------------------------------------------
--	Called when we want to decode a packet into a series of text lines
--	---------------------------------------------------------------------------

function PacketDisplay.ShowPacket(Packet, UI, ThisSlice)

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
	imgui.SetCursorPosX(xPos+275)

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
	
	imgui.SetCursorPosY(imgui.GetCursorPosY()+4)
	
	imgui.PushStyleColor(ImGuiCol_Separator, { 0.0, 0.0, 0.0, 1.0 })
	imgui.Separator()
	imgui.PopStyleColor()

	--	Show the raw data

	if PacketDisplay.ShowRaw[1] then 
		imgui.SetCursorPosY(imgui.GetCursorPosY()+10)
		PacketDisplay.RenderRawData(Packet)	
	end
	
	--	-----------------------------------------------------------------------
	--	Now try and unpack it
	--	-----------------------------------------------------------------------

	local found = false

	--print(string.format('Searching for Rules'))

	CentralData.PacketRules = T{}

	if 1 == Packet.direction then

		for Group, RuleTable in pairs(PktDspRulesIN) do

			if nil ~= RuleTable and Group == Packet.packet then
				found = true
				DataProc.DecodeRuleTable(RuleTable)
			end
		end

	else

		for Group, RuleTable in pairs(PktDspRulesOUT) do

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

		for i=1, 1024 do
			PacketDisplay.Flags[i] = 0
		end

		-- Sort the rules, we want them in numerical order

		CentralData.PacketRules:sort(function (a, b)
			return (a.Index < b.Index)
		end)

		local RuleSize = 0

		for Rule, RuleTable in pairs(CentralData.PacketRules) do
			RuleSize = RuleSize + 1
		end

		--print(string.format('Rules: %d', RuleSize))

		imgui.SetCursorPosY(imgui.GetCursorPosY()+20)

		if imgui.BeginTable("table1", 4, ImGuiTableFlags_Borders + ImGuiTableFlags_RowBg) then

			imgui.TableSetupColumn("1", ImGuiTableColumnFlags_WidthFixed, 45)
			imgui.TableSetupColumn("2", ImGuiTableColumnFlags_WidthFixed, 30)
			imgui.TableSetupColumn("3", ImGuiTableColumnFlags_WidthFixed, 100)

			--	---------------------------------------------------------------
			--	Execute the rules, one at a time
			--	---------------------------------------------------------------

			while RuleSize > 0 and CentralData.IDX > 0 and CentralData.IDX <= RuleSize do

				--print(string.format('Line %d of %d', CentralData.IDX, RuleSize))
			
				RuleSize = 0

				for Rule, RuleTable in pairs(CentralData.PacketRules) do
					RuleSize = RuleSize + 1
				end
					
				RuleTable = CentralData.PacketRules[CentralData.IDX]

				if ((nil ~= RuleTable.Command) and (#RuleTable.Command > 0)) then

					if DataProc.ProcessCommand(PacketDisplay, RuleTable, Packet) then
						CentralData.IDX = CentralData.IDX + 1
					else

						RuleSize = 0

						for Rule, RuleTable in pairs(CentralData.PacketRules) do
							RuleSize = RuleSize + 1
						end
		
						RuleTable = CentralData.PacketRules[CentralData.IDX]

					end

				else

					--	If we get here then it is a normal decode line

					imgui.TableNextRow()

					imgui.TableSetColumnIndex(0)
					imgui.TextColored({ 0.9, 0.9, 0.9, 1.0 }, ('0x%.3X'):fmt(RuleTable.Offset) )

					imgui.TableSetColumnIndex(1)

					local Bit = '-'
					
					if RuleTable.Bit ~= 0 or RuleTable.Decode == 'bits' then
						Bit = string.format('%d', RuleTable.Bit)
					end

					local TextWidth = imgui.CalcTextSize(Bit)
					imgui.SetCursorPosX(imgui.GetCursorPosX()+((imgui.GetColumnWidth() - TextWidth)/2))

					if RuleTable.Bit ~= 0 or RuleTable.Decode == 'bits' then
						imgui.TextColored({ 0.0, 1.0, 0.0, 1.0 }, ('%s'):fmt(Bit) )
					else
						imgui.TextColored({ 0.5, 0.5, 0.5, 1.0 }, ('%s'):fmt(Bit) )
					end

					imgui.TableSetColumnIndex(2)
					local TextWidth = imgui.CalcTextSize(RuleTable.String)
					imgui.SetCursorPosX(imgui.GetCursorPosX()+((imgui.GetColumnWidth() - TextWidth)/2))
					imgui.TextColored({ 0.9, 0.9, 0.0, 1.0 }, ('%s'):fmt(RuleTable.String) )
					
					imgui.TableSetColumnIndex(3)
					
					--	Now execute the rule ...

					PacketDisplay.ExecuteRule(Packet, RuleTable, UI)

					CentralData.IDX = CentralData.IDX + 1
					
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

-- Return the object

return PacketDisplay
