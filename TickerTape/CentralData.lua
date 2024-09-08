--	---------------------------------------------------------------------------
--	This file contains the central data structures and the flow logic
--	---------------------------------------------------------------------------

require('common')

local chat	= require('chat')
local imgui	= require('imgui')

local CentralData = {

	PktDspRulesIN	= require('data/RulesIn'),	--	Table of IN  display rules
	PktDspRulesOUT	= require('data/RulesOut'),	--	Table of OUT display rules

	PacketRules	=	T{},
	CmdStk		=	{},
	IDX			=	1,

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

	table.insert( CentralData.CmdStk,	{	Index	= (StackSize + 1),
											CMD 	= RuleTable.Command,
											Packet	= 0,
											Line	= CentralData.IDX,
											Op1		= RuleTable.CMDOpt1,
											Op2		= RuleTable.CMDOpt2,
											Op3  	= RuleTable.CMDOpt3,
											Op4		= RuleTable.CMDOpt1,	--	Copy of 1 ~ 3 to replace later
											Op5		= RuleTable.CMDOpt2,
											Op6  	= RuleTable.CMDOpt3,
										} )

	table.sort(CentralData.CmdStk, (function (a, b)
		return (a.Index < b.Index)
		end))

	--print(string.format('LOOP .. Pushed'))

	--CentralData.ShowStack()

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

	--	Adjust the code based on the loop

	while Line < CentralData.IDX do
		
		if -1 == Stack.Op2 then		--	Increment by the size of the data type
		
			if 'word' == CentralData.PacketRules[Line].Format or 'rword' == CentralData.PacketRules[Line].Format then
				CentralData.PacketRules[Line].Offset = CentralData.PacketRules[Line].Offset + 2
			elseif 'dword' == CentralData.PacketRules[Line].Format or 'rdword' == CentralData.PacketRules[Line].Format then
				CentralData.PacketRules[Line].Offset = CentralData.PacketRules[Line].Offset + 4
			else
				CentralData.PacketRules[Line].Offset = CentralData.PacketRules[Line].Offset + 1
			end

		else
			CentralData.PacketRules[Line].Offset = CentralData.PacketRules[Line].Offset + Stack.Op2
		end
	
		CentralData.PacketRules[Line].Bit = CentralData.PacketRules[Line].Bit + Stack.Op3

		Line = Line + 1

	end

	Stack.Op1 = Stack.Op1 - 1

	if 0 ~= Stack.Op1 then
		
		CentralData.IDX = Stack.Line
	
	else

		--	Before we exit we put the loop back to its start settings

		Stack.Op1		= Stack.Op4
		Stack.Op2		= Stack.Op5
		Stack.Op31		= Stack.Op6

		CentralData.Pop()

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
