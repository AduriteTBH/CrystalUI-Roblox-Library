--[[
    CrystalUI Example Script
    
    This demonstrates all the features of the CrystalUI library.
    For your own games, simply require the Library and start building!
]]

-- Load the library (adjust path as needed)
-- For local testing: local Library = require(script.Parent.Library)
-- For GitHub hosting: local Library = loadstring(game:HttpGet("YOUR_RAW_GITHUB_URL"))()

local Library = loadstring(game:HttpGet("YOUR_CRYSTALUI_LIBRARY_URL"))()

--[[ ============================================
    CREATE WINDOW
============================================ ]]--

local Window = Library:CreateWindow({
    Title = "CrystalUI Demo",
    Footer = "v1.0.0 | Made with ❤️",
    Size = UDim2.fromOffset(700, 550),
    Center = true,
    AutoShow = true,
    ToggleKeybind = Enum.KeyCode.RightControl
})

--[[ ============================================
    MAIN TAB
============================================ ]]--

local MainTab = Window:AddTab("Main", "home")

-- Left side groupbox
local FeaturesGroup = MainTab:AddLeftGroupbox("Features")

FeaturesGroup:AddLabel("Welcome to CrystalUI!")
FeaturesGroup:AddLabel({
    Text = "This library features glass morphism design, smooth animations, and full customization.",
    DoesWrap = true
})

FeaturesGroup:AddDivider()

-- Toggle example
local MyToggle = FeaturesGroup:AddToggle("MyToggle", {
    Text = "Enable Feature",
    Default = false,
    Tooltip = "This toggle enables an awesome feature!",
    Callback = function(Value)
        print("Feature enabled:", Value)
    end
})

MyToggle:OnChanged(function(Value)
    Library:Notify({
        Title = "Toggle Changed",
        Description = "Feature is now " .. (Value and "enabled" or "disabled"),
        Time = 3
    })
end)

-- Slider example
local SpeedSlider = FeaturesGroup:AddSlider("SpeedSlider", {
    Text = "Speed Multiplier",
    Default = 1,
    Min = 0.5,
    Max = 5,
    Rounding = 1,
    Suffix = "x",
    Callback = function(Value)
        print("Speed set to:", Value)
    end
})

-- Button example
local ActionButton = FeaturesGroup:AddButton({
    Text = "Execute Action",
    Tooltip = "Click to execute the main action",
    Func = function()
        Library:Notify("Action executed successfully!", 3)
    end
})

-- Sub-button example
ActionButton:AddButton({
    Text = "Secondary",
    Func = function()
        Library:Notify("Secondary action!", 2)
    end
})

-- Risky button example
FeaturesGroup:AddButton({
    Text = "Dangerous Action",
    Risky = true,
    DoubleClick = true,
    Tooltip = "Double-click to confirm this risky action",
    Func = function()
        Library:Notify({
            Title = "Warning",
            Description = "Dangerous action executed!",
            Time = 4
        })
    end
})

-- Right side groupbox
local OptionsGroup = MainTab:AddRightGroupbox("Options")

-- Input example
local NameInput = OptionsGroup:AddInput("NameInput", {
    Text = "Player Name",
    Default = "",
    Placeholder = "Enter name...",
    Callback = function(Value)
        print("Name entered:", Value)
    end
})

-- Numeric input example
local AmountInput = OptionsGroup:AddInput("AmountInput", {
    Text = "Amount",
    Default = "100",
    Numeric = true,
    Finished = true, -- Only fires when Enter is pressed
    Callback = function(Value)
        print("Amount set to:", Value)
    end
})

-- Dropdown example
local ModeDropdown = OptionsGroup:AddDropdown("ModeDropdown", {
    Text = "Select Mode",
    Values = {"Normal", "Fast", "Turbo", "Insane"},
    Default = "Normal",
    Callback = function(Value)
        print("Mode selected:", Value)
    end
})

-- Multi-select dropdown example
local FeaturesDropdown = OptionsGroup:AddDropdown("FeaturesDropdown", {
    Text = "Enable Features",
    Values = {"ESP", "Aimbot", "Speed", "Fly", "Noclip"},
    Default = {"ESP"},
    Multi = true,
    Callback = function(Values)
        print("Selected features:")
        for feature, enabled in pairs(Values) do
            if enabled then
                print("  -", feature)
            end
        end
    end
})

--[[ ============================================
    COMBAT TAB (with Tabbox example)
============================================ ]]--

local CombatTab = Window:AddTab("Combat", "crosshair")

local CombatTabbox = CombatTab:AddLeftTabbox("Combat Options")

-- Aimbot tab
local AimbotTab = CombatTabbox:AddTab("Aimbot")

local AimbotToggle = AimbotTab:AddToggle("AimbotEnabled", {
    Text = "Enable Aimbot",
    Default = false,
    Callback = function(Value)
        print("Aimbot:", Value)
    end
})

-- Add keybind to toggle
AimbotToggle:AddKeyPicker("AimbotKey", {
    Text = "Aimbot Key",
    Default = "E",
    Mode = "Hold",
    SyncToggleState = true,
    Callback = function(Value)
        print("Aimbot key state:", Value)
    end
})

-- Add color picker to toggle
AimbotToggle:AddColorPicker("AimbotColor", {
    Default = Color3.fromRGB(255, 0, 0),
    Title = "Aimbot FOV Color",
    Callback = function(Value)
        print("Aimbot color:", Value)
    end
})

AimbotTab:AddSlider("AimbotFOV", {
    Text = "FOV Size",
    Default = 100,
    Min = 10,
    Max = 500,
    Rounding = 0,
    Suffix = "px",
    Callback = function(Value)
        print("FOV:", Value)
    end
})

AimbotTab:AddSlider("AimbotSmooth", {
    Text = "Smoothness",
    Default = 5,
    Min = 1,
    Max = 20,
    Rounding = 1,
    Callback = function(Value)
        print("Smoothness:", Value)
    end
})

AimbotTab:AddDropdown("AimbotTarget", {
    Text = "Target Part",
    Values = {"Head", "Torso", "HumanoidRootPart"},
    Default = "Head",
    Callback = function(Value)
        print("Targeting:", Value)
    end
})

-- Triggerbot tab
local TriggerbotTab = CombatTabbox:AddTab("Triggerbot")

TriggerbotTab:AddToggle("TriggerbotEnabled", {
    Text = "Enable Triggerbot",
    Default = false,
    Callback = function(Value)
        print("Triggerbot:", Value)
    end
})

TriggerbotTab:AddSlider("TriggerbotDelay", {
    Text = "Trigger Delay",
    Default = 50,
    Min = 0,
    Max = 500,
    Rounding = 0,
    Suffix = "ms",
    Callback = function(Value)
        print("Trigger delay:", Value)
    end
})

-- Right side - ESP options
local ESPGroup = CombatTab:AddRightGroupbox("ESP Settings")

local ESPToggle = ESPGroup:AddToggle("ESPEnabled", {
    Text = "Enable ESP",
    Default = false,
    Callback = function(Value)
        print("ESP:", Value)
    end
})

ESPToggle:AddColorPicker("ESPColor", {
    Default = Color3.fromRGB(100, 255, 100),
    Title = "ESP Color",
    Callback = function(Value)
        print("ESP Color:", Value)
    end
})

ESPGroup:AddDropdown("ESPElements", {
    Text = "ESP Elements",
    Values = {"Boxes", "Names", "Health Bars", "Distance", "Tracers", "Skeletons"},
    Default = {"Boxes", "Names"},
    Multi = true,
    Callback = function(Values)
        print("ESP Elements changed")
    end
})

ESPGroup:AddSlider("ESPDistance", {
    Text = "Max Distance",
    Default = 1000,
    Min = 100,
    Max = 5000,
    Rounding = 0,
    Suffix = " studs",
    Callback = function(Value)
        print("ESP Distance:", Value)
    end
})

--[[ ============================================
    SETTINGS TAB
============================================ ]]--

local SettingsTab = Window:AddTab("Settings", "settings")

local UISettings = SettingsTab:AddLeftGroupbox("UI Settings")

