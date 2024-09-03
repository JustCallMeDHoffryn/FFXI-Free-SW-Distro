--	---------------------------------------------------------------------------
--	This file contains the data processing for Ticker Tape
--	---------------------------------------------------------------------------

require('common')

local chat = require('chat')

local CentralData		= require('CentralData')
local PktDspRulesIN		= require('data/RulesIn')	--	Table of IN  display rules
local PktDspRulesOUT	= require('data/RulesOut')	--	Table of OUT display rules

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

--	---------------------------------------------------------------------------
--	Makes a rule table entry safe
--	---------------------------------------------------------------------------

function DataProc.DecodeRuleTable(RuleTable)

	for Item, ItemDef in ipairs(RuleTable) do

		--print(string.format('Rule: %d', Item))
		
		local   Offset	= 0
		local   Bits	= 0
		local   NoBits	= 0
		local	Logic	= 'none'
		local	Flag	= 0
		local	TabID	= 0
		local	Extra	= ''
		local	CMD		= {'', 0, 0, 0}
		local	Format	= 'na'
		local	Decode	= 'na'
		local	String	= 'na'

		if nil ~= ItemDef[1] then
			if ItemDef[1][1] ~= nil then CMD[1] = ItemDef[1][1] end
			if ItemDef[1][2] ~= nil then CMD[2] = ItemDef[1][2] end
			if ItemDef[1][3] ~= nil then CMD[3] = ItemDef[1][3] end
			if ItemDef[1][4] ~= nil then CMD[4] = ItemDef[1][4] end
		end

		if nil ~= ItemDef[2] then
			if ItemDef[2][1] ~= nil then Offset = ItemDef[2][1] end
			if ItemDef[2][2] ~= nil then Bits   = ItemDef[2][2] end
			if ItemDef[2][3] ~= nil then NoBits = ItemDef[2][3] end
		end

		if ItemDef[3] ~= nil then Format = ItemDef[3] end
		if ItemDef[4] ~= nil then Decode = ItemDef[4] end
		if ItemDef[5] ~= nil then String = ItemDef[5] end

		if nil ~= ItemDef[6] then
			if ItemDef[6][1] ~= nil then Logic = ItemDef[6][1] end
			if ItemDef[6][2] ~= nil then Flag  = ItemDef[6][2] end
		end

		if ItemDef[7] ~= nil then TabID = ItemDef[7] end
		if ItemDef[8] ~= nil then Extra = ItemDef[8] end

		CentralData.PacketRules:append( {	Index	= Item,
											Command	= CMD[1],
											CMDOpt1 = CMD[2],
											CMDOpt2 = CMD[3],
											CMDOpt3 = CMD[4],
											Offset	= Offset,
											Bit		= Bits,			--	This is the value of the bit, ie bit 7 is 128
											Len		= NoBits,		--	The number of bits when decode == 'bits'
											Format	= Format,		--	Data format 
											Decode	= Decode,		--	Basic decode type
											String	= String,		--	Caption to tell the user what it is

											Logic	= Logic,		--	none, use, set
											Flag	= Flag,			--	Can use or set (see Format) flag from 1 to 1024
											TableID	= TabID,		--	If there is a table of data for this value
											Info	= Extra,		--	Info shown when type is a bool
										} )

	end

end

--	---------------------------------------------------------------------------
--	This processes a single command. A TRUE return causes the caller to purge
--	---------------------------------------------------------------------------

