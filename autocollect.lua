-- ================= INITIAL GUI (ALWAYS APPEARS) =================
local Players = game:GetService("Players")
local player = Players.LocalPlayer

pcall(function()
	player.PlayerGui:FindFirstChild("XuanCollectorUI"):Destroy()
end)

local gui = Instance.new("ScreenGui")
gui.Name = "XuanCollectorUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 240, 0, 145)
frame.Position = UDim2.new(0.5, -120, 0.15, 0)
frame.BackgroundColor3 = Color3.fromRGB(255, 240, 245)
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.fromRGB(255, 105, 180)
frame.Active = true
frame.Draggable = true
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 15)

local gradient = Instance.new("UIGradient", frame)
gradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 240, 245)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 182, 193))
}
gradient.Rotation = 45

local titleBar = Instance.new("Frame", frame)
titleBar.Size = UDim2.new(1, 0, 0, 32)
titleBar.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
titleBar.BorderSizePixel = 0
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 15)

local title = Instance.new("TextLabel", titleBar)
title.Size = UDim2.new(1, 0, 1, 0)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "XUAN AUTO COLLECT"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Center


local shadow = Instance.new("ImageLabel", frame)
shadow.Size = UDim2.new(1, 20, 1, 20)
shadow.Position = UDim2.new(0, -10, 0, -10)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
shadow.ImageTransparency = 0.8
shadow.ZIndex = 0

local collectBtn = Instance.new("TextButton", frame)
collectBtn.Size = UDim2.new(0.9, 0, 0, 38)
collectBtn.Position = UDim2.new(0.05, 0, 0, 40)
collectBtn.BackgroundColor3 = Color3.fromRGB(255, 20, 147)
collectBtn.TextColor3 = Color3.new(0,0,0)
collectBtn.Font = Enum.Font.GothamBold
collectBtn.TextSize = 14
collectBtn.Text = "START COLLECTING"
collectBtn.AutoButtonColor = false
Instance.new("UICorner", collectBtn).CornerRadius = UDim.new(0, 10)

local btnGradient = Instance.new("UIGradient", collectBtn)
btnGradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 20, 147)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(219, 39, 119))
}
btnGradient.Rotation = 90

local btnStroke = Instance.new("UIStroke", collectBtn)
btnStroke.Color = Color3.fromRGB(255, 255, 255)
btnStroke.Thickness = 1.5
btnStroke.Transparency = 0.7

-- Hover effect for collect button
collectBtn.MouseEnter:Connect(function()
	collectBtn.Size = UDim2.new(0.92, 0, 0, 40)
	collectBtn.Position = UDim2.new(0.04, 0, 0, 39)
end)
collectBtn.MouseLeave:Connect(function()
	collectBtn.Size = UDim2.new(0.9, 0, 0, 38)
	collectBtn.Position = UDim2.new(0.05, 0, 0, 40)
end)

-- Auto Spin Button
local spinBtn = Instance.new("TextButton", frame)
spinBtn.Size = UDim2.new(0.9, 0, 0, 38)
spinBtn.Position = UDim2.new(0.05, 0, 0, 95)
spinBtn.BackgroundColor3 = Color3.fromRGB(255, 20, 147)
spinBtn.TextColor3 = Color3.new(0,0,0)
spinBtn.Font = Enum.Font.GothamBold
spinBtn.TextSize = 14
spinBtn.Text = "START SPINNING"
spinBtn.AutoButtonColor = false
Instance.new("UICorner", spinBtn).CornerRadius = UDim.new(0, 10)

local spinGradient = Instance.new("UIGradient", spinBtn)
spinGradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 20, 147)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(219, 39, 119))
}
spinGradient.Rotation = 90

local spinStroke = Instance.new("UIStroke", spinBtn)
spinStroke.Color = Color3.fromRGB(255, 255, 255)
spinStroke.Thickness = 1.5
spinStroke.Transparency = 0.7

-- Hover effect for spin button
spinBtn.MouseEnter:Connect(function()
	spinBtn.Size = UDim2.new(0.92, 0, 0, 40)
	spinBtn.Position = UDim2.new(0.04, 0, 0, 94)
end)
spinBtn.MouseLeave:Connect(function()
	spinBtn.Size = UDim2.new(0.9, 0, 0, 38)
	spinBtn.Position = UDim2.new(0.05, 0, 0, 95)
end)

-- ================= FUNCTIONALITY LOGIC =================

local character, humanoidRootPart
local EventFolder = nil

local PullDelay = 0.1
local HeightOffset = 3
local active = false
local spinning = false

-- Character handler (safe)
local function setupCharacter(char)
	character = char
	humanoidRootPart = char:WaitForChild("HumanoidRootPart", 10)
end

if player.Character then
	setupCharacter(player.Character)
end
player.CharacterAdded:Connect(setupCharacter)

-- Find EventParts WITHOUT BLOCKING GUI
task.spawn(function()
	while not EventFolder do
		EventFolder = workspace:FindFirstChild("EventParts")
		task.wait(1)
	end
end)

-- Model part
local function getModelPart(model)
	if model.PrimaryPart then return model.PrimaryPart end
	for _, v in ipairs(model:GetDescendants()) do
		if v:IsA("BasePart") then
			model.PrimaryPart = v
			return v
		end
	end
end

-- Loop to pull models
task.spawn(function()
	while true do
		if active and humanoidRootPart and EventFolder then
			for _, model in ipairs(EventFolder:GetChildren()) do
				if model:IsA("Model") then
					local part = getModelPart(model)
					if part then
						model:SetPrimaryPartCFrame(
							CFrame.new(humanoidRootPart.Position + Vector3.new(0, HeightOffset, 0))
						)
					end
				end
			end
		end
		task.wait(PullDelay)
	end
end)

-- Collect Button logic
collectBtn.MouseButton1Click:Connect(function()
	active = not active
	collectBtn.Text = active and "STOP COLLECTING" or "START COLLECTING"
	btnGradient.Color = active and ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(239, 68, 68)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(185, 28, 28))
	} or ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 20, 147)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(219, 39, 119))
	}
end)

-- Auto Spin logic
task.spawn(function()
	while true do
		if spinning then
			pcall(function()
				game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Net"):WaitForChild("RF/WheelSpin.Roll"):InvokeServer()
			end)
			task.wait(1)
		else
			task.wait(0.5)
		end
	end
end)

-- Spin Button logic
spinBtn.MouseButton1Click:Connect(function()
	spinning = not spinning
	spinBtn.Text = spinning and "STOP SPINNING" or "START SPINNING"
	spinGradient.Color = spinning and ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(239, 68, 68)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(185, 28, 28))
	} or ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 20, 147)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(219, 39, 119))
	}
end)
