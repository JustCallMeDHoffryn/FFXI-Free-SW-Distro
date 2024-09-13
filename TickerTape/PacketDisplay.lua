--	---------------------------------------------------------------------------
--	This file contains the data processing for TickerTap
--	---------------------------------------------------------------------------

--	---------------------------------------------------------------------------

require('common')

local chat	= require('chat')
local imgui	= require('imgui')
local ETC	= require('ETC')

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
	
	if C1 ~= nil then
		if C1 >= 48 and C1 <= 57 then
			Value1 = C1 - 48
		else
			Value1 = C1 - 65 + 10
		end
	end

	if C2 ~= nil then
		if C2 >= 48 and C2 <= 57 then
			Value2 = C2 - 48
		else
			Value2 = C2 - 65 + 10
		end
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
		local BVal = 128

		XPos = imgui.GetCursorPosX()
		imgui.SetCursorPosX(imgui.GetCursorPosX()+10)

		imgui.TextColored( ETC.Dirty, ('[') )

		for i=1, 8 do
			
			imgui.SameLine()
			imgui.SetCursorPosX(XPos+10+(i*10))
			
			if 	BVal == Flag then
				if BAND ~= 0 then
					imgui.TextColored( ETC.Green, ('1') )
				else
					imgui.TextColored( ETC.Red, ('0') )
				end
			else
				if 0 ~= math.floor(bit.band(Byte, BVal)) then
					imgui.TextColored( ETC.Soft, ('1') )
				else
					imgui.TextColored( ETC.Soft, ('0') )
				end
			end

			BVal = math.floor(BVal / 2)

		end

		imgui.SameLine()
		imgui.SetCursorPosX(XPos+100)
		imgui.TextColored( ETC.Dirty, (']') )
		imgui.SameLine()

		imgui.SetCursorPosX(XPos+120)

		if BAND ~= 0 then
		
			if 'set' == RuleTable.Logic then
				PacketDisplay.Flags[RuleTable.Flag] = 1
			end

			imgui.TextColored( ETC.Green, ('%s'):fmt(RuleTable.Info) )
		
		else
		
			if 'set' == RuleTable.Logic then
				PacketDisplay.Flags[RuleTable.Flag] = 0
			end
		
			imgui.TextColored( ETC.Soft, ('%s'):fmt(RuleTable.Info) )
		
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
			imgui.TextColored(ETC.Brown, ('%s'):fmt(Decode.Actions[action]) )
		else
			imgui.TextColored({ 0.9, 0.9, 0.0, 1.0 }, ('%s'):fmt(Decode.Actions[action]) )
		end
	
		return	--	We don't want to exectute anything else ...

	end

	--	-----------------------------------------------------------------------
	--	WS Name
	--	-----------------------------------------------------------------------

	if 'wskill' == RuleTable.Decode then
		Decode.WSkill(Packet, PacketDisplay, RuleTable, PacketDisplay.GetValueByType(Packet, RuleTable))
		return
	end

	--	-----------------------------------------------------------------------
	--	Spell Name
	--	-----------------------------------------------------------------------

	if 'spell' == RuleTable.Decode then
		Decode.Spell(Packet, PacketDisplay, RuleTable, PacketDisplay.GetValueByType(Packet, RuleTable))
		return
	end

	--	-----------------------------------------------------------------------
	--	Merit points. We want to supress empty entries so don't drop through
	--	-----------------------------------------------------------------------

	if 'merit' == RuleTable.Decode then
		Decode.MeritPoints(Packet, PacketDisplay, RuleTable, PacketDisplay.GetValueByType(Packet, RuleTable))
		return
	end

	--	-----------------------------------------------------------------------
	--	Job points. We want to supress empty entries so don't drop through
	--	-----------------------------------------------------------------------

	if 'jpoint' == RuleTable.Decode then
		Decode.JobPoints(Packet, PacketDisplay, RuleTable)
		return
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
	--	Item (by ID)
	--	-----------------------------------------------------------------------

	if 'item' == RuleTable.Decode then
		Decode.Item(Packet, PacketDisplay, RuleTable, PacketDisplay.GetValueByType(Packet, RuleTable))
		--	Drop through to show raw values
	end

	--	-----------------------------------------------------------------------
	--	Bag
	--	-----------------------------------------------------------------------

	if 'store' == RuleTable.Decode then
		Decode.Store(Packet, PacketDisplay, RuleTable, PacketDisplay.GetValueByType(Packet, RuleTable))
		return		--	All on 1 line 
	end

	--	-----------------------------------------------------------------------
	--	IP Address
	--	-----------------------------------------------------------------------

	if 'ip' == RuleTable.Decode then
		Decode.IP(Packet, PacketDisplay, RuleTable)
	end

	--	-----------------------------------------------------------------------
	--	Vana'Diel Date
	--	-----------------------------------------------------------------------

	if 'vdate' == RuleTable.Decode then
		Decode.VDate(Packet, PacketDisplay, RuleTable, PacketDisplay.GetValueByType(Packet, RuleTable))
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
		local Brush = ETC.Yellow

		if nil ~= name then

			imgui.SetCursorPosX(imgui.GetCursorPosX()+10)

			if (('use' == RuleTable.Logic) and (0 == PacketDisplay.Flags[RuleTable.Flag])) then
				Brush = ETC.Brown
			end

			imgui.TextColored(Brush, ('%s'):fmt(name) )
	
		end

		--	NOTE .. we allow 'fall through' as we want the core to show the number

	end

	--	-----------------------------------------------------------------------
	--	Entity ID - This is just the index, so we can find what this is
	--	without having to know thw zone etc.. this may be a player so check
	--	-----------------------------------------------------------------------

	if 'eid' == RuleTable.Decode then

		local EID = PacketDisplay.GetValueByType(Packet, RuleTable)

		if 0 ~= EID then

			local name = AshitaCore:GetMemoryManager():GetEntity():GetName(EID)

			--	If NIL we allow it to drop through ..

			if nil ~= name then

				imgui.SetCursorPosX(imgui.GetCursorPosX()+10)

				if (('use' == RuleTable.Logic) and (0 == PacketDisplay.Flags[RuleTable.Flag])) then
					imgui.TextColored(ETC.Brown, ('%s'):fmt(name) )
				else
					imgui.TextColored({ 0.9, 0.9, 0.0, 1.0 }, ('%s'):fmt(name) )
				end
			end
		end

	end

	--	-----------------------------------------------------------------------
	--	Job (from table)
	--	-----------------------------------------------------------------------

	if 'job' == RuleTable.Decode then
		Decode.JobByte(UI, PacketDisplay, RuleTable, Packet, PacketDisplay.GetValueByType(Packet, RuleTable))
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
	--	Bit extraction
	--	-----------------------------------------------------------------------

	if 'craft' == RuleTable.Decode then
		Decode.Craft(PacketDisplay, RuleTable, Packet, PacketDisplay.GetValueByType(Packet, RuleTable))
	end
		
	--	-----------------------------------------------------------------------
	--	String (usually a name)
	--	-----------------------------------------------------------------------

	if 'string' == RuleTable.Decode then
		Decode.String(UI, PacketDisplay, RuleTable, Packet)
		return
	end

	--	-----------------------------------------------------------------------
	--	DBox Command
	--	-----------------------------------------------------------------------

	if 'dbox' == RuleTable.Decode then
		Decode.DBox(PacketDisplay, RuleTable, Packet, PacketDisplay.GetValueByType(Packet, RuleTable))
		return
	end

	--	-----------------------------------------------------------------------
	--	Music
	--	-----------------------------------------------------------------------

	if 'music' == RuleTable.Decode then
		Decode.Music(PacketDisplay, RuleTable, Packet, PacketDisplay.GetValueByType(Packet, RuleTable))
		return
	end

	--	-----------------------------------------------------------------------
	--	Status
	--	-----------------------------------------------------------------------

	if 'status' == RuleTable.Decode then
		Decode.Status(PacketDisplay, RuleTable, Packet, PacketDisplay.GetValueByType(Packet, RuleTable))
		return
	end

	--	-----------------------------------------------------------------------
	--	Info
	--	-----------------------------------------------------------------------

	if 'info' == RuleTable.Decode then

		imgui.SetCursorPosX(imgui.GetCursorPosX()+10)
		imgui.TextColored({ 1.0, 0.5, 1.0, 1.0 }, ('%s'):fmt(RuleTable.Info) )

		return
	end

	--	-----------------------------------------------------------------------
	--	Blue Spell (add 0x200)
	--	-----------------------------------------------------------------------

	if 'bluspell' == RuleTable.Decode then
		
		local Spell		= PacketDisplay.GetValueByType(Packet, RuleTable) + 0x200
		local Resource	= AshitaCore:GetResourceManager():GetSpellById(Spell)
		local Name		= nil

		if nil ~= Resource then
			Name = Resource.Name[1]
		end

		if Spell > 512 and nil ~= Name then
			
			imgui.SetCursorPosX(imgui.GetCursorPosX()+10)
			imgui.TextColored(ETC.OffW, ('%d'):fmt(Spell) )
			imgui.SameLine()
			imgui.TextColored(ETC.Green, ('%s'):fmt(Name) )

			return
		end

	end

	--	-----------------------------------------------------------------------
	--	Attachment (add 0x2100 to get sub ID)
	--	-----------------------------------------------------------------------

	if 'attach' == RuleTable.Decode then
		
		local Item		= PacketDisplay.GetValueByType(Packet, RuleTable) + 0x2100
		local Name		= nil

		imgui.SetCursorPosX(imgui.GetCursorPosX()+10)

		if Decode.Attach[Item] ~= nil then

			Name = Decode.Attach[Item]

			imgui.TextColored(ETC.OffW, ('%d'):fmt(Item) )
			imgui.SameLine()
			imgui.TextColored(ETC.Green, ('%s'):fmt(Name) )

		else

			imgui.TextColored(ETC.OffW, ('%d'):fmt(Item) )

		end

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
			imgui.TextColored(ETC.Brown, ('%d days  %.2d:%.2d:%.2d  %d ms'):fmt(value, hour, min, sec, ms) )
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

		local XPos = imgui.GetCursorPosX()
		imgui.SetCursorPosX(imgui.GetCursorPosX()+10)

		local value = PacketDisplay.ExtractByte(Packet, RuleTable.Offset)

		if (('use' == RuleTable.Logic) and (0 == PacketDisplay.Flags[RuleTable.Flag])) then
			imgui.TextColored(ETC.Brown, ('%d'):fmt(value) )
			imgui.SameLine()
			imgui.TextColored(ETC.Brown, ('(0x%.2X)'):fmt(value) )
		else
			imgui.TextColored(ETC.OffW, ('%d'):fmt(value) )
			imgui.SameLine()
			imgui.TextColored(ETC.Dirty, ('(0x%.2X)'):fmt(value) )
		end

		--	Packet size is an odd-ball, the data is shifted...

		if 'psize' == RuleTable.Decode then

			local value = PacketDisplay.ExtractByte(Packet, RuleTable.Offset)

			value = math.floor(value / 2)
			value = math.floor(value * 4)

			--	If packet size we don't bother with flags
			
			imgui.SameLine()
			imgui.SetCursorPosX(XPos+120)
			imgui.SameLine()
			imgui.TextColored(ETC.Dirty, (' >> '):fmt(value) )
			imgui.SameLine()

			imgui.TextColored(ETC.Green, ('%d'):fmt(value) )
			imgui.SameLine()
			imgui.TextColored(ETC.Dirty, ('(0x%.2X)'):fmt(value) )

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
			imgui.TextColored(ETC.Brown, ('%d'):fmt(value) )
			imgui.SameLine()
			imgui.TextColored(ETC.Brown, ('(0x%.4X)'):fmt(value) )
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
			imgui.TextColored(ETC.Brown, ('%d'):fmt(value) )
			imgui.SameLine()
			imgui.TextColored(ETC.Brown, ('  ..  0x%.8X'):fmt(value) )
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

		for i=1, 1024 do PacketDisplay.Flags[i] = 0 end

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

		if imgui.BeginTable("table1", 3, ImGuiTableFlags_Borders + ImGuiTableFlags_RowBg) then

			imgui.TableSetupColumn("1", ImGuiTableColumnFlags_WidthFixed, 50)
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

				if ((nil ~= RuleTable.Command) and (#RuleTable.Command > 0)) then

					if 'ifnot' == RuleTable.Command then
						
						local Value = PacketDisplay.GetValueByType(Packet, RuleTable)
						
						local Skip  = 1
						if 0 ~= RuleTable.CMDOpt2 then Skip = RuleTable.CMDOpt2 end

						if Value == RuleTable.CMDOpt1 then 
							CentralData.IDX	= CentralData.IDX + Skip
							ExecuteThis		= false
						end

					elseif 'if' == RuleTable.Command then

						local Value = PacketDisplay.GetValueByType(Packet, RuleTable)

						local Skip  = 1
						if 0 ~= RuleTable.CMDOpt2 then Skip = RuleTable.CMDOpt2 end

						if Value ~= RuleTable.CMDOpt1 then
							CentralData.IDX	= CentralData.IDX + Skip
							ExecuteThis		= false
						end

					elseif '@' ~= RuleTable.Command then
						
						ThisIsCommand = true
					
					end

				end

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
							imgui.TextColored({ 0.9, 0.9, 0.9, 1.0 }, ('0x%.3X'):fmt(RuleTable.Offset) )
						end

						imgui.TableSetColumnIndex(1)
						
						local TextWidth = imgui.CalcTextSize(RuleTable.String)
						imgui.SetCursorPosX(imgui.GetCursorPosX()+((imgui.GetColumnWidth() - TextWidth)/2))
						
						if RuleTable.Offset >= 0 then
							imgui.TextColored({ 0.9, 0.9, 0.0, 1.0 }, ('%s'):fmt(RuleTable.String) )
						else
							imgui.TextColored({ 0.0, 1.0, 0.0, 1.0 }, ('%s'):fmt(RuleTable.String) )
						end

						imgui.TableSetColumnIndex(2)

						--	Now execute the rule ...

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

-- Return the object

return PacketDisplay
