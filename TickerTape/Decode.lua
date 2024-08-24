--	---------------------------------------------------------------------------
--	This file contains the data decoding functions
--	---------------------------------------------------------------------------

require('common')

local chat	= require('chat')
local imgui	= require('imgui')

local Decode = {

}

--	---------------------------------------------------------------------------
--	This decodes a reverse byte DWORD (4 bytes)
--
--	Special cases include ..
--		'entity'	.. A NPC or MOB
--
--	This data type can be flag controlled
--	---------------------------------------------------------------------------

function Decode.RDWORD(PacketDisplay, RuleTable, Packet)

	--	Reverse DWORD (4 bytes in reverse)
	
	local party = AshitaCore:GetMemoryManager():GetParty()
	local player = AshitaCore:GetMemoryManager():GetPlayer()
	local index = party:GetMemberTargetIndex(0)

	local partyZoneID = party:GetMemberZone(0)
	local ZoneBase    = 0x1001000 + ((partyZoneID - 1) * 4096)

	local value = 0

	for i = 0, 3 do
		value = (value * 256) + PacketDisplay.ExtractByte(Packet, RuleTable.Offset + 3 - i)
		end

	--	This type can use the flag system
	
	if (('use' == RuleTable.Logic) and (0 == PacketDisplay.Flags[RuleTable.Flag])) then
		imgui.TextColored({ 0.4, 0.4, 0.4, 1.0 }, ('%d'):fmt(value) )
		imgui.SameLine()
		imgui.TextColored({ 0.4, 0.4, 0.4, 1.0 }, ('  ..  0x%.8X'):fmt(value) )
	else
		imgui.TextColored({ 0.9, 0.9, 0.9, 1.0 }, ('%d'):fmt(value) )
		imgui.SameLine()
		imgui.TextColored({ 0.7, 0.7, 0.7, 1.0 }, ('  ..  0x%.8X'):fmt(value) )
	end
	
	--	An entity type can have a name extracted
	
	if 'entity' == RuleTable.Decode then
	
		local npc  = value - ZoneBase
		local name = AshitaCore:GetMemoryManager():GetEntity():GetName(npc)

		if (('use' == RuleTable.Logic) and (0 == PacketDisplay.Flags[RuleTable.Flag])) then
			imgui.TextColored({ 0.4, 0.4, 0.4, 1.0 }, ('%s'):fmt(name) )
		else
			imgui.TextColored({ 0.9, 0.9, 0.0, 1.0 }, ('%s'):fmt(name) )
		end

	end
	
end

return Decode
