-- [Auto XP Stable Mode] - tanpa UI
-- Buat kamu yang mau AFK farming XP dengan gerakan kecil dan stabil.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- ===== PARAMETER GERAK =====
local MOVE_RADIUS = 6        -- jarak gerak kecil
local STEP_COUNT = 6         -- banyak langkah per siklus
local MOVE_WAIT_MIN = 1.0
local MOVE_WAIT_MAX = 2.2
local JUMP_CHANCE = 0.25
local LOOP_WAIT = 1.0
local SAFE_GROUND_CHECK = true

-- ===== UTILITAS =====
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
	local startTick = tick()

	humanoid:MoveTo(targetPos)
	while (tick() - startTick) < timeout do
		if (hrp.Position - targetPos).Magnitude < 2.2 then
			reached = true
			break
		end
		task.wait(0.1)
	end
	return reached
end

-- ===== LOOP AUTO XP =====
task.wait(2)
print("[AutoXP] Starting loop...")

while task.wait(1) do
	local char, hrp, humanoid = getCharacterParts()
	if not (char and hrp and humanoid) then
		print("[AutoXP] Waiting for character...")
		player.CharacterAdded:Wait()
		task.wait(1)
	else
		local base = hrp.CFrame
		local points = buildPoints(base, STEP_COUNT, MOVE_RADIUS)

		for _, pos in ipairs(points) do
			local ok, err = pcall(function()
				if SAFE_GROUND_CHECK then
					local rayOrigin = Vector3.new(pos.X, pos.Y + 2.5, pos.Z)
					local rayDir = Vector3.new(0, -8, 0)
					local hit = workspace:FindPartOnRayWithIgnoreList(Ray.new(rayOrigin, rayDir), {char})
					if not hit then
						pos = Vector3.new(pos.X, base.Position.Y, pos.Z)
					end
				end
				safeMoveTo(hrp, humanoid, pos, 4)
				if math.random() < JUMP_CHANCE then
					humanoid.Jump = true
				end
			end)
			if not ok then
				warn("[AutoXP] Error:", err)
			end
			task.wait(rnd(MOVE_WAIT_MIN, MOVE_WAIT_MAX))
		end
		print("[AutoXP] Cycle complete. Waiting before next...")
		task.wait(LOOP_WAIT + math.random()*1.5)
	end
end
