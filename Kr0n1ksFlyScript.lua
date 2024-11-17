local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Use pcall for safer execution and everything
local function safeExecute()
    local player = Players.LocalPlayer
    local camera = workspace.CurrentCamera

    local flyMode = false
    local speedLevels = {
        {speed = 25, name = "Slow"},
        {speed = 50, name = "Normal"},
        {speed = 100, name = "Fast"},
        {speed = 250, name = "Turbo"}
    }
    local currentSpeedLevel = 2 -- Default to normal
    local flySpeed = speedLevels[currentSpeedLevel].speed

    -- Fly Mode Indicator at the bottom of the screen
    local function createFlyModeIndicator()
        local screenGui = Instance.new("ScreenGui")
        screenGui.Parent = player.PlayerGui
        
        local indicator = Instance.new("TextLabel")
        indicator.Size = UDim2.new(0, 200, 0, 50)
        indicator.Position = UDim2.new(0.5, -100, 0.9, 0)
        indicator.BackgroundTransparency = 0.5
        indicator.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        indicator.TextColor3 = Color3.fromRGB(255, 255, 255)
        indicator.Font = Enum.Font.GothamBold
        indicator.TextScaled = true
        indicator.Parent = screenGui
        
        return indicator
    end

    local flyIndicator = createFlyModeIndicator()
    local canDash = true
    local dashCooldown = 0.5
    local dashSpeed = 200

    local flyModeSettings = {
        smoothing = 0.1,
        trailEffects = true,
        soundEffects = true
    }

    local function createFlyTrail()
        if not flyModeSettings.trailEffects then return end
        
        local character = player.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end
        
        local trail = Instance.new("Trail")
        trail.Lifetime = 0.5
        trail.WidthScale = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.5),
            NumberSequenceKeypoint.new(1, 0)
        })
        trail.Color = ColorSequence.new(Color3.fromRGB(0, 255, 255))
        trail.Parent = rootPart
    end

    local function performDash()
        if not canDash or not flyMode then return end
        
        local character = player.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end
        
        local dashDirection = camera.CFrame.LookVector
        rootPart.CFrame = rootPart.CFrame + dashDirection * dashSpeed
        
        canDash = false
        task.delay(dashCooldown, function()
            canDash = true
        end)
    end

    local function startFlying()
        flyMode = true
        local character = player.Character
        if not character then return end
        
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        
        if humanoid and rootPart then
            humanoid:ChangeState(Enum.HumanoidStateType.Physics)
            rootPart.Anchored = true
            
            -- Update indicator :>
            flyIndicator.Text = "Fly Mode: ON\nSpeed: " .. speedLevels[currentSpeedLevel].name
            flyIndicator.TextColor3 = Color3.fromRGB(0, 255, 0)
            
            -- Create trail effect (It doesn't work It's sh**)
            createFlyTrail()
        end
    end

    local function stopFlying()
        flyMode = false
        local character = player.Character
        if not character then return end
        
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        
        if humanoid and rootPart then
            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
            rootPart.Anchored = false
            
            -- Update indicator :>
            flyIndicator.Text = "Fly Mode: OFF"
            flyIndicator.TextColor3 = Color3.fromRGB(255, 0, 0)
            
            -- Remove trail (basically doesn't work, whoever can update this script be my guest)
            local trail = rootPart:FindFirstChildOfClass("Trail")
            if trail then trail:Destroy() end
        end
    end

    local function updateFlyMovement(dt)
        if not flyMode then return end
        
        local character = player.Character
        if not character then return end
        
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end
        
        local moveDirection = Vector3.new(0, 0, 0)
        local camCFrame = camera.CFrame
        
        local currentSpeed = flySpeed
        
        -- Movement directions
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDirection = moveDirection + camCFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDirection = moveDirection - camCFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDirection = moveDirection - camCFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDirection = moveDirection + camCFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.E) then
            moveDirection = moveDirection + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Q) then
            moveDirection = moveDirection - Vector3.new(0, 1, 0)
        end
        
        if moveDirection.Magnitude > 0 then
            local newPosition = rootPart.Position + moveDirection.Unit * currentSpeed * dt
            rootPart.CFrame = CFrame.new(newPosition, newPosition + camCFrame.LookVector)
        end
    end

    -- Toggle flying
    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.F then
            if flyMode then
                stopFlying()
            else
                startFlying()
            end
        end
        
        -- Speed level cycling
        if input.KeyCode == Enum.KeyCode.X then
            currentSpeedLevel = (currentSpeedLevel % #speedLevels) + 1
            flySpeed = speedLevels[currentSpeedLevel].speed
            
            if flyMode then
                flyIndicator.Text = "Fly Mode: ON\nSpeed: " .. speedLevels[currentSpeedLevel].name
            end
        end
        
        -- Dash ability
        if input.KeyCode == Enum.KeyCode.V then
            performDash()
        end
    end)

    -- Continuous movement update
    RunService.Heartbeat:Connect(updateFlyMovement)
end

-- Executor-safe execution
local success, err = pcall(safeExecute)
if not success then
    warn("Fly script failed to execute: " .. tostring(err))
end

-- Credits go to Kr0n1k It's sh** I know, but I'm lazy to fix this shit.