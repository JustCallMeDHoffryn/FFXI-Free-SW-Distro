--	---------------------------------------------------------------------------
--	This file contains the data processing for TickerTap
--	---------------------------------------------------------------------------

--	---------------------------------------------------------------------------

require('common')

local chat = require('chat')

local DataProc = {

}

--	---------------------------------------------------------------------------
--	Called when we want to encode a packet into a text string
--	---------------------------------------------------------------------------

function DataProc.EncodePacket(Packet)

	local	Str			= ''
	local	SingleByte	= ''
	
	for index = 1, Packet.size do
		
		SingleByte = string.format('%.2X', Packet.data:byte(index, index))
		Str = Str .. SingleByte
		
	end

	return Str
	
end

-- Return the object

return DataProc
