--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher


-- Backwards compatibility with addons
util.AddNetworkString( "PlayerKilledNPC" )
util.AddNetworkString( "NPCKilledNPC" )
util.AddNetworkString( "PlayerKilled" )
util.AddNetworkString( "PlayerKilledSelf" )
util.AddNetworkString( "PlayerKilledByPlayer" )

-- New way
util.AddNetworkString( "DeathNoticeEvent" )

DEATH_NOTICE_FRIENDLY_VICTIM = 1
DEATH_NOTICE_FRIENDLY_ATTACKER = 2
--DEATH_NOTICE_HEADSHOT = 4
--DEATH_NOTICE_PENETRATION = 8
function GM:SendDeathNotice( attacker, inflictor, victim, flags )

	net.Start( "DeathNoticeEvent" )

		if ( !attacker ) then
			net.WriteUInt( 0, 2 )
		elseif ( isstring( attacker ) ) then
			net.WriteUInt( 1, 2 )
			net.WriteString( attacker )
		elseif ( IsValid( attacker ) ) then
			net.WriteUInt( 2, 2 )
			net.WriteEntity( attacker )
		end

		net.WriteString( inflictor )

		if ( !victim ) then
			net.WriteUInt( 0, 2 )
		elseif ( isstring( victim ) ) then
			net.WriteUInt( 1, 2 )
			net.WriteString( victim )
		elseif ( IsValid( victim ) ) then
			net.WriteUInt( 2, 2 )
			net.WriteEntity( victim )
		end

		net.WriteUInt( flags, 8 )

	net.Broadcast()

end

