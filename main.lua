-- =========================================================================
-- ruin.lol | Compact Edition | Drawing Image
-- =========================================================================

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService      = game:GetService("HttpService")
local Lighting         = game:GetService("Lighting")
local CoreGui          = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera      = workspace.CurrentCamera

-- =========================================================================
-- SETTINGS
-- =========================================================================

local Settings = {
    MasterToggle = false, TeamCheck = false, MaxDistance = 1000,
    Box = false, CornerBox = false, BoxFilled = false, BoxOpacity = 35,
    HealthBar = false, Name = false, Distance = false, Skeleton = false,
    Snaplines = false, Chams = false, Crosshair = false, BulletTracers = false,

    SpeedHack = false, WalkSpeed = 60,
    InfiniteJump = false, Noclip = false, Fly = false, FlySpeed = 50,
    GodMode = false, AntiRagdoll = false, CameraFOV = 90, Spinbot = false, SpinSpeed = 30,
    AntiFling = false, AntiKick = false,
    NoRecoil = false, NoSpread = false, InstantReload = false, FullAuto = false,

    AimEnabled = false,
    AimKeySlot = 1,
    AimMode = 1,
    AimMaxDistance = 500,
    AimHitPart = "Head",
    AimVisibleCheck = false,
    AimUseFOV = false,
    AimFOV_Radius = 120,
    AimFOV_Color = 1,
    DrawAimFOV = false,
    AimSmoothing = 0.35,
    AimPrediction = 0.12,
    AimAirPrediction = 0.05,

    CombatImage = true,
    MenuKeybindSlot = 1,
    UnlockFPS = false, TargetFPS = 240,
    CustomSkybox = false, SkyboxTexture = "rbxassetid://6444884359",
    ForceTimeOfDay = false, TimeOfDay = 14,

    PresetName = "default",
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

local KEY_PRESETS = {
    [1] = Enum.KeyCode.Z, [2] = Enum.KeyCode.C, [3] = Enum.KeyCode.V,
    [4] = Enum.KeyCode.F, [5] = Enum.KeyCode.Q, [6] = Enum.KeyCode.E,
    [7] = "Mouse1", [8] = "Mouse2",
}
local KEY_PRESET_NAMES = {
    [1]="Z", [2]="C", [3]="V", [4]="F",
    [5]="Q", [6]="E", [7]="Mouse1", [8]="Mouse2",
}

local HITPART_PRESETS = { [1]="Head", [2]="UpperTorso", [3]="HumanoidRootPart", [4]="Nearest" }
local AIM_MODE_PRESETS = { [1]="Camera", [2]="Mouse" }

local OPTION_KEY = {
    AimEnabled="AimEnabled", AimMaxDistance="AimMaxDistance",
    CheckTeam="CheckTeam", CheckVisible="AimVisibleCheck",
    DrawAimFOV="DrawAimFOV", AimFOV_Radius="AimFOV_Radius", AimFOV_Color="AimFOV_Color",
    AimKeySlot="AimKeySlot", AimMode="AimMode",
    CombatImage="CombatImage",
    MasterToggle="MasterToggle", Box="Box", CornerBox="CornerBox",
    BoxFilled="BoxFilled", BoxOpacity="BoxOpacity",
    HealthBar="HealthBar", Name="Name", Distance="Distance", Skeleton="Skeleton",
    Chams="Chams", MaxDistance="MaxDistance", Crosshair="Crosshair",
    Snaplines="Snaplines", BulletTracers="BulletTracers",
    SpeedHack="SpeedHack", WalkSpeed="WalkSpeed",
    InfiniteJump="InfiniteJump",
    Fly="Fly", FlySpeed="FlySpeed", Noclip="Noclip", Spinbot="Spinbot", SpinSpeed="SpinSpeed",
    AntiFling="AntiFling", AntiKick="AntiKick",
    GodMode="GodMode", AntiRagdoll="AntiRagdoll", CameraFOV="CameraFOV",
    NoRecoil="NoRecoil", NoSpread="NoSpread", InstantReload="InstantReload", FullAuto="FullAuto",
    MenuKeybindSlot="MenuKeybindSlot",
    UnlockFPS="UnlockFPS", TargetFPS="TargetFPS",
    CustomSkybox="CustomSkybox", ForceTimeOfDay="ForceTimeOfDay", TimeOfDay="TimeOfDay",
    PresetName="PresetName"
}

local function applyOption(optName, value)
    local key = OPTION_KEY[optName] or optName
    if Settings[key] ~= nil then Settings[key] = value end
end

local function KeyMatches(input, key)
    if not key then return false end
    if key == "Mouse1" then return input.UserInputType == Enum.UserInputType.MouseButton1 end
    if key == "Mouse2" then return input.UserInputType == Enum.UserInputType.MouseButton2 end
    return input.KeyCode == key
end

-- =========================================================================
-- PRESETS
-- =========================================================================

local PRESET_DIR_WIN = "../../../../Users/lewis/OneDrive/Desktop/ruin.lol/presets"
local PRESET_DIR_LOCAL = "ruin_presets"

local function ensurePresetFolder()
    pcall(function() if makefolder then makefolder(PRESET_DIR_LOCAL) end end)
end

local function presetPath(name) return PRESET_DIR_WIN .. "/" .. name .. ".json" end
local function presetPathFallback(name) return PRESET_DIR_LOCAL .. "/" .. name .. ".json" end

local function savePreset(name)
    local data = {}
    for k, v in pairs(Settings) do
        if type(v) ~= "function" and type(v) ~= "userdata" then data[k] = v end
    end
    local ok, encoded = pcall(function() return HttpService:JSONEncode(data) end)
    if not ok then return false end
    ensurePresetFolder()
    local wrote = false
    if writefile then
        local ok1 = pcall(function() writefile(presetPath(name), encoded) end)
        if ok1 then wrote = true end
        if not wrote then
            local ok2 = pcall(function() writefile(presetPathFallback(name), encoded) end)
            if ok2 then wrote = true end
        end
    end
    return wrote
end

local function loadPreset(name)
    local content = nil
    if readfile then
        local ok1, res1 = pcall(function() return readfile(presetPath(name)) end)
        if ok1 and res1 and #res1 > 0 then content = res1 end
        if not content then
            local ok2, res2 = pcall(function() return readfile(presetPathFallback(name)) end)
            if ok2 and res2 and #res2 > 0 then content = res2 end
        end
    end
    if not content then return false end
    local ok, data = pcall(function() return HttpService:JSONDecode(content) end)
    if not ok or type(data) ~= "table" then return false end
    for k, v in pairs(data) do
        if Settings[k] ~= nil then Settings[k] = v end
    end
    return true
end

-- =========================================================================
-- ENVIRONMENT
-- =========================================================================

local function ApplyEnvironmentSettings()
    if Settings.UnlockFPS then
        if setfpscap then pcall(function() setfpscap(Settings.TargetFPS) end) end
        if setfflag then
            pcall(function() setfflag("DFIntTaskSchedulerTargetFps", tostring(Settings.TargetFPS)) end)
            pcall(function() setfflag("DFIntMaxFrameBufferSize", tostring(math.floor(Settings.TargetFPS / 30) * 30)) end)
        end
    end
    if Settings.CustomSkybox then
        local sky = Lighting:FindFirstChildOfClass("Sky")
        if not sky then sky = Instance.new("Sky"); sky.Parent = Lighting end
        pcall(function()
            sky.SkyboxBk = Settings.SkyboxTexture
            sky.SkyboxDn = Settings.SkyboxTexture
            sky.SkyboxFt = Settings.SkyboxTexture
            sky.SkyboxLf = Settings.SkyboxTexture
            sky.SkyboxRt = Settings.SkyboxTexture
            sky.SkyboxUp = Settings.SkyboxTexture
        end)
    end
    if Settings.ForceTimeOfDay then
        local hour = tonumber(Settings.TimeOfDay) or 14
        pcall(function()
            Lighting.ClockTime = hour
            Lighting.TimeOfDay = string.format("%02d:00:00", hour)
        end)
    end
end

task.spawn(function()
    while task.wait(1) do ApplyEnvironmentSettings() end
end)

-- =========================================================================
-- MENU STATE
-- =========================================================================

local RGB = Color3.fromRGB
local SCREEN_SIZE = Camera.ViewportSize
local menuWidth, menuHeight = 440, 420

local menu = {
    w = menuWidth, h = menuHeight,
    x = math.floor((SCREEN_SIZE.X / 2) - (menuWidth / 2)),
    y = math.floor((SCREEN_SIZE.Y / 2) - (menuHeight / 2)),
    columns = { width = (menuWidth - 40) / 2, left = 17, right = (menuWidth - 20) / 2 + 13 },
    activetab = 1, open = true,
    mousedown = false, dragging = false, dragOffsetX = 0, dragOffsetY = 0,
    postable = {}, options = {},
    clrs = { norm = {}, dark = {}, togz = {} },
    mc = { 255, 255, 255 },
    tabnames = {}, multigroups = {}, mgrouptabz = {},
    tabs = {}, tabz = {}, barguy = nil,
    bbmenu = {}, keybinds = {}, unloaded = false, allItems = {},
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
    local minColor, maxColor = ranges[selected], ranges[selected + 1]
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
local function reg(d) if capturing then table.insert(menu.allItems, d) end return d end

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
    d.Text = text; d.Size = size; d.Center = centered
    d.Outline = true; d.OutlineColor = RGB(clr2[1], clr2[2], clr2[3]); d.Font = font
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
-- MENU ELEMENTS
-- =========================================================================

function drawCoolBox(name, x, y, w, h, tab)
    OutlinedRect(true, x, y, w, h, {15,15,18,255}, tab)
    OutlinedRect(true, x + 1, y + 1, w - 2, h - 2, {40,40,46,255}, tab)
    OutlinedRect(true, x + 2, y + 2, w - 3, 1, {255,255,255,255}, tab)
    OutlinedRect(true, x + 2, y + 3, w - 3, 1, {160,160,160,255}, tab)
    OutlinedRect(true, x + 2, y + 4, w - 3, 1, {30,30,35,255}, tab)
    for i = 0, 7 do
        local d = FilledRect(true, x + 2, y + 5 + (i * 2), w - 4, 2, {30,30,35,255}, tab)
        d.Color = ColorRange(i, { [1]={start=0,color=RGB(45,45,52)}, [2]={start=7,color=RGB(28,28,33)} })
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
            d.Color = ColorRange(i, { [1]={start=0,color=RGB(255,255,255)}, [2]={start=3,color=RGB(215,215,215)} })
        else
            d.Color = ColorRange(i, { [1]={start=0,color=RGB(55,55,62)}, [2]={start=3,color=RGB(32,32,38)} })
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
        d.Color = ColorRange(i, { [1]={start=0,color=RGB(55,55,62)}, [2]={start=3,color=RGB(32,32,38)} })
    end
    local tt = {}
    local pct = (value - minv) / math.max(maxv - minv, 0.0001)
    for i = 0, 3 do
        local d = FilledRect(true, x + 2, y + 14 + (i * 2), (length - 4) * pct, 2, {20,20,24,255}, tab)
        table.insert(tt, d)
        d.Color = ColorRange(i, { [1]={start=0,color=RGB(255,255,255)}, [2]={start=3,color=RGB(215,215,215)} })
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

function drawButton(name, x, y, length, tab)
    local tt = {}
    for i = 0, 7 do
        local d = FilledRect(true, x + 2, y + 2 + (i * 2), length - 4, 2, {20,20,24,255}, tab)
        table.insert(tt, d)
        d.Color = ColorRange(i, { [1]={start=0,color=RGB(55,55,62)}, [2]={start=7,color=RGB(32,32,38)} })
    end
    OutlinedRect(true, x, y, length, 18, {50,50,58,255}, tab)
    OutlinedRect(true, x + 1, y + 1, length - 2, 16, {20,20,24,255}, tab)
    tt.label = OutlinedText(name, 2, true, x + length * 0.5, y + 2, 13, true, {255,255,255,255}, {0,0,0}, tab)
    table.insert(tt, tt.label)
    return tt
end

-- =========================================================================
-- BUILD MENU
-- =========================================================================

local function BuildMenu(menutable)
    capturing = true
    menu.allItems = {}; menu.bbmenu = {}; menu.tabs = {}; menu.tabnames = {}
    menu.tabz = {}; menu.postable = {}; menu.options = {}

    AbsFilled(menu.x, menu.y, menu.w, menu.h, {32,32,36,255}, menu.bbmenu)
    AbsOutlined(menu.x, menu.y, menu.w, menu.h, {15,15,18,255}, menu.bbmenu)
    AbsOutlined(menu.x+1, menu.y+1, menu.w-2, menu.h-2, {55,55,62,255}, menu.bbmenu)
    AbsOutlined(menu.x+2, menu.y+2, menu.w-3, 1, {255,255,255,255}, menu.bbmenu)
    AbsOutlined(menu.x+2, menu.y+3, menu.w-3, 1, {180,180,180,255}, menu.bbmenu)
    AbsOutlined(menu.x+2, menu.y+4, menu.w-3, 1, {28,28,32,255}, menu.bbmenu)

    for i = 0, 19 do
        local d = AbsFilled(menu.x + 2, menu.y + 5 + i, menu.w - 4, 1, {32,32,36,255}, menu.bbmenu)
        d.Color = ColorRange(i, { [1]={start=0,color=RGB(50,50,58)}, [2]={start=20,color=RGB(32,32,36)} })
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
        d.Color = ColorRange(i, { [1]={start=0,color=RGB(42,42,48)}, [2]={start=15,color=RGB(24,24,28)} })
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
                if type(v1.name) == "table" then groups = v1.name else table.insert(groups, v1.name) end

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
                            elseif v2.type == "button" then
                                menu.options[v.name][g_name][v2.name] = {}
                                local btn = drawButton(v2.name, v1.x + 8, v1.y + y_pos, v1.width - 16, menu.tabz[k])
                                menu.options[v.name][g_name][v2.name][4] = btn
                                menu.options[v.name][g_name][v2.name][2] = "button"
                                menu.options[v.name][g_name][v2.name][1] = false
                                menu.options[v.name][g_name][v2.name][3] = { v1.x + 7, v1.y + y_pos - 1, v1.width - 16 }
                                menu.options[v.name][g_name][v2.name].optName = v2.name
                                y_pos = y_pos + 24
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
-- SCHEMA
-- =========================================================================

BuildMenu({
    {
        name = "Combat",
        content = {
            {
                name = "Aimbot", autopos = "left", autofill = true,
                content = {
                    { type = "toggle", name = "AimEnabled", value = Settings.AimEnabled },
                    { type = "slider", name = "AimMode", value = Settings.AimMode, minvalue = 1, maxvalue = 2, custom = AIM_MODE_PRESETS },
                    { type = "slider", name = "AimKeySlot", value = Settings.AimKeySlot, minvalue = 1, maxvalue = 8, custom = KEY_PRESET_NAMES },
                    { type = "slider", name = "AimMaxDistance", value = Settings.AimMaxDistance, minvalue = 50, maxvalue = 1000 },
                    { type = "slider", name = "AimHitPart", value = 1, minvalue = 1, maxvalue = 4, custom = HITPART_PRESETS },
                    { type = "slider", name = "AimSmoothing", value = Settings.AimSmoothing, minvalue = 0, maxvalue = 1, decimal = 0.01 },
                    { type = "slider", name = "AimPrediction", value = Settings.AimPrediction, minvalue = 0, maxvalue = 0.5, decimal = 0.01 },
                },
            },
            {
                name = "Aimbot Render", autopos = "right", autofill = true,
                content = {
                    { type = "toggle", name = "DrawAimFOV", value = Settings.DrawAimFOV },
                    { type = "toggle", name = "CombatImage", value = Settings.CombatImage },
                    { type = "toggle", name = "AimVisibleCheck", value = Settings.AimVisibleCheck },
                    { type = "toggle", name = "AimUseFOV", value = Settings.AimUseFOV },
                    { type = "slider", name = "AimFOV_Radius", value = Settings.AimFOV_Radius, minvalue = 20, maxvalue = 500 },
                    { type = "slider", name = "AimFOV_Color", value = Settings.AimFOV_Color, minvalue = 1, maxvalue = 6, custom = {[1]="White",[2]="Cyan",[3]="Red",[4]="Green",[5]="Pink",[6]="Yellow"} },
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
                    { type = "toggle", name = "Chams", value = Settings.Chams },
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
                name = "Environment", autopos = "right", autofill = true,
                content = {
                    { type = "slider", name = "MenuKeybindSlot", value = Settings.MenuKeybindSlot, minvalue = 1, maxvalue = 4, custom = {[1]="R-Shift",[2]="X",[3]="Insert",[4]="L-Alt"} },
                    { type = "toggle", name = "UnlockFPS", value = Settings.UnlockFPS },
                    { type = "slider", name = "TargetFPS", value = Settings.TargetFPS, minvalue = 60, maxvalue = 360 },
                    { type = "toggle", name = "CustomSkybox", value = Settings.CustomSkybox },
                    { type = "toggle", name = "ForceTimeOfDay", value = Settings.ForceTimeOfDay },
                    { type = "slider", name = "TimeOfDay", value = Settings.TimeOfDay, minvalue = 0, maxvalue = 24 },
                },
            },
        },
    },
    {
        name = "Presets",
        content = {
            {
                name = "Save / Load", autopos = "left", autofill = true,
                content = {
                    { type = "button", name = "SavePreset", },
                    { type = "button", name = "LoadPreset", },
                },
            },
        },
    },
})

-- =========================================================================
-- TAB SWITCH
-- =========================================================================

local function setActiveTab(slot)
    menu.activetab = slot
    local tabW = (menu.w - 20) / math.max(#menu.tabnames, 1)
    if menu.barguy then
        menu.barguy.Position = Vector2.new(menu.x + 11 + ((tabW - 2) * (slot - 1)) + ((slot - 1) * 2), menu.y + 58)
        menu.barguy.Size = Vector2.new(tabW - 2, 2)
    end
    for k, v in pairs(menu.tabs) do
        if v[1] then v[1].Color = (k == slot) and RGB(255,255,255) or RGB(170,170,170) end
    end
    for k, v in pairs(menu.tabz) do
        for _, d in pairs(v) do
            if d and d.Visible ~= nil then d.Visible = (k == slot) and menu.open end
        end
    end
end

setActiveTab(menu.activetab)

local function MouseInMenu(x, y, w, h)
    local m = UserInputService:GetMouseLocation()
    return m.X >= menu.x + x and m.X <= menu.x + x + w
       and m.Y >= menu.y + y and m.Y <= menu.y + y + h
end

-- =========================================================================
-- FOV CIRCLE
-- =========================================================================

local AimFOVCircle = Drawing.new("Circle")
AimFOVCircle.Thickness = 1
AimFOVCircle.NumSides = 64
AimFOVCircle.Filled = false
AimFOVCircle.Visible = false

-- =========================================================================
-- COMBAT TAB IMAGE — Drawing.new("Image")
-- =========================================================================

local combatImage = Drawing.new("Image")
combatImage.Visible = false
combatImage.Transparency = 1
combatImage.Size = Vector2.new(130, 130)
combatImage.Position = Vector2.new(0, 0)
combatImage.Data = nil

task.spawn(function()
    local urls = {}
    local ok, th = pcall(function()
        return game:HttpGet("https://thumbnails.roblox.com/v1/assets?assetIds=102295485471784&size=420x420&format=Png")
    end)
    if ok and th then
        local decodeOk, parsed = pcall(function() return HttpService:JSONDecode(th) end)
        if decodeOk and parsed and parsed.data and parsed.data[1] and parsed.data[1].imageUrl then
            table.insert(urls, parsed.data[1].imageUrl)
        end
    end
    table.insert(urls, "https://tr.rbxcdn.com/180DAY-c82599188f1eff3acd2d44408d9be274/420/420/Image/Png/noFilter")

    for _, url in ipairs(urls) do
        local ok2, data = pcall(function() return game:HttpGet(url) end)
        if ok2 and data and #data > 100 then
            combatImage.Data = data
            break
        end
    end
end)

-- =========================================================================
-- PRESET BUTTONS
-- =========================================================================

local function handleButton(name)
    if name == "SavePreset" then
        savePreset(Settings.PresetName)
    elseif name == "LoadPreset" then
        loadPreset(Settings.PresetName)
        ApplyEnvironmentSettings()
    end
end

-- =========================================================================
-- INPUT
-- =========================================================================

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end

    local activeMenuKey = KEYBIND_LOOKUP[Settings.MenuKeybindSlot] or Enum.KeyCode.RightShift
    if input.KeyCode == activeMenuKey then
        menu.open = not menu.open
        for _, d in ipairs(menu.allItems) do pcall(function() d.Visible = menu.open end) end
        if menu.open then setActiveTab(menu.activetab) end
        return
    end

    if input.UserInputType ~= Enum.UserInputType.MouseButton1
    and input.UserInputType ~= Enum.UserInputType.Touch then return end
    if not menu.open then return end

    local m = UserInputService:GetMouseLocation()
    if m.X >= menu.x and m.X <= menu.x + menu.w and m.Y >= menu.y and m.Y <= menu.y + 25 then
        menu.dragging = true
        menu.dragOffsetX = m.X - menu.x
        menu.dragOffsetY = m.Y - menu.y
        return
    end

    local tabW = (menu.w - 20) / math.max(#menu.tabnames, 1)
    for i = 1, #menu.tabnames do
        if MouseInMenu(10 + ((i - 1) * tabW), 27, tabW, 32) then
            setActiveTab(i); return
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
                                    v2[4][i + 1].Color = ColorRange(i, { [1]={start=0,color=RGB(255,255,255)}, [2]={start=3,color=RGB(215,215,215)} })
                                else
                                    v2[4][i + 1].Color = ColorRange(i, { [1]={start=0,color=RGB(55,55,62)}, [2]={start=3,color=RGB(32,32,38)} })
                                end
                            end
                        end
                    elseif v2[2] == "slider" then
                        if MouseInMenu(v2[3][1], v2[3][2], v2[3][3], 28) then v2[5] = true end
                    elseif v2[2] == "button" then
                        if MouseInMenu(v2[3][1], v2[3][2], v2[3][3], 20) then
                            handleButton(v2.optName)
                        end
                    end
                end
            end
        end
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType ~= Enum.UserInputType.MouseMovement
    and input.UserInputType ~= Enum.UserInputType.Touch then return end

    local m = UserInputService:GetMouseLocation()
    if menu.dragging then
        local newX = m.X - menu.dragOffsetX
        local newY = m.Y - menu.dragOffsetY
        shiftAllItems(newX - menu.x, newY - menu.y)
        menu.x = newX; menu.y = newY
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
                            v2[1] = (not v2.decimal and math.floor(new_val + 0.5) or math.floor(new_val / v2.decimal + 0.5) * v2.decimal)
                            if v2[1] < minv then v2[1] = minv elseif v2[1] > maxv then v2[1] = maxv end
                            v2[4].valueText.Text = (v2.custom and v2.custom[v2[1]]) or (tostring(v2[1]) .. (v2.stradd or ""))
                            for i = 1, 4 do v2[4][i].Size = Vector2.new((v2[3][3] - 4) * pct, 2) end
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
-- ESP
-- =========================================================================

local ESPCache = {}
local ChamsCache = {}
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
    d.Visible = false; d.Transparency = 1
    if d.Color then d.Color = clr or Color3.new(1,1,1) end
    if d.Filled ~= nil then d.Filled = filled and true or false end
    return d
end

local function CreateESP(player)
    if player == LocalPlayer or ESPCache[player] then return end
    local obj = {
        BoxFill = mkdraw("Square", Color3.fromRGB(255,255,255), true),
        Box     = mkdraw("Square", Color3.fromRGB(255,255,255), false),
        HBBack  = mkdraw("Square", Color3.fromRGB(0,0,0), true),
        HB      = mkdraw("Square", Color3.fromRGB(80,220,100), true),
        Name    = mkdraw("Text", Color3.fromRGB(255,255,255)),
        Dist    = mkdraw("Text", Color3.fromRGB(200,200,200)),
        Snap    = mkdraw("Line", Color3.fromRGB(255,255,255)),
        Corners = {}, Skel = {},
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
    if d then
        HideESP(d)
        for _, v in pairs(d) do
            if type(v) == "table" then
                for _, l in ipairs(v) do pcall(function() if l then l:Remove() end end) end
            elseif v and v.Remove then pcall(function() v:Remove() end) end
        end
        ESPCache[p] = nil
    end
    if ChamsCache[p] then pcall(function() ChamsCache[p]:Destroy() end) ChamsCache[p] = nil end
end)
for _, p in ipairs(Players:GetPlayers()) do CreateESP(p) end

local function UpdateChams(player, char, enabled)
    if not char then return end
    if enabled then
        if not ChamsCache[player] then
            local hl = Instance.new("Highlight")
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hl.FillColor = Color3.fromRGB(0, 0, 0)
            hl.FillTransparency = 0.5
            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
            hl.Parent = char
            ChamsCache[player] = hl
        else
            ChamsCache[player].Enabled = true
        end
    elseif ChamsCache[player] then
        ChamsCache[player].Enabled = false
    end
end

-- =========================================================================
-- CROSSHAIR + TRACERS
-- =========================================================================

local CrossLines = {
    Drawing.new("Line"), Drawing.new("Line"),
    Drawing.new("Line"), Drawing.new("Line")
}
local CrossDot = Drawing.new("Square")
CrossDot.Filled = true; CrossDot.Size = Vector2.new(2, 2); CrossDot.Color = Color3.fromRGB(255,255,255)
for _, l in ipairs(CrossLines) do
    l.Thickness = 1; l.Color = Color3.fromRGB(255,255,255); l.Visible = false
end

local TracerFolder = Instance.new("Folder", workspace)
TracerFolder.Name = "ruin_Tracers"

local function DrawTracer(a, b)
    local p1 = Instance.new("Part")
    p1.Size = Vector3.new(0.1, 0.1, 0.1); p1.Position = a
    p1.Transparency = 1; p1.Anchored = true; p1.CanCollide = false
    p1.Parent = TracerFolder
    local p2 = Instance.new("Part")
    p2.Size = Vector3.new(0.1, 0.1, 0.1); p2.Position = b
    p2.Transparency = 1; p2.Anchored = true; p2.CanCollide = false
    p2.Parent = TracerFolder
    local a1 = Instance.new("Attachment", p1)
    local a2 = Instance.new("Attachment", p2)
    local beam = Instance.new("Beam")
    beam.Attachment0 = a1; beam.Attachment1 = a2
    beam.Color = ColorSequence.new(Color3.fromRGB(255,255,255))
    beam.Width0 = 0.15; beam.Width1 = 0.15
    beam.FaceCamera = true
    beam.Transparency = NumberSequence.new(0)
    beam.Parent = p1
    task.spawn(function()
        local t = 0
        while t < 1.5 do
            local dt = RunService.RenderStepped:Wait()
            t += dt
            beam.Transparency = NumberSequence.new(t / 1.5)
        end
        p1:Destroy(); p2:Destroy()
    end)
end

local lastFire = 0
local function OnFire()
    if not Settings.BulletTracers then return end
    if tick() - lastFire < 0.05 then return end
    lastFire = tick()
    local char = LocalPlayer.Character
    local tool = char and char:FindFirstChildOfClass("Tool")
    if not tool then return end
    local muzzle = tool:FindFirstChild("Muzzle") or tool:FindFirstChild("Handle") or char:FindFirstChild("Head")
    local start = muzzle and muzzle.Position or Camera.CFrame.Position
    local m = UserInputService:GetMouseLocation()
    local ray = Camera:ViewportPointToRay(m.X, m.Y)
    local rp = RaycastParams.new()
    rp.FilterType = Enum.RaycastFilterType.Exclude
    rp.FilterDescendantsInstances = { char, TracerFolder }
    local hit = workspace:Raycast(ray.Origin, ray.Direction * 2000, rp)
    local ending = hit and hit.Position or (ray.Origin + ray.Direction * 2000)
    DrawTracer(start, ending)
end

local function HookTool(child)
    if child:IsA("Tool") then child.Activated:Connect(OnFire) end
end

LocalPlayer.CharacterAdded:Connect(function(c)
    c.ChildAdded:Connect(HookTool)
    for _, child in ipairs(c:GetChildren()) do HookTool(child) end
end)
if LocalPlayer.Character then
    for _, child in ipairs(LocalPlayer.Character:GetChildren()) do HookTool(child) end
    LocalPlayer.Character.ChildAdded:Connect(HookTool)
end

-- =========================================================================
-- WEAPON MODS
-- =========================================================================

task.spawn(function()
    while task.wait(1) do
        local char = LocalPlayer.Character
        if not char then continue end
        for _, tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") then
                if Settings.NoRecoil then
                    pcall(function() tool:SetAttribute("Recoil", 0) end)
                    for _, d in ipairs(tool:GetDescendants()) do
                        if d:IsA("NumberValue") and d.Name:lower():find("recoil") then d.Value = 0 end
                    end
                end
                if Settings.NoSpread then
                    pcall(function() tool:SetAttribute("Spread", 0) end)
                    for _, d in ipairs(tool:GetDescendants()) do
                        if d:IsA("NumberValue") and d.Name:lower():find("spread") then d.Value = 0 end
                    end
                end
                if Settings.InstantReload then
                    pcall(function() tool:SetAttribute("ReloadTime", 0) end)
                    for _, d in ipairs(tool:GetDescendants()) do
                        if d:IsA("NumberValue") and d.Name:lower():find("reload") then d.Value = 0 end
                    end
                end
                if Settings.FullAuto then
                    pcall(function() tool:SetAttribute("Automatic", true) end)
                    pcall(function() tool:SetAttribute("FullAuto", true) end)
                    for _, d in ipairs(tool:GetDescendants()) do
                        if d:IsA("BoolValue") and (d.Name:lower():find("auto") or d.Name:lower():find("automatic")) then
                            d.Value = true
                        end
                    end
                end
            end
        end
    end
end)

-- =========================================================================
-- GODMODE / ANTI-RAGDOLL
-- =========================================================================

task.spawn(function()
    while task.wait(0.5) do
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            if Settings.GodMode then
                hum.MaxHealth = math.huge
                hum.Health = math.huge
            end
            if Settings.AntiRagdoll then
                hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
                hum:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
            end
        end
    end
end)

-- =========================================================================
-- AIMBOT
-- =========================================================================

local aimTarget, aiming = nil, false
local aimLockTime = 0
local AIM_LOCK_DURATION = 0.35

local function AimVisible(fromPos, part, ignoreChar)
    if not Settings.AimVisibleCheck then return true end
    local rp = RaycastParams.new()
    rp.FilterType = Enum.RaycastFilterType.Exclude
    rp.FilterDescendantsInstances = { ignoreChar, LocalPlayer.Character }
    local dir = part.Position - fromPos
    local hit = workspace:Raycast(fromPos, dir, rp)
    return hit == nil or hit.Instance:IsDescendantOf(part.Parent)
end

local AIM_PARTS_ORDER = {
    ["Head"]             = { "Head", "UpperTorso", "HumanoidRootPart" },
    ["UpperTorso"]       = { "UpperTorso", "Head", "HumanoidRootPart" },
    ["HumanoidRootPart"] = { "HumanoidRootPart", "UpperTorso", "Head" },
    ["Nearest"]          = { "Head", "UpperTorso", "LowerTorso", "HumanoidRootPart", "LeftUpperArm", "RightUpperArm", "LeftUpperLeg", "RightUpperLeg" },
}

local function GetBestHitPart(char, mode)
    local order = AIM_PARTS_ORDER[mode] or AIM_PARTS_ORDER["Head"]
    if mode == "Nearest" then
        local closest, bestD = nil, math.huge
        local cp = Camera.CFrame.Position
        for _, name in ipairs(order) do
            local p = char:FindFirstChild(name)
            if p and p:IsA("BasePart") then
                local d = (p.Position - cp).Magnitude
                if d < bestD then bestD = d closest = p end
            end
        end
        return closest
    end
    for _, name in ipairs(order) do
        local p = char:FindFirstChild(name)
        if p and p:IsA("BasePart") then return p end
    end
    return nil
end

local function AimValid(player)
    if not player or player == LocalPlayer then return false end
    local char = player.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return false end
    if Settings.CheckAlive and hum.Health <= 0 then return false end
    if Settings.CheckKnocked and hum.Health < 18 then return false end
    if Settings.CheckTeam and LocalPlayer.Team and player.Team == LocalPlayer.Team then return false end
    return true
end

local function PickAimTarget()
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local best, bestScore = nil, math.huge
    local fov = Settings.AimUseFOV and Settings.AimFOV_Radius or math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if AimValid(player) then
            local char = player.Character
            local part = GetBestHitPart(char, Settings.AimHitPart)
            if part then
                local dist = (part.Position - Camera.CFrame.Position).Magnitude
                if dist <= Settings.AimMaxDistance then
                    local sp, on = Camera:WorldToViewportPoint(part.Position)
                    if on then
                        local sd = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                        if sd <= fov then
                            if AimVisible(Camera.CFrame.Position, part, char) then
                                local score = sd + (dist * 0.05)
                                if score < bestScore then
                                    bestScore = score
                                    best = player
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return best
end

UserInputService.InputBegan:Connect(function(input, gp)
    if gp or not Settings.AimEnabled then return end
    if KeyMatches(input, KEY_PRESETS[Settings.AimKeySlot]) then
        aiming = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if not Settings.AimEnabled then return end
    if KeyMatches(input, KEY_PRESETS[Settings.AimKeySlot]) then
        aiming = false
        aimTarget = nil
        aimLockTime = 0
    end
end)

local function AimStep(dt)
    if not Settings.AimEnabled or not aiming then return end

    local now = tick()
    local stillValid = false
    if aimTarget then
        stillValid = AimValid(aimTarget) and (now - aimLockTime) < AIM_LOCK_DURATION
        if stillValid then
            local char = aimTarget.Character
            local part = GetBestHitPart(char, Settings.AimHitPart)
            if not part then stillValid = false end
        end
    end

    if not stillValid then
        local fresh = PickAimTarget()
        if fresh then
            aimTarget = fresh
            aimLockTime = now
        else
            aimTarget = nil
            return
        end
    end

    local char = aimTarget.Character
    if not char then return end
    local part = GetBestHitPart(char, Settings.AimHitPart)
    if not part then return end

    local hum = char:FindFirstChildOfClass("Humanoid")
    local airborne = hum and (hum:GetState() == Enum.HumanoidStateType.Freefall
        or hum:GetState() == Enum.HumanoidStateType.Jumping)
    local pred = airborne and Settings.AimAirPrediction or Settings.AimPrediction
    local aimPos = part.Position + (part.AssemblyLinearVelocity * pred)

    if Settings.AimMode == 2 then
        local myChar = LocalPlayer.Character
        local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if myHrp then
            local dir = (aimPos - myHrp.Position)
            local flat = Vector3.new(dir.X, 0, dir.Z)
            if flat.Magnitude > 0.01 then
                myHrp.CFrame = CFrame.new(myHrp.Position, myHrp.Position + flat.Unit)
            end
        end
    end

    local goal = CFrame.new(Camera.CFrame.Position, aimPos)
    local smooth = math.clamp(Settings.AimSmoothing, 0, 1)
    if smooth <= 0 then
        Camera.CFrame = goal
    else
        local alpha = math.clamp((1 - smooth) * dt * 60, 0.05, 1)
        Camera.CFrame = Camera.CFrame:Lerp(goal, alpha)
    end
end

-- =========================================================================
-- MOVEMENT
-- =========================================================================

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

-- =========================================================================
-- RENDER LOOP
-- =========================================================================

RunService.RenderStepped:Connect(function(dt)
    SCREEN_SIZE = Camera.ViewportSize
    Camera.FieldOfView = Settings.CameraFOV
    local mLoc = UserInputService:GetMouseLocation()

    if Settings.DrawAimFOV then
        AimFOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        AimFOVCircle.Radius = Settings.AimFOV_Radius
        AimFOVCircle.Color = COLOR_PRESETS[Settings.AimFOV_Color] or Color3.new(1,1,1)
        AimFOVCircle.Visible = true
    else
        AimFOVCircle.Visible = false
    end

    -- image on right side of Combat tab, below Aimbot Render group
    if Settings.CombatImage and combatImage.Data then
        combatImage.Visible = menu.open and (menu.activetab == 1)
        combatImage.Position = Vector2.new(menu.x + menu.w - 160, menu.y + menu.h - 175)
        combatImage.Size = Vector2.new(160, 160)
    else
        combatImage.Visible = false
    end

    if Settings.Crosshair then
        local c = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        local len, gap = 6, 3
        CrossLines[1].From = c - Vector2.new(0, gap + len); CrossLines[1].To = c - Vector2.new(0, gap); CrossLines[1].Visible = true
        CrossLines[2].From = c + Vector2.new(0, gap); CrossLines[2].To = c + Vector2.new(0, gap + len); CrossLines[2].Visible = true
        CrossLines[3].From = c - Vector2.new(gap + len, 0); CrossLines[3].To = c - Vector2.new(gap, 0); CrossLines[3].Visible = true
        CrossLines[4].From = c + Vector2.new(gap, 0); CrossLines[4].To = c + Vector2.new(gap + len, 0); CrossLines[4].Visible = true
        CrossDot.Position = c - Vector2.new(1, 1)
        CrossDot.Color = Color3.fromRGB(255,255,255)
        CrossDot.Visible = true
    else
        for _, l in ipairs(CrossLines) do l.Visible = false end
        CrossDot.Visible = false
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

                    if Settings.Box and Settings.BoxFilled and data.BoxFill then
                        data.BoxFill.Size = Vector2.new(w, h)
                        data.BoxFill.Position = Vector2.new(bx, by)
                        data.BoxFill.Transparency = Settings.BoxOpacity / 100
                        data.BoxFill.Color = Color3.fromRGB(255, 255, 255)
                        data.BoxFill.Visible = true
                    elseif data.BoxFill then data.BoxFill.Visible = false end

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

                    if Settings.Name and data.Name then
                        data.Name.Position = Vector2.new(topPos.X, by - 16)
                        data.Name.Text = player.Name
                        data.Name.Visible = true
                    elseif data.Name then data.Name.Visible = false end

                    if Settings.Distance and data.Dist then
                        data.Dist.Position = Vector2.new(topPos.X, by + h + 4)
                        data.Dist.Text = string.format("%dm", math.floor(dist))
                        data.Dist.Visible = true
                    elseif data.Dist then data.Dist.Visible = false end

                    if Settings.Snaplines and data.Snap then
                        data.Snap.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                        data.Snap.To = Vector2.new(topPos.X, topPos.Y)
                        data.Snap.Visible = true
                    elseif data.Snap then data.Snap.Visible = false end

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
        UpdateChams(player, char, Settings.MasterToggle and Settings.Chams and char and hum and hum.Health > 0)
    end

    AimStep(dt)
end)
