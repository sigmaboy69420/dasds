local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/sigmaboy69420/just-remaking-GameSneeze/refs/heads/main/suigma.lua"))()

local Window = Library:New({Name = "NvrLose.Paste", Style = 1, PageAmmount = 7, Size = Vector2.new(554, 629)})

local AimpPage = Window:Page({Name = "Aimbot"})
local EspPage = Window:Page({Name = "Esp"})
local ExploitPage = Window:Page({Name = "Exploit"})
local PlrList = Window:Page({Name = "Player List"})

local AimSec = AimpPage:Section({Name = "Aimbot", Fill = false, Side = "Left"})
local EspSec = EspPage:Section({Name = "Esp", Fill = false, Side = "Left"})
local ExpSec = ExploitPage:Section({Name = "Exploit", Fill = false, Side = "Left"})
local Label = AimSec:Label({Name = "Main Section", Center = true, Flag = "Section_Label"})

-- Aimbot Toggle
local AimbotEnabled = false
local Toggle = AimSec:Toggle({Name = "Aimbot Enabled", Default = false, Callback = function(State) 
    AimbotEnabled = State
end, Flag = "Section_Toggle"
})

-- Aimbot Keybind
local AimbotKeybind = Enum.KeyCode.E
local AimbotKeybindEnabled = false
local ToggleWKeybind = AimSec:Toggle({Name = "Aimbot Enabled (w/ key)", Default = false, Callback = function(State) 
    AimbotKeybindEnabled = State
end, Flag = "Section_Toggle"
})

ToggleWKeybind:Keybind({Callback = function(Key)
    AimbotKeybind = Key
end})

-- Aimbot FOV
local AimbotFOV = 150
local Slider = AimSec:Slider({Name = "Aimbot FOV", default = 150, minimum = 50, maximum = 600, Callback = function(State)
    AimbotFOV = State
end})

-- Prioritize Hitbox
local HitboxPriority = "Head"
local Dropdown = AimSec:Dropdown({Name = "Prioritize Hitbox", Default = "Head", Options = {"Head", "Torso", "Legs", "Arms", "Upper", "Lower"}, Max = 6 , Callback = function(State) 
    HitboxPriority = State
end, Flag = "Section_Dropdown"
})

-- Aimbot Type Dropdown
local AimbotType = "Mouse"
local AimbotTypeDropdown = AimSec:Dropdown({Name = "Aimbot Type", Default = "Mouse", Options = {"Mouse", "CFrame", "Lock-On"}, Callback = function(State) 
    AimbotType = State
end, Flag = "Aimbot_Type_Dropdown"
})

-- Smoothing Option
local SmoothingValue = 3 -- Default smoothing value
local SmoothingSlider = AimSec:Slider({Name = "Smoothing", default = 3, minimum = 1, maximum = 20, Callback = function(State)
    SmoothingValue = State
end})

-- FOV Circle Toggle
local FOVCircleEnabled = false
local FOVCircleToggle = AimSec:Toggle({Name = "FOV Circle", Default = false, Callback = function(State)
    FOVCircleEnabled = State
end, Flag = "FOVCircle_Toggle"
})

-- Colorpicker for ESP (Set to White)
local ESPColor = Color3.fromRGB(255, 255, 255) -- White
local ESPTransparency = 1 -- Default transparency

local Colorpicker = AimSec:Colorpicker({Name = "Target ESP Color", Default = ESPColor, Alpha = ESPTransparency, Info = "For Box Esp Only", Callback = function(Color, Transparency) 
    ESPColor = Color
    ESPTransparency = Transparency
    UpdateBoxColors() -- Update the colors of all boxes instantly
end, Flag = "Section_Colorpicker"
})

-- Player List
local PlayerList = PlrList:PlayerList({})

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = game.Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Drawing = Drawing -- Using Drawing API for ESP

-- ESP Toggles
_G.ESPEnabled = false
_G.NameESPEnabled = false
_G.DistanceESPEnabled = false
_G.SkeletonESPEnabled = false

-- ESP Containers
local ESPBoxes = {}
local NameESPObjects = {}
local DistanceESPObjects = {}
local SkeletonLimbs = {}

-- Free Cam Variables
local FreeCamEnabled = false
local FreeCamSpeed = 1
local FreeCamToggle = ExpSec:Toggle({Name = "Free Cam", Default = false, Callback = function(State)
    FreeCamEnabled = State
    if FreeCamEnabled then
        EnableFreeCam()
    else
        DisableFreeCam()
    end
end})

local FreeCamSpeedSlider = ExpSec:Slider({Name = "Free Cam Speed", Default = 1, Min = 1, Max = 5, Callback = function(Value)
    FreeCamSpeed = Value
end})

-- Anti-Cheat Bypass Variables
local AntiCheatBypassEnabled = false
local AntiCheatBypassToggle = ExpSec:Toggle({Name = "Anti-Cheat Bypass", Default = false, Callback = function(State)
    AntiCheatBypassEnabled = State
    if AntiCheatBypassEnabled then
        BypassAntiCheat()
    else
        RestoreAntiCheat()
    end
end})

