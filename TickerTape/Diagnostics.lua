--	---------------------------------------------------------------------------
--	This file contains the diagnostic display for TT
--	---------------------------------------------------------------------------

require('common')
require('os')

local chat			= require('chat')
local imgui			= require('imgui')
local CentralData	= require('CentralData')
local PacketDisplay = require('PacketDisplay')

local DIAG = {

    PacketByteIn  = { '0' },
    PacketBitIn   = { '0' },

    PacketByteOffset = 0,
    PacketBitOffset  = 0,

    RegisterByteIn  = { '0' },
    RegisterBitIn   = { '0' },
    RegisterBitsIn  = { '0' },

    RegisterByteOffset = 0,
    RegisterBitOffset  = 0,
    RegisterBitsCount  = 0,

    Result = 0,

    ComboSelected = 0,
    ComboMode     = 0,

    ComboOptions  = { },
}

local X64Data = {}

--	---------------------------------------------------------------------------
--	Build the empty register
--	---------------------------------------------------------------------------

function DIAG.BuildX64()

    for i=1, 64 do
    
        table.insert( X64Data,	{   BitIndex	= i,
                                    BiValue     = 0
                                }   )
    end

    table.sort(X64Data, (function (a, b)
        return (a.BitIndex < b.BitIndex)
        end))

    --  Combo box

    table.insert( DIAG.ComboOptions, { index = 1, text = 'Actor'    } )
    table.insert( DIAG.ComboOptions, { index = 2, text = 'Spell'    } )
    table.insert( DIAG.ComboOptions, { index = 3, text = 'Item'     } )
    table.insert( DIAG.ComboOptions, { index = 4, text = 'Action'   } )

    table.sort(DIAG.ComboOptions, (function (a, b)
        return (a.index < b.index)
        end))
            
end

--	---------------------------------------------------------------------------
--	Extract a HEX value from a string
--	---------------------------------------------------------------------------

function DIAG.GetStr2Hex(StrIn)

	local Hunt = 0

	for i=1, string.len(StrIn) do

		Hunt = Hunt * 16

		local This = StrIn:byte(i, i)

		if This >= 48 and This <= 57 then		--	0 ~ 9
			Hunt = Hunt + This - 48
		end

		if This >= 65 and This <= 70 then		--	A ~ F
			Hunt = Hunt + This - 65 + 10
		end

		if This >= 97 and This <= 102 then		--	a ~ f
			Hunt = Hunt + This - 97 + 10
		end

	end

    return Hunt

end

--	---------------------------------------------------------------------------
--	Extract a DEC value from a string
--	---------------------------------------------------------------------------

function DIAG.GetStr2Dec(StrIn)

	local Hunt = 0

	for i=1, string.len(StrIn) do

		Hunt = Hunt * 10

		local This = StrIn:byte(i, i)

		if This >= 48 and This <= 57 then		--	0 ~ 9
			Hunt = Hunt + This - 48
		end

	end

    return Hunt

end

--	---------------------------------------------------------------------------
--	Extract the various parameters
--	---------------------------------------------------------------------------

function DIAG.ExtractPacketStartByte()
    DIAG.PacketByteOffset = DIAG.GetStr2Hex(DIAG.PacketByteIn[1])
end

function DIAG.ExtractPacketStartBit()
    DIAG.PacketBitOffset = DIAG.GetStr2Dec(DIAG.PacketBitIn[1])
end

function DIAG.ExtractRegisterStartByte()
    DIAG.RegisterByteOffset = DIAG.GetStr2Hex(DIAG.RegisterByteIn[1])
end

function DIAG.ExtractRegisterStartBit()
    DIAG.RegisterBitOffset = DIAG.GetStr2Dec(DIAG.RegisterBitIn[1])
end

function DIAG.ExtractRegisterStartBits()
    DIAG.RegisterBitsCount = DIAG.GetStr2Dec(DIAG.RegisterBitsIn[1])
end

--	---------------------------------------------------------------------------
--	Read the processor value
--	---------------------------------------------------------------------------

function DIAG.ReadProcessor(Packet)

    local index = DIAG.RegisterBitOffset + 1
    local byte  = DIAG.RegisterByteOffset
    local bits  = DIAG.RegisterBitsCount
    
    while byte > 0 do
        byte  = byte - 1
        index = index + 8
    end

    local value = 0

    while bits > 0 and index < 65 do

        --print(string.format('index: %d, bits: %d, X64: %d', index, bits, X64Data[index].BiValue))

        if 1 == X64Data[index].BiValue then
            value = value + math.pow(2, (DIAG.RegisterBitsCount - bits))
        end

        index = index + 1
        bits  = bits  - 1

    end

    DIAG.Result = value

end

--	---------------------------------------------------------------------------
--	Load the processor value
--	---------------------------------------------------------------------------

function DIAG.LoadProcessor(UI, Packet)

    local index     = 1
    local byte      = DIAG.PacketByteOffset
    local bit       = DIAG.PacketBitOffset
    local bitsleft  = 8

    --  Correct a big bit offset

    while bit > 7 do
        bit  = bit - 8
        byte = byte + 1
    end

    --  Get the byte with the first bit

    local this = PacketDisplay.ExtractByte(Packet, byte)
    
    --  Shuffle off any remaining bottom bits we dont want

    while bit > 0 do
        bit      = bit - 1
        bitsleft = bitsleft  - 1
        this     = math.floor(this / 2)
    end

    --  Now extract 64 bits worth of data

    repeat

        if byte >= Packet.size then
            X64Data[index].BiValue = 2
        else
            if 1 == this % 2 then 
                X64Data[index].BiValue = 1
            else
                X64Data[index].BiValue = 0
            end
        end

		this = math.floor(this / 2)
		bitsleft = bitsleft - 1

        if 0 == bitsleft then
            byte     = byte + 1
            this     = PacketDisplay.ExtractByte(Packet, byte)
            bitsleft = 8
        end

        index = index + 1

    until index == 65

end

--	---------------------------------------------------------------------------
--	Show the contents of the register
--	---------------------------------------------------------------------------

function DIAG.ShowRegister(UI, Packet)

    --  Before we start we work out the range of bits

    local   first = (DIAG.RegisterByteOffset * 8) + DIAG.RegisterBitOffset
    local   count = DIAG.RegisterBitsCount
    local   last  = first + count - 1

    local   Grey  = { 0.9, 0.9, 0.9, 1.0 }
    local   Used1 = { 1.0, 0.6, 0.0, 1.0 }
    local   Used2 = { 0.8, 0.4, 0.0, 1.0 }

    local ms = math.floor((os.clock() * 1000) % 1000)
        
    for j=1, 8 do

        for i=1, 8 do

            local Brush = Grey
            local index = ((j-1) * 8) + i

            if count > 0 then
                if (index - 1) >= first and (index - 1) <= last then
                    Brush = Used1
                    if ms > 499 then
                        Brush = Used2
                    end
                end
            end

            imgui.SetCursorPosY(25)
            imgui.SameLine()
            imgui.SetCursorPosX((10 * i) + ((j - 1) * 90))
            
            if nil == Packet then
                imgui.TextColored( Brush, '#' )
            else

                if 1 == X64Data[i+((j-1)*8)].BiValue then
                    imgui.TextColored( Brush, '1' )
                elseif 0 == X64Data[i+((j-1)*8)].BiValue then
                    imgui.TextColored( Brush, '0' )
                else
                    imgui.TextColored( Brush, '#' )
                end

            end
        end
    end
end

--	---------------------------------------------------------------------------
--	Paint A 3D divide
--	---------------------------------------------------------------------------

function DIAG.Divide(line)

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
--	Paint the combo box
--	---------------------------------------------------------------------------

function DIAG.ShowCombo()

    local flags = ImGuiComboFlags_PopupAlignLeft

    imgui.SetNextItemWidth( 100 )

    imgui.SetCursorPosY(155)
    imgui.SetCursorPosX(343)

    local Preview = 'Decode'

    if DIAG.ComboSelected > 0 then
        Preview = DIAG.ComboOptions[DIAG.ComboSelected].text
    end

    if (imgui.BeginCombo('##Decode Options', Preview, flags)) then

        for i=1, #DIAG.ComboOptions do

            if imgui.Selectable((DIAG.ComboOptions[i].text), (DIAG.ComboSelected == i)) then
                DIAG.ComboSelected = i
            end

        end

        imgui.EndCombo()
    
    end

end

--	---------------------------------------------------------------------------
--	?
--	---------------------------------------------------------------------------

function DIAG.ShowWindow(UI)

    imgui.SetNextWindowSize( { 733, 210, } )
    imgui.SetNextWindowSizeConstraints({ 733 , 210, }, { FLT_MAX, FLT_MAX, })

    if (imgui.Begin('X64 - Bit Diagnostics', 1, ImGuiWindowFlags_NoResize)) then

        --  Look for the active packet

        local Packet = nil

		if -1 ~= UI.LineSel then
		
			local ThisSlice = UI.StackIn - UI.StackSize + UI.LineSel - 1
		
			if ThisSlice > UI.WindowSize then ThisSlice = ThisSlice - UI.WindowSize end
			if ThisSlice < 1 then ThisSlice = ThisSlice + UI.WindowSize end

			if 0 ~= UI.PacketStack[ThisSlice].packet then
                Packet = UI.PacketStack[ThisSlice]
			end
        
        end

        --  Show the register 

        DIAG.ShowRegister(UI, Packet)
        DIAG.Divide(58)

        --  Load Register

        imgui.SetCursorPosY(76)
        imgui.SetCursorPosX(12)

        imgui.TextColored( { 0.9, 0.9, 0.9, 1.0 }, 'Packet:' )
        imgui.SameLine()
        imgui.TextColored( { 0.0, 1.0, 0.0, 1.0 }, '[Byte, Bit] ' )

        imgui.SameLine()
        imgui.SetCursorPosY(73)

        --  We update the offsets every cycle they change

        imgui.PushItemWidth(50)
        
        if imgui.InputText('##ByteIn', DIAG.PacketByteIn, 5) then 
            DIAG.ExtractPacketStartByte() 
        end

        imgui.SameLine()
        imgui.PushItemWidth(30)

        if imgui.InputText('##BitIn', DIAG.PacketBitIn, 3) then
            DIAG.ExtractPacketStartBit() 
        end

        imgui.PopItemWidth(2)

        --  Extract Data (text)

        imgui.SetCursorPosX(343)
        imgui.SetCursorPosY(76)

        imgui.TextColored( { 0.9, 0.9, 0.9, 1.0 }, 'Register:' )
        imgui.SameLine()
        imgui.TextColored( { 0.0, 1.0, 0.0, 1.0 }, '[Byte, Bit, Bits]' )
        
        imgui.SameLine()
        imgui.SetCursorPosY(73)

        imgui.PushItemWidth(50)

        if imgui.InputText('##ByteEx', DIAG.RegisterByteIn, 5) then
            DIAG.ExtractRegisterStartByte()
        end

        imgui.SameLine()
        imgui.PushItemWidth(30)
        
        if imgui.InputText('##BitEx',  DIAG.RegisterBitIn, 3) then
            DIAG.ExtractRegisterStartBit()
        end

        imgui.SameLine()

        if imgui.InputText('##BitsEx', DIAG.RegisterBitsIn, 3) then
            DIAG.ExtractRegisterStartBits()
        end

        imgui.PopItemWidth(2)

        --  Button line

        imgui.SetCursorPosY(110)
        imgui.SetCursorPosX(12)

        if imgui.Button('Load Register From Packet##X64', {250, 0})  then
            imgui.SetWindowFocus('Load Register From Packet##X64')
            if nil ~= Packet then
                DIAG.LoadProcessor(UI, Packet)
            end
        end

        imgui.SetCursorPosY(110)
        imgui.SetCursorPosX(343)

        if imgui.Button('Extract Data From Register##X64', {250, 0})  then
            imgui.SetWindowFocus('Load Register From Packet##X64')
            DIAG.ReadProcessor(UI, Packet)
        end
          
        DIAG.Divide(145)

        imgui.SetCursorPosY(155)
        
        imgui.TextColored( { 1.0, 1.0, 0.0, 1.0 }, 'Result:' )
        imgui.SameLine()
        imgui.SetCursorPosX(80)
        imgui.TextColored( { 1.0, 1.0, 1.0, 1.0 }, ('0x%.4X'):fmt(DIAG.Result) )
        imgui.SetCursorPosX(80)
        imgui.TextColored( { 1.0, 1.0, 1.0, 1.0 }, ('%d'):fmt(DIAG.Result) )
        
        DIAG.ShowCombo()

        imgui.SetCursorPosY(158)
        imgui.SetCursorPosX(460)

        if 1 == DIAG.ComboSelected then
        
            local party = AshitaCore:GetMemoryManager():GetParty()
            local zone	= party:GetMemberZone(0)
            local base	= 0x1001000 + ((zone - 1) * 4096)
            local npc	= DIAG.Result - base
            local name	= AshitaCore:GetMemoryManager():GetEntity():GetName(npc)
    
            if nil ~= name then
    
                imgui.TextColored( { 1.0, 1.0, 1.0, 1.0 }, ('%s'):fmt(name) )
        
            end
            
        end

        if 2 == DIAG.ComboSelected then

            local resource = AshitaCore:GetResourceManager():GetSpellById(DIAG.Result)
            
            if (nil ~= resource) then
                imgui.TextColored( { 1.0, 1.0, 1.0, 1.0 }, ('%s'):fmt(resource.Name[1]) )
            end
        end

    end
    
end

-- Return the object

return DIAG
