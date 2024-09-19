--	---------------------------------------------------------------------------
--	This file contains functions that can be used anywhere
--	---------------------------------------------------------------------------

local imgui	        = require('imgui')
local ETC	        = require('ETC')		    --	Our global data (brushes etc)
local CentralData	= require('CentralData')	--	Central data store

local XFunc = {}

--	---------------------------------------------------------------------------
--	Found on the internet, open source code (not mine)
--	---------------------------------------------------------------------------

function XFunc.BinToFloat32(bin1, bin2, bin3, bin4)

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

function XFunc.ExtractByte(Packet, Offset)

    --  Adjust for loop

    local Byte = Offset + CentralData.PlusByte

	local C1 = Packet.data:byte((Byte*2)+1, (Byte*2)+1)
	local C2 = Packet.data:byte((Byte*2)+2, (Byte*2)+2)

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
--	This returns a byte, word, dword etc (simple types)
--	---------------------------------------------------------------------------

function XFunc.GetValueByType(Packet, RuleTable)

	local value = 0

	if 1 == RuleTable.Bytes then
		value = XFunc.ExtractByte(Packet, RuleTable.Offset)
	elseif 2 == RuleTable.Bytes then
		value = XFunc.ExtractByte(Packet, RuleTable.Offset) + (256 * XFunc.ExtractByte(Packet, RuleTable.Offset + 1))
	elseif 4 == RuleTable.Bytes then
		for i = 0, 3 do
			value = (value * 256) + XFunc.ExtractByte(Packet, RuleTable.Offset + 3 - i)
		end
	end

	--	Whatever we have, even if it is zero, pass it back

	return value

end

--	---------------------------------------------------------------------------
--	Paint A 3D divide
--	---------------------------------------------------------------------------

function XFunc.Divide(line)

    imgui.SetCursorPosY(line)

    imgui.PushStyleColor(ImGuiCol_Separator, { 0.0, 0.0, 0.0, 1.0 })
    imgui.Separator()
    imgui.PopStyleColor()

    imgui.SetCursorPosY(line+1)

    imgui.PushStyleColor(ImGuiCol_Separator, { 0.3, 0.3, 0.3, 1.0 })
    imgui.Separator()
    imgui.PopStyleColor()

end

--	---------------------------------------------------------------------------
--	Paint a decimal int in curved brackets ( x )
--	---------------------------------------------------------------------------

function XFunc.Decimal(value, brush)

    imgui.TextColored( ETC.Dirty, '(' )
	imgui.SameLine()
	imgui.SetCursorPosX(imgui.GetCursorPosX() - 5)

	imgui.TextColored( brush, ('%d'):fmt(value) )
	
    imgui.SameLine()
	imgui.SetCursorPosX(imgui.GetCursorPosX() - 5)
	imgui.TextColored( ETC.Dirty, ')' )

end

function XFunc.Hex(value, brush, bits)

	imgui.TextColored( ETC.Dirty, '[' )
	imgui.SameLine()
	imgui.SetCursorPosX(imgui.GetCursorPosX() - 5)

	if bits > 16 then
		imgui.TextColored( brush, ('0x%.8X'):fmt(value) )
	elseif bits > 8 then
		imgui.TextColored( brush, ('0x%.4X'):fmt(value) )
	else
		imgui.TextColored( brush, ('0x%.2X'):fmt(value) )
	end

	imgui.SameLine()
	imgui.SetCursorPosX(imgui.GetCursorPosX() - 5)
	imgui.TextColored( ETC.Dirty, ']' )

end


--	---------------------------------------------------------------------------
--	This converts a string into a table of words
--	---------------------------------------------------------------------------

function XFunc.BuildWordList(Status, Words)

	local count		= 0
	local offset	= 1
	local index		= 0

	repeat

		index = string.find(Status, ' ', offset)

		if nil ~= index then

			part = ''

			for i=offset, (index - 1) do
				part = part .. Status[i]
			end

			count  = count + 1

			table.insert( Words , { index = count,
									text = part } )

			offset = index + 1

		end

	until nil == index

	--	We now have the last word to add

	part = ''

	repeat

		part = part .. Status[offset]
		offset = offset + 1

	until offset > string.len(Status)

	table.insert( Words , { index = count + 1,
							text = part } )

end

--	---------------------------------------------------------------------------
--	Paint a long string over several lines
--	---------------------------------------------------------------------------

function XFunc.PaintLongString(Name, brush, maxlen)

    --	Build a list of spaces

    local Used  = 0
    local Words = {}

    XFunc.BuildWordList(Name, Words)

    local Try1 = ''
    local Try2 = ''

    repeat
        
        Try1 = Try2
        Try2 = Try2 .. ' ' .. Words[Used+1].text

        if imgui.CalcTextSize(Try2) > maxlen then
            imgui.TextColored( brush, ('%s'):fmt(Try1) )
            Try1 = Words[Used+1].text
            Try2 = Words[Used+1].text
            imgui.SetCursorPosX(imgui.GetCursorPosX()+10)
        end

        Used = Used + 1

    until Used == #Words

    imgui.TextColored( brush, ('%s'):fmt(Try2) )

end

-- Return the XFunc object

return XFunc
