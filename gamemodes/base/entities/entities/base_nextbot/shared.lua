--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher


AddCSLuaFile()

ENT.Base 			= "base_entity"
ENT.PrintName		= ""
ENT.Author			= ""
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""

ENT.Type = "nextbot"

function ENT:Initialize()
end

if ( SERVER ) then

	--
	-- All of the AI logic is serverside - so we derive it from a
	-- specialized class on the server.
	--
	include( "sv_nextbot.lua" )

else

	--[[---------------------------------------------------------
		Name: Draw
		Desc: Draw it!
	-----------------------------------------------------------]]
	function ENT:Draw()
		self:DrawModel()
	end

	--[[---------------------------------------------------------
		Name: DrawTranslucent
		Desc: Draw translucent
	-----------------------------------------------------------]]
	function ENT:DrawTranslucent()

		-- This is here just to make it backwards compatible.
		-- You shouldn't really be drawing your model here unless it's translucent

		self:Draw()

	end

	--[[---------------------------------------------------------
		Name: FireAnimationEvent
		Desc: Called when an animation event is fired. Return true to suppress
	-----------------------------------------------------------]]
	function ENT:FireAnimationEvent( pos, ang, event, options )
	end

end


--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher
