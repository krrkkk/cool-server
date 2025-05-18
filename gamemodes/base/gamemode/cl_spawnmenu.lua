--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher

--[[---------------------------------------------------------
	Spawn Menu
-----------------------------------------------------------]]
function GM:OnSpawnMenuOpen()
end

function GM:OnSpawnMenuClose()
end

concommand.Add( "+menu", function()
	hook.Run( "OnSpawnMenuOpen" )
end, nil, "Opens the spawnmenu", FCVAR_DONTRECORD )

concommand.Add( "-menu", function()
	if ( input.IsKeyTrapping() ) then return end
	hook.Run( "OnSpawnMenuClose" )
end, nil, "Closes the spawnmenu", FCVAR_DONTRECORD )


--[[---------------------------------------------------------
	Context Menu
-----------------------------------------------------------]]
function GM:OnContextMenuOpen()
end

function GM:OnContextMenuClose()
end

concommand.Add( "+menu_context", function()
	hook.Run( "OnContextMenuOpen" )
end, nil, "Opens the context menu", FCVAR_DONTRECORD )

concommand.Add( "-menu_context", function()
	if ( input.IsKeyTrapping() ) then return end
	hook.Run( "OnContextMenuClose" )
end, nil, "Closes the context menu", FCVAR_DONTRECORD )


--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher
