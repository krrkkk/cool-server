--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher


-- Tool should return true if freezing the view angles
function ToolObj:FreezeMovement()
	return false
end

-- The tool's opportunity to draw to the HUD
function ToolObj:DrawHUD()
end

-- Force rebuild the Control Panel
function ToolObj:RebuildControlPanel( ... )

	local cPanel = controlpanel.Get( self.Mode )
	if ( !cPanel ) then ErrorNoHalt( "Couldn't find control panel to rebuild!" ) return end

	cPanel:ClearControls()
	self.BuildCPanel( cPanel, ... )

end


--leak by matveicher
--vk group - https://vk.com/codespill
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/7XaRzQSZ45
--ds - matveicher
