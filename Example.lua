--[[
    CrystalUI Example Script
    
    This demonstrates all the features of the CrystalUI library.
]]

-- Load the library
-- For production: local Library = loadstring(game:HttpGet("YOUR_CRYSTALUI_URL"))()
-- For testing, paste the Library.lua contents above this line or use:
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/AduriteTBH/CrystalUI-Roblox-Library/refs/heads/main/Library.lua"))()

--[[ ============================================
    CREATE WINDOW
============================================ ]]--

local Window = Library:CreateWindow({
    Title = "CrystalUI Demo",
    Footer = "v1.0.0",
    Size = UDim2.fromOffset(680, 500),
    Center = true,
    AutoShow = true,
    ToggleKeybind = Enum.KeyCode.RightControl
})

-- Show welcome notification
Library:Notify({
    Title = "CrystalUI Loaded",
    Description = "Press Right-Ctrl to toggle UI",
    Time = 5
})

--[[ ============================================
    MAIN TAB
============================================ ]]--

local MainTab = Window:AddTab("Main", "home")

-- Left Groupbox
local LeftGroup = MainTab:AddLeftGroupbox("Features")

LeftGroup:AddLabel("Welcome to CrystalUI!")

LeftGroup:AddToggle("TestToggle", {
    Text = "Enable Feature",
    Default = false,
    Tooltip = "Toggle this feature on or off",
    Callback = function(Value)
        print("Toggle:", Value)
        Library:Notify("Feature " .. (Value and "enabled" or "disabled"), 2)
    end
})

LeftGroup:AddSlider("SpeedSlider", {
    Text = "Speed",
    Default = 16,
    Min = 16,
    Max = 100,
    Rounding = 0,
    Suffix = " studs/s",
    Callback = function(Value)
        print("Speed:", Value)
    end
})

LeftGroup:AddButton({
    Text = "Click Me",
    Tooltip = "A simple button",
    Func = function()
        Library:Notify("Button clicked!", 2)
    end
})

LeftGroup:AddButton({
    Text = "Risky Action",
    Risky = true,
    DoubleClick = true,
    Tooltip = "Double-click to confirm",
    Func = function()
        Library:Notify({
            Title = "Warning",
            Description = "Risky action executed!",
            Time = 3
        })
    end
})

-- Right Groupbox
local RightGroup = MainTab:AddRightGroupbox("Options")

RightGroup:AddInput("NameInput", {
    Text = "Your Name",
    Default = "",
    Placeholder = "Enter name...",
    Callback = function(Value)
        print("Name:", Value)
    end
})

RightGroup:AddDropdown("ModeDropdown", {
    Text = "Select Mode",
    Values = {"Easy", "Normal", "Hard", "Expert"},
    Default = "Normal",
    Callback = function(Value)
        print("Mode:", Value)
        Library:Notify("Mode: " .. Value, 2)
    end
})

RightGroup:AddDropdown("MultiSelect", {
    Text = "Features",
    Values = {"Speed", "Jump", "Fly", "Noclip"},
    Default = {},
    Multi = true,
    Callback = function(Values)
        local selected = {}
        for k, v in pairs(Values) do
            if v then table.insert(selected, k) end
        end
        print("Selected:", table.concat(selected, ", "))
    end
})

--[[ ============================================
    SETTINGS TAB
============================================ ]]--

local SettingsTab = Window:AddTab("Settings", "settings")

local UIGroup = SettingsTab:AddLeftGroupbox("UI Settings")

UIGroup:AddToggle("Notifications", {
    Text = "Show Notifications",
    Default = true
})

UIGroup:AddLabel({
    Text = "Press Right-Ctrl to toggle the UI visibility.",
    DoesWrap = true
})

local InfoGroup = SettingsTab:AddRightGroupbox("Information")

InfoGroup:AddLabel("CrystalUI Library")
InfoGroup:AddLabel("Glass Morphism Design")
InfoGroup:AddDivider()
InfoGroup:AddLabel({
    Text = "A modern UI library with smooth animations and beautiful styling.",
    DoesWrap = true
})

InfoGroup:AddButton({
    Text = "Unload UI",
    Risky = true,
    DoubleClick = true,
    Func = function()
        Library:Unload()
    end
})

print("CrystalUI loaded! Toggle: Right Control")
