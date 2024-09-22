--	---------------------------------------------------------------------------
--	This file contains the data decoding functions
--	---------------------------------------------------------------------------

require('common')

local chat	= require('chat')
local imgui	= require('imgui')

local ETC			= require('ETC')			--	Our global data (brushes etc)
local XFunc 		= require('XFunc')			--	Our support functions
local X64 			= require('X64Reg')			--	Our 64 bit register
local CentralData	= require('CentralData')	--	Central data store

local Decode = {

	RuleStack		=	{},

	Jobs	  		= T{	'WAR', 'MNK', 'WHM', 'BLM', 'RDM', 'THF', 'PLD', 'DRK', 'BST', 'BRD', 'RNG', 
							'SAM', 'NIN', 'DRG', 'SMN', 'BLU', 'COR', 'PUP', 'DNC', 'SCH', 'GEO', 'RUN', },

	TAB_Actions		= require('data/Tab_Actions'),		--	Names of actions
	TAB_Storage		= require('data/Tab_Storage'),		--	Names of storage locations
	TAB_Attach		= require('data/Tab_Attach'),		--	Names of puppet attachments (by sub ID)
	TAB_Merits		= require('data/Tab_Merits'),		--	Names of merits
	TAB_JPoints		= require('data/Tab_JobPoints'),	--	Names of Job Point effects
	TAB_Music		= require('data/Tab_Music'),		--	Names of songs
	TAB_Weather		= require('data/Tab_Weather'),		--	Names of weather formats
	TAB_MogHouse	= require('data/Tab_MogHouse'),		--	Names of mog house locations
	TAB_ActCats		= require('data/Tab_ActCats'),		--	Names of action categories
	TAB_WSkills		= require('data/Tab_WeaponSkills'),	--	Names of weapon skills
	TAB_Abilities	= require('data/Tab_Abilities'),	--	Names of Abilities
	TAB_Mounts		= require('data/Tab_Mounts'),		--	Names of Mounts
	TAB_Recasts		= require('data/Tab_Recasts'),		--	Names of Ability Recasts
	TAB_LogStates	= require('data/Tab_LogState'),		--	Names of Zone log states
	TAB_Geo			= require('data/Tab_Geo'),			--	Names of GEO colure effects
	TAB_Puppet		= require('data/Tab_Puppet'),		--	Names of Puppet parts
	TAB_RoE			= require('data/Tab_RoE'),			--	Names of RoE missions

	Tables	=	{

		[10] = T{
		
			[0x00]	=	"Invalid Command",
			[0x01]	=	"Work",
			[0x02]	=	"Set",
			[0x03]	=	"Send",
			[0x04]	=	"Cancel",
			[0x05]	=	"Check",
			[0x06]	=	"Receive",
			[0x07]	=	"Confirm",
			[0x08]	=	"Accept",
			[0x09]	=	"Reject",
			[0x0A]	=	"Get",
			[0x0B]	=	"Clear",
			[0x0C]	=	"Query",
			[0x0D]	=	"Request Enter Delivery",
			[0x0E]	=	"Request Enter Post",
			[0x0F]	=	"Request Exit Mode",
		
		},
	},
}

--	---------------------------------------------------------------------------
--	Job points
--	---------------------------------------------------------------------------

function Decode.JobPoints(RuleTable, Packet)

	imgui.SetCursorPosX(imgui.GetCursorPosX()+10)

	local B1 = XFunc.ExtractByte(Packet, RuleTable.Offset)
	local B2 = XFunc.ExtractByte(Packet, RuleTable.Offset + 1)
	local B3 = XFunc.ExtractByte(Packet, RuleTable.Offset + 2)
	local B4 = XFunc.ExtractByte(Packet, RuleTable.Offset + 3)

	if B1 == 0 and B2 == 0 then		--	No data
		imgui.TextColored({ 0.7, 0.7, 0.7, 1.0 }, ('(No data in this slot)') )
	else

		local JobPointID	= (256 * B2) + B1
		local Level			= math.floor(B4 / 4)
		local Job			= math.floor(JobPointID / 32)
		local Id			= math.floor(JobPointID % 32)
		local Name			= 'NONE'

		local Ability = Decode.TAB_JPoints[JobPointID]
	
		if (nil ~= Ability) then

			imgui.TextColored( ETC.Green, ('%s'):fmt(Ability) )
			imgui.SetCursorPosX(imgui.GetCursorPosX()+10)
			
		end
		
		if Job > 0 and Job < 23 then
			Name = Decode.Jobs[Job]
		end

		local XPos = imgui.GetCursorPosX()
		
		imgui.TextColored( { 0.9, 0.9, 0.0, 1.0 }, ('%s:'):fmt(Name) )
		imgui.SameLine()

		imgui.TextColored( { 0.9, 0.9, 0.9, 1.0 }, ('0x%.3X'):fmt(JobPointID) )
		imgui.SameLine()

		imgui.SetCursorPosX(XPos+120)

		imgui.TextColored( { 0.9, 0.9, 0.0, 1.0 }, ('Lv:') )
		imgui.SameLine()

		imgui.TextColored( { 0.9, 0.9, 0.9, 1.0 }, ('%d'):fmt(Level) )
		imgui.SameLine()

		imgui.SetCursorPosX(XPos+200)

		imgui.TextColored( { 0.9, 0.9, 0.0, 1.0 }, ('Next:') )
		imgui.SameLine()

		imgui.TextColored( { 0.9, 0.9, 0.9, 1.0 }, ('%d'):fmt(B3) )
	
	end
end

--	---------------------------------------------------------------------------
--	This decodes the craft skill and rank
--	---------------------------------------------------------------------------

function Decode.Craft(RuleTable)

	local value = X64.GetValue(RuleTable)
	local XPos  = imgui.GetCursorPosX()

	local	SavedIn	 = math.floor(value)
	local	Level	 = math.floor(value / 32)
	local	Rank 	 = math.floor(value) % 32

	imgui.SetCursorPosX(imgui.GetCursorPosX()+10)

	imgui.TextColored({ 0.0, 1.0, 0.0, 1.0 }, ('Rank:') )
	imgui.SameLine()
	imgui.TextColored({ 0.9, 0.9, 0.9, 1.0 }, ('%d'):fmt(Rank) )
	imgui.SameLine()

	imgui.TextColored({ 0.0, 1.0, 0.0, 1.0 }, ('Level:') )
	imgui.SameLine()
	imgui.TextColored({ 0.9, 0.9, 0.9, 1.0 }, ('%d'):fmt(Level) )
	imgui.SameLine()

	imgui.SameLine()

end

--	---------------------------------------------------------------------------
--	This decodes a delivery box command
--	---------------------------------------------------------------------------

function Decode.DBox(RuleTable)

	local value = X64.GetValue(RuleTable)
	local XPos  = imgui.GetCursorPosX()

	local OurTable	= Decode.Tables[10]		--	Table of commands
	local Name		= 'Unknown'
	
	if nil ~= OurTable then
		for i, ThisTable in pairs(OurTable) do
			if i == math.floor(value) then
				Name = ThisTable
			end
		end

		imgui.SetCursorPosX(imgui.GetCursorPosX()+10)
		imgui.TextColored({ 0.9, 0.9, 0.9, 1.0 }, ('%s'):fmt(Name) )

	end
end

--	---------------------------------------------------------------------------
--	This decodes raw data (any data size)
--	---------------------------------------------------------------------------

function Decode.RAW(RuleTable)

	local value = X64.GetValue(RuleTable)
	local XPos  = imgui.GetCursorPosX()

	imgui.SetCursorPosX(imgui.GetCursorPosX()+10)

	--	Show the number of bytes in the data (powers of 2)

	XFunc.Hex(value, ETC.OffW, X64.BitCount)	

	--	Show the decimal value at the end

	imgui.SameLine()
	imgui.SetCursorPosX(XPos+150)

	XFunc.Decimal(value, ETC.OffW)
	
	--	We use this (if requested) to set a sys flag

	if 'set' == RuleTable.Logic then
		CentralData.Flags[RuleTable.Flag] = value
	end

end

--	---------------------------------------------------------------------------
--	This decodes Packet Size (adjusted)
--	---------------------------------------------------------------------------

function Decode.PSize(RuleTable)

	local value = X64.GetValue(RuleTable)
	local XPos  = imgui.GetCursorPosX()
	
	imgui.SetCursorPosX(imgui.GetCursorPosX()+10)

	XFunc.Decimal(value, ETC.OffW)
	imgui.SameLine()

	value = math.floor(value * 4)

	imgui.SetCursorPosX(XPos+100)
	imgui.TextColored(ETC.Amber, '>>' )
	imgui.SameLine()

	imgui.SetCursorPosX(XPos+150)
	XFunc.Decimal(value, ETC.Amber)
	imgui.SameLine()

	XFunc.Hex(value, ETC.Amber, 16)	

end

--	---------------------------------------------------------------------------
--	This decodes a direction
--	---------------------------------------------------------------------------

function Decode.Direction(RuleTable)

	local value = X64.GetValue(RuleTable)
	local XPos  = imgui.GetCursorPosX()

	local Angle = value * 360 / 256
	local Comp  = '?'
	
	if value > 240 or value < 16 then Comp = 'E' 
	elseif value >= 16  and value < 48  then Comp = 'SE'
	elseif value >= 48  and value < 80  then Comp = 'S'
	elseif value >= 80  and value < 112 then Comp = 'SW'
	elseif value >= 112 and value < 144 then Comp = 'W'
	elseif value >= 144 and value < 176 then Comp = 'NW'
	elseif value >= 176 and value < 208 then Comp = 'N'
	else Comp = 'NE' end
	
	imgui.SetCursorPosX(imgui.GetCursorPosX()+10)

	imgui.TextColored( ETC.Dirty, '[' )
	imgui.SameLine()
	imgui.TextColored( ETC.OffW, ('%s'):fmt(Comp) )
	imgui.SameLine()
	imgui.TextColored( ETC.Dirty, ']' )
	imgui.SameLine()

	imgui.TextColored(ETC.Amber, ('%d°'):fmt(Angle) )
	imgui.SameLine()

	imgui.SetCursorPosX(XPos+150)
	
	XFunc.Hex(value, ETC.OffW, 8)
	imgui.SameLine()
	XFunc.Decimal(value, ETC.OffW)

end

--	---------------------------------------------------------------------------
--	Position decode (X,Y,Z) as 12 bytes (3 x 4) - Can use flags
--	---------------------------------------------------------------------------

function Decode.XYZ(RuleTable, Packet)

	imgui.SetCursorPosX(imgui.GetCursorPosX()+10)

	local B1 = XFunc.ExtractByte(Packet, RuleTable.Offset)
	local B2 = XFunc.ExtractByte(Packet, RuleTable.Offset + 1)
	local B3 = XFunc.ExtractByte(Packet, RuleTable.Offset + 2)
	local B4 = XFunc.ExtractByte(Packet, RuleTable.Offset + 3)

	imgui.TextColored( ETC.Green,  'X:' )
	imgui.SameLine()
	imgui.SetCursorPosX(imgui.GetCursorPosX()-5)
	imgui.TextColored( ETC.Yellow, ('%.2f  '):fmt( XFunc.BinToFloat32( B1, B2, B3, B4 ) ) )
	imgui.SameLine()

	local B1 = XFunc.ExtractByte(Packet, RuleTable.Offset + 4)
	local B2 = XFunc.ExtractByte(Packet, RuleTable.Offset + 5)
	local B3 = XFunc.ExtractByte(Packet, RuleTable.Offset + 6)
	local B4 = XFunc.ExtractByte(Packet, RuleTable.Offset + 7)

	imgui.TextColored( ETC.Green,  'Y:' )
	imgui.SameLine()
	imgui.SetCursorPosX(imgui.GetCursorPosX()-5)
	imgui.TextColored( ETC.Yellow, ('%.2f  '):fmt( XFunc.BinToFloat32( B1, B2, B3, B4 ) ) )
	imgui.SameLine()

	local B1 = XFunc.ExtractByte(Packet, RuleTable.Offset + 8)
	local B2 = XFunc.ExtractByte(Packet, RuleTable.Offset + 9)
	local B3 = XFunc.ExtractByte(Packet, RuleTable.Offset + 10)
	local B4 = XFunc.ExtractByte(Packet, RuleTable.Offset + 11)

	imgui.TextColored( ETC.Green,  'Z:' )
	imgui.SameLine()
	imgui.SetCursorPosX(imgui.GetCursorPosX()-5)
	imgui.TextColored( ETC.Yellow, ('%.2f'):fmt( XFunc.BinToFloat32( B1, B2, B3, B4 ) ) )
		
end

--	---------------------------------------------------------------------------
--	Time
--	---------------------------------------------------------------------------

function Decode.Time(RuleTable)

	local value = X64.GetValue(RuleTable)
	local XPos  = imgui.GetCursorPosX()

	local sec   = value % 60
	value = value / 60

	local min   = value % 60
	value = value / 60

	local hour  = value % 24
	local days  = value / 24
	
	imgui.SetCursorPosX(imgui.GetCursorPosX()+10)
	imgui.TextColored( ETC.Yellow, ('%d'):fmt(days) )
	imgui.SameLine()
	imgui.TextColored( ETC.Green, 'days ' )
	
	imgui.SameLine()
	imgui.TextColored( ETC.Yellow, ('%d'):fmt(hour) )
	imgui.SameLine()
	imgui.TextColored( ETC.Green, 'h  ' )

	imgui.SameLine()
	imgui.TextColored( ETC.Yellow, ('%d'):fmt(min) )
	imgui.SameLine()
	imgui.TextColored( ETC.Green, 'm  ' )

	imgui.SameLine()
	imgui.TextColored( ETC.Yellow, ('%d'):fmt(sec) )
	imgui.SameLine()
	imgui.TextColored( ETC.Green, 's' )

end

--	---------------------------------------------------------------------------
--	Timestamp (mostly pointless)
--	---------------------------------------------------------------------------

function Decode.MSTime(RuleTable)

	local value = X64.GetValue(RuleTable)
	local XPos  = imgui.GetCursorPosX()

	local ms    = value % 1000
	value = value / 1000

	local sec   = value % 60
	value = value / 60

	local min   = value % 60
	value = value / 60

	local hour  = value % 24
	local days  = value / 24
	
	imgui.SetCursorPosX(imgui.GetCursorPosX()+10)
	imgui.TextColored( ETC.Yellow, ('%d'):fmt(days) )
	imgui.SameLine()
	imgui.TextColored( ETC.Green, 'days' )
	imgui.SameLine()
	imgui.TextColored( ETC.Yellow, ('%.2d:%.2d:%.2d  %d'):fmt(hour, min, sec, ms) )
	imgui.SameLine()
	imgui.TextColored( ETC.Green, 'ms' )

end

--	-----------------------------------------------------------------------
--	Entity ID - This is just the index, so we can find what this is
--	without having to know the zone etc.. this may be a player so check
--	-----------------------------------------------------------------------

function Decode.EID(RuleTable)

	local value = X64.GetValue(RuleTable)
	local XPos  = imgui.GetCursorPosX()
	local name	= AshitaCore:GetMemoryManager():GetEntity():GetName(value)

	--	If NIL we don't know what or who it is

	imgui.SetCursorPosX(imgui.GetCursorPosX()+10)

	if nil ~= name then
		imgui.TextColored( ETC.Yellow, ('%s'):fmt(name) )
	elseif 0 == value then
		imgui.TextColored( ETC.OffW, 'No Selection' )
	else
		imgui.TextColored( ETC.Red, 'Unknown' )
		imgui.SameLine()
		imgui.SetCursorPosX(XPos+150)
	
		XFunc.Hex(value, ETC.OffW, 8)
		imgui.SameLine()
		XFunc.Decimal(value, ETC.OffW)
	end

end

--	-----------------------------------------------------------------------
--	Entity ID - This is the full ID
--	-----------------------------------------------------------------------

function Decode.Entity(RuleTable)

	local value = X64.GetValue(RuleTable)
	local XPos  = imgui.GetCursorPosX()
	local party = AshitaCore:GetMemoryManager():GetParty()
	local zone	= party:GetMemberZone(0)
	local base	= 0x1001000 + ((zone - 1) * 4096)
	local npc	= value - base
	local name	= AshitaCore:GetMemoryManager():GetEntity():GetName(npc)

	imgui.SetCursorPosX(imgui.GetCursorPosX()+10)

	if nil ~= name then
		imgui.TextColored( ETC.Yellow , ('%s'):fmt(name) )
	else
		name = AshitaCore:GetMemoryManager():GetEntity():GetName(value)
		if nil ~= name then
			imgui.TextColored( ETC.Yellow , ('%s'):fmt(name) )
		else
			local eid = value - base
			name = AshitaCore:GetMemoryManager():GetEntity():GetName(eid)
			if nil ~= name then
				imgui.TextColored( ETC.Yellow , ('%s'):fmt(name) )
			else
				imgui.TextColored( ETC.Red , 'Unknown' )
				imgui.SameLine()
				XFunc.Hex(value, ETC.OffW, 32)
			end
		end
	end

end

--	---------------------------------------------------------------------------
--	This decodes a text string
--	---------------------------------------------------------------------------

function Decode.String(RuleTable, Packet)

	local 	strText		= ""
	local	index		= 0
	local	ThisByte	= ""
	
	imgui.SetCursorPosX(imgui.GetCursorPosX()+10)

	repeat
		
		ThisByte = XFunc.ExtractByte(Packet, RuleTable.Offset + index)
		ThisChar = string.format('%c', ThisByte)

		if ThisByte >= 32 then
			strText = strText .. ThisChar
		end
	
		index = index + 1

		local stop = false

		if (ThisByte == 0) or ((RuleTable.Offset + index) >= Packet.size) then
			stop = true 
		end

		if (RuleTable.Bytes > 1) and (index >= RuleTable.Bytes) then
			stop = true 
		end

	until stop == true

	local Str = string.format('%c%s%c', 39, strText, 39)
	imgui.TextColored( ETC.Green, Str )

end

--	---------------------------------------------------------------------------
--	This decodes a song name (uses the long string logic)
--	---------------------------------------------------------------------------

