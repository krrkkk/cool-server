local PLUGIN = PLUGIN
PLUGIN.cameraData = PLUGIN.cameraData or {}

util.AddNetworkString("ixCameraMenuPoints")
util.AddNetworkString("ixRequestCameraPoints")
util.AddNetworkString("ixAddCameraPoint")
util.AddNetworkString("ixClearCameraPoints")
util.AddNetworkString("ixUpdateCameraPointSpeed")

-- Создаём таблицу в SQLite при запуске
function PLUGIN:Initialize()
    sql.Query([[
        CREATE TABLE IF NOT EXISTS camera_points (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            map TEXT,
            pos_x REAL,
            pos_y REAL,
            pos_z REAL,
            ang_p REAL,
            ang_y REAL,
            ang_r REAL,
            speed REAL
        )
    ]])
    self:LoadCameraPoints()
end

-- Загружаем точки из SQLite
function PLUGIN:LoadCameraPoints()
    local map = game.GetMap()
    self.cameraData[map] = {}

    local data = sql.Query("SELECT * FROM camera_points WHERE map = " .. sql.SQLStr(map))
    if data then
        for _, row in ipairs(data) do
            table.insert(self.cameraData[map], {
                pos = Vector(tonumber(row.pos_x), tonumber(row.pos_y), tonumber(row.pos_z)),
                ang = Angle(tonumber(row.ang_p), tonumber(row.ang_y), tonumber(row.ang_r)),
                speed = tonumber(row.speed)
            })
        end
    end
end

-- Сохраняем точку в SQLite
function PLUGIN:SaveCameraPoint(map, pos, ang, speed)
    sql.Query(string.format([[
        INSERT INTO camera_points (map, pos_x, pos_y, pos_z, ang_p, ang_y, ang_r, speed)
        VALUES (%s, %f, %f, %f, %f, %f, %f, %f)
    ]],
        sql.SQLStr(map),
        pos.x, pos.y, pos.z,
        ang.p, ang.y, ang.r,
        speed
    ))
end

-- Удаляем точки из SQLite
function PLUGIN:ClearCameraPointsInDB(map)
    sql.Query("DELETE FROM camera_points WHERE map = " .. sql.SQLStr(map))
end

-- Команда добавления точки
ix.command.Add("AddCameraPoint", {
    adminOnly = true,
    arguments = {ix.type.number},
    OnRun = function(self, client, speed)
        local map = game.GetMap()
        local pos = client:GetPos() + Vector(0, 0, 64)
        local ang = client:EyeAngles()

        PLUGIN.cameraData[map] = PLUGIN.cameraData[map] or {}
        table.insert(PLUGIN.cameraData[map], { pos = pos, ang = ang, speed = speed })
        PLUGIN:SaveCameraPoint(map, pos, ang, speed)

        client:Notify("Точка камеры добавлена для карты " .. map)
    end
})

-- Команда очистки точек
ix.command.Add("ClearCameraPoints", {
    adminOnly = true,
    OnRun = function(self, client)
        local map = game.GetMap()
        PLUGIN.cameraData[map] = {}
        PLUGIN:ClearCameraPointsInDB(map)

        client:Notify("Точки камеры очищены для карты " .. map)

        for _, v in ipairs(player.GetAll()) do
            net.Start("ixCameraMenuPoints")
                net.WriteTable({})
            net.Send(v)
        end
    end
})

-- Отправка точек клиенту
net.Receive("ixRequestCameraPoints", function(_, ply)
    local map = game.GetMap()
    net.Start("ixCameraMenuPoints")
        net.WriteTable(PLUGIN.cameraData[map] or {})
    net.Send(ply)
end)

-- Добавление точки с клиента (через VGUI)
net.Receive("ixAddCameraPoint", function(_, ply)
    if not ply:IsAdmin() then return end

    local map = game.GetMap()
    local pos = ply:GetPos() + Vector(0, 0, 64)
    local ang = ply:EyeAngles()
    local speed = 3

    PLUGIN.cameraData[map] = PLUGIN.cameraData[map] or {}
    table.insert(PLUGIN.cameraData[map], { pos = pos, ang = ang, speed = speed })
    PLUGIN:SaveCameraPoint(map, pos, ang, speed)

    ply:Notify("Точка камеры добавлена для карты " .. map)

    for _, v in ipairs(player.GetAll()) do
        net.Start("ixCameraMenuPoints")
            net.WriteTable(PLUGIN.cameraData[map])
        net.Send(v)
    end
end)

-- Обновление скорости точки
net.Receive("ixUpdateCameraPointSpeed", function(_, ply)
    if not ply:IsAdmin() then return end

    local index = net.ReadInt(16)
    local newSpeed = net.ReadFloat()
    local map = game.GetMap()

    local data = PLUGIN.cameraData[map]
    if data and data[index] then
        data[index].speed = newSpeed
        ply:Notify("Скорость точки #" .. index .. " обновлена")

        -- Применяем обновление в БД (по-простому: очистим и заново сохраним)
        PLUGIN:ClearCameraPointsInDB(map)
        for _, point in ipairs(data) do
            PLUGIN:SaveCameraPoint(map, point.pos, point.ang, point.speed)
        end

        for _, v in ipairs(player.GetAll()) do
            net.Start("ixCameraMenuPoints")
                net.WriteTable(data)
            net.Send(v)
        end
    else
        ply:Notify("Точка с таким индексом не найдена")
    end
end)

-- Вызов инициализации
PLUGIN:Initialize()
