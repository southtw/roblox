local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local VirtualInputManager = nil
pcall(function() VirtualInputManager = game:GetService("VirtualInputManager") end)
local VirtualUser = nil
pcall(function() VirtualUser = game:GetService("VirtualUser") end)

local LocalPlayer = Players.LocalPlayer

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()

local Window = Library.CreateLib("Card Counter", "DarkTheme")

local MainTab = Window:NewTab("Main")
local MainSection = MainTab:NewSection("Card Counter")

local StatsTab = Window:NewTab("Stats")
local StatsSection = StatsTab:NewSection("Information")

local AutoOn = false
local AutoLoopThread = nil
local AutoAvailable = (VirtualInputManager ~= nil) or (VirtualUser ~= nil)

local RecommendationLabel = StatsSection:NewLabel("Recommendation: Waiting...")
local SafeChanceLabel = StatsSection:NewLabel("Safe Draw Chance: 0%")
local PointsNeededLabel = StatsSection:NewLabel("Points Needed: 0")
local OpponentExpectedLabel = StatsSection:NewLabel("Opponent Expected: 0")
local RemainingCardsLabel = StatsSection:NewLabel("Remaining Cards: None")

MainSection:NewToggle("Auto Play", "Based on recommendation", function(state)
    if not AutoAvailable then
        Library:Notification("Error", "Not supported click-sim method", "Okay")
        return
    end
    
    AutoOn = state
    if AutoOn then
        startAutoLoop()
        Library:Notification("Auto Play", "Auto play enabled!", "Okay")
    else
        stopAutoLoop()
        Library:Notification("Auto Play", "Auto play disabled!", "Okay")
    end
end)

-- Manual Controls
MainSection:NewButton("Take Card", "Manually take a card", function()
    local camera = workspace.CurrentCamera
    if not camera then return end
    
    local vx = camera.ViewportSize.X / 2
    local vy = camera.ViewportSize.Y / 2
    
    if VirtualInputManager then
        VirtualInputManager:SendMouseButtonEvent(vx, vy, 0, true, game, 1)
        task.wait(0.02)
        VirtualInputManager:SendMouseButtonEvent(vx, vy, 0, false, game, 1)
    elseif VirtualUser then
        VirtualUser:CaptureController()
        VirtualUser:Button1Down(Vector2.new(vx, vy))
        task.wait(0.02)
        VirtualUser:Button1Up(Vector2.new(vx, vy))
    end
end)

MainSection:NewButton("Hold", "Manually hold", function()
    local camera = workspace.CurrentCamera
    if not camera then return end
    
    local vx = camera.ViewportSize.X / 2
    local vy = camera.ViewportSize.Y / 2
    
    if VirtualInputManager then
        VirtualInputManager:SendMouseButtonEvent(vx, vy, 1, true, game, 1)
        task.wait(0.02)
        VirtualInputManager:SendMouseButtonEvent(vx, vy, 1, false, game, 1)
    elseif VirtualUser and VirtualUser.Button2Down then
        VirtualUser:CaptureController()
        VirtualUser:Button2Down(Vector2.new(vx, vy))
        task.wait(0.02)
        VirtualUser:Button2Up(Vector2.new(vx, vy))
    end
end)

local SettingsTab = Window:NewTab("Settings")
local SettingsSection = SettingsTab:NewSection("Settings")

local requiredSafeChanceBase = 0.50
SettingsSection:NewSlider("Safe Chance Threshold", "Minimum safe chance to take card", 100, 40, function(s)
    requiredSafeChanceBase = s / 100
end)

-- Auto Loop Function
function startAutoLoop()
    if AutoLoopThread then return end
    AutoLoopThread = task.spawn(function()
        while AutoOn do
            local camera = workspace.CurrentCamera
            if not camera then
                task.wait(1)
                continue
            end
            
            local vx = camera.ViewportSize.X / 2
            local vy = camera.ViewportSize.Y / 2

            local rec = ""
            pcall(function() 
                local recText = RecommendationLabel and tostring(RecommendationLabel) or ""
                rec = recText:upper()
            end)

            if rec:find("TAKE") then
                local function doLeftClick()
                    if VirtualInputManager then
                        VirtualInputManager:SendMouseButtonEvent(vx, vy, 0, true, game, 1)
                        task.wait(0.02)
                        VirtualInputManager:SendMouseButtonEvent(vx, vy, 0, false, game, 1)
                    elseif VirtualUser then
                        VirtualUser:CaptureController()
                        VirtualUser:Button1Down(Vector2.new(vx, vy))
                        task.wait(0.02)
                        VirtualUser:Button1Up(Vector2.new(vx, vy))
                    end
                end
                doLeftClick()
                task.wait(0.1)
                doLeftClick()

            elseif rec:find("HOLD") then
                local function doRightClick()
                    if VirtualInputManager then
                        VirtualInputManager:SendMouseButtonEvent(vx, vy, 1, true, game, 1)
                        task.wait(0.02)
                        VirtualInputManager:SendMouseButtonEvent(vx, vy, 1, false, game, 1)
                    elseif VirtualUser and VirtualUser.Button2Down then
                        VirtualUser:CaptureController()
                        VirtualUser:Button2Down(Vector2.new(vx, vy))
                        task.wait(0.02)
                        VirtualUser:Button2Up(Vector2.new(vx, vy))
                    end
                end
                doRightClick()
                task.wait(0.1)
                doRightClick()
            end

            task.wait(1)
        end
        AutoLoopThread = nil
    end)
end

