local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Player = Players.LocalPlayer
local PlayerGui = Player.PlayerGui

-- State
local Running = false
local IsShooting = false
local IsMinimized = false
local ShotStartTime = 0
local TargetDelay = 0.68 -- Default starting time preference
local ScanConnection = nil

-- Clean UI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CleanHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = PlayerGui

-- Main Window Container
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 620, 0, 400)
MainFrame.Position = UDim2.new(0.5, -310, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainFrame.BackgroundTransparency = 0.02
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(40, 40, 40)
UIStroke.Thickness = 1
UIStroke.Parent = MainFrame

-- Subtle Drop Shadow
local Shadow = Instance.new("ImageLabel")
Shadow.Name = "Shadow"
Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
Shadow.Position = UDim2.new(0.5, 0, 0.5, 6)
Shadow.Size = UDim2.new(1, 32, 1, 32)
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxassetid://1316045217"
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.6
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(10, 10, 118, 118)
Shadow.ZIndex = -1
Shadow.Parent = MainFrame

-- Top Navigation / Header Bar
local HeaderBar = Instance.new("Frame")
HeaderBar.Name = "HeaderBar"
HeaderBar.Size = UDim2.new(1, 0, 0, 64)
HeaderBar.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
HeaderBar.BorderSizePixel = 0
HeaderBar.Parent = MainFrame

local HeaderDivider = Instance.new("Frame")
HeaderDivider.Name = "HeaderDivider"
HeaderDivider.Size = UDim2.new(1, 0, 0, 1)
HeaderDivider.Position = UDim2.new(0, 0, 1, -1)
HeaderDivider.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
HeaderDivider.BorderSizePixel = 0
HeaderDivider.Parent = HeaderBar

-- Title Text
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0, 150, 0, 20)
TitleLabel.Position = UDim2.new(0, 20, 0, 22)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Countx"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 16
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = HeaderBar

-- Minimize and Close Controls
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(1, -16, 0, 20)
CloseBtn.AnchorPoint = Vector2.new(1, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(220, 80, 80)
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = HeaderBar

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 24, 0, 24)
MinBtn.Position = UDim2.new(1, -46, 0, 20)
MinBtn.AnchorPoint = Vector2.new(1, 0)
MinBtn.BackgroundTransparency = 1
MinBtn.Text = "—"
MinBtn.TextColor3 = Color3.fromRGB(160, 160, 160)
MinBtn.TextSize = 12
MinBtn.Font = Enum.Font.GothamBold
MinBtn.Parent = HeaderBar

-- Left Sidebar Navigation
local Sidebar = Instance.new("ScrollingFrame")
Sidebar.Size = UDim2.new(0, 175, 1, -64)
Sidebar.Position = UDim2.new(0, 0, 0, 64)
Sidebar.BackgroundColor3 = Color3.fromRGB(3, 3, 3)
Sidebar.BorderSizePixel = 0
Sidebar.CanvasSize = UDim2.new(0, 0, 0, 200)
Sidebar.ScrollBarThickness = 2
Sidebar.Parent = MainFrame

local SidebarDivider = Instance.new("Frame")
SidebarDivider.Size = UDim2.new(0, 1, 1, 0)
SidebarDivider.Position = UDim2.new(1, -1, 0, 0)
SidebarDivider.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
SidebarDivider.BorderSizePixel = 0
SidebarDivider.Parent = Sidebar

local TabShooting = Instance.new("TextButton")
TabShooting.Size = UDim2.new(1, -16, 0, 42)
TabShooting.Position = UDim2.new(0, 8, 0, 12)
TabShooting.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
TabShooting.BorderSizePixel = 0
TabShooting.Text = ""
TabShooting.AutoButtonColor = false
TabShooting.Parent = Sidebar

local TabCorner = Instance.new("UICorner")
TabCorner.CornerRadius = UDim.new(0, 8)
TabCorner.Parent = TabShooting

local TabLabel = Instance.new("TextLabel")
TabLabel.Size = UDim2.new(1, -20, 1, 0)
TabLabel.Position = UDim2.new(0, 16, 0, 0)
TabLabel.BackgroundTransparency = 1
TabLabel.Text = "Shooting"
TabLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TabLabel.TextSize = 12
TabLabel.Font = Enum.Font.GothamBold
TabLabel.TextXAlignment = Enum.TextXAlignment.Left
TabLabel.Parent = TabShooting

-- Content Area Panel
local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -175, 1, -64)
ContentArea.Position = UDim2.new(0, 175, 0, 64)
ContentArea.BackgroundTransparency = 1
ContentArea.ClipsDescendants = true
ContentArea.Parent = MainFrame

-- Feature Section Heading inside Content Area
local SectionTitle = Instance.new("TextLabel")
SectionTitle.Size = UDim2.new(0, 200, 0, 18)
SectionTitle.Position = UDim2.new(0, 20, 0, 14)
SectionTitle.BackgroundTransparency = 1
SectionTitle.Text = "AUTO GREEN"
SectionTitle.TextColor3 = Color3.fromRGB(170, 170, 170)
SectionTitle.TextSize = 11
SectionTitle.Font = Enum.Font.GothamBold
SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
SectionTitle.Parent = ContentArea

local SectionDesc = Instance.new("TextLabel")
SectionDesc.Size = UDim2.new(1, -40, 0, 30)
SectionDesc.Position = UDim2.new(0, 20, 0, 32)
SectionDesc.BackgroundTransparency = 1
SectionDesc.Text = "Automatically cuts and releases your shot at your specified time preference."
SectionDesc.TextColor3 = Color3.fromRGB(140, 140, 140)
SectionDesc.TextSize = 10
SectionDesc.Font = Enum.Font.Gotham
SectionDesc.TextXAlignment = Enum.TextXAlignment.Left
SectionDesc.TextWrapped = true
SectionDesc.Parent = ContentArea

-- TIME PREFERENCE BAR (NEW)
local TimeCard = Instance.new("Frame")
TimeCard.Size = UDim2.new(1, -40, 0, 42)
TimeCard.Position = UDim2.new(0, 20, 0, 68)
TimeCard.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
TimeCard.BorderSizePixel = 0
TimeCard.Parent = ContentArea

local TimeCardCorner = Instance.new("UICorner")
TimeCardCorner.CornerRadius = UDim.new(0, 8)
TimeCardCorner.Parent = TimeCard

local TimeCardStroke = Instance.new("UIStroke")
TimeCardStroke.Color = Color3.fromRGB(30, 30, 30)
TimeCardStroke.Thickness = 1
TimeCardStroke.Parent = TimeCard

local TimeCardLabel = Instance.new("TextLabel")
TimeCardLabel.Size = UDim2.new(1, -100, 1, 0)
TimeCardLabel.Position = UDim2.new(0, 16, 0, 0)
TimeCardLabel.BackgroundTransparency = 1
TimeCardLabel.Text = "Target Time (Seconds)"
TimeCardLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
TimeCardLabel.TextSize = 12
TimeCardLabel.Font = Enum.Font.GothamMedium
TimeCardLabel.TextXAlignment = Enum.TextXAlignment.Left
TimeCardLabel.Parent = TimeCard

local TimeTextBox = Instance.new("TextBox")
TimeTextBox.Size = UDim2.new(0, 70, 0, 26)
TimeTextBox.Position = UDim2.new(1, -12, 0.5, 0)
TimeTextBox.AnchorPoint = Vector2.new(1, 0.5)
TimeTextBox.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
TimeTextBox.BorderSizePixel = 0
TimeTextBox.Text = "0.68"
TimeTextBox.PlaceholderText = "0.68"
TimeTextBox.PlaceholderColor3 = Color3.fromRGB(90, 90, 90)
TimeTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
TimeTextBox.TextSize = 12
TimeTextBox.Font = Enum.Font.GothamBold
TimeTextBox.ClearTextOnFocus = false
TimeTextBox.Parent = TimeCard

local TimeBoxCorner = Instance.new("UICorner")
TimeBoxCorner.CornerRadius = UDim.new(0, 6)
TimeBoxCorner.Parent = TimeTextBox

local TimeBoxStroke = Instance.new("UIStroke")
TimeBoxStroke.Color = Color3.fromRGB(50, 50, 50)
TimeBoxStroke.Thickness = 1
TimeBoxStroke.Parent = TimeTextBox

-- Toggle Card Container
local ToggleCard = Instance.new("Frame")
ToggleCard.Size = UDim2.new(1, -40, 0, 48)
ToggleCard.Position = UDim2.new(0, 20, 0, 116)
ToggleCard.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
ToggleCard.BorderSizePixel = 0
ToggleCard.Parent = ContentArea

local CardCorner = Instance.new("UICorner")
CardCorner.CornerRadius = UDim.new(0, 8)
CardCorner.Parent = ToggleCard

local CardStroke = Instance.new("UIStroke")
CardStroke.Color = Color3.fromRGB(30, 30, 30)
CardStroke.Thickness = 1
CardStroke.Parent = ToggleCard

local ToggleCardLabel = Instance.new("TextLabel")
ToggleCardLabel.Size = UDim2.new(1, -70, 1, 0)
ToggleCardLabel.Position = UDim2.new(0, 16, 0, 0)
ToggleCardLabel.BackgroundTransparency = 1
ToggleCardLabel.Text = "Auto Green"
ToggleCardLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
ToggleCardLabel.TextSize = 13
ToggleCardLabel.Font = Enum.Font.GothamMedium
ToggleCardLabel.TextXAlignment = Enum.TextXAlignment.Left
ToggleCardLabel.Parent = ToggleCard

-- Checkbox/Toggle Switch button inside Hub
local SwitchButton = Instance.new("TextButton")
SwitchButton.Size = UDim2.new(0, 28, 0, 28)
SwitchButton.Position = UDim2.new(1, -22, 0.5, 0)
SwitchButton.AnchorPoint = Vector2.new(1, 0.5)
SwitchButton.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
SwitchButton.BorderSizePixel = 0
SwitchButton.Text = ""
SwitchButton.AutoButtonColor = false
SwitchButton.Parent = ToggleCard

local SwitchCorner = Instance.new("UICorner")
SwitchCorner.CornerRadius = UDim.new(1, 0)
SwitchCorner.Parent = SwitchButton

local SwitchStroke = Instance.new("UIStroke")
SwitchStroke.Color = Color3.fromRGB(150, 150, 150)
SwitchStroke.Thickness = 2
SwitchStroke.Parent = SwitchButton

local SwitchDot = Instance.new("Frame")
SwitchDot.Size = UDim2.new(0, 0, 0, 0)
SwitchDot.AnchorPoint = Vector2.new(0.5, 0.5)
SwitchDot.Position = UDim2.new(0.5, 0, 0.5, 0)
SwitchDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SwitchDot.BorderSizePixel = 0
SwitchDot.Parent = SwitchButton

local DotCorner = Instance.new("UICorner")
DotCorner.CornerRadius = UDim.new(1, 0)
DotCorner.Parent = SwitchDot

-- Panic Button Inside Hub
local PanicButton = Instance.new("TextButton")
PanicButton.Size = UDim2.new(1, -40, 0, 36)
PanicButton.Position = UDim2.new(0, 20, 0, 178)
PanicButton.BackgroundColor3 = Color3.fromRGB(30, 10, 10)
PanicButton.BorderSizePixel = 0
PanicButton.AutoButtonColor = false
PanicButton.Text = "PANIC STOP (UNLOAD)"
PanicButton.TextColor3 = Color3.fromRGB(255, 100, 100)
PanicButton.TextSize = 11
PanicButton.Font = Enum.Font.GothamBold
PanicButton.Parent = ContentArea

local PanicCorner = Instance.new("UICorner")
PanicCorner.CornerRadius = UDim.new(0, 8)
PanicCorner.Parent = PanicButton

local PanicStroke = Instance.new("UIStroke")
PanicStroke.Color = Color3.fromRGB(100, 30, 30)
PanicStroke.Thickness = 1
PanicStroke.Parent = PanicButton

-- Status feedback label under Panic Button
local StatusFeedback = Instance.new("TextLabel")
StatusFeedback.Size = UDim2.new(1, -40, 0, 20)
StatusFeedback.Position = UDim2.new(0, 20, 0, 222)
StatusFeedback.BackgroundTransparency = 1
StatusFeedback.Text = "Status: Ready (Custom Timer Ready)"
StatusFeedback.TextColor3 = Color3.fromRGB(110, 110, 110)
StatusFeedback.TextSize = 11
StatusFeedback.Font = Enum.Font.GothamMedium
StatusFeedback.TextXAlignment = Enum.TextXAlignment.Left
StatusFeedback.Parent = ContentArea

-- Tween Helper Function
local function tween(obj, props, time, style, dir)
	local tw = TweenService:Create(obj, TweenInfo.new(time or 0.25, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
	tw:Play()
	return tw
end

local function updateStatusText(text, color)
	StatusFeedback.Text = text
	StatusFeedback.TextColor3 = color or Color3.fromRGB(110, 110, 110)
end

-- Update TargetDelay from TextBox Input
TimeTextBox.FocusLost:Connect(function()
	local val = tonumber(TimeTextBox.Text)
	if val and val > 0 then
		TargetDelay = val
		updateStatusText("Status: Timer set to " .. val .. "s", Color3.fromRGB(150, 220, 255))
	else
		TimeTextBox.Text = tostring(TargetDelay)
	end
end)

-- Timer-based Scanner (Heartbeat) using Custom TargetDelay
local function startScanning()
	if ScanConnection then ScanConnection:Disconnect() end
	ScanConnection = RunService.Heartbeat:Connect(function()
		if not Running then return end
		
		if IsShooting then
			local elapsedTime = tick() - ShotStartTime
			if elapsedTime >= TargetDelay then
				pcall(function()
					VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
				end)
				IsShooting = false
				updateStatusText("Status: " .. TargetDelay .. "s Barrier Hit ✓", Color3.fromRGB(150, 255, 150))
				task.wait(0.3)
				if Running then
					updateStatusText("Status: Active (" .. TargetDelay .. "s Timer Guard)", Color3.fromRGB(200, 200, 200))
				end
			end
		end
	end)
end

local function stopScanning()
	if ScanConnection then
		ScanConnection:Disconnect()
		ScanConnection = nil
	end
end

-- Input Listeners for Shooting (Press 'E')
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not Running then return end
	if input.KeyCode == Enum.KeyCode.E then
		IsShooting = true
		ShotStartTime = tick()
		updateStatusText("Status: Guard Armed (Waiting for " .. TargetDelay .. "s)...", Color3.fromRGB(220, 220, 220))
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.E and IsShooting then
		IsShooting = false
		pcall(function()
			VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
		end)
		if Running then
			updateStatusText("Status: Active (" .. TargetDelay .. "s Timer Guard)", Color3.fromRGB(200, 200, 200))
		end
	end
end)

-- Toggle State Logic
local function setToggleState(on)
	Running = on
	IsShooting = false
	if on then
		tween(SwitchButton, {BackgroundColor3 = Color3.fromRGB(255, 255, 255)}, 0.2)
		tween(SwitchDot, {Size = UDim2.new(0, 16, 0, 16)}, 0.2)
		updateStatusText("Status: Active (" .. TargetDelay .. "s Timer Guard)", Color3.fromRGB(200, 200, 200))
		startScanning()
	else
		tween(SwitchButton, {BackgroundColor3 = Color3.fromRGB(15, 15, 15)}, 0.2)
		tween(SwitchDot, {Size = UDim2.new(0, 0, 0, 0)}, 0.2)
		updateStatusText("Status: Ready (Standby)", Color3.fromRGB(110, 110, 110))
		stopScanning()
	end
end

SwitchButton.MouseButton1Click:Connect(function()
	setToggleState(not Running)
end)

-- Panic Button / Close UI
PanicButton.MouseButton1Click:Connect(function()
	Running = false
	stopScanning()
	ScreenGui:Destroy()
end)

CloseBtn.MouseButton1Click:Connect(function()
	Running = false
	stopScanning()
	ScreenGui:Destroy()
end)

MinBtn.MouseButton1Click:Connect(function()
	IsMinimized = not IsMinimized
	if IsMinimized then
		MinBtn.Text = "+"
		tween(MainFrame, {Size = UDim2.new(0, 620, 0, 64)}, 0.25)
		Sidebar.Visible = false
		ContentArea.Visible = false
	else
		MinBtn.Text = "—"
		tween(MainFrame, {Size = UDim2.new(0, 620, 0, 400)}, 0.25)
		Sidebar.Visible = true
		ContentArea.Visible = true
	end
end)
