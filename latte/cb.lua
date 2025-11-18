
local attempt_time = os.clock()
while (not Drawing) or (type(Drawing.new) ~= "function") do
    warn("waiting for drawing to initialize...")
    wait(0.1)
    if os.clock() - attempt_time > 10 then
        warn("drawing unavailable, GUI fallback enabled.")
        Drawing = {
            new = function()
                return setmetatable({}, { __index = function() return function() end end })
            end
        }
        break
    end
end


local UPDATE_RATE = 0.006
local TELEPORT_INTERVAL = 0.02
local nospread_enable = false
local firerate_enable = false
local reload_enable = false
local infammo_enable = false
local ui_visible = true


local camera = workspace.CurrentCamera
while not camera do
    wait(0.1)
    camera = workspace.CurrentCamera
end

local function create_gui()
    local bg = Drawing.new("Square")
    bg.Filled = true
    bg.Transparency = 0.8
    bg.Color = Color3.fromRGB(20, 20, 20)
    bg.Size = Vector2.new(270, 180)
    bg.Position = Vector2.new(camera.ViewportSize.X - 290, 20)
    bg.Visible = true

    local title = Drawing.new("Text")
title.Text = "FurryHub"
title.Position = Vector2.new(bg.Position.X + 10, bg.Position.Y + 8)
title.Color = Color3.fromRGB(255, 255, 255)
title.Outline = true
title.Visible = true

spawn(function()
    local hue = 0
    while true do
        wait(0.03)
        hue = (hue + 2) % 360

        local function HSVtoRGB(h, s, v)
            local r, g, b
            local i = math.floor(h * 6)
            local f = h * 6 - i
            local p = v * (1 - s)
            local q = v * (1 - f * s)
            local t = v * (1 - (1 - f) * s)
            i = i % 6
            
            if i == 0 then r, g, b = v, t, p
            elseif i == 1 then r, g, b = q, v, p
            elseif i == 2 then r, g, b = p, v, t
            elseif i == 3 then r, g, b = p, q, v
            elseif i == 4 then r, g, b = t, p, v
            elseif i == 5 then r, g, b = v, p, q
            end
            
            return Color3.fromRGB(r * 255, g * 255, b * 255)
        end
        
        if ui_visible and title then
            title.Color = HSVtoRGB(hue / 360, 1, 1)
        end
    end
end)

    local tp_box = Drawing.new("Square")
    tp_box.Filled = true
    tp_box.Color = Color3.fromRGB(120, 0, 0)
    tp_box.Transparency = 0.8
    tp_box.Size = Vector2.new(20, 20)
    tp_box.Position = Vector2.new(bg.Position.X + 10, bg.Position.Y + 35)
    tp_box.Visible = true

    local tp_text = Drawing.new("Text")
    tp_text.Text = "No Spread: OFF"
    tp_text.Position = Vector2.new(tp_box.Position.X + 30, tp_box.Position.Y + 3)
    tp_text.Color = Color3.fromRGB(255, 255, 255)
    tp_text.Outline = true
    tp_text.Visible = true

    local auto_box = Drawing.new("Square")
    auto_box.Filled = true
    auto_box.Color = Color3.fromRGB(120, 0, 0)
    auto_box.Transparency = 0.8
    auto_box.Size = Vector2.new(20, 20)
    auto_box.Position = Vector2.new(bg.Position.X + 10, bg.Position.Y + 65)
    auto_box.Visible = true

    local auto_text = Drawing.new("Text")
    auto_text.Text = "Rapid Fire: OFF"
    auto_text.Position = Vector2.new(auto_box.Position.X + 30, auto_box.Position.Y + 3)
    auto_text.Color = Color3.fromRGB(255, 255, 255)
    auto_text.Outline = true
    auto_text.Visible = true

    local rc_box = Drawing.new("Square")
    rc_box.Filled = true
    rc_box.Color = Color3.fromRGB(120, 0, 0)
    rc_box.Transparency = 0.8
    rc_box.Size = Vector2.new(20, 20)
    rc_box.Position = Vector2.new(bg.Position.X + 10, bg.Position.Y + 95)
    rc_box.Visible = true

    local rc_text = Drawing.new("Text")
    rc_text.Text = "Fast Reload: OFF"
    rc_text.Position = Vector2.new(rc_box.Position.X + 30, rc_box.Position.Y + 3)
    rc_text.Color = Color3.fromRGB(255, 255, 255)
    rc_text.Outline = true
    rc_text.Visible = true

    local ia_box = Drawing.new("Square")
    ia_box.Filled = true
    ia_box.Color = Color3.fromRGB(120, 0, 0)
    ia_box.Transparency = 0.8
    ia_box.Size = Vector2.new(20, 20)
    ia_box.Position = Vector2.new(bg.Position.X + 10, bg.Position.Y + 125)
    ia_box.Visible = true

    local ia_text = Drawing.new("Text")
    ia_text.Text = "Inf Ammo: OFF"
    ia_text.Position = Vector2.new(ia_box.Position.X + 30, ia_box.Position.Y + 3)
    ia_text.Color = Color3.fromRGB(255, 255, 255)
    ia_text.Outline = true
    ia_text.Visible = true
