--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher


-- A spawnflag constant for addons
SF_LUA_RUN_ON_SPAWN = 1

ENT.Type = "point"
ENT.DisableDuplicator = true

AccessorFunc( ENT, "m_bDefaultCode", "DefaultCode" )

function ENT:Initialize()

	-- If the entity has its first spawnflag set, run the code automatically
	if ( self:HasSpawnFlags( SF_LUA_RUN_ON_SPAWN ) ) then
		self:RunCode( self, self, self:GetDefaultCode() )
	end

end

function ENT:KeyValue( key, value )

	if ( key == "Code" ) then
		self:SetDefaultCode( value )
	end

end

function ENT:SetupGlobals( activator, caller )

	ACTIVATOR = activator
	CALLER = caller

	if ( IsValid( activator ) && activator:IsPlayer() ) then
		TRIGGER_PLAYER = activator
	end

end

function ENT:KillGlobals()

	ACTIVATOR = nil
	CALLER = nil
	TRIGGER_PLAYER = nil

end

function ENT:RunCode( activator, caller, code )

	self:SetupGlobals( activator, caller )

		RunString( code, "lua_run#" .. self:EntIndex() )

	self:KillGlobals()

end

function ENT:AcceptInput( name, activator, caller, data )

	if ( name == "RunCode" ) then self:RunCode( activator, caller, self:GetDefaultCode() ) return true end
	if ( name == "RunPassedCode" ) then self:RunCode( activator, caller, data ) return true end

	return false

end


--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher
