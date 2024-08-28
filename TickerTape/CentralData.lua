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

function CentralData.GetSize()
	return #CentralData.Command
end

return CentralData
