local PLUGIN = PLUGIN
PLUGIN.cameraData = PLUGIN.cameraData or {}

util.AddNetworkString("ixCameraMenuPoints")
util.AddNetworkString("ixRequestCameraPoints")
util.AddNetworkString("ixAddCameraPoint")
util.AddNetworkString("ixClearCameraPoints")

ix.command.Add("AddCameraPoint", {
    adminOnly = true,
    arguments = {ix.type.number},
    OnRun = function(self, client, speed)
        local map = game.GetMap()

        if type(PLUGIN.cameraData) ~= "table" then
            PLUGIN.cameraData = {}
        end

        if type(PLUGIN.cameraData[map]) ~= "table" then
            PLUGIN.cameraData[map] = {}
        end

        table.insert(PLUGIN.cameraData[map], {
            pos = client:GetPos() + Vector(0,0,64),
            ang = client:EyeAngles(),
            speed = speed
        })

        client:Notify("Точка камеры добавлена для карты "..map)
    end
})

ix.command.Add("ClearCameraPoints", {
    adminOnly = true,
    OnRun = function(self, client)
        local map = game.GetMap()

        if type(PLUGIN.cameraData) ~= "table" then
            PLUGIN.cameraData = {}
        end

        PLUGIN.cameraData[map] = {}

        client:Notify("Точки камеры очищены для карты "..map)
    end
})

net.Receive("ixRequestCameraPoints", function(len, ply)
    local map = game.GetMap()

    if type(PLUGIN.cameraData) ~= "table" then
        PLUGIN.cameraData = {}
    end

    net.Start("ixCameraMenuPoints")
        net.WriteTable(PLUGIN.cameraData[map] or {})
    net.Send(ply)
end)

net.Receive("ixAddCameraPoint", function(len, ply)
    if not ply:IsAdmin() then return end

    local map = game.GetMap()

    if type(PLUGIN.cameraData) ~= "table" then
        PLUGIN.cameraData = {}
    end

    if type(PLUGIN.cameraData[map]) ~= "table" then
        PLUGIN.cameraData[map] = {}
    end

    table.insert(PLUGIN.cameraData[map], {
        pos = ply:GetPos() + Vector(0,0,64),
        ang = ply:EyeAngles(),
        speed = 3 -- фиксированная скорость для добавления через VGUI
    })

    ply:Notify("Точка камеры добавлена для карты "..map)

    -- Обновляем клиентам (если нужно)
    for _, v in ipairs(player.GetAll()) do
        net.Start("ixCameraMenuPoints")
            net.WriteTable(PLUGIN.cameraData[map])
        net.Send(v)
    end
end)

net.Receive("ixClearCameraPoints", function(len, ply)
    if not ply:IsAdmin() then return end

    local map = game.GetMap()

    if type(PLUGIN.cameraData) ~= "table" then
        PLUGIN.cameraData = {}
    end

    PLUGIN.cameraData[map] = {}

    ply:Notify("Точки камеры очищены для карты "..map)

    for _, v in ipairs(player.GetAll()) do
        net.Start("ixCameraMenuPoints")
            net.WriteTable({})
        net.Send(v)
    end
end)

util.AddNetworkString("ixUpdateCameraPointSpeed")

net.Receive("ixUpdateCameraPointSpeed", function(len, ply)
    if not ply:IsAdmin() then return end

    local index = net.ReadInt(16)
    local newSpeed = net.ReadFloat()

    local map = game.GetMap()

    if type(PLUGIN.cameraData) ~= "table" then
        PLUGIN.cameraData = {}
    end

    if type(PLUGIN.cameraData[map]) ~= "table" then
        PLUGIN.cameraData[map] = {}
    end

    if PLUGIN.cameraData[map][index] then
        PLUGIN.cameraData[map][index].speed = newSpeed
        ply:Notify("Скорость точки #" .. index .. " обновлена")

        -- Рассылаем обновлённые данные всем игрокам
        for _, v in ipairs(player.GetAll()) do
            net.Start("ixCameraMenuPoints")
                net.WriteTable(PLUGIN.cameraData[map])
            net.Send(v)
        end
    else
        ply:Notify("Точка с таким индексом не найдена")
    end
end)

