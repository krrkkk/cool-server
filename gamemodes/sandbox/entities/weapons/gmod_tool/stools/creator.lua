--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher


TOOL.AddToMenu = false
TOOL.ClientConVar[ "type" ] = "0"
TOOL.ClientConVar[ "name" ] = "0"
TOOL.ClientConVar[ "arg" ] = "0"

TOOL.Information = { { name = "left" } }

function TOOL:LeftClick( trace, attach )

	local type = self:GetClientNumber( "type", 0 )
	local name = self:GetClientInfo( "name" )
	local arg = self:GetClientInfo( "arg" )

	if ( CLIENT ) then return true end

	if ( type == 0 ) then

		Spawn_SENT( self:GetOwner(), name, trace )

	elseif ( type == 1 ) then

		Spawn_Vehicle( self:GetOwner(), name, trace )

	elseif ( type == 2 ) then

		Spawn_NPC( self:GetOwner(), name, arg, trace )

	elseif ( type == 3 ) then

		Spawn_Weapon( self:GetOwner(), name, trace )

	elseif ( type == 4 ) then

		CCSpawn( self:GetOwner(), nil, { name } ) -- Props

	end

	return true

end


--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher
