-- =========================================================================
-- ruin.lol | Compact Edition (FOV Circles, Menu Keybind & Misc Upgrades)
-- =========================================================================

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService      = game:GetService("HttpService")
local Lighting         = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Camera      = workspace.CurrentCamera

-- =========================================================================
-- SETTINGS
-- =========================================================================

local Settings = {
    MasterToggle = true, TeamCheck = true, MaxDistance = 1000,
    Box = true, CornerBox = true, BoxFilled = true, BoxOpacity = 35,
    HealthBar = true, Name = true, Distance = true, Skeleton = true,
    Snaplines = false, Chams = true, Crosshair = true, BulletTracers = false,
    
    SpeedHack = false, WalkSpeed = 16,
    InfiniteJump = false, Noclip = false, Fly = false, FlySpeed = 50,
    GodMode = false, AntiRagdoll = false, CameraFOV = 90, Spinbot = false, SpinSpeed = 30,
    AntiFling = true, AntiKick = true,
    NoRecoil = false, NoSpread = false, InstantReload = false, FullAuto = false,
    
    AimEnabled = true, AimKey = Enum.KeyCode.Z, ToggleMode = true,
    AimPart = "HumanoidRootPart", AimMaxDistance = 300,
    PredictionBase = 0.12, PredictionAir = 0.05,
    SmoothingEnabled = true, SmoothingMin = 0.08, SmoothingMax = 0.2,
    CheckVisible = true, CheckTeam = false, CheckAlive = true, CheckKnocked = true,
    DrawAimFOV = true, AimFOV_Radius = 120, AimFOV_Color = 1, -- Color Preset
    
    SilentAim_Enabled = false, SilentAim_Key = Enum.KeyCode.C,
    SilentAim_FOV = 150, SilentAim_TeamCheck = true,
    SilentAim_VisibleCheck = false, SilentAim_AliveCheck = true,
    SilentAim_HitPart = "Head",
    SilentAim_DrawFOV = true, SilentAim_FOV_Color = 2,
    
    -- Menu Keybind
    MenuKeybindSlot = 1, -- 1: RightShift, 2: X, 3: Insert, 4: LeftAlt
    
    -- Environment
    UnlockFPS = true, TargetFPS = 240,
    CustomSkybox = false, SkyboxTexture = "rbxassetid://6444884359",
    ForceTimeOfDay = false, TimeOfDay = "14:00:00",
}

local KEYBIND_LOOKUP = {
    [1] = Enum.KeyCode.RightShift,
    [2] = Enum.KeyCode.X,
    [3] = Enum.KeyCode.Insert,
    [4] = Enum.KeyCode.LeftAlt
}

local COLOR_PRESETS = {
    [1] = Color3.fromRGB(255, 255, 255),
    [2] = Color3.fromRGB(0, 230, 255),
    [3] = Color3.fromRGB(255, 60, 60),
    [4] = Color3.fromRGB(60, 255, 100),
    [5] = Color3.fromRGB(255, 80, 220),
    [6] = Color3.fromRGB(255, 220, 60),
}

local OPTION_KEY = {
    AimEnabled = "AimEnabled", AimMaxDistance = "AimMaxDistance",
    CheckTeam = "CheckTeam", CheckVisible = "CheckVisible",
    DrawAimFOV = "DrawAimFOV", AimFOV_Radius = "AimFOV_Radius", AimFOV_Color = "AimFOV_Color",
    
    SilentAim_Enabled = "SilentAim_Enabled", SilentAim_TeamCheck = "SilentAim_TeamCheck",
    SilentAim_VisibleCheck = "SilentAim_VisibleCheck", SilentAim_DrawFOV = "SilentAim_DrawFOV",
    SilentAim_FOV = "SilentAim_FOV", SilentAim_FOV_Color = "SilentAim_FOV_Color",
    
    MasterToggle = "MasterToggle", Box = "Box", CornerBox = "CornerBox",
    BoxFilled = "BoxFilled", BoxOpacity = "BoxOpacity",
    HealthBar = "HealthBar", Name = "Name", Distance = "Distance", Skeleton = "Skeleton",
    Chams = "Chams", MaxDistance = "MaxDistance", Crosshair = "Crosshair",
    Snaplines = "Snaplines", BulletTracers = "BulletTracers",
    
    SpeedHack = "SpeedHack", WalkSpeed = "WalkSpeed", InfiniteJump = "InfiniteJump",
    Fly = "Fly", FlySpeed = "FlySpeed", Noclip = "Noclip", Spinbot = "Spinbot", SpinSpeed = "SpinSpeed",
    AntiFling = "AntiFling", AntiKick = "AntiKick",
    GodMode = "GodMode", AntiRagdoll = "AntiRagdoll", CameraFOV = "CameraFOV",
    NoRecoil = "NoRecoil", NoSpread = "NoSpread", InstantReload = "InstantReload", FullAuto = "FullAuto",
    MenuKeybindSlot = "MenuKeybindSlot"
}

local function applyOption(optName, value)
    local key = OPTION_KEY[optName] or optName
    if Settings[key] ~= nil then
        Settings[key] = value
    end
end

-- =========================================================================
-- OFFSETS API
-- =========================================================================

local Offsets = { LastUpdated = "Fetching..." }
task.spawn(function()
    local ok, res = pcall(function() return game:HttpGet("https://offsets.imtheo.lol/") end)
    if ok and res then
        local decodeOk, data = pcall(function() return HttpService:JSONDecode(res) end)
        if decodeOk and type(data) == "table" then
            for k, v in pairs(data) do Offsets[k] = v end
            Offsets.LastUpdated = os.date("%X")
        end
    end
end)

-- =========================================================================
-- ENVIRONMENT & FFLAGS
-- =========================================================================

local function ApplyEnvironmentSettings()
    if Settings.UnlockFPS then
        if setfpscap then pcall(function() setfpscap(Settings.TargetFPS) end) end
        if setfflag then pcall(function() setfflag("DFIntTaskSchedulerTargetFps", tostring(Settings.TargetFPS)) end) end
    end
    if Settings.CustomSkybox then
        local sky = Lighting:FindFirstChildOfClass("Sky") or Instance.new("Sky", Lighting)
        sky.SkyboxBk = Settings.SkyboxTexture
        sky.SkyboxDn = Settings.SkyboxTexture
        sky.SkyboxFt = Settings.SkyboxTexture
        sky.SkyboxLf = Settings.SkyboxTexture
        sky.SkyboxRt = Settings.SkyboxTexture
        sky.SkyboxUp = Settings.SkyboxTexture
    end
    if Settings.ForceTimeOfDay then
        Lighting.TimeOfDay = Settings.TimeOfDay
    end
end

-- =========================================================================
-- MENU STATE (Dark Grey Theme)
-- =========================================================================

local RGB = Color3.fromRGB
local SCREEN_SIZE = Camera.ViewportSize
local menuWidth, menuHeight = 440, 350

local menu = {
    w = menuWidth, h = menuHeight,
    x = math.floor((SCREEN_SIZE.X / 2) - (menuWidth / 2)),
    y = math.floor((SCREEN_SIZE.Y / 2) - (menuHeight / 2)),
    columns = {
        width = (menuWidth - 40) / 2,
        left = 17,
        right = (menuWidth - 20) / 2 + 13,
    },
    activetab = 1,
    open = true,
    mousedown = false,
    dragging = false,
    dragOffsetX = 0, dragOffsetY = 0,
    postable = {}, options = {},
    clrs = { norm = {}, dark = {}, togz = {} },
    mc = { 255, 255, 255 },
    tabnames = {}, multigroups = {}, mgrouptabz = {},
    tabs = {}, tabz = {}, barguy = nil,
    bbmenu = {}, keybinds = {}, unloaded = false,
    allItems = {},
}

local function Lerp(delta, from, to)
    if delta > 1 then return to end
    if delta < 0 then return from end
    return from + (to - from) * delta
end

local function ColorRange(value, ranges)
    if value <= ranges[1].start then return ranges[1].color end
    if value >= ranges[#ranges].start then return ranges[#ranges].color end
    local selected = #ranges
    for i = 1, #ranges - 1 do
        if value < ranges[i + 1].start then selected = i break end
    end
    local minColor = ranges[selected]
    local maxColor = ranges[selected + 1]
    local lv = (value - minColor.start) / math.max(maxColor.start - minColor.start, 0.0001)
    return Color3.new(
        Lerp(lv, minColor.color.r, maxColor.color.r),
        Lerp(lv, minColor.color.g, maxColor.color.g),
        Lerp(lv, minColor.color.b, maxColor.color.b)
    )
end

-- =========================================================================
-- DRAW HELPERS
-- =========================================================================

local function mkDraw(class, pos, size, clr, filled, thick, trans)
    local d = Drawing.new(class)
    d.Visible = true
    d.Position = pos
    if d.Size ~= nil and size ~= nil then d.Size = size end
    if d.Color ~= nil and clr ~= nil then d.Color = clr end
    if d.Filled ~= nil then d.Filled = filled == true end
    if d.Thickness ~= nil then d.Thickness = thick or 1 end
    if d.Transparency ~= nil then d.Transparency = trans or 1 end
    return d
end

local capturing = false
local function reg(d)
    if capturing then table.insert(menu.allItems, d) end
    return d
end

local function OutlinedRect(visible, x, y, w, h, clr, tab)
    local d = reg(mkDraw("Square", Vector2.new(x + menu.x, y + menu.y), Vector2.new(w, h), RGB(clr[1], clr[2], clr[3]), false, 1, (clr[4] or 255) / 255))
    if tab then table.insert(tab, d) end
    return d
end

local function FilledRect(visible, x, y, w, h, clr, tab)
    local d = reg(mkDraw("Square", Vector2.new(x + menu.x, y + menu.y), Vector2.new(w, h), RGB(clr[1], clr[2], clr[3]), true, 0, (clr[4] or 255) / 255))
    if tab then table.insert(tab, d) end
    return d
end

local function OutlinedText(text, font, visible, x, y, size, centered, clr, clr2, tab)
    local d = reg(mkDraw("Text", Vector2.new(x + menu.x, y + menu.y), nil, RGB(clr[1], clr[2], clr[3]), nil, nil, (clr[4] or 255) / 255))
    d.Text = text
    d.Size = size
    d.Center = centered
    d.Outline = true
    d.OutlineColor = RGB(clr2[1], clr2[2], clr2[3])
    d.Font = font
    if tab then table.insert(tab, d) end
    return d
end

local function AbsFilled(x, y, w, h, clr, tab)
    local d = reg(mkDraw("Square", Vector2.new(x, y), Vector2.new(w, h), RGB(clr[1], clr[2], clr[3]), true, 0, (clr[4] or 255) / 255))
    if tab then table.insert(tab, d) end
    return d
end

local function AbsOutlined(x, y, w, h, clr, tab)
    local d = reg(mkDraw("Square", Vector2.new(x, y), Vector2.new(w, h), RGB(clr[1], clr[2], clr[3]), false, 1, (clr[4] or 255) / 255))
    if tab then table.insert(tab, d) end
    return d
end

local function shiftAllItems(dx, dy)
    for _, d in ipairs(menu.allItems) do
        pcall(function()
            local p = d.Position
            d.Position = Vector2.new(p.X + dx, p.Y + dy)
        end)
    end
end

-- =========================================================================
-- BUILD MENU
-- =========================================================================

function drawCoolBox(name, x, y, w, h, tab)
    OutlinedRect(true, x, y, w, h, {15,15,18,255}, tab)
    OutlinedRect(true, x + 1, y + 1, w - 2, h - 2, {40,40,46,255}, tab)
    OutlinedRect(true, x + 2, y + 2, w - 3, 1, {255,255,255,255}, tab)
    OutlinedRect(true, x + 2, y + 3, w - 3, 1, {160,160,160,255}, tab)
    OutlinedRect(true, x + 2, y + 4, w - 3, 1, {30,30,35,255}, tab)
    for i = 0, 7 do
        local d = FilledRect(true, x + 2, y + 5 + (i * 2), w - 4, 2, {30,30,35,255}, tab)
        d.Color = ColorRange(i, {
            [1] = { start = 0, color = RGB(45,45,52) },
            [2] = { start = 7, color = RGB(28,28,33) },
        })
    end
    return OutlinedText(name, 2, true, x + 6, y + 5, 13, false, {255,255,255,255}, {0,0,0}, tab)
end

function drawToggle(name, value, x, y, tab)
    OutlinedRect(true, x, y, 12, 12, {50,50,58,255}, tab)
    OutlinedRect(true, x + 1, y + 1, 10, 10, {20,20,24,255}, tab)
    local tt = {}
    for i = 0, 3 do
        local d = FilledRect(true, x + 2, y + 2 + (i * 2), 8, 2, {20,20,24,255}, tab)
        table.insert(tt, d)
        if value then
            d.Color = ColorRange(i, {
                [1] = { start = 0, color = RGB(255,255,255) },
                [2] = { start = 3, color = RGB(215,215,215) },
            })
        else
            d.Color = ColorRange(i, {
                [1] = { start = 0, color = RGB(55,55,62) },
                [2] = { start = 3, color = RGB(32,32,38) },
            })
        end
    end
    tt.label = OutlinedText(name, 2, true, x + 16, y - 1, 13, false, {255,255,255,255}, {0,0,0}, tab)
    table.insert(tt, tt.label)
    return tt
end

function drawSlider(name, stradd, value, minv, maxv, custom, decimal, x, y, length, tab)
    OutlinedText(name, 2, true, x, y - 3, 13, false, {255,255,255,255}, {0,0,0}, tab)
    for i = 0, 3 do
        local d = FilledRect(true, x + 2, y + 14 + (i * 2), length - 4, 2, {20,20,24,255}, tab)
        d.Color = ColorRange(i, {
            [1] = { start = 0, color = RGB(55,55,62) },
            [2] = { start = 3, color = RGB(32,32,38) },
        })
    end
    local tt = {}
    local pct = (value - minv) / math.max(maxv - minv, 0.0001)
    for i = 0, 3 do
        local d = FilledRect(true, x + 2, y + 14 + (i * 2), (length - 4) * pct, 2, {20,20,24,255}, tab)
        table.insert(tt, d)
        d.Color = ColorRange(i, {
            [1] = { start = 0, color = RGB(255,255,255) },
            [2] = { start = 3, color = RGB(215,215,215) },
        })
    end
    OutlinedRect(true, x, y + 12, length, 12, {50,50,58,255}, tab)
    OutlinedRect(true, x + 1, y + 13, length - 2, 10, {20,20,24,255}, tab)
    if stradd == nil then stradd = "" end
    tt.valueText = OutlinedText((custom and custom[value]) or (tostring(value) .. stradd),
        2, true, x + (length * 0.5), y + 11, 13, true, {255,255,255,255}, {0,0,0}, tab)
    table.insert(tt, tt.valueText)
    tt.stradd = stradd
    return tt
end

local function BuildMenu(menutable)
    capturing = true

    menu.allItems = {}
    menu.bbmenu = {}
    menu.tabs = {}
    menu.tabnames = {}
    menu.tabz = {}
    menu.postable = {}
    menu.options = {}

    AbsFilled(menu.x, menu.y, menu.w, menu.h, {32,32,36,255}, menu.bbmenu)
    AbsOutlined(menu.x, menu.y, menu.w, menu.h, {15,15,18,255}, menu.bbmenu)
    AbsOutlined(menu.x+1, menu.y+1, menu.w-2, menu.h-2, {55,55,62,255}, menu.bbmenu)
    AbsOutlined(menu.x+2, menu.y+2, menu.w-3, 1, {255,255,255,255}, menu.bbmenu)
    AbsOutlined(menu.x+2, menu.y+3, menu.w-3, 1, {180,180,180,255}, menu.bbmenu)
    AbsOutlined(menu.x+2, menu.y+4, menu.w-3, 1, {28,28,32,255}, menu.bbmenu)

    for i = 0, 19 do
        local d = AbsFilled(menu.x + 2, menu.y + 5 + i, menu.w - 4, 1, {32,32,36,255}, menu.bbmenu)
        d.Color = ColorRange(i, {
            [1] = { start = 0, color = RGB(50,50,58) },
            [2] = { start = 20, color = RGB(32,32,36) },
        })
    end
    AbsFilled(menu.x + 2, menu.y + 25, menu.w - 4, menu.h - 27, {28,28,32,255}, menu.bbmenu)

    local brandText = Drawing.new("Text")
    brandText.Visible = true
    brandText.Position = Vector2.new(menu.x + 6, menu.y + 6)
    brandText.Text = "ruin.lol"
    brandText.Size = 13
    brandText.Center = false
    brandText.Outline = true
    brandText.Font = 2
    brandText.Color = RGB(255,255,255)
    table.insert(menu.bbmenu, brandText)
    table.insert(menu.allItems, brandText)

    AbsOutlined(menu.x + 8, menu.y + 22, menu.w - 16, menu.h - 30, {15,15,18,255}, menu.bbmenu)
    AbsOutlined(menu.x + 9, menu.y + 23, menu.w - 18, menu.h - 32, {45,45,50,255}, menu.bbmenu)

    for i = 0, 14 do
        local d = AbsFilled(menu.x + 10, menu.y + 27 + (i * 2), menu.w - 20, 2, {24,24,28,255}, menu.bbmenu)
        d.Color = ColorRange(i, {
            [1] = { start = 0, color = RGB(42,42,48) },
            [2] = { start = 15, color = RGB(24,24,28) },
        })
    end
    AbsFilled(menu.x + 10, menu.y + 57, menu.w - 20, menu.h - 67, {24,24,28,255}, menu.bbmenu)

    for i = 1, #menutable do menu.tabz[i] = {} end
    local tabW = (menu.w - 20) / #menutable

    for k, v in pairs(menutable) do
        local tx = menu.x + 10 + ((k - 1) * tabW)
        AbsFilled(tx, menu.y + 27, tabW, 32, {36,36,42,255}, menu.bbmenu)
        AbsOutlined(tx, menu.y + 27, tabW, 32, {15,15,18,255}, menu.bbmenu)
        local txt = Drawing.new("Text")
        txt.Visible = true
        txt.Position = Vector2.new(tx + (tabW * 0.5), menu.y + 35)
        txt.Text = v.name
        txt.Size = 13
        txt.Center = true
        txt.Outline = true
        txt.Font = 2
        txt.Color = RGB(170,170,170)
        table.insert(menu.bbmenu, txt)
        table.insert(menu.allItems, txt)

        table.insert(menu.tabs, { txt, tx })
        table.insert(menu.tabnames, v.name)

        menu.options[v.name] = {}
        local y_offies = { left = 66, right = 66 }

        if v.content ~= nil then
            for _, v1 in pairs(v.content) do
                if v1.autopos ~= nil then
                    v1.width = menu.columns.width
                    if v1.autopos == "left" then v1.x = menu.columns.left; v1.y = y_offies.left
                    elseif v1.autopos == "right" then v1.x = menu.columns.right; v1.y = y_offies.right end
                end

                local groups = {}
                if type(v1.name) == "table" then groups = v1.name
                else table.insert(groups, v1.name) end

                local y_pos = 24
                for g_ind, g_name in ipairs(groups) do
                    menu.options[v.name][g_name] = {}
                    local content = (type(v1.name) == "table") and (v1[g_ind] and v1[g_ind].content) or v1.content

                    if content ~= nil then
                        for _, v2 in pairs(content) do
                            if v2.type == "toggle" then
                                menu.options[v.name][g_name][v2.name] = {}
                                local btn = drawToggle(v2.name, v2.value, v1.x + 8, v1.y + y_pos, menu.tabz[k])
                                menu.options[v.name][g_name][v2.name][4] = btn
                                menu.options[v.name][g_name][v2.name][1] = v2.value
                                menu.options[v.name][g_name][v2.name][2] = "toggle"
                                menu.options[v.name][g_name][v2.name][3] = { v1.x + 7, v1.y + y_pos - 1 }
                                menu.options[v.name][g_name][v2.name].optName = v2.name
                                y_pos = y_pos + 18
                            elseif v2.type == "slider" then
                                menu.options[v.name][g_name][v2.name] = {}
                                local btn = drawSlider(v2.name, v2.stradd, v2.value,
                                    v2.minvalue, v2.maxvalue, v2.custom or {}, v2.decimal,
                                    v1.x + 8, v1.y + y_pos, v1.width - 16, menu.tabz[k])
                                menu.options[v.name][g_name][v2.name][4] = btn
                                menu.options[v.name][g_name][v2.name][1] = v2.value
                                menu.options[v.name][g_name][v2.name][2] = "slider"
                                menu.options[v.name][g_name][v2.name][3] = { v1.x + 7, v1.y + y_pos - 1, v1.width - 16 }
                                menu.options[v.name][g_name][v2.name][5] = false
                                menu.options[v.name][g_name][v2.name][6] = { v2.minvalue, v2.maxvalue }
                                menu.options[v.name][g_name][v2.name].decimal = v2.decimal
                                menu.options[v.name][g_name][v2.name].custom = v2.custom or {}
                                menu.options[v.name][g_name][v2.name].optName = v2.name
                                menu.options[v.name][g_name][v2.name].stradd = v2.stradd or ""
                                y_pos = y_pos + 30
                            end
                        end
                    end
                end

                y_pos = y_pos + 2
                if type(v1.name) ~= "table" and v1.autopos ~= nil then
                    if v1.autofill then y_pos = (menu.h - 17) - v1.y
                    elseif v1.size ~= nil then y_pos = v1.size end
                    drawCoolBox(v1.name, v1.x, v1.y, v1.width, y_pos, menu.tabz[k])
                    y_offies[v1.autopos] = y_offies[v1.autopos] + y_pos + 6
                end
            end
        end
    end

    AbsOutlined(menu.x + 10, menu.y + 59, menu.w - 20, menu.h - 69, {40,40,46,255}, menu.bbmenu)
    menu.barguy = AbsOutlined(menu.x + 11, menu.y + 58, tabW - 2, 2, {255,255,255,255}, menu.bbmenu)

    capturing = false
end

-- =========================================================================
-- BUILD SCHEMA WITH FOV CIRCLES & KEYBIND CONTROLS
-- =========================================================================

BuildMenu({
    {
        name = "Combat",
        content = {
            {
                name = "Aimbot", autopos = "left", autofill = true,
                content = {
                    { type = "toggle", name = "AimEnabled", value = Settings.AimEnabled },
                    { type = "slider", name = "AimMaxDistance", value = Settings.AimMaxDistance, minvalue = 20, maxvalue = 500 },
                    { type = "toggle", name = "DrawAimFOV", value = Settings.DrawAimFOV },
                    { type = "slider", name = "AimFOV_Radius", value = Settings.AimFOV_Radius, minvalue = 20, maxvalue = 500 },
                    { type = "slider", name = "AimFOV_Color", value = Settings.AimFOV_Color, minvalue = 1, maxvalue = 6, custom = {[1]="White",[2]="Cyan",[3]="Red",[4]="Green",[5]="Pink",[6]="Yellow"} },
                },
            },
            {
                name = "Silent Aim", autopos = "right", autofill = true,
                content = {
                    { type = "toggle", name = "SilentAim_Enabled", value = Settings.SilentAim_Enabled },
                    { type = "toggle", name = "SilentAim_DrawFOV", value = Settings.SilentAim_DrawFOV },
                    { type = "slider", name = "SilentAim_FOV", value = Settings.SilentAim_FOV, minvalue = 20, maxvalue = 500 },
                    { type = "slider", name = "SilentAim_FOV_Color", value = Settings.SilentAim_FOV_Color, minvalue = 1, maxvalue = 6, custom = {[1]="White",[2]="Cyan",[3]="Red",[4]="Green",[5]="Pink",[6]="Yellow"} },
                },
            },
        },
    },
    {
        name = "Visuals",
        content = {
            {
                name = "ESP", autopos = "left", autofill = true,
                content = {
                    { type = "toggle", name = "MasterToggle", value = Settings.MasterToggle },
                    { type = "toggle", name = "Box", value = Settings.Box },
                    { type = "toggle", name = "CornerBox", value = Settings.CornerBox },
                    { type = "toggle", name = "BoxFilled", value = Settings.BoxFilled },
                    { type = "slider", name = "BoxOpacity", value = Settings.BoxOpacity, minvalue = 0, maxvalue = 100, stradd = "%" },
                    { type = "toggle", name = "HealthBar", value = Settings.HealthBar },
                    { type = "toggle", name = "Name", value = Settings.Name },
                    { type = "toggle", name = "Distance", value = Settings.Distance },
                    { type = "toggle", name = "Skeleton", value = Settings.Skeleton },
                    { type = "slider", name = "MaxDistance", value = Settings.MaxDistance, minvalue = 100, maxvalue = 5000 },
                },
            },
            {
                name = "Render", autopos = "right", autofill = true,
                content = {
                    { type = "toggle", name = "Crosshair", value = Settings.Crosshair },
                    { type = "toggle", name = "Snaplines", value = Settings.Snaplines },
                    { type = "toggle", name = "BulletTracers", value = Settings.BulletTracers },
                },
            },
        },
    },
    {
        name = "Player",
        content = {
            {
                name = "Movement", autopos = "left", autofill = true,
                content = {
                    { type = "toggle", name = "SpeedHack", value = Settings.SpeedHack },
                    { type = "slider", name = "WalkSpeed", value = Settings.WalkSpeed, minvalue = 16, maxvalue = 250 },
                    { type = "toggle", name = "InfiniteJump", value = Settings.InfiniteJump },
                    { type = "toggle", name = "Fly", value = Settings.Fly },
                    { type = "slider", name = "FlySpeed", value = Settings.FlySpeed, minvalue = 50, maxvalue = 300 },
                    { type = "toggle", name = "Noclip", value = Settings.Noclip },
                    { type = "toggle", name = "Spinbot", value = Settings.Spinbot },
                    { type = "slider", name = "SpinSpeed", value = Settings.SpinSpeed, minvalue = 10, maxvalue = 100 },
                },
            },
            {
                name = "Character", autopos = "right", autofill = true,
                content = {
                    { type = "toggle", name = "GodMode", value = Settings.GodMode },
                    { type = "toggle", name = "AntiRagdoll", value = Settings.AntiRagdoll },
                    { type = "toggle", name = "AntiFling", value = Settings.AntiFling },
                    { type = "slider", name = "CameraFOV", value = Settings.CameraFOV, minvalue = 70, maxvalue = 120 },
                },
            },
        },
    },
    {
        name = "Settings",
        content = {
            {
                name = "Weapon Mods", autopos = "left", autofill = true,
                content = {
                    { type = "toggle", name = "NoRecoil", value = Settings.NoRecoil },
                    { type = "toggle", name = "NoSpread", value = Settings.NoSpread },
                    { type = "toggle", name = "InstantReload", value = Settings.InstantReload },
                    { type = "toggle", name = "FullAuto", value = Settings.FullAuto },
                },
            },
            {
                name = "Environment & Menu", autopos = "right", autofill = true,
                content = {
                    { type = "slider", name = "MenuKeybindSlot", value = Settings.MenuKeybindSlot, minvalue = 1, maxvalue = 4, custom = {[1]="R-Shift",[2]="X",[3]="Insert",[4]="L-Alt"} },
                    { type = "toggle", name = "UnlockFPS", value = Settings.UnlockFPS },
                    { type = "slider", name = "TargetFPS", value = Settings.TargetFPS, minvalue = 60, maxvalue = 360 },
                    { type = "toggle", name = "CustomSkybox", value = Settings.CustomSkybox },
                    { type = "toggle", name = "ForceTimeOfDay", value = Settings.ForceTimeOfDay },
                },
            },
        },
    },
})

-- =========================================================================
-- TAB SWITCHING & VISIBILITY CONTROLLER
-- =========================================================================

local function setActiveTab(slot)
    menu.activetab = slot
    local tabW = (menu.w - 20) / math.max(#menu.tabnames, 1)
    if menu.barguy then
        menu.barguy.Position = Vector2.new(
            menu.x + 11 + ((tabW - 2) * (slot - 1)) + ((slot - 1) * 2),
            menu.y + 58
        )
        menu.barguy.Size = Vector2.new(tabW - 2, 2)
    end
    for k, v in pairs(menu.tabs) do
        if v[1] then
            v[1].Color = (k == slot) and RGB(255,255,255) or RGB(170,170,170)
        end
    end
    for k, v in pairs(menu.tabz) do
        for _, d in pairs(v) do
            if d and d.Visible ~= nil then
                d.Visible = (k == slot) and menu.open
            end
        end
    end
end

setActiveTab(menu.activetab)

local function MouseInMenu(x, y, w, h)
    local m = UserInputService:GetMouseLocation()
    local mx, my = m.X, m.Y
    return mx >= menu.x + x and mx <= menu.x + x + w
       and my >= menu.y + y and my <= menu.y + y + h
end

-- =========================================================================
-- FOV CIRCLES DRAWING
-- =========================================================================

local AimFOVCircle = Drawing.new("Circle")
AimFOVCircle.Thickness = 1
AimFOVCircle.NumSides = 64
AimFOVCircle.Filled = false
AimFOVCircle.Visible = false

local SilentAimFOVCircle = Drawing.new("Circle")
SilentAimFOVCircle.Thickness = 1
SilentAimFOVCircle.NumSides = 64
SilentAimFOVCircle.Filled = false
SilentAimFOVCircle.Visible = false

-- =========================================================================
-- INPUT CONTROLLER
-- =========================================================================

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end

    local activeMenuKey = KEYBIND_LOOKUP[Settings.MenuKeybindSlot] or Enum.KeyCode.RightShift
    if input.KeyCode == activeMenuKey then
        menu.open = not menu.open
        for _, d in ipairs(menu.allItems) do
            pcall(function() d.Visible = menu.open end)
        end
        if menu.open then
            setActiveTab(menu.activetab)
        end
        return
    end

    if input.UserInputType ~= Enum.UserInputType.MouseButton1
    and input.UserInputType ~= Enum.UserInputType.Touch then
        return
    end

    if not menu.open then return end
    local m = UserInputService:GetMouseLocation()

    if m.X >= menu.x and m.X <= menu.x + menu.w
    and m.Y >= menu.y and m.Y <= menu.y + 25 then
        menu.dragging = true
        menu.dragOffsetX = m.X - menu.x
        menu.dragOffsetY = m.Y - menu.y
        return
    end

    local tabW = (menu.w - 20) / math.max(#menu.tabnames, 1)
    for i = 1, #menu.tabnames do
        if MouseInMenu(10 + ((i - 1) * tabW), 27, tabW, 32) then
            setActiveTab(i)
            return
        end
    end

    for k, v in pairs(menu.options) do
        if menu.tabnames[menu.activetab] == k then
            for _, v1 in pairs(v) do
                for _, v2 in pairs(v1) do
                    if v2[2] == "toggle" then
                        if MouseInMenu(v2[3][1], v2[3][2], 30 + (v2[4].label.TextBounds.X or 0), 16) then
                            v2[1] = not v2[1]
                            applyOption(v2.optName, v2[1])
                            ApplyEnvironmentSettings()
                            for i = 0, 3 do
                                if v2[1] then
                                    v2[4][i + 1].Color = ColorRange(i, {
                                        [1] = { start = 0, color = RGB(255,255,255) },
                                        [2] = { start = 3, color = RGB(215,215,215) },
                                    })
                                else
                                    v2[4][i + 1].Color = ColorRange(i, {
                                        [1] = { start = 0, color = RGB(55,55,62) },
                                        [2] = { start = 3, color = RGB(32,32,38) },
                                    })
                                end
                            end
                        end
                    elseif v2[2] == "slider" then
                        if MouseInMenu(v2[3][1], v2[3][2], v2[3][3], 28) then
                            v2[5] = true
                        end
                    end
                end
            end
        end
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType ~= Enum.UserInputType.MouseMovement
    and input.UserInputType ~= Enum.UserInputType.Touch then
        return
    end

    local m = UserInputService:GetMouseLocation()

    if menu.dragging then
        local newX = m.X - menu.dragOffsetX
        local newY = m.Y - menu.dragOffsetY
        local dx = newX - menu.x
        local dy = newY - menu.y
        menu.x = newX
        menu.y = newY
        shiftAllItems(dx, dy)
        return
    end

    if menu.open then
        for k, v in pairs(menu.options) do
            if menu.tabnames[menu.activetab] == k then
                for _, v1 in pairs(v) do
                    for _, v2 in pairs(v1) do
                        if v2[2] == "slider" and v2[5] then
                            local minv, maxv = v2[6][1], v2[6][2]
                            local relX = math.clamp(m.X - (menu.x + v2[3][1]), 0, v2[3][3])
                            local pct = relX / v2[3][3]
                            local new_val = minv + (pct * (maxv - minv))
                            v2[1] = (not v2.decimal and math.floor(new_val)
                                or math.floor(new_val / v2.decimal) * v2.decimal)
                            if v2[1] < minv then v2[1] = minv
                            elseif v2[1] > maxv then v2[1] = maxv end
                            v2[4].valueText.Text = (v2.custom and v2.custom[v2[1]])
                                or (tostring(v2[1]) .. (v2.stradd or ""))
                            for i = 1, 4 do
                                v2[4][i].Size = Vector2.new((v2[3][3] - 4) * pct, 2)
                            end
                            applyOption(v2.optName, v2[1])
                            ApplyEnvironmentSettings()
                        end
                    end
                end
            end
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        menu.mousedown = false
        menu.dragging = false
        for k, v in pairs(menu.options) do
            if menu.tabnames[menu.activetab] == k then
                for _, v1 in pairs(v) do
                    for _, v2 in pairs(v1) do
                        if v2[2] == "slider" and v2[5] then
                            v2[5] = false
                            applyOption(v2.optName, v2[1])
                            ApplyEnvironmentSettings()
                        end
                    end
                end
            end
        end
    end
end)

-- =========================================================================
-- FIXED ESP ENGINE
-- =========================================================================

local ESPCache = {}
local BoneRig = {
    {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
    {"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},
    {"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"},
    {"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
    {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"}
}

local function mkdraw(class, clr, filled)
    local ok, d = pcall(function() return Drawing.new(class) end)
    if not ok or not d then return nil end
    d.Visible = false
    d.Transparency = 1
    if d.Color then d.Color = clr or Color3.new(1,1,1) end
    if d.Filled ~= nil then d.Filled = filled and true or false end
    return d
end

local function CreateESP(player)
    if player == LocalPlayer or ESPCache[player] then return end
    local obj = {
        BoxFill    = mkdraw("Square", Color3.fromRGB(255,255,255), true),
        Box        = mkdraw("Square", Color3.fromRGB(255,255,255), false),
        HBBack     = mkdraw("Square", Color3.fromRGB(0,0,0), true),
        HB         = mkdraw("Square", Color3.fromRGB(80,220,100), true),
        Name       = mkdraw("Text", Color3.fromRGB(255,255,255)),
        Dist       = mkdraw("Text", Color3.fromRGB(200,200,200)),
        Snap       = mkdraw("Line", Color3.fromRGB(255,255,255)),
        Corners    = {},
        Skel       = {},
    }
    if obj.Box then obj.Box.Thickness = 1 end
    if obj.Name then obj.Name.Size = 13; obj.Name.Center = true; obj.Name.Outline = true; obj.Name.Font = 2 end
    if obj.Dist then obj.Dist.Size = 11; obj.Dist.Center = true; obj.Dist.Outline = true; obj.Dist.Font = 2 end
    if obj.Snap then obj.Snap.Thickness = 1 end
    
    for i = 1, 8 do
        local c = mkdraw("Line", Color3.fromRGB(255,255,255))
        if c then c.Thickness = 1 end
        table.insert(obj.Corners, c)
    end
    
    for _ = 1, #BoneRig do
        local l = mkdraw("Line", Color3.fromRGB(255,255,255))
        if l then l.Thickness = 1 end
        table.insert(obj.Skel, l)
    end
    ESPCache[player] = obj
end

local function HideESP(d)
    if d.BoxFill then d.BoxFill.Visible = false end
    if d.Box then d.Box.Visible = false end
    if d.HBBack then d.HBBack.Visible = false end
    if d.HB then d.HB.Visible = false end
    if d.Name then d.Name.Visible = false end
    if d.Dist then d.Dist.Visible = false end
    if d.Snap then d.Snap.Visible = false end
    for _, c in ipairs(d.Corners) do if c then c.Visible = false end end
    for _, l in ipairs(d.Skel) do if l then l.Visible = false end end
end

Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(function(p)
    local d = ESPCache[p]
    if not d then return end
    HideESP(d)
    for _, v in pairs(d) do
        if type(v) == "table" then
            for _, l in ipairs(v) do pcall(function() if l then l:Remove() end end) end
        elseif v and v.Remove then pcall(function() v:Remove() end) end
    end
    ESPCache[p] = nil
end)
for _, p in ipairs(Players:GetPlayers()) do CreateESP(p) end

-- =========================================================================
-- AIMBOT & MOVEMENT RENDER PIPELINES
-- =========================================================================

local aimTarget, aiming = nil, false

local function AimValid(player)
    if not player or not player.Character or player == LocalPlayer then return false end
    local char = player.Character
    local part = char:FindFirstChild(Settings.AimPart)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not part or not hum then return false end
    if Settings.CheckAlive and hum.Health <= 0 then return false end
    if Settings.CheckKnocked and hum.Health < 18 then return false end
    if Settings.CheckTeam and LocalPlayer.Team and player.Team == LocalPlayer.Team then return false end
    if (part.Position - Camera.CFrame.Position).Magnitude > Settings.AimMaxDistance then return false end
    return true
end

local function PickAimTarget()
    local mouse = UserInputService:GetMouseLocation()
    local best, bestDist = nil, math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if AimValid(player) then
            local part = player.Character[Settings.AimPart]
            local sp, on = Camera:WorldToScreenPoint(part.Position)
            if on then
                local d = (Vector2.new(sp.X, sp.Y) - mouse).Magnitude
                if d < bestDist then bestDist = d best = player end
            end
        end
    end
    return best
end

UserInputService.InputBegan:Connect(function(input, gp)
    if gp or not Settings.AimEnabled then return end
    if input.KeyCode == Settings.AimKey then
        if Settings.ToggleMode then
            aiming = not aiming
            if not aiming then aimTarget = nil end
        else
            aiming = true
        end
    end
end)

UserInputService.InputEnded:Connect(function(input, gp)
    if gp or not Settings.AimEnabled then return end
    if input.KeyCode == Settings.AimKey and not Settings.ToggleMode then
        aiming = false
        aimTarget = nil
    end
end)

RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")

    if hum then
        if Settings.SpeedHack then hum.WalkSpeed = Settings.WalkSpeed end
        if Settings.Fly and hrp then
            hum.PlatformStand = true
            local dir = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
            hrp.Velocity = dir.Magnitude > 0 and dir.Unit * Settings.FlySpeed or Vector3.new()
        end
        if Settings.Spinbot and hrp then
            hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(Settings.SpinSpeed), 0)
        end
        if Settings.AntiFling and hrp then
            if hrp.AssemblyLinearVelocity.Magnitude > 250 then
                hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
            end
        end
    end
    if Settings.Noclip and char then
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if Settings.InfiniteJump and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

RunService.RenderStepped:Connect(function(dt)
    SCREEN_SIZE = Camera.ViewportSize
    Camera.FieldOfView = Settings.CameraFOV

    local mLoc = UserInputService:GetMouseLocation()

    -- Render Aimbot FOV Circle
    if Settings.DrawAimFOV then
        AimFOVCircle.Position = mLoc
        AimFOVCircle.Radius = Settings.AimFOV_Radius
        AimFOVCircle.Color = COLOR_PRESETS[Settings.AimFOV_Color] or Color3.new(1,1,1)
        AimFOVCircle.Visible = true
    else
        AimFOVCircle.Visible = false
    end

    -- Render Silent Aim FOV Circle
    if Settings.SilentAim_DrawFOV then
        SilentAimFOVCircle.Position = mLoc
        SilentAimFOVCircle.Radius = Settings.SilentAim_FOV
        SilentAimFOVCircle.Color = COLOR_PRESETS[Settings.SilentAim_FOV_Color] or Color3.new(0,1,1)
        SilentAimFOVCircle.Visible = true
    else
        SilentAimFOVCircle.Visible = false
    end

    for player, data in pairs(ESPCache) do
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        
        if not Settings.MasterToggle or not char or not hrp or not hum or hum.Health <= 0 then
            HideESP(data)
        else
            local mate = Settings.TeamCheck and LocalPlayer.Team and player.Team == LocalPlayer.Team
            local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
            if mate or dist > Settings.MaxDistance then
                HideESP(data)
            else
                local head = char:FindFirstChild("Head")
                local headPos = head and head.Position or (hrp.Position + Vector3.new(0, 2, 0))
                local topPos = Camera:WorldToViewportPoint(headPos + Vector3.new(0, 0.6, 0))
                local botPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3.2, 0))

                if not topPos.Z or topPos.Z <= 0 then
                    HideESP(data)
                else
                    local h = math.abs(botPos.Y - topPos.Y)
                    local w = h * 0.65
                    local bx = topPos.X - (w / 2)
                    local by = topPos.Y

                    -- Filled Box
                    if Settings.Box and Settings.BoxFilled and data.BoxFill then
                        data.BoxFill.Size = Vector2.new(w, h)
                        data.BoxFill.Position = Vector2.new(bx, by)
                        data.BoxFill.Transparency = Settings.BoxOpacity / 100
                        data.BoxFill.Color = Color3.fromRGB(255, 255, 255)
                        data.BoxFill.Visible = true
                    elseif data.BoxFill then
                        data.BoxFill.Visible = false
                    end

                    -- Full Box vs Cornered Box
                    if Settings.Box then
                        if Settings.CornerBox then
                            if data.Box then data.Box.Visible = false end
                            local cornerLen = w * 0.25
                            local c = data.Corners
                            
                            c[1].From = Vector2.new(bx, by); c[1].To = Vector2.new(bx + cornerLen, by); c[1].Visible = true
                            c[2].From = Vector2.new(bx, by); c[2].To = Vector2.new(bx, by + cornerLen); c[2].Visible = true
                            c[3].From = Vector2.new(bx + w, by); c[3].To = Vector2.new(bx + w - cornerLen, by); c[3].Visible = true
                            c[4].From = Vector2.new(bx + w, by); c[4].To = Vector2.new(bx + w, by + cornerLen); c[4].Visible = true
                            c[5].From = Vector2.new(bx, by + h); c[5].To = Vector2.new(bx + cornerLen, by + h); c[5].Visible = true
                            c[6].From = Vector2.new(bx, by + h); c[6].To = Vector2.new(bx, by + h - cornerLen); c[6].Visible = true
                            c[7].From = Vector2.new(bx + w, by + h); c[7].To = Vector2.new(bx + w - cornerLen, by + h); c[7].Visible = true
                            c[8].From = Vector2.new(bx + w, by + h); c[8].To = Vector2.new(bx + w, by + h - cornerLen); c[8].Visible = true
                        else
                            for _, cn in ipairs(data.Corners) do cn.Visible = false end
                            if data.Box then
                                data.Box.Size = Vector2.new(w, h)
                                data.Box.Position = Vector2.new(bx, by)
                                data.Box.Visible = true
                            end
                        end
                    else
                        if data.Box then data.Box.Visible = false end
                        for _, cn in ipairs(data.Corners) do cn.Visible = false end
                    end

                    -- HealthBar
                    if Settings.HealthBar and data.HB and data.HBBack then
                        local pct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                        data.HBBack.Size = Vector2.new(3, h)
                        data.HBBack.Position = Vector2.new(bx - 6, by)
                        data.HBBack.Visible = true

                        data.HB.Size = Vector2.new(3, h * pct)
                        data.HB.Position = Vector2.new(bx - 6, by + (h * (1 - pct)))
                        data.HB.Color = Color3.fromRGB(255 - (pct * 175), pct * 220, 80)
                        data.HB.Visible = true
                    elseif data.HB then
                        data.HBBack.Visible = false
                        data.HB.Visible = false
                    end

                    -- Name
                    if Settings.Name and data.Name then
                        data.Name.Position = Vector2.new(topPos.X, by - 16)
                        data.Name.Text = player.Name
                        data.Name.Visible = true
                    elseif data.Name then data.Name.Visible = false end

                    -- Distance
                    if Settings.Distance and data.Dist then
                        data.Dist.Position = Vector2.new(topPos.X, by + h + 4)
                        data.Dist.Text = string.format("%dm", math.floor(dist))
                        data.Dist.Visible = true
                    elseif data.Distance then data.Dist.Visible = false end

                    -- Snaplines
                    if Settings.Snaplines and data.Snap then
                        data.Snap.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                        data.Snap.To = Vector2.new(topPos.X, topPos.Y)
                        data.Snap.Visible = true
                    elseif data.Snap then data.Snap.Visible = false end

                    -- Skeleton
                    if Settings.Skeleton then
                        for i, pair in ipairs(BoneRig) do
                            local pA, pB = char:FindFirstChild(pair[1]), char:FindFirstChild(pair[2])
                            if pA and pB and data.Skel[i] then
                                local a, va = Camera:WorldToViewportPoint(pA.Position)
                                local b, vb = Camera:WorldToViewportPoint(pB.Position)
                                if va and vb then
                                    data.Skel[i].From = Vector2.new(a.X, a.Y)
                                    data.Skel[i].To = Vector2.new(b.X, b.Y)
                                    data.Skel[i].Visible = true
                                else data.Skel[i].Visible = false end
                            elseif data.Skel[i] then data.Skel[i].Visible = false end
                        end
                    else
                        for _, l in ipairs(data.Skel) do if l then l.Visible = false end end
                    end
                end
            end
        end
    end

    if Settings.AimEnabled and aiming then
        if not aimTarget or not AimValid(aimTarget) then aimTarget = PickAimTarget() end
        if aimTarget then
            local part = aimTarget.Character[Settings.AimPart]
            local pos = part.Position
            local hum = aimTarget.Character:FindFirstChildOfClass("Humanoid")
            local airborne = hum and (hum:GetState() == Enum.HumanoidStateType.Freefall
                or hum:GetState() == Enum.HumanoidStateType.Jumping)
            local pred = airborne and Settings.PredictionAir or Settings.PredictionBase
            pos = pos + (part.AssemblyLinearVelocity * pred)
            local goal = CFrame.new(Camera.CFrame.Position, pos)
            if Settings.SmoothingEnabled then
                local alpha = math.clamp(0.5 * dt * 60, Settings.SmoothingMin, Settings.SmoothingMax)
                Camera.CFrame = Camera.CFrame:Lerp(goal, alpha)
            else
                Camera.CFrame = goal
            end
        end
    end
end)
