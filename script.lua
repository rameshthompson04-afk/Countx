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
local TargetDelay = 0.68 
local PredictionOffset = 0.03 
local ScanConnection = nil

-- Speed Hack State
local SpeedEnabled = false
local WalkSpeedValue = 24 
local SpeedConnection = nil

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
MainFrame.Size = UDim2.new(0, 620, 0, 420)
MainFrame.Position = UDim2.new(0.5, -310, 0.5, -210)
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

-- Left Sidebar Navigation matching image style
local Sidebar = Instance.new("ScrollingFrame")
Sidebar.Size = UDim2.new(0, 185, 1, -64)
Sidebar.Position = UDim2.new(0, 0, 0, 64)
Sidebar.BackgroundColor3 = Color3.fromRGB(3, 3, 3)
Sidebar.BorderSizePixel = 0
Sidebar.CanvasSize = UDim2.new(0, 0, 0, 300)
Sidebar.ScrollBarThickness = 2
Sidebar.Parent = MainFrame

local SidebarDivider = Instance.new("Frame")
SidebarDivider.Size = UDim2.new(0, 1, 1, 0)
SidebarDivider.Position = UDim2.new(1, -1, 0, 0)
SidebarDivider.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
SidebarDivider.BorderSizePixel = 0
SidebarDivider.Parent = Sidebar

-- Helper function to create styled tabs with circular ring icons matching user image
local function createSidebarTab(name, text, yPos, isActive)
    local tab = Instance.new("TextButton")
    tab.Name = name .. "Tab"
    tab.Size = UDim2.new(1, -16, 0, 46)
    tab.Position = UDim2.new(0, 8, 0, yPos)
    tab.BackgroundColor3 = isActive and Color3.fromRGB(25, 20, 35) or Color3.fromRGB(12, 10, 18)
    tab.BorderSizePixel = 0
    tab.Text = ""
    tab.AutoButtonColor = false
    tab.Parent = Sidebar

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = tab

    local stroke = Instance.new("UIStroke")
    stroke.Color = isActive and Color3.fromRGB(140, 100, 190) or Color3.fromRGB(40, 30, 55)
    stroke.Thickness = 1
    stroke.Parent = tab

    -- Icon Container (Circular Target Ring matching your screenshot)
    local iconOuter = Instance.new("Frame")
    iconOuter.Size = UDim2.new(0, 24, 0, 24)
    iconOuter.Position = UDim2.new(0, 12, 0.5, -12)
    iconOuter.BackgroundTransparency = 1
    iconOuter.Parent = tab

    local ring1 = Instance.new("UIStroke")
    ring1.Color = isActive and Color3.fromRGB(190, 140, 255) or Color3.fromRGB(80, 70, 100)
    ring1.Thickness = 1.5
    ring1.Parent = iconOuter
    local ringCorner1 = Instance.new("UICorner")
    ringCorner1.CornerRadius = UDim.new(1, 0)
    ringCorner1.Parent = iconOuter

    local iconInner = Instance.new("Frame")
    iconInner.Size = UDim2.new(0, 12, 0, 12)
    iconInner.AnchorPoint = Vector2.new(0.5, 0.5)
    iconInner.Position = UDim2.new(0.5, 0, 0.5, 0)
    iconInner.BackgroundTransparency = 1
    iconInner.Parent = iconOuter

    local ring2 = Instance.new("UIStroke")
    ring2.Color = isActive and Color3.fromRGB(190, 140, 255) or Color3.fromRGB(80, 70, 100)
    ring2.Thickness = 1.5
    ring2.Parent = iconInner
    local ringCorner2 = Instance.new("UICorner")
    ringCorner2.CornerRadius = UDim.new(1, 0)
    ringCorner2.Parent = iconInner

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -48, 1, 0)
    lbl.Position = UDim2.new(0, 44, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = isActive and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 140, 170)
    lbl.TextSize = 13
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = tab

    return tab, stroke, ring1, ring2, lbl
end

local TabShooting, StrokeShooting, Ring1S, Ring2S, LabelS = createSidebarTab("Shooting", "Shooting", 12, true)
local TabMovement, StrokeMovement, Ring1M, Ring2M, LabelM = createSidebarTab("Movement", "Movement", 68, false)
local TabOverlay, StrokeOverlay, Ring1O, Ring2O, LabelO = createSidebarTab("Overlay", "Overlay", 124, false)
local TabESP, StrokeESP, Ring1E, Ring2E, LabelE = createSidebarTab("ESP", "ESP", 180, false)