function GM:GetDeathNoticeEntityName( ent )

	-- Some specific HL2 NPCs, just for fun
	-- TODO: Localization strings?
	if ( ent:GetClass() == "npc_citizen" ) then
		if ( ent:GetName() == "griggs" ) then return "Griggs" end
		if ( ent:GetName() == "sheckley" ) then return "Sheckley" end
		if ( ent:GetName() == "tobias" ) then return "Laszlo" end
		if ( ent:GetName() == "stanley" ) then return "Sandy" end
	end

	-- Custom vehicle and NPC names from spawnmenu
	if ( ent:IsVehicle() and ent.VehicleTable and ent.VehicleTable.Name ) then
		return ent.VehicleTable.Name
	end
	if ( ent:IsNPC() and ent.NPCTable and ent.NPCTable.Name ) then
		return ent.NPCTable.Name
	end

	-- Map spawned Odessa or Rebels, etc..
	for unique_class, NPC in pairs( list.Get( "NPC" ) ) do
		if ( unique_class == NPC.Class or ent:GetClass() != NPC.Class ) then continue end

		local allGood = true
		if ( NPC.Model and ent:GetModel() != NPC.Model ) then
			allGood = false
		end

		if ( NPC.Skin and ent:GetSkin() != NPC.Skin ) then
			allGood = false
		end

		-- For Rebels, etc.
		if ( NPC.KeyValues ) then
			for k, v in pairs( NPC.KeyValues ) do
				local kL = k:lower()
				if ( kL != "squadname" and kL != "numgrenades" and ent:GetInternalVariable( k ) != v ) then
					allGood = false
					break
				end
			end

			-- They get unset often :(
			--if ( NPC.SpawnFlags and ent:HasSpawnFlags( NPC.SpawnFlags ) ) then allGood = false end
		end

		-- Medics, ew..
		if ( unique_class == "Medic" and !ent:HasSpawnFlags( SF_CITIZEN_MEDIC ) ) then allGood = false end
		if ( unique_class == "Rebel" and ent:HasSpawnFlags( SF_CITIZEN_MEDIC ) ) then allGood = false end

		if ( allGood ) then return NPC.Name end
	end

	-- Unfortunately the code above still doesn't work for Antlion Workers, because they change their classname..
	if ( ent:GetClass() == "npc_antlion" and ent:GetModel() == "models/antlion_worker.mdl" ) then
		return list.Get( "NPC" )[ "npc_antlion_worker" ].Name
	end

	-- Fallback to old behavior
	return "#" .. ent:GetClass()

end

--[[---------------------------------------------------------
   Name: gamemode:OnNPCKilled( entity, attacker, inflictor )
   Desc: The NPC has died
-----------------------------------------------------------]]
function GM:OnNPCKilled( ent, attacker, inflictor )

	-- Don't spam the killfeed with scripted stuff
	if ( ent:GetClass() == "npc_bullseye" or ent:GetClass() == "npc_launcher" ) then return end

	-- If killed by trigger_hurt, act as if NPC killed itself
	if ( IsValid( attacker ) and attacker:GetClass() == "trigger_hurt" ) then attacker = ent end

	-- NPC got run over..
	if ( IsValid( attacker ) and attacker:IsVehicle() and IsValid( attacker:GetDriver() ) ) then
		attacker = attacker:GetDriver()
	end

	if ( !IsValid( inflictor ) and IsValid( attacker ) ) then
		inflictor = attacker
	end

	-- Convert the inflictor to the weapon that they're holding if we can.
	if ( IsValid( inflictor ) and attacker == inflictor and ( inflictor:IsPlayer() or inflictor:IsNPC() ) ) then

		inflictor = inflictor:GetActiveWeapon()
		if ( !IsValid( attacker ) ) then inflictor = attacker end

	end

	local InflictorClass = "worldspawn"
	local AttackerClass = game.GetWorld()

	if ( IsValid( inflictor ) ) then InflictorClass = inflictor:GetClass() end
	if ( IsValid( attacker ) ) then

		AttackerClass = attacker

		-- If there is no valid inflictor, use the attacker (i.e. manhacks)
		if ( !IsValid( inflictor ) ) then InflictorClass = attacker:GetClass() end

		if ( attacker:IsPlayer() ) then

			local flags = 0
			if ( ent:IsNPC() and ent:Disposition( attacker ) != D_HT ) then flags = flags + DEATH_NOTICE_FRIENDLY_VICTIM end

			self:SendDeathNotice( attacker, InflictorClass, self:GetDeathNoticeEntityName( ent ), flags )

			return
		end

	end

	-- Floor turret got knocked over
	if ( ent:GetClass() == "npc_turret_floor" ) then AttackerClass = ent end

	-- It was NPC suicide..
	if ( ent == AttackerClass ) then InflictorClass = "suicide" end

	local flags = 0
	if ( IsValid( Entity( 1 ) ) and ent:IsNPC() and ent:Disposition( Entity( 1 ) ) == D_LI ) then flags = flags + DEATH_NOTICE_FRIENDLY_VICTIM end
	if ( IsValid( Entity( 1 ) ) and AttackerClass:IsNPC() and AttackerClass:Disposition( Entity( 1 ) ) == D_LI ) then flags = flags + DEATH_NOTICE_FRIENDLY_ATTACKER end

	self:SendDeathNotice( self:GetDeathNoticeEntityName( AttackerClass ), InflictorClass, self:GetDeathNoticeEntityName( ent ), flags )

end

--[[---------------------------------------------------------
   Name: gamemode:ScaleNPCDamage( ply, hitgroup, dmginfo )
   Desc: Scale the damage based on being shot in a hitbox
-----------------------------------------------------------]]
function GM:ScaleNPCDamage( npc, hitgroup, dmginfo )

	-- More damage if we're shot in the head
	if ( hitgroup == HITGROUP_HEAD ) then

		dmginfo:ScaleDamage( 2 )

	end

	-- Less damage if we're shot in the arms or legs
	if ( hitgroup == HITGROUP_LEFTARM or
		 hitgroup == HITGROUP_RIGHTARM or
		 hitgroup == HITGROUP_LEFTLEG or
		 hitgroup == HITGROUP_RIGHTLEG or
		 hitgroup == HITGROUP_GEAR ) then

		dmginfo:ScaleDamage( 0.25 )

	end

end


--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher
