local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()

-- Configuration
local Config = {
	HitboxSize = Vector3.new(10, 10, 10),
	Transparency = 1,
	Notifications = false,
	ESPEnabled = true,
	HitboxEnabled = true,
	ESPBoxes = true,
	ESPNames = false,
	ESPTracers = false,
	ESPColor = Color3.fromRGB(255, 0, 4)
}

-- Store the time when the code starts executing
local start = os.clock()

-- Send initial notification
game.StarterGui:SetCore("SendNotification", {
	Title = "Script",
	Text = "Loading script...",
	Icon = "",
	Duration = 5
})

-- Load the ESP library
local esp = loadstring(game:HttpGet("https://raw.githubusercontent.com/andrewc0de/Roblox/main/Dependencies/ESP.lua"))()
esp:Toggle(Config.ESPEnabled)

-- Configure ESP settings
esp.Boxes = Config.ESPBoxes
esp.Names = Config.ESPNames
esp.Tracers = Config.ESPTracers
esp.Players = false

-- Add an object listener to the workspace to detect enemy models
esp:AddObjectListener(workspace, {
	Name = "soldier_model",
	Type = "Model",
	Color = Config.ESPColor,

	-- Specify the primary part of the model as the HumanoidRootPart
	PrimaryPart = function(obj)
		local root
		repeat
			root = obj:FindFirstChild("HumanoidRootPart")
			task.wait()
		until root
		return root
	end,

	-- Use a validator function to ensure that models do not have the "friendly_marker" child
	Validator = function(obj)
		task.wait(1)
		if obj:FindFirstChild("friendly_marker") then
			return false
		end
		return true
	end,

	-- Set a custom name to use for the enemy models
	CustomName = "Enemy",

	-- Enable the ESP for enemy models
	IsEnabled = "enemy"
})

-- Enable the ESP for enemy models
esp.enemy = true

-- Function to apply hitboxes
local function applyHitbox(model)
	if not Config.HitboxEnabled then return end
	
	local hrp = model:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	
	local pos = hrp.Position
	for _, bp in pairs(workspace:GetChildren()) do
		if bp:IsA("BasePart") then
			local distance = (bp.Position - pos).Magnitude
			if distance <= 5 then
				bp.Transparency = Config.Transparency
				bp.Size = Config.HitboxSize
			end
		end
	end
end

-- Wait for the game to load fully before applying hitboxes
task.wait(1)

-- Apply hitboxes to all existing enemy models in the workspace
for _, v in pairs(workspace:GetDescendants()) do
	if v.Name == "soldier_model" and v:IsA("Model") and not v:FindFirstChild("friendly_marker") then
		applyHitbox(v)
	end
end

-- Function to handle when a new descendant is added to the workspace
local function handleDescendantAdded(descendant)
	task.wait(1)

	-- If the new descendant is an enemy model
	if descendant.Name == "soldier_model" and descendant:IsA("Model") and not descendant:FindFirstChild("friendly_marker") then
		if Config.Notifications then
			game.StarterGui:SetCore("SendNotification", {
				Title = "Script",
				Text = "[Warning] New Enemy Spawned! Applied hitboxes.",
				Icon = "",
				Duration = 3
			})
		end

		-- Apply hitboxes to the new enemy model
		applyHitbox(descendant)
	end
end

-- Connect the handleDescendantAdded function to the DescendantAdded event of the workspace
task.spawn(function()
	game.Workspace.DescendantAdded:Connect(handleDescendantAdded)
end)

-- CREATE KAVO UI
local Window = Library.CreateLib("FRONTLINES", "DarkTheme")

-- ESP Tab
local ESPTab = Window:NewTab("ESP Settings")
local ESPSection = ESPTab:NewSection("ESP Configuration")

-- Enable ESP Toggle
ESPSection:NewToggle("Enable ESP", "Toggle ESP on/off", function(state)
	Config.ESPEnabled = state
	esp:Toggle(state)
end)

-- ESP Boxes Toggle
ESPSection:NewToggle("ESP Boxes", "Show boxes around enemies", function(state)
	Config.ESPBoxes = state
	esp.Boxes = state
end)

-- ESP Names Toggle
ESPSection:NewToggle("ESP Names", "Show enemy names", function(state)
	Config.ESPNames = state
	esp.Names = state
end)

-- ESP Tracers Toggle
ESPSection:NewToggle("ESP Tracers", "Show tracers to enemies", function(state)
	Config.ESPTracers = state
	esp.Tracers = state
end)

-- ESP Color Picker
ESPSection:NewColorPicker("ESP Color", "Change ESP color", Config.ESPColor, function(color)
	Config.ESPColor = color
	-- Note: Changing color requires reloading ESP
end)

-- Hitbox Tab
local HitboxTab = Window:NewTab("Hitbox Settings")
local HitboxSection = HitboxTab:NewSection("Hitbox Configuration")

-- Enable Hitbox Toggle
HitboxSection:NewToggle("Enable Hitbox", "Toggle hitbox expansion", function(state)
	Config.HitboxEnabled = state
end)

-- Hitbox Size X Slider
HitboxSection:NewSlider("Hitbox Size X", "Adjust hitbox X size", 50, 1, function(value)
	Config.HitboxSize = Vector3.new(value, Config.HitboxSize.Y, Config.HitboxSize.Z)
end)

-- Hitbox Size Y Slider
HitboxSection:NewSlider("Hitbox Size Y", "Adjust hitbox Y size", 50, 1, function(value)
	Config.HitboxSize = Vector3.new(Config.HitboxSize.X, value, Config.HitboxSize.Z)
end)

-- Hitbox Size Z Slider
HitboxSection:NewSlider("Hitbox Size Z", "Adjust hitbox Z size", 50, 1, function(value)
	Config.HitboxSize = Vector3.new(Config.HitboxSize.X, Config.HitboxSize.Y, value)
end)

-- Transparency Slider
HitboxSection:NewSlider("Transparency", "Adjust hitbox transparency (0=visible, 100=invisible)", 100, 0, function(value)
	Config.Transparency = value / 100
end)

-- Quick Presets
local PresetSection = HitboxTab:NewSection("Quick Presets")

PresetSection:NewButton("Small Hitbox (5x5x5)", "Set hitbox to small size", function()
	Config.HitboxSize = Vector3.new(5, 5, 5)
end)

PresetSection:NewButton("Medium Hitbox (10x10x10)", "Set hitbox to medium size", function()
	Config.HitboxSize = Vector3.new(10, 10, 10)
end)

PresetSection:NewButton("Large Hitbox (20x20x20)", "Set hitbox to large size", function()
	Config.HitboxSize = Vector3.new(20, 20, 20)
end)

PresetSection:NewButton("Huge Hitbox (30x30x30)", "Set hitbox to huge size", function()
	Config.HitboxSize = Vector3.new(30, 30, 30)
end)

-- Misc Tab
local MiscTab = Window:NewTab("Misc")
local MiscSection = MiscTab:NewSection("Other Settings")

-- Notifications Toggle
MiscSection:NewToggle("Enemy Spawn Notifications", "Get notified when enemies spawn", function(state)
	Config.Notifications = state
end)

-- Refresh Hitboxes Button
MiscSection:NewButton("Refresh All Hitboxes", "Reapply hitboxes to all enemies", function()
	for _, v in pairs(workspace:GetDescendants()) do
		if v.Name == "soldier_model" and v:IsA("Model") and not v:FindFirstChild("friendly_marker") then
			applyHitbox(v)
		end
	end
	game.StarterGui:SetCore("SendNotification", {
		Title = "Script",
		Text = "All hitboxes refreshed!",
		Icon = "",
		Duration = 3
	})
end)

-- Info Section
local InfoSection = MiscTab:NewSection("Information")

InfoSection:NewLabel("Script Version: 2.0")
InfoSection:NewLabel("Target: soldier_model")
InfoSection:NewLabel("Excludes: friendly_marker")

-- Keybind
InfoSection:NewKeybind("Toggle UI", "Toggle the UI visibility", Enum.KeyCode.RightControl, function()
	Library:ToggleUI()
end)

-- Store the time when the code finishes executing
local finish = os.clock()

-- Calculate how long the code took to run
local time = finish - start
local rating
if time < 3 then
	rating = "fast"
elseif time < 5 then
	rating = "acceptable"
else
	rating = "slow"
end

-- Send completion notification
game.StarterGui:SetCore("SendNotification", {
	Title = "Script",
	Text = string.format("Script loaded in %.2f seconds (%s loading)", time, rating),
	Icon = "",
	Duration = 5
})