-- Content Panels Container
local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -185, 1, -64)
ContentArea.Position = UDim2.new(0, 185, 0, 64)
ContentArea.BackgroundTransparency = 1
ContentArea.BorderSizePixel = 0
ContentArea.Parent = MainFrame

-- Sub-panel 1: Shooting Panel
local PanelShooting = Instance.new("ScrollingFrame")
PanelShooting.Size = UDim2.new(1, 0, 1, 0)
PanelShooting.BackgroundTransparency = 1
PanelShooting.BorderSizePixel = 0
PanelShooting.CanvasSize = UDim2.new(0, 0, 0, 260)
PanelShooting.ScrollBarThickness = 2
PanelShooting.Visible = true
PanelShooting.Parent = ContentArea

-- Sub-panel 2: Movement Panel (Speed Hack)
local PanelMovement = Instance.new("ScrollingFrame")
PanelMovement.Size = UDim2.new(1, 0, 1, 0)
PanelMovement.BackgroundTransparency = 1
PanelMovement.BorderSizePixel = 0
PanelMovement.CanvasSize = UDim2.new(0, 0, 0, 200)
PanelMovement.ScrollBarThickness = 2
PanelMovement.Visible = false
PanelMovement.Parent = ContentArea

-- Sub-panel 3: Overlay Settings Panel
local PanelOverlay = Instance.new("ScrollingFrame")
PanelOverlay.Size = UDim2.new(1, 0, 1, 0)
PanelOverlay.BackgroundTransparency = 1
PanelOverlay.BorderSizePixel = 0
PanelOverlay.CanvasSize = UDim2.new(0, 0, 0, 200)
PanelOverlay.ScrollBarThickness = 2
PanelOverlay.Visible = false
PanelOverlay.Parent = ContentArea

-- Sub-panel 4: ESP Settings Panel
local PanelESP = Instance.new("ScrollingFrame")
PanelESP.Size = UDim2.new(1, 0, 1, 0)
PanelESP.BackgroundTransparency = 1
PanelESP.BorderSizePixel = 0
PanelESP.CanvasSize = UDim2.new(0, 0, 0, 200)
PanelESP.ScrollBarThickness = 2
PanelESP.Visible = false
PanelESP.Parent = ContentArea

-- Tab Switching Logic
local function switchTab(selectedTab)
    PanelShooting.Visible = (selectedTab == "Shooting")
    PanelMovement.Visible = (selectedTab == "Movement")
    PanelOverlay.Visible = (selectedTab == "Overlay")
    PanelESP.Visible = (selectedTab == "ESP")

    local function updateTabVisual(tab, stroke, r1, r2, lbl, active)
        tab.BackgroundColor3 = active and Color3.fromRGB(25, 20, 35) or Color3.fromRGB(12, 10, 18)
        stroke.Color = active and Color3.fromRGB(140, 100, 190) or Color3.fromRGB(40, 30, 55)
        r1.Color = active and Color3.fromRGB(190, 140, 255) or Color3.fromRGB(80, 70, 100)
        r2.Color = active and Color3.fromRGB(190, 140, 255) or Color3.fromRGB(80, 70, 100)
        lbl.TextColor3 = active and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 140, 170)
    end

    updateTabVisual(TabShooting, StrokeShooting, Ring1S, Ring2S, LabelS, selectedTab == "Shooting")
    updateTabVisual(TabMovement, StrokeMovement, Ring1M, Ring2M, LabelM, selectedTab == "Movement")
    updateTabVisual(TabOverlay, StrokeOverlay, Ring1O, Ring2O, LabelO, selectedTab == "Overlay")
    updateTabVisual(TabESP, StrokeESP, Ring1E, Ring2E, LabelE, selectedTab == "ESP")
end

TabShooting.MouseButton1Click:Connect(function() switchTab("Shooting") end)
TabMovement.MouseButton1Click:Connect(function() switchTab("Movement") end)
TabOverlay.MouseButton1Click:Connect(function() switchTab("Overlay") end)
TabESP.MouseButton1Click:Connect(function() switchTab("ESP") end)

-- FILL SHOOTING PANEL CONTENT
local SectionTitle = Instance.new("TextLabel")
SectionTitle.Size = UDim2.new(0, 200, 0, 18)
SectionTitle.Position = UDim2.new(0, 20, 0, 14)
SectionTitle.BackgroundTransparency = 1
SectionTitle.Text = "AUTO GREEN"
SectionTitle.TextColor3 = Color3.fromRGB(170, 170, 170)
SectionTitle.TextSize = 11
SectionTitle.Font = Enum.Font.GothamBold
SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
SectionTitle.Parent = PanelShooting

-- TIME PREFERENCE BAR
local TimeCard = Instance.new("Frame")
TimeCard.Size = UDim2.new(1, -40, 0, 42)
TimeCard.Position = UDim2.new(0, 20, 0, 38)
TimeCard.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
TimeCard.BorderSizePixel = 0
TimeCard.Parent = PanelShooting

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

-- SHOT PREDICTION OFFSET BAR
local PredCard = Instance.new("Frame")
PredCard.Size = UDim2.new(1, -40, 0, 42)
PredCard.Position = UDim2.new(0, 20, 0, 86)
PredCard.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
PredCard.BorderSizePixel = 0
PredCard.Parent = PanelShooting

local PredCardCorner = Instance.new("UICorner")
PredCardCorner.CornerRadius = UDim.new(0, 8)
PredCardCorner.Parent = PredCard
local PredCardStroke = Instance.new("UIStroke")
PredCardStroke.Color = Color3.fromRGB(30, 30, 30)
PredCardStroke.Thickness = 1
PredCardStroke.Parent = PredCard

local PredCardLabel = Instance.new("TextLabel")
PredCardLabel.Size = UDim2.new(1, -100, 1, 0)
PredCardLabel.Position = UDim2.new(0, 16, 0, 0)
PredCardLabel.BackgroundTransparency = 1
PredCardLabel.Text = "Prediction / Lag Offset"
PredCardLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
PredCardLabel.TextSize = 12
PredCardLabel.Font = Enum.Font.GothamMedium
PredCardLabel.TextXAlignment = Enum.TextXAlignment.Left
PredCardLabel.Parent = PredCard

local PredTextBox = Instance.new("TextBox")
PredTextBox.Size = UDim2.new(0, 70, 0, 26)
PredTextBox.Position = UDim2.new(1, -12, 0.5, 0)
PredTextBox.AnchorPoint = Vector2.new(1, 0.5)
PredTextBox.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
PredTextBox.BorderSizePixel = 0
PredTextBox.Text = "0.03"
PredTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
PredTextBox.TextSize = 12
PredTextBox.Font = Enum.Font.GothamBold
PredTextBox.ClearTextOnFocus = false
PredTextBox.Parent = PredCard
local PredBoxCorner = Instance.new("UICorner")
PredBoxCorner.CornerRadius = UDim.new(0, 6)
PredBoxCorner.Parent = PredTextBox
local PredBoxStroke = Instance.new("UIStroke")
PredBoxStroke.Color = Color3.fromRGB(50, 50, 50)
PredBoxStroke.Thickness = 1
PredBoxStroke.Parent = PredTextBox

-- Auto Green Toggle Card
local ToggleCard = Instance.new("Frame")
ToggleCard.Size = UDim2.new(1, -40, 0, 48)
ToggleCard.Position = UDim2.new(0, 20, 0, 134)
ToggleCard.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
ToggleCard.BorderSizePixel = 0
ToggleCard.Parent = PanelShooting

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


-- FILL MOVEMENT PANEL CONTENT (Speed Hack)
local MovementSecTitle = Instance.new("TextLabel")
MovementSecTitle.Size = UDim2.new(0, 200, 0, 18)
MovementSecTitle.Position = UDim2.new(0, 20, 0, 14)
MovementSecTitle.BackgroundTransparency = 1
MovementSecTitle.Text = "MOVEMENT & SPEED HACK"
MovementSecTitle.TextColor3 = Color3.fromRGB(170, 170, 170)
MovementSecTitle.TextSize = 11
MovementSecTitle.Font = Enum.Font.GothamBold
MovementSecTitle.TextXAlignment = Enum.TextXAlignment.Left
MovementSecTitle.Parent = PanelMovement

local SpeedCard = Instance.new("Frame")
SpeedCard.Size = UDim2.new(1, -40, 0, 42)
SpeedCard.Position = UDim2.new(0, 20, 0, 38)
SpeedCard.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
SpeedCard.BorderSizePixel = 0
SpeedCard.Parent = PanelMovement

local SpeedCardCorner = Instance.new("UICorner")
SpeedCardCorner.CornerRadius = UDim.new(0, 8)
SpeedCardCorner.Parent = SpeedCard
local SpeedCardStroke = Instance.new("UIStroke")
SpeedCardStroke.Color = Color3.fromRGB(30, 30, 30)
SpeedCardStroke.Thickness = 1
SpeedCardStroke.Parent = SpeedCard

local SpeedCardLabel = Instance.new("TextLabel")
SpeedCardLabel.Size = UDim2.new(1, -100, 1, 0)
SpeedCardLabel.Position = UDim2.new(0, 16, 0, 0)
SpeedCardLabel.BackgroundTransparency = 1
SpeedCardLabel.Text = "WalkSpeed Value"
SpeedCardLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
SpeedCardLabel.TextSize = 12
SpeedCardLabel.Font = Enum.Font.GothamMedium
SpeedCardLabel.TextXAlignment = Enum.TextXAlignment.Left
SpeedCardLabel.Parent = SpeedCard

local SpeedTextBox = Instance.new("TextBox")
SpeedTextBox.Size = UDim2.new(0, 70, 0, 26)
SpeedTextBox.Position = UDim2.new(1, -12, 0.5, 0)
SpeedTextBox.AnchorPoint = Vector2.new(1, 0.5)
SpeedTextBox.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
SpeedTextBox.BorderSizePixel = 0
SpeedTextBox.Text = "24"
SpeedTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedTextBox.TextSize = 12
SpeedTextBox.Font = Enum.Font.GothamBold
SpeedTextBox.ClearTextOnFocus = false
SpeedTextBox.Parent = SpeedCard
local SpeedBoxCorner = Instance.new("UICorner")
SpeedBoxCorner.CornerRadius = UDim.new(0, 6)
SpeedBoxCorner.Parent = SpeedTextBox
local SpeedBoxStroke = Instance.new("UIStroke")
SpeedBoxStroke.Color = Color3.fromRGB(50, 50, 50)
SpeedBoxStroke.Thickness = 1
SpeedBoxStroke.Parent = SpeedTextBox

local SpeedToggleCard = Instance.new("Frame")
SpeedToggleCard.Size = UDim2.new(1, -40, 0, 48)
SpeedToggleCard.Position = UDim2.new(0, 20, 0, 86)
SpeedToggleCard.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
SpeedToggleCard.BorderSizePixel = 0
SpeedToggleCard.Parent = PanelMovement

local SpeedToggleCardCorner = Instance.new("UICorner")
SpeedToggleCardCorner.CornerRadius = UDim.new(0, 8)
SpeedToggleCardCorner.Parent = SpeedToggleCard
local SpeedToggleCardStroke = Instance.new("UIStroke")
SpeedToggleCardStroke.Color = Color3.fromRGB(30, 30, 30)
SpeedToggleCardStroke.Thickness = 1
SpeedToggleCardStroke.Parent = SpeedToggleCard

local SpeedToggleCardLabel = Instance.new("TextLabel")
SpeedToggleCardLabel.Size = UDim2.new(1, -70, 1, 0)
SpeedToggleCardLabel.Position = UDim2.new(0, 16, 0, 0)
SpeedToggleCardLabel.BackgroundTransparency = 1
SpeedToggleCardLabel.Text = "Enable Speed Hack"
SpeedToggleCardLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
SpeedToggleCardLabel.TextSize = 13
SpeedToggleCardLabel.Font = Enum.Font.GothamMedium
SpeedToggleCardLabel.TextXAlignment = Enum.TextXAlignment.Left
SpeedToggleCardLabel.Parent = SpeedToggleCard

local SpeedSwitchButton = Instance.new("TextButton")
SpeedSwitchButton.Size = UDim2.new(0, 28, 0, 28)
SpeedSwitchButton.Position = UDim2.new(1, -22, 0.5, 0)
SpeedSwitchButton.AnchorPoint = Vector2.new(1, 0.5)
SpeedSwitchButton.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
SpeedSwitchButton.BorderSizePixel = 0
SpeedSwitchButton.Text = ""
SpeedSwitchButton.AutoButtonColor = false
SpeedSwitchButton.Parent = SpeedToggleCard

local SpeedSwitchCorner = Instance.new("UICorner")
SpeedSwitchCorner.CornerRadius = UDim.new(1, 0)
SpeedSwitchCorner.Parent = SpeedSwitchButton
local SpeedSwitchStroke = Instance.new("UIStroke")
SpeedSwitchStroke.Color = Color3.fromRGB(150, 150, 150)
SpeedSwitchStroke.Thickness = 2
SpeedSwitchStroke.Parent = SpeedSwitchButton

local SpeedSwitchDot = Instance.new("Frame")
SpeedSwitchDot.Size = UDim2.new(0, 0, 0, 0)
SpeedSwitchDot.AnchorPoint = Vector2.new(0.5, 0.5)
SpeedSwitchDot.Position = UDim2.new(0.5, 0, 0.5, 0)
SpeedSwitchDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SpeedSwitchDot.BorderSizePixel = 0
SpeedSwitchDot.Parent = SpeedSwitchButton
local SpeedDotCorner = Instance.new("UICorner")
SpeedDotCorner.CornerRadius = UDim.new(1, 0)
SpeedDotCorner.Parent = SpeedSwitchDot


-- FILL OVERLAY PANEL CONTENT
local OverlaySectionTitle = Instance.new("TextLabel")
OverlaySectionTitle.Size = UDim2.new(0, 200, 0, 18)
OverlaySectionTitle.Position = UDim2.new(0, 20, 0, 14)
OverlaySectionTitle.BackgroundTransparency = 1
OverlaySectionTitle.Text = "KEY OVERLAY HUD"
OverlaySectionTitle.TextColor3 = Color3.fromRGB(170, 170, 170)
OverlaySectionTitle.TextSize = 11
OverlaySectionTitle.Font = Enum.Font.GothamBold
OverlaySectionTitle.TextXAlignment = Enum.TextXAlignment.Left
OverlaySectionTitle.Parent = PanelOverlay

local OverlayToggleCard = Instance.new("Frame")
OverlayToggleCard.Size = UDim2.new(1, -40, 0, 48)
OverlayToggleCard.Position = UDim2.new(0, 20, 0, 38)
OverlayToggleCard.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
OverlayToggleCard.BorderSizePixel = 0
OverlayToggleCard.Parent = PanelOverlay

local OverlayToggleCardCorner = Instance.new("UICorner")
OverlayToggleCardCorner.CornerRadius = UDim.new(0, 8)
OverlayToggleCardCorner.Parent = OverlayToggleCard
local OverlayToggleCardStroke = Instance.new("UIStroke")
OverlayToggleCardStroke.Color = Color3.fromRGB(30, 30, 30)
OverlayToggleCardStroke.Thickness = 1
OverlayToggleCardStroke.Parent = OverlayToggleCard

local OverlayToggleCardLabel = Instance.new("TextLabel")
OverlayToggleCardLabel.Size = UDim2.new(1, -70, 1, 0)
OverlayToggleCardLabel.Position = UDim2.new(0, 16, 0, 0)
OverlayToggleCardLabel.BackgroundTransparency = 1
OverlayToggleCardLabel.Text = "Show Bottom-Right Key HUD"
OverlayToggleCardLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
OverlayToggleCardLabel.TextSize = 13
OverlayToggleCardLabel.Font = Enum.Font.GothamMedium
OverlayToggleCardLabel.TextXAlignment = Enum.TextXAlignment.Left
OverlayToggleCardLabel.Parent = OverlayToggleCard

local OverlaySwitchButton = Instance.new("TextButton")
OverlaySwitchButton.Size = UDim2.new(0, 28, 0, 28)
OverlaySwitchButton.Position = UDim2.new(1, -22, 0.5, 0)
OverlaySwitchButton.AnchorPoint = Vector2.new(1, 0.5)
OverlaySwitchButton.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
OverlaySwitchButton.BorderSizePixel = 0
OverlaySwitchButton.Text = ""
OverlaySwitchButton.AutoButtonColor = false
OverlaySwitchButton.Parent = OverlayToggleCard

local OverlaySwitchCorner = Instance.new("UICorner")
OverlaySwitchCorner.CornerRadius = UDim.new(1, 0)
OverlaySwitchCorner.Parent = OverlaySwitchButton
local OverlaySwitchStroke = Instance.new("UIStroke")
OverlaySwitchStroke.Color = Color3.fromRGB(150, 150, 150)
OverlaySwitchStroke.Thickness = 2
OverlaySwitchStroke.Parent = OverlaySwitchButton

local OverlaySwitchDot = Instance.new("Frame")
OverlaySwitchDot.Size = UDim2.new(0, 0, 0, 0)
OverlaySwitchDot.AnchorPoint = Vector2.new(0.5, 0.5)
OverlaySwitchDot.Position = UDim2.new(0.5, 0, 0.5, 0)
OverlaySwitchDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
OverlaySwitchDot.BorderSizePixel = 0
OverlaySwitchDot.Parent = OverlaySwitchButton
local OverlayDotCorner = Instance.new("UICorner")
OverlayDotCorner.CornerRadius = UDim.new(1, 0)
OverlayDotCorner.Parent = OverlaySwitchDot


-- FILL ESP PANEL CONTENT (Placeholder)
local ESPSecTitle = Instance.new("TextLabel")
ESPSecTitle.Size = UDim2.new(0, 200, 0, 18)
ESPSecTitle.Position = UDim2.new(0, 20, 0, 14)
ESPSecTitle.BackgroundTransparency = 1
ESPSecTitle.Text = "PLAYER ESP SETTINGS"
ESPSecTitle.TextColor3 = Color3.fromRGB(170, 170, 170)
ESPSecTitle.TextSize = 11
ESPSecTitle.Font = Enum.Font.GothamBold
ESPSecTitle.TextXAlignment = Enum.TextXAlignment.Left
ESPSecTitle.Parent = PanelESP

local ESPCard = Instance.new("Frame")
ESPCard.Size = UDim2.new(1, -40, 0, 48)
ESPCard.Position = UDim2.new(0, 20, 0, 38)
ESPCard.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
ESPCard.BorderSizePixel = 0
ESPCard.Parent = PanelESP
local ESPCardCorner = Instance.new("UICorner")
ESPCardCorner.CornerRadius = UDim.new(0, 8)
ESPCardCorner.Parent = ESPCard
local ESPCardStroke = Instance.new("UIStroke")
ESPCardStroke.Color = Color3.fromRGB(30, 30, 30)
ESPCardStroke.Thickness = 1
ESPCardStroke.Parent = ESPCard

local ESPCardLabel = Instance.new("TextLabel")
ESPCardLabel.Size = UDim2.new(1, -70, 1, 0)
ESPCardLabel.Position = UDim2.new(0, 16, 0, 0)
ESPCardLabel.BackgroundTransparency = 1
ESPCardLabel.Text = "Enable Box ESP"
ESPCardLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
ESPCardLabel.TextSize = 13
ESPCardLabel.Font = Enum.Font.GothamMedium
ESPCardLabel.TextXAlignment = Enum.TextXAlignment.Left
ESPCardLabel.Parent = ESPCard


-- Panic Button inside bottom of Shooting Panel Content
local PanicButton = Instance.new("TextButton")
PanicButton.Size = UDim2.new(1, -40, 0, 36)
PanicButton.Position = UDim2.new(0, 20, 0, 200)
PanicButton.BackgroundColor3 = Color3.fromRGB(30, 10, 10)
PanicButton.BorderSizePixel = 0
PanicButton.AutoButtonColor = false
PanicButton.Text = "PANIC STOP (UNLOAD)"
PanicButton.TextColor3 = Color3.fromRGB(255, 100, 100)
PanicButton.TextSize = 11
PanicButton.Font = Enum.Font.GothamBold
PanicButton.Parent = PanelShooting

local PanicCorner = Instance.new("UICorner")
PanicCorner.CornerRadius = UDim.new(0, 8)
PanicCorner.Parent = PanicButton
local PanicStroke = Instance.new("UIStroke")
PanicStroke.Color = Color3.fromRGB(100, 30, 30)
PanicStroke.Thickness = 1
PanicStroke.Parent = PanicButton


--- // STANDALONE KEY OVERLAY (Docked to Bottom Right) ---
local OverlayContainer = Instance.new("Frame")
OverlayContainer.Name = "KeyOverlay"
OverlayContainer.Size = UDim2.new(0, 270, 0, 220)
OverlayContainer.Position = UDim2.new(1, -290, 1, -240)
OverlayContainer.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
OverlayContainer.BackgroundTransparency = 0.1
OverlayContainer.BorderSizePixel = 0
OverlayContainer.Visible = false
OverlayContainer.Active = true
OverlayContainer.Draggable = true
OverlayContainer.Parent = ScreenGui

local OverlayCorner = Instance.new("UICorner")
OverlayCorner.CornerRadius = UDim.new(0, 10)
OverlayCorner.Parent = OverlayContainer

local OverlayStroke = Instance.new("UIStroke")
OverlayStroke.Color = Color3.fromRGB(40, 35, 50)
OverlayStroke.Thickness = 1.5
OverlayStroke.Parent = OverlayContainer

local KeyFrames = {}
local function createKeyVisual(name, text, px, py, pw, ph)
    local btn = Instance.new("Frame")
    btn.Size = UDim2.new(0, pw or 48, 0, ph or 42)
    btn.Position = UDim2.new(0, px, 0, py)
    btn.BackgroundColor3 = Color3.fromRGB(25, 20, 30)
    btn.BorderSizePixel = 0
    btn.Parent = OverlayContainer

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(80, 65, 95)
    stroke.Thickness = 1.5
    stroke.Parent = btn

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(240, 240, 240)
    lbl.TextSize = 13
    lbl.Font = Enum.Font.GothamBold
    lbl.Parent = btn

    KeyFrames[name] = {Frame = btn, Stroke = stroke, Label = lbl}
    return btn
end

createKeyVisual("W", "W", 110, 20, 48, 42)
createKeyVisual("A", "A", 58, 66, 48, 42)
createKeyVisual("S", "S", 110, 66, 48, 42)
createKeyVisual("D", "D", 162, 66, 48, 42)
createKeyVisual("Shift", "SHIFT", 58, 112, 68, 42)
createKeyVisual("Space", "SPACE", 130, 112, 80, 42)
createKeyVisual("E", "E", 58, 158, 48, 42)
createKeyVisual("G", "G", 110, 158, 48, 42)

local function setKeyState(keyName, isPressed)
    if not OverlayContainer.Visible then return end
    local kData = KeyFrames[keyName]
    if not kData then return end
    
    if isPressed then
        TweenService:Create(kData.Frame, TweenInfo.new(0.08), {BackgroundColor3 = Color3.fromRGB(110, 75, 145)}):Play()
        TweenService:Create(kData.Stroke, TweenInfo.new(0.08), {Color = Color3.fromRGB(200, 150, 255)}):Play()
    else
        TweenService:Create(kData.Frame, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(25, 20, 30)}):Play()
        TweenService:Create(kData.Stroke, TweenInfo.new(0.12), {Color = Color3.fromRGB(80, 65, 95)}):Play()
    end
end


--- HEARTBEAT FLOATING CIRCLE (MINIMIZED ICON) ---
local HeartbeatButton = Instance.new("TextButton")
HeartbeatButton.Name = "HeartbeatButton"
HeartbeatButton.Size = UDim2.new(0, 50, 0, 50)
HeartbeatButton.Position = UDim2.new(0, 30, 0.5, -25)
HeartbeatButton.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
HeartbeatButton.BorderSizePixel = 0
HeartbeatButton.AutoButtonColor = false
HeartbeatButton.Visible = false
HeartbeatButton.Active = true
HeartbeatButton.Draggable = true
HeartbeatButton.Text = "♥"
HeartbeatButton.TextColor3 = Color3.fromRGB(255, 80, 80)
HeartbeatButton.TextSize = 22
HeartbeatButton.Font = Enum.Font.GothamBold
HeartbeatButton.Parent = ScreenGui

local HeartCorner = Instance.new("UICorner")
HeartCorner.CornerRadius = UDim.new(1, 0)
HeartCorner.Parent = HeartbeatButton
local HeartStroke = Instance.new("UIStroke")
HeartStroke.Color = Color3.fromRGB(255, 80, 80)
HeartStroke.Thickness = 1.5
HeartStroke.Parent = HeartbeatButton