UISettings:AddToggle("Notifications", {
    Text = "Enable Notifications",
    Default = true,
    Callback = function(Value)
        print("Notifications:", Value)
    end
})

UISettings:AddSlider("UITransparency", {
    Text = "UI Transparency",
    Default = 0,
    Min = 0,
    Max = 50,
    Rounding = 0,
    Suffix = "%",
    Callback = function(Value)
        print("Transparency:", Value)
    end
})

UISettings:AddDropdown("Theme", {
    Text = "Color Theme",
    Values = {"Default", "Red", "Green", "Purple", "Orange"},
    Default = "Default",
    Callback = function(Value)
        -- You could implement theme switching here
        if Value == "Red" then
            Library.Scheme.Accent = Color3.fromRGB(255, 100, 100)
        elseif Value == "Green" then
            Library.Scheme.Accent = Color3.fromRGB(100, 255, 100)
        elseif Value == "Purple" then
            Library.Scheme.Accent = Color3.fromRGB(180, 100, 255)
        elseif Value == "Orange" then
            Library.Scheme.Accent = Color3.fromRGB(255, 180, 100)
        else
            Library.Scheme.Accent = Color3.fromRGB(100, 140, 255)
        end
        Library:Notify("Theme changed to " .. Value, 2)
    end
})

-- Config management
local ConfigGroup = SettingsTab:AddRightGroupbox("Configuration")

ConfigGroup:AddInput("ConfigName", {
    Text = "Config Name",
    Default = "default",
    Placeholder = "Enter config name...",
    Callback = function(Value)
        print("Config name:", Value)
    end
})

ConfigGroup:AddButton({
    Text = "Save Config",
    Func = function()
        local name = Library.Options.ConfigName.Value
        Library:Notify({
            Title = "Config Saved",
            Description = "Saved as: " .. name,
            Time = 3
        })
    end
})

ConfigGroup:AddButton({
    Text = "Load Config",
    Func = function()
        local name = Library.Options.ConfigName.Value
        Library:Notify({
            Title = "Config Loaded",
            Description = "Loaded: " .. name,
            Time = 3
        })
    end
})

ConfigGroup:AddButton({
    Text = "Delete Config",
    Risky = true,
    DoubleClick = true,
    Func = function()
        local name = Library.Options.ConfigName.Value
        Library:Notify({
            Title = "Config Deleted",
            Description = "Deleted: " .. name,
            Time = 3
        })
    end
})

ConfigGroup:AddDivider()

ConfigGroup:AddButton({
    Text = "Unload UI",
    Risky = true,
    DoubleClick = true,
    Func = function()
        Library:Unload()
    end
})

--[[ ============================================
    CREDITS TAB
============================================ ]]--

local CreditsTab = Window:AddTab("Credits", "info")

local CreditsGroup = CreditsTab:AddLeftGroupbox("About")

CreditsGroup:AddLabel({
    Text = "CrystalUI - A Glass Morphism UI Library",
    DoesWrap = false
})

CreditsGroup:AddDivider()

CreditsGroup:AddLabel({
    Text = "Features:\n• Glass morphism design\n• Smooth TweenService animations\n• Full customization system\n• Similar API to ObsidianUI\n• Notifications & Tooltips\n• Keybind support\n• Color pickers\n• And much more!",
    DoesWrap = true
})

local LinksGroup = CreditsTab:AddRightGroupbox("Links")

LinksGroup:AddButton({
    Text = "Copy Discord Invite",
    Func = function()
        -- setclipboard("discord.gg/example")
        Library:Notify("Discord link copied!", 2)
    end
})

LinksGroup:AddButton({
    Text = "Open Documentation",
    Func = function()
        Library:Notify("Documentation: github.com/...", 3)
    end
})

--[[ ============================================
    INITIAL NOTIFICATION
============================================ ]]--

Library:Notify({
    Title = "CrystalUI Loaded",
    Description = "Press Right-Ctrl to toggle the UI",
    Time = 5
})

print("CrystalUI Example loaded successfully!")
print("Toggle keybind: Right Control")
print("Access elements via Library.Options or Library.Toggles")
