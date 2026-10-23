-- ==============================================================================
-- LANTERNLIB - OFFICIAL LOADER EXAMPLE
-- Demonstrates Key Authentication, Auto-Save System, and Payload Launch
-- Design Language: Modern Minimal Dark Cyan (Matching Loaderdesign.svg 1:1)
-- ==============================================================================

local repo = "https://raw.githubusercontent.com/LanternSupport/LanternLib/main/"

-- [1] Load LoaderLib Module
local LoaderLib = nil
do
    -- Local executor test check (if developing locally)
    if readfile and isfile and isfile("loader/LoaderLib.lua") then
        LoaderLib = loadstring(readfile("loader/LoaderLib.lua"))()
    elseif readfile and isfile and isfile("LanternLib/loader/LoaderLib.lua") then
        LoaderLib = loadstring(readfile("LanternLib/loader/LoaderLib.lua"))()
    else
        -- GitHub Raw
        LoaderLib = loadstring(game:HttpGet(repo .. "loader/LoaderLib.lua"))()
    end
end

-- [2] Constants & Key File Paths
local HWID = LoaderLib:GetHWID()
local GET_KEY_URL = "https://www.lanternsupport.xyz/"
local KEY_FILE = "LanternLib/Key.txt"

-- [3] Auto-Save Key Management System
local function saveKey(key)
    pcall(function()
        if makefolder and not isfolder("LanternLib") then
            makefolder("LanternLib")
        end
        if writefile then
            writefile(KEY_FILE, key)
        end
    end)
end

local function loadSavedKey()
    local savedKey = nil
    pcall(function()
        if isfile and isfile(KEY_FILE) and readfile then
            savedKey = readfile(KEY_FILE)
        end
    end)
    if savedKey then
        savedKey = string.gsub(savedKey, "%s+", "")
        if #savedKey > 0 then
            return savedKey
        end
    end
    return nil
end

local function deleteSavedKey()
    pcall(function()
        if isfile and isfile(KEY_FILE) and delfile then
            delfile(KEY_FILE)
        end
    end)
end

-- [4] Verification & Script Payload Execution Logic
local function verifyAndExecute(key, controller, doneCallback, isAutoAuth)
    controller:SetVerifying(true, isAutoAuth and "Auto Login..." or "Checking...")

    task.spawn(function()
        -- Simulate key verification delay (or insert your own API HTTP request here)
        task.wait(1.0)

        -- Example Key Check logic (replace with your custom API verification if needed)
        local isValid = (#key >= 5)

        if not isValid then
            deleteSavedKey()
            controller:SetVerifying(false)
            controller:SetStatus("Invalid or expired key. Please get a new key.", Color3.fromRGB(244, 63, 94))
            if doneCallback then doneCallback() end
            return
        end

        -- Key is valid! Save it to disk
        saveKey(key)

        controller:SetSuccess("Verified!")
        controller:SetStatus("Key verified! Launching LanternLib...", Color3.fromRGB(52, 211, 153))

        -- Smoothly fade out and close loader window
        task.wait(0.6)
        controller:Close(0.5)

        -- Execute the main library payload
        task.delay(0.55, function()
            local mainPayloadSuccess, mainPayloadErr = pcall(function()
                loadstring(game:HttpGet(repo .. "Example.lua"))()
            end)

            if not mainPayloadSuccess then
                warn("[LanternLib] Error launching payload: " .. tostring(mainPayloadErr))
            end
        end)

        if doneCallback then doneCallback() end
    end)
end

-- [5] Create Loader Window via LoaderLib
local window = LoaderLib:CreateWindow({
    Title = "Example Loader - by Butidontknow",
    Subtitle = "Roblox Key Verification.",
    HWID = HWID,
    GetKeyURL = GET_KEY_URL,
    PlaceholderText = "Enter Key here (e.g. LX-XXXX-XXXX-XXXX) . . . .",
    OnSubmit = function(submittedKey, controller, doneCallback)
        if not submittedKey or #submittedKey < 5 then
            controller:SetStatus("Please enter a valid key format.", Color3.fromRGB(244, 63, 94))
            doneCallback()
            return
        end
        verifyAndExecute(submittedKey, controller, doneCallback, false)
    end
})

-- [6] Auto-Save Key Detection on Startup
local savedKey = loadSavedKey()
if savedKey and #savedKey >= 5 then
    window:SetKeyText(savedKey)
    window:SetStatus("Saved key detected. Auto-authenticating...", Color3.fromRGB(56, 189, 248))
    task.delay(0.5, function()
        verifyAndExecute(savedKey, window, nil, true)
    end)
end
