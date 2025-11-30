local webhookUrl = ""

--/ main
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local JobEnded = ReplicatedStorage.Systems.Jobs.JobEnded
local BuyItem = ReplicatedStorage.Systems.Shop.BuyItem
local ConsumeFood = ReplicatedStorage.Systems.Food.ConsumeFood
local Warp = ReplicatedStorage.Systems.Teleport.Warp
local StartJob = ReplicatedStorage.Systems.Jobs.StartJob

local autoFarmEnabled = false
local isProcessing = false
local drinksToBuy = 4
local drinksToConsume = 4
local webhookEnabled = false

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

local Window = Library.CreateLib("Anime Life", "DarkTheme")

-- Main Tab
local MainTab = Window:NewTab("main")
local MainSection = MainTab:NewSection("auto farm")

MainSection:NewToggle("sword cutting", "Automatically farm sword cutting job", function(state)
    autoFarmEnabled = state
    if state then
        SendMessage(webhookUrl, "# 🟢 auto farm enabled")
    else
        SendMessage(webhookUrl, "# 🔴 auto farm disabled")
    end
end)

local ControlSection = MainTab:NewSection("settings")

ControlSection:NewSlider("Drinks to Buy", "Set number of sports drinks to buy", 10, 1, function(value)
    drinksToBuy = value
end)

ControlSection:NewSlider("Drinks to Consume", "Set number of sports drinks to consume", 10, 1, function(value)
    drinksToConsume = value
end)

local MiscSection = MainTab:NewSection("misc")

MiscSection:NewButton("Buy Sports Drinks", "Purchase sports drinks", function()
    for i = 1, drinksToBuy do
        pcall(function()
            BuyItem:InvokeServer("SportsDrink")
        end)
        wait(0.1)
    end
    SendMessage(webhookUrl, "# 🛒 Bought " .. drinksToBuy .. " sports drinks")
end)

MiscSection:NewButton("Consume Sports Drinks", "Consume sports drinks", function()
    for i = 1, drinksToConsume do
        pcall(function()
            ConsumeFood:FireServer("SportsDrink")
        end)
        wait(0.1)
    end
    SendMessage(webhookUrl, "# 🥤 Used " .. drinksToConsume .. " sports drinks")
end)

MiscSection:NewButton("TP to Sword Cutting", "Teleport to sword cutting location", function()
    Warp:InvokeServer(Vector3.new(-1818, 63, 2055))
end)

MiscSection:NewButton("Start Sword Cutting Job", "Start the sword cutting job", function()
    StartJob:FireServer("SwordCuttingGame")
    SendMessage(webhookUrl, "⚔️ Started Sword Cutting job")
end)

-- Webhook Tab
local WebhookTab = Window:NewTab("webhook")
local WebhookSection = WebhookTab:NewSection("discord webhook")
--[[
WebhookSection:NewTextBox("Webhook URL", "Enter your Discord webhook URL", function(txt)
    webhookUrl = txt
    SendMessage(webhookUrl, "# ✅ Webhook connected!")
end)
--]]

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

-- Job Completion Handler
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

-- Info Tab
local InfoTab = Window:NewTab("info")
local InfoSection = InfoTab:NewSection("settings")

InfoSection:NewKeybind("toggle ui", "kys", Enum.KeyCode.H, function()
    Library:ToggleUI()

end)
