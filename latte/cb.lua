--gmeasensi.pub aka skeetoes.cc

--> ensure Drawing
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

--> constants
local UPDATE_RATE = 0.006
local TELEPORT_INTERVAL = 0.02
local nospread_enable = false
local firerate_enable = false
local ui_visible = true

--> ensure camera
local camera = workspace.CurrentCamera
while not camera do
    wait(0.1)
    camera = workspace.CurrentCamera
end

--> GUI setup (80% visible)
local function create_gui()
    local bg = Drawing.new("Square")
    bg.Filled = true
    bg.Transparency = 0.8
    bg.Color = Color3.fromRGB(20, 20, 20)
    bg.Size = Vector2.new(270, 180)
    bg.Position = Vector2.new(camera.ViewportSize.X - 290, 20)
    bg.Visible = true

    local title = Drawing.new("Text")
    title.Text = "coolmathsense.pub"
    title.Position = Vector2.new(bg.Position.X + 10, bg.Position.Y + 8)
    title.Color = Color3.fromRGB(255, 255, 255)
    title.Outline = true
    title.Visible = true

    local tp_box = Drawing.new("Square")
    tp_box.Filled = true
    tp_box.Color = Color3.fromRGB(120, 0, 0)
    tp_box.Transparency = 0.8
    tp_box.Size = Vector2.new(20, 20)
    tp_box.Position = Vector2.new(bg.Position.X + 10, bg.Position.Y + 35)
    tp_box.Visible = true

    local tp_text = Drawing.new("Text")
    tp_text.Text = "NoSpread: OFF"
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
    auto_text.Text = "RapidFire: OFF"
    auto_text.Position = Vector2.new(auto_box.Position.X + 30, auto_box.Position.Y + 3)
    auto_text.Color = Color3.fromRGB(255, 255, 255)
    auto_text.Outline = true
    auto_text.Visible = true

    return {
        bg = bg, title = title,
        tp_box = tp_box, tp_text = tp_text,
        auto_box = auto_box, auto_text = auto_text
    }
end

local gui = create_gui()

--> nospread function
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

--> firerate
local function firerate_nigger()
for i, v in next, game:GetService("ReplicatedStorage").Weapons:GetChildren() do
    for _, value in next, v:GetChildren() do
        if value.Name == "FireRate" then
            value.Value = -1;
            printl("Setted value for the weapon " .. v.Name);
        end;
    end;
end;
end

--> GUI visibility
local function set_ui_visible(state)
    ui_visible = state
    for _, v in pairs(gui) do
        if v and v.Visible ~= nil then
            v.Visible = state
        end
    end
end

--> GUI + hotkey control
local niggaballs = false

spawn(function()
    while true do
        wait(UPDATE_RATE)
        local mx, my = mouse.X, mouse.Y

        if ismouse1pressed() then
            -- ns toggle
            if mx >= gui.tp_box.Position.X and mx <= gui.tp_box.Position.X + gui.tp_box.Size.X and
               my >= gui.tp_box.Position.Y and my <= gui.tp_box.Position.Y + gui.tp_box.Size.Y then
                nospread_enable = not nospread_enable
                gui.tp_box.Color = nospread_enable and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(120, 0, 0)
                gui.tp_text.Text = nospread_enable and "NoSpread: ON" or "NoSpread: OFF"
                wait(0.25)
            end

            -- rf toggle
            if mx >= gui.auto_box.Position.X and mx <= gui.auto_box.Position.X + gui.auto_box.Size.X and
               my >= gui.auto_box.Position.Y and my <= gui.auto_box.Position.Y + gui.auto_box.Size.Y then
                firerate_enable = not firerate_enable
                gui.auto_box.Color = firerate_enable and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(120, 0, 0)
                gui.auto_text.Text = firerate_enable and "RapidFire: ON" or "RapidFire: OFF"
                wait(0.25)
            end
        else
            niggaballs = false
        end
    end
end)

--> hotkey toggles (F1, F2, F3)
spawn(function()
    while true do
        wait(0.1)
        if iskeypressed(112) then -- F1 = hide/show GUI
            set_ui_visible(not ui_visible)
            wait(0.4)
        elseif iskeypressed(113) then -- F2 = teleport toggle
            nospread_enable = not nospread_enable
            gui.tp_box.Color = nospread_enable and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(120, 0, 0)
            gui.tp_text.Text = nospread_enable and "NoSpread: ON" or "NoSpread: OFF"
            wait(0.4)
        elseif iskeypressed(114) then -- F3 = auto-walk toggle
            firerate_enable = not firerate_enable
            gui.auto_box.Color = firerate_enable and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(120, 0, 0)
            gui.auto_text.Text = firerate_enable and "RapidFire: ON" or "RapidFire: OFF"
            wait(0.4)
        end
    end
end)

--> main loop
spawn(function()
    while true do
        wait(TELEPORT_INTERVAL)
        if nospread_enable then nospread_nigger() end
        if firerate_enable then firerate_nigger() end
    end
end)
