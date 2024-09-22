--	---------------------------------------------------------------------------
--	This file contains the central data structures and the flow logic
--	---------------------------------------------------------------------------

require('common')

local chat	= require('chat')
local imgui	= require('imgui')
local ETC	= require('ETC')			--	Our global data (brushes etc)

local CentralData = {

	PktDspRulesIN	= require('data/RulesIn'),	--	Table of IN  display rules
	PktDspRulesOUT	= require('data/RulesOut'),	--	Table of OUT display rules

	PacketRules	=	T{},
	CmdStk		=	{},
	IDX			=	1,
	Flags		=	T{},

	LoopIndex	=	0,
	LoopDepth	=	0,
	LoopProduct =	0,
	PlusByte	=	0,
	PlusBit		=	0,
    PacketSize	=	0,
    PacketData	=	0,
}

--	===========================================================================
--	These are the stack commands
--	===========================================================================

function CentralData.ZERO()

	local	Entries = CentralData.GetSize()

	while 0 ~= Entries do

		CentralData.CmdStk[Entries] = nil
		table.remove(CentralData)
		Entries = CentralData.GetSize()

	end
end

function CentralData.GetSize()

	local count = 0

	for _, Stack in ipairs(CentralData.CmdStk) do
		count = count + 1
	end

	return count

end

function CentralData.ShowStack()
	
	if 0 ~= CentralData.GetSize() then

		print(string.format('Stack State (%d Entries)', CentralData.GetSize()))

		for i, Stk in ipairs(CentralData.CmdStk) do
			print(string.format('    [%d] -> {%s} %d, %d, %d, %d, %d, %d, %d, %d', 
				i, Stk.CMD, Stk.Packet, Stk.Line, Stk.Op1, Stk.Op2, Stk.Op3, Stk.Op4, Stk.Op5, Stk.Op6 ))
		end

	else
		print(string.format('Stack [EMPTY]'))
	end

end

function CentralData.GetLastStack()

	local size = CentralData.GetSize()
	
	if 0 ~= size then
		return CentralData.CmdStk[size]
	else
		return nil
	end

end

function CentralData.GetLastStackCommand()

	local Size = CentralData.GetSize()

	if 0 ~= Size then
		return CentralData.CmdStk[Size].CMD
	else
		return nil
	end

end

function CentralData.Pop()

	local Size = CentralData.GetSize()

	--CentralData.ShowStack()

	if 0 ~= Size then
		CentralData.CmdStk[Size] = nil
		table.remove(CentralData)
		--CentralData.ShowStack()
	--else
		--print(string.format('ERROR .. Stack is already [EMPTY]'))
	end

end

--	===========================================================================
--	These are logic flow
--	===========================================================================

--	---------------------------------------------------------------------------
--	Push the start of a loop
--	---------------------------------------------------------------------------

function CentralData.PushLoop(RuleTable)

	local StackSize = CentralData.GetSize()
	local V1		= 0
	local V2		= 0
	local V3		= 0
	local idx		= 0

	--	Any of these could be a flag

	if type(RuleTable.CMDOpt1) == "string" then
		--imgui.TextColored( ETC.Magic, ('V1 = string = %s'):fmt(RuleTable.CMDOpt1) )
		idx, V1 = CentralData.GetNextValidNumber(RuleTable.CMDOpt1, 1)
	else
		V1 = RuleTable.CMDOpt1
	end

	if type(RuleTable.CMDOpt2) == "string" then
		idx, V2 = CentralData.GetNextValidNumber(RuleTable.CMDOpt2, 1)
	else
		V2 = RuleTable.CMDOpt2
	end

	if type(RuleTable.CMDOpt3) == "string" then
		idx, V3 = CentralData.GetNextValidNumber(RuleTable.CMDOpt3, 1)
	else
		V3 = RuleTable.CMDOpt3
	end

	--imgui.TextColored( ETC.Magic, ('V1 = %d, V2 = %d, V3 = %d'):fmt(V1, V2, V3) )
	
	if V1 > 0 then

		table.insert( CentralData.CmdStk,	{	Index	= (StackSize + 1),
												CMD 	= RuleTable.Command,
												Packet	= 0,
												Line	= CentralData.IDX,
												Op1		= V1,
												Op2		= V2,
												Op3  	= V3,
												Op4		= V1,	--	Copy of 1 ~ 3 to replace later
												Op5		= V2,
												Op6  	= V3,
											} )

		table.sort(CentralData.CmdStk, (function (a, b)
			return (a.Index < b.Index)
			end))

		CentralData.PlusByte	=	0
		CentralData.PlusBit		=	0
		
		--print(string.format('LOOP .. Pushed'))

		--CentralData.ShowStack()
	end

