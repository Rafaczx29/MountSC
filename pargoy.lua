--[[ 
    ================================================
    MOUNT PARGOY AUTO SUMMIT (Native Roblox UI) with Toggle - FINAL ATTEMPT
    LOGIKA: CF1 -> 1s delay -> CF2 -> ... -> CF7 (Summit) -> Reset -> Final Delay.
    ================================================
]]

local Players = game:GetService("Players")
local player = game:GetService("Players").LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

-- UBAH INI SESUAI KEINGINANMU
local Author = "PARGOY AUTO SUMMIT v2.2 (Final Toggle Fix)"

-- CFRAME WAYPOINTS UNTUK MOUNT PARGOY (7 Checkpoint)
local PARGOY_WAYPOINTS = {
    CFrame.new(-701.920471, 105.007523, -371.480377, -0.952635407, -2.52235282e-08, -0.304114699, 8.50061688e-10, 1, -8.56036451e-08, 0.304114699, -8.18075776e-08, -0.952635407), 
    CFrame.new(-636.905457, 137.007523, -108.230003, -0.996407092, 7.19039606e-10, -0.0846929029, 2.35565345e-09, 1, -1.92241636e-08, 0.0846929029, -1.93546015e-08, -0.996407092), 
    CFrame.new(-605.321472, 209.414169, 61.2097816, -0.473458797, 5.95815628e-08, 0.880815983, -4.33927916e-09, 1, -6.99760605e-08, -0.880815983, -3.6952887e-08, -0.473458797), 
    CFrame.new(-432.342682, 268.988312, 263.520233, 0.457835644, -5.16428784e-08, -0.889036834, 1.0088731e-09, 1, -5.75690215e-08, 0.889036834, 2.54602242e-08, 0.457835644), 
    CFrame.new(-39.9746628, 366.16684, 74.0292969, 0.933295727, -3.68317554e-09, -0.359108686, 4.2046075e-10, 1, -9.16369203e-09, 0.359108686, 8.4014431e-09, 0.933295727), 
    CFrame.new(104.984848, 472.990875, -177.288254, 0.257116467, 3.9098822e-08, 0.966380417, -4.26770974e-08, 1, -2.91043118e-08, -0.966380417, -3.37591146e-08, 0.257116467), 
    CFrame.new(305.696167, 588.57312, -689.283997, 0.0279630944, 3.00938616e-08, -0.999608934, 5.77285864e-09, 1, 3.02671239e-08, 0.999608934, -6.61696387e-09, 0.0279630944)
}
local CHECKPOINT_DELAY = 1 

local runningPargoy = false
local teleportsLeftPargoy = 10 
local delayTimePargoy = 2 

-- ===================================
-- LOGIKA TELEPORTASI & KONTROL
-- ===================================

local function log(message)
    print("[Pargoy Auto Summit] " .. message)
end

local function executeCheckpointCycle(waypointsTable, checkpointDelay, finalDelay, mountName)
    -- Logika inti tetap sama
    local success = pcall(function()
        local char = player.Character or player.CharacterAdded:Wait(3)
        if not char then return end 
        local root = char:WaitForChild("HumanoidRootPart", 5)
        if not root then return end
        local newCharWait = player.CharacterAdded:Once() 
        
        log("Starting " .. mountName .. " Checkpoints...")
        for i, cframe in ipairs(waypointsTable) do
            if not runningPargoy then return end 
            root.CFrame = cframe
            task.wait(checkpointDelay) 
        end
        
        task.wait(2) 
        
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.Health > 0 then humanoid.Health = 0 end
        
        newCharWait:Wait() 
        
        if finalDelay > 0 then task.wait(finalDelay) end
    end)
    
    if not success then
        log("Error selama siklus " .. mountName .. "! Stopping loop.")
        task.wait(2)
        runningPargoy = false
    end
    return success
end

local function startPargoyLoop()
    local count = teleportsLeftPargoy
    local finalDelay = delayTimePargoy
    local cpDelay = CHECKPOINT_DELAY

    if runningPargoy then 
        runningPargoy = false; 
        task.wait(finalDelay * 0.5) 
    end

    runningPargoy = true
    
    log("Auto Summit Pargoy Dimulai! Count: " .. (count == -1 and "Infinite" or count));
    
    task.spawn(function()
        while runningPargoy and (count > 0 or count == -1) do
            
            executeCheckpointCycle(PARGOY_WAYPOINTS, cpDelay, finalDelay, "Pargoy")
            
            if count > 0 then
                count -= 1
                teleportsLeftPargoy = count 
                if UI and UI.StatusLabel then
                    UI.StatusLabel.Text = "Running... Left: " .. (count == -1 and "Infinite" or count)
                end
            end
        end
        runningPargoy = false
        if UI and UI.StatusLabel then
            UI.StatusLabel.Text = "Stopped. Last count: " .. (count == -1 and "Infinite" or count)
        end
        log("Auto Summit Pargoy Selesai.")
    end)
end

local function stopPargoyLoop()
    runningPargoy = false
    if UI and UI.StatusLabel then
        UI.StatusLabel.Text = "Stopped Manually."
    end
    log("Auto Summit Pargoy Dihentikan Manual.")
end


-- ===================================
-- 3. PEMBUATAN NATIVE ROBLOX UI
-- ===================================

local UI = {}

-- Main ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PargoyAutoSummitUI"
ScreenGui.Parent = player:WaitForChild("PlayerGui")

-- FUNGSI TOGGLE UNTUK MENGURUS TOMBOL DAN MENU UTAMA
local function toggleMenu()
    if UI.MainFrame.Visible then
        UI.MainFrame.Visible = false
        UI.ToggleButton.Text = "[OPEN]" 
        log("Menu ditutup.")
    else
        UI.MainFrame.Visible = true
        UI.ToggleButton.Text = "[CLOSE]" 
        log("Menu dibuka.")
    end
end

-- 0. TOMBOL TOGGLE (IKON OPEN/CLOSE)
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Size = UDim2.new(0, 70, 0, 30)
ToggleButton.Position = UDim2.new(1, -75, 0.3, 0) -- Kanan Tengah, agar tidak bentrok dengan UI atas
ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 14
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.Text = "[OPEN]" 
ToggleButton.Parent = ScreenGui
UI.ToggleButton = ToggleButton

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim2.new(0, 4)
ToggleCorner.Parent = ToggleButton

ToggleButton.MouseButton1Click:Connect(toggleMenu)


-- 1. MAIN FRAME (Menu Utama)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 240)
-- Posisikan di dekat tombol toggle (Kanan Tengah)
MainFrame.Position = UDim2.new(1, -260, 0.3, 40) 
MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MainFrame.BorderSizePixel = 0
MainFrame.Draggable = true
MainFrame.Visible = false -- DEFAULT: TERSEMBUNYI
MainFrame.Parent = ScreenGui
UI.MainFrame = MainFrame

-- Frame Corner
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim2.new(0, 8)
UICorner.Parent = MainFrame

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.Font = Enum.Font.SourceSansBold
Title.Text = "Mount Pargoy AUTO SUMMIT"
Title.Parent = MainFrame

-- UI LIST LAYOUT untuk menata elemen
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -20, 1, -Title.Size.Y.Offset - 5)
ContentFrame.Position = UDim2.new(0, 10, 0, Title.Size.Y.Offset + 5)
ContentFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ContentFrame.BorderSizePixel = 0
ContentFrame.Parent = MainFrame

local ContentListLayout = Instance.new("UIListLayout")
ContentListLayout.Padding = UDim.new(0, 8)
ContentListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
ContentListLayout.Parent = ContentFrame
ContentListLayout.SortOrder = Enum.SortOrder.LayoutOrder


-- INPUT JUMLAH SUMMIT
local CountInput = Instance.new("TextBox")
-- (Kode input lainnya tetap sama...)
CountInput.Name = "CountInput"
CountInput.Size = UDim2.new(1, 0, 0, 30)
CountInput.PlaceholderText = "Jumlah Summit (e.g., 10 atau 0 untuk Infinite)"
CountInput.Text = tostring(teleportsLeftPargoy)
CountInput.TextColor3 = Color3.fromRGB(255, 255, 255)
CountInput.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
CountInput.TextSize = 14
CountInput.Font = Enum.Font.SourceSans
CountInput.Parent = ContentFrame

CountInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local count = tonumber(CountInput.Text)
        if count and count >= 0 then
            teleportsLeftPargoy = (count == 0) and -1 or math.floor(count)
        else
            CountInput.Text = tostring(teleportsLeftPargoy)
        end
    end
end)

-- INPUT DELAY FINAL
local DelayInput = Instance.new("TextBox")
-- (Kode input lainnya tetap sama...)
DelayInput.Name = "DelayInput"
DelayInput.Size = UDim2.new(1, 0, 0, 30)
DelayInput.PlaceholderText = "Delay Final (detik) - Setelah Respawn"
DelayInput.Text = tostring(delayTimePargoy)
DelayInput.TextColor3 = Color3.fromRGB(255, 255, 255)
DelayInput.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
DelayInput.TextSize = 14
DelayInput.Font = Enum.Font.SourceSans
DelayInput.Parent = ContentFrame

DelayInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local delay = tonumber(DelayInput.Text)
        if delay and delay >= 0.1 then
            delayTimePargoy = delay
        else
            DelayInput.Text = tostring(delayTimePargoy)
        end
    end
end)

-- Separator
local Separator = Instance.new("TextLabel")
Separator.Size = UDim2.new(1, 0, 0, 5)
Separator.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Separator.Text = ""
Separator.Parent = ContentFrame


-- TOMBOL START
local StartButton = Instance.new("TextButton")
StartButton.Size = UDim2.new(1, 0, 0, 30)
StartButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50) 
StartButton.TextColor3 = Color3.fromRGB(255, 255, 255)
StartButton.TextSize = 16
StartButton.Font = Enum.Font.SourceSansBold
StartButton.Text = "START AUTO SUMMIT PARGOY"
StartButton.Parent = ContentFrame
StartButton.MouseButton1Click:Connect(startPargoyLoop)

-- TOMBOL STOP
local StopButton = Instance.new("TextButton")
StopButton.Size = UDim2.new(1, 0, 0, 30)
StopButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50) 
StopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
StopButton.TextSize = 16
StopButton.Font = Enum.Font.SourceSansBold
StopButton.Text = "STOP AUTO LOOP"
StopButton.Parent = ContentFrame
StopButton.MouseButton1Click:Connect(stopPargoyLoop)

-- Status Label
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 15)
StatusLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
StatusLabel.TextSize = 12
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.Text = "Ready. Checkpoint Delay: " .. CHECKPOINT_DELAY .. "s"
StatusLabel.Parent = ContentFrame
UI.StatusLabel = StatusLabel 

log("Native Roblox UI Loaded. Tombol [OPEN] siap di pojok kanan tengah. Klik untuk membuka menu!")