function DataProc.ProcessCommand(PacketDisplay, RuleTable, Packet)

	local	Step	= true
	local	Found	= false

	--	-----------------------------------------------------------------------
	--	Bottom of a LOOP (count, byte offset, bit offset are on the stack)
	--	-----------------------------------------------------------------------

	if 'end' == RuleTable.Command then

		local LastCommand = CentralData.GetLastStackCommand()

		--print(string.format('END .. Stack has %d entries (last .. %s)', CentralData.GetSize(), LastCommand))

		--	End of a loop (atm we are only interested in loops)

		if ('loop' == LastCommand) then
			CentralData.LoopEnd(RuleTable)
			Step	= true
			Found	= true
		end

	end

	--	-----------------------------------------------------------------------
	--	Break
	--	-----------------------------------------------------------------------

	if Found == false and 'break' == RuleTable.Command then

		local Stop	= false
		local Count = 0

		--print(string.format('Found BREAK .. Looking for [END 0]') )

		while Stop == false do
			
			CentralData.IDX = CentralData.IDX + 1
			local NextRule = CentralData.PacketRules[CentralData.IDX]

			if nil == NextRule then
				--print('Ran off the end...')
				CentralData.Pop()
				Stop = true
			else

				if nil ~= NextRule.Command then

					--	Have we hit the / an end

					if Count == 0 and 'end' == NextRule.Command then
						--print('Found End 0 ...')
						CentralData.Pop()
						Stop = true
						Step = true
					else
	
						if 'end' == NextRule.Command then
							Count = Count - 1
						end

						--	If we find a loop we need to step over the next 'end'

						if 'loop' == NextRule.Command then
							Count = Count + 1
						end

					end
				end
			end
		end

		Step	= true
		Found	= true

	end

	--	-----------------------------------------------------------------------
	--	TOP of a LOOP (params pushed to stack for later)
	--	-----------------------------------------------------------------------

	if Found == false and 'loop' == RuleTable.Command then
		CentralData.PushLoop(RuleTable)
		Step	= true
		Found	= true
	end

	--	-----------------------------------------------------------------------
	--	TOP of a SWITCH (params pushed to stack for later)
	--	-----------------------------------------------------------------------

	if Found == false and 'switch' == RuleTable.Command then

		local StackSize = CentralData.GetSize()
		local TestValue = PacketDisplay.ExtractByte(Packet, RuleTable.CMDOpt1)

		if RuleTable.CMDOpt2 == 2 then
			TestValue = TestValue + (256 * (PacketDisplay.ExtractByte(Packet, RuleTable.CMDOpt1 + 1)))
		end

		table.insert(CentralData.CmdStk, {	Index	= (StackSize + 1),
											CMD 	= RuleTable.Command,
											Packet	= 0,
											Line	= CentralData.IDX,
											Op1     = RuleTable.CMDOpt1,
											Op2     = RuleTable.CMDOpt2,
											Op3     = TestValue,
											Op4  	= 0,
											Op5  	= 0,
											Op6  	= 0,
											} )

		table.sort(CentralData.CmdStk, (function (a, b)
			return (a.Index < b.Index)
			end))

		--print(string.format('Found Switch .. [%d] (pushing)', TestValue) )
			
		--CentralData.ShowStack()

		--	Look for a "case" to test or "default"

		local Count = 0
		local Stop	= false
		Step 		= false

		--print(string.format('Looking for [case %d]', TestValue) )

		while Stop == false do

			CentralData.IDX = CentralData.IDX + 1
			local NextRule = CentralData.PacketRules[CentralData.IDX]

			--print(string.format('Line: %d - %s', NextRule.Index, NextRule.Command) )

			if nil == NextRule then
				--print('Ran off the end...')
				Stop = true
			else

				if nil ~= NextRule.Command then

					if 'loop' == NextRule.Command then
						Count = Count + 1
					end

					--	Have we hit the end

					if 'end' == NextRule.Command then

						if Count == 0 then
							--print('Found end... Going to POP now')
							CentralData.Pop()
							Stop = true
							Step = true
						else
							Count = Count - 1
						end
					end

					--	Have we hit a case

					if 'case' == NextRule.Command then

						--print(string.format('Found case [%s, %d]', NextRule.Command, NextRule.CMDOpt1) )

						if TestValue == NextRule.CMDOpt1 then
							--print('Found match...')
							Stop = true
							Step = true
						else
							--print('No match... Keep looking')
						end
					end

					--	Have we hit the default 

					if 'default' == NextRule.Command then
						Stop = true
						Step = true
					end

				end

			end

		end
	
		Found = true
		
	end

	--	-----------------------------------------------------------------------
	--	Return to caller
	--	-----------------------------------------------------------------------

	if Found == false and 'return' == RuleTable.Command then

		local StackSize = CentralData.GetSize()

		--print(string.format('RETURN Stack has %d entries', StackSize) )

		if StackSize > 0 then
			
			local Stack = CentralData.CmdStk[StackSize]

			--	Load the new rule set

			CentralData.PacketRules = T{}
			
			if 1 == Stack.Op1 then
		
				for Group, RuleTable in pairs(PktDspRulesIN) do
		
					if nil ~= RuleTable and Group == Stack.Packet then
						DataProc.DecodeRuleTable(RuleTable)
					end
				end
		
			else
		
				for Group, RuleTable in pairs(PktDspRulesOUT) do
		
					if nil ~= RuleTable and Group == Stack.Packet then
						DataProc.DecodeRuleTable(RuleTable)
					end
				end

			end

			-- Sort the rules, we want them in numerical order

			CentralData.PacketRules:sort(function (a, b)
				return (a.Index < b.Index)
			end)		

			CentralData.IDX = Stack.Line + 1

			Step	= false
			Found	= true

			--	Pop the stack

			CentralData.Pop()

		end

	end
	
	--	-----------------------------------------------------------------------
	--	Call another rule
	--	-----------------------------------------------------------------------

	if Found == false and 'call' == RuleTable.Command then

		local found = false

		--print(string.format('CALL 0x%03X, Direction = %d', RuleTable.CMDOpt1, Packet.direction) )
		
		if PacketDisplay.VerifyPacketRule(Packet.direction, RuleTable.CMDOpt1) then

			CentralData.PushCall(DataProc, RuleTable, Packet)

			found	= true
			Step	= false
			Found	= true
		
		end

	end

	return Step

end

-- Return the object

return DataProc