end

--	---------------------------------------------------------------------------
--	Push the start of a call
--	---------------------------------------------------------------------------

function CentralData.PushCall(DataProc, RuleTable, Packet)

	local StackSize = CentralData.GetSize()
	local Target    = RuleTable.CMDOpt1

	--	Insert into stack and sort

	table.insert(CentralData.CmdStk, {	Index	= (StackSize + 1),
										CMD 	= RuleTable.Command,
										Packet  = Packet.packet,
										Line	= CentralData.IDX,
										Op1		= Packet.direction,
										Op2  	= 0,
										Op3  	= 0,
										Op4  	= 0,
										Op5  	= 0,
										Op6  	= 0,
									} )

	table.sort(CentralData.CmdStk, (function (a, b)
										return (a.Index < b.Index)
										end))

	--CentralData.ShowStack()

	--	Load the new rule set (we have already verified that it exists)

	CentralData.PacketRules = T{}

	if 1 == Packet.direction then

		if nil ~= CentralData.PktDspRulesIN then

			for Group, Rule in pairs(CentralData.PktDspRulesIN) do

				if nil ~= Rule and Group == Target then
					DataProc.DecodeRuleTable(Rule)
				end
			end

		end

	else

		if nil ~= CentralData.PktDspRulesOUT then

			for Group, Rule in pairs(CentralData.PktDspRulesOUT) do

				if nil ~= Rule and Group == Target then
					DataProc.DecodeRuleTable(Rule)
				end
			end

		end

	end

	-- Sort the rules, we want them in numerical order

	CentralData.PacketRules:sort(function (a, b)
		return (a.Index < b.Index)
		end)

	CentralData.IDX	= 1

end

--	---------------------------------------------------------------------------
--	Pop the end of a loop
--	---------------------------------------------------------------------------

function CentralData.LoopEnd(RuleTable)

	local StackSize	= CentralData.GetSize()
	local Stack		= CentralData.CmdStk[StackSize]
	local Line		= Stack.Line + 1

	Stack.Op1 = Stack.Op1 - 1

	if 0 ~= Stack.Op1 then

		CentralData.PlusByte = CentralData.PlusByte + Stack.Op2
		CentralData.PlusBit	 = CentralData.PlusBit  + Stack.Op3
			
		CentralData.IDX			= Stack.Line
		CentralData.LoopIndex	= CentralData.LoopIndex + 1

	else

		CentralData.PlusByte	=	0
		CentralData.PlusBit		=	0
		CentralData.LoopIndex	=	0
		
		CentralData.Pop()

	end

end

--	===========================================================================
--	These are Flag functions
--	===========================================================================

function CentralData.ExtractFlag(str)

	local ret = 0

	if str:byte(1) == 0x23 then									--	#

		if str:byte(2) > 0x30 and str:byte(2) < 0x3A then		--	1 ~ 9
			ret = str:byte(2) - 0x30
		end
	
		if str:byte(2) == 0x43 or str:byte(2) == 0x63 then		--	C or c
			ret = 12 											-- Calculated when set
		end

		if str:byte(2) == 0x44 or str:byte(2) == 0x64 then		--	D or d
			ret = 13 											-- Calculated when set
		end

	end

	return ret

end

--	---------------------------------------------------------------------------
--	Gets the next valid character in a string (ignores spaces)
--	---------------------------------------------------------------------------

function CentralData.GetNextValidChar(str, idx)

	local	byte  = 0
	local   index = idx

	repeat

		if 32 == str:byte(index) then
			index = index + 1
		else
			byte  = str:byte(index)
			index = index + 1
		end

	until index > #str or 0 ~= byte

	return index, byte

end

--	---------------------------------------------------------------------------
--	Gets the next valid number in a string (may be the contents of a flag)
--	---------------------------------------------------------------------------

function CentralData.GetNextValidNumber(str, idx)

	local	byte  = 0
	local	value = 0

	idx, byte = CentralData.GetNextValidChar(str, idx)

	--imgui.TextColored( ETC.Magic, ('Str == <%s>, idx == %d, byte == 0x%02X'):fmt(str, idx, byte) )

	if 0x23 == byte then

		if idx <= #str then
			
			idx, byte = CentralData.GetNextValidChar(str, idx)

			if byte == 0x41 or byte == 0x61 then	--	#A == Packet size
				value = CentralData.PacketSize
			end

			if byte == 0x42 or byte == 0x62 then	--	#B == Loop depth
				value = CentralData.LoopDepth
			end

			if byte == 0x4C or byte == 0x6C then	--	#C == Loop offset product
				value = CentralData.LoopProduct
			end

			if byte > 0x30 and byte < 0x3A then		--	#1 ~ 9
				value = CentralData.Flags[byte - 0x30]
			end
			
			--imgui.TextColored( ETC.Magic, ('Flag value extracted == %d'):fmt(value) )

		end

	else

		--	Extract a decimal number

		value = byte - 0x30

		while idx <= #str and byte >= 0x30 and byte < 0x3A do
		
			idx, byte = CentralData.GetNextValidChar(str, idx)

			if byte >= 0x30 and byte < 0x3A then
				value = value * 10
				value = value + byte
				value = value - 0x30
			end
		end

		--imgui.TextColored( ETC.Magic, ('Number value extracted == %d'):fmt(value) )

	end

	return idx, value

end

--	---------------------------------------------------------------------------
--	Simple expression
--	---------------------------------------------------------------------------

function CentralData.ExecuteCalc(RuleTable)

	local ops    = '+-*/<>'
	local opID   = 0
	local stop   = false
	local idx    = 1
	local byte   = 0
	local str    = RuleTable.CMDOpt1
	local length = #str
	local flag   = 0
	local Val1 	 = 0
	local Val2 	 = 0
	local Value  = 0

	--	ALL commands must be of the form .. #? = A <op> B
	--	A and B can be a number (integer) or a flag (#1~9)
	--	<op> can be " + - * / < > " (<> are shift left right)
	--	? can be 1~9

	--	Look for the start ..

	idx, byte = CentralData.GetNextValidChar(str, idx)

	if idx > length or 0x23 ~= byte then stop = true end

	--	Now look for the flag ID

	if not stop then
		idx, byte = CentralData.GetNextValidChar(str, idx)
		if idx > length or byte <= 0x30 or byte >= 0x3A then
			stop = true
		else
			flag = byte - 0x30
		end
	end
	
	--	Now we need to find and step over the '='

	if not stop then
		idx, byte = CentralData.GetNextValidChar(str, idx)
		if idx > length or byte ~= 0x3D then
			stop = true
		end
	end

	if not stop then
		--	We now have the target flag (1~9) and a pointer to the next char, it may be a flag or a number
		--imgui.TextColored( ETC.Magic, ('Size %d, target = %d'):fmt(length, flag) )
		idx, Val1 = CentralData.GetNextValidNumber(str, idx)
		if idx > length then stop = true end	
	end

	if not stop then
		idx, byte = CentralData.GetNextValidChar(str, idx)
		if idx > length then stop = true end	
		--	Extract the operator
		
		for i=1, #ops do
			if byte == ops:byte(i) then
				opID = i
			end
		end
		
		--imgui.TextColored( ETC.Magic, ('Op = %d (%d, 0x%02x)'):fmt(opID, byte, byte) )

		if not stop and opID > 0 then
			
			idx, Val2 = CentralData.GetNextValidNumber(str, idx)

			--	We now have all we need

			if 1 == opID then Value = Val1 + Val2 end
			if 2 == opID then Value = Val1 - Val2 end
			if 3 == opID then Value = Val1 * Val2 end
			if 4 == opID and 0 ~= Val2 then Value = Val1 / Val2 end
			if 5 == opID then Value = bit.lshift(Val1, Val2) end
			if 6 == opID then Value = bit.rshift(Val1, Val2) end

			--imgui.TextColored( ETC.Magic, ('V1 = %d, V2 = %d, Value = %d'):fmt(Val1, Val2, Value) )

			CentralData.Flags[flag] = Value

		end

	end

end

--	---------------------------------------------------------------------------
--	Reload the rules
--	---------------------------------------------------------------------------

function CentralData.ReloadOUT(UI)

	local path = UI.GetScriptPath() .. 'data\\RulesOut.lua'

	CentralData.PktDspRulesOUT = nil
	CentralData.PktDspRulesOUT = dofile(path)

end

function CentralData.ReloadIN(UI)

	local path = UI.GetScriptPath() .. 'data/RulesIn.lua'

	CentralData.PktDspRulesIN = nil
	CentralData.PktDspRulesIN = dofile(path)

end

return CentralData
