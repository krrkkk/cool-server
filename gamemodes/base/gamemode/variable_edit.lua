--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher


--
-- Called when we've received a call from a client who wants to edit
-- a particular entity.
--
function GM:VariableEdited( ent, ply, key, val, editor )

	if ( !IsValid( ent ) ) then return end
	if ( !IsValid( ply ) ) then return end

	--
	-- Check with the gamemode that we can edit the entity
	--
	local CanEdit = hook.Run( "CanEditVariable", ent, ply, key, val, editor )
	if ( !CanEdit ) then return end

	--
	-- Actually apply the edited value
	--
	ent:EditValue( key, val )

end

--
-- Your gamemode should use this hook to allow/dissallow editing
-- By default only admins can edit entities.
--
function GM:CanEditVariable( ent, ply, key, val, editor )

	return ply:IsAdmin() || game.SinglePlayer()

end


--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher
