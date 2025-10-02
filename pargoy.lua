--// UI Toggle + Frame
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local TextBox = Instance.new("TextBox")
local StartButton = Instance.new("TextButton")
local StopButton = Instance.new("TextButton")
local ToggleButton = Instance.new("TextButton")

ScreenGui.Parent = game.CoreGui

-- Frame utama
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MainFrame.Size = UDim2.new(0, 220, 0, 160)
MainFrame.Position = UDim2.new(0.35, 0, 0.35, 0)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = true

-- TextBox input loop
TextBox.Parent = MainFrame
TextBox.Size = UDim2.new(0, 200, 0, 40)
TextBox.Position = UDim2.new(0, 10, 0, 10)
TextBox.PlaceholderText = "Input jumlah summit (loop)"
TextBox.Text = ""
TextBox.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
TextBox.TextColor3 = Color3.fromRGB(255,255,255)

-- Start Button
StartButton.Parent = MainFrame
StartButton.Size = UDim2.new(0, 200, 0, 40)
StartButton.Position = UDim2.new(0, 10, 0, 60)
StartButton.Text = "▶ Start Mount Pargoy"
StartButton.BackgroundColor3 = Color3.fromRGB(0, 170, 80)
StartButton.TextColor3 = Color3.fromRGB(255,255,255)

-- Stop Button
StopButton.Parent = MainFrame
StopButton.Size = UDim2.new(0, 200, 0, 40)
StopButton.Position = UDim2.new(0, 10, 0, 110)
StopButton.Text = "⏹ Stop"
StopButton.BackgroundColor3 = Color3.fromRGB(200, 0, 50)
StopButton.TextColor3 = Color3.fromRGB(255,255,255)

-- Toggle Button (pojok)
ToggleButton.Parent = ScreenGui
ToggleButton.Size = UDim2.new(0, 40, 0, 40)
ToggleButton.Position = UDim2.new(0, 10, 0, 200)
ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
ToggleButton.Text = "☰"
ToggleButton.TextScaled = true
ToggleButton.TextColor3 = Color3.fromRGB(255,255,255)

--// Checkpoint CF
local checkpoints = {
    CFrame.new(-701.920471, 105.007523, -371.480377, -0.952635407, -2.52235282e-08, -0.304114699, 8.50061688e-10, 1, -8.56036451e-08, 0.304114699, -8.18075776e-08, -0.952635407),
    CFrame.new(-636.905457, 137.007523, -108.230003, -0.996407092, 7.19039606e-10, -0.0846929029, 2.35565345e-09, 1, -1.92241636e-08, 0.0846929029, -1.93546015e-08, -0.996407092),
    CFrame.new(-605.321472, 209.414169, 61.2097816, -0.473458797, 5.95815628e-08, 0.880815983, -4.33927916e-09, 1, -6.99760605e-08, -0.880815983, -3.6952887e-08, -0.473458797),
    CFrame.new(-432.342682, 268.988312, 263.520233, 0.457835644, -5.16428784e-08, -0.889036834, 1.0088731e-09, 1, -5.75690215e-08, 0.889036834, 2.54602242e-08, 0.457835644),
    CFrame.new(-39.9746628, 366.16684, 74.0292969, 0.933295727, -3.68317554e-09, -0.359108686, 4.2046075e-10, 1, -9.16369203e-09, 0.359108686, 8.4014431e-09, 0.933295727),
    CFrame.new(104.984848, 472.990875, -177.288254, 0.257116467, 3.9098822e-08, 0.966380417, -4.26770974e-08, 1, -2.91043118e-08, -0.966380417, -3.37591146e-08, 0.257116467),
    CFrame.new(305.696167, 588.57312, -689.283997, 0.0279630944, 3.00938616e-08, -0.999608934, 5.77285864e-09, 1, 3.02671239e-08, 0.999608934, -6.61696387e-09, 0.0279630944)
}

--// Variabel kontrol loop
local running = false

-- Fungsi Summit Loop
local function doSummit(loopCount)
    local plr = game.Players.LocalPlayer
    local char = plr.Character or plr.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")

    running = true
    for i = 1, loopCount do
        if not running then break end
        for _, cf in ipairs(checkpoints) do
            if not running then break end
            hrp.CFrame = cf
            task.wait(1)
        end
    end
end

-- Start Button
StartButton.MouseButton1Click:Connect(function()
    local loops = tonumber(TextBox.Text)
    if loops and loops > 0 then
        if running then
            warn("Script masih jalan, stop dulu kalau mau restart.")
        else
            doSummit(loops)
        end
    else
        warn("Masukkan angka valid untuk jumlah loop summit!")
    end
end)

-- Stop Button
StopButton.MouseButton1Click:Connect(function()
    running = false
    warn("Summit loop dihentikan.")
end)

-- Toggle UI Button
ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)