-- Anti-AFK Variables
local AntiAFKEnabled = false
local AntiAFKToggle = ExpSec:Toggle({Name = "Anti-AFK", Default = false, Callback = function(State)
    AntiAFKEnabled = State
    if AntiAFKEnabled then
        EnableAntiAFK()
    else
        DisableAntiAFK()
    end
end})

-- No Clip Variables
local NoClipEnabled = false
local NoClipToggle = ExpSec:Toggle({Name = "No Clip", Default = false, Callback = function(State)
    NoClipEnabled = State
    if NoClipEnabled then
        EnableNoClip()
    else
        DisableNoClip()
    end
end})

-- Arrow ESP Variables
local ArrowESPEnabled = false
local ArrowESPToggle = EspSec:Toggle({Name = "Arrow ESP", Default = false, Callback = function(State)
    ArrowESPEnabled = State
end})

local DistFromCenter = 80
local TriangleHeight = 16
local TriangleWidth = 16
local TriangleFilled = true
local TriangleTransparency = 0
local TriangleThickness = 1
local TriangleColor = Color3.fromRGB(255, 255, 255)
local AntiAliasing = false

local ArrowESPObjects = {}

-- Skeleton ESP Variables
local SkeletonESPColor = Color3.fromRGB(255, 255, 255) -- White
local SkeletonESPEnabled = false
local SkeletonESPToggle = EspSec:Toggle({Name = "Skeleton ESP", Default = false, Callback = function(State)
    SkeletonESPEnabled = State
end})

-- Rainbow Chams Variables
local RainbowChamsEnabled = false
local RainbowChamsSpeed = 1 -- Speed of color transition
local RainbowChamsTransparency = 0.5 -- Transparency of the chams

-- Function to apply rainbow chams to a player
local function ApplyRainbowChams(player)
    if player.Character then
        for _, part in pairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                -- Create a Highlight object for the part
                local highlight = Instance.new("Highlight")
                highlight.Parent = part
                highlight.FillTransparency = RainbowChamsTransparency
                highlight.OutlineTransparency = 0

                -- Rainbow color effect
                local hue = 0
                RunService.RenderStepped:Connect(function()
                    if RainbowChamsEnabled then
                        hue = (hue + RainbowChamsSpeed * 0.01) % 1
                        highlight.FillColor = Color3.fromHSV(hue, 1, 1)
                        highlight.OutlineColor = Color3.fromHSV(hue, 1, 1)
                    else
                        highlight:Destroy()
                    end
                end)
            end
        end
    end
end

-- Toggle Rainbow Chams
local RainbowChamsToggle = EspSec:Toggle({Name = "Rainbow Chams", Default = false, Callback = function(State)
    RainbowChamsEnabled = State
    if RainbowChamsEnabled then
        -- Apply Rainbow Chams to all existing players
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                ApplyRainbowChams(player)
            end
        end
    end
end})

-- Apply Rainbow Chams to new players
Players.PlayerAdded:Connect(function(player)
    if RainbowChamsEnabled and player ~= LocalPlayer then
        ApplyRainbowChams(player)
    end
end)

-- FOV Changer Variables
local FOVChangerEnabled = false
local FOVChangerValue = 70 -- Default FOV value
local FOVChangerToggle = ExpSec:Toggle({Name = "FOV Changer", Default = false, Callback = function(State)
    FOVChangerEnabled = State
    if FOVChangerEnabled then
        Camera.FieldOfView = FOVChangerValue
    else
        Camera.FieldOfView = 70 -- Reset to default FOV
    end
end})

local FOVChangerSlider = ExpSec:Slider({Name = "FOV Value", Default = 70, Min = 50, Max = 120, Callback = function(Value)
    FOVChangerValue = Value
    if FOVChangerEnabled then
        Camera.FieldOfView = FOVChangerValue
    end
end})

-- Fullbright Variables
local FullbrightEnabled = false
local FullbrightToggle = ExpSec:Toggle({Name = "Fullbright", Default = false, Callback = function(State)
    FullbrightEnabled = State
    if FullbrightEnabled then
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.Brightness = 2
    else
        Lighting.Ambient = Color3.new(0, 0, 0)
        Lighting.Brightness = 1
    end
end})

-- FOV Protection Mechanism
local function FOVProtection()
    RunService.RenderStepped:Connect(function()
        if FOVChangerEnabled and Camera.FieldOfView ~= FOVChangerValue then
            -- If FOV is changed by an external script or game mechanic, revert it
            Camera.FieldOfView = FOVChangerValue
        end
    end)
end

-- Initialize FOV Protection
FOVProtection()

-- Function to check if a player is an enemy
local function IsEnemy(player)
    if LocalPlayer.Team and player.Team then
        return LocalPlayer.Team ~= player.Team
    end
    return true -- If no teams exist, target all players
end

-- Function to create a box for a player
local function CreateBox(player)
    if ESPBoxes[player] then return end -- Prevent duplicate boxes

    local box = Drawing.new("Square")
    box.Color = ESPColor
    box.Thickness = 1.5
    box.Filled = false
    box.Transparency = ESPTransparency

    ESPBoxes[player] = box
end

-- Function to remove a player's box when they leave
local function RemoveBox(player)
    if ESPBoxes[player] then
        ESPBoxes[player]:Remove()
        ESPBoxes[player] = nil
    end
end

-- Function to update ESP boxes
local function UpdateESP()
    if not _G.ESPEnabled then
        for _, box in pairs(ESPBoxes) do
            box.Visible = false
        end
        return
    end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and IsEnemy(player) and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local rootPart = player.Character.HumanoidRootPart
            local head = player.Character:FindFirstChild("Head")

            local screenPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
            local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 1, 0))
            local footPos = Camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3, 0))

            if onScreen then
                local box = ESPBoxes[player]
                if not box then
                    CreateBox(player)
                    box = ESPBoxes[player]
                end
                
                local height = math.abs(headPos.Y - footPos.Y)
                local width = height / 2

                box.Size = Vector2.new(width, height)
                box.Position = Vector2.new(screenPos.X - width / 2, screenPos.Y - height / 2)
                box.Visible = true
            else
                if ESPBoxes[player] then
                    ESPBoxes[player].Visible = false
                end
            end
        elseif ESPBoxes[player] then
            ESPBoxes[player].Visible = false
        end
    end
end

-- Function to update ESP box colors
local function UpdateBoxColors()
    for _, box in pairs(ESPBoxes) do
        box.Color = ESPColor
        box.Transparency = ESPTransparency
    end
end

-- Function to create a Name ESP label
local function CreateNameESP(player)
    if NameESPObjects[player] then return end -- Prevent duplicate labels

    local nameTag = Drawing.new("Text")
    nameTag.Color = Color3.fromRGB(255, 255, 255) -- White Text
    nameTag.Size = 16
    nameTag.Outline = true
    nameTag.Center = true
    nameTag.Visible = false

    NameESPObjects[player] = nameTag
end

-- Function to remove a player's Name ESP when they leave
local function RemoveNameESP(player)
    if NameESPObjects[player] then
        NameESPObjects[player]:Remove()
        NameESPObjects[player] = nil
    end
end

-- Function to create a Distance ESP label
local function CreateDistanceESP(player)
    if DistanceESPObjects[player] then return end -- Prevent duplicate labels

    local distanceTag = Drawing.new("Text")
    distanceTag.Color = Color3.fromRGB(255, 255, 255) -- White Text
    distanceTag.Size = 16
    distanceTag.Outline = true
    distanceTag.Center = true
    distanceTag.Visible = false

    DistanceESPObjects[player] = distanceTag
end

-- Function to remove a player's Distance ESP when they leave
local function RemoveDistanceESP(player)
    if DistanceESPObjects[player] then
        DistanceESPObjects[player]:Remove()
        DistanceESPObjects[player] = nil
    end
end

-- Function to update Name ESP positions
local function UpdateNameESP()
    if not _G.NameESPEnabled then
        for _, nameTag in pairs(NameESPObjects) do
            nameTag.Visible = false
        end
        return
    end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and IsEnemy(player) and player.Character and player.Character:FindFirstChild("Head") then
            local head = player.Character.Head
            local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 1, 0))

            if onScreen then
                local nameTag = NameESPObjects[player]
                if not nameTag then
                    CreateNameESP(player)
                    nameTag = NameESPObjects[player]
                end
                
                nameTag.Position = Vector2.new(screenPos.X, screenPos.Y)
                nameTag.Text = player.Name
                nameTag.Visible = true
            else
                if NameESPObjects[player] then
                    NameESPObjects[player].Visible = false
                end
            end
        elseif NameESPObjects[player] then
            NameESPObjects[player].Visible = false
        end
    end
end

-- Function to update Distance ESP positions
local function UpdateDistanceESP()
    if not _G.DistanceESPEnabled then
        for _, distanceTag in pairs(DistanceESPObjects) do
            distanceTag.Visible = false
        end
        return
    end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and IsEnemy(player) and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local rootPart = player.Character.HumanoidRootPart
            local screenPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)

            if onScreen then
                local distanceTag = DistanceESPObjects[player]
                if not distanceTag then
                    CreateDistanceESP(player)
                    distanceTag = DistanceESPObjects[player]
                end

                -- Calculate distance in studs
                local distance = (rootPart.Position - Camera.CFrame.Position).Magnitude
                distanceTag.Text = "Studs " .. math.floor(distance)
                distanceTag.Position = Vector2.new(screenPos.X, screenPos.Y + 20) -- Position below the player's feet
                distanceTag.Visible = true
            else
                if DistanceESPObjects[player] then
                    DistanceESPObjects[player].Visible = false
                end
            end
        elseif DistanceESPObjects[player] then
            DistanceESPObjects[player].Visible = false
        end
    end
end

-- Free Cam Functions
local FreeCamConnection
local FreeCamCFrame

local function EnableFreeCam()
    FreeCamCFrame = Camera.CFrame
    FreeCamConnection = RunService.RenderStepped:Connect(function()
        if FreeCamEnabled then
            local moveVector = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                moveVector = moveVector + FreeCamCFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                moveVector = moveVector - FreeCamCFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                moveVector = moveVector - FreeCamCFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                moveVector = moveVector + FreeCamCFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                moveVector = moveVector + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                moveVector = moveVector - Vector3.new(0, 1, 0)
            end
            FreeCamCFrame = FreeCamCFrame + (moveVector * FreeCamSpeed)
            Camera.CFrame = FreeCamCFrame
        end
    end)
end

local function DisableFreeCam()
    if FreeCamConnection then
        FreeCamConnection:Disconnect()
        FreeCamConnection = nil
    end
    Camera.CFrame = FreeCamCFrame
end

-- Anti-Cheat Bypass Functions
local function BypassAntiCheat()
    -- Example: Disable anti-cheat checks (this is highly game-specific)
    warn("Anti-Cheat Bypass Enabled (This is a placeholder)")
end

local function RestoreAntiCheat()
    -- Example: Re-enable anti-cheat checks (this is highly game-specific)
    warn("Anti-Cheat Bypass Disabled (This is a placeholder)")
end

-- Anti-AFK Functions
local AntiAFKConnection

local function EnableAntiAFK()
    AntiAFKConnection = RunService.Heartbeat:Connect(function()
        if AntiAFKEnabled then
            -- Simulate movement to prevent AFK
            LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0, 0.1, 0)
            wait(1)
            LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame - Vector3.new(0, 0.1, 0)
        end
    end)
end

local function DisableAntiAFK()
    if AntiAFKConnection then
        AntiAFKConnection:Disconnect()
        AntiAFKConnection = nil
    end
end

-- No Clip Functions
local NoClipConnection

local function EnableNoClip()
    NoClipConnection = RunService.Stepped:Connect(function()
        if NoClipEnabled and LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end

local function DisableNoClip()
    if NoClipConnection then
        NoClipConnection:Disconnect()
        NoClipConnection = nil
    end
    if LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

-- Remove ESP when players leave
Players.PlayerRemoving:Connect(function(player)
    RemoveBox(player)
    RemoveNameESP(player)
    RemoveDistanceESP(player)
    if SkeletonLimbs[player] then
        for _, line in pairs(SkeletonLimbs[player]) do
            line:Remove()
        end
        SkeletonLimbs[player] = nil
    end
end)

-- FOV Circle
local FovCircle = Drawing.new("Circle")
FovCircle.Color = Color3.fromRGB(255, 255, 255) -- White
FovCircle.Thickness = 1
FovCircle.NumSides = 50
FovCircle.Filled = false
FovCircle.Transparency = 1
FovCircle.Visible = false

-- Function to update the FOV circle
local function UpdateFovCircle()
    if FOVCircleEnabled then
        local mousePos = UserInputService:GetMouseLocation()
        FovCircle.Position = Vector2.new(mousePos.X, mousePos.Y)
        FovCircle.Radius = AimbotFOV
        FovCircle.Visible = true
    else
        FovCircle.Visible = false
    end
end

-- Function to check if target is within FOV
local function IsInFov(targetPosition)
    local screenPoint, onScreen = Camera:WorldToViewportPoint(targetPosition)
    local mousePos = UserInputService:GetMouseLocation()

    if onScreen then
        local distanceFromMouse = (Vector2.new(screenPoint.X, screenPoint.Y) - mousePos).Magnitude
        return distanceFromMouse <= AimbotFOV
    end
    return false
end

-- Function to get the prioritized hitbox based on the dropdown selection
local function GetPrioritizedHitbox(player)
    if player.Character then
        if HitboxPriority == "Head" then
            return player.Character:FindFirstChild("Head")
        elseif HitboxPriority == "Torso" then
            if player.Character:FindFirstChild("Humanoid").RigType == Enum.HumanoidRigType.R15 then
                return player.Character:FindFirstChild("UpperTorso")
            else
                return player.Character:FindFirstChild("Torso")
            end
        elseif HitboxPriority == "Legs" then
            return player.Character:FindFirstChild("LeftLowerLeg") or player.Character:FindFirstChild("RightLowerLeg")
        elseif HitboxPriority == "Arms" then
            return player.Character:FindFirstChild("LeftUpperArm") or player.Character:FindFirstChild("RightUpperArm")
        elseif HitboxPriority == "Upper" then
            return player.Character:FindFirstChild("UpperTorso") or player.Character:FindFirstChild("Torso")
        elseif HitboxPriority == "Lower" then
            return player.Character:FindFirstChild("LowerTorso") or player.Character:FindFirstChild("Torso")
        end
    end
    return nil
end

-- Get the nearest enemy inside FOV
local function GetNearestEnemy()
    local nearestPlayer = nil
    local shortestDistance = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("Humanoid") and IsEnemy(player) then
            local humanoid = player.Character.Humanoid
            local aimPart = GetPrioritizedHitbox(player) -- Use the prioritized hitbox

            if aimPart and humanoid.Health > 0 and IsInFov(aimPart.Position) then
                local distance = (aimPart.Position - Camera.CFrame.Position).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    nearestPlayer = player
                end
            end
        end
    end
    return nearestPlayer
end

-- Aimbot Logic
local function Aimbot()
    if AimbotEnabled then
        local targetPlayer = GetNearestEnemy()
        if targetPlayer and targetPlayer.Character then
            local aimPart = GetPrioritizedHitbox(targetPlayer) -- Use the prioritized hitbox
            if aimPart then
                local aimPartScreenPos, onScreen = Camera:WorldToViewportPoint(aimPart.Position)

                if onScreen then
                    if AimbotType == "Mouse" then
                        local mousePos = UserInputService:GetMouseLocation()
                        local targetPos = Vector2.new(aimPartScreenPos.X, aimPartScreenPos.Y)
                        
                        -- Apply Smooth Movement
                        local moveX = (targetPos.X - mousePos.X) / SmoothingValue
                        local moveY = (targetPos.Y - mousePos.Y) / SmoothingValue

                        mousemoverel(moveX, moveY)
                    elseif AimbotType == "CFrame" then
                        local targetCFrame = CFrame.new(Camera.CFrame.Position, aimPart.Position)
                        Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, SmoothingValue / 20)
                    elseif AimbotType == "Lock-On" then
                        local targetCFrame = CFrame.new(Camera.CFrame.Position, aimPart.Position)
                        Camera.CFrame = targetCFrame
                    end
                end
            end
        end
    end
end

-- ESP Toggle
local ESPToggle = EspSec:Toggle({Name = "Box Esp", Default = false, Callback = function(State) 
    _G.ESPEnabled = State
    if State then
        print("ESP is now: Enabled")
    else
        print("ESP is now: Disabled")
    end
end, Flag = "ESP_Toggle"
})

-- Name ESP Toggle
local NameESPToggle = EspSec:Toggle({Name = "Name ESP Enabled", Default = false, Callback = function(State) 
    _G.NameESPEnabled = State
    if State then
        print("Name ESP is now: Enabled")
    else
        print("Name ESP is now: Disabled")
    end
end, Flag = "NameESP_Toggle"
})

-- Distance ESP Toggle
local DistanceESPToggle = EspSec:Toggle({Name = "Distance ESP Enabled", Default = false, Callback = function(State) 
    _G.DistanceESPEnabled = State
    if State then
        print("Distance ESP is now: Enabled")
    else
        print("Distance ESP is now: Disabled")
    end
end, Flag = "DistanceESP_Toggle"
})

-- Speed Hack
local SpeedHackEnabled = false
local SpeedHackToggle = ExpSec:Toggle({Name = "Speed Hack", Default = false, Callback = function(State)
    SpeedHackEnabled = State
end})

local SpeedMultiplier = 2
local SpeedSlider = ExpSec:Slider({Name = "Speed Multiplier", Default = 2, Min = 1, Max = 5, Callback = function(Value)
    SpeedMultiplier = Value
end})

RunService.RenderStepped:Connect(function()
    if SpeedHackEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = 16 * SpeedMultiplier
    end
end)

-- Infinite Jump
local InfiniteJumpEnabled = false
local InfiniteJumpToggle = ExpSec:Toggle({Name = "Infinite Jump", Default = false, Callback = function(State)
    InfiniteJumpEnabled = State
end})

game:GetService("UserInputService").JumpRequest:Connect(function()
    if InfiniteJumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Fly Hack
local FlyHackEnabled = false
local FlyHackToggle = ExpSec:Toggle({Name = "Fly Hack", Default = false, Callback = function(State)
    FlyHackEnabled = State
end})

local FlySpeed = 1 -- Adjusted for smoother floating
local FlySpeedSlider = ExpSec:Slider({Name = "Fly Speed", Default = 1, Min = 1, Max = 5, Callback = function(Value)
    FlySpeed = Value
end})

local function Fly()
    if FlyHackEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local rootPart = LocalPlayer.Character.HumanoidRootPart
        local velocity = rootPart.Velocity

        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            velocity = velocity + Vector3.new(0, FlySpeed, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            velocity = velocity - Vector3.new(0, FlySpeed, 0)
        end

        rootPart.Velocity = velocity
    end
end

RunService.RenderStepped:Connect(Fly)

-- Arrow ESP Functions
local function GetRelative(pos, char)
    if not char then return Vector2.new(0, 0) end

    local rootP = char.PrimaryPart.Position
    local camP = Camera.CFrame.Position
    local relative = CFrame.new(Vector3.new(rootP.X, camP.Y, rootP.Z), camP):PointToObjectSpace(pos)

    return Vector2.new(relative.X, relative.Z)
end

local function RelativeToCenter(v)
    return Camera.ViewportSize / 2 - v
end

local function RotateVect(v, a)
    a = math.rad(a)
    local x = v.x * math.cos(a) - v.y * math.sin(a)
    local y = v.x * math.sin(a) + v.y * math.cos(a)

    return Vector2.new(x, y)
end

local function DrawTriangle(color)
    local l = Drawing.new("Triangle")
    l.Visible = false
    l.Color = color
    l.Filled = TriangleFilled
    l.Thickness = TriangleThickness
    l.Transparency = 1 - TriangleTransparency
    return l
end

local function AntiA(v)
    if not AntiAliasing then return v end
    return Vector2.new(math.round(v.x), math.round(v.y))
end

local function ShowArrow(player)
    local Arrow = DrawTriangle(TriangleColor)

    local function Update()
        local connection
        connection = RunService.RenderStepped:Connect(function()
            if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local char = player.Character
                local hum = char:FindFirstChildOfClass("Humanoid")

                if hum and hum.Health > 0 then
                    local _, vis = Camera:WorldToViewportPoint(char.PrimaryPart.Position)
                    if not vis then
                        local rel = GetRelative(char.PrimaryPart.Position, LocalPlayer.Character)
                        local direction = rel.Unit

                        local base = direction * DistFromCenter
                        local sideLength = TriangleWidth / 2
                        local baseL = base + RotateVect(direction, 90) * sideLength
                        local baseR = base + RotateVect(direction, -90) * sideLength

                        local tip = direction * (DistFromCenter + TriangleHeight)

                        Arrow.PointA = AntiA(RelativeToCenter(baseL))
                        Arrow.PointB = AntiA(RelativeToCenter(baseR))
                        Arrow.PointC = AntiA(RelativeToCenter(tip))

                        Arrow.Visible = ArrowESPEnabled
                    else
                        Arrow.Visible = false
                    end
                else
                    Arrow.Visible = false
                end
            else
                Arrow.Visible = false

                if not player or not player.Parent then
                    Arrow:Remove()
                    connection:Disconnect()
                end
            end
        end)
    end

    coroutine.wrap(Update)()
end

-- Initialize Arrow ESP for all players
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        ShowArrow(player)
    end
end

-- Add Arrow ESP for new players
Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        ShowArrow(player)
    end
end)

-- Skeleton ESP Functions
local function DrawLine()
    local l = Drawing.new("Line")
    l.Visible = false
    l.From = Vector2.new(0, 0)
    l.To = Vector2.new(1, 1)
    l.Color = SkeletonESPColor -- White
    l.Thickness = 1
    l.Transparency = 1
    return l
end

local function DrawESP(plr)
    repeat wait() until plr.Character ~= nil and plr.Character:FindFirstChild("Humanoid") ~= nil
    local limbs = {}
    local R15 = (plr.Character.Humanoid.RigType == Enum.HumanoidRigType.R15) and true or false
    if R15 then 
        limbs = {
            -- Spine
            Head_UpperTorso = DrawLine(),
            UpperTorso_LowerTorso = DrawLine(),
            -- Left Arm
            UpperTorso_LeftUpperArm = DrawLine(),
            LeftUpperArm_LeftLowerArm = DrawLine(),
            LeftLowerArm_LeftHand = DrawLine(),
            -- Right Arm
            UpperTorso_RightUpperArm = DrawLine(),
            RightUpperArm_RightLowerArm = DrawLine(),
            RightLowerArm_RightHand = DrawLine(),
            -- Left Leg
            LowerTorso_LeftUpperLeg = DrawLine(),
            LeftUpperLeg_LeftLowerLeg = DrawLine(),
            LeftLowerLeg_LeftFoot = DrawLine(),
            -- Right Leg
            LowerTorso_RightUpperLeg = DrawLine(),
            RightUpperLeg_RightLowerLeg = DrawLine(),
            RightLowerLeg_RightFoot = DrawLine(),
        }
    else 
        limbs = {
            Head_Spine = DrawLine(),
            Spine = DrawLine(),
            LeftArm = DrawLine(),
            LeftArm_UpperTorso = DrawLine(),
            RightArm = DrawLine(),
            RightArm_UpperTorso = DrawLine(),
            LeftLeg = DrawLine(),
            LeftLeg_LowerTorso = DrawLine(),
            RightLeg = DrawLine(),
            RightLeg_LowerTorso = DrawLine()
        }
    end
    local function Visibility(state)
        for i, v in pairs(limbs) do
            v.Visible = state
        end
    end

    local function Colorize(color)
        for i, v in pairs(limbs) do
            v.Color = color
        end
    end

    local function UpdaterR15()
        local connection
        connection = game:GetService("RunService").RenderStepped:Connect(function()
            if plr.Character ~= nil and plr.Character:FindFirstChild("Humanoid") ~= nil and plr.Character:FindFirstChild("HumanoidRootPart") ~= nil and plr.Character.Humanoid.Health > 0 then
                local HUM, vis = Camera:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
                if vis and SkeletonESPEnabled and IsEnemy(plr) then
                    -- Head
                    local H = Camera:WorldToViewportPoint(plr.Character.Head.Position)
                    if limbs.Head_UpperTorso.From ~= Vector2.new(H.X, H.Y) then
                        --Spine
                        local UT = Camera:WorldToViewportPoint(plr.Character.UpperTorso.Position)
                        local LT = Camera:WorldToViewportPoint(plr.Character.LowerTorso.Position)
                        -- Left Arm
                        local LUA = Camera:WorldToViewportPoint(plr.Character.LeftUpperArm.Position)
                        local LLA = Camera:WorldToViewportPoint(plr.Character.LeftLowerArm.Position)
                        local LH = Camera:WorldToViewportPoint(plr.Character.LeftHand.Position)
                        -- Right Arm
                        local RUA = Camera:WorldToViewportPoint(plr.Character.RightUpperArm.Position)
                        local RLA = Camera:WorldToViewportPoint(plr.Character.RightLowerArm.Position)
                        local RH = Camera:WorldToViewportPoint(plr.Character.RightHand.Position)
                        -- Left leg
                        local LUL = Camera:WorldToViewportPoint(plr.Character.LeftUpperLeg.Position)
                        local LLL = Camera:WorldToViewportPoint(plr.Character.LeftLowerLeg.Position)
                        local LF = Camera:WorldToViewportPoint(plr.Character.LeftFoot.Position)
                        -- Right leg
                        local RUL = Camera:WorldToViewportPoint(plr.Character.RightUpperLeg.Position)
                        local RLL = Camera:WorldToViewportPoint(plr.Character.RightLowerLeg.Position)
                        local RF = Camera:WorldToViewportPoint(plr.Character.RightFoot.Position)

                        --Head
                        limbs.Head_UpperTorso.From = Vector2.new(H.X, H.Y)
                        limbs.Head_UpperTorso.To = Vector2.new(UT.X, UT.Y)

                        --Spine
                        limbs.UpperTorso_LowerTorso.From = Vector2.new(UT.X, UT.Y)
                        limbs.UpperTorso_LowerTorso.To = Vector2.new(LT.X, LT.Y)

                        -- Left Arm
                        limbs.UpperTorso_LeftUpperArm.From = Vector2.new(UT.X, UT.Y)
                        limbs.UpperTorso_LeftUpperArm.To = Vector2.new(LUA.X, LUA.Y)

                        limbs.LeftUpperArm_LeftLowerArm.From = Vector2.new(LUA.X, LUA.Y)
                        limbs.LeftUpperArm_LeftLowerArm.To = Vector2.new(LLA.X, LLA.Y)

                        limbs.LeftLowerArm_LeftHand.From = Vector2.new(LLA.X, LLA.Y)
                        limbs.LeftLowerArm_LeftHand.To = Vector2.new(LH.X, LH.Y)

                        -- Right Arm
                        limbs.UpperTorso_RightUpperArm.From = Vector2.new(UT.X, UT.Y)
                        limbs.UpperTorso_RightUpperArm.To = Vector2.new(RUA.X, RUA.Y)

                        limbs.RightUpperArm_RightLowerArm.From = Vector2.new(RUA.X, RUA.Y)
                        limbs.RightUpperArm_RightLowerArm.To = Vector2.new(RLA.X, RLA.Y)

                        limbs.RightLowerArm_RightHand.From = Vector2.new(RLA.X, RLA.Y)
                        limbs.RightLowerArm_RightHand.To = Vector2.new(RH.X, RH.Y)

                        -- Left Leg
                        limbs.LowerTorso_LeftUpperLeg.From = Vector2.new(LT.X, LT.Y)
                        limbs.LowerTorso_LeftUpperLeg.To = Vector2.new(LUL.X, LUL.Y)

                        limbs.LeftUpperLeg_LeftLowerLeg.From = Vector2.new(LUL.X, LUL.Y)
                        limbs.LeftUpperLeg_LeftLowerLeg.To = Vector2.new(LLL.X, LLL.Y)

                        limbs.LeftLowerLeg_LeftFoot.From = Vector2.new(LLL.X, LLL.Y)
                        limbs.LeftLowerLeg_LeftFoot.To = Vector2.new(LF.X, LF.Y)

                        -- Right Leg
                        limbs.LowerTorso_RightUpperLeg.From = Vector2.new(LT.X, LT.Y)
                        limbs.LowerTorso_RightUpperLeg.To = Vector2.new(RUL.X, RUL.Y)

                        limbs.RightUpperLeg_RightLowerLeg.From = Vector2.new(RUL.X, RUL.Y)
                        limbs.RightUpperLeg_RightLowerLeg.To = Vector2.new(RLL.X, RLL.Y)

                        limbs.RightLowerLeg_RightFoot.From = Vector2.new(RLL.X, RLL.Y)
                        limbs.RightLowerLeg_RightFoot.To = Vector2.new(RF.X, RF.Y)
                    end

                    if limbs.Head_UpperTorso.Visible ~= true then
                        Visibility(true)
                    end
                else 
                    if limbs.Head_UpperTorso.Visible ~= false then
                        Visibility(false)
                    end
                end
            else 
                if limbs.Head_UpperTorso.Visible ~= false then
                    Visibility(false)
                end
                if game.Players:FindFirstChild(plr.Name) == nil then 
                    for i, v in pairs(limbs) do
                        v:Remove()
                    end
                    connection:Disconnect()
                end
            end
        end)
    end

    local function UpdaterR6()
        local connection
        connection = game:GetService("RunService").RenderStepped:Connect(function()
            if plr.Character ~= nil and plr.Character:FindFirstChild("Humanoid") ~= nil and plr.Character:FindFirstChild("HumanoidRootPart") ~= nil and plr.Character.Humanoid.Health > 0 then
                local HUM, vis = Camera:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
                if vis and SkeletonESPEnabled and IsEnemy(plr) then
                    local H = Camera:WorldToViewportPoint(plr.Character.Head.Position)
                    if limbs.Head_Spine.From ~= Vector2.new(H.X, H.Y) then
                        local T_Height = plr.Character.Torso.Size.Y/2 - 0.2
                        local UT = Camera:WorldToViewportPoint((plr.Character.Torso.CFrame * CFrame.new(0, T_Height, 0)).p)
                        local LT = Camera:WorldToViewportPoint((plr.Character.Torso.CFrame * CFrame.new(0, -T_Height, 0)).p)

                        local LA_Height = plr.Character["Left Arm"].Size.Y/2 - 0.2
                        local LUA = Camera:WorldToViewportPoint((plr.Character["Left Arm"].CFrame * CFrame.new(0, LA_Height, 0)).p)
                        local LLA = Camera:WorldToViewportPoint((plr.Character["Left Arm"].CFrame * CFrame.new(0, -LA_Height, 0)).p)

                        local RA_Height = plr.Character["Right Arm"].Size.Y/2 - 0.2
                        local RUA = Camera:WorldToViewportPoint((plr.Character["Right Arm"].CFrame * CFrame.new(0, RA_Height, 0)).p)
                        local RLA = Camera:WorldToViewportPoint((plr.Character["Right Arm"].CFrame * CFrame.new(0, -RA_Height, 0)).p)

                        local LL_Height = plr.Character["Left Leg"].Size.Y/2 - 0.2
                        local LUL = Camera:WorldToViewportPoint((plr.Character["Left Leg"].CFrame * CFrame.new(0, LL_Height, 0)).p)
                        local LLL = Camera:WorldToViewportPoint((plr.Character["Left Leg"].CFrame * CFrame.new(0, -LL_Height, 0)).p)

                        local RL_Height = plr.Character["Right Leg"].Size.Y/2 - 0.2
                        local RUL = Camera:WorldToViewportPoint((plr.Character["Right Leg"].CFrame * CFrame.new(0, RL_Height, 0)).p)
                        local RLL = Camera:WorldToViewportPoint((plr.Character["Right Leg"].CFrame * CFrame.new(0, -RL_Height, 0)).p)

                        -- Head
                        limbs.Head_Spine.From = Vector2.new(H.X, H.Y)
                        limbs.Head_Spine.To = Vector2.new(UT.X, UT.Y)

                        --Spine
                        limbs.Spine.From = Vector2.new(UT.X, UT.Y)
                        limbs.Spine.To = Vector2.new(LT.X, LT.Y)

                        --Left Arm
                        limbs.LeftArm.From = Vector2.new(LUA.X, LUA.Y)
                        limbs.LeftArm.To = Vector2.new(LLA.X, LLA.Y)

                        limbs.LeftArm_UpperTorso.From = Vector2.new(UT.X, UT.Y)
                        limbs.LeftArm_UpperTorso.To = Vector2.new(LUA.X, LUA.Y)

                        --Right Arm
                        limbs.RightArm.From = Vector2.new(RUA.X, RUA.Y)
                        limbs.RightArm.To = Vector2.new(RLA.X, RLA.Y)

                        limbs.RightArm_UpperTorso.From = Vector2.new(UT.X, UT.Y)
                        limbs.RightArm_UpperTorso.To = Vector2.new(RUA.X, RUA.Y)

                        --Left Leg
                        limbs.LeftLeg.From = Vector2.new(LUL.X, LUL.Y)
                        limbs.LeftLeg.To = Vector2.new(LLL.X, LLL.Y)

                        limbs.LeftLeg_LowerTorso.From = Vector2.new(LT.X, LT.Y)
                        limbs.LeftLeg_LowerTorso.To = Vector2.new(LUL.X, LUL.Y)

                        --Right Leg
                        limbs.RightLeg.From = Vector2.new(RUL.X, RUL.Y)
                        limbs.RightLeg.To = Vector2.new(RLL.X, RLL.Y)

                        limbs.RightLeg_LowerTorso.From = Vector2.new(LT.X, LT.Y)
                        limbs.RightLeg_LowerTorso.To = Vector2.new(RUL.X, RUL.Y)
                    end

                    if limbs.Head_Spine.Visible ~= true then
                        Visibility(true)
                    end
                else 
                    if limbs.Head_Spine.Visible ~= false then
                        Visibility(false)
                    end
                end
            else 
                if limbs.Head_Spine.Visible ~= false then
                    Visibility(false)
                end
                if game.Players:FindFirstChild(plr.Name) == nil then 
                    for i, v in pairs(limbs) do
                        v:Remove()
                    end
                    connection:Disconnect()
                end
            end
        end)
    end

    if R15 then
        coroutine.wrap(UpdaterR15)()
    else 
        coroutine.wrap(UpdaterR6)()
    end
end

-- Initialize Skeleton ESP for all players
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        DrawESP(player)
    end
end

-- Add Skeleton ESP for new players
Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        DrawESP(player)
    end
end)

-- Update ESP and Aimbot on every frame
RunService.RenderStepped:Connect(function()
    UpdateESP()
    UpdateNameESP()
    UpdateDistanceESP()
    UpdateFovCircle()

    -- Aimbot Logic
    if AimbotKeybindEnabled then
        -- Aimbot w/ Key: Only activate when the key is pressed
        if UserInputService:IsKeyDown(AimbotKeybind) then
            Aimbot()
        end
    else
        -- Aimbot w/o Key: Automatically lock onto the closest player in FOV
        Aimbot()
    end
end)

Window:Initialize()