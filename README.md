# LanternLib

A sleek, modern dark cyan UI library for Roblox scripting, built with clean design aesthetics and complete configuration management.

## 🚀 Quick Start

Load **LanternLib** directly from GitHub via `game:HttpGet`:

```lua
local repo = "https://raw.githubusercontent.com/LanternSupport/LanternLib/main/"

local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()
```

---

## 📋 Basic Usage Example

```lua
local repo = "https://raw.githubusercontent.com/LanternSupport/LanternLib/main/"

local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

-- Create Main Window
local Window = Library:CreateWindow({
    Title = "LanternLib Interface",
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

-- Navigation Tabs
local Tabs = {
    Main = Window:AddTab("Main"),
    ["UI Settings"] = Window:AddTab("UI Settings"),
}

-- Add Groupbox
local MainGroup = Tabs.Main:AddLeftGroupbox("Features")

MainGroup:AddToggle("ExampleToggle", {
    Text = "Enable Feature",
    Default = false,
    Tooltip = "Example toggle description",
    Callback = function(Value)
        print("Toggle value:", Value)
    end
})

MainGroup:AddButton("Execute Action", function()
    Library:Notify("Button was clicked!", 3)
end)

-- Setup Theme & Save Manager in UI Settings tab
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
ThemeManager:SetFolder("LanternLib")
SaveManager:SetFolder("LanternLib")

SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])
SaveManager:LoadAutoloadConfig()
```

> 💡 For a comprehensive demonstration covering all features (sliders, dropdowns, sub-buttons, color pickers, keybinds, tabboxes, watermarks, etc.), see [Example.lua](Example.lua).

---

## 📂 Repository Structure

```text
LanternLib/
├── Library.lua          # Core UI Library engine
├── Example.lua          # Full showcase reference script
├── addons/
│   ├── ThemeManager.lua # Built-in & custom theme management
│   └── SaveManager.lua  # Config presets & auto-load management
├── assets/              # UI textures & icons (with fallback to Roblox asset IDs)
├── loader/              # Key System Loader UI module
│   ├── LoaderLib.lua    # Loader UI Engine (550x180 px)
│   └── Example.lua      # Generic Key system example
└── README.md
```
