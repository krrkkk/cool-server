
// Lua Developer: nano

// Server Side


---------------------------------------------------


--# off all server hooks #--
local function PlayerStuckOff()
	hook.Remove("StartCommand", "StartCommandStuck")
	hook.Remove("ShouldCollide", "ShouldCollideStuck")
	hook.Remove("PlayerSwitchWeapon", "PlayerSwitchWeaponStuck")
	hook.Remove("FinishMove", "FinishMoveStuck")
	hook.Remove("PhysgunDrop", "PhysgunDropStuck")
	hook.Remove("PhysgunPickup", "PhysgunPickupStuck")
	
	hook.Remove("PlayerInitialSpawn", "PlayerInitialSpawnStuck")
	hook.Remove("Think","ThinkStuck")
end

--# on all server hooks #--
local function PlayerStuckOn()
	hook.Add("StartCommand", "StartCommandStuck", StartCommandStuck)
	hook.Add("ShouldCollide", "ShouldCollideStuck", ShouldCollideStuck)
	hook.Add("PlayerSwitchWeapon", "PlayerSwitchWeaponStuck", PlayerSwitchWeaponStuck)
	hook.Add("FinishMove", "FinishMoveStuck", FinishMoveStuck)
	hook.Add("PhysgunDrop", "PhysgunDropStuck", PhysgunDropStuck)
	hook.Add("PhysgunPickup", "PhysgunPickupStuck", PhysgunPickupStuck)

	hook.Add("PlayerInitialSpawn", "PlayerInitialSpawnStuck", PlayerInitialSpawnStuck)
end

--# collision switch #--
local function SetCollide(ply, b)
	if not b then
		ply.b_stuck = nil
	else
		ply.b_stuck = true
	end
	ply:CollisionRulesChanged()
	ply:SetCustomCollisionCheck(b)
end

--# ConVar controls #--
CreateConVar("sv_player_stuck", "1", {FCVAR_ARCHIVE,FCVAR_REPLICATED,FCVAR_SERVER_CAN_EXECUTE})

cvars.AddChangeCallback("sv_player_stuck", function(convar_name, value_old, value_new)
	if value_new == "0" then
		PlayerStuckOff()
	elseif value_new == "1" then
		PlayerStuckOn()
		for k, ply in pairs(player.GetAll()) do
			ply:SetCustomCollisionCheck(true)
			if value_old == "2" then
				SetCollide(ply, false)
			end
		end
		hook.Add("Think","ThinkStuck", ThinkStuckPlayer)
	elseif value_new == "2" then
		PlayerStuckOn()
		for k, ply in pairs(player.GetAll()) do
			ply:SetCustomCollisionCheck(true)
			SetCollide(ply, true)
		end
		hook.Remove("Think", "ThinkStuck")
	end
end)

--# addon initialize #--
hook.Add("InitPostEntity","InitPostEntityStuckStartMap", function()
	local var = GetConVar("sv_player_stuck"):GetInt()
	if var == 1 then
		PlayerStuckOn()
		hook.Add("Think","ThinkStuck", ThinkStuckPlayer)
	elseif var == 2 then
		PlayerStuckOn()
	end
	hook.Remove("InitPostEntity","InitPostEntityStuckStartMap")
end)

--# client connected initialize #--
function PlayerInitialSpawnStuck(ply)
	ply:SetCustomCollisionCheck(true)
	if GetConVar("sv_player_stuck"):GetInt() == 2 then
		SetCollide(ply, true)
	end
end

--# on server start stuck #--
util.AddNetworkString("n_StuckClient")

