--	------------------------------
--	File handler (interface to OS)
--	------------------------------

require('io')
require('os')

local MiniFiles = {}

--	---------------------------------------------------------------------------
--	Low level file operations (via Ashita)
--	---------------------------------------------------------------------------

function MiniFiles.FolderExists(path)
    return ashita.fs.exists(path)
end

function MiniFiles.FileExists(path)
    return ashita.fs.exists(path)
end

function MiniFiles.CreateFolder(path)
    ashita.fs.create_dir(path)
end

--	---------------------------------------------------------------------------
--	This will try to create a folder at the "NewFolder" path
--	---------------------------------------------------------------------------

function MiniFiles.MKDIR(NewFolder)

	--	If the folder exists

	if not MiniFiles.FolderExists(NewFolder) then
		MiniFiles.CreateFolder(NewFolder)
	end

end

function MiniFiles.MKFile(Folder, NewFile)

	--	If the folder exists

	if MiniFiles.FolderExists(Folder) then

		if not MiniFiles.FileExists(Folder .. '\\' .. NewFile) then

			local fh = io.open(Folder .. '\\' .. NewFile .. '.log', 'w')

			fh:write('')
			fh:close()

		end
	end

end

function MiniFiles.FileAppend(Folder, File, Data)

    local hFile = io.open(Folder .. '\\' .. File .. '.log', 'a')

	hFile:write(Data)
	hFile:flush()
    hFile:close()

end

return MiniFiles
