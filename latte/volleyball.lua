local game = game
local replicated_storage = game:GetService("ReplicatedStorage")
local Drawing = Drawing
local Vector3 = Vector3
local Color3 = Color3
local Vector2 = Vector2
local wait = wait
local print = print
local warn = warn

local assets = replicated_storage:FindFirstChild("Assets")
if not assets then
    warn("cant find assets folder")
    return
end

local ball_folder = assets:FindFirstChild("Ball")
if not ball_folder then
    warn("cant find balls folder")
    return
end

local TARGET_SIZE = Vector3.new(1000, 1000, 1000)
local update_delay = 0.006
local total_meshes = 0

local gui_text = Drawing.new("Text")
gui_text.Text = "cold dihh"
gui_text.Position = Vector2.new(20, 20)
gui_text.Color = Color3.fromRGB(255, 255, 255)
gui_text.Outline = true
gui_text.Transparency = 0.8
gui_text.Visible = true

for _, model in ipairs(ball_folder:GetChildren()) do
    if model and model:IsA("Model") then
        for _, obj in ipairs(model:GetDescendants()) do
            if obj and obj:IsA("MeshPart") then
                obj.Size = TARGET_SIZE
                total_meshes = total_meshes + 1

                gui_text.Text = string.format(
                    "resized #%d | %s",
                    total_meshes,
                    obj.Name
                )

                wait(update_delay)
            end
        end
    end
end

gui_text.Text = string.format(
    "completed %d",
    total_meshes
)
print("meshpart resizing completed")

wait(2)
gui_text.Visible = false
gui_text:Remove()
