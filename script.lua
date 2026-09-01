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
local ScanConnection = nil

-- Auto Time State
local AutoTimeEnabled = false
local ShotHistory = {}
local AutoTimeMinLimit = 0.30
local AutoTimeMaxLimit = 0.80

-- Detailed Component Color States
local ComponentColors = {
    Header = Color3.fromRGB(5, 5, 5),
    Sidebar = Color3.fromRGB(3, 3, 3),
    MainBg = Color3.fromRGB(0, 0, 0),
    Keys = Color3.fromRGB(15, 15, 18),
    Text = Color3.fromRGB(255, 255, 255),
    Accent = Color3.fromRGB(140, 100, 190)
}

local SelectedCustomPart = "Header"

-- Clean UI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CleanHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = PlayerGui

-- Main Window Container (Size: 520x350)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 520, 0, 350)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -175)
MainFrame.BackgroundColor3 = ComponentColors.MainBg
MainFrame.BackgroundTransparency = 0.02
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
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

-- Top Navigation / Header Bar (Height: 52px)
local HeaderBar = Instance.new("Frame")
HeaderBar.Name = "HeaderBar"
HeaderBar.Size = UDim2.new(1, 0, 0, 52)
HeaderBar.BackgroundColor3 = ComponentColors.Header
HeaderBar.BorderSizePixel = 0
HeaderBar.Parent = MainFrame

local HeaderDivider = Instance.new("Frame")
HeaderDivider.Name = "HeaderDivider"
HeaderDivider.Size = UDim2.new(1, 0, 0, 1)
HeaderDivider.Position = UDim2.new(0, 0, 1, -1)
HeaderDivider.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
HeaderDivider.BorderSizePixel = 0
HeaderDivider.Parent = HeaderBar

-- Helper function to build textured moon layout
local function buildTexturedMoon(parent)
    local container = Instance.new("Frame")
    container.Name = "MoonContainer"
    container.Size = UDim2.new(0, 32, 0, 32)
    container.Position = UDim2.new(0, 9, 0, 10)
    container.BackgroundTransparency = 1
    container.ZIndex = 5
    container.Parent = parent

    local outerGlow = Instance.new("Frame")
    outerGlow.Size = UDim2.new(0, 28, 0, 28)
    outerGlow.AnchorPoint = Vector2.new(0.5, 0.5)
    outerGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
    outerGlow.BackgroundColor3 = Color3.fromRGB(210, 225, 255)
    outerGlow.BackgroundTransparency = 0.8
    outerGlow.BorderSizePixel = 0
    outerGlow.ZIndex = 4
    outerGlow.Parent = container
    local ogCorner = Instance.new("UICorner") ogCorner.CornerRadius = UDim.new(1, 0) ogCorner.Parent = outerGlow

    local fullMoon = Instance.new("Frame")
    fullMoon.Size = UDim2.new(0, 24, 0, 24)
    fullMoon.AnchorPoint = Vector2.new(0.5, 0.5)
    fullMoon.Position = UDim2.new(0.5, 0, 0.5, 0)
    fullMoon.BackgroundColor3 = Color3.fromRGB(220, 228, 240)
    fullMoon.BorderSizePixel = 0
    fullMoon.ClipsDescendants = true
    fullMoon.ZIndex = 5
    fullMoon.Parent = container

    local moonCorner = Instance.new("UICorner") moonCorner.CornerRadius = UDim.new(1, 0) moonCorner.Parent = fullMoon
    local moonStroke = Instance.new("UIStroke") moonStroke.Color = Color3.fromRGB(180, 205, 245) moonStroke.Thickness = 1.2 moonStroke.Parent = fullMoon

    local function addCrater(px, py, pw, ph, col, transp)
        local c = Instance.new("Frame")
        c.Size = UDim2.new(0, pw, 0, ph)
        c.Position = UDim2.new(0, px, 0, py)
        c.BackgroundColor3 = col or Color3.fromRGB(145, 160, 185)
        c.BackgroundTransparency = transp or 0.25
        c.BorderSizePixel = 0
        c.ZIndex = 6
        c.Parent = fullMoon
        local cc = Instance.new("UICorner") cc.CornerRadius = UDim.new(1, 0) cc.Parent = c
    end

    addCrater(3, 3, 8, 7, Color3.fromRGB(135, 150, 175), 0.2)
    addCrater(11, 7, 9, 8, Color3.fromRGB(140, 155, 180), 0.25)
    addCrater(6, 12, 10, 7, Color3.fromRGB(130, 145, 170), 0.3)
    addCrater(13, 3, 4, 4, Color3.fromRGB(255, 255, 255), 0.1)
    addCrater(2, 14, 5, 4, Color3.fromRGB(235, 245, 255), 0.15)
    addCrater(9, 2, 3, 3, Color3.fromRGB(240, 248, 255), 0.2)
    addCrater(16, 13, 4, 4, Color3.fromRGB(225, 238, 255), 0.25)
    addCrater(5, 7, 3, 3, Color3.fromRGB(170, 185, 210), 0.2)

    task.spawn(function()
        while true do
            TweenService:Create(moonStroke, TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transparency = 0.5, Thickness = 2.5}):Play()
            TweenService:Create(outerGlow, TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Size = UDim2.new(0, 34, 0, 34), BackgroundTransparency = 0.92}):Play()
            task.wait(1.4)
            TweenService:Create(moonStroke, TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transparency = 0.2, Thickness = 1.0}):Play()
            TweenService:Create(outerGlow, TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Size = UDim2.new(0, 26, 0, 26), BackgroundTransparency = 0.78}):Play()
            task.wait(1.4)
        end
    end)
    return container
end

buildTexturedMoon(HeaderBar)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0, 130, 0, 18)
TitleLabel.Position = UDim2.new(0, 48, 0, 17)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Countx"
TitleLabel.TextColor3 = ComponentColors.Text
TitleLabel.TextSize = 13
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = HeaderBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 20, 0, 20)
CloseBtn.Position = UDim2.new(1, -12, 0, 16)
CloseBtn.AnchorPoint = Vector2.new(1, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(220, 80, 80)
CloseBtn.TextSize = 12
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = HeaderBar

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 20, 0, 20)
MinBtn.Position = UDim2.new(1, -36, 0, 16)
MinBtn.AnchorPoint = Vector2.new(1, 0)
MinBtn.BackgroundTransparency = 1
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.fromRGB(160, 160, 160)
MinBtn.TextSize = 11
MinBtn.Font = Enum.Font.GothamBold
MinBtn.Parent = HeaderBar

-- Left Sidebar Navigation
local Sidebar = Instance.new("ScrollingFrame")
Sidebar.Size = UDim2.new(0, 155, 1, -52)
Sidebar.Position = UDim2.new(0, 0, 0, 52)
Sidebar.BackgroundColor3 = ComponentColors.Sidebar
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

local allTabs = {}

local function buildSidebarBlackHole(parent)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(0, 20, 0, 20)
    container.Position = UDim2.new(0, 10, 0.5, -10)
    container.BackgroundTransparency = 1
    container.Parent = parent

    local ring = Instance.new("Frame")
    ring.Size = UDim2.new(1, 0, 1, 0)
    ring.AnchorPoint = Vector2.new(0.5, 0.5)
    ring.Position = UDim2.new(0.5, 0, 0.5, 0)
    ring.BackgroundTransparency = 1
    ring.Parent = container
    local rc = Instance.new("UICorner") rc.CornerRadius = UDim.new(1, 0) rc.Parent = ring
    local rs = Instance.new("UIStroke") rs.Color = Color3.fromRGB(255, 255, 255) rs.Thickness = 1.5 rs.Parent = ring

    local core = Instance.new("Frame")
    core.Size = UDim2.new(0, 10, 0, 10)
    core.AnchorPoint = Vector2.new(0.5, 0.5)
    core.Position = UDim2.new(0.5, 0, 0.5, 0)
    core.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    core.BorderSizePixel = 0
    core.Parent = container
    local cc = Instance.new("UICorner") cc.CornerRadius = UDim.new(1, 0) cc.Parent = core
    local cs = Instance.new("UIStroke") cs.Color = Color3.fromRGB(200, 200, 200) cs.Thickness = 1 cs.Parent = core
end

local function createSidebarTab(name, text, yPos, isActive)
    local tab = Instance.new("TextButton")
    tab.Name = name .. "Tab"
    tab.Size = UDim2.new(1, -12, 0, 38)
    tab.Position = UDim2.new(0, 6, 0, yPos)
    tab.BackgroundColor3 = isActive and Color3.fromRGB(25, 20, 35) or Color3.fromRGB(12, 10, 18)
    tab.BorderSizePixel = 0
    tab.Text = ""
    tab.AutoButtonColor = false
    tab.Parent = Sidebar

    local corner = Instance.new("UICorner") corner.CornerRadius = UDim.new(0, 8) corner.Parent = tab
    local stroke = Instance.new("UIStroke") stroke.Color = isActive and ComponentColors.Accent or Color3.fromRGB(40, 30, 55) stroke.Thickness = 1 stroke.Parent = tab

    buildSidebarBlackHole(tab)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -38, 1, 0)
    lbl.Position = UDim2.new(0, 36, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = isActive and ComponentColors.Text or Color3.fromRGB(150, 140, 170)
    lbl.TextSize = 11
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = tab

    local tabData = {Button = tab, Stroke = stroke, Label = lbl, Active = isActive}
    table.insert(allTabs, tabData)
    return tabData
end

local TabShooting = createSidebarTab("Shooting", "Shooting", 10, true)
local TabOverlay = createSidebarTab("Overlay", "Overlay", 54, false)
local TabTheme = createSidebarTab("Theme", "Theme", 98, false)

-- Content Panels Container
local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -155, 1, -52)
ContentArea.Position = UDim2.new(0, 155, 0, 52)
ContentArea.BackgroundTransparency = 1
ContentArea.BorderSizePixel = 0
ContentArea.Parent = MainFrame

-- Panels Setup
local PanelShooting = Instance.new("ScrollingFrame")
PanelShooting.Size = UDim2.new(1, 0, 1, 0)
PanelShooting.BackgroundTransparency = 1
PanelShooting.BorderSizePixel = 0
PanelShooting.CanvasSize = UDim2.new(0, 0, 0, 210)
PanelShooting.ScrollBarThickness = 2
PanelShooting.Visible = true
PanelShooting.Parent = ContentArea

local PanelOverlay = Instance.new("ScrollingFrame")
PanelOverlay.Size = UDim2.new(1, 0, 1, 0)
PanelOverlay.BackgroundTransparency = 1
PanelOverlay.BorderSizePixel = 0
PanelOverlay.CanvasSize = UDim2.new(0, 0, 0, 180)
PanelOverlay.ScrollBarThickness = 2
PanelOverlay.Visible = false
PanelOverlay.Parent = ContentArea

local PanelTheme = Instance.new("ScrollingFrame")
PanelTheme.Size = UDim2.new(1, 0, 1, 0)
PanelTheme.BackgroundTransparency = 1
PanelTheme.BorderSizePixel = 0
PanelTheme.CanvasSize = UDim2.new(0, 0, 0, 270)
PanelTheme.ScrollBarThickness = 2
PanelTheme.Visible = false
PanelTheme.Parent = ContentArea

-- Tab Switching Logic
local function switchTab(selectedName)
    PanelShooting.Visible = (selectedName == "Shooting")
    PanelOverlay.Visible = (selectedName == "Overlay")
    PanelTheme.Visible = (selectedName == "Theme")

    for _, tData in ipairs(allTabs) do
        local isActive = (tData.Button.Name == selectedName .. "Tab")
        tData.Active = isActive
        tData.Button.BackgroundColor3 = isActive and Color3.fromRGB(25, 20, 35) or Color3.fromRGB(12, 10, 18)
        tData.Stroke.Color = isActive and ComponentColors.Accent or Color3.fromRGB(40, 30, 55)
        tData.Label.TextColor3 = isActive and ComponentColors.Text or Color3.fromRGB(150, 140, 170)
    end
end

TabShooting.Button.MouseButton1Click:Connect(function() switchTab("Shooting") end)
TabOverlay.Button.MouseButton1Click:Connect(function() switchTab("Overlay") end)
TabTheme.Button.MouseButton1Click:Connect(function() switchTab("Theme") end)

-- SHOOTING PANEL CONTENT
local SectionTitle = Instance.new("TextLabel")
SectionTitle.Size = UDim2.new(0, 180, 0, 16)
SectionTitle.Position = UDim2.new(0, 14, 0, 12)
SectionTitle.BackgroundTransparency = 1
SectionTitle.Text = "AUTO GREEN & TIMING"
SectionTitle.TextColor3 = Color3.fromRGB(170, 170, 170)
SectionTitle.TextSize = 10
SectionTitle.Font = Enum.Font.GothamBold
SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
SectionTitle.Parent = PanelShooting

local TimeCard = Instance.new("Frame")
TimeCard.Size = UDim2.new(1, -28, 0, 36)
TimeCard.Position = UDim2.new(0, 14, 0, 32)
TimeCard.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
TimeCard.BorderSizePixel = 0
TimeCard.Parent = PanelShooting
local TimeCardCorner = Instance.new("UICorner") TimeCardCorner.CornerRadius = UDim.new(0, 6) TimeCardCorner.Parent = TimeCard
local TimeCardStroke = Instance.new("UIStroke") TimeCardStroke.Color = Color3.fromRGB(30, 30, 30) TimeCardStroke.Thickness = 1 TimeCardStroke.Parent = TimeCard

local TimeCardLabel = Instance.new("TextLabel")
TimeCardLabel.Size = UDim2.new(1, -80, 1, 0)
TimeCardLabel.Position = UDim2.new(0, 12, 0, 0)
TimeCardLabel.BackgroundTransparency = 1
TimeCardLabel.Text = "Target Time (Seconds)"
TimeCardLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
TimeCardLabel.TextSize = 11
TimeCardLabel.Font = Enum.Font.GothamMedium
TimeCardLabel.TextXAlignment = Enum.TextXAlignment.Left
TimeCardLabel.Parent = TimeCard

local TimeTextBox = Instance.new("TextBox")
TimeTextBox.Size = UDim2.new(0, 60, 0, 22)
TimeTextBox.Position = UDim2.new(1, -10, 0.5, 0)
TimeTextBox.AnchorPoint = Vector2.new(1, 0.5)
TimeTextBox.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
TimeTextBox.BorderSizePixel = 0
TimeTextBox.Text = "0.68"
TimeTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
TimeTextBox.TextSize = 11
TimeTextBox.Font = Enum.Font.GothamBold
TimeTextBox.ClearTextOnFocus = false
TimeTextBox.Parent = TimeCard
local TimeBoxCorner = Instance.new("UICorner") TimeBoxCorner.CornerRadius = UDim.new(0, 5) TimeBoxCorner.Parent = TimeTextBox
local TimeBoxStroke = Instance.new("UIStroke") TimeBoxStroke.Color = Color3.fromRGB(50, 50, 50) TimeBoxStroke.Thickness = 1 TimeBoxStroke.Parent = TimeTextBox

-- TOGGLE HELPERS
local function tween(obj, props, time, style, dir)
    local tw = TweenService:Create(obj, TweenInfo.new(time or 0.25, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
    tw:Play()
    return tw
end

local function applyBlackHoleToggleState(switchBtn, ringStroke, coreFrame, coreStroke, isOn)
    if not isOn then
        tween(switchBtn, {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}, 0.2)
        tween(ringStroke, {Color = Color3.fromRGB(80, 80, 80), Thickness = 1.5}, 0.2)
        tween(coreFrame, {Size = UDim2.new(0, 0, 0, 0), BackgroundColor3 = Color3.fromRGB(255, 255, 255)}, 0.2)
        tween(coreStroke, {Transparency = 1}, 0.2)
    else
        tween(switchBtn, {BackgroundColor3 = Color3.fromRGB(10, 8, 15)}, 0.2)
        tween(ringStroke, {Color = Color3.fromRGB(180, 110, 255), Thickness = 2.2}, 0.2)
        tween(coreFrame, {Size = UDim2.new(0, 12, 0, 12), BackgroundColor3 = Color3.fromRGB(0, 0, 0)}, 0.2)
        tween(coreStroke, {Transparency = 0, Color = Color3.fromRGB(200, 140, 255)}, 0.2)
    end
end

-- Auto Time Toggle Card
local AutoTimeCard = Instance.new("Frame")
AutoTimeCard.Size = UDim2.new(1, -28, 0, 38)
AutoTimeCard.Position = UDim2.new(0, 14, 0, 74)
AutoTimeCard.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
AutoTimeCard.BorderSizePixel = 0
AutoTimeCard.Parent = PanelShooting
local ATCCorner = Instance.new("UICorner") ATCCorner.CornerRadius = UDim.new(0, 6) ATCCorner.Parent = AutoTimeCard
local ATCStroke = Instance.new("UIStroke") ATCStroke.Color = Color3.fromRGB(30, 30, 30) ATCStroke.Thickness = 1 ATCStroke.Parent = AutoTimeCard

local AutoTimeCardLabel = Instance.new("TextLabel")
AutoTimeCardLabel.Size = UDim2.new(1, -60, 1, 0)
AutoTimeCardLabel.Position = UDim2.new(0, 12, 0, 0)
AutoTimeCardLabel.BackgroundTransparency = 1
AutoTimeCardLabel.Text = "Auto Time (Dynamic Sync)"
AutoTimeCardLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
AutoTimeCardLabel.TextSize = 11
AutoTimeCardLabel.Font = Enum.Font.GothamMedium
AutoTimeCardLabel.TextXAlignment = Enum.TextXAlignment.Left
AutoTimeCardLabel.Parent = AutoTimeCard

local AutoTimeSwitchButton = Instance.new("TextButton")
AutoTimeSwitchButton.Size = UDim2.new(0, 24, 0, 24)
AutoTimeSwitchButton.Position = UDim2.new(1, -14, 0.5, 0)
AutoTimeSwitchButton.AnchorPoint = Vector2.new(1, 0.5)
AutoTimeSwitchButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
AutoTimeSwitchButton.BorderSizePixel = 0
AutoTimeSwitchButton.Text = ""
AutoTimeSwitchButton.AutoButtonColor = false
AutoTimeSwitchButton.Parent = AutoTimeCard
local ATSCorner = Instance.new("UICorner") ATSCorner.CornerRadius = UDim.new(1, 0) ATSCorner.Parent = AutoTimeSwitchButton
local ATSStroke = Instance.new("UIStroke") ATSStroke.Color = Color3.fromRGB(80, 80, 80) ATSStroke.Thickness = 1.5 ATSStroke.Parent = AutoTimeSwitchButton

local ATSCore = Instance.new("Frame")
ATSCore.Size = UDim2.new(0, 0, 0, 0)
ATSCore.AnchorPoint = Vector2.new(0.5, 0.5)
ATSCore.Position = UDim2.new(0.5, 0, 0.5, 0)
ATSCore.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ATSCore.BorderSizePixel = 0
ATSCore.Parent = AutoTimeSwitchButton
local ATSCoreCorner = Instance.new("UICorner") ATSCoreCorner.CornerRadius = UDim.new(1, 0) ATSCoreCorner.Parent = ATSCore
local ATSCoreStroke = Instance.new("UIStroke") ATSCoreStroke.Color = Color3.fromRGB(200, 140, 255) ATSCoreStroke.Thickness = 1 ATSCoreStroke.Transparency = 1 ATSCoreStroke.Parent = ATSCore

-- Main Auto Green Toggle Card
local ToggleCard = Instance.new("Frame")
ToggleCard.Size = UDim2.new(1, -28, 0, 38)
ToggleCard.Position = UDim2.new(0, 14, 0, 118)
ToggleCard.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
ToggleCard.BorderSizePixel = 0
ToggleCard.Parent = PanelShooting
local CardCorner = Instance.new("UICorner") CardCorner.CornerRadius = UDim.new(0, 6) CardCorner.Parent = ToggleCard
local CardStroke = Instance.new("UIStroke") CardStroke.Color = Color3.fromRGB(30, 30, 30) CardStroke.Thickness = 1 CardStroke.Parent = ToggleCard

local ToggleCardLabel = Instance.new("TextLabel")
ToggleCardLabel.Size = UDim2.new(1, -60, 1, 0)
ToggleCardLabel.Position = UDim2.new(0, 12, 0, 0)
ToggleCardLabel.BackgroundTransparency = 1
ToggleCardLabel.Text = "Auto Green"
ToggleCardLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
ToggleCardLabel.TextSize = 11
ToggleCardLabel.Font = Enum.Font.GothamMedium
ToggleCardLabel.TextXAlignment = Enum.TextXAlignment.Left
ToggleCardLabel.Parent = ToggleCard

local SwitchButton = Instance.new("TextButton")
SwitchButton.Size = UDim2.new(0, 24, 0, 24)
SwitchButton.Position = UDim2.new(1, -14, 0.5, 0)
SwitchButton.AnchorPoint = Vector2.new(1, 0.5)
SwitchButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SwitchButton.BorderSizePixel = 0
SwitchButton.Text = ""
SwitchButton.AutoButtonColor = false
SwitchButton.Parent = ToggleCard
local SwitchCorner = Instance.new("UICorner") SwitchCorner.CornerRadius = UDim.new(1, 0) SwitchCorner.Parent = SwitchButton
local SwitchStroke = Instance.new("UIStroke") SwitchStroke.Color = Color3.fromRGB(80, 80, 80) SwitchStroke.Thickness = 1.5 SwitchStroke.Parent = SwitchButton

local SwitchCore = Instance.new("Frame")
SwitchCore.Size = UDim2.new(0, 0, 0, 0)
SwitchCore.AnchorPoint = Vector2.new(0.5, 0.5)
SwitchCore.Position = UDim2.new(0.5, 0, 0.5, 0)
SwitchCore.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SwitchCore.BorderSizePixel = 0
SwitchCore.Parent = SwitchButton
local CoreCorner = Instance.new("UICorner") CoreCorner.CornerRadius = UDim.new(1, 0) CoreCorner.Parent = SwitchCore
local CoreStroke = Instance.new("UIStroke") CoreStroke.Color = Color3.fromRGB(200, 140, 255) CoreStroke.Thickness = 1 CoreStroke.Transparency = 1 CoreStroke.Parent = SwitchCore

local PanicButton = Instance.new("TextButton")
PanicButton.Size = UDim2.new(1, -28, 0, 32)
PanicButton.Position = UDim2.new(0, 14, 0, 162)
PanicButton.BackgroundColor3 = Color3.fromRGB(50, 30, 30)
PanicButton.BorderSizePixel = 0
PanicButton.AutoButtonColor = false
PanicButton.Text = "PANIC STOP (UNLOAD)"
PanicButton.TextColor3 = Color3.fromRGB(255, 100, 100)
PanicButton.TextSize = 10
PanicButton.Font = Enum.Font.GothamBold
PanicButton.Parent = PanelShooting
local PanicCorner = Instance.new("UICorner") PanicCorner.CornerRadius = UDim.new(0, 6) PanicCorner.Parent = PanicButton
local PanicStroke = Instance.new("UIStroke") PanicStroke.Color = Color3.fromRGB(100, 30, 30) PanicStroke.Thickness = 1 PanicStroke.Parent = PanicButton

-- OVERLAY PANEL CONTENT
local OverlaySectionTitle = Instance.new("TextLabel")
OverlaySectionTitle.Size = UDim2.new(0, 180, 0, 16)
OverlaySectionTitle.Position = UDim2.new(0, 14, 0, 12)
OverlaySectionTitle.BackgroundTransparency = 1
OverlaySectionTitle.Text = "KEY OVERLAY HUD"
OverlaySectionTitle.TextColor3 = Color3.fromRGB(170, 170, 170)
OverlaySectionTitle.TextSize = 10
OverlaySectionTitle.Font = Enum.Font.GothamBold
OverlaySectionTitle.TextXAlignment = Enum.TextXAlignment.Left
OverlaySectionTitle.Parent = PanelOverlay

local OverlayToggleCard = Instance.new("Frame")
OverlayToggleCard.Size = UDim2.new(1, -28, 0, 38)
OverlayToggleCard.Position = UDim2.new(0, 14, 0, 32)
OverlayToggleCard.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
OverlayToggleCard.BorderSizePixel = 0
OverlayToggleCard.Parent = PanelOverlay
local OverlayToggleCardCorner = Instance.new("UICorner") OverlayToggleCardCorner.CornerRadius = UDim.new(0, 6) OverlayToggleCardCorner.Parent = OverlayToggleCard
local OverlayToggleCardStroke = Instance.new("UIStroke") OverlayToggleCardStroke.Color = Color3.fromRGB(30, 30, 30) OverlayToggleCardStroke.Thickness = 1 OverlayToggleCardStroke.Parent = OverlayToggleCard

local OverlayToggleCardLabel = Instance.new("TextLabel")
OverlayToggleCardLabel.Size = UDim2.new(1, -60, 1, 0)
OverlayToggleCardLabel.Position = UDim2.new(0, 12, 0, 0)
OverlayToggleCardLabel.BackgroundTransparency = 1
OverlayToggleCardLabel.Text = "Enable Key HUD"
OverlayToggleCardLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
OverlayToggleCardLabel.TextSize = 11
OverlayToggleCardLabel.Font = Enum.Font.GothamMedium
OverlayToggleCardLabel.TextXAlignment = Enum.TextXAlignment.Left
OverlayToggleCardLabel.Parent = OverlayToggleCard

local OverlaySwitchButton = Instance.new("TextButton")
OverlaySwitchButton.Size = UDim2.new(0, 24, 0, 24)
OverlaySwitchButton.Position = UDim2.new(1, -14, 0.5, 0)
OverlaySwitchButton.AnchorPoint = Vector2.new(1, 0.5)
OverlaySwitchButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
OverlaySwitchButton.BorderSizePixel = 0
OverlaySwitchButton.Text = ""
OverlaySwitchButton.AutoButtonColor = false
OverlaySwitchButton.Parent = OverlayToggleCard
local OverlaySwitchCorner = Instance.new("UICorner") OverlaySwitchCorner.CornerRadius = UDim.new(1, 0) OverlaySwitchCorner.Parent = OverlaySwitchButton
local OverlaySwitchStroke = Instance.new("UIStroke") OverlaySwitchStroke.Color = Color3.fromRGB(80, 80, 80) OverlaySwitchStroke.Thickness = 1.5 OverlaySwitchStroke.Parent = OverlaySwitchButton

local OverlaySwitchCore = Instance.new("Frame")
OverlaySwitchCore.Size = UDim2.new(0, 0, 0, 0)
OverlaySwitchCore.AnchorPoint = Vector2.new(0.5, 0.5)
OverlaySwitchCore.Position = UDim2.new(0.5, 0, 0.5, 0)
OverlaySwitchCore.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
OverlaySwitchCore.BorderSizePixel = 0
OverlaySwitchCore.Parent = OverlaySwitchButton
local OverlayCoreCorner = Instance.new("UICorner") OverlayCoreCorner.CornerRadius = UDim.new(1, 0) OverlayCoreCorner.Parent = OverlaySwitchCore
local OverlayCoreStroke = Instance.new("UIStroke") OverlayCoreStroke.Color = Color3.fromRGB(200, 140, 255) OverlayCoreStroke.Thickness = 1 OverlayCoreStroke.Transparency = 1 OverlayCoreStroke.Parent = OverlaySwitchCore

local LockCard = Instance.new("Frame")
LockCard.Size = UDim2.new(1, -28, 0, 38)
LockCard.Position = UDim2.new(0, 14, 0, 76)
LockCard.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
LockCard.BorderSizePixel = 0
LockCard.Parent = PanelOverlay
local LockCardCorner = Instance.new("UICorner") LockCardCorner.CornerRadius = UDim.new(0, 6) LockCardCorner.Parent = LockCard
local LockCardStroke = Instance.new("UIStroke") LockCardStroke.Color = Color3.fromRGB(30, 30, 30) LockCardStroke.Thickness = 1 LockCardStroke.Parent = LockCard

local LockCardLabel = Instance.new("TextLabel")
LockCardLabel.Size = UDim2.new(1, -60, 1, 0)
LockCardLabel.Position = UDim2.new(0, 12, 0, 0)
LockCardLabel.BackgroundTransparency = 1
LockCardLabel.Text = "Lock Overlay Position"
LockCardLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
LockCardLabel.TextSize = 11
LockCardLabel.Font = Enum.Font.GothamMedium
LockCardLabel.TextXAlignment = Enum.TextXAlignment.Left
LockCardLabel.Parent = LockCard

local LockSwitchButton = Instance.new("TextButton")
LockSwitchButton.Size = UDim2.new(0, 24, 0, 24)
LockSwitchButton.Position = UDim2.new(1, -14, 0.5, 0)
LockSwitchButton.AnchorPoint = Vector2.new(1, 0.5)
LockSwitchButton.BackgroundColor3 = Color3.fromRGB(10, 8, 15)
LockSwitchButton.BorderSizePixel = 0
LockSwitchButton.Text = ""
LockSwitchButton.AutoButtonColor = false
LockSwitchButton.Parent = LockCard
local LockSwitchCorner = Instance.new("UICorner") LockSwitchCorner.CornerRadius = UDim.new(1, 0) LockSwitchCorner.Parent = LockSwitchButton
local LockSwitchStroke = Instance.new("UIStroke") LockSwitchStroke.Color = Color3.fromRGB(180, 110, 255) LockSwitchStroke.Thickness = 2.2 LockSwitchStroke.Parent = LockSwitchButton

local LockSwitchCore = Instance.new("Frame")
LockSwitchCore.Size = UDim2.new(0, 12, 0, 12)
LockSwitchCore.AnchorPoint = Vector2.new(0.5, 0.5)
LockSwitchCore.Position = UDim2.new(0.5, 0, 0.5, 0)
LockSwitchCore.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
LockSwitchCore.BorderSizePixel = 0
LockSwitchCore.Parent = LockSwitchButton
local LockCoreCorner = Instance.new("UICorner") LockCoreCorner.CornerRadius = UDim.new(1, 0) LockCoreCorner.Parent = LockSwitchCore
local LockCoreStroke = Instance.new("UIStroke") LockCoreStroke.Color = Color3.fromRGB(200, 140, 255) LockCoreStroke.Thickness = 1 LockCoreStroke.Transparency = 0 LockCoreStroke.Parent = LockSwitchButton

--- COLOR CUSTOMIZER PANEL ---
local ThemeSecTitle = Instance.new("TextLabel")
ThemeSecTitle.Size = UDim2.new(0, 180, 0, 16)
ThemeSecTitle.Position = UDim2.new(0, 14, 0, 12)
ThemeSecTitle.BackgroundTransparency = 1
ThemeSecTitle.Text = "FULL GUI CUSTOMIZER"
ThemeSecTitle.TextColor3 = Color3.fromRGB(170, 170, 170)
ThemeSecTitle.TextSize = 10
ThemeSecTitle.Font = Enum.Font.GothamBold
ThemeSecTitle.TextXAlignment = Enum.TextXAlignment.Left
ThemeSecTitle.Parent = PanelTheme

local PartSelectCard = Instance.new("Frame")
PartSelectCard.Size = UDim2.new(1, -28, 0, 52)
PartSelectCard.Position = UDim2.new(0, 14, 0, 32)
PartSelectCard.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
PartSelectCard.BorderSizePixel = 0
PartSelectCard.Parent = PanelTheme
local PSCorner = Instance.new("UICorner") PSCorner.CornerRadius = UDim.new(0, 6) PSCorner.Parent = PartSelectCard
local PSStroke = Instance.new("UIStroke") PSStroke.Color = Color3.fromRGB(30, 30, 30) PSStroke.Thickness = 1 PSStroke.Parent = PartSelectCard

local PSLabel = Instance.new("TextLabel")
PSLabel.Size = UDim2.new(1, -16, 0, 16)
PSLabel.Position = UDim2.new(0, 10, 0, 5)
PSLabel.BackgroundTransparency = 1
PSLabel.Text = "1. Select Part to Customize:"
PSLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
PSLabel.TextSize = 10
PSLabel.Font = Enum.Font.GothamMedium
PSLabel.TextXAlignment = Enum.TextXAlignment.Left
PSLabel.Parent = PartSelectCard

local PartButtonsHolder = Instance.new("Frame")
PartButtonsHolder.Size = UDim2.new(1, -20, 0, 22)
PartButtonsHolder.Position = UDim2.new(0, 10, 0, 24)
PartButtonsHolder.BackgroundTransparency = 1
PartButtonsHolder.Parent = PartSelectCard

local partsList = {"Header", "Sidebar", "MainBg", "Keys", "Text"}
local partButtons = {}

local function updateSelectedPartHighlight()
    for pName, btn in pairs(partButtons) do
        if pName == SelectedCustomPart then
            btn.BackgroundColor3 = Color3.fromRGB(140, 100, 190)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            btn.TextColor3 = Color3.fromRGB(180, 180, 180)
        end
    end
end

for i, pName in ipairs(partsList) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.2, -3, 1, 0)
    btn.Position = UDim2.new((i-1)*0.2, 0, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.BorderSizePixel = 0
    btn.Text = pName
    btn.TextSize = 9
    btn.Font = Enum.Font.GothamBold
    btn.TextColor3 = Color3.fromRGB(180, 180, 180)
    btn.Parent = PartButtonsHolder
    local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, 4) c.Parent = btn
    
    partButtons[pName] = btn
    btn.MouseButton1Click:Connect(function()
        SelectedCustomPart = pName
        updateSelectedPartHighlight()
    end)
end
updateSelectedPartHighlight()

local currentColorValues = {R = 140, G = 100, B = 190}
local KeyFrames = {}

local function applyCurrentColor()
    local newColor = Color3.fromRGB(currentColorValues.R, currentColorValues.G, currentColorValues.B)
    ComponentColors[SelectedCustomPart] = newColor
    
    if SelectedCustomPart == "Header" then HeaderBar.BackgroundColor3 = newColor
    elseif SelectedCustomPart == "Sidebar" then Sidebar.BackgroundColor3 = newColor
    elseif SelectedCustomPart == "MainBg" then MainFrame.BackgroundColor3 = newColor
    elseif SelectedCustomPart == "Text" then TitleLabel.TextColor3 = newColor
    elseif SelectedCustomPart == "Keys" then
        for _, kData in pairs(KeyFrames) do kData.Frame.BackgroundColor3 = newColor end
    end
end

local function createInteractiveSlider(parent, labelText, initialValue, yPos, onValueChanged)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, -28, 0, 32)
    card.Position = UDim2.new(0, 14, 0, yPos)
    card.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    card.BorderSizePixel = 0
    card.Parent = parent
    
    local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, 6) c.Parent = card
    local s = Instance.new("UIStroke") s.Color = Color3.fromRGB(30, 30, 30) s.Thickness = 1 s.Parent = card

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0, 60, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText .. ":"
    lbl.TextColor3 = Color3.fromRGB(220, 220, 220)
    lbl.TextSize = 10
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = card

    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(0, 35, 1, 0)
    valLbl.Position = UDim2.new(1, -45, 0, 0)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = tostring(initialValue)
    valLbl.TextColor3 = Color3.fromRGB(180, 150, 220)
    valLbl.TextSize = 10
    valLbl.Font = Enum.Font.GothamBold
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.Parent = card

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -150, 0, 5)
    track.Position = UDim2.new(0, 75, 0.5, -2)
    track.BackgroundColor3 = Color3.fromRGB(20, 18, 28)
    track.BorderSizePixel = 0
    track.Parent = card
    local tc = Instance.new("UICorner") tc.CornerRadius = UDim.new(1, 0) tc.Parent = track

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(initialValue / 255, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(140, 100, 190)
    fill.BorderSizePixel = 0
    fill.Parent = track
    local fc = Instance.new("UICorner") fc.CornerRadius = UDim.new(1, 0) fc.Parent = fill

    local thumb = Instance.new("Frame")
    thumb.Size = UDim2.new(0, 12, 0, 12)
    thumb.AnchorPoint = Vector2.new(0.5, 0.5)
    thumb.Position = UDim2.new(initialValue / 255, 0, 0.5, 0)
    thumb.BackgroundColor3 = Color3.fromRGB(235, 225, 255)
    thumb.BorderSizePixel = 0
    thumb.Parent = track
    local thc = Instance.new("UICorner") thc.CornerRadius = UDim.new(1, 0) thc.Parent = thumb
    local ths = Instance.new("UIStroke") ths.Color = Color3.fromRGB(140, 100, 190) ths.Thickness = 1.5 ths.Parent = thumb

    local draggingSlider = false

    local function updateSlide(inputPos)
        local absPos = track.AbsolutePosition.X
        local absSize = track.AbsoluteSize.X
        if absSize <= 0 then return end
        local relX = math.clamp(inputPos - absPos, 0, absSize)
        local pct = relX / absSize
        local val = math.floor(pct * 255)

        fill.Size = UDim2.new(pct, 0, 1, 0)
        thumb.Position = UDim2.new(pct, 0, 0.5, 0)
        valLbl.Text = tostring(val)
        onValueChanged(val)
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingSlider = true
            updateSlide(input.Position.X)
        end
    end)
    thumb.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingSlider = true
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSlide(input.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingSlider = false
        end
    end)
end

createInteractiveSlider(PanelTheme, "Red", 140, 92, function(v) currentColorValues.R = v applyCurrentColor() end)
createInteractiveSlider(PanelTheme, "Green", 100, 128, function(v) currentColorValues.G = v applyCurrentColor() end)
createInteractiveSlider(PanelTheme, "Blue", 190, 164, function(v) currentColorValues.B = v applyCurrentColor() end)

--- KEY OVERLAY ---
local OverlayContainer = Instance.new("Frame")
OverlayContainer.Name = "KeyOverlay"
OverlayContainer.Size = UDim2.new(0, 290, 0, 170)
OverlayContainer.Position = UDim2.new(0, 20, 1, -190)
OverlayContainer.BackgroundTransparency = 1
OverlayContainer.BorderSizePixel = 0
OverlayContainer.Visible = false
OverlayContainer.Active = true
OverlayContainer.Parent = ScreenGui

local IsOverlayLocked = true
local overlayDragging, overlayDragInput, overlayDragStart, overlayStartPos

OverlayContainer.InputBegan:Connect(function(input)
    if IsOverlayLocked then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        overlayDragging = true
        overlayDragStart = input.Position
        overlayStartPos = OverlayContainer.Position
    end
end)

OverlayContainer.InputChanged:Connect(function(input)
    if IsOverlayLocked then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        overlayDragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if IsOverlayLocked then return end
    if input == overlayDragInput and overlayDragging then
        local delta = input.Position - overlayDragStart
        OverlayContainer.Position = UDim2.new(overlayStartPos.X.Scale, overlayStartPos.X.Offset + delta.X, overlayStartPos.Y.Scale, overlayStartPos.Y.Offset + delta.Y)
    end
end)

local function createKeyVisual(name, text, px, py, pw, ph)
    local btn = Instance.new("Frame")
    btn.Size = UDim2.new(0, pw or 45, 0, ph or 45)
    btn.Position = UDim2.new(0, px, 0, py)
    btn.BackgroundColor3 = ComponentColors.Keys
    btn.BackgroundTransparency = 0.1
    btn.BorderSizePixel = 0
    btn.Parent = OverlayContainer

    local corner = Instance.new("UICorner") corner.CornerRadius = UDim.new(0, 6) corner.Parent = btn
    local stroke = Instance.new("UIStroke") stroke.Color = Color3.fromRGB(110, 60, 160) stroke.Thickness = 1.5 stroke.Parent = btn

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(190, 145, 235)
    lbl.TextSize = 14
    lbl.Font = Enum.Font.SpecialElite
    lbl.Parent = btn

    KeyFrames[name] = {Frame = btn, Stroke = stroke, Label = lbl}
    return btn
end

createKeyVisual("Tab", "TAB", 8, 12, 55, 45)
createKeyVisual("Q", "Q", 68, 12, 45, 45)
createKeyVisual("W", "W", 118, 12, 45, 45)
createKeyVisual("E", "E", 168, 12, 45, 45)
createKeyVisual("A", "A", 68, 62, 45, 45)
createKeyVisual("S", "S", 118, 62, 45, 45)
createKeyVisual("D", "D", 168, 62, 45, 45)

local KeysPressed = {}

local function setKeyState(keyName, isPressed)
    KeysPressed[keyName] = isPressed
    if not OverlayContainer.Visible then return end
    local kData = KeyFrames[keyName]
    if not kData then return end
    
    if isPressed then
        TweenService:Create(kData.Frame, TweenInfo.new(0.08), {BackgroundColor3 = Color3.fromRGB(150, 90, 220)}):Play()
        TweenService:Create(kData.Stroke, TweenInfo.new(0.08), {Color = Color3.fromRGB(220, 185, 255)}):Play()
        TweenService:Create(kData.Label, TweenInfo.new(0.08), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
    else
        TweenService:Create(kData.Frame, TweenInfo.new(0.12), {BackgroundColor3 = ComponentColors.Keys}):Play()
        TweenService:Create(kData.Stroke, TweenInfo.new(0.12), {Color = Color3.fromRGB(110, 60, 160)}):Play()
        TweenService:Create(kData.Label, TweenInfo.new(0.12), {TextColor3 = Color3.fromRGB(190, 145, 235)}):Play()
    end
end

-- MINIMIZED FLOATING ICON
local MinimizeIconButton = Instance.new("TextButton")
MinimizeIconButton.Name = "MinimizeIconButton"
MinimizeIconButton.Size = UDim2.new(0, 42, 0, 42)
MinimizeIconButton.Position = UDim2.new(0, 24, 0.5, -21)
MinimizeIconButton.BackgroundColor3 = Color3.fromRGB(12, 10, 18)
MinimizeIconButton.BackgroundTransparency = 1
MinimizeIconButton.BorderSizePixel = 0
MinimizeIconButton.AutoButtonColor = false
MinimizeIconButton.Visible = false
MinimizeIconButton.Active = true
MinimizeIconButton.Draggable = true
MinimizeIconButton.Text = ""
MinimizeIconButton.Parent = ScreenGui

local IconCorner = Instance.new("UICorner") IconCorner.CornerRadius = UDim.new(1, 0) IconCorner.Parent = MinimizeIconButton
local IconStroke = Instance.new("UIStroke") IconStroke.Color = Color3.fromRGB(180, 200, 255) IconStroke.Transparency = 1 IconStroke.Thickness = 1.5 IconStroke.Parent = MinimizeIconButton

local MiniGlow = Instance.new("Frame")
MiniGlow.Size = UDim2.new(0, 32, 0, 32)
MiniGlow.AnchorPoint = Vector2.new(0.5, 0.5)
MiniGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
MiniGlow.BackgroundColor3 = Color3.fromRGB(210, 225, 255)
MiniGlow.BackgroundTransparency = 0.8
MiniGlow.BorderSizePixel = 0
MiniGlow.Parent = MinimizeIconButton
local mgCorner = Instance.new("UICorner") mgCorner.CornerRadius = UDim.new(1, 0) mgCorner.Parent = MiniGlow

local MiniMoon = Instance.new("Frame")
MiniMoon.Size = UDim2.new(0, 24, 0, 24)
MiniMoon.AnchorPoint = Vector2.new(0.5, 0.5)
MiniMoon.Position = UDim2.new(0.5, 0, 0.5, 0)
MiniMoon.BackgroundColor3 = Color3.fromRGB(220, 228, 240)
MiniMoon.BorderSizePixel = 0
MiniMoon.ClipsDescendants = true
MiniMoon.Parent = MinimizeIconButton
local MMCorner = Instance.new("UICorner") MMCorner.CornerRadius = UDim.new(1, 0) MMCorner.Parent = MiniMoon
local MMStroke = Instance.new("UIStroke") MMStroke.Color = Color3.fromRGB(180, 205, 245) MMStroke.Thickness = 1.2 MMStroke.Parent = MiniMoon

local function addMiniCrater(px, py, pw, ph, col, transp)
    local c = Instance.new("Frame")
    c.Size = UDim2.new(0, pw, 0, ph)
    c.Position = UDim2.new(0, px, 0, py)
    c.BackgroundColor3 = col or Color3.fromRGB(145, 160, 185)
    c.BackgroundTransparency = transp or 0.25
    c.BorderSizePixel = 0
    c.ZIndex = 6
    c.Parent = MiniMoon
    local cc = Instance.new("UICorner") cc.CornerRadius = UDim.new(1, 0) cc.Parent = c
end

addMiniCrater(3, 3, 8, 7, Color3.fromRGB(135, 150, 175), 0.2)
addMiniCrater(11, 7, 9, 8, Color3.fromRGB(140, 155, 180), 0.25)
addMiniCrater(6, 12, 10, 7, Color3.fromRGB(130, 145, 170), 0.3)
addMiniCrater(13, 3, 4, 4, Color3.fromRGB(255, 255, 255), 0.1)
addMiniCrater(2, 14, 5, 4, Color3.fromRGB(235, 245, 255), 0.15)
addMiniCrater(9, 2, 3, 3, Color3.fromRGB(240, 248, 255), 0.2)

task.spawn(function()
    while true do
        TweenService:Create(MMStroke, TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transparency = 0.5, Thickness = 2.5}):Play()
        TweenService:Create(MiniGlow, TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Size = UDim2.new(0, 36, 0, 36), BackgroundTransparency = 0.92}):Play()
        task.wait(1.4)
        TweenService:Create(MMStroke, TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transparency = 0.2, Thickness = 1.0}):Play()
        TweenService:Create(MiniGlow, TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Size = UDim2.new(0, 28, 0, 28), BackgroundTransparency = 0.78}):Play()
        task.wait(1.4)
    end
