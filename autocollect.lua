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
frame.Size = UDim2.new(0, 280, 0, 120)
frame.Position = UDim2.new(0.5, -140, 0.15, 0)
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
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
titleBar.BorderSizePixel = 0
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 15)

local title = Instance.new("TextLabel", titleBar)
title.Size = UDim2.new(1, -50, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "XUAN AUTO COLLECT"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left

local version = Instance.new("TextLabel", titleBar)
version.Size = UDim2.new(0, 35, 1, 0)
version.Position = UDim2.new(1, -40, 0, 0)
version.BackgroundTransparency = 1
version.Text = "V2.1"
version.TextColor3 = Color3.fromRGB(255, 255, 255)
version.Font = Enum.Font.GothamBold
version.TextSize = 11

local shadow = Instance.new("ImageLabel", frame)
shadow.Size = UDim2.new(1, 20, 1, 20)
shadow.Position = UDim2.new(0, -10, 0, -10)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
shadow.ImageTransparency = 0.8
shadow.ZIndex = 0

local toggleBtn = Instance.new("TextButton", frame)
toggleBtn.Size = UDim2.new(0.9, 0, 0, 50)
toggleBtn.Position = UDim2.new(0.05, 0, 0, 55)
toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 20, 147)
toggleBtn.TextColor3 = Color3.new(0,0,0)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 18
toggleBtn.Text = "START COLLECTING"
toggleBtn.AutoButtonColor = false
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 10)

local btnGradient = Instance.new("UIGradient", toggleBtn)
btnGradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 20, 147)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(219, 39, 119))
}
btnGradient.Rotation = 90

local btnStroke = Instance.new("UIStroke", toggleBtn)
btnStroke.Color = Color3.fromRGB(255, 255, 255)
btnStroke.Thickness = 1.5
btnStroke.Transparency = 0.7

-- Hover effect
toggleBtn.MouseEnter:Connect(function()
	toggleBtn.Size = UDim2.new(0.92, 0, 0, 52)
	toggleBtn.Position = UDim2.new(0.04, 0, 0, 54)
end)
toggleBtn.MouseLeave:Connect(function()
	toggleBtn.Size = UDim2.new(0.9, 0, 0, 50)
	toggleBtn.Position = UDim2.new(0.05, 0, 0, 55)
end)

-- ================= FUNCTIONALITY LOGIC =================

local character, humanoidRootPart
local EventFolder = nil

local PullDelay = 0.1
local HeightOffset = 3
local active = false

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

-- Button logic
toggleBtn.MouseButton1Click:Connect(function()
	active = not active
	toggleBtn.Text = active and "STOP COLLECTING" or "START COLLECTING"
	btnGradient.Color = active and ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(239, 68, 68)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(185, 28, 28))
	} or ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 20, 147)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(219, 39, 119))
	}
end)

