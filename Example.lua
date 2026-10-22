--[[
    =============================================================================
    LanternUI - Modern Minimal Dark Cyan Interface Example
    =============================================================================
    A comprehensive reference example showcasing all features and components
    available in LanternUI (Engine, Controls, Containers, Themes, and Configs).

    Features demonstrated:
      - Windows, Tabs, Groupboxes, and Tabboxes
      - Toggles with attached ColorPickers and KeyPickers
      - Buttons with Sub-Buttons (single-click & double-click)
      - Sliders (standard & custom format display)
      - Text Inputs (standard & numeric)
      - Dropdowns (single, multi-select, searchable, compact addon)
      - Keybinds (Toggle, Hold, Press modes)
      - Dependency Boxes (nested visibility control)
      - Realtime Watermark (FPS & Ping tracking)
      - SaveManager (JSON configuration presets)
      - ThemeManager (Built-in themes & custom color pickers)
    =============================================================================
--]]

-- [1] Module Loader (Loads directly from GitHub Raw with local workspace fallback for testing)
local repo = "https://raw.githubusercontent.com/LanternSupport/LanternLib/main/"

local function loadModule(relPath)
	-- Local executor workspace fallback (if developing locally)
	if readfile and isfile then
		if isfile("LanternLib/" .. relPath) then
			return loadstring(readfile("LanternLib/" .. relPath))()
		elseif isfile(relPath) then
			return loadstring(readfile(relPath))()
		end
	end

	-- Remote GitHub Raw
	local success, content = pcall(function()
		return game:HttpGet(repo .. relPath)
	end)

	if success and content and #content > 0 and not content:find("404: Not Found") then
		return loadstring(content)()
	end

	error("[LanternLib] Failed to load module: " .. tostring(relPath))
end

local Library = loadModule("Library.lua")
local ThemeManager = loadModule("addons/ThemeManager.lua")
local SaveManager = loadModule("addons/SaveManager.lua")

-- Direct access tables added by Library to global / environment
local Options = Library.Options
local Toggles = Library.Toggles

-- Global UI Preferences
Library.ShowToggleFrameInKeybinds = true -- Allows toggling directly inside the Keybinds menu
Library.NotifySide = "Left"              -- Side where notifications appear: "Left" or "Right"

-- [2] Create Window
local Window = Library:CreateWindow({
	Title = "LanternX Hub",
	Center = true,                 -- Center menu on screen upon launch
	AutoShow = true,               -- Automatically display menu when loaded
	Resizable = true,              -- Allow user to resize the window in-game
	UnlockMouseWhileOpen = true,   -- Automatically unlock mouse while the menu is open
	NotifySide = "Left",           -- Side of notifications: "Left" or "Right"
	TabPadding = 8,                -- Spacing between tab buttons
	MenuFadeTime = 0.2             -- Fade transition animation duration
})

-- [3] Define Navigation Tabs (Combined Main features & UI Settings)
local Tabs = {
	Main = Window:AddTab("Main"),
	["UI Settings"] = Window:AddTab("UI Settings"),
}

-- =============================================================================
-- TAB: MAIN (All UI Elements & Showcase)
-- =============================================================================

--------------------------------------------------------------------------------
-- LEFT COLUMN: Toggles, Buttons, Sliders, Text Inputs, and Tabbox
--------------------------------------------------------------------------------

-- [Left 1] Controls & Buttons Groupbox
local MainControls = Tabs.Main:AddLeftGroupbox("Controls & Buttons")

-- Toggle with attached ColorPickers
MainControls:AddToggle("AutoFarmToggle", {
	Text = "Auto Farm Feature",
	Default = false,
	Tooltip = "Toggles automatic farming cycle.",
	Callback = function(Value)
		print("[LanternUI] AutoFarm toggled:", Value)
	end
}):AddColorPicker("EspColorPrimary", {
	Default = Color3.fromRGB(56, 189, 248), -- Cyan accent
	Title = "Highlight Color",
	Transparency = 0,
	Callback = function(Value, Transparency)
		print("[LanternUI] Highlight color updated:", Value, "Alpha:", Transparency)
	end
}):AddColorPicker("EspColorSecondary", {
	Default = Color3.fromRGB(244, 63, 94), -- Red secondary
	Title = "Target Color",
	Transparency = 0,
	Callback = function(Value, Transparency)
		print("[LanternUI] Target color updated:", Value, "Alpha:", Transparency)
	end
})

-- Listen for changes programmatically
Toggles.AutoFarmToggle:OnChanged(function()
	print("[LanternUI] AutoFarm state is now:", Toggles.AutoFarmToggle.Value)
end)

MainControls:AddDivider()

-- Interactive Buttons & Sub-Buttons
local ActionBtn = MainControls:AddButton({
	Text = "Perform Action",
	DoubleClick = false,
	Tooltip = "Click once to trigger an action and notification.",
	Func = function()
		Library:Notify("Action executed successfully!", 4)
	end
})

-- Sub-Button (placed side-by-side with ActionBtn, requires double-click)
ActionBtn:AddButton({
	Text = "Confirm (2x)",
	DoubleClick = true,
	Tooltip = "Double-click to confirm critical action.",
	Func = function()
		Library:Notify("Critical action confirmed with sound!", 4, 4590657391)
	end
})

-- Disabled Button example
MainControls:AddButton({
	Text = "Unavailable Action",
	Disabled = true,
	DisabledTooltip = "This feature is currently locked.",
	Func = function() end
})

MainControls:AddDivider()

-- Labels with wrapping support
MainControls:AddLabel("Status: Active and running.", false, "StatusLabel")
MainControls:AddLabel("Multiline label:\nLanternUI provides clean dark cyan styling.", true)

-- [Left 2] Sliders & Inputs Groupbox
local SlidersGroup = Tabs.Main:AddLeftGroupbox("Sliders & Inputs")

-- Standard numeric Slider
SlidersGroup:AddSlider("WalkSpeedSlider", {
	Text = "Walk Speed",
	Default = 16,
	Min = 16,
	Max = 120,
	Rounding = 0,
	Suffix = " studs/s",
	Compact = false,
	Tooltip = "Adjust character movement speed.",
	Callback = function(Value)
		print("[LanternUI] WalkSpeed:", Value)
	end
})

-- Custom Display Formatter Slider
SlidersGroup:AddSlider("FovSlider", {
	Text = "Field of View",
	Default = 70,
	Min = 50,
	Max = 120,
	Rounding = 0,
	Compact = false,
	FormatDisplayValue = function(slider, value)
		if value == slider.Min then return "Narrow (50°)" end
		if value == slider.Max then return "Ultra Wide (120°)" end
		return tostring(value) .. "°"
	end,
	Callback = function(Value)
		print("[LanternUI] FOV updated:", Value)
	end
})

SlidersGroup:AddDivider()

-- Text Input (Textbox)
SlidersGroup:AddInput("CustomTagInput", {
	Default = "LanternX User",
	Text = "Player Custom Tag",
	Placeholder = "Enter your tag...",
	ClearTextOnFocus = false,
	Tooltip = "Type a custom tag to display over your character.",
	Callback = function(Value)
		print("[LanternUI] Custom tag set to:", Value)
	end
})

-- Numeric-only Input
SlidersGroup:AddInput("TeleportDelayInput", {
	Default = "1.5",
	Numeric = true,
	Finished = true, -- Only triggers callback when user presses Enter
	Text = "Teleport Delay (sec)",
	Placeholder = "1.0",
	Tooltip = "Press Enter to apply delay value.",
	Callback = function(Value)
		print("[LanternUI] Teleport delay applied:", Value)
	end
})

-- [Left 3] Tabbox Example (multiple sub-tabs inside one column box)
local LeftTabbox = Tabs.Main:AddLeftTabbox()
local SubTab1 = LeftTabbox:AddTab("Preset A")
local SubTab2 = LeftTabbox:AddTab("Preset B")

SubTab1:AddToggle("PresetAToggle", { Text = "Fast Reload" })
SubTab1:AddSlider("PresetASlider", { Text = "Multiplier", Default = 1, Min = 1, Max = 5, Rounding = 1 })

SubTab2:AddToggle("PresetBToggle", { Text = "Silent Walk" })
SubTab2:AddSlider("PresetBSlider", { Text = "Volume", Default = 0, Min = 0, Max = 100, Rounding = 0 })

--------------------------------------------------------------------------------
-- RIGHT COLUMN: Dropdowns, Keybinds, and Dependency Boxes
--------------------------------------------------------------------------------

-- [Right 1] Dropdowns Groupbox
local DropdownGroup = Tabs.Main:AddRightGroupbox("Dropdown Showcase")

-- Single Selection Dropdown
DropdownGroup:AddDropdown("WeaponDropdown", {
	Text = "Selected Weapon",
	Values = { "Rifle", "Shotgun", "Sniper", "Pistol", "Katana" },
	Default = 1,
	Multi = false,
	Tooltip = "Select weapon preset.",
	Callback = function(Value)
		print("[LanternUI] Weapon selected:", Value)
	end
})

-- Searchable Dropdown (ideal for long lists)
DropdownGroup:AddDropdown("LocationDropdown", {
	Text = "Searchable Location",
	Values = { "Spawn Island", "Main City", "Underground Base", "Desert Outpost", "Mountain Peak", "Harbor Dock" },
	Default = 1,
	Multi = false,
	Searchable = true,
	Tooltip = "Type to filter locations.",
	Callback = function(Value)
		print("[LanternUI] Teleporting to:", Value)
	end
})

-- Multi-Selection Dropdown
DropdownGroup:AddDropdown("EspFiltersDropdown", {
	Text = "ESP Filter Layers",
	Values = { "Boxes", "Names", "Health", "Distance", "Tracers", "Snaplines" },
	Default = { "Boxes", "Names" },
	Multi = true,
	Tooltip = "Toggle multiple display options simultaneously.",
	Callback = function(Value)
		print("[LanternUI] ESP Filters updated:")
		for item, enabled in pairs(Options.EspFiltersDropdown.Value) do
			if enabled then
				print("  - " .. item)
			end
		end
	end
})

-- [Right 2] Keybinds Groupbox
local KeybindGroup = Tabs.Main:AddRightGroupbox("Keybinds & Addons")

-- Label with attached KeyPicker (Toggle Mode)
KeybindGroup:AddLabel("Fly Keybind"):AddKeyPicker("FlyKeybind", {
	Default = "F",
	SyncToggleState = false,
	Mode = "Toggle", -- Modes: "Toggle", "Hold", "Press", "Always"
	Text = "Fly Toggle",
	NoUI = false,
	Callback = function(Value)
		print("[LanternUI] Fly keybind toggled:", Value)
	end
})

-- Label with attached KeyPicker (Hold Mode)
KeybindGroup:AddLabel("Sprint Keybind"):AddKeyPicker("SprintKeybind", {
	Default = "LeftShift",
	Mode = "Hold",
	Text = "Sprint (Hold)",
	Callback = function(Value)
		print("[LanternUI] Sprinting:", Value)
	end
})

-- Label with attached KeyPicker (Press Mode)
KeybindGroup:AddLabel("Quick Teleport"):AddKeyPicker("TeleportKeybind", {
	Default = "T",
	Mode = "Press",
	Text = "Quick Teleport",
	Callback = function()
		print("[LanternUI] Quick Teleport pressed!")
	end
})

-- Label with attached Compact Dropdown
KeybindGroup:AddLabel("Aim Target"):AddDropdown("AimTargetDropdown", {
	Values = { "Head", "Torso", "Random" },
	Default = 1,
	Multi = false,
	Tooltip = "Select target hit part.",
	Callback = function(Value)
		print("[LanternUI] Aim target changed to:", Value)
	end
})

-- [Right 3] Dependency Box Example
local DependencyGroup = Tabs.Main:AddRightGroupbox("Dependency Controls")

DependencyGroup:AddToggle("ShowAdvancedToggle", {
	Text = "Show Advanced Options",
	Default = false,
	Tooltip = "Reveals extra settings below when enabled."
})

local AdvancedDepBox = DependencyGroup:AddDependencyBox()
AdvancedDepBox:AddSlider("SmoothingSlider", { Text = "Aim Smoothing", Default = 5, Min = 1, Max = 20, Rounding = 1 })
AdvancedDepBox:AddDropdown("PriorityDropdown", { Text = "Target Priority", Values = { "Closest Distance", "Lowest Health", "Crosshair FOV" }, Default = 1 })

-- Link visibility to ShowAdvancedToggle being true
AdvancedDepBox:SetupDependencies({
	{ Toggles.ShowAdvancedToggle, true }
})

-- =============================================================================
-- REALTIME WATERMARK (FPS & Ping tracking)
-- =============================================================================
Library:SetWatermarkVisibility(true)

local FrameTimer = tick()
local FrameCounter = 0
local CurrentFPS = 60
local GetPing = function()
	return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
end
local SupportsPing = pcall(function() return GetPing() end)

local WatermarkConnection = game:GetService("RunService").RenderStepped:Connect(function()
	FrameCounter += 1

	if (tick() - FrameTimer) >= 1 then
		CurrentFPS = FrameCounter
		FrameTimer = tick()
		FrameCounter = 0
	end

	if SupportsPing then
		Library:SetWatermark(("LanternX Hub | %d FPS | %d ms"):format(
			math.floor(CurrentFPS),
			GetPing()
		))
	else
		Library:SetWatermark(("LanternX Hub | %d FPS"):format(math.floor(CurrentFPS)))
	end
end)

-- Clean up connection when menu is unloaded
Library:OnUnload(function()
	if WatermarkConnection then
		WatermarkConnection:Disconnect()
	end
	print("[LanternUI] Menu unloaded cleanly.")
	Library.Unloaded = true
end)

-- =============================================================================
-- TAB: UI SETTINGS (ThemeManager & SaveManager Addons)
-- =============================================================================
local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu Settings")

-- Keybind Menu Visibility
MenuGroup:AddToggle("KeybindMenuOpen", {
	Text = "Open Keybind Menu",
	Default = Library.KeybindFrame.Visible,
	Callback = function(Value)
		Library.KeybindFrame.Visible = Value
	end
})

MenuGroup:AddDivider()

-- Menu Toggle Keybind
MenuGroup:AddLabel("Menu Keybind"):AddKeyPicker("MenuKeybind", {
	Default = "RightShift",
	NoUI = true,
	Text = "Menu Keybind"
})
Library.ToggleKeybind = Options.MenuKeybind

-- Unload Button
MenuGroup:AddButton("Unload Menu", function()
	Library:Unload()
end)

-- Setup Managers
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

-- Ignore theme settings in regular configs
SaveManager:IgnoreThemeSettings()

-- Exclude menu toggle key from configs
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })

-- Configure folder path for configs and themes (saves directly to workspace/LanternLib/settings)
ThemeManager:SetFolder("LanternLib")
SaveManager:SetFolder("LanternLib")

-- Build SaveManager Config Menu on the Right side of UI Settings
SaveManager:BuildConfigSection(Tabs["UI Settings"])

-- Build ThemeManager Theme Menu on the Left side of UI Settings
ThemeManager:ApplyToTab(Tabs["UI Settings"])

-- Load any configuration marked as Autoload
SaveManager:LoadAutoloadConfig()
