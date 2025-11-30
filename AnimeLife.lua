local webhookUrl = ""

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local drinksToBuy = 4
local drinksToConsume = 4
local webhookEnabled = false

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NotificationGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = game:GetService("CoreGui")

local function createnoti(title, message, duration)
    duration = duration or 3

    local notifFrame = Instance.new("Frame")
    notifFrame.Size = UDim2.new(0, 300, 0, 80)
    notifFrame.Position = UDim2.new(0.5, -150, 1, 100)
    notifFrame.AnchorPoint = Vector2.new(0.5, 0)
    notifFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    notifFrame.BorderSizePixel = 0
    notifFrame.ClipsDescendants = true
    notifFrame.ZIndex = 999999
    notifFrame.Parent = ScreenGui

    local accent = Instance.new("Frame")
    accent.Size = UDim2.new(0, 3, 1, 0)
    accent.Position = UDim2.new(0, 0, 0, 0)
    accent.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
    accent.BorderSizePixel = 0
    accent.ZIndex = 999999
    accent.Parent = notifFrame

    task.spawn(function()
        local hue = 0
        while accent and accent.Parent do
            hue = (hue + 0.01) % 1
            accent.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
            task.wait(0.03)
        end
    end)

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -15, 0, 25)
    titleLabel.Position = UDim2.new(0, 12, 0, 8)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 16
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextYAlignment = Enum.TextYAlignment.Top
    titleLabel.ZIndex = 999999
    titleLabel.Parent = notifFrame

    local messageLabel = Instance.new("TextLabel")
    messageLabel.Size = UDim2.new(1, -15, 0, 40)
    messageLabel.Position = UDim2.new(0, 12, 0, 32)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = message
    messageLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    messageLabel.TextSize = 13
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextYAlignment = Enum.TextYAlignment.Top
    messageLabel.TextWrapped = true
    messageLabel.ZIndex = 999999
    messageLabel.Parent = notifFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = notifFrame

    notifFrame.Position = UDim2.new(0.5, -150, 1, 100)
    local slideIn = TweenService:Create(notifFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -150, 1, -100)
    })
    slideIn:Play()

    task.delay(duration, function()
        local slideOut = TweenService:Create(notifFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
            Position = UDim2.new(0.5, -150, 1, 100)
        })
        slideOut:Play()
        slideOut.Completed:Connect(function()
            notifFrame:Destroy()
        end)
    end)
end

-- Discord Webhook Functions
function SendMessage(url, message)
    if url == "" or not webhookEnabled then return end
    local headers = {
        ["Content-Type"] = "application/json"
    }
    local data = {
        ["content"] = message
    }
    local body = HttpService:JSONEncode(data)
    pcall(function()
        request({
            Url = url,
            Method = "POST",
            Headers = headers,
            Body = body
        })
    end)
end

function SendMessageEMBED(url, embed)
    if url == "" or not webhookEnabled then return end
    local headers = {
        ["Content-Type"] = "application/json"
    }
    local data = {
        ["embeds"] = {
            {
                ["title"] = embed.title,
                ["description"] = embed.description,
                ["color"] = embed.color,
                ["fields"] = embed.fields,
                ["footer"] = {
                    ["text"] = embed.footer.text
                },
                ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
            }
        }
    }
    local body = HttpService:JSONEncode(data)
    pcall(function()
        request({
            Url = url,
            Method = "POST",
            Headers = headers,
            Body = body
        })
    end)
end

local JobEnded = ReplicatedStorage.Systems.Jobs.JobEnded
local BuyItem = ReplicatedStorage.Systems.Shop.BuyItem
local ConsumeFood = ReplicatedStorage.Systems.Food.ConsumeFood
local Warp = ReplicatedStorage.Systems.Teleport.Warp
local StartJob = ReplicatedStorage.Systems.Jobs.StartJob

local autoFarmEnabled = false
local isProcessing = false
--local webhookEnabled = false
--local webhookURL = ""

local Window = Library.CreateLib("Anime Life", "Midnight")

local MainTab = Window:NewTab("main")
local MainSection = MainTab:NewSection("aura farm")

--[[
MainSection:NewButton("load pyro hub", "", function()
    shared.discord_key = "BREAKING_BAD"
loadstring(game:HttpGet("https://pyro.delivery/bundle.lua"))()
end)
--]]

local labelaf = MainSection:NewLabel("af state: ")
MainSection:NewToggle("sword cutting", "Automatically farm sword cutting job", function(state)
    autoFarmEnabled = state
    if state then
        SendMessage(webhookUrl, "# 🟢 auto farm enabled")
        createnoti("sword cutting: ", "Enabled", 3)
        labelaf:UpdateLabel("af state: Enabled")
    else
        SendMessage(webhookUrl, "# 🔴 auto farm disabled")
        createnoti("sword cutting: ", "Disabled", 3)
        labelaf:UpdateLabel("af state: Disabled")
    end
end)

local ControlSection = MainTab:NewSection("misc")
local labelml = ControlSection:NewLabel("log: ")

ControlSection:NewSlider("Drinks to Buy", "Set number of sports drinks to buy", 10, 1, function(value)
    drinksToBuy = value
end)

