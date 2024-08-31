--	---------------------------------------------------------------------------
--	This file contains the central data structures
--	---------------------------------------------------------------------------

require('common')

local chat	= require('chat')
local imgui	= require('imgui')

local CentralData = {

	PacketRules	=	T{},
	Command		=	T{},
	IDX			=	1,

}

--	---------------------------------------------------------------------------
--	---------------------------------------------------------------------------

function CentralData.Push(NewCommand)

end

function CentralData.Pop()

	local Size = CentralData.GetSize()

	if 0 ~= Size then
		CentralData.Command[Size] = nil
		--print(string.format('Stack = %d', CentralData.GetSize()) )
	end
end

function CentralData.GetSize()

	local count = 0

	for _, Stack in ipairs(CentralData.Command) do
		count = count + 1
	end

	return count

end

return CentralData