--[[
    local kw_box = Drawing.new("Square")
    kw_box.Filled = true
    kw_box.Color = Color3.fromRGB(120, 0, 0)
    kw_box.Transparency = 0.8
    kw_box.Size = Vector2.new(20, 20)
    kw_box.Position = Vector2.new(bg.Position.X + 10, bg.Position.Y + 155)
    kw_box.Visible = true

    local kw_text = Drawing.new("Text")
    kw_text.Text = "hvh scout"
    kw_text.Position = Vector2.new(kw_box.Position.X + 30, kw_box.Position.Y + 3)
    kw_text.Color = Color3.fromRGB(255, 255, 255)
    kw_text.Outline = true
    kw_text.Visible = true

--]]

    return {
        bg = bg, title = title,
        tp_box = tp_box, tp_text = tp_text,
        auto_box = auto_box, auto_text = auto_text,
        rc_box = rc_box, rc_text = rc_text,
        ia_box = ia_box, ia_text = ia_text,
        --kw_box = kw_box, kw_text = kw_text
    }
end

local gui = create_gui()

local function nospread_nigger()
    for _, weapon in ipairs(game:GetService("ReplicatedStorage").Weapons:GetChildren()) do
    local spread = weapon:FindFirstChild("Spread")
    if spread then
        for _, spread2 in ipairs(spread:GetChildren()) do
            spread2.Value = 0
        end
    end
end
end

local function firerate_nigger()
for i, v in next, game:GetService("ReplicatedStorage").Weapons:GetChildren() do
    for _, value in next, v:GetChildren() do
        if value.Name == "FireRate" then
            value.Value = -1;
        end;
    end;
end;
end

local function reload_nigger()
for i, v in next, game:GetService("ReplicatedStorage").Weapons:GetChildren() do
    for _, value in next, v:GetChildren() do
        if value.Name == "ReloadTime" then
            value.Value = 0.1;
        end;
    end;
end;
end

local function infa_nigger()
    for i, v in next, game:GetService("ReplicatedStorage").Weapons:GetChildren() do
    for _, value in next, v:GetChildren() do
        if value.Name == "Ammo" then
            value.Value = -1;
        end;
    end;
end;
end

