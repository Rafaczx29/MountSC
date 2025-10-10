-- Auto XP (pelan & stabil) — FIX GUI Parent
-- Pastikan jalankan setelah player sudah masuk game.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- ---------- SAFE GUI PARENT ----------
local function getSafeGuiParent()
    -- prefer gethui() for many executors
    if gethui then
        local ok, parent = pcall(gethui)
        if ok and parent then return parent end
    end

    -- syn executor protection
    if syn and syn.protect_gui then
        local s = Instance.new("ScreenGui")
        syn.protect_gui(s)
        -- parent to CoreGui (protected) or PlayerGui fallback
        if game:FindFirstChildOfClass("CoreGui") then
            s.Parent = game:GetService("CoreGui")
        elseif player:FindFirstChildOfClass("PlayerGui") then
            s.Parent = player:FindFirstChildOfClass("PlayerGui")
        else
            s.Parent = game:GetService("StarterGui")
        end
        return s.Parent
    end

    -- if PlayerGui ready, use it
    if player and player:FindFirstChildOfClass("PlayerGui") then
        return player:FindFirstChildOfClass("PlayerGui")
    end

    -- fallback to CoreGui if available
    if game:FindFirstChildOfClass("CoreGui") then
        return game:GetService("CoreGui")
    end

    -- ultimate fallback
    return game:GetService("StarterGui")
end

-- ---------- CLEAN EXISTING UI ----------
local function cleanup(name)
    local parentCandidates = {
        getSafeGuiParent(),
        game:GetService("CoreGui"),
        player:FindFirstChildOfClass("PlayerGui"),
        game:GetService("StarterGui")
    }
    for _, parent in ipairs(parentCandidates) do
        if parent and parent:FindFirstChild(name) then
            pcall(function() parent[name]:Destroy() end)
        end
    end
end

-- ---------- BUILD UI ----------
local GUI_NAME = "AutoXP_UI_Fixed_v2"
cleanup(GUI_NAME)

-- create screen gui (but don't parent yet)
local screen = Instance.new("ScreenGui")
screen.Name = GUI_NAME
screen.ResetOnSpawn = false
screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 340, 0, 160)
frame.Position = UDim2.new(0.5, -170, 0.12, 0)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screen
local corner = Instance.new("UICorner", frame)
corner.CornerRadius = UDim.new(0,10)

-- title
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, -16, 0, 34)
title.Position = UDim2.new(0,8,0,6)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.Text = "Auto XP — Pelan & Stabil (Fixed UI)"
title.TextColor3 = Color3.fromRGB(245,245,245)
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left

-- info
local info = Instance.new("TextLabel", frame)
info.Size = UDim2.new(1, -16, 0, 48)
info.Position = UDim2.new(0,8,0,40)
info.BackgroundTransparency = 1
info.Font = Enum.Font.Gotham
info.TextSize = 12
info.TextColor3 = Color3.fromRGB(200,200,200)
info.TextWrapped = true
info.Text = "Mode: move-to kecil + jump occasional. Gunakan private server. Atur parameter di script jika perlu."

-- status
local statusLabel = Instance.new("TextLabel", frame)
statusLabel.Size = UDim2.new(1, -16, 0, 18)
statusLabel.Position = UDim2.new(0,8,0,92)
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 12
statusLabel.TextColor3 = Color3.fromRGB(200,200,200)
statusLabel.Text = "Status: Idle"

-- start/stop buttons
local startBtn = Instance.new("TextButton", frame)
startBtn.Size = UDim2.new(0.46, -6, 0, 32)
startBtn.Position = UDim2.new(0,8,0,112)
startBtn.Text = "▶ Start"
startBtn.Font = Enum.Font.GothamBold
startBtn.TextSize = 14
startBtn.BackgroundColor3 = Color3.fromRGB(50,160,70)
local sCorner = Instance.new("UICorner", startBtn)
sCorner.CornerRadius = UDim.new(0,8)

local stopBtn = Instance.new("TextButton", frame)
stopBtn.Size = UDim2.new(0.46, -6, 0, 32)
stopBtn.Position = UDim2.new(0.54, 0, 0, 112)
stopBtn.Text = "⏹ Stop"
stopBtn.Font = Enum.Font.GothamBold
stopBtn.TextSize = 14
stopBtn.BackgroundColor3 = Color3.fromRGB(160,50,50)
local tCorner = Instance.new("UICorner", stopBtn)
tCorner.CornerRadius = UDim.new(0,8)

-- ready to parent: try several parents until one works
local parentsToTry = {
    getSafeGuiParent(),
    player:FindFirstChildOfClass("PlayerGui"),
    game:GetService("CoreGui"),
    game:GetService("StarterGui")
}

local parentSet = false
for _, p in ipairs(parentsToTry) do
    if p then
        local ok, err = pcall(function() screen.Parent = p end)
        if ok then
            parentSet = true
            break
        end
    end
end

-- If still not parented, try delayed parent to PlayerGui
if not parentSet then
    spawn(function()
        for i = 1, 10 do
            task.wait(0.2)
            if player:FindFirstChildOfClass("PlayerGui") then
                pcall(function() screen.Parent = player:FindFirstChildOfClass("PlayerGui") end)
                parentSet = true
                break
            end
        end
        if not parentSet then
            screen.Parent = game:GetService("StarterGui")
        end
    end)
end

-- ---------- AUTO XP LOGIC (pelan & stabil) ----------
local MOVE_RADIUS = 6
local STEP_COUNT = 6
local MOVE_WAIT_MIN = 1.0
local MOVE_WAIT_MAX = 2.2
local JUMP_CHANCE = 0.25
local LOOP_WAIT = 1.0
local SAFE_GROUND_CHECK = true

local running = false

local function rnd(a,b) return a + math.random()*(b-a) end

local function getCharacterParts()
    local char = player.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    return char, hrp, humanoid
end

local function buildPoints(baseCFrame, count, radius)
    local pts = {}
    local bx, by, bz = baseCFrame.Position.X, baseCFrame.Position.Y, baseCFrame.Position.Z
    for i = 1, count do
        local ang = (i-1) * (2*math.pi / count) + rnd(-0.3,0.3)
        local r = radius * (0.6 + math.random()*0.8)
        local x = bx + math.cos(ang)*r
        local z = bz + math.sin(ang)*r
        local y = by + rnd(-0.3, 0.8)
        table.insert(pts, Vector3.new(x,y,z))
    end
    return pts
end

local function safeMoveTo(hrp, humanoid, targetPos, timeout)
    timeout = timeout or 4
    if not hrp or not humanoid then return false end
    local reached = false
    local reachedConn
    local moved = Instance.new("BindableEvent")
    local startTick = tick()

    reachedConn = RunService.Heartbeat:Connect(function()
        if (hrp.Position - targetPos).Magnitude < 2.2 then
            reached = true
            moved:Fire()
        end
    end)

    pcall(function() humanoid:MoveTo(targetPos) end)

    local done = false
    local conn = moved.Event:Connect(function() done = true end)
    while not done and tick() - startTick < timeout do
        task.wait(0.12)
    end
    conn:Disconnect()
    reachedConn:Disconnect()

    if not done then
        local current = hrp.CFrame
        local half = current:Lerp(CFrame.new(targetPos), 0.5)
        hrp.CFrame = half
        task.wait(0.12)
        pcall(function() humanoid:MoveTo(targetPos) end)
        task.wait(0.4)
    end

    return true
end

local function runAutoXP()
    running = true
    statusLabel.Text = "Status: Running"
    while running do
        local char, hrp, humanoid = getCharacterParts()
        if not (char and hrp and humanoid) then
            statusLabel.Text = "Status: Waiting for character..."
            player.CharacterAdded:Wait()
            task.wait(0.5)
            goto continue_loop
        end

        local base = hrp.CFrame
        local points = buildPoints(base, STEP_COUNT, MOVE_RADIUS)

        for idx, pos in ipairs(points) do
            if not running then break end
            if SAFE_GROUND_CHECK then
                local rayOrigin = Vector3.new(pos.X, pos.Y + 2.5, pos.Z)
                local rayDir = Vector3.new(0, -8, 0)
                local okHit = workspace:FindPartOnRayWithIgnoreList(Ray.new(rayOrigin, rayDir), {char})
                if not okHit then
                    pos = Vector3.new(pos.X, base.Position.Y, pos.Z)
                end
            end

            pcall(function()
                safeMoveTo(hrp, humanoid, pos, 4)
            end)

            if math.random() < JUMP_CHANCE then
                pcall(function() humanoid.Jump = true end)
            end

            local waitTime = rnd(MOVE_WAIT_MIN, MOVE_WAIT_MAX)
            waitTime = waitTime + (math.random() - 0.5) * 0.3
            local t = 0
            while t < waitTime and running do
                task.wait(0.25)
                t = t + 0.25
            end
        end

        ::continue_loop::
        if not running then break end
        statusLabel.Text = "Status: Cycle complete. Waiting..."
        local lw = LOOP_WAIT + (math.random()*1.5)
        local tt = 0
        while tt < lw and running do
            task.wait(0.25); tt = tt + 0.25
        end
    end
    statusLabel.Text = "Status: Stopped"
end

-- UI handlers
startBtn.MouseButton1Click:Connect(function()
    if running then return end
    task.spawn(runAutoXP)
end)

stopBtn.MouseButton1Click:Connect(function()
    running = false
end)

-- ensure screen parent final (in case previous set failed)
if not screen.Parent then
    screen.Parent = getSafeGuiParent() or player:WaitForChild("PlayerGui")
end

-- final visible ready state
statusLabel.Text = "Status: Idle"
