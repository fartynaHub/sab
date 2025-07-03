-- LocalScript (например, вставить в StarterPlayerScripts)
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")
local UIS = game:GetService("UserInputService")
local flying = false
local noclip = false
local walkspeed = 16

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local root = char:WaitForChild("HumanoidRootPart")

local flying = false
local flySpeed = 100
local velocity
local gyro

local directions = {
	F = false,
	B = false,
	L = false,
	R = false,
	U = false,
	D = false
}

-- 📌 Направление движения
local function getDirectionVector()
	local cam = workspace.CurrentCamera
	local moveDir = Vector3.zero

	if directions.F then moveDir += cam.CFrame.LookVector end
	if directions.B then moveDir -= cam.CFrame.LookVector end
	if directions.L then moveDir -= cam.CFrame.RightVector end
	if directions.R then moveDir += cam.CFrame.RightVector end
	if directions.U then moveDir += cam.CFrame.UpVector end
	if directions.D then moveDir -= cam.CFrame.UpVector end

	return moveDir.Unit
end

-- 🛫 Запуск полёта
local function startFly()
	if flying then return end
	flying = true

	velocity = Instance.new("BodyVelocity")
	velocity.Velocity = Vector3.zero
	velocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
	velocity.P = 1e4
	velocity.Parent = root

	gyro = Instance.new("BodyGyro")
	gyro.CFrame = root.CFrame
	gyro.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
	gyro.P = 1e5
	gyro.Parent = root

	RunService:BindToRenderStep("FlyMovement", Enum.RenderPriority.Input.Value, function()
		local dir = getDirectionVector()
		if dir.Magnitude > 0 then
			velocity.Velocity = dir * flySpeed
		else
			velocity.Velocity = Vector3.zero
		end
		gyro.CFrame = workspace.CurrentCamera.CFrame
	end)
end

-- 🛬 Остановка полёта
local function stopFly()
	flying = false
	RunService:UnbindFromRenderStep("FlyMovement")
	if velocity then velocity:Destroy() end
	if gyro then gyro:Destroy() end
end

-- ⌨️ Управление кнопками
UIS.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	local code = input.KeyCode

	if code == Enum.KeyCode.F then
		if flying then
			stopFly()
		else
			startFly()
		end
	elseif code == Enum.KeyCode.W then directions.F = true
	elseif code == Enum.KeyCode.S then directions.B = true
	elseif code == Enum.KeyCode.A then directions.L = true
	elseif code == Enum.KeyCode.D then directions.R = true
	elseif code == Enum.KeyCode.Space then directions.U = true
	elseif code == Enum.KeyCode.LeftControl then directions.D = true
	end
end)

UIS.InputEnded:Connect(function(input)
	local code = input.KeyCode
	if code == Enum.KeyCode.W then directions.F = false
	elseif code == Enum.KeyCode.S then directions.B = false
	elseif code == Enum.KeyCode.A then directions.L = false
	elseif code == Enum.KeyCode.D then directions.R = false
	elseif code == Enum.KeyCode.Space then directions.U = false
	elseif code == Enum.KeyCode.LeftControl then directions.D = false
	end
end)

-- 🚶‍♂️ Toggle WalkSpeed
function toggleSpeed()
	if humanoid.WalkSpeed == 16 then
		humanoid.WalkSpeed = 100 -- custom test speed
	else
		humanoid.WalkSpeed = 16
	end
end

-- 🚪 Noclip function
game:GetService("RunService").Stepped:Connect(function()
	if noclip then
		for _, part in pairs(char:GetDescendants()) do
			if part:IsA("BasePart") and part.CanCollide == true then
				part.CanCollide = false
			end
		end
	end
end)

-- ⌨️ Keybinds
UIS.InputBegan:Connect(function(key)
	if key.KeyCode == Enum.KeyCode.N then
		noclip = not noclip
	elseif key.KeyCode == Enum.KeyCode.L then
		toggleSpeed()
	elseif key.KeyCode == Enum.KeyCode.F then
		if not flying then
			fly()
		end
	end
end)
