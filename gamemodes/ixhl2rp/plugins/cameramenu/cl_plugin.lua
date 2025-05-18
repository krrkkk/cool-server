local PLUGIN = PLUGIN or {}

local cameraPoints = {}
local currentIndex = 1
local progress = 0
local isAnimating = false

local function lerpVector(a, b, t)
    return a + (b - a) * t
end

local function lerpAngle(a, b, t)
    return LerpAngle(t, a, b)
end

local function StartCameraAnimation()
    if #cameraPoints < 2 then
        isAnimating = false
        return
    end

    currentIndex = 1
    progress = 0
    isAnimating = true
end

-- Получаем точки с сервера при открытии меню персонажей
hook.Add("InitPostEntity", "HookCharacterMenuInit", function()
    if ix.gui.characterMenu and ix.gui.characterMenu.Init then
        local oldInit = ix.gui.characterMenu.Init
        function ix.gui.characterMenu:Init(...)
            oldInit(self, ...)

            net.Start("ixRequestCameraPoints")
            net.SendToServer()
        end
    end
end)

hook.Add("OnCharacterMenuCreated", "StartCameraAnimationHook", function(panel)
    net.Start("ixRequestCameraPoints")
    net.SendToServer()
end)

net.Receive("ixCameraMenuPoints", function()
    cameraPoints = net.ReadTable()
    StartCameraAnimation()
end)

hook.Add("Think", "StopAnimationOnCharacterMenuClose", function()
    if isAnimating and ix.gui.characterMenu and ix.gui.characterMenu.bClosing then
        isAnimating = false
    end
end)

hook.Add("CalcView", "CameraMenuAnimation", function(ply, pos, angles, fov)
    if not isAnimating or #cameraPoints < 2 then return end

    local from = cameraPoints[currentIndex]
    local to = cameraPoints[currentIndex + 1]

    if not from or not to then
        isAnimating = false
        return
    end

    progress = progress + FrameTime() / (to.speed or 1)
    if progress >= 1 then
        progress = 0
        currentIndex = currentIndex + 1

        if currentIndex >= #cameraPoints then
            currentIndex = 1
        end
    end

    local newPos = lerpVector(from.pos, to.pos, progress)
    local newAng = lerpAngle(from.ang, to.ang, progress)

    return {
        origin = newPos,
        angles = newAng,
        fov = fov,
        drawviewer = true,
    }
end)

-- Остановка анимации при загрузке персонажа
hook.Add("CharacterLoaded", "StopCameraAnimationOnCharLoad", function()
    isAnimating = false
end)

hook.Add("PlayerButtonDown", "ixCameraMenu_StopOnKey", function(ply, button)
    if isAnimating and button == KEY_SPACE then
        isAnimating = false
    end
end)

-- Скрытие игроков и себя во время анимации камеры
hook.Add("PreDrawPlayer", "HidePlayersDuringCameraAnimation", function(ply)
    if isAnimating then return false end
end)

hook.Add("ShouldDrawLocalPlayer", "HideSelfDuringCameraAnimation", function()
    if isAnimating then return false end
end)

-- ======= VGUI для управления точками камеры (только клиент) =======

local function OpenCameraPointsMenu()
    local frame = vgui.Create("DFrame")
    frame:SetSize(500, 400)
    frame:Center()
    frame:SetTitle("Управление точками камеры для карты: " .. game.GetMap())
    frame:MakePopup()

    local list = vgui.Create("DListView", frame)
    list:Dock(FILL)
    list:AddColumn("№")
    list:AddColumn("Позиция")
    list:AddColumn("Угол")
    list:AddColumn("Скорость")

    local function RefreshList()
        list:Clear()
        for i, point in ipairs(cameraPoints) do
            list:AddLine(
                i,
                string.format("x: %.1f y: %.1f z: %.1f", point.pos.x, point.pos.y, point.pos.z),
                string.format("p: %.1f y: %.1f r: %.1f", point.ang.p, point.ang.y, point.ang.r),
                tostring(point.speed)
            )
        end
    end

    RefreshList()

    -- Редактирование скорости по нажатию на колонке "Скорость"
    list.OnRowSelected = function(lst, index, pnl)
        if not pnl then return end

        local pointIndex = index
        local oldSpeed = cameraPoints[pointIndex] and cameraPoints[pointIndex].speed or 1

        Derma_StringRequest(
            "Редактировать скорость",
            "Введите новую скорость для точки #" .. pointIndex,
            tostring(oldSpeed),
            function(text)
                local newSpeed = tonumber(text)
                if newSpeed and newSpeed > 0 then
                    cameraPoints[pointIndex].speed = newSpeed
                    RefreshList()

                    net.Start("ixUpdateCameraPointSpeed")
                    net.WriteInt(pointIndex, 16)
                    net.WriteFloat(newSpeed)
                    net.SendToServer()
                else
                    chat.AddText(Color(255, 100, 100), "Некорректное значение скорости")
                end
            end,
            function() end
        )
    end

    local pnlBottom = vgui.Create("DPanel", frame)
    pnlBottom:Dock(BOTTOM)
    pnlBottom:SetTall(30)
    pnlBottom:DockPadding(5, 5, 5, 5)

    local btnAdd = vgui.Create("DButton", pnlBottom)
    btnAdd:SetText("Добавить точку камеры (по позиции игрока)")
    btnAdd:Dock(LEFT)
    btnAdd:SetWide(220)
    btnAdd.DoClick = function()
        net.Start("ixAddCameraPoint")
        net.SendToServer()
    end

    local btnClear = vgui.Create("DButton", pnlBottom)
    btnClear:SetText("Очистить все точки")
    btnClear:Dock(LEFT)
    btnClear:SetWide(120)
    btnClear:DockMargin(5, 0, 5, 0)
    btnClear.DoClick = function()
        net.Start("ixClearCameraPoints")
        net.SendToServer()
    end

    local btnPreview = vgui.Create("DButton", pnlBottom)
    btnPreview:SetText("Предпросмотр анимации")
    btnPreview:Dock(FILL)
    btnPreview.DoClick = function()
        if #cameraPoints < 2 then
            chat.AddText(Color(255, 100, 100), "Недостаточно точек для анимации")
            return
        end

        isAnimating = true
        currentIndex = 1
        progress = 0
    end

    net.Receive("ixCameraMenuPoints", function()
        cameraPoints = net.ReadTable()
        RefreshList()
    end)
end

concommand.Add("open_camera_points_menu", function()
    OpenCameraPointsMenu()
end)
