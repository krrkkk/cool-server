local SUI, NAME = CURRENT_SUI, CURRENT_SUI.name
local TDLib = sui.TDLib

local Panel = {}

sui.scaling_functions(Panel)

AccessorFunc(Panel, "m_bValue", "Value", FORCE_NUMBER)
AccessorFunc(Panel, "m_bMin", "Min", FORCE_NUMBER)
AccessorFunc(Panel, "m_bMax", "Max", FORCE_NUMBER)
AccessorFunc(Panel, "m_bDecimals", "Decimals", FORCE_NUMBER)


AccessorFunc(Panel, "m_fSlideX", "SlideX")
AccessorFunc(Panel, "m_fSlideY", "SlideY")

AccessorFunc(Panel, "m_iLockX", "LockX")
AccessorFunc(Panel, "m_iLockY", "LockY")

AccessorFunc(Panel, "Dragging", "Dragging")

function Panel:Init()
	self:ScaleInit()

	self:SetSlideX(0.5)
	self:SetSlideY(0.5)

	self:SetMouseInputEnabled(true)
	self:SetMin(0)
	self:SetMax(10)
	self:SetValue(1)
	self:SetDecimals(1)

	self:SetSize(100, 12)

	self.rounded_box = {}

	self.Knob = vgui.Create("DButton", self)
	self.Knob:SetText("")
	self.Knob:SetSize(15, 15)
	self.Knob:NoClipping(true)
	self.Knob.Paint = self.KnobPaint
	self.Knob.OnCursorMoved = function(panel, x, y)
		x, y = panel:LocalToScreen(x, y)
		x, y = self:ScreenToLocal(x, y)
		self:OnCursorMoved(x, y)
	end
	self.Knob.circle = {}

	self:SetLockY(0.5)
end

function Panel:IsEditing()
	return self.Dragging or self.Knob.Depressed
end

function Panel:SetEnabled(b)
	self.Knob:SetEnabled(b)
	FindMetaTable("Panel").SetEnabled(self, b) -- There has to be a better way!
end

function Panel:OnCursorMoved(x, y)
	if (not self.Dragging and not self.Knob.Depressed) then return end

	local w, h = self:GetSize()
	local iw, ih = self.Knob:GetSize()

	w = w - iw
	h = h - ih

	x = x - iw * 0.5
	y = y - ih * 0.5

	x = math.Clamp(x, 0, w) / w
	y = math.Clamp(y, 0, h) / h

	if self.m_iLockX then x = self.m_iLockX end
	if self.m_iLockY then y = self.m_iLockY end

	x, y = self:TranslateValues(x, y)

	self:SetSlideX(x)
	self:SetSlideY(y)

	self:InvalidateLayout()
end

function Panel:OnMousePressed(mcode)
	if not self:IsEnabled() then return true end

	-- When starting dragging with not pressing on the knob.
	self.Knob.Hovered = true

	self:SetDragging(true)
	self:MouseCapture(true)

	local x, y = self:CursorPos()
	self:OnCursorMoved(x, y)
end

function Panel:OnMouseReleased(mcode)
	-- This is a hack. Panel.Hovered is not updated when dragging a panel (Source's dragging, not Lua Drag'n'drop)
	self.Knob.Hovered = vgui.GetHoveredPanel() == self.Knob

	self:SetDragging(false)
	self:MouseCapture(false)
end

function Panel:SetMinMax(min, max)
	self:SetMin(min)
	self:SetMax(max)
end

function Panel:TranslateValues(x, y)
	self:SetValue(self:GetMin() + (x * self:GetRange()))
	return self:GetFraction(), y
end

function Panel:GetFraction()
	return (self:GetValue() - self:GetMin()) / self:GetRange()
end

function Panel:SetValue(val)
	val = math.Clamp(val, self:GetMin(), self:GetMax())
	val = math.Round(val, self:GetDecimals())

	self.m_bValue = val
	self:SetSlideX((val - self:GetMin()) / self:GetRange())

	self:OnValueChanged(val)
end

function Panel:OnValueChanged(val)
end

function Panel:GetRange()
	return self:GetMax() - self:GetMin()
end

function Panel:Paint(w, h)
	local _h = SUI.Scale(2)
	TDLib.RoundedBox(self.rounded_box, 3, 0, h / 2 - _h / 2, w, _h, SUI.GetColor("slider_track"))
end

function Panel:KnobPaint(w, h)
	if self.Depressed then
		TDLib.DrawCircle(self.circle, w / 2, h / 2, h / 1.1, SUI.GetColor("slider_pressed"))
	elseif self.Hovered then
		TDLib.DrawCircle(self.circle, w / 2, h / 2, h / 1.1, SUI.GetColor("slider_hover"))
	end

	TDLib.DrawCircle(self.circle, w / 2, h / 2, h / 2, SUI.GetColor("slider_knob"))
end

function Panel:PerformLayout(w, h)
	local knob_size = SUI.Scale(12)
	self.Knob:SetSize(knob_size, knob_size)

	w = w - knob_size
	h = h - knob_size
	self.Knob:SetPos((self.m_fSlideX or 0) * w, (self.m_fSlideY or 0) * h)
end

function Panel:SetSlideX(i)
	self.m_fSlideX = i
	self:InvalidateLayout()
end

function Panel:SetSlideY(i)
	self.m_fSlideY = i
	self:InvalidateLayout()
end

function Panel:GetDragging()
	return self.Dragging or self.Knob.Depressed
end

sui.register("Slider", Panel, "Panel")
