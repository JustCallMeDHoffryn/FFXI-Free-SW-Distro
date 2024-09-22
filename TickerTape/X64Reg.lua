--	---------------------------------------------------------------------------
--	This file contains the 64 bit register manipulation
--	---------------------------------------------------------------------------

require('common')
require('os')

local chat			= require('chat')
local imgui			= require('imgui')
local ETC			= require('ETC')
local XFunc			= require('XFunc')
local CentralData	= require('CentralData')	--	Central data store

local X64 = {

    BitCount = 0,
    Register = {},

}

--	---------------------------------------------------------------------------
--	Build the empty register
--	---------------------------------------------------------------------------

function X64.BuildX64()

    for i=1, 64 do
    
        table.insert( X64.Register,	{   BitIndex	= i,
                                        BitValue    = 0
                                    }   )
    end

    table.sort(X64.Register, (function (a, b)
        return (a.BitIndex < b.BitIndex)
        end))

end

--	---------------------------------------------------------------------------
--	Get the current value from the register (we may use a flag bypass)
--	---------------------------------------------------------------------------

function X64.GetValue(RuleTable)

    local index = 1
    local value = 0

    --  We may need to use a flag value

    if 'useflag' == RuleTable.Command then

        if 12 == RuleTable.FlagOff then
            value = CentralData.LoopIndex
        elseif RuleTable.FlagOff > 0 and RuleTable.FlagOff < 10 then
            value = CentralData.Flags[RuleTable.FlagOff]
        else
            value = 0
        end

    else

        repeat

            if 1 == X64.Register[index].BitValue then
                value = value + math.pow(2, (index - 1))
            end

            index = index + 1

        until index > X64.BitCount

    end

    return value

end

--	---------------------------------------------------------------------------
--	Load the register
--	---------------------------------------------------------------------------

function X64.ExtractFromPacket(Packet, RuleTable)

    --  We always save the packt size for times when we don't have access to the packet

    CentralData.PacketSize = Packet.size
    CentralData.PacketData = Packet.size - 4
   
    for i=1, 64 do  
        X64.Register[i].BitValue = 0
    end

    if RuleTable.Command ~= 'useflag' then     --  Extracted at point of use

        local index     = 1
        local byte      = RuleTable.Offset
        local bit       = RuleTable.Bit
        local bitsleft  = 8
        local required  = RuleTable.Len

        --  When any param is -1 we use the loop counter

        if -1 == byte then byte = CentralData.LoopIndex end
        if -1 == bit  then bit  = CentralData.LoopIndex end

        --  Adjust for loop

        bit = bit + CentralData.PlusBit

        --  Correct a big bit offset (some people are stupid)

        while bit > 7 do
            bit  = bit - 8
            byte = byte + 1
        end

        if required > 64 then required = 64 end

        --  Get the byte with the first bit

        local this = XFunc.ExtractByte(Packet, byte)
        
        --  Shuffle off any remaining bottom bits we dont want

        while bit > 0 do
            bit      = bit - 1
            bitsleft = bitsleft  - 1
            this     = math.floor(this / 2)
        end

        --  Now extract the required bits worth of data

        repeat

            if byte >= Packet.size then
                X64.Register[index].BitValue = 0
            else
                if 1 == this % 2 then 
                    X64.Register[index].BitValue = 1
                else
                    X64.Register[index].BitValue = 0
                end
            end

            this = math.floor(this / 2)
            bitsleft = bitsleft - 1

            if 0 == bitsleft then
                byte     = byte + 1
                this     = XFunc.ExtractByte(Packet, byte)
                bitsleft = 8
            end

            index = index + 1

        until index > required

        X64.BitCount = required

    end

end

-- Return the object

return X64