function ThinkStuckPlayer()
	for k, ply in pairs(player.GetAll()) do
		if IsValid(ply) and ply:Alive() then
			local mins,maxs = ply:GetCollisionBounds()
			local trace = {}
			trace.start = ply:GetPos()
			trace.endpos = ply:GetPos()
			trace.filter = ply
			trace.mins = mins
			trace.maxs = maxs
			trace.ignoreworld = true
			trace.mask = MASK_PLAYERSOLID
			local tr = util.TraceHull(trace)
			local ent = tr.Entity
			if not ply.b_stuck and not ply.b_weaponstuck and IsValid(ent) and ent:IsPlayer() then
				SetCollide(ply, true)
				if not ply:IsBot() then
					net.Start("n_StuckClient")
					net.WriteBool(true)
					net.Send(ply)
				end
			elseif ply.b_stuck and !IsValid(ent) then
				SetCollide(ply, false)
				if not ply:IsBot() then
					net.Start("n_StuckClient")
					net.Send(ply)
				end
			end
		end
	end
end

--# fire base weapons collide control #--
function StartCommandStuck(ply, cmd)
	if not ply.b_stuck and ply.b_weaponstuck then
		ply.b_weaponstuck = nil
		SetCollide(ply, true)
	end
end

function PhysgunPickupStuck(ply, ent)
	local wep = ply:GetActiveWeapon()
	if IsValid(wep) then
		wep.physweapon = true
	end
end

function PhysgunDropStuck(ply, ent)
	local wep = ply:GetActiveWeapon()
	if IsValid(wep) then
		wep.physweapon = nil
	end
end

function FinishMoveStuck(ply, mv)
	local wep = ply:GetActiveWeapon()
	if IsValid(wep) and not wep:IsScripted() and ply.b_stuck then
		if wep:GetClass() == "weapon_physgun" then
			if mv:KeyDown(IN_ATTACK) then 
				if not wep.physweapon then
					ply.b_weaponstuck = true
					SetCollide(ply, false)
				end
			end
		elseif wep:GetNextPrimaryFire() <= CurTime() and mv:KeyDown(IN_ATTACK) then
			ply.b_weaponstuck = true
			SetCollide(ply, false)
		end
	end
end

--# fire swep collide control #--
function PlayerSwitchWeaponStuck(ply, oldWeapon, newWeapon)
	if IsValid(oldWeapon) and oldWeapon:IsScripted() then
		if oldWeapon.StuckPrimaryAttack then
			oldWeapon.PrimaryAttack = oldWeapon.StuckPrimaryAttack
			oldWeapon.StuckPrimaryAttack = nil
		end
	end
	
	if IsValid(newWeapon) and newWeapon:IsScripted() then
		if not newWeapon.StuckPrimaryAttack then
			newWeapon.StuckPrimaryAttack = newWeapon.PrimaryAttack
			
			newWeapon.PrimaryAttack = function()
				if ply.b_stuck then
					ply.b_weaponstuck = true
					SetCollide(ply, false)
				else
					newWeapon.StuckPrimaryAttack(newWeapon)
					return
				end
				newWeapon.StuckPrimaryAttack(newWeapon)
				if not ply.b_stuck then
					ply.b_weaponstuck = nil
					SetCollide(ply, true)
				end
			end
		end
		
		if not newWeapon.StuckSecondaryAttack then
			newWeapon.StuckSecondaryAttack = newWeapon.SecondaryAttack
			
			newWeapon.SecondaryAttack = function()
				if ply.b_stuck then
					ply.b_weaponstuck = true
					SetCollide(ply, false)
				else
					newWeapon.StuckSecondaryAttack(newWeapon)
					return
				end
				newWeapon.StuckSecondaryAttack(newWeapon)
				if not ply.b_stuck then
					ply.b_weaponstuck = nil
					SetCollide(ply, true)
				end
			end
		end
	end
end

--# collision control #--
function ShouldCollideStuck(ent1, ent2)
	if IsValid(ent1) and
	IsValid(ent2) and
	ent1:IsPlayer() and
	ent2:IsPlayer() and
	ent2.b_stuck and
	(ent1.b_stuck or ent1.b_weaponstuck) then
		return false
	end
end