function Decode.Music(RuleTable)

	local value 	= X64.GetValue(RuleTable)
	local XPos  	= imgui.GetCursorPosX()
	local OurTable	= Decode.TAB_Music
	local Name		= 'Unknown'
	
	if nil ~= OurTable then
		for i, ThisTable in pairs(OurTable) do
			if i == math.floor(value) then
				Name = ThisTable
			end
		end
	end

	if imgui.CalcTextSize(Name) < 300 then

		imgui.SetCursorPosX(imgui.GetCursorPosX()+10)
		imgui.TextColored( ETC.Green, ('%s'):fmt(Name) )

	else

		XFunc.PaintLongString(Name, ETC.Green, 300)

	end

end

--	---------------------------------------------------------------------------
--	This decodes an ability
--	---------------------------------------------------------------------------

function Decode.Ability(RuleTable)

	local value 	= X64.GetValue(RuleTable)
	local XPos  	= imgui.GetCursorPosX()
	local OurTable	= Decode.TAB_Abilities
	local Name		= 'Unknown'
	
	if nil ~= OurTable then
		Name = OurTable[value]
	end

	imgui.SetCursorPosX(imgui.GetCursorPosX()+10)
	XFunc.Hex(value, ETC.OffW, 8)
	imgui.SameLine()
	XFunc.Decimal(value, ETC.OffW)

	imgui.SameLine()
	imgui.SetCursorPosX(XPos+150)

	if nil ~= Name then
		imgui.TextColored( ETC.Green, ('%s'):fmt(Name) )
	else
		imgui.TextColored( ETC.Red, 'Unknown Abilty' )
	end

end

--	---------------------------------------------------------------------------
--	Weather
--	---------------------------------------------------------------------------

function Decode.Weather(RuleTable)

	local value 	= X64.GetValue(RuleTable)
	local XPos  	= imgui.GetCursorPosX()
	local Weather	= Decode.TAB_Weather[value]
	
	imgui.SetCursorPosX(imgui.GetCursorPosX()+10)

	if nil ~= Weather then
		imgui.TextColored( ETC.Green, ('%s'):fmt(Weather) )
	end

	imgui.SameLine()
	imgui.SetCursorPosX(XPos+150)
	
	XFunc.Hex(value, ETC.OffW, 8)
	imgui.SameLine()
	XFunc.Decimal(value, ETC.OffW)

end

--	---------------------------------------------------------------------------
--	GEO Element
--	---------------------------------------------------------------------------

function Decode.GEO(RuleTable)

	local value 	= X64.GetValue(RuleTable)
	local XPos  	= imgui.GetCursorPosX()
	local Element	= Decode.TAB_Geo[value]
	
	imgui.SetCursorPosX(imgui.GetCursorPosX()+10)

	if nil ~= Element then
		imgui.TextColored( ETC.Green, ('%s'):fmt(Element) )
	end

	imgui.SameLine()
	imgui.SetCursorPosX(XPos+150)
	
	XFunc.Hex(value, ETC.OffW, 8)
	imgui.SameLine()
	XFunc.Decimal(value, ETC.OffW)

end

--	---------------------------------------------------------------------------
--	Zone Name
--	---------------------------------------------------------------------------

function Decode.Zone(RuleTable)

	local value 	= X64.GetValue(RuleTable)
    local party		= AshitaCore:GetMemoryManager():GetParty()
    local player	= AshitaCore:GetMemoryManager():GetPlayer()
    local ZoneID	= party:GetMemberZone(0)
	local ZoneName	= AshitaCore:GetResourceManager():GetString('zones.names', ZoneID)

	imgui.SetCursorPosX(imgui.GetCursorPosX()+10)

	if nil ~= ZoneName then
		imgui.TextColored( ETC.Green, ('%s'):fmt(ZoneName) )
	else
		imgui.TextColored( ETC.Red, 'Invalid Zone' )
	end

end

--	---------------------------------------------------------------------------
--	Mog House
--	---------------------------------------------------------------------------

function Decode.MHouse(RuleTable)

	local value 	= X64.GetValue(RuleTable)
	local XPos  	= imgui.GetCursorPosX()
	local Location	= Decode.TAB_MogHouse[value]
	
	imgui.SetCursorPosX(imgui.GetCursorPosX()+10)

	if nil ~= Location then
		imgui.TextColored( ETC.Green, ('%s'):fmt(Location) )
	end

end

--	---------------------------------------------------------------------------
--	Bit extracted from a byte
--	---------------------------------------------------------------------------