-- Tween Helper Function
local function tween(obj, props, time, style, dir)
    local tw = TweenService:Create(obj, TweenInfo.new(time or 0.25, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
    tw:Play()
    return tw
end

-- TextBox Inputs & Logic
TimeTextBox.FocusLost:Connect(function()
    local val = tonumber(TimeTextBox.Text)
    if val and val > 0 then TargetDelay = val else TimeTextBox.Text = tostring(TargetDelay) end
end)

PredTextBox.FocusLost:Connect(function()
    local val = tonumber(PredTextBox.Text)
    if val and val >= 0 then PredictionOffset = val else PredTextBox.Text = tostring(PredictionOffset) end
end)

SpeedTextBox.FocusLost:Connect(function()
    local val = tonumber(SpeedTextBox.Text)
    if val and val > 0 then WalkSpeedValue = val else SpeedTextBox.Text = tostring(WalkSpeedValue) end
end)

-- Speed Hack Loop
local function startSpeedHack()
    if SpeedConnection then SpeedConnection:Disconnect() end
    SpeedConnection = RunService.RenderStepped:Connect(function()
        if not SpeedEnabled then return end
        local character = Player.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.WalkSpeed ~= WalkSpeedValue then
                humanoid.WalkSpeed = WalkSpeedValue
            end
        end
    end)
end

local function stopSpeedHack()
    if SpeedConnection then SpeedConnection:Disconnect(); SpeedConnection = nil end
    local character = Player.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.WalkSpeed = 16 end
    end
end

-- Sub-Frame Scanner Loop
local function startScanning()
    if ScanConnection then ScanConnection:Disconnect() end
    ScanConnection = RunService.RenderStepped:Connect(function()
        if not Running then return end
        if IsShooting then
            local elapsedTime = tick() - ShotStartTime
            local adjustedTarget = TargetDelay - PredictionOffset
            local hardStopLimit = TargetDelay + 0.02
            
            if elapsedTime >= adjustedTarget or elapsedTime >= hardStopLimit then
                pcall(function()
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                end)
                IsShooting = false
                task.wait(0.3)
            end
        end
    end)
end

local function stopScanning()
    if ScanConnection then ScanConnection:Disconnect(); ScanConnection = nil end
end

-- Input Listeners
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.W then setKeyState("W", true)
    elseif input.KeyCode == Enum.KeyCode.A then setKeyState("A", true)
    elseif input.KeyCode == Enum.KeyCode.S then setKeyState("S", true)
    elseif input.KeyCode == Enum.KeyCode.D then setKeyState("D", true)
    elseif input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then setKeyState("Shift", true)
    elseif input.KeyCode == Enum.KeyCode.Space then setKeyState("Space", true)
    elseif input.KeyCode == Enum.KeyCode.E then 
        setKeyState("E", true)
        if Running then
            IsShooting = true
            ShotStartTime = tick()
        end
    elseif input.KeyCode == Enum.KeyCode.G then setKeyState("G", true)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.W then setKeyState("W", false)
    elseif input.KeyCode == Enum.KeyCode.A then setKeyState("A", false)
    elseif input.KeyCode == Enum.KeyCode.S then setKeyState("S", false)
    elseif input.KeyCode == Enum.KeyCode.D then setKeyState("D", false)
    elseif input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then setKeyState("Shift", false)
    elseif input.KeyCode == Enum.KeyCode.Space then setKeyState("Space", false)
    elseif input.KeyCode == Enum.KeyCode.E then 
        setKeyState("E", false)
        if IsShooting then
            IsShooting = false
            pcall(function()
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
            end)
        end
    elseif input.KeyCode == Enum.KeyCode.G then setKeyState("G", false)
    end
end)

-- Toggles
SwitchButton.MouseButton1Click:Connect(function()
    Running = not Running
    IsShooting = false
    if Running then
        tween(SwitchButton, {BackgroundColor3 = Color3.fromRGB(255, 255, 255)}, 0.2)
        tween(SwitchDot, {Size = UDim2.new(0, 16, 0, 16)}, 0.2)
        startScanning()
    else
        tween(SwitchButton, {BackgroundColor3 = Color3.fromRGB(15, 15, 15)}, 0.2)
        tween(SwitchDot, {Size = UDim2.new(0, 0, 0, 0)}, 0.2)
        stopScanning()
    end
end)

SpeedSwitchButton.MouseButton1Click:Connect(function()
    SpeedEnabled = not SpeedEnabled
    if SpeedEnabled then
        tween(SpeedSwitchButton, {BackgroundColor3 = Color3.fromRGB(255, 255, 255)}, 0.2)
        tween(SpeedSwitchDot, {Size = UDim2.new(0, 16, 0, 16)}, 0.2)
        startSpeedHack()
    else
        tween(SpeedSwitchButton, {BackgroundColor3 = Color3.fromRGB(15, 15, 15)}, 0.2)
        tween(SpeedSwitchDot, {Size = UDim2.new(0, 0, 0, 0)}, 0.2)
        stopSpeedHack()
    end
end)

OverlaySwitchButton.MouseButton1Click:Connect(function()
    local hudEnabled = not OverlayContainer.Visible
    if hudEnabled then
        OverlayContainer.Visible = true
        tween(OverlaySwitchButton, {BackgroundColor3 = Color3.fromRGB(255, 255, 255)}, 0.2)
        tween(OverlaySwitchDot, {Size = UDim2.new(0, 16, 0, 16)}, 0.2)
    else
        OverlayContainer.Visible = false
        tween(OverlaySwitchButton, {BackgroundColor3 = Color3.fromRGB(15, 15, 15)}, 0.2)
        tween(OverlaySwitchDot, {Size = UDim2.new(0, 0, 0, 0)}, 0.2)
    end
end)

MinBtn.MouseButton1Click:Connect(function()
    IsMinimized = true
    MainFrame.Visible = false
    HeartbeatButton.Visible = true
end)

HeartbeatButton.MouseButton1Click:Connect(function()
    IsMinimized = false
    HeartbeatButton.Visible = false
    MainFrame.Visible = true
end)

PanicButton.MouseButton1Click:Connect(function()
    Running = false
    SpeedEnabled = false
    stopScanning()
    stopSpeedHack()
    ScreenGui:Destroy()
end)

CloseBtn.MouseButton1Click:Connect(function()
    Running = false
    SpeedEnabled = false
    stopScanning()
    stopSpeedHack()
    ScreenGui:Destroy()
end)
