--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher


list.Set( "RopeMaterials", "#ropematerial.rope",		"cable/rope" )
list.Set( "RopeMaterials", "#ropematerial.cable",		"cable/cable2" )
list.Set( "RopeMaterials", "#ropematerial.xbeam",		"cable/xbeam" )
list.Set( "RopeMaterials", "#ropematerial.laser",		"cable/redlaser" )
list.Set( "RopeMaterials", "#ropematerial.electric",	"cable/blue_elec" )
list.Set( "RopeMaterials", "#ropematerial.physbeam",	"cable/physbeam" )
list.Set( "RopeMaterials", "#ropematerial.hydra",		"cable/hydra" )

local PANEL = {}

--[[---------------------------------------------------------
	Name: Paint
-----------------------------------------------------------]]
function PANEL:Init()

	self:SetItemWidth( 0.14 )
	self:SetItemHeight( 0.3 )
	self:SetAutoHeight( true )

	local mats = list.Get( "RopeMaterials" )
	for k, v in pairs( mats ) do

		self:AddMaterial( k, v )

	end

end

function PANEL:Paint( w, h )

	draw.RoundedBox( 4, 0, 0, w, h, Color( 128, 128, 128, 255 ) )

end

vgui.Register( "RopeMaterial", PANEL, "MatSelect" )


--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher
