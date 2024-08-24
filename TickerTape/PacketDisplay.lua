--	---------------------------------------------------------------------------
--	This file contains the data processing for TickerTap
--	---------------------------------------------------------------------------

--	---------------------------------------------------------------------------

require('common')

local chat	= require('chat')
local imgui	= require('imgui')

local PktDspRulesIN		= require('data/RulesIn')	--	Table of IN  display rules
local PktDspRulesOUT	= require('data/RulesOut')	--	Table of OUT display rules

local Decode			= require('decode')

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
--	Called when we want to encode a packet into a text string
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
	
	--	Now try and unpack it
	
	local ThisPacketRules = T{}		--	Start with an empty table
	local found = false
	
	if 1 == Packet.direction then
	
		for Group, RuleTable in pairs(PktDspRulesIN) do
	
			if nil ~= RuleTable and Group == Packet.packet then

				found = true
				
				for Item, ItemDef in pairs(RuleTable) do
			
					ThisPacketRules:append(T{	Index	= Item,
												Offset	= ItemDef[1],
												Bit		= ItemDef[2],	--	This is the value of the bit, ie bit 7 is 128
												String	= ItemDef[3],	--	Caption to tell the user what it is
												Format	= ItemDef[4],
												Logic	= ItemDef[5],	--	none, use, set
												Flag	= ItemDef[6],	--	Can use or set (see Format) flag from 1 to 1024
												Decode	= ItemDef[7],	--	Basic decode type
												Info	= ItemDef[8],	--	Info shown when type is a bool
											} )
					
				end
				
			end
		end
		
	else
	
		for Group, RuleTable in pairs(PktDspRulesOUT) do
	
			if nil ~= RuleTable and Group == Packet.packet then

				found = true
				
				for Item, ItemDef in pairs(RuleTable) do
			
					ThisPacketRules:append(T{	Index	= Item,
												Offset	= ItemDef[1],
												Bit		= ItemDef[2],	--	This is the value of the bit, ie bit 7 is 128
												String	= ItemDef[3],	--	Caption to tell the user what it is
												Format	= ItemDef[4],
												Logic	= ItemDef[5],	--	none, use, set
												Flag	= ItemDef[6],	--	Can use or set (see Format) flag from 1 to 1024
												Decode	= ItemDef[7],	--	Basic decode type
												Info	= ItemDef[8],	--	Info shown when type is a bool
											} )
					
				end
				
			end
		end

	end

	if found then
		
		--	All flags are off by default
		
		for i=1, 1024 do
			PacketDisplay.Flags[i] = 0
		end
		
		-- Sort the rules, we want them in order

		ThisPacketRules:sort(function (a, b)
			return (a.Index < b.Index)
		end)

		imgui.SetCursorPosY(imgui.GetCursorPosY()+20)

		if imgui.BeginTable("table1", 4, ImGuiTableFlags_Borders + ImGuiTableFlags_RowBg) then

			imgui.TableSetupColumn("1", ImGuiTableColumnFlags_WidthFixed, 50)
			imgui.TableSetupColumn("2", ImGuiTableColumnFlags_WidthFixed, 20)
			imgui.TableSetupColumn("3", ImGuiTableColumnFlags_WidthFixed, 80)

			for Rule, RuleTable in pairs(ThisPacketRules) do
			
				imgui.TableNextRow()

				imgui.TableSetColumnIndex(0)
				imgui.TextColored({ 0.9, 0.9, 0.9, 1.0 }, ('0x%.3X'):fmt(RuleTable.Offset) )

				imgui.TableSetColumnIndex(1)
				imgui.SetCursorPosX(imgui.GetCursorPosX()+5)
				
				if RuleTable.Bit ~= 0 then
					imgui.TextColored({ 0.9, 0.9, 0.9, 1.0 }, ('%d'):fmt(RuleTable.Bit) )
				else
					imgui.TextColored({ 0.9, 0.9, 0.9, 1.0 }, ('-') )
				end
				
				imgui.TableSetColumnIndex(2)
				imgui.TextColored({ 0.9, 0.9, 0.0, 1.0 }, ('%s'):fmt(RuleTable.String) )
				
				imgui.TableSetColumnIndex(3)

				--	A single BYTE - Can use FLAGS

				if 'byte' == RuleTable.Format then

					local value = PacketDisplay.ExtractByte(Packet, RuleTable.Offset)
					
					if (('use' == RuleTable.Logic) and (0 == PacketDisplay.Flags[RuleTable.Flag])) then
						imgui.TextColored({ 0.4, 0.4, 0.4, 1.0 }, ('%d'):fmt(value) )
						imgui.SameLine()
						imgui.TextColored({ 0.4, 0.4, 0.4, 1.0 }, ('(0x%.2X)'):fmt(value) )
					else
						imgui.TextColored({ 0.9, 0.9, 0.9, 1.0 }, ('%d'):fmt(value) )
						imgui.SameLine()
						imgui.TextColored({ 0.7, 0.7, 0.7, 1.0 }, ('(0x%.2X)'):fmt(value) )
					end
					
				end

				--	Reverse WORD (2 bytes in reverse)
				
				if 'rword' == RuleTable.Format then
								
					local value1 = PacketDisplay.ExtractByte(Packet, RuleTable.Offset)
					local value2 = PacketDisplay.ExtractByte(Packet, RuleTable.Offset + 1)
					
					imgui.TextColored({ 0.9, 0.9, 0.9, 1.0 }, ('%d'):fmt(value1 + (value2 * 256)) )
					imgui.SameLine()
					imgui.TextColored({ 0.7, 0.7, 0.7, 1.0 }, ('(0x%.4X)'):fmt(value1 + (value2 * 256)) )
				
				end

				--	Reverse DWORD (4 bytes in reverse)
				
				if 'rdword' == RuleTable.Format then
					Decode.RDWORD(PacketDisplay, RuleTable, Packet)				
				end
				
				--	Single bit flags (the Info is shown if the flag bit is set)
				
				if 'bool' == RuleTable.Decode then
				
					local Byte = PacketDisplay.ExtractByte(Packet, RuleTable.Offset)
					local Flag = RuleTable.Bit
					local BAND = bit.band(Byte, Flag)

					if BAND ~= 0 then
						PacketDisplay.Flags[RuleTable.Flag] = 1
						imgui.TextColored( { 0.9, 0.9, 0.0, 1.0 }, ('%s'):fmt(RuleTable.Info) )
					else
						PacketDisplay.Flags[RuleTable.Flag] = 0
						imgui.TextColored( { 0.4, 0.4, 0.4, 1.0 }, ('%s'):fmt(RuleTable.Info) )
					end
					
				end
			
				--	Position decode (X,Y,Z) - Can use flags
				
				if 'xyz' == RuleTable.Decode then
				
					local B1 = PacketDisplay.ExtractByte(Packet, RuleTable.Offset)
					local B2 = PacketDisplay.ExtractByte(Packet, RuleTable.Offset + 1)
					local B3 = PacketDisplay.ExtractByte(Packet, RuleTable.Offset + 2)
					local B4 = PacketDisplay.ExtractByte(Packet, RuleTable.Offset + 3)
				
					if (('use' == RuleTable.Logic) and (0 == PacketDisplay.Flags[RuleTable.Flag])) then
						imgui.TextColored( { 0.4, 0.4, 0.4, 1.0 }, ('X:%.2f  '):fmt( PacketDisplay.BinToFloat32( B1, B2, B3, B4 ) ) )
					else
						imgui.TextColored( { 0.9, 0.9, 0.0, 1.0 }, ('X:%.2f  '):fmt( PacketDisplay.BinToFloat32( B1, B2, B3, B4 ) ) )
					end
					
					imgui.SameLine()

					local B1 = PacketDisplay.ExtractByte(Packet, RuleTable.Offset + 4)
					local B2 = PacketDisplay.ExtractByte(Packet, RuleTable.Offset + 5)
					local B3 = PacketDisplay.ExtractByte(Packet, RuleTable.Offset + 6)
					local B4 = PacketDisplay.ExtractByte(Packet, RuleTable.Offset + 7)

					if (('use' == RuleTable.Logic) and (0 == PacketDisplay.Flags[RuleTable.Flag])) then
						imgui.TextColored( { 0.4, 0.4, 0.4, 1.0 }, ('Y:%.2f  '):fmt( PacketDisplay.BinToFloat32( B1, B2, B3, B4 ) ) )
					else
						imgui.TextColored( { 0.9, 0.9, 0.0, 1.0 }, ('Y:%.2f  '):fmt( PacketDisplay.BinToFloat32( B1, B2, B3, B4 ) ) )
					end
					
					imgui.SameLine()

					local B1 = PacketDisplay.ExtractByte(Packet, RuleTable.Offset + 8)
					local B2 = PacketDisplay.ExtractByte(Packet, RuleTable.Offset + 9)
					local B3 = PacketDisplay.ExtractByte(Packet, RuleTable.Offset + 10)
					local B4 = PacketDisplay.ExtractByte(Packet, RuleTable.Offset + 11)

					if (('use' == RuleTable.Logic) and (0 == PacketDisplay.Flags[RuleTable.Flag])) then
						imgui.TextColored( { 0.4, 0.4, 0.4, 1.0 }, ('Z:%.2f'):fmt( PacketDisplay.BinToFloat32( B1, B2, B3, B4 ) ) )
					else
						imgui.TextColored( { 0.9, 0.9, 0.0, 1.0 }, ('Z:%.2f'):fmt( PacketDisplay.BinToFloat32( B1, B2, B3, B4 ) ) )
					end
					
				end
				
			end
	
			imgui.EndTable()

		end
		
	else
		imgui.TextColored({ 0.9, 0.9, 0.0, 1.0 }, ('No Rules') )	
	end

end

-- Return the object

return PacketDisplay