ControlSection:NewSlider("Drinks to Consume", "Set number of sports drinks to consume", 10, 1, function(value)
    drinksToConsume = value
end)

ControlSection:NewButton("buy sports drinks", "Purchase 4 sports drinks", function()
    for i = 1, drinksToBuy do
        pcall(function()
        BuyItem:InvokeServer("SportsDrink")
        end
        wait(0.1)
    end
    createnoti("bought:", " sd (4)", 3)
    labelml:UpdateLabel("log: Bought 4 Sports Drinks")
end)

ControlSection:NewButton("consume sports drinks", "Consume 4 sports drinks", function()
    for i = 1, drinksToBuy do
        pcall(function()
        ConsumeFood:FireServer("SportsDrink")
        end
        wait(0.1)
    end
    createnoti("consumed:", "sd (4)", 3)
    labelml:UpdateLabel("log: Consumed 4 Sports Drinks")
end)


ControlSection:NewButton("TP to Sword Cutting", "Teleport to sword cutting location", function()
    Warp:InvokeServer(Vector3.new(-1818, 63, 2055))
    createnoti("tp:", "sc", 3)
    labelml:UpdateLabel("log: Teleported to Sword Cutting")
end)
--[[
ControlSection:NewButton("TP to home (default)", "Teleport to sword cutting location", function()
    Warp:InvokeServer(Vector3.new(-1818, 63, 2055))
    labelml:UpdateLabel("log: Teleported to Sword Cutting")
end)
--]]
ControlSection:NewButton("Start Sword Cutting Job", "Start the sword cutting job", function()
    StartJob:FireServer("SwordCuttingGame")
    createnoti("started:", "sc job", 3)
    labelml:UpdateLabel("log: Started Sword Cutting Job")
end)

local InfoTab = Window:NewTab("logs")
--[[
local WebhookSection = InfoTab:NewSection("discord")

WebhookSection:NewTextBox("webhook url", "enter your discord webhook url", function(txt)
    webhookURL = txt
    createnoti("webhook URL set", "", 3)
end)

WebhookSection:NewToggle("enable webhook", "send notifications to discord", function(state)
    webhookEnabled = state
    if state then
        if webhookURL == "" then
            createnoti("warn:", "please enter a webhook URL first", 2)
            webhookEnabled = false
        else
            createnoti("enabled:", "discord webhook", 2)
        end
    else
        createnoti("disabled:", "discord webhook", 2)
    end
end)
--]]

local InfoSection = InfoTab:NewSection("script info -")
InfoSection:NewLabel("log:")
local labelafstate = InfoSection:NewLabel("")
InfoSection:NewLabel("warn:")
local labelafwarn = InfoSection:NewLabel("")

--[[
local function sendWebhook(message)
    if not webhookEnabled or webhookURL == "" then return end
    
    local success, err = pcall(function()
        local http = game:GetService("HttpService")
        local data = {
            ["content"] = message,
            ["username"] = "Goon Life",
            ["avatar_url"] = "https://cdn.discordapp.com/attachments/1427844208806465588/1427846803272765641/image.png"
        }
        
        local jsonData = http:JSONEncode(data)
        http:PostAsync(webhookURL, jsonData, Enum.HttpContentType.ApplicationJson)
    end)
    
    if not success then
        warn("failed to send webhook:", err)
    end
end
--]]

local WebhookTab = Window:NewTab("webhook")
local WebhookSection = WebhookTab:NewSection("discord webhook")

WebhookSection:NewToggle("Enable Webhook", "Toggle webhook notifications", function(state)
    webhookEnabled = state
end)

WebhookSection:NewButton("Test Webhook", "Send test message", function()
    local embed = {
        ["title"] = "Anime Life",
        ["description"] = " ",
        ["color"] = 3447003,
        ["fields"] = {
            {
                ["name"] = "Status",
                ["value"] = "✅"
            },
            {
                ["name"] = "Auto Farm",
                ["value"] = autoFarmEnabled and "🟢" or "🔴"
            }
        },
        ["footer"] = {
            ["text"] = "Test notification"
        }
    }
    SendMessageEMBED(webhookUrl, embed)
end)

--[[
local function onJobEnded()
    if not autoFarmEnabled or isProcessing then return end
    
    isProcessing = true

    jobCount = jobCount + 1
    --SendMessage(url, "detected job ended")
    createnoti("job ended - ", "starting autofarm", 3)
    labelafstate:UpdateLabel("Job Ended - Starting Auto Process")

    wait(1)

    --SendMessage(url, "buying sd (4)")
    createnoti("buying sd (4)", "", 3)
    labelafstate:UpdateLabel("Buying 4 Sports Drinks...")
    for i = 1, 4 do
        local success, err = pcall(function()
            BuyItem:InvokeServer("SportsDrink")
        end)
        if not success then
            createnoti("warn: failed to buy sd", "", 3)
            labelafwarn:UpdateLabel("Failed to buy sports drink:", err)
        end
        wait(0.2)
    end

    --SendMessage(url, "consuming sd (4)")
    createnoti("consuming sd (4)", "", 3)
    labelafstate:UpdateLabel("Consuming 4 Sports Drinks...")
    for i = 1, 4 do
        local success, err = pcall(function()
            ConsumeFood:FireServer("SportsDrink")
        end)
        if not success then
            createnoti("warn: failed to consume", "", 3)
            labelafwarn:UpdateLabel("Failed to consume sports drink:", err)
        end
        wait(0.2)
    end

    --make sure sc job work
    --SendMessage(url, "tping to sc")
    createnoti("tping to sc", "", 3)
    labelafstate:UpdateLabel("Teleporting to Sword Cutting...")
    wait(0.5)
    local success, err = pcall(function()
        Warp:InvokeServer(Vector3.new(-1818, 63, 2055))
    end)
    if not success then
        createnoti("failed to tp", "", 3)
        labelafwarn:UpdateLabel("Failed to teleport:", err)
    end

    wait(1)

    --SendMessage(url, "starting sc job")
    createnoti("starting sc job", "", 3)
    labelafstate:UpdateLabel("Starting Sword Cutting Job...")
    local success, err = pcall(function()
        StartJob:FireServer("SwordCuttingGame")
    end)
    if not success then
        createnoti("warn: failed to start job", "", 3)
        labelafwarn:UpdateLabel("Failed to start job:", err)
    end
    --SendMessage(url, "waiting for next job")
    createnoti("waiting...", "", 3)
    labelafstate:UpdateLabel("waiting for next job end")
    isProcessing = false
end

JobEnded.OnClientEvent:Connect(onJobEnded)

local nigga = Window:NewTab("info")
local nisec = nigga:NewSection("start a job first")
nisec:NewKeybind("toggle ui", "kys", Enum.KeyCode.H, function()
	Library:ToggleUI()
end)


local success, err = pcall(function()
    local calendar = LocalPlayer.PlayerGui:WaitForChild("HUD"):WaitForChild("TopRight"):WaitForChild("Calendar")
    if calendar then
        calendar:Destroy()
    end
end)
if not success then
warn("error:", err)
end


local success2, err2 = pcall(function()
    local analyticsError = ReplicatedStorage:WaitForChild("GameAnalyticsError")
    if analyticsError then
        analyticsError:Destroy()
    end
end)
if not success2 then
    warn("error:", err2)
end

--]]

--[[ Discord Webhook
function SendMessage(url, message)
    local http = game:GetService("HttpService")
    local headers = {
        ["Content-Type"] = "application/json"
    }
    local data = {
        ["content"] = message
    }
    local body = http:JSONEncode(data)
    local response = request({
        Url = url,
        Method = "POST",
        Headers = headers,
        Body = body
    })
end

function SendMessageEMBED(url, embed)
    local http = game:GetService("HttpService")
    local headers = {
        ["Content-Type"] = "application/json"
    }
    local data = {
        ["embeds"] = {
            {
                ["title"] = embed.title,
                ["description"] = embed.description,
                ["color"] = embed.color,
                ["fields"] = embed.fields,
                ["footer"] = {
                    ["text"] = embed.footer.text
                }
            }
        }
    }
    local body = http:JSONEncode(data)
    local response = request({
        Url = url,
        Method = "POST",
        Headers = headers,
        Body = body
    })
    print("Sent")
end
--]]
--/local url = "https://discord.com/api/webhooks/1427848569985040414/dgFdkp_c6kUBcpGcxA8W-ZhKlFSipGbhipE0xX9_hnoi4yCTrePL7i-LGNT1FiEl9Mcd"

local jobCount = 0
local function onJobEnded()
    if not autoFarmEnabled or isProcessing then return end
   
    isProcessing = true
    jobCount = jobCount + 1
    
    wait(1)
    
    for i = 1, drinksToBuy do
        pcall(function()
            BuyItem:InvokeServer("SportsDrink")
        end)
        wait(0.2)
    end
    
    for i = 1, drinksToConsume do
        pcall(function()
            ConsumeFood:FireServer("SportsDrink")
        end)
        wait(0.2)
    end
    
    wait(0.5)
    pcall(function()
        Warp:InvokeServer(Vector3.new(-1818, 63, 2055))
    end)
    
    wait(1)
    pcall(function()
        StartJob:FireServer("SwordCuttingGame")
    end)
    
    -- Send embed notification
    local embed = {
        ["title"] = "Kamidere - Released",
        ["description"] = "Job Completed",
        ["color"] = 5763719,
        ["fields"] = {
            {
                ["name"] = "Jobs Completed",
                ["value"] = tostring(jobCount)
            },
            {
                ["name"] = "Drinks Bought",
                ["value"] = tostring(drinksToBuy)
            },
            {
                ["name"] = "Drinks Used",
                ["value"] = tostring(drinksToConsume)
            }
        },
        ["footer"] = {
            ["text"] = "Auto farming..."
        }
    }
    SendMessageEMBED(webhookUrl, embed)
    
    isProcessing = false
end

JobEnded.OnClientEvent:Connect(onJobEnded)


createnoti("script loaded", "nigger", 3)

