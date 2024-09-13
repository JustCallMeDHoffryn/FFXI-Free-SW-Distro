--	---------------------------------------------------------------------------
--	This file contains most of the logic for TickerTap, it makes use of IMGUI 
--	to render the various panels that display the packet information
--	---------------------------------------------------------------------------

local name    = 'tickertape'
local author  = 'DHoffryn'
local version = '0.1'
local command = 'tt'

--	---------------------------------------------------------------------------

if addon then
    addon.name 		= name
    addon.author 	= author
    addon.version	= version
    addon.command	= command
end

--	---------------------------------------------------------------------------

require('common')

local chat			= require('chat')
local imgui			= require('imgui')
local settings 		= require('settings')
local MiniFiles		= require('MiniFiles')
local CentralData	= require('CentralData')
local DIAG			= require('Diagnostics')

local PacketsClientOUT		= require('data/PacketsOut')	--	Table of packets OUT from the client TO the server
local PacketsClientIN		= require('data/PacketsIn')		--	Table of packets IN to the client FROM the server

local DataProc 				= require('DataProc')
local PacketDisplay			= require('PacketDisplay')

local InRun					= false
local OutRun				= false
local InMode				= 1
local OutMode				= 1
local ModeTextIn			= { 'Normal##IN',  'Start On##IN',  'Stop On##IN',  'Burst On##IN',  '- WAIT -##IN'  }
local ModeTextOut			= { 'Normal##OUT', 'Start On##OUT', 'Stop On##OUT', 'Burst On##OUT', '- WAIT -##OUT' }
local InFilter				= { '' }
local OutFilter				= { '' }
local InHunt				= 0
local OutHunt				= 0
local AnyCount				= 10

--	---------------------------------------------------------------------------
--	UI Variables
--	---------------------------------------------------------------------------

local defaults = T{
    
	x = 100,
    y = 500,
    show = true,

	ShowIn = T{},
	ShowOut = T{},

}

local UI = {
	
    -- Main Window

    ShowMain 		= { false, },
	ShowDiagnostics	= { false, },
	
	PacketStack = T{},
	
	StackIn 	= 1,	--	Next slot for a new packet
	StackSize	= 0,	--	How many packet are in the stack
	WindowSize	= 36,	--	How many lines the window can show
	
    LineSel		=  -1,
	
	SeqRun		= T{true},
	SeqSave		= T{false},
	
	CfgActive	= false,
	SaveLog		= false,

	PacketsOUT	=	T{},
	PacketsIN	=	T{},
	
    settings 	= settings.load(defaults),
	
	FileName	= '',

	Dirty  		= T{ 0.7, 0.7, 0.7, 1.0, },
	Soft  		= T{ 0.6, 0.6, 0.6, 1.0, },
	Grey1  		= T{ 0.5, 0.5, 0.5, 1.0, },
	OffW		= T{ 0.9, 0.9, 0.9, 1.0, },
	Yellow 		= T{ 0.9, 0.9, 0.0, 1.0, },
	Green		= T{ 0.0, 1.0, 0.0, 1.0, },
	Red			= T{ 0.9, 0.0, 0.0, 1.0, },
	Brown		= T{ 0.6, 0.4, 0.2, 1.0, },
}

--	---------------------------------------------------------------------------
--	Gets a cleaned up version of the path 
--	---------------------------------------------------------------------------

function UI.GetScriptPath()
	local path = addon.path
    path = string.gsub(path, '\\\\', '\\')
    return path
end

--	---------------------------------------------------------------------------
--	Build the file name, call the open function
--	---------------------------------------------------------------------------

function UI.StartCap()

    local date		= os.date('*t')
    local RootDir	= UI.GetScriptPath() .. 'captures'
    local FileName	= string.format('%.4d-%.2d-%.2d_%.2d_%.2d', date['year'], date['month'], date['day'], date['hour'], date['min'])

	MiniFiles.MKDIR(RootDir)
	MiniFiles.MKFile(RootDir, FileName)

	UI.FileName	= FileName
	UI.SaveLog	= true

end

--	---------------------------------------------------------------------------
--	Called when we want to force a save of the settings
--	---------------------------------------------------------------------------

function UI.SaveState()

	settings.save()

end

--	---------------------------------------------------------------------------
--	Updates the addon settings.
--
--	{table} s - The new settings table to use for the addon settings.
--	---------------------------------------------------------------------------

local function UpdateSettings(s)

	--	Update the settings table..

	if (s ~= nil) then
        UI.settings = s
    end

    --	Save the current settings..

	settings.save(defaults)

end

