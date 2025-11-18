local superadvancedconsoletextdisplay = "loaded"


local plot = game.Players.LocalPlayer.Stats.Plot.Value
local character = game.Players.LocalPlayer.Character

for _,v in pairs(plot.Builds:GetDescendants()) do
    if v.Name == "SellingStandDetect" then
        
        v.Size = Vector3.new(10000, 10000, 10000)
        v.Position = character.HumanoidRootPart.Position + Vector3.new(2, 0, 0)
    end
end
print("dihh", superadvancedconsoletextdisplay)
