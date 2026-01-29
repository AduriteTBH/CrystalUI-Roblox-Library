# CrystalUI

A modern, glass morphism UI library for Roblox with smooth animations and full customization.

![CrystalUI Preview](preview.png)

## Features

- 🌟 **Glass Morphism Design** - Beautiful frosted glass aesthetic with subtle blur effects
- ✨ **Smooth Animations** - All interactions use TweenService with Quint easing
- 🎨 **Full Customization** - Complete theming system with easy color customization
- 📱 **Mobile Support** - Touch-friendly interactions
- 🔔 **Notifications** - Toast-style notifications with progress bars
- 💡 **Tooltips** - Hover tooltips for additional information
- ⌨️ **Keybinds** - Full keybind support with Hold, Toggle, and Always modes
- 🎨 **Color Pickers** - RGB color pickers for any color property

## Installation

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/AduriteTBH/CrystalUI-Roblox-Library/refs/heads/main/Library.lua"))()
```

## Quick Start

```lua
-- Create a window
local Window = Library:CreateWindow({
    Title = "My Script",
    Footer = "v1.0.0",
    Center = true,
    AutoShow = true
})

-- Create a tab
local MainTab = Window:AddTab("Main", "home")

-- Create a groupbox
local Settings = MainTab:AddLeftGroupbox("Settings")

-- Add elements
Settings:AddToggle("MyToggle", {
    Text = "Enable Feature",
    Default = false,
    Callback = function(Value)
        print("Feature enabled:", Value)
    end
})
```

## API Reference

### Library

#### `Library:CreateWindow(options)`
Creates a new window.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| Title | string | "CrystalUI" | Window title |
| Footer | string | "" | Footer text |
| Size | UDim2 | (680, 520) | Window size |
| Position | UDim2 | (100, 100) | Initial position |
| Center | boolean | true | Center on screen |
| AutoShow | boolean | true | Show immediately |
| ToggleKeybind | KeyCode | RightControl | Toggle key |
| Resizable | boolean | true | Allow resizing |

#### `Library:Notify(options, duration)`
Shows a notification.

```lua
-- Simple
Library:Notify("Hello!", 5)

-- Advanced
Library:Notify({
    Title = "Success",
    Description = "Operation completed",
    Time = 5
})
```

#### `Library:Toggle(state)`
Shows or hides the UI.

#### `Library:Unload()`
Destroys the UI completely.

---

### Window

#### `Window:AddTab(name, icon)`
Adds a new tab. Returns a Tab object.

```lua
local Tab = Window:AddTab("Main", "home")
```

---

### Tab

#### `Tab:AddLeftGroupbox(name)` / `Tab:AddRightGroupbox(name)`
Creates a groupbox in the left or right column.

```lua
local LeftGroup = Tab:AddLeftGroupbox("Features")
local RightGroup = Tab:AddRightGroupbox("Options")
```

#### `Tab:AddLeftTabbox(name)` / `Tab:AddRightTabbox(name)`
Creates a tabbox (groupbox with internal tabs).

```lua
local Tabbox = Tab:AddLeftTabbox("Settings")
local SubTab1 = Tabbox:AddTab("General")
local SubTab2 = Tabbox:AddTab("Advanced")
```

---

### Groupbox Elements

#### `Groupbox:AddLabel(options)`
Adds a text label.

```lua
Groupbox:AddLabel("Simple label")

Groupbox:AddLabel({
    Text = "This is a wrapped label",
    DoesWrap = true
})
```

#### `Groupbox:AddDivider()`
Adds a horizontal divider line.

#### `Groupbox:AddButton(options)`
Adds a clickable button.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| Text | string | "Button" | Button text |
| Func | function | nil | Click callback |
| DoubleClick | boolean | false | Require double-click |
| Risky | boolean | false | Red styling |
| Disabled | boolean | false | Disable interaction |
| Tooltip | string | nil | Hover tooltip |

```lua
local Button = Groupbox:AddButton({
    Text = "Click Me",
    Func = function()
        print("Clicked!")
    end
})

-- Add sub-button
Button:AddButton({
    Text = "Sub",
    Func = function() end
})
```

#### `Groupbox:AddToggle(index, options)`
Adds a toggle switch.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| Text | string | "Toggle" | Label text |
| Default | boolean | false | Initial state |
| Callback | function | nil | State change callback |
| Disabled | boolean | false | Disable interaction |
| Tooltip | string | nil | Hover tooltip |

```lua
local Toggle = Groupbox:AddToggle("MyToggle", {
    Text = "Enable Feature",
    Default = false,
    Callback = function(Value)
        print("Toggled:", Value)
    end
})

-- Methods
Toggle:SetValue(true)
Toggle:GetValue()
Toggle:OnChanged(function(Value) end)
Toggle:AddKeyPicker("MyKey", {...})
Toggle:AddColorPicker("MyColor", {...})
```

#### `Groupbox:AddSlider(index, options)`
Adds a slider for numeric values.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| Text | string | "Slider" | Label text |
| Default | number | 0 | Initial value |
| Min | number | 0 | Minimum value |
| Max | number | 100 | Maximum value |
| Rounding | number | 0 | Decimal places |
| Prefix | string | "" | Text before value |
| Suffix | string | "" | Text after value |
| Callback | function | nil | Value change callback |

```lua
local Slider = Groupbox:AddSlider("Speed", {
    Text = "Walk Speed",
    Default = 16,
    Min = 16,
    Max = 100,
    Rounding = 0,
    Suffix = " studs/s",
    Callback = function(Value)
        print("Speed:", Value)
    end
})

-- Methods
Slider:SetValue(50)
Slider:SetMin(0)
Slider:SetMax(200)
Slider:OnChanged(function(Value) end)
```

#### `Groupbox:AddInput(index, options)`
Adds a text input field.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| Text | string | "Input" | Label text |
| Default | string | "" | Initial value |
| Placeholder | string | "" | Placeholder text |
| Numeric | boolean | false | Numbers only |
| Finished | boolean | false | Fire on Enter only |
| Callback | function | nil | Value change callback |

```lua
local Input = Groupbox:AddInput("Name", {
    Text = "Player Name",
    Placeholder = "Enter name...",
    Callback = function(Value)
        print("Name:", Value)
    end
})

-- Methods
Input:SetValue("NewName")
Input:OnChanged(function(Value) end)
```

#### `Groupbox:AddDropdown(index, options)`
Adds a dropdown selector.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| Text | string | nil | Label text |
| Values | table | {} | Available options |
| Default | any | nil | Default selection |
| Multi | boolean | false | Allow multiple selection |
| Callback | function | nil | Selection change callback |

```lua
-- Single select
local Dropdown = Groupbox:AddDropdown("Mode", {
    Text = "Select Mode",
    Values = {"Easy", "Normal", "Hard"},
    Default = "Normal",
    Callback = function(Value)
        print("Selected:", Value)
    end
})

-- Multi select
local MultiDropdown = Groupbox:AddDropdown("Features", {
    Text = "Enable Features",
    Values = {"ESP", "Aimbot", "Speed"},
    Default = {"ESP"},
    Multi = true,
    Callback = function(Values)
        for feature, enabled in pairs(Values) do
            print(feature, enabled)
        end
    end
})

-- Methods
Dropdown:SetValue("Hard")
Dropdown:SetValues({"New", "Options"})
Dropdown:AddValues({"Another"})
Dropdown:OnChanged(function(Value) end)
```

#### `Groupbox:AddKeyPicker(index, options)`
Adds a keybind picker.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| Text | string | "Keybind" | Label text |
| Default | string | "None" | Default key |
| Mode | string | "Toggle" | "Toggle", "Hold", or "Always" |
| SyncToggleState | boolean | false | Sync with parent toggle |
| Callback | function | nil | State change callback |

```lua
-- Standalone
local KeyPicker = Groupbox:AddKeyPicker("MyKey", {
    Text = "Activate Key",
    Default = "E",
    Mode = "Hold",
    Callback = function(Active)
        print("Key active:", Active)
    end
})

-- Attached to toggle
local Toggle = Groupbox:AddToggle("MyToggle", {...})
Toggle:AddKeyPicker("ToggleKey", {
    Default = "F",
    Mode = "Toggle",
    SyncToggleState = true
})

-- Methods
KeyPicker:SetValue({"G", "Hold"})
KeyPicker:GetState()
```

#### `Groupbox:AddColorPicker(index, options)`
Adds a color picker.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| Default | Color3 | White | Default color |
| Title | string | "Color Picker" | Picker title |
| Callback | function | nil | Color change callback |

```lua
-- Standalone
local ColorPicker = Groupbox:AddColorPicker("BGColor", {
    Default = Color3.fromRGB(255, 0, 0),
    Title = "Background Color",
    Callback = function(Color)
        print("Color:", Color)
    end
})

-- Attached to toggle
local Toggle = Groupbox:AddToggle("ESPToggle", {...})
Toggle:AddColorPicker("ESPColor", {
    Default = Color3.fromRGB(0, 255, 0),
    Title = "ESP Color"
})

-- Methods
ColorPicker:SetValue(Color3.fromRGB(0, 0, 255))
ColorPicker:OnChanged(function(Color) end)
```

---

### Accessing Elements

All elements are stored in `Library.Options` and `Library.Toggles` by their index:

```lua
-- Access toggle
Library.Toggles.MyToggle:SetValue(true)
print(Library.Toggles.MyToggle.Value)

-- Access any option
Library.Options.MySlider:SetValue(50)
Library.Options.MyDropdown:SetValue("Hard")
```

---

## Theming

Customize the UI appearance by modifying `Library.Scheme`:

```lua
Library.Scheme = {
    -- Main Colors
    Background = Color3.fromRGB(15, 15, 20),
    Surface = Color3.fromRGB(25, 25, 35),
    SurfaceLight = Color3.fromRGB(35, 35, 50),
    
    -- Glass Effect
    GlassBackground = Color3.fromRGB(30, 30, 45),
    GlassBorder = Color3.fromRGB(60, 60, 80),
    GlassHighlight = Color3.fromRGB(255, 255, 255),
    
    -- Accent
    Accent = Color3.fromRGB(100, 140, 255),
    AccentDark = Color3.fromRGB(70, 100, 200),
    AccentLight = Color3.fromRGB(130, 170, 255),
    
    -- Text
    TextPrimary = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(180, 180, 200),
    TextMuted = Color3.fromRGB(120, 120, 140),
    
    -- Status
    Success = Color3.fromRGB(100, 200, 120),
    Warning = Color3.fromRGB(255, 180, 80),
    Error = Color3.fromRGB(255, 100, 100),
    
    -- Transparency
    GlassTransparency = 0.15,
    BorderTransparency = 0.5,
}
```

---

## Credits

- Inspired by [ObsidianUI](https://github.com/deividcomsono/Obsidian)
- Glass morphism design principles
- Built with ❤️ for the Roblox development community

## License

MIT License - Feel free to use, modify, and distribute.