--	---------------------------------------------------------------------------
--	Registers a callback for the settings to monitor for character switches.
--	---------------------------------------------------------------------------

settings.register('settings', 'settings_update', UpdateSettings)

function UI.LoadInRules()

	UI.PacketsIN = T{}

	for pkt, Rule in pairs(PacketsClientIN) do

		local show = UI.settings.ShowIn[pkt]

		if nil == show then
			show = true
		end

		UI.PacketsIN:append(T{
			Index   	= pkt,
			Name		= Rule[1],
			View		= T{show},
		})

		UI.settings.ShowIn[pkt] = show

	end

	UI.PacketsIN:sort(function (a, b)
		return (a.Index < b.Index)
	end)

end

function UI.LoadOutRules()

	UI.PacketsOUT = T{}
	local count = 0
	for pkt, Rule in pairs(PacketsClientOUT) do

		local show = UI.settings.ShowOut[pkt]

		if nil == show then
			show = true
		end

		UI.PacketsOUT:append(T{
			Index   	= pkt,
			Name		= Rule[1],
			View		= T{show},
		})

		UI.settings.ShowOut[pkt] = show

		count = count + 1
	end

	UI.PacketsOUT:sort(function (a, b)
		return (a.Index < b.Index)
	end)

end

--	---------------------------------------------------------------------------
--	Loads the UI
--	---------------------------------------------------------------------------

function UI.load()

	UI.ShowMain[1] = UI.settings.show
	
	UI.PacketStack = T{}	-- Empty the table before we start

	for key = 1, UI.WindowSize do
		
		UI.PacketStack:append(T{
			index   	= key,
			direction	= 0,
			packet		= 0,
			size		= 0,
			now			= 0,
			data		= 0,
		})

	end

	UI.LoadOutRules()
	UI.LoadInRules()

	DIAG.BuildX64()

	--	Push the settings back to disk

	settings.save()

end

--	---------------------------------------------------------------------------
--	Build an ASCII grid of the data packet
--	---------------------------------------------------------------------------

function UI.RawData(Packet)

	local DataTable = T{}
	local index		= 1
	
	--	Build the top line
	
    local Header1 = '        |  0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F\n'
	local Header2 = '    ----+------------------------------------------------\n'

	DataTable = Header1 .. Header2

	local	row = 0
	local	col = 0
	local	idx = 0

	for byte = 1, Packet.size do

		if col == 0 then

			local Str = string.format('      %d | ', row)
			DataTable = DataTable .. Str

		end
	
		DataTable = DataTable .. string.format('%.2X ', Packet.data:byte(idx + 1, idx + 1))

		idx = idx + 1
		col = col + 1

		if col > 15 then
			col = 0
			row = row + 1

			DataTable = DataTable .. '\n'
			
		end

	end

	if col ~= 0 then
		DataTable = DataTable .. '\n'
	end

	DataTable = DataTable .. '\n'
	
	return DataTable
	
end

--	---------------------------------------------------------------------------
--	Handle the IN TO THE SERVER packets (normally called OUT)
--	---------------------------------------------------------------------------

function UI.packet_in(Packet)

	--	Look for a reason to start (Start ON)

	if InRun and 2 == InMode then
		if Packet.id == InHunt then
			UI.SeqRun[1] = true
			InRun  = false
			InMode = 1
		end
	end

	--	Look for a reason to start (Burst ON)

	if InRun and 4 == InMode then
		if Packet.id == InHunt then
			UI.SeqRun[1] = true
			AnyCount = 18
			InMode   = 5
		end
	end

	if ((UI.SeqRun[1]) or (InRun and 4 == InMode)) then

		local Show = true

		for pkt, Rule in pairs(UI.PacketsIN) do
			if (Packet.id == Rule.Index) then
				Show = Rule.View[1]
			end
		end	
		
		if Show then

			UI.PacketStack[UI.StackIn].direction	= 1
			UI.PacketStack[UI.StackIn].packet		= Packet.id
			UI.PacketStack[UI.StackIn].now			= os.date('[%M:%S]', os.time())
			UI.PacketStack[UI.StackIn].size			= Packet.size
			UI.PacketStack[UI.StackIn].data			= DataProc.EncodePacket(Packet)
			
			if UI.StackSize < UI.WindowSize then
				UI.StackSize = UI.StackSize + 1
			end
			
			if UI.StackIn < UI.WindowSize then
				UI.StackIn = UI.StackIn + 1
			else
				UI.StackIn = 1
			end

		end

		--	Look for a reason to stop

		if InRun and 3 == InMode then
			if Packet.id == InHunt then
				UI.SeqRun[1] = false
				InRun  = false
				InMode = 1
			end
		end

		--	Look for a reason to stop (Burst OFF in either mode)

		if (InRun and 5 == InMode) or (OutRun and 5 == OutMode) then
			
			if Show then AnyCount = AnyCount - 1 end

			if AnyCount <= 0 then
				UI.SeqRun[1] = false
				InRun   = false
				InMode  = 1
				OutRun  = false
				OutMode = 1
			end
		end

	end

    if UI.SaveLog then

		local RootDir = UI.GetScriptPath() .. 'captures'

		local timestr = os.date('%Y-%m-%d %H:%M:%S')
		local hexidstr = string.format('0x%.3X', Packet.id)

		MiniFiles.FileAppend(RootDir, UI.FileName, string.format('[%s] Incoming packet %s\n', timestr, hexidstr))
		MiniFiles.FileAppend(RootDir, UI.FileName, UI.RawData(Packet))

    end