function stopAutoLoop()
    AutoOn = false
end

local currentRecommendation = "Waiting..."

local function updateAdvisor()
    local cardsContainer = workspace.Room and workspace.Room:FindFirstChild("Cards")
    local opponentRoot = workspace.Room and workspace.Room.Opponent and workspace.Room.Opponent:FindFirstChild("HumanoidRootPart")
    local myCamera = workspace.Room and workspace.Room:FindFirstChild("Camera")

    local goalValue
    do
        local sumLabel = workspace.Room
            and workspace.Room.Main
            and workspace.Room.Main:FindFirstChild("YourCardsSum")
            and workspace.Room.Main.YourCardsSum:FindFirstChild("SurfaceGui")
            and workspace.Room.Main.YourCardsSum.SurfaceGui:FindFirstChild("TextLabel")
        if sumLabel and sumLabel:IsA("TextLabel") then
            goalValue = tonumber((sumLabel.Text or ""):match("%d+/(%d+)"))
        end
    end

    if not (cardsContainer and opponentRoot and myCamera and goalValue) then
        currentRecommendation = "Waiting..."
        RecommendationLabel:UpdateLabel("Recommendation: Waiting...")
        SafeChanceLabel:UpdateLabel("Safe Draw Chance: 0%")
        PointsNeededLabel:UpdateLabel("Points Needed: 0")
        OpponentExpectedLabel:UpdateLabel("Opponent Expected: 0")
        RemainingCardsLabel:UpdateLabel("Remaining Cards: None")
        return
    end

    local myCards, opponentCards = {}, {}
    for _, obj in ipairs(cardsContainer:GetChildren()) do
        if obj.Name == "Card" and obj:IsA("BasePart") then
            local scoreLabel = obj:FindFirstChild("Score") and obj.Score:FindFirstChild("TextLabel")
            local faceValue = scoreLabel and scoreLabel.Text or "[Hidden]"
            local distToOpponent = (obj.Position - opponentRoot.Position).Magnitude
            local distToMe = (obj.Position - myCamera.Position).Magnitude
            local owner = (distToOpponent < distToMe) and "Opponent" or "Me"
            if owner == "Me" then
                table.insert(myCards, faceValue)
            else
                table.insert(opponentCards, faceValue)
            end
        end
    end

    local function cardValue(v)
        if v == "L" then return 99 end
        return tonumber(v)
    end

    local mySum = 0
    for _, v in ipairs(myCards) do
        local n = cardValue(v)
        if n then mySum = mySum + n end
    end

    local oppKnownSum, oppHiddenCount = 0, 0
    for _, v in ipairs(opponentCards) do
        local n = cardValue(v)
        if n then
            oppKnownSum = oppKnownSum + n
        else
            oppHiddenCount = oppHiddenCount + 1
        end
    end

    local deck = {1,2,3,4,5,6,7,8,9,10,11}
    local visibleCards = {}
    for _, v in ipairs(myCards) do
        local n = tonumber(v)
        if n then table.insert(visibleCards, n) end
    end
    for _, v in ipairs(opponentCards) do
        local n = tonumber(v)
        if n then table.insert(visibleCards, n) end
    end
    for _, cardValue in ipairs(visibleCards) do
        for i, deckCard in ipairs(deck) do
            if deckCard == cardValue then
                table.remove(deck, i)
                break
            end
        end
    end

    local safeDraws, bustDraws = 0, 0
    for _, value in ipairs(deck) do
        if mySum + value <= goalValue then
            safeDraws += 1
        else
            bustDraws += 1
        end
    end
    local totalRemaining = safeDraws + bustDraws
    local safeChance = (totalRemaining > 0) and (safeDraws / totalRemaining) or 0

    local sumOfDeck = 0
    for _, v in ipairs(deck) do sumOfDeck += v end
    local avgDeckValue = (totalRemaining > 0) and (sumOfDeck / totalRemaining) or 0
    local oppExpectedSum = oppKnownSum + (oppHiddenCount * avgDeckValue)

    local pointsNeeded = goalValue - mySum
    local opponentBust = oppKnownSum > goalValue

    local requiredSafeChance = requiredSafeChanceBase
    local opponentAdvantage = math.max(0, oppExpectedSum - mySum)
    requiredSafeChance = requiredSafeChance - (opponentAdvantage * 0.05)
    requiredSafeChance = math.max(0.40, requiredSafeChance)

    if opponentBust then
        currentRecommendation = "HOLD (Opponent Bust)"
    elseif (1 - safeChance) >= 0.5 and oppExpectedSum <= mySum then
        currentRecommendation = "HOLD (Low Chance)"
    elseif safeChance >= requiredSafeChance then
        currentRecommendation = "TAKE"
    else
        currentRecommendation = "HOLD (Risky)"
    end

    local deckText = ""
    for i, card in ipairs(deck) do
        deckText = deckText .. card
        if i < #deck then deckText = deckText .. ", " end
    end

    RecommendationLabel:UpdateLabel("Recommendation: " .. currentRecommendation)
    SafeChanceLabel:UpdateLabel(string.format("Safe Draw Chance: %.1f%%", safeChance * 100))
    PointsNeededLabel:UpdateLabel("Points Needed: " .. pointsNeeded)
    OpponentExpectedLabel:UpdateLabel(string.format("Opponent Expected: %.1f", oppExpectedSum))
    RemainingCardsLabel:UpdateLabel("Remaining Cards: " .. deckText)
end

RunService.RenderStepped:Connect(updateAdvisor)