end)

TimeTextBox.FocusLost:Connect(function()
    local val = tonumber(TimeTextBox.Text)
    if val and val > 0 then 
        TargetDelay = math.clamp(val, AutoTimeMinLimit, AutoTimeMaxLimit)
        TimeTextBox.Text = tostring(TargetDelay)
    else 
        TimeTextBox.Text = tostring(TargetDelay) 
    end
end)

local function recordShotTiming(duration)
    if not AutoTimeEnabled then return end
    table.insert(ShotHistory, duration)
    if #ShotHistory > 5 then table.remove(ShotHistory, 1) end
    local sum = 0
    for _, t in ipairs(ShotHistory) do sum = sum + t end
    local avg = sum / #ShotHistory
    
    TargetDelay = math.clamp(tonumber(string.format("%.3f", avg)) or TargetDelay, AutoTimeMinLimit, AutoTimeMaxLimit)
    TimeTextBox.Text = tostring(TargetDelay)
end

local function startScanning()
    if ScanConnection then ScanConnection:Disconnect() end
    ScanConnection = RunService.RenderStepped:Connect(function()
        if not Running then return end
        if IsShooting then
            local elapsedTime = tick() - ShotStartTime
            
            if elapsedTime >= TargetDelay then
                pcall(function() VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game) end)
                IsShooting = false
                task.wait(0.3)
            end
        end
    end)
end

local function stopScanning()
    if ScanConnection then ScanConnection:Disconnect(); ScanConnection = nil end
end

-- Key Bindings
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Tab then setKeyState("Tab", true)
    elseif input.KeyCode == Enum.KeyCode.Q then setKeyState("Q", true)
    elseif input.KeyCode == Enum.KeyCode.W then setKeyState("W", true)
    elseif input.KeyCode == Enum.KeyCode.A then setKeyState("A", true)
    elseif input.KeyCode == Enum.KeyCode.S then setKeyState("S", true)
    elseif input.KeyCode == Enum.KeyCode.D then setKeyState("D", true)
    elseif input.KeyCode == Enum.KeyCode.E then 
        setKeyState("E", true)
        if Running then
            IsShooting = true
            ShotStartTime = tick()
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Tab then setKeyState("Tab", false)
    elseif input.KeyCode == Enum.KeyCode.Q then setKeyState("Q", false)
    elseif input.KeyCode == Enum.KeyCode.W then setKeyState("W", false)
    elseif input.KeyCode == Enum.KeyCode.A then setKeyState("A", false)
    elseif input.KeyCode == Enum.KeyCode.S then setKeyState("S", false)
    elseif input.KeyCode == Enum.KeyCode.D then setKeyState("D", false)
    elseif input.KeyCode == Enum.KeyCode.E then 
        setKeyState("E", false)
        if IsShooting then
            local elapsedTime = tick() - ShotStartTime
            
            if elapsedTime < TargetDelay then
                pcall(function() VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game) end)
            else
                local shotDuration = elapsedTime
                recordShotTiming(shotDuration)
                IsShooting = false
                pcall(function() VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game) end)
            end
        end
    end
end)

AutoTimeSwitchButton.MouseButton1Click:Connect(function()
    AutoTimeEnabled = not AutoTimeEnabled
    ShotHistory = {}
    applyBlackHoleToggleState(AutoTimeSwitchButton, ATSStroke, ATSCore, ATSCore.UIStroke, AutoTimeEnabled)
end)

SwitchButton.MouseButton1Click:Connect(function()
    Running = not Running
    IsShooting = false
    applyBlackHoleToggleState(SwitchButton, SwitchStroke, SwitchCore, SwitchCore.UIStroke, Running)
    if Running then startScanning() else stopScanning() end
end)

OverlaySwitchButton.MouseButton1Click:Connect(function()
    local hudEnabled = not OverlayContainer.Visible
    OverlayContainer.Visible = hudEnabled
    applyBlackHoleToggleState(OverlaySwitchButton, OverlaySwitchStroke, OverlaySwitchCore, OverlaySwitchCore.UIStroke, hudEnabled)
end)

LockSwitchButton.MouseButton1Click:Connect(function()
    IsOverlayLocked = not IsOverlayLocked
    applyBlackHoleToggleState(LockSwitchButton, LockSwitchStroke, LockSwitchCore, LockSwitchCore.UIStroke, IsOverlayLocked)
end)

MinBtn.MouseButton1Click:Connect(function()
    IsMinimized = true
    MainFrame.Visible = false
    MinimizeIconButton.Visible = true
end)

MinimizeIconButton.MouseButton1Click:Connect(function()
    IsMinimized = false
    MinimizeIconButton.Visible = false
    MainFrame.Visible = true
end)

PanicButton.MouseButton1Click:Connect(function()
    Running = false
    AutoTimeEnabled = false
    stopScanning()
    ScreenGui:Destroy()
end)

CloseBtn.MouseButton1Click:Connect(function()
    Running = false
    AutoTimeEnabled = false
    stopScanning()
    ScreenGui:Destroy()
end)
