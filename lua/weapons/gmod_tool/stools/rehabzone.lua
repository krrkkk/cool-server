TOOL.Category = "Rehab"
TOOL.Name = "Rehab Zone Tool"

local zones = zones or {}
local firstCorner = nil

if SERVER then
    util.AddNetworkString("ixRehabSyncZones")

    function SaveZones()
        sql.Query([[CREATE TABLE IF NOT EXISTS rehab_zones (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            minx REAL, miny REAL, minz REAL,
            maxx REAL, maxy REAL, maxz REAL
        );]])

        sql.Query("DELETE FROM rehab_zones;")

        for _, zone in ipairs(zones) do
            sql.Query(string.format("INSERT INTO rehab_zones (minx, miny, minz, maxx, maxy, maxz) VALUES (%f, %f, %f, %f, %f, %f);",
                zone.min.x, zone.min.y, zone.min.z,
                zone.max.x, zone.max.y, zone.max.z))
        end
    end

    function sendZones(ply)
        net.Start("ixRehabSyncZones")
            net.WriteUInt(#zones, 16)
            for _, zone in ipairs(zones) do
                net.WriteVector(zone.min)
                net.WriteVector(zone.max)
            end
        if ply then net.Send(ply) else net.Broadcast() end
    end
end

function TOOL:LeftClick(trace)
    if not self:GetOwner():IsAdmin() then return false end
    firstCorner = trace.HitPos
    self:GetOwner():ChatPrint("[Rehab Tool] First corner set.")
    return true
end

function TOOL:RightClick(trace)
    if not self:GetOwner():IsAdmin() then return false end
    if not firstCorner then
        self:GetOwner():ChatPrint("[Rehab Tool] Set the first corner first using left-click.")
        return false
    end

    local secondCorner = trace.HitPos
    local minCorner = Vector(math.min(firstCorner.x, secondCorner.x), math.min(firstCorner.y, secondCorner.y), math.min(firstCorner.z, secondCorner.z))
    local maxCorner = Vector(math.max(firstCorner.x, secondCorner.x), math.max(firstCorner.y, secondCorner.y), math.max(firstCorner.z, secondCorner.z))

    table.insert(zones, { min = minCorner, max = maxCorner })
    firstCorner = nil

    if SERVER then
        SaveZones()
        sendZones()
    end

    self:GetOwner():ChatPrint("[Rehab Tool] Zone created.")
    return true
end

function TOOL:Reload(trace)
    local ply = self:GetOwner()
    local pos = ply:GetPos()

    for i, zone in ipairs(zones) do
        if pos:WithinAABox(zone.min, zone.max) then
            table.remove(zones, i)
            if SERVER then
                SaveZones()
                sendZones()
            end
            ply:ChatPrint("[Rehab Tool] Zone removed.")
            return true
        end
    end

    ply:ChatPrint("[Rehab Tool] You are not inside any zone.")
    return false
end
-- Tool Logic
function TOOL:LeftClick(trace)
    if not self:GetOwner():IsAdmin() then return false end
    firstCorner = trace.HitPos
    self:GetOwner():ChatPrint("[Rehab Tool] Первая точка установлена.")
    return true
end

function TOOL:RightClick(trace)
    if not self:GetOwner():IsAdmin() then return false end
    if not firstCorner then
        self:GetOwner():ChatPrint("[Rehab Tool] Сначала установите первую точку (ЛКМ).")
        return false
    end

    local secondCorner = trace.HitPos
    local minCorner = Vector(
        math.min(firstCorner.x, secondCorner.x),
        math.min(firstCorner.y, secondCorner.y),
        math.min(firstCorner.z, secondCorner.z)
    )
    local maxCorner = Vector(
        math.max(firstCorner.x, secondCorner.x),
        math.max(firstCorner.y, secondCorner.y),
        math.max(firstCorner.z, secondCorner.z)
    )

    -- Для простоты создаём зону с targetZoneID = 0 и waitTime = 5, можно потом редактировать через VGUI
    table.insert(zones, {
        min = minCorner,
        max = maxCorner,
        targetZoneID = 0,
        waitTime = 5
    })

    firstCorner = nil

    SaveZones()
    if SERVER then sendZones() end

    self:GetOwner():ChatPrint("[Rehab Tool] Зона создана.")
    return true
end



-- Render zones only when holding the tool
if CLIENT then
    hook.Add("PostDrawTranslucentRenderables", "DrawRehabZones", function()
        local ply = LocalPlayer()
        local wep = ply:GetActiveWeapon()
        if not IsValid(wep) or wep:GetClass() ~= "gmod_tool" then return end
        local tool = ply:GetTool()
        if not tool or tool:GetMode() ~= "rehabzone" then return end

        if zones then
            render.SetMaterial(Material("models/props_combine/portalball001_sheet"))
            for _, zone in ipairs(zones) do
                if zone.min and zone.max then
                    local mins = zone.min
                    local maxs = zone.max
                    local center = (mins + maxs) / 2
                    local size = maxs - mins
                    local color = Color(255, 0, 0, 100)
                    render.DrawBox(center, Angle(0, 0, 0), -size / 2, size / 2, color, true)
                end
            end
        end
    end)

    net.Receive("ixRehabSyncZones", function()
        local count = net.ReadUInt(16)
        zones = {}
        for i = 1, count do
            local min = net.ReadVector()
            local max = net.ReadVector()
            local targetZoneID = net.ReadUInt(16)
            local waitTime = net.ReadFloat()
            table.insert(zones, { min = min, max = max, targetZoneID = targetZoneID, waitTime = waitTime })
        end
    end)
end