--[[
local function modifyScoutProperties()
    local scout = game:FindFirstChild("ReplicatedStorage")
        and game.ReplicatedStorage:FindFirstChild("Weapons")
        and game.ReplicatedStorage.Weapons:FindFirstChild("Scout")

    if scout then
        local success, err = pcall(function()
            local huInfo = game:FindFirstChild("ReplicatedStorage")
            if huInfo then
                local scoutFolder = huInfo:FindFirstChild("HUInfo")
                if scoutFolder then
                    local scoutFolderInHU = scoutFolder:FindFirstChild("Scout")
                    if scoutFolderInHU then
                        local walkSpeedValue = scoutFolderInHU:FindFirstChild("WalkSpeed")
                        if walkSpeedValue then walkSpeedValue.Value = 1500 end

                        local scopedValue = scoutFolderInHU:FindFirstChild("Scoped")
                        if scopedValue then scopedValue.Value = 1500 end
                    end
                end
            end

            local fireRate = scout:FindFirstChild("FireRate")
            if fireRate then fireRate.Value = -1 end

            local equipTime = scout:FindFirstChild("EquipTime")
            if equipTime then equipTime.Value = 0.1 end

            local auto = scout:FindFirstChild("Auto")
            if auto then auto.Value = true end

            local ammo = scout:FindFirstChild("Ammo")
            if ammo then ammo.Value = -1 end

            local range = scout:FindFirstChild("Range")
            if range then range.Value = 99999999 end

            local reloadTime = scout:FindFirstChild("ReloadTime")
            if reloadTime then reloadTime.Value = 0.1 end

            local storedAmmo = scout:FindFirstChild("StoredAmmo")
            if storedAmmo then storedAmmo.Value = 34698734634 end

            local rangeModifier = scout:FindFirstChild("RangeModifier")
            if rangeModifier then rangeModifier.Value = 5555555555555 end

            local spreadFolder = scout:FindFirstChild("Spread")
            if spreadFolder then
                for _, child in pairs(spreadFolder:GetChildren()) do
                    if child:IsA("NumberValue") then
                        child.Value = 0
                    end
                end
            end
        end)

        if not success then
            warn("Failed to modify Scout properties:")
        end
    end
end
--]]

local function set_ui_visible(state)
    ui_visible = state
    for _, v in pairs(gui) do
        if v and v.Visible ~= nil then
            v.Visible = state
        end
    end
end

local debuger = false

spawn(function()
    while true do
        wait(UPDATE_RATE)
        local mx, my = mouse.X, mouse.Y

        if ismouse1pressed() then
            if mx >= gui.tp_box.Position.X and mx <= gui.tp_box.Position.X + gui.tp_box.Size.X and
               my >= gui.tp_box.Position.Y and my <= gui.tp_box.Position.Y + gui.tp_box.Size.Y then
                nospread_enable = not nospread_enable
                gui.tp_box.Color = nospread_enable and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(120, 0, 0)
                gui.tp_text.Text = nospread_enable and "No Spread: ON" or "No Spread: OFF"
                wait(0.25)
            end


            if mx >= gui.auto_box.Position.X and mx <= gui.auto_box.Position.X + gui.auto_box.Size.X and
               my >= gui.auto_box.Position.Y and my <= gui.auto_box.Position.Y + gui.auto_box.Size.Y then
                firerate_enable = not firerate_enable
                gui.auto_box.Color = firerate_enable and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(120, 0, 0)
                gui.auto_text.Text = firerate_enable and "Rapid Fire: ON" or "Rapid Fire: OFF"
                wait(0.25)
            end


            if mx >= gui.rc_box.Position.X and mx <= gui.rc_box.Position.X + gui.rc_box.Size.X and
               my >= gui.rc_box.Position.Y and my <= gui.rc_box.Position.Y + gui.rc_box.Size.Y then
                reload_enable = not reload_enable
                gui.rc_box.Color = reload_enable and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(120, 0, 0)
                gui.rc_text.Text = reload_enable and "Fast Reload: ON" or "Fast Reload: OFF"
                wait(0.25)
            end


            if mx >= gui.ia_box.Position.X and mx <= gui.ia_box.Position.X + gui.ia_box.Size.X and
               my >= gui.ia_box.Position.Y and my <= gui.ia_box.Position.Y + gui.ia_box.Size.Y then
                infammo_enable = not infammo_enable
                gui.ia_box.Color = infammo_enable and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(120, 0, 0)
                gui.ia_text.Text = infammo_enable and "Inf Ammo: ON" or "Inf Ammo: OFF"
                wait(0.25)
            end

            --[[
            if mx >= gui.kw_box.Position.X and mx <= gui.kw_box.Position.X + gui.kw_box.Size.X and
               my >= gui.kw_box.Position.Y and my <= gui.kw_box.Position.Y + gui.kw_box.Size.Y then
                kw_enable = not kw_enable
                gui.kw_box.Color = kw_enable and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(120, 0, 0)
                gui.kw_text.Text = kw_enable and "hvh scout" or "legit scout"
                wait(0.25)
            end
            ]]
        else
            debuger = false
        end
    end
end)

spawn(function()
    while true do
        wait(0.1)
        if iskeypressed(112) then
            set_ui_visible(not ui_visible)
            wait(0.4)
        elseif iskeypressed(113) then
            nospread_enable = not nospread_enable
            gui.tp_box.Color = nospread_enable and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(120, 0, 0)
            gui.tp_text.Text = nospread_enable and "NoSpread: ON" or "NoSpread: OFF"
            wait(0.4)
        elseif iskeypressed(114) then
            firerate_enable = not firerate_enable
            gui.auto_box.Color = firerate_enable and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(120, 0, 0)
            gui.auto_text.Text = firerate_enable and "Rapid Fire: ON" or "Rapid Fire: OFF"
            wait(0.4)
        elseif iskeypressed(115) then
            reload_enable = not reload_enable
            gui.rc_box.Color = reload_enable and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(120, 0, 0)
            gui.rc_text.Text = reload_enable and "Fast Reload: ON" or "Fast Reload: OFF"
            wait(0.4)
        elseif iskeypressed(116) then
            infammo_enable = not infammo_enable
            gui.ia_box.Color = infammo_enable and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(120, 0, 0)
            gui.ia_text.Text = infammo_enable and "Inf Ammo: ON" or "Inf Ammo: OFF"
            wait(0.4)
            --[[
        elseif iskeypressed(117) then
            kw_enable = not kw_enable
            gui.kw_box.Color = kw_enable and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(120, 0, 0)
            gui.kw_text.Text = kw_enable and "hvh scout" or "legit scout"
            wait(0.4)
            ]]
        end
    end
end)

spawn(function()
    while true do
        wait(TELEPORT_INTERVAL)
        if nospread_enable then nospread_nigger() end
        if firerate_enable then firerate_nigger() end
        if reload_enable then reload_nigger() end
        if infammo_enable then infa_nigger() end
        --if kw_enable then modifyScoutProperties() end
    end
end)

local gui_text = Drawing.new("Text")
gui_text.Text = "furryhub.real"
gui_text.Position = Vector2.new(20, 20)
gui_text.Color = Color3.fromRGB(255, 255, 255)
gui_text.Outline = true
gui_text.Transparency = 0.8
gui_text.Visible = true

spawn(function()
    local hue = 0
    while true do
        wait(0.03)
        hue = (hue + 2) % 360
        
        local function HSVtoRGB(h, s, v)
            local r, g, b
            local i = math.floor(h * 6)
            local f = h * 6 - i
            local p = v * (1 - s)
            local q = v * (1 - f * s)
            local t = v * (1 - (1 - f) * s)
            i = i % 6
            
            if i == 0 then r, g, b = v, t, p
            elseif i == 1 then r, g, b = q, v, p
            elseif i == 2 then r, g, b = p, v, t
            elseif i == 3 then r, g, b = p, q, v
            elseif i == 4 then r, g, b = t, p, v
            elseif i == 5 then r, g, b = v, p, q
            end
            
            return Color3.fromRGB(r * 255, g * 255, b * 255)
        end
        
        gui_text.Color = HSVtoRGB(hue / 360, 1, 1)
    end
end)