end

--	---------------------------------------------------------------------------
--	Handle the OUT FROM THE SERVER packets (normally called IN)
--	---------------------------------------------------------------------------

function UI.packet_out(Packet)

	--	Look for a reason to start (Start ON)

	if OutRun and 2 == OutMode then
		if Packet.id == OutHunt then
			UI.SeqRun[1] = true
			OutRun  = false
			OutMode = 1
		end
	end

	--	Look for a reason to start (Burst)

	if OutRun and 4 == OutMode then
		if Packet.id == OutHunt then
			UI.SeqRun[1] = true
			AnyCount = 18
			OutMode  = 5
		end
	end

	if ((UI.SeqRun[1]) or (OutRun and 4 == OutMode)) then

		local Show = true

		for pkt, Rule in pairs(UI.PacketsOUT) do
			if (Packet.id == Rule.Index) then
				Show = Rule.View[1]
			end
		end

		if Show then

			UI.PacketStack[UI.StackIn].direction 	= -1
			UI.PacketStack[UI.StackIn].packet		= Packet.id
			UI.PacketStack[UI.StackIn].now			= os.date('[%M:%S]', os.time())
			UI.PacketStack[UI.StackIn].size			= Packet.size
			UI.PacketStack[UI.StackIn].data			= DataProc.EncodePacket(Packet)

			if UI.StackSize < UI.WindowSize then
				UI.StackSize = UI.StackSize + 1 
			end

			if UI.StackIn < UI.WindowSize then
				UI.StackIn = UI.StackIn + 1
			else
				UI.StackIn = 1
			end

		end

		--	Look for a reason to stop

		if OutRun and 3 == OutMode then
			if Packet.id == OutHunt then
				UI.SeqRun[1] = false
				OutRun  = false
				OutMode = 1
			end
		end

		--	Look for a reason to stop (Burst OFF in either mode)

		if (InRun and 5 == InMode) or (OutRun and 5 == OutMode) then

			if Show then AnyCount = AnyCount - 1 end

			if AnyCount <= 0 then
				UI.SeqRun[1] = false
				InRun   = false
				InMode  = 1
				OutRun  = false
				OutMode = 1
			end
		end

	end

    if UI.SaveLog then

		local RootDir = UI.GetScriptPath() .. 'captures'

		local timestr = os.date('%Y-%m-%d %H:%M:%S')
		local hexidstr = string.format('0x%.3X', Packet.id)

		MiniFiles.FileAppend(RootDir, UI.FileName, string.format('[%s] Outgoing packet %s\n', timestr, hexidstr))
		MiniFiles.FileAppend(RootDir, UI.FileName, UI.RawData(Packet))

    end

end

--	---------------------------------------------------------------------------
--	Renders the Packet Viewer
--	---------------------------------------------------------------------------

function UI.PacketViewer()

    imgui.SetNextWindowSizeConstraints({ 540 , 400, }, { 540, 980, })

	imgui.PushStyleColor(ImGuiCol_TitleBg,  		{0, 0.05, 0.10, .7})
	imgui.PushStyleColor(ImGuiCol_TitleBgActive, 	{0, 0.15, 0.25, .9})
	imgui.PushStyleColor(ImGuiCol_TitleBgCollapsed, {0, 0.25, 0.50, .4})
    imgui.PushStyleColor(ImGuiCol_WindowBg, 		{0.15, 0.20, 0.20, .8})

	if (imgui.Begin('Packet Viewer', UI.ShowMain )) then	

		--	If a line is selected, find the data and unpack it

		if -1 ~= UI.LineSel then
		
			local ThisSlice = UI.StackIn - UI.StackSize + UI.LineSel - 1
		
			if ThisSlice > UI.WindowSize then ThisSlice = ThisSlice - UI.WindowSize end
			if ThisSlice < 1 then ThisSlice = ThisSlice + UI.WindowSize end

			if 0 ~= UI.PacketStack[ThisSlice].packet then

				PacketDisplay.ShowPacket(UI.PacketStack[ThisSlice], UI, ThisSlice)
				
			end
			
		end
		
		imgui.End()

	end
	
	imgui.PopStyleColor(4)

	if UI.ShowDiagnostics[1] then
		DIAG.ShowWindow(UI)
	end

end

--	---------------------------------------------------------------------------
--	Renders the sequencer common 
--	---------------------------------------------------------------------------

function UI.RenderSequencerCommon()

	imgui.SetNextWindowSize({ 420, 869, })

    imgui.SetNextWindowSizeConstraints({ 420 , 869, }, { FLT_MAX, FLT_MAX, })

	imgui.PushStyleColor(ImGuiCol_TitleBg,  {0, 0.05, 0.10, .7})
	imgui.PushStyleColor(ImGuiCol_TitleBgActive, 	{0, 0.15, 0.25, .9})
	imgui.PushStyleColor(ImGuiCol_TitleBgCollapsed, {0, 0.25, 0.50, .4})

	if UI.SeqRun[1] then
		imgui.PushStyleColor(ImGuiCol_WindowBg, 		{0.15, 0.20, 0.20, .3})
	else
		imgui.PushStyleColor(ImGuiCol_WindowBg, 		{0.15, 0.20, 0.20, .8})
	end

	if (imgui.Begin('Ticker Tape - Sequence', UI.ShowMain, ImGuiWindowFlags_NoResize + ImGuiWindowFlags_NoScrollbar)) then	
		
		--	Render the controls
		
		if (imgui.Checkbox('Run', UI.SeqRun)) then
			UI.LineSel = -1
		end

		imgui.SameLine()
		imgui.SetCursorPosX(imgui.GetCursorPosX()+10)

		if (imgui.Checkbox('Save', UI.SeqSave)) then
			
			if UI.SeqSave[1] then
				--	Start a new save
				UI.StartCap()
			else
				--	Stop saving
				UI.SaveLog = false
			end

		end

		local XPos = imgui.GetCursorPosX()

		if UI.SaveLog then
		
			imgui.SameLine()
			imgui.TextColored({ 0.7, 0.7, 0.7, 1.0 }, ':')
			imgui.SameLine()
			imgui.TextColored({ 1.0, 0.2, 0.2, 1.0 }, UI.FileName)

		end

		imgui.SameLine()
		imgui.SetCursorPosX(XPos + 340)

		if (imgui.Button('Config')) then
			if UI.CfgActive then
				UI.CfgActive = false
			else
				UI.CfgActive = true
			end
		end

		imgui.SetCursorPosY(imgui.GetCursorPosY()+4)

		imgui.PushStyleColor(ImGuiCol_Separator, { 0.0, 0.0, 0.0, 1.0 })
		imgui.Separator()
		imgui.PopStyleColor()

		imgui.SetCursorPosY(imgui.GetCursorPosY()+5)

		return true

	end

	return false

end

--	---------------------------------------------------------------------------
--	Get a meaningful packet name
--	---------------------------------------------------------------------------

function UI.GetPacketName(ThisSlice)

	local Pkt = ''

	if 1 == UI.PacketStack[ThisSlice].direction then

		if nil ~= PacketsClientIN[UI.PacketStack[ThisSlice].packet] then					
			Pkt = string.format('%s', PacketsClientIN[UI.PacketStack[ThisSlice].packet][1])
		else
			Pkt = 'UKNOWN PACKET (IN)'
		end

	else

		if nil ~= PacketsClientOUT[UI.PacketStack[ThisSlice].packet] then					
			Pkt = string.format('%s', PacketsClientOUT[UI.PacketStack[ThisSlice].packet][1])
		else
			Pkt = 'UKNOWN PACKET (OUT)'
		end

	end

	return Pkt

end

--	---------------------------------------------------------------------------
--	Renders the common sequence line header
--	---------------------------------------------------------------------------

function UI.SeqHeader(ThisSlice)

	--	Time of packet

	local Alpha = 1.0

	if UI.SeqRun[1] then
		Alpha = 0.5
	end

	imgui.TextColored({ 0.9, 0.9, 0.9, Alpha }, UI.PacketStack[ThisSlice].now)
	imgui.SameLine()

	--	Packet ID and direction
	
	local hexidstr = string.format('%.3X', UI.PacketStack[ThisSlice].packet)

	if 1 == UI.PacketStack[ThisSlice].direction then
		imgui.TextColored({ 0.2, 1.0, 0.2, 1.0 }, string.format('C'))				--	IN to client
		imgui.SameLine()
		imgui.TextColored({ 1.0, 1.0, 1.0, 1.0 }, string.format('<<'))
		imgui.SameLine()
		imgui.TextColored({ 0.2, 1.0, 0.2, 1.0 }, string.format('%s', hexidstr))
	else
		imgui.TextColored({ 0.6, 0.6, 1.0, 1.0 }, string.format('%s', hexidstr))	--	OUT from client
		imgui.SameLine()
		imgui.TextColored({ 1.0, 1.0, 1.0, 1.0 }, string.format('>>'))
		imgui.SameLine()
		imgui.TextColored({ 0.6, 0.6, 1.0, 1.0 }, string.format('S'))
	end

	imgui.SameLine()
	local XPos = imgui.GetCursorPosX()

	imgui.SameLine()
	imgui.SetCursorPosX(XPos+2)
	imgui.TextColored({ 0.9, 0.9, 0.9, 1.0 }, (':'))

	imgui.SameLine()
	imgui.SetCursorPosX(XPos+10)
	imgui.PushStyleColor(ImGuiCol_Text, { 0.9, 0.9, 0.0, 1.0 })
	imgui.SameLine()

end

--	---------------------------------------------------------------------------
--	Renders the sequencer while static
--	---------------------------------------------------------------------------

function UI.RenderSequencerStatic()

	if UI.RenderSequencerCommon() and UI.StackSize > 0 then 

		imgui.PushStyleColor(ImGuiCol_Header, 			{0.75, 0.25, 0.25, 1.00} )
		imgui.PushStyleColor(ImGuiCol_HeaderHovered, 	{0.90, 0.31, 0.31, 1.00} )
		imgui.PushStyleColor(ImGuiCol_HeaderActive, 	{1.00, 0.44, 0.44, 1.00} )
		imgui.PushStyleColor(ImGuiCol_Text, 			{1.0, 1.0, 0.0, 1})

		local index = 1		--	We cannot trust the key, so we use an index as well	

		for key = 0, (UI.StackSize - 1) do
		
			local IsSelected = UI.LineSel == index

			if (key <= UI.StackSize) then
		
				local ThisSlice = UI.StackIn - UI.StackSize + key
			
				if ThisSlice > UI.WindowSize then ThisSlice = ThisSlice - UI.WindowSize end
				if ThisSlice < 1 then ThisSlice = ThisSlice + UI.WindowSize end

				if 0 ~= UI.PacketStack[ThisSlice].packet then

					UI.SeqHeader(ThisSlice)

					--	The packet content can be selected
										
					local Str = string.format('%s\t\t\t\t\t\t%d', UI.GetPacketName(ThisSlice), key)
						
					if (imgui.Selectable(Str, IsSelected)) then
						UI.LineSel = index
					end

				end
				
			end
			
			index = index + 1
			
		end

		imgui.PopStyleColor(4)		--	Local

		imgui.End()
		imgui.PopStyleColor(4)		--	From common
	
	end
	
end

--	---------------------------------------------------------------------------
--	Renders the sequencer while active
--	---------------------------------------------------------------------------

function UI.RenderSequencer()

	if UI.RenderSequencerCommon() and UI.StackSize > 0 then 
	
		--	The oldest slice is at the top of the window
		
		for key = 0, (UI.StackSize - 1) do

			local ThisSlice = UI.StackIn - UI.StackSize + key
		
			if ThisSlice > UI.WindowSize then ThisSlice = ThisSlice - UI.WindowSize end
			if ThisSlice < 1 then ThisSlice = ThisSlice + UI.WindowSize end

			if 0 ~= UI.PacketStack[ThisSlice].packet then

				UI.SeqHeader(ThisSlice)

				--	Packets from the SERVER -> CLIENT

				if 1 == UI.PacketStack[ThisSlice].direction then

					imgui.SameLine()
					
					if nil ~= PacketsClientIN[UI.PacketStack[ThisSlice].packet] then
						imgui.TextColored( { 0.9, 0.9, 0.0, 1.0 }, ('%s'):fmt(PacketsClientIN[UI.PacketStack[ThisSlice].packet][1]) )
					else
						imgui.TextColored( { 0.9, 0.9, 0.0, 1.0 }, ('UNKNOWN PACKET (IN)') )
					end
				end

				--	Packets from the CLIENT -> SERVER

				if -1 == UI.PacketStack[ThisSlice].direction then

					imgui.SameLine()

					if nil ~= PacketsClientOUT[UI.PacketStack[ThisSlice].packet] then
						imgui.TextColored( { 0.9, 0.9, 0.0, 1.0 }, ('%s'):fmt(PacketsClientOUT[UI.PacketStack[ThisSlice].packet][1]) )
					else
						imgui.TextColored( { 0.9, 0.9, 0.0, 1.0 }, ('UNKNOWN PACKET (OUT)') )
					end

				end

			end

		end
		
		imgui.End()
		imgui.PopStyleColor(4)	

    end

end

--	---------------------------------------------------------------------------
--	Renders list of OUT packets so the user can disable/enable them
--	---------------------------------------------------------------------------

function UI.Render_OutList()

	for pkt, Rule in pairs(UI.PacketsOUT) do

		local name = string.format('[0x%.3X]', Rule.Index)

		if (imgui.Checkbox(name, Rule.View)) then 
			UI.settings.ShowOut[Rule.Index] = Rule.View[1]
			UI.SaveState()
		end

		imgui.SameLine()

		if Rule.Index == OutHunt and OutRun then
			imgui.TextColored( { 1.0, 0.0, 0.0, 1.0 }, ('%s'):fmt(Rule.Name) )
		else
			imgui.TextColored( { 0.6, 0.6, 1.0, 1.0 }, ('%s'):fmt(Rule.Name) )
		end

	end

end

--	---------------------------------------------------------------------------
--	Renders list of IN packets so the user can disable/enable them
--	---------------------------------------------------------------------------

function UI.Render_InList()

	for pkt, Rule in pairs(UI.PacketsIN) do
	
		local name = string.format('[0x%.3X]', Rule.Index)
		
		if (imgui.Checkbox(name, Rule.View)) then
			UI.settings.ShowIn[Rule.Index] = Rule.View[1]
			UI.SaveState()
		end
		
		imgui.SameLine()

		if Rule.Index == InHunt and InRun then
			imgui.TextColored( { 1.0, 0.0, 0.0, 1.0 }, ('%s'):fmt(Rule.Name) )
		else
			imgui.TextColored( { 0.2, 1.0, 0.2, 1.0 }, ('%s'):fmt(Rule.Name) )
		end

	end

end

--	---------------------------------------------------------------------------
--	Handles the buttons in the config window
--	---------------------------------------------------------------------------

function UI.ConfigButtons()

	--	Set ALL OUT

	if imgui.Button('All##Out', {50, 0})  then
		for pkt, Rule in pairs(UI.PacketsOUT) do
			Rule.View[1] = true
			UI.settings.ShowOut[Rule.Index] = Rule.View[1]
		end
		UI.SaveState()
	end

	--	Set NONE OUT

	imgui.SameLine()

	if imgui.Button('None##Out', {50, 0}) then
		for pkt, Rule in pairs(UI.PacketsOUT) do
			Rule.View[1] = false
			UI.settings.ShowOut[Rule.Index] = Rule.View[1]
		end
		UI.SaveState()
	end

	--	Invert ALL OUT

	imgui.SameLine()

	if imgui.Button('Invert##Out', {75, 0}) then
		for pkt, Rule in pairs(UI.PacketsOUT) do
			Rule.View[1] = not Rule.View[1]
			UI.settings.ShowOut[Rule.Index] = Rule.View[1]
		end
		UI.SaveState()
	end

	--	Special OUT

	imgui.SameLine()

	if imgui.Button('Defined##Out', {75, 0}) then
		for pkt, Rule in pairs(UI.PacketsOUT) do

			if PacketDisplay.VerifyPacketRule(-1, Rule.Index) then
				Rule.View[1] = true
				UI.settings.ShowOut[Rule.Index] = true
			else
				Rule.View[1] = false
				UI.settings.ShowOut[Rule.Index] = false
			end

		end
		UI.SaveState()
	end

	imgui.SameLine()

	imgui.SetCursorPosX(376)

	--	Set ALL IN

	if imgui.Button('All##In', {50, 0}) then
		for pkt, Rule in pairs(UI.PacketsIN) do
			Rule.View[1] = true
			UI.settings.ShowIn[Rule.Index] = Rule.View[1]
		end
		UI.SaveState()
	end

	imgui.SameLine()

	--	Set NONE IN

	if imgui.Button('None##In', {50, 0}) then
		for pkt, Rule in pairs(UI.PacketsIN) do
			Rule.View[1] = false
			UI.settings.ShowIn[Rule.Index] = Rule.View[1]
		end
		UI.SaveState()
	end

	imgui.SameLine()

	--	Invert ALL IN

	if imgui.Button('Invert##In', {75, 0}) then
		for pkt, Rule in pairs(UI.PacketsIN) do
			Rule.View[1] = not Rule.View[1]
			UI.settings.ShowIn[Rule.Index] = Rule.View[1]
		end
		UI.SaveState()
	end

	--	Special IN

	imgui.SameLine()

	if imgui.Button('Defined##In', {75, 0}) then
		for pkt, Rule in pairs(UI.PacketsIN) do

			if PacketDisplay.VerifyPacketRule(1, Rule.Index) then
				Rule.View[1] = true
				UI.settings.ShowIn[Rule.Index] = true
			else
				Rule.View[1] = false
				UI.settings.ShowIn[Rule.Index] = false
			end

		end
		UI.SaveState()
	end

end

--	---------------------------------------------------------------------------
--	Extract the IN packet ID
--	---------------------------------------------------------------------------

function UI.StartInFilter()

	local Hunt = 0

	for i=1, string.len(InFilter[1]) do

		Hunt = Hunt * 16

		local This = InFilter[1]:byte(i, i)

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

	InHunt = Hunt
	imgui.SetWindowFocus('Set##2')

end

--	---------------------------------------------------------------------------
--	Extract the OUT packet ID
--	---------------------------------------------------------------------------

function UI.StartOutFilter()

	local Hunt = 0

	for i=1, string.len(OutFilter[1]) do

		Hunt = Hunt * 16

		local This = OutFilter[1]:byte(i, i)

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

	OutHunt = Hunt
	imgui.SetWindowFocus('Set##2')

end

--	---------------------------------------------------------------------------
--	Renders the UI.
--	---------------------------------------------------------------------------

function UI.Render()

	--	Don't waste time rendering if closed

	if (not UI.ShowMain[1]) then return end

	--	-----------------------------------------------------------------------
	--	Render the configuration window
	--	-----------------------------------------------------------------------

	if UI.CfgActive then

		imgui.PushStyleColor(ImGuiCol_WindowBg, 		{0.15, 0.20, 0.20, .8})
		imgui.PushStyleColor(ImGuiCol_TitleBg,  		{0, 0.05, 0.10, .7})
		imgui.PushStyleColor(ImGuiCol_TitleBgActive, 	{0, 0.15, 0.25, .9})
		imgui.PushStyleColor(ImGuiCol_TitleBgCollapsed, {0, 0.25, 0.50, .4})
		imgui.PushStyleColor(ImGuiCol_Header, 			{0, 0.06, .16,  .7})
		imgui.PushStyleColor(ImGuiCol_HeaderHovered, 	{0, 0.06, .16,  .9})
		imgui.PushStyleColor(ImGuiCol_HeaderActive, 	{0, 0.06, .16,   1})
		imgui.PushStyleColor(ImGuiCol_FrameBg, 			{0, 0.06, .16,   1})
		imgui.PushStyleColor(ImGuiCol_TabActive,		{0, 0.50, 0.75,  1})
		imgui.PushStyleColor(ImGuiCol_TabHovered,		{0, 0.40, 0.65,  1})
		imgui.PushStyleColor(ImGuiCol_Button, 			{0.75, 0.25, 0.25, 1.00} )
		imgui.PushStyleColor(ImGuiCol_ButtonHovered, 	{0.90, 0.31, 0.31, 1.00} )
		imgui.PushStyleColor(ImGuiCol_ButtonActive, 	{1.00, 0.44, 0.44, 1.00} )

		imgui.SetNextWindowSize({ 744, 524, })
		imgui.SetNextWindowSizeConstraints({ 744 , 524, }, { FLT_MAX, FLT_MAX, })

		if (imgui.Begin('Ticker Tape - Configuration', 1, ImGuiWindowFlags_NoResize)) then

			--	Buttons at the top

			imgui.SetCursorPosY(imgui.GetCursorPosY()+3)
			UI.ConfigButtons()
			imgui.SetCursorPosY(imgui.GetCursorPosY()+5)

			--	Left and right panels

			imgui.BeginChild('InPacketPanel', { 360, 414, }, true)
				UI.Render_OutList()
			imgui.EndChild()

			imgui.SameLine()

			imgui.BeginChild('OutPacketPanel', { 0, 414, }, true)
				UI.Render_InList()
			imgui.EndChild()

			--	Reload

			imgui.SetCursorPosY(imgui.GetCursorPosY()+5)

			if imgui.Button('Reload Rules##OUT', {120, 0}) then
				UI.LoadOutRules()
				CentralData.ReloadOUT(UI)
			end

			imgui.SameLine()
			imgui.SetCursorPosX(170)

			if OutRun then
				imgui.PushStyleColor(ImGuiCol_Button, 			{1, 0.6, 0.6,   1} )
				imgui.PushStyleColor(ImGuiCol_ButtonHovered, 	{1, 0.7, 0.7,   1} )
				imgui.PushStyleColor(ImGuiCol_ButtonActive, 	{1, 0.8, 0.8,   1} )
				imgui.PushStyleColor(ImGuiCol_Text, 			{1.0, 0.0, 0.0, 1} )
			else
				imgui.PushStyleColor(ImGuiCol_Button, 			{0.75, 0.25, 0.25, 1.00} )
				imgui.PushStyleColor(ImGuiCol_ButtonHovered, 	{0.90, 0.31, 0.31, 1.00} )
				imgui.PushStyleColor(ImGuiCol_ButtonActive, 	{1.00, 0.44, 0.44, 1.00} )
				imgui.PushStyleColor(ImGuiCol_Text, 			{1.0, 1.0, 0.0, 1})
			end

			if imgui.Button(ModeTextOut[OutMode], {85, 0}) then
				if OutRun then
					OutRun = false
				else			
					if OutMode < 4 then
						OutMode = OutMode + 1 
					else
						OutMode = 1
					end
				end
			end

			imgui.PopStyleColor(4)

			imgui.SameLine()
			imgui.SetCursorPosX(259)

			imgui.PushItemWidth(50)
			imgui.InputText('##OutLook', OutFilter, 5)
			imgui.PopItemWidth()

			imgui.SameLine()
			imgui.SetCursorPosX(313)

			if imgui.Button('Set##1', {40, 0}) then
				if OutRun then 
					OutFilter = { '' }
				else
					UI.StartOutFilter()
				end
				OutRun = not OutRun
			end

			--	Reload

			imgui.SameLine()
			imgui.SetCursorPosX(376)

			if imgui.Button('Reload Rules##IN', {120, 0}) then
				UI.LoadInRules()
				CentralData.ReloadIN(UI)
			end

			imgui.SameLine()
			imgui.SetCursorPosX(170+368)

			if InRun then
				imgui.PushStyleColor(ImGuiCol_Button, 			{1, 0.6, 0.6,   1} )
				imgui.PushStyleColor(ImGuiCol_ButtonHovered, 	{1, 0.7, 0.7,   1} )
				imgui.PushStyleColor(ImGuiCol_ButtonActive, 	{1, 0.8, 0.8,   1} )
				imgui.PushStyleColor(ImGuiCol_Text, 			{1.0, 0.0, 0.0, 1} )
			else
				imgui.PushStyleColor(ImGuiCol_Button, 			{0.75, 0.25, 0.25, 1.00} )
				imgui.PushStyleColor(ImGuiCol_ButtonHovered, 	{0.90, 0.31, 0.31, 1.00} )
				imgui.PushStyleColor(ImGuiCol_ButtonActive, 	{1.00, 0.44, 0.44, 1.00} )
				imgui.PushStyleColor(ImGuiCol_Text, 			{1.0, 1.0, 0.0, 1})
			end

			if imgui.Button(ModeTextIn[InMode], {85, 0}) then
				if InRun then
					InRun = false
				else
					if InMode < 4 then
						InMode = InMode + 1 
					else
						InMode = 1
					end
				end
			end

			imgui.PopStyleColor(4)

			imgui.SameLine()
			imgui.SetCursorPosX(627)

			imgui.PushItemWidth(50)
			imgui.InputText('##In Look', InFilter, 5)
			imgui.PopItemWidth()

			imgui.SameLine()
			imgui.SetCursorPosX(681)

			if imgui.Button('Set##2', {40, 0}) then
				if InRun then 
					InFilter = { '' }
				else
					UI.StartInFilter()
				end
				InRun = not InRun
			end

			imgui.End()

		end

		imgui.PopStyleColor(13)

	end

	--	-----------------------------------------------------------------------
	--	Render the sequencer
	--	-----------------------------------------------------------------------

	if UI.SeqRun[1] then
		UI.RenderSequencer()
	else
		UI.RenderSequencerStatic()
	end

	--	-----------------------------------------------------------------------
	--	Render the packet viewer
	--	-----------------------------------------------------------------------

	if UI.SeqRun[1] == false then
		UI.PacketViewer()
	end

end

-- Return the UI object

return UI
