local tool = script.Parent
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local userInputService = game:GetService("UserInputService")
local camera = workspace.CurrentCamera

-- Check if PlayerGui exists
if not player.PlayerGui then
	return
end

-- Wait for and check if the DirectionalWeapon GUI exists
local gui = player.PlayerGui:WaitForChild("DirectionalWeapon")
if not gui then
	return
else
	gui.Enabled = false
end

-- Check if the Frame and TextLabel exist
local frame = gui.Frame
if not frame then
	return
end

local textLabel = frame.TextLabel
if not textLabel then
	return
end

local defaultTextLabelPosition = textLabel.Position

-- Initialize variables
local lastMousePosition = userInputService:GetMouseLocation()
local lastCameraCFrame = camera.CFrame
local lastDirection = "Left"
local hitable = false
local shiftLockThreshold = 0.05

-- Function to update the direction based on mouse or camera movement
local function updateDirection()
	if userInputService.MouseBehavior == Enum.MouseBehavior.LockCenter then
		textLabel.Position = defaultTextLabelPosition
		
		local character = tool.Parent
		local rootPart = character and character.HumanoidRootPart
		if not rootPart then return end

		local relativeDirection = rootPart.CFrame:ToObjectSpace(camera.CFrame).LookVector
		local delta = camera.CFrame.LookVector - lastCameraCFrame.LookVector

		if math.abs(delta.X) > shiftLockThreshold then
			if relativeDirection.X > 0 then
				textLabel.Text = "→"
				lastDirection = "Right"
			else
				textLabel.Text = "←"
				lastDirection = "Left"
			end
		end

		if math.abs(delta.Y) > shiftLockThreshold then
			if relativeDirection.Y > 0 then
				textLabel.Text = "↑"
				lastDirection = "Up"
			else
				textLabel.Text = "↓"
				lastDirection = "Down"
			end
		end
		lastCameraCFrame = camera.CFrame
	else
		
		local currentMousePosition = userInputService:GetMouseLocation()
		local offset = Vector2.new(0, -100)
		local newPosition = currentMousePosition + offset

		textLabel.Position = UDim2.new(0, newPosition.X, 0, newPosition.Y)
		local delta = currentMousePosition - lastMousePosition

		textLabel.Position = UDim2.new(0, currentMousePosition.X, 0, currentMousePosition.Y)

		-- Direction logic
		if math.abs(delta.X) > math.abs(delta.Y) then
			if delta.X > 0 then
				textLabel.Text = "→"
				lastDirection = "Right"
			elseif delta.X < 0 then
				textLabel.Text = "←"
				lastDirection = "Left"
			end
		else
			if delta.Y > 0 then
				textLabel.Text = "↓"
				lastDirection = "Down"
			elseif delta.Y < 0 then
				textLabel.Text = "↑"
				lastDirection = "Up"
			end
		end
		lastMousePosition = currentMousePosition
	end
end

-- Connect the updateDirection function to RenderStepped
game:GetService("RunService").RenderStepped:Connect(updateDirection)

-- Handle tool equipped
tool.Equipped:Connect(function()
	gui.Enabled = true
	local character = tool.Parent
	local humanoid = character.Humanoid

	-- Ensure the humanoid has an Animator
	if humanoid and not humanoid.Animator then
		Instance.new("Animator", humanoid)
	end

	local animator = humanoid and humanoid.Animator
	if not animator then return end

	-- Load animations
	local animations = {
		Left = animator:LoadAnimation(tool.Left),
		Right = animator:LoadAnimation(tool.Right),
		Up = animator:LoadAnimation(tool.Up),
		Down = animator:LoadAnimation(tool.Down)
	}

	-- Set animation priorities
	for _, anim in pairs(animations) do
		if anim then
			anim.Priority = Enum.AnimationPriority.Action4
		end
	end

	-- Handle tool activation
	tool.Activated:Connect(function()
		hitable = true
		local animation = animations[lastDirection]
		if animation then
			animation:Play(0.1)
		end
		wait(3)
		hitable = false
	end)
end)

-- Handle tool unequipped
tool.Unequipped:Connect(function()
	gui.Enabled = false
end)

-- Handle tool touching another part
tool.Handle.Touched:Connect(function(opart)
	local otherHumanoid = opart.Parent.Humanoid

	if otherHumanoid and opart.Parent ~= tool.Parent then
		if hitable then
			hitable = false
			otherHumanoid.Health = otherHumanoid.Health - 35
		end
	end
end)