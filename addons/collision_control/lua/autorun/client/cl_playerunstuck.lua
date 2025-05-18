
// Lua Developer: nano

// Client Side


---------------------------------------------------


--# off all client hooks #--
local function PlayerStuckOff()
	hook.Remove("StartCommand", "StartCommandStuck")
	hook.Remove("ShouldCollide", "ShouldCollideStuck")
	hook.Remove("PlayerSwitchWeapon", "PlayerSwitchWeaponStuck")
	hook.Remove("FinishMove", "FinishMoveStuck")
	hook.Remove("PhysgunDrop", "PhysgunDropStuck")
	hook.Remove("PhysgunPickup", "PhysgunPickupStuck")
end

--# on all client hooks #--
local function PlayerStuckOn()
	hook.Add("StartCommand", "StartCommandStuck", StartCommandStuck)
	hook.Add("ShouldCollide", "ShouldCollideStuck", ShouldCollideStuck)
	hook.Add("PlayerSwitchWeapon", "PlayerSwitchWeaponStuck", PlayerSwitchWeaponStuck)
	hook.Add("FinishMove", "FinishMoveStuck", FinishMoveStuck)
	hook.Add("PhysgunDrop", "PhysgunDropStuck", PhysgunDropStuck)
	hook.Add("PhysgunPickup", "PhysgunPickupStuck", PhysgunPickupStuck)
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
	local ply = LocalPlayer()
	if value_new == "0" then
		PlayerStuckOff()
	elseif value_new == "1" then
		PlayerStuckOn()
		ply:SetCustomCollisionCheck(true)
		if value_old == "2" then
			SetCollide(ply, false)
		end
	elseif value_new == "2" then
		PlayerStuckOn()
		ply:SetCustomCollisionCheck(true)
		SetCollide(ply, true)
	end
end)


--# client initialize #--
hook.Add("InitPostEntity","InitPostEntityStuckStartMap", function()
	local var = GetConVar("sv_player_stuck"):GetInt()
	local ply = LocalPlayer()
	if var == 1 then
		PlayerStuckOn()
		ply:SetCustomCollisionCheck(true)
	elseif var == 2 then
		PlayerStuckOn()
		ply:SetCustomCollisionCheck(true)
		SetCollide(ply, true)
	end
	hook.Remove("InitPostEntity","InitPostEntityStuckStartMap")
end)

--# on client start stuck #--
net.Receive("n_StuckClient", function(len, ply)
	ply = LocalPlayer()
	local b = net.ReadBool()
	if IsValid(ply) then
		SetCollide(ply, b)
	else
		hook.Add("Think", "ThinkStuck", function()
			ply = LocalPlayer()
			if IsValid(ply) then
				SetCollide(ply, b)
				hook.Remove("Think", "ThinkStuck")
			end
		end)
	end
end)

--# fire base weapons collide control #--
function StartCommandStuck(ply, cmd)
	if not ply.b_stuck and ply.b_weaponstuck then
		SetCollide(ply, true)
		ply.b_weaponstuck = nil
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
					SetCollide(ply, false)
					ply.b_weaponstuck = true
				else
					newWeapon.StuckPrimaryAttack(newWeapon)
					return
				end
				newWeapon.StuckPrimaryAttack(newWeapon)
				if not ply.b_stuck then
					SetCollide(ply, true)
					ply.b_weaponstuck = nil
				end
			end
		end
		
		if not newWeapon.StuckSecondaryAttack then
			newWeapon.StuckSecondaryAttack = newWeapon.SecondaryAttack
			
			newWeapon.SecondaryAttack = function()
				if ply.b_stuck then
					SetCollide(ply, false)
					ply.b_weaponstuck = true
				else
					newWeapon.StuckSecondaryAttack(newWeapon)
					return
				end
				newWeapon.StuckSecondaryAttack(newWeapon)
				if not ply.b_stuck then
					SetCollide(ply, true)
					ply.b_weaponstuck = nil
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
	ent2.b_stuck then
		return false
	end
end