function Decode.BitFlag(RuleTable, Packet)

	local value 	= X64.GetValue(RuleTable)
	local XPos  	= imgui.GetCursorPosX()
	local Byte		= XFunc.ExtractByte(Packet, RuleTable.Offset)
	local Start		= Byte
	local BitVal	= 1

	imgui.SetCursorPosX(imgui.GetCursorPosX()+10)
	imgui.TextColored( ETC.Dirty, ('[') )

	for i=1, 8 do
			
		imgui.SameLine()
		imgui.SetCursorPosX(XPos+10+(i*10))
		
		if 	i == (RuleTable.Bit + 1) then
			if 1 == value then
				imgui.TextColored( ETC.Green, '1' )
			else
				imgui.TextColored( ETC.Red, '0' )
			end
		else
			if 1 == (Byte % 2) then
				imgui.TextColored( ETC.Soft, '1' )
			else
				imgui.TextColored( ETC.Soft, '0' )
			end
		end

		Byte = math.floor (Byte / 2)

	end
	
	imgui.SameLine()
	imgui.SetCursorPosX(XPos+100)
	imgui.TextColored( ETC.Dirty, (']') )
	imgui.SameLine()

	imgui.SameLine()
	imgui.SetCursorPosX(XPos+150)
	XFunc.Decimal(value, ETC.OffW)
	imgui.SameLine()
	XFunc.Hex(Start, ETC.OffW, 8)

	--	We use this (if requested) to set a sys flag

	if 'set' == RuleTable.Logic then
		CentralData.Flags[RuleTable.Flag] = value
	end

end

--	---------------------------------------------------------------------------
--	This decodes an IP address
--	---------------------------------------------------------------------------

function Decode.IP(RuleTable, Packet)

	local	IP1 = XFunc.ExtractByte(Packet, RuleTable.Offset)
	local	IP2 = XFunc.ExtractByte(Packet, RuleTable.Offset + 1)
	local	IP3 = XFunc.ExtractByte(Packet, RuleTable.Offset + 2)
	local	IP4 = XFunc.ExtractByte(Packet, RuleTable.Offset + 3)

	imgui.SetCursorPosX(imgui.GetCursorPosX()+10)
	imgui.TextColored({ 0.9, 0.9, 0.9, 1.0 }, ('Address: %d.%d.%d.%d'):fmt(IP1, IP2, IP3, IP4) )

end

--	---------------------------------------------------------------------------
--	This decodes a storge location
--	---------------------------------------------------------------------------

function Decode.Store(RuleTable)

	local	value = X64.GetValue(RuleTable)
	local	Store = Decode.TAB_Storage[value]
	local	XPos  = imgui.GetCursorPosX()

	imgui.SetCursorPosX(imgui.GetCursorPosX()+10)

	if nil ~= Store then
			
		imgui.TextColored(ETC.Green, ('%s'):fmt(Store) )
		imgui.SameLine()
		imgui.SetCursorPosX(XPos+150)
		XFunc.Decimal(value, ETC.OffW)
	
	else

		imgui.TextColored(ETC.Red, ('UNKNOWN LOCATION') )
		imgui.SameLine()
		imgui.SetCursorPosX(XPos+150)
		XFunc.Decimal(value, ETC.OffW)

	end

end

--	---------------------------------------------------------------------------
--	This decodes an item ID
--	---------------------------------------------------------------------------

function Decode.Item(RuleTable)

	local	value = X64.GetValue(RuleTable)
	local	XPos  = imgui.GetCursorPosX()

	imgui.SetCursorPosX(imgui.GetCursorPosX()+10)

	local resource = AshitaCore:GetResourceManager():GetItemById(value)

	if nil ~= resource then
		imgui.TextColored(ETC.Green, ('%s'):fmt(resource.Name[1]) )
	else
 		imgui.TextColored(ETC.Red, 'UNKNOWN ITEM ID' )
	end

end

--	---------------------------------------------------------------------------
--	This decodes EXData
--	---------------------------------------------------------------------------

function Decode.EXData(RuleTable, Packet)

	local	OurBytes	= T{}
	local	XPos  		= imgui.GetCursorPosX()
	
	for i=1, 24 do
		
		local value = XFunc.ExtractByte(Packet, RuleTable.Offset + i - 1)

		table.insert( OurBytes,	{	Index	= i,
									Value 	= value, }
					)
			
	end

	table.sort(OurBytes, (function (a, b)
		return (a.Index < b.Index)
		end))

	for i=1, 3 do

		imgui.SetCursorPosX(XPos+10)

		for j=1, 8 do
			
			if (j ~= 1) then imgui.SameLine() end

			local idx = ((i-1)*8)+j
			local val = OurBytes[idx].Value

			imgui.TextColored( { 0.9, 0.9, 0.9, 1.0 }, ('%.2X'):fmt(val) )

			imgui.SetCursorPosX(XPos+(j*10))

		end

	end

end

--	---------------------------------------------------------------------------
--	This decodes an item ID
--	---------------------------------------------------------------------------

function Decode.Info(RuleTable)

	local	value = X64.GetValue(RuleTable)
	local	XPos  = imgui.GetCursorPosX()

	imgui.SetCursorPosX(imgui.GetCursorPosX()+10)
	imgui.TextColored({ 1.0, 0.5, 1.0, 1.0 }, ('%s'):fmt(RuleTable.Info) )

end

--	---------------------------------------------------------------------------
--	This decodes the Vana'Diel date
--	---------------------------------------------------------------------------

function Decode.VDate(RuleTable)

	local	value = X64.GetValue(RuleTable)
	local	XPos  = imgui.GetCursorPosX()

	imgui.SetCursorPosX(imgui.GetCursorPosX()+10)

	local	min	 	= 0
	local	hour	= 0
	local	day  	= 0
	local	month	= 0
	local	year	= 0

	min   = math.floor(value) % 60
	value = math.floor(value / 60)

	hour  = math.floor(value) % 24
	value = math.floor(value / 24)

	day   = math.floor(value) % 30
	value = math.floor(value / 30)

	month = math.floor(value) % 12
	year  = math.floor(value / 12)

	imgui.TextColored({ 0.9, 0.9, 0.9, 1.0 }, ('Y:%d  M:%.2d  D:%.2d  H:%.2d  M:%.2d'):fmt(year, month, day, hour, min) )

end

--	---------------------------------------------------------------------------
--	Merit points
--	---------------------------------------------------------------------------

function Decode.MeritPoints(RuleTable)

	local	value = X64.GetValue(RuleTable)
	local	XPos  = imgui.GetCursorPosX()

	imgui.SetCursorPosX(imgui.GetCursorPosX()+10)

	local Ability = Decode.TAB_Merits[value]
	imgui.TextColored( ETC.OffW, ('%.3X'):fmt(value) )
	imgui.SameLine()

	if (nil ~= Ability) then
		imgui.TextColored( ETC.Green, ('%s'):fmt(Ability) )
	else
		imgui.TextColored( ETC.Red, ('UNKNOWN') )
	end

end

--	---------------------------------------------------------------------------
--	This decodes a single byte as a JOB
--	---------------------------------------------------------------------------

function Decode.JobByte(RuleTable)

	local	value = X64.GetValue(RuleTable)
	local	XPos  = imgui.GetCursorPosX()

	imgui.SetCursorPosX(imgui.GetCursorPosX()+10)

	imgui.TextColored({ 0.9, 0.9, 0.9, 1.0 }, ('%d'):fmt(value) )
	imgui.SameLine()
	imgui.TextColored({ 0.7, 0.7, 0.7, 1.0 }, ('(0x%.2X)'):fmt(value) )
	
	imgui.SameLine()

	if value > 0 and value < 23 then
		imgui.TextColored({ 0.0, 1.0, 0.0, 1.0 }, ('%s'):fmt(Decode.Jobs[value]) )
	else
		imgui.TextColored( ETC.Red, 'NONE' )
	end

end

--	-----------------------------------------------------------------------
--	Blue Spell (add 0x200)
--	-----------------------------------------------------------------------

function Decode.BLUSpell(RuleTable)

	local	value		= X64.GetValue(RuleTable) + 0x200
	local	XPos		= imgui.GetCursorPosX()	
	local	Resource	= AshitaCore:GetResourceManager():GetSpellById(value)
	local	Name		= nil

	imgui.SetCursorPosX(imgui.GetCursorPosX()+10)

	if nil ~= Resource then
		Name = Resource.Name[1]
	end

	XFunc.Decimal(value, ETC.OffW)
	imgui.SameLine()
	imgui.SetCursorPosX(XPos+150)

	if value > 512 and nil ~= Name then
		imgui.TextColored(ETC.Green, ('%s'):fmt(Name) )
	else
		imgui.TextColored(ETC.Red, 'Unknown Spell' )
	end

end

--	-----------------------------------------------------------------------
--	Attachment (add 0x2100 to get sub ID)
--	-----------------------------------------------------------------------

function Decode.Attach(RuleTable)

	local	value	= X64.GetValue(RuleTable) + 0x2100
	local	XPos	= imgui.GetCursorPosX()	
	local	Name	= nil

	imgui.SetCursorPosX(imgui.GetCursorPosX()+10)
	XFunc.Decimal(value, ETC.OffW)
	imgui.SameLine()

	imgui.SetCursorPosX(XPos+100)

	Name = Decode.TAB_Attach[value]

	if Name ~= nil then
		imgui.TextColored(ETC.Green, ('%s'):fmt(Name) )
	else
		imgui.TextColored(ETC.Red, 'Unknown' )
	end

end

--	---------------------------------------------------------------------------
--	Puppet Part
--	---------------------------------------------------------------------------

function Decode.Puppet(RuleTable)

	local value = X64.GetValue(RuleTable)
	local XPos  = imgui.GetCursorPosX()
	local Item	= Decode.TAB_Puppet[value]
	
	imgui.SetCursorPosX(imgui.GetCursorPosX()+10)
	XFunc.Decimal(value, ETC.OffW)
	imgui.SameLine()
	
	imgui.SetCursorPosX(XPos+100)

	if nil ~= Item then
		imgui.TextColored( ETC.Green, ('%s'):fmt(Item) )
	else
		imgui.TextColored(ETC.Red, 'Unknown' )
	end

end

--	---------------------------------------------------------------------------
--	Spell
--	---------------------------------------------------------------------------

function Decode.Spell(RuleTable)

	local value 	= X64.GetValue(RuleTable)
	local XPos  	= imgui.GetCursorPosX()

	imgui.SetCursorPosX(imgui.GetCursorPosX()+10)

	XFunc.Decimal(value, ETC.OffW)
	imgui.SameLine()

	imgui.SetCursorPosX(XPos+150)

	local resource = AshitaCore:GetResourceManager():GetSpellById(value)

	if (nil ~= resource) then
		imgui.TextColored( ETC.Green, ('%s'):fmt(resource.Name[1]) )
	else
		imgui.TextColored( ETC.Red, ('UNKNOWN SPELL') )
	end

end

--	---------------------------------------------------------------------------
--	This decodes a status effect
--	---------------------------------------------------------------------------

function Decode.Status(RuleTable)

	local value 	= X64.GetValue(RuleTable)
	local XPos  	= imgui.GetCursorPosX()
	local resource	= AshitaCore:GetResourceManager():GetStatusIconById(value)

	if nil ~= resource then
	
		local Status = resource.Description[1]
		XFunc.PaintLongString(Status, ETC.Green, 300)

	else

		--	We have no idea

		imgui.SetCursorPosX(imgui.GetCursorPosX()+10)
		imgui.TextColored(ETC.Red, ('UNKNOWN') )

	end

end

--	---------------------------------------------------------------------------
--	This decodes a player action
--	---------------------------------------------------------------------------

function Decode.Action(RuleTable)

	local value 	= X64.GetValue(RuleTable)
	local XPos  	= imgui.GetCursorPosX()
	local name		= Decode.TAB_Actions[value]

	imgui.SetCursorPosX(imgui.GetCursorPosX()+10)

	if nil ~= name then
		imgui.TextColored(ETC.Green, ('%s'):fmt(name) )
	else
		imgui.TextColored(ETC.Red, 'UNKNOWN' )
	end

end

--	---------------------------------------------------------------------------
--	This decodes a weapon skill
--	---------------------------------------------------------------------------

function Decode.WSkill(RuleTable)

	local value 	= X64.GetValue(RuleTable)
	local XPos  	= imgui.GetCursorPosX()
	local name		= Decode.TAB_Actions[value]

	imgui.SetCursorPosX(imgui.GetCursorPosX()+10)

	XFunc.Hex(value, ETC.OffW, 16)
	imgui.SameLine()
	imgui.SetCursorPosX(XPos + 150)

	local OurTable = Decode.TAB_WSkills

	if nil ~= OurTable then
		for i, ThisTable in pairs(OurTable) do
			if i == value then

				if nil ~= RuleTable.Command then
					imgui.TextColored( ETC.Yellow, ('%s'):fmt(ThisTable) )
				else
					imgui.TextColored( ETC.Red, 'Unknown' )
				end
			end
		end
	end

end

--	---------------------------------------------------------------------------
--	This decodes a RoE missions
--	---------------------------------------------------------------------------

function Decode.RoE(RuleTable)

	local value 	= X64.GetValue(RuleTable)
	local XPos  	= imgui.GetCursorPosX()

	local OurTable = Decode.TAB_RoE

	if nil ~= OurTable then
		for i, ThisTable in pairs(OurTable) do
			if i == value then

				if nil ~= RuleTable.Command then
					XFunc.PaintLongString(ThisTable, ETC.Green, 300)					
				else
					imgui.TextColored( ETC.Red, 'Unknown' )
				end
			end
		end
	end

end

--	Return this object

return Decode
