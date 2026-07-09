--[[
    FALLEN S.V - Universal Roblox Script
    Compatible: Delta, Arceus X, Fluxus, Hydrogen, etc.
    Author: ENI for LO ⚡
]]

-- ============================================
-- SERVICES
-- ============================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ============================================
-- STATE MANAGEMENT
-- ============================================
local State = {
    Speed1 = false,
    Speed1Value = 50,
    Speed2 = false,
    Speed2Value = 50,
    Fly1 = false,
    Fly1Speed = 50,
    Fly2 = false,
    Fly2Speed = 50,
    InfiniteJump = false,
    SwimFly = false,
    JumpPower1 = false,
    JumpPower1Value = 100,
    JumpPower2 = false,
    JumpPower2Value = 100,
    Noclip = false,
    Chams1 = false,
    Chams2 = false,
    Xray = false,
    ESPPlayer = false,
    ESPBox = false,
    ESPTracer = false,
    ESPSkeleton = false,
    Freecam = false,
    FreecamSpeed = 1,
    Fullbright = false,
    RemoveFog = false,
    LowGraphics = false,
    TptoolActive = false,
}

-- Storage for ESP objects
local ESPObjects = {}
local ChamsObjects = {}
local LoopGotoConnection = nil

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================
local function GetCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function GetHumanoid()
    local char = GetCharacter()
    return char:FindFirstChildOfClass("Humanoid")
end

local function GetRootPart()
    local char = GetCharacter()
    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("Head")
end

local function IsAlive()
    local hum = GetHumanoid()
    return hum and hum.Health > 0
end

local function GetPlayers()
    local list = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            table.insert(list, p)
        end
    end
    return list
end

local function WorldToScreen(pos)
    local screenPos, onScreen = Camera:WorldToScreenPoint(pos)
    return Vector2.new(screenPos.X, screenPos.Y), onScreen
end

-- ============================================
-- PLAYER FEATURES
-- ============================================

-- Speed Method 1: WalkSpeed
local function ToggleSpeed1(enable)
    State.Speed1 = enable
    if enable then
        spawn(function()
            while State.Speed1 do
                local hum = GetHumanoid()
                if hum then
                    hum.WalkSpeed = State.Speed1Value
                end
                RunService.Heartbeat:Wait()
            end
        end)
    else
        local hum = GetHumanoid()
        if hum then hum.WalkSpeed = 16 end
    end
end

-- Speed Method 2: CFrame-based
local function ToggleSpeed2(enable)
    State.Speed2 = enable
    if enable then
        spawn(function()
            while State.Speed2 do
                local hum = GetHumanoid()
                local root = GetRootPart()
                if hum and root and hum.MoveDirection.Magnitude > 0 then
                    local moveDir = hum.MoveDirection
                    root.CFrame = root.CFrame + moveDir * State.Speed2Value * 0.016
                end
                RunService.Heartbeat:Wait()
            end
        end)
    end
end

-- Fly Method 1: BodyVelocity
local flyBV, flyBG
local function ToggleFly1(enable)
    State.Fly1 = enable
    local root = GetRootPart()
    if not root then return end
    
    if enable then
        if flyBV then flyBV:Destroy() end
        if flyBG then flyBG:Destroy() end
        
        flyBV = Instance.new("BodyVelocity")
        flyBV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        flyBV.Velocity = Vector3.new(0, 0, 0)
        flyBV.Parent = root
        
        flyBG = Instance.new("BodyGyro")
        flyBG.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        flyBG.P = 9e4
        flyBG.Parent = root
        
        spawn(function()
            while State.Fly1 and root and root.Parent do
                local camCF = Camera.CFrame
                local dir = Vector3.new(0, 0, 0)
                
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    dir = dir + camCF.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    dir = dir - camCF.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    dir = dir - camCF.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    dir = dir + camCF.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    dir = dir + Vector3.new(0, 1, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                    dir = dir - Vector3.new(0, 1, 0)
                end
                
                if dir.Magnitude > 0 then
                    flyBV.Velocity = dir.Unit * State.Fly1Speed
                else
                    flyBV.Velocity = Vector3.new(0, 0, 0)
                end
                
                flyBG.CFrame = camCF
                RunService.Heartbeat:Wait()
            end
            if flyBV then flyBV:Destroy() flyBV = nil end
            if flyBG then flyBG:Destroy() flyBG = nil end
        end)
    else
        if flyBV then flyBV:Destroy() flyBV = nil end
        if flyBG then flyBG:Destroy() flyBG = nil end
    end
end

-- Fly Method 2: CFrame Teleport
local function ToggleFly2(enable)
    State.Fly2 = enable
    if enable then
        spawn(function()
            while State.Fly2 do
                local root = GetRootPart()
                if root then
                    local camCF = Camera.CFrame
                    local dir = Vector3.new(0, 0, 0)
                    
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                        dir = dir + camCF.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                        dir = dir - camCF.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                        dir = dir - camCF.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                        dir = dir + camCF.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                        dir = dir + Vector3.new(0, 1, 0)
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                        dir = dir - Vector3.new(0, 1, 0)
                    end
                    
                    if dir.Magnitude > 0 then
                        root.CFrame = root.CFrame + dir.Unit * State.Fly2Speed * 0.016
                    end
                end
                RunService.Heartbeat:Wait()
            end
        end)
    end
end

-- Infinite Jump
local infJumpConn
local function ToggleInfiniteJump(enable)
    State.InfiniteJump = enable
    if enable then
        infJumpConn = UserInputService.JumpRequest:Connect(function()
            local hum = GetHumanoid()
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    else
        if infJumpConn then infJumpConn:Disconnect() infJumpConn = nil end
    end
end

-- Swim Fly
local swimConn
local function ToggleSwimFly(enable)
    State.SwimFly = enable
    if enable then
        spawn(function()
            while State.SwimFly do
                local hum = GetHumanoid()
                if hum then
                    hum:ChangeState(Enum.HumanoidStateType.Swimming)
                end
                RunService.Heartbeat:Wait()
            end
        end)
    end
end

-- Jump Power Method 1: JumpPower
local function ToggleJumpPower1(enable)
    State.JumpPower1 = enable
    if enable then
        spawn(function()
            while State.JumpPower1 do
                local hum = GetHumanoid()
                if hum then
                    hum.JumpPower = State.JumpPower1Value
                    hum.UseJumpPower = true
                end
                RunService.Heartbeat:Wait()
            end
        end)
    else
        local hum = GetHumanoid()
        if hum then hum.JumpPower = 50 end
    end
end

-- Jump Power Method 2: JumpHeight
local function ToggleJumpPower2(enable)
    State.JumpPower2 = enable
    if enable then
        spawn(function()
            while State.JumpPower2 do
                local hum = GetHumanoid()
                if hum then
                    hum.JumpHeight = State.JumpPower2Value / 10
                    hum.UseJumpPower = false
                end
                RunService.Heartbeat:Wait()
            end
        end)
    else
        local hum = GetHumanoid()
        if hum then hum.JumpHeight = 7.2 end
    end
end

-- Noclip
local noclipConn
local function ToggleNoclip(enable)
    State.Noclip = enable
    if enable then
        noclipConn = RunService.Stepped:Connect(function()
            local char = GetCharacter()
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if noclipConn then noclipConn:Disconnect() noclipConn = nil end
        local char = GetCharacter()
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end

-- ============================================
-- ESP FEATURES
-- ============================================

-- Chams Method 1: Highlight
local function CreateChams1(player)
    if player == LocalPlayer then return end
    local char = player.Character
    if not char then return end
    
    if ChamsObjects[player] then
        for _, obj in pairs(ChamsObjects[player]) do
            if obj then obj:Destroy() end
        end
    end
    
    ChamsObjects[player] = {}
    
    local highlight = Instance.new("Highlight")
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0
    highlight.Adornee = char
    highlight.Parent = char
    
    table.insert(ChamsObjects[player], highlight)
end

local function RemoveChams1(player)
    if ChamsObjects[player] then
        for _, obj in pairs(ChamsObjects[player]) do
            if obj then obj:Destroy() end
        end
        ChamsObjects[player] = nil
    end
end

local chams1Conn
local function ToggleChams1(enable)
    State.Cham1 = enable
    if enable then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then CreateChams1(p) end
        end
        chams1Conn = Players.PlayerAdded:Connect(function(p)
            p.CharacterAdded:Connect(function()
                wait(1)
                if State.Cham1 then CreateChams1(p) end
            end)
        end)
    else
        if chams1Conn then chams1Conn:Disconnect() chams1Conn = nil end
        for _, p in pairs(Players:GetPlayers()) do
            RemoveChams1(p)
        end
    end
end

-- Chams Method 2: BoxHandleAdornment (Backup)
local function CreateChams2(player)
    if player == LocalPlayer then return end
    local char = player.Character
    if not char then return end
    
    if ChamsObjects[player] then
        for _, obj in pairs(ChamsObjects[player]) do
            if obj and obj:IsA("BoxHandleAdornment") then obj:Destroy() end
        end
    end
    
    ChamsObjects[player] = ChamsObjects[player] or {}
    
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            local box = Instance.new("BoxHandleAdornment")
            box.Color3 = Color3.fromRGB(255, 0, 0)
            box.Transparency = 0.5
            box.AlwaysOnTop = true
            box.ZIndex = 10
            box.Adornee = part
            box.Size = part.Size
            box.Parent = Camera
            
            table.insert(ChamsObjects[player], box)
        end
    end
end

local chams2Conn
local function ToggleChams2(enable)
    State.Cham2 = enable
    if enable then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then CreateChams2(p) end
        end
        chams2Conn = Players.PlayerAdded:Connect(function(p)
            p.CharacterAdded:Connect(function()
                wait(1)
                if State.Cham2 then CreateChams2(p) end
            end)
        end)
    else
        if chams2Conn then chams2Conn:Disconnect() chams2Conn = nil end
        for _, p in pairs(Players:GetPlayers()) do
            RemoveChams1(p) -- Same cleanup function works
        end
    end
end

-- Xray
local xrayBackup = {}
local function ToggleXray(enable)
    State.Xray = enable
    if enable then
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and not obj:IsA("Terrain") then
                xrayBackup[obj] = {
                    Transparency = obj.Transparency,
                    Material = obj.Material
                }
                obj.Transparency = 0.7
                obj.Material = Enum.Material.ForceField
            end
        end
    else
        for obj, data in pairs(xrayBackup) do
            if obj and obj.Parent then
                obj.Transparency = data.Transparency
                obj.Material = data.Material
            end
        end
        xrayBackup = {}
    end
end

-- ESP Player (Name + Distance)
local function CreateESPPlayer(player)
    if player == LocalPlayer then return end
    
    ESPObjects[player] = ESPObjects[player] or {}
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_Player"
    billboard.AlwaysOnTop = true
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.Parent = Camera
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 13
    nameLabel.Text = player.Name
    nameLabel.Parent = billboard
    
    local distLabel = Instance.new("TextLabel")
    distLabel.Size = UDim2.new(1, 0, 0.5, 0)
    distLabel.Position = UDim2.new(0, 0, 0.5, 0)
    distLabel.BackgroundTransparency = 1
    distLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    distLabel.TextStrokeTransparency = 0
    distLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    distLabel.Font = Enum.Font.Gotham
    distLabel.TextSize = 11
    distLabel.Text = "0m"
    distLabel.Parent = billboard
    
    table.insert(ESPObjects[player], billboard)
end

local espPlayerConn
local function ToggleESPPlayer(enable)
    State.ESPPlayer = enable
    if enable then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then CreateESPPlayer(p) end
        end
        espPlayerConn = Players.PlayerAdded:Connect(function(p)
            p.CharacterAdded:Connect(function()
                wait(1)
                if State.ESPPlayer then CreateESPPlayer(p) end
            end)
        end)
        
        spawn(function()
            while State.ESPPlayer do
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and ESPObjects[p] then
                        local head = p.Character:FindFirstChild("Head")
                        local root = p.Character:FindFirstChild("HumanoidRootPart")
                        if head and root then
                            local myRoot = GetRootPart()
                            if myRoot then
                                local dist = (root.Position - myRoot.Position).Magnitude
                                for _, obj in pairs(ESPObjects[p]) do
                                    if obj:IsA("BillboardGui") then
                                        obj.Adornee = head
                                        local distLabel = obj:FindFirstChildOfClass("TextLabel") and obj:FindFirstChild("distLabel")
                                        if distLabel then
                                            distLabel.Text = math.floor(dist) .. "m"
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                RunService.Heartbeat:Wait()
            end
        end)
    else
        if espPlayerConn then espPlayerConn:Disconnect() espPlayerConn = nil end
        for _, p in pairs(Players:GetPlayers()) do
            if ESPObjects[p] then
                for _, obj in pairs(ESPObjects[p]) do
                    if obj then obj:Destroy() end
                end
                ESPObjects[p] = nil
            end
        end
    end
end

-- ESP Box
local function CreateESPBox(player)
    if player == LocalPlayer then return end
    
    ESPObjects[player] = ESPObjects[player] or {}
    
    local box = Instance.new("BoxHandleAdornment")
    box.Name = "ESP_Box"
    box.Color3 = Color3.fromRGB(255, 255, 255)
    box.Transparency = 0.8
    box.AlwaysOnTop = true
    box.ZIndex = 10
    box.Parent = Camera
    
    table.insert(ESPObjects[player], box)
end

local espBoxConn
local function ToggleESPBox(enable)
    State.ESPBox = enable
    if enable then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then CreateESPBox(p) end
        end
        espBoxConn = Players.PlayerAdded:Connect(function(p)
            p.CharacterAdded:Connect(function()
                wait(1)
                if State.ESPBox then CreateESPBox(p) end
            end)
        end)
        
        spawn(function()
            while State.ESPBox do
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and ESPObjects[p] then
                        local root = p.Character:FindFirstChild("HumanoidRootPart")
                        if root then
                            for _, obj in pairs(ESPObjects[p]) do
                                if obj.Name == "ESP_Box" then
                                    obj.Adornee = root
                                    obj.Size = Vector3.new(4, 6, 2)
                                end
                            end
                        end
                    end
                end
                RunService.Heartbeat:Wait()
            end
        end)
    else
        if espBoxConn then espBoxConn:Disconnect() espBoxConn = nil end
        for _, p in pairs(Players:GetPlayers()) do
            if ESPObjects[p] then
                for _, obj in pairs(ESPObjects[p]) do
                    if obj and obj.Name == "ESP_Box" then obj:Destroy() end
                end
            end
        end
    end
end

-- ESP Tracer (Lines from bottom to player)
local function CreateESPTracer(player)
    if player == LocalPlayer then return end
    
    ESPObjects[player] = ESPObjects[player] or {}
    
    local line = Instance.new("LineHandleAdornment")
    line.Name = "ESP_Tracer"
    line.Color3 = Color3.fromRGB(255, 255, 255)
    line.Thickness = 1
    line.Transparency = 0.5
    line.AlwaysOnTop = true
    line.ZIndex = 10
    line.Parent = Camera
    
    table.insert(ESPObjects[player], line)
end

local espTracerConn
local function ToggleESPTracer(enable)
    State.ESPTracer = enable
    if enable then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then CreateESPTracer(p) end
        end
        espTracerConn = Players.PlayerAdded:Connect(function(p)
            p.CharacterAdded:Connect(function()
                wait(1)
                if State.ESPTracer then CreateESPTracer(p) end
            end)
        end)
        
        spawn(function()
            while State.ESPTracer do
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and ESPObjects[p] then
                        local root = p.Character:FindFirstChild("HumanoidRootPart")
                        local myRoot = GetRootPart()
                        if root and myRoot then
                            for _, obj in pairs(ESPObjects[p]) do
                                if obj.Name == "ESP_Tracer" then
                                    -- LineHandleAdornment approach: from player to ground
                                    obj.Adornee = root
                                end
                            end
                        end
                    end
                end
                RunService.Heartbeat:Wait()
            end
        end)
    else
        if espTracerConn then espTracerConn:Disconnect() espTracerConn = nil end
        for _, p in pairs(Players:GetPlayers()) do
            if ESPObjects[p] then
                for _, obj in pairs(ESPObjects[p]) do
                    if obj and obj.Name == "ESP_Tracer" then obj:Destroy() end
                end
            end
        end
    end
end

-- ESP Skeleton
local function CreateESPSkeleton(player)
    if player == LocalPlayer then return end
    local char = player.Character
    if not char then return end
    
    ESPObjects[player] = ESPObjects[player] or {}
    
    local connections = {
        {"Head", "Torso"},
        {"Torso", "Left Arm"},
        {"Torso", "Right Arm"},
        {"Torso", "Left Leg"},
        {"Torso", "Right Leg"},
    }
    
    for _, conn in pairs(connections) do
        local line = Instance.new("LineHandleAdornment")
        line.Name = "ESP_Skeleton_" .. conn[1] .. "_" .. conn[2]
        line.Color3 = Color3.fromRGB(255, 255, 255)
        line.Thickness = 2
        line.Transparency = 0.3
        line.AlwaysOnTop = true
        line.ZIndex = 10
        line.Parent = Camera
        
        table.insert(ESPObjects[player], line)
    end
end

local espSkelConn
local function ToggleESPSkeleton(enable)
    State.ESPSkeleton = enable
    if enable then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then CreateESPSkeleton(p) end
        end
        espSkelConn = Players.PlayerAdded:Connect(function(p)
            p.CharacterAdded:Connect(function()
                wait(1)
                if State.ESPSkeleton then CreateESPSkeleton(p) end
            end)
        end)
        
        spawn(function()
            while State.ESPSkeleton do
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and ESPObjects[p] then
                        local char = p.Character
                        for _, obj in pairs(ESPObjects[p]) do
                            if obj and obj.Name:find("ESP_Skeleton_") then
                                local parts = obj.Name:split("_")
                                local part1 = char:FindFirstChild(parts[3])
                                local part2 = char:FindFirstChild(parts[4])
                                if part1 and part2 then
                                    obj.Adornee = part1
                                end
                            end
                        end
                    end
                end
                RunService.Heartbeat:Wait()
            end
        end)
    else
        if espSkelConn then espSkelConn:Disconnect() espSkelConn = nil end
        for _, p in pairs(Players:GetPlayers()) do
            if ESPObjects[p] then
                for _, obj in pairs(ESPObjects[p]) do
                    if obj and obj.Name:find("ESP_Skeleton") then obj:Destroy() end
                end
            end
        end
    end
end

-- ============================================
-- TELEPORT FEATURES
-- ============================================

local function TeleportToPlayer(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return end
    local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    local myRoot = GetRootPart()
    if targetRoot and myRoot then
        myRoot.CFrame = targetRoot.CFrame + Vector3.new(0, 3, 0)
    end
end

local function ToggleLoopGoto(targetPlayer, interval)
    if LoopGotoConnection then
        LoopGotoConnection:Disconnect()
        LoopGotoConnection = nil
    end
    
    if targetPlayer and interval > 0 then
        LoopGotoConnection = spawn(function()
            while true do
                TeleportToPlayer(targetPlayer)
                wait(interval)
            end
        end)
    end
end

local function GiveTpTool()
    local char = GetCharacter()
    if not char then return end
    
    local tool = Instance.new("Tool")
    tool.Name = "TpTool"
    tool.RequiresHandle = false
    
    tool.Activated:Connect(function()
        local mouse = LocalPlayer:GetMouse()
        if mouse.Hit then
            local root = GetRootPart()
            if root then
                root.CFrame = mouse.Hit + Vector3.new(0, 3, 0)
            end
        end
    end)
    
    tool.Parent = char
end

-- ============================================
-- MISC FEATURES
-- ============================================

local freecamConn
local freecamOrigCF
local function ToggleFreecam(enable)
    State.Freecam = enable
    local root = GetRootPart()
    
    if enable then
        if root then
            root.Anchored = true
        end
        freecamOrigCF = Camera.CFrame
        
        freecamConn = spawn(function()
            while State.Freecam do
                local speed = State.FreecamSpeed
                local cf = Camera.CFrame
                
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    cf = cf + cf.LookVector * speed
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    cf = cf - cf.LookVector * speed
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    cf = cf - cf.RightVector * speed
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    cf = cf + cf.RightVector * speed
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    cf = cf + Vector3.new(0, speed, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                    cf = cf - Vector3.new(0, speed, 0)
                end
                
                Camera.CFrame = cf
                RunService.RenderStepped:Wait()
            end
        end)
    else
        if freecamConn then freecamConn:Disconnect() freecamConn = nil end
        if root then
            root.Anchored = false
        end
    end
end

local function ToggleFullbright(enable)
    State.Fullbright = enable
    if enable then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.Ambient = Color3.fromRGB(178, 178, 178)
        Lighting.OutdoorAmbient = Color3.fromRGB(178, 178, 178)
    else
        Lighting.Brightness = 1
        Lighting.ClockTime = 14
        Lighting.Ambient = Color3.fromRGB(0, 0, 0)
        Lighting.OutdoorAmbient = Color3.fromRGB(0, 0, 0)
    end
end

local fogBackup
local function ToggleRemoveFog(enable)
    State.RemoveFog = enable
    if enable then
        fogBackup = {
            FogEnd = Lighting.FogEnd,
            FogStart = Lighting.FogStart,
            FogColor = Lighting.FogColor
        }
        Lighting.FogEnd = 100000
        Lighting.FogStart = 0
    else
        if fogBackup then
            Lighting.FogEnd = fogBackup.FogEnd
            Lighting.FogStart = fogBackup.FogStart
            Lighting.FogColor = fogBackup.FogColor
        end
    end
end

local graphicsBackup = {}
local function ToggleLowGraphics(enable)
    State.LowGraphics = enable
    if enable then
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                graphicsBackup[obj] = {
                    Material = obj.Material,
                    Color = obj.Color
                }
                obj.Material = Enum.Material.SmoothPlastic
                obj.Color = Color3.fromRGB(128, 128, 128)
            elseif obj:IsA("Texture") or obj:IsA("Decal") then
                graphicsBackup[obj] = { Transparency = obj.Transparency }
                obj.Transparency = 1
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
                graphicsBackup[obj] = { Enabled = obj.Enabled }
                obj.Enabled = false
            end
        end
    else
        for obj, data in pairs(graphicsBackup) do
            if obj and obj.Parent then
                if obj:IsA("BasePart") then
                    obj.Material = data.Material
                    obj.Color = data.Color
                elseif obj:IsA("Texture") or obj:IsA("Decal") then
                    obj.Transparency = data.Transparency
                elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
                    obj.Enabled = data.Enabled
                end
            end
        end
        graphicsBackup = {}
    end
end

-- ============================================
-- GUI CREATION
-- ============================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FALLEN_SV"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pcall(function()
    ScreenGui.Parent = game:GetService("CoreGui")
end)

if not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 400, 0, 500)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 8)
mainCorner.Parent = MainFrame

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -60, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "FALLEN S.V"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 14
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

-- Minimize Button
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
MinimizeBtn.Position = UDim2.new(1, -60, 0, 0)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
MinimizeBtn.BorderSizePixel = 0
MinimizeBtn.Text = "—"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 14
MinimizeBtn.Parent = TitleBar

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -30, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 12
CloseBtn.Parent = TitleBar

-- Minimized Icon
local MinIcon = Instance.new("TextButton")
MinIcon.Name = "MinIcon"
MinIcon.Size = UDim2.new(0, 50, 0, 50)
MinIcon.Position = UDim2.new(0, 10, 0, 10)
MinIcon.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MinIcon.BorderSizePixel = 0
MinIcon.Text = "🌃"
MinIcon.TextSize = 30
MinIcon.Visible = false
MinIcon.Parent = ScreenGui

local minIconCorner = Instance.new("UICorner")
minIconCorner.CornerRadius = UDim.new(0, 8)
minIconCorner.Parent = MinIcon

-- Content Area (Scroll)
local ContentScroll = Instance.new("ScrollingFrame")
ContentScroll.Name = "Content"
ContentScroll.Size = UDim2.new(1, 0, 1, -30)
ContentScroll.Position = UDim2.new(0, 0, 0, 30)
ContentScroll.BackgroundTransparency = 1
ContentScroll.BorderSizePixel = 0
ContentScroll.ScrollBarThickness = 4
ContentScroll.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
ContentScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
ContentScroll.Parent = MainFrame

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout.Padding = UDim.new(0, 5)
ContentLayout.Parent = ContentScroll

local ContentPadding = Instance.new("UIPadding")
ContentPadding.PaddingLeft = UDim.new(0, 5)
ContentPadding.PaddingRight = UDim.new(0, 5)
ContentPadding.PaddingTop = UDim.new(0, 5)
ContentPadding.PaddingBottom = UDim.new(0, 5)
ContentPadding.Parent = ContentScroll

-- ============================================
-- GUI HELPER FUNCTIONS
-- ============================================

local function CreateCategory(name, order)
    local catFrame = Instance.new("Frame")
    catFrame.Name = name
    catFrame.Size = UDim2.new(1, -10, 0, 30)
    catFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    catFrame.BorderSizePixel = 0
    catFrame.LayoutOrder = order
    catFrame.Parent = ContentScroll
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = catFrame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = name:upper()
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.Parent = catFrame
    
    return catFrame
end

local function CreateSwitch(parent, name, order, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 30)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    frame.BorderSizePixel = 0
    frame.LayoutOrder = order
    frame.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local switchBtn = Instance.new("TextButton")
    switchBtn.Size = UDim2.new(0, 40, 0, 20)
    switchBtn.Position = UDim2.new(1, -50, 0.5, -10)
    switchBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    switchBtn.BorderSizePixel = 0
    switchBtn.Text = ""
    switchBtn.Parent = frame
    
    local switchCorner = Instance.new("UICorner")
    switchCorner.CornerRadius = UDim.new(1, 0)
    switchCorner.Parent = switchBtn
    
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 16, 0, 16)
    indicator.Position = UDim2.new(0, 2, 0, 2)
    indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    indicator.BorderSizePixel = 0
    indicator.Parent = switchBtn
    
    local indCorner = Instance.new("UICorner")
    indCorner.CornerRadius = UDim.new(1, 0)
    indCorner.Parent = indicator
    
    local enabled = false
    switchBtn.MouseButton1Click:Connect(function()
        enabled = not enabled
        if enabled then
            switchBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
            indicator.Position = UDim2.new(0, 22, 0, 2)
        else
            switchBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
            indicator.Position = UDim2.new(0, 2, 0, 2)
        end
        callback(enabled)
    end)
    
    return frame
end

local function CreateSwitchWithInput(parent, name, order, defaultVal, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 30)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    frame.BorderSizePixel = 0
    frame.LayoutOrder = order
    frame.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.4, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local input = Instance.new("TextBox")
    input.Size = UDim2.new(0, 50, 0, 20)
    input.Position = UDim2.new(1, -100, 0.5, -10)
    input.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    input.BorderSizePixel = 0
    input.Text = tostring(defaultVal)
    input.TextColor3 = Color3.fromRGB(255, 255, 255)
    input.Font = Enum.Font.Gotham
    input.TextSize = 11
    input.PlaceholderText = "Num"
    input.Parent = frame
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 4)
    inputCorner.Parent = input
    
    local switchBtn = Instance.new("TextButton")
    switchBtn.Size = UDim2.new(0, 40, 0, 20)
    switchBtn.Position = UDim2.new(1, -50, 0.5, -10)
    switchBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    switchBtn.BorderSizePixel = 0
    switchBtn.Text = ""
    switchBtn.Parent = frame
    
    local switchCorner = Instance.new("UICorner")
    switchCorner.CornerRadius = UDim.new(1, 0)
    switchCorner.Parent = switchBtn
    
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 16, 0, 16)
    indicator.Position = UDim2.new(0, 2, 0, 2)
    indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    indicator.BorderSizePixel = 0
    indicator.Parent = switchBtn
    
    local indCorner = Instance.new("UICorner")
    indCorner.CornerRadius = UDim.new(1, 0)
    indCorner.Parent = indicator
    
    local enabled = false
    
    input.FocusLost:Connect(function()
        local num = tonumber(input.Text)
        if num then
            callback(enabled, num)
        end
    end)
    
    switchBtn.MouseButton1Click:Connect(function()
        enabled = not enabled
        local num = tonumber(input.Text) or defaultVal
        if enabled then
            switchBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
            indicator.Position = UDim2.new(0, 22, 0, 2)
        else
            switchBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
            indicator.Position = UDim2.new(0, 2, 0, 2)
        end
        callback(enabled, num)
    end)
    
    return frame
end

-- ============================================
-- BUILD CATEGORIES
-- ============================================

-- PLAYER CATEGORY
local playerCat = CreateCategory("PLAYER", 1)

local playerContainer = Instance.new("Frame")
playerContainer.Size = UDim2.new(1, 0, 0, 0)
playerContainer.BackgroundTransparency = 1
playerContainer.BorderSizePixel = 0
playerContainer.AutomaticSize = Enum.AutomaticSize.Y
playerContainer.LayoutOrder = 2
playerContainer.Parent = ContentScroll

local playerLayout = Instance.new("UIListLayout")
playerLayout.SortOrder = Enum.SortOrder.LayoutOrder
playerLayout.Padding = UDim.new(0, 3)
playerLayout.Parent = playerContainer

CreateSwitchWithInput(playerContainer, "Speed", 1, 50, function(on, val) State.Speed1Value = val ToggleSpeed1(on) end)
CreateSwitchWithInput(playerContainer, "Speed2", 2, 50, function(on, val) State.Speed2Value = val ToggleSpeed2(on) end)
CreateSwitchWithInput(playerContainer, "Fly", 3, 50, function(on, val) State.Fly1Speed = val ToggleFly1(on) end)
CreateSwitchWithInput(playerContainer, "Fly2", 4, 50, function(on, val) State.Fly2Speed = val ToggleFly2(on) end)
CreateSwitch(playerContainer, "Infinite Jump", 5, ToggleInfiniteJump)
CreateSwitch(playerContainer, "Swim Fly", 6, ToggleSwimFly)
CreateSwitchWithInput(playerContainer, "Jump Power", 7, 100, function(on, val) State.JumpPower1Value = val ToggleJumpPower1(on) end)
CreateSwitchWithInput(playerContainer, "Jump Power2", 8, 100, function(on, val) State.JumpPower2Value = val ToggleJumpPower2(on) end)
CreateSwitch(playerContainer, "Noclip", 9, ToggleNoclip)

-- ESP CATEGORY
local espCat = CreateCategory("ESP", 10)

local espContainer = Instance.new("Frame")
espContainer.Size = UDim2.new(1, 0, 0, 0)
espContainer.BackgroundTransparency = 1
espContainer.BorderSizePixel = 0
espContainer.AutomaticSize = Enum.AutomaticSize.Y
espContainer.LayoutOrder = 11
espContainer.Parent = ContentScroll

local espLayout = Instance.new("UIListLayout")
espLayout.SortOrder = Enum.SortOrder.LayoutOrder
espLayout.Padding = UDim.new(0, 3)
espLayout.Parent = espContainer

CreateSwitch(espContainer, "Chams", 1, ToggleChams1)
CreateSwitch(espContainer, "Chams2", 2, ToggleChams2)
CreateSwitch(espContainer, "Xray", 3, ToggleXray)
CreateSwitch(espContainer, "ESP Player", 4, ToggleESPPlayer)
CreateSwitch(espContainer, "ESP Box", 5, ToggleESPBox)
CreateSwitch(espContainer, "ESP Tracer", 6, ToggleESPTracer)
CreateSwitch(espContainer, "ESP Skeleton", 7, ToggleESPSkeleton)

-- TELEPORT CATEGORY
local tpCat = CreateCategory("TELEPORT", 20)

local tpContainer = Instance.new("Frame")
tpContainer.Size = UDim2.new(1, 0, 0, 0)
tpContainer.BackgroundTransparency = 1
tpContainer.BorderSizePixel = 0
tpContainer.AutomaticSize = Enum.AutomaticSize.Y
tpContainer.LayoutOrder = 21
tpContainer.Parent = ContentScroll

local tpLayout = Instance.new("UIListLayout")
tpLayout.SortOrder = Enum.SortOrder.LayoutOrder
tpLayout.Padding = UDim.new(0, 3)
tpLayout.Parent = tpContainer

-- Goto Section
local gotoFrame = Instance.new("Frame")
gotoFrame.Size = UDim2.new(1, 0, 0, 60)
gotoFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
gotoFrame.BorderSizePixel = 0
gotoFrame.LayoutOrder = 1
gotoFrame.Parent = tpContainer

local gotoCorner = Instance.new("UICorner")
gotoCorner.CornerRadius = UDim.new(0, 4)
gotoCorner.Parent = gotoFrame

local gotoLabel = Instance.new("TextLabel")
gotoLabel.Size = UDim2.new(1, 0, 0, 20)
gotoLabel.Position = UDim2.new(0, 10, 0, 2)
gotoLabel.BackgroundTransparency = 1
gotoLabel.Text = "Goto Player"
gotoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
gotoLabel.Font = Enum.Font.Gotham
gotoLabel.TextSize = 12
gotoLabel.TextXAlignment = Enum.TextXAlignment.Left
gotoLabel.Parent = gotoFrame

local gotoDropdown = Instance.new("TextButton")
gotoDropdown.Size = UDim2.new(0.7, -15, 0, 25)
gotoDropdown.Position = UDim2.new(0, 10, 0, 25)
gotoDropdown.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
gotoDropdown.BorderSizePixel = 0
gotoDropdown.Text = "Select Player"
gotoDropdown.TextColor3 = Color3.fromRGB(200, 200, 200)
gotoDropdown.Font = Enum.Font.Gotham
gotoDropdown.TextSize = 11
gotoDropdown.Parent = gotoFrame

local ddCorner = Instance.new("UICorner")
ddCorner.CornerRadius = UDim.new(0, 4)
ddCorner.Parent = gotoDropdown

local gotoTeleBtn = Instance.new("TextButton")
gotoTeleBtn.Size = UDim2.new(0.3, -5, 0, 25)
gotoTeleBtn.Position = UDim2.new(0.7, 0, 0, 25)
gotoTeleBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
gotoTeleBtn.BorderSizePixel = 0
gotoTeleBtn.Text = "Teleport"
gotoTeleBtn.TextColor3 = Color3.fromRGB(25, 25, 35)
gotoTeleBtn.Font = Enum.Font.GothamBold
gotoTeleBtn.TextSize = 11
gotoTeleBtn.Parent = gotoFrame

local tpCorner = Instance.new("UICorner")
tpCorner.CornerRadius = UDim.new(0, 4)
tpCorner.Parent = gotoTeleBtn

-- Dropdown list for goto
local gotoList = Instance.new("Frame")
gotoList.Size = UDim2.new(0.7, -15, 0, 0)
gotoList.Position = UDim2.new(0, 10, 0, 50)
gotoList.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
gotoList.BorderSizePixel = 0
gotoList.ClipsDescendants = true
gotoList.Visible = false
gotoList.ZIndex = 100
gotoList.Parent = gotoFrame

local gotoListLayout = Instance.new("UIListLayout")
gotoListLayout.SortOrder = Enum.SortOrder.LayoutOrder
gotoListLayout.Parent = gotoList

local selectedGotoPlayer = nil

local function RefreshPlayerList()
    for _, child in pairs(gotoList:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    local order = 1
    for _, p in pairs(GetPlayers()) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 20)
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        btn.BorderSizePixel = 0
        btn.Text = p.Name
        btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 10
        btn.LayoutOrder = order
        btn.ZIndex = 101
        btn.Parent = gotoList
        
        btn.MouseButton1Click:Connect(function()
            selectedGotoPlayer = p
            gotoDropdown.Text = p.Name
            gotoList.Visible = false
            gotoList.Size = UDim2.new(0.7, -15, 0, 0)
        end)
        
        order = order + 1
    end
    
    gotoList.Size = UDim2.new(0.7, -15, 0, 20 * (#GetPlayers()))
end

gotoDropdown.MouseButton1Click:Connect(function()
    RefreshPlayerList()
    gotoList.Visible = not gotoList.Visible
end)

gotoTeleBtn.MouseButton1Click:Connect(function()
    if selectedGotoPlayer then
        TeleportToPlayer(selectedGotoPlayer)
    end
end)

-- Loop Goto Section
local loopGotoFrame = Instance.new("Frame")
loopGotoFrame.Size = UDim2.new(1, 0, 0, 85)
loopGotoFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
loopGotoFrame.BorderSizePixel = 0
loopGotoFrame.LayoutOrder = 2
loopGotoFrame.Parent = tpContainer

local lgCorner = Instance.new("UICorner")
lgCorner.CornerRadius = UDim.new(0, 4)
lgCorner.Parent = loopGotoFrame

local loopGotoLabel = Instance.new("TextLabel")
loopGotoLabel.Size = UDim2.new(1, 0, 0, 20)
loopGotoLabel.Position = UDim2.new(0, 10, 0, 2)
loopGotoLabel.BackgroundTransparency = 1
loopGotoLabel.Text = "Loop Goto"
loopGotoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
loopGotoLabel.Font = Enum.Font.Gotham
loopGotoLabel.TextSize = 12
loopGotoLabel.TextXAlignment = Enum.TextXAlignment.Left
loopGotoLabel.Parent = loopGotoFrame

local loopGotoDropdown = Instance.new("TextButton")
loopGotoDropdown.Size = UDim2.new(0.5, -15, 0, 25)
loopGotoDropdown.Position = UDim2.new(0, 10, 0, 25)
loopGotoDropdown.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
loopGotoDropdown.BorderSizePixel = 0
loopGotoDropdown.Text = "Select Player"
loopGotoDropdown.TextColor3 = Color3.fromRGB(200, 200, 200)
loopGotoDropdown.Font = Enum.Font.Gotham
loopGotoDropdown.TextSize = 11
loopGotoDropdown.Parent = loopGotoFrame

local lgddCorner = Instance.new("UICorner")
lgddCorner.CornerRadius = UDim.new(0, 4)
lgddCorner.Parent = loopGotoDropdown

local loopIntervalInput = Instance.new("TextBox")
loopIntervalInput.Size = UDim2.new(0.25, -10, 0, 25)
loopIntervalInput.Position = UDim2.new(0.5, 0, 0, 25)
loopIntervalInput.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
loopIntervalInput.BorderSizePixel = 0
loopIntervalInput.Text = "1"
loopIntervalInput.TextColor3 = Color3.fromRGB(255, 255, 255)
loopIntervalInput.Font = Enum.Font.Gotham
loopIntervalInput.TextSize = 11
loopIntervalInput.PlaceholderText = "Sec"
loopIntervalInput.Parent = loopGotoFrame

local liCorner = Instance.new("UICorner")
liCorner.CornerRadius = UDim.new(0, 4)
liCorner.Parent = loopIntervalInput

local loopGotoTeleBtn = Instance.new("TextButton")
loopGotoTeleBtn.Size = UDim2.new(0.25, -5, 0, 25)
loopGotoTeleBtn.Position = UDim2.new(0.75, 0, 0, 25)
loopGotoTeleBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
loopGotoTeleBtn.BorderSizePixel = 0
loopGotoTeleBtn.Text = "Loop TP"
loopGotoTeleBtn.TextColor3 = Color3.fromRGB(25, 25, 35)
loopGotoTeleBtn.Font = Enum.Font.GothamBold
loopGotoTeleBtn.TextSize = 10
loopGotoTeleBtn.Parent = loopGotoFrame

local lgtCorner = Instance.new("UICorner")
lgtCorner.CornerRadius = UDim.new(0, 4)
lgtCorner.Parent = loopGotoTeleBtn

local loopGotoStopBtn = Instance.new("TextButton")
loopGotoStopBtn.Size = UDim2.new(1, -20, 0, 25)
loopGotoStopBtn.Position = UDim2.new(0, 10, 0, 55)
loopGotoStopBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
loopGotoStopBtn.BorderSizePixel = 0
loopGotoStopBtn.Text = "Stop Loop"
loopGotoStopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
loopGotoStopBtn.Font = Enum.Font.GothamBold
loopGotoStopBtn.TextSize = 11
loopGotoStopBtn.Parent = loopGotoFrame

local lgsCorner = Instance.new("UICorner")
lgsCorner.CornerRadius = UDim.new(0, 4)
lgsCorner.Parent = loopGotoStopBtn

-- Loop Goto Dropdown List
local loopGotoList = Instance.new("Frame")
loopGotoList.Size = UDim2.new(0.5, -15, 0, 0)
loopGotoList.Position = UDim2.new(0, 10, 0, 50)
loopGotoList.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
loopGotoList.BorderSizePixel = 0
loopGotoList.ClipsDescendants = true
loopGotoList.Visible = false
loopGotoList.ZIndex = 100
loopGotoList.Parent = loopGotoFrame

local loopGotoListLayout = Instance.new("UIListLayout")
loopGotoListLayout.SortOrder = Enum.SortOrder.LayoutOrder
loopGotoListLayout.Parent = loopGotoList

local selectedLoopPlayer = nil

local function RefreshLoopPlayerList()
    for _, child in pairs(loopGotoList:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    local order = 1
    for _, p in pairs(GetPlayers()) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 20)
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        btn.BorderSizePixel = 0
        btn.Text = p.Name
        btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 10
        btn.LayoutOrder = order
        btn.ZIndex = 101
        btn.Parent = loopGotoList
        
        btn.MouseButton1Click:Connect(function()
            selectedLoopPlayer = p
            loopGotoDropdown.Text = p.Name
            loopGotoList.Visible = false
        end)
        
        order = order + 1
    end
end

loopGotoDropdown.MouseButton1Click:Connect(function()
    RefreshLoopPlayerList()
    loopGotoList.Visible = not loopGotoList.Visible
end)

loopGotoTeleBtn.MouseButton1Click:Connect(function()
    if selectedLoopPlayer then
        local interval = tonumber(loopIntervalInput.Text) or 1
        ToggleLoopGoto(selectedLoopPlayer, interval)
    end
end)

loopGotoStopBtn.MouseButton1Click:Connect(function()
    ToggleLoopGoto(nil, 0)
end)

-- TpTool
local tptoolFrame = Instance.new("Frame")
tptoolFrame.Size = UDim2.new(1, 0, 0, 35)
tptoolFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
tptoolFrame.BorderSizePixel = 0
tptoolFrame.LayoutOrder = 3
tptoolFrame.Parent = tpContainer

local ttCorner = Instance.new("UICorner")
ttCorner.CornerRadius = UDim.new(0, 4)
ttCorner.Parent = tptoolFrame

local tptoolBtn = Instance.new("TextButton")
tptoolBtn.Size = UDim2.new(1, -20, 0, 25)
tptoolBtn.Position = UDim2.new(0, 10, 0, 5)
tptoolBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
tptoolBtn.BorderSizePixel = 0
tptoolBtn.Text = "Give TpTool"
tptoolBtn.TextColor3 = Color3.fromRGB(25, 25, 35)
tptoolBtn.Font = Enum.Font.GothamBold
tptoolBtn.TextSize = 12
tptoolBtn.Parent = tptoolFrame

local ttbCorner = Instance.new("UICorner")
ttbCorner.CornerRadius = UDim.new(0, 4)
ttbCorner.Parent = tptoolBtn

tptoolBtn.MouseButton1Click:Connect(function()
    GiveTpTool()
end)

-- MISC CATEGORY
local miscCat = CreateCategory("MISC", 30)

local miscContainer = Instance.new("Frame")
miscContainer.Size = UDim2.new(1, 0, 0, 0)
miscContainer.BackgroundTransparency = 1
miscContainer.BorderSizePixel = 0
miscContainer.AutomaticSize = Enum.AutomaticSize.Y
miscContainer.LayoutOrder = 31
miscContainer.Parent = ContentScroll

local miscLayout = Instance.new("UIListLayout")
miscLayout.SortOrder = Enum.SortOrder.LayoutOrder
miscLayout.Padding = UDim.new(0, 3)
miscLayout.Parent = miscContainer

CreateSwitchWithInput(miscContainer, "Freecam", 1, 1, function(on, val) State.FreecamSpeed = val ToggleFreecam(on) end)
CreateSwitch(miscContainer, "Fullbright", 2, ToggleFullbright)
CreateSwitch(miscContainer, "Remove Fog", 3, ToggleRemoveFog)
CreateSwitch(miscContainer, "Low Graphics", 4, ToggleLowGraphics)

-- ============================================
-- DRAGGING FUNCTIONALITY
-- ============================================
local function MakeDraggable(dragPart, frame)
    local dragging = false
    local dragInput
    local dragStart
    local startPos
    
    dragPart.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    dragPart.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

MakeDraggable(TitleBar, MainFrame)
MakeDraggable(MinIcon, MinIcon)

-- ============================================
-- RESIZE FUNCTIONALITY
-- ============================================
local resizing = false
local resizeEdge = nil
local resizeStart
local resizeStartSize

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local mousePos = UserInputService:GetMouseLocation()
        local framePos = MainFrame.AbsolutePosition
        local frameSize = MainFrame.AbsoluteSize
        
        local relPos = mousePos - framePos
        
        -- Check edges (5px tolerance)
        if relPos.X > frameSize.X - 5 then
            resizing = true
            resizeEdge = "Right"
            resizeStart = mousePos
            resizeStartSize = MainFrame.Size
        elseif relPos.Y > frameSize.Y - 5 then
            resizing = true
            resizeEdge = "Bottom"
            resizeStart = mousePos
            resizeStartSize = MainFrame.Size
        end
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - resizeStart
        
        if resizeEdge == "Right" then
            local newWidth = math.max(200, resizeStartSize.X.Offset + delta.X)
            MainFrame.Size = UDim2.new(0, newWidth, resizeStartSize.Y.Scale, resizeStartSize.Y.Offset)
        elseif resizeEdge == "Bottom" then
            local newHeight = math.max(150, resizeStartSize.Y.Offset + delta.Y)
            MainFrame.Size = UDim2.new(resizeStartSize.X.Scale, resizeStartSize.X.Offset, 0, newHeight)
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        resizing = false
        resizeEdge = nil
    end
end)

-- ============================================
-- MINIMIZE / CLOSE
-- ============================================
MinimizeBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    MinIcon.Visible = true
end)

MinIcon.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    MinIcon.Visible = false
end)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    
    -- Cleanup all connections
    if noclipConn then noclipConn:Disconnect() end
    if infJumpConn then infJumpConn:Disconnect() end
    if freecamConn then freecamConn:Disconnect() end
    if chams1Conn then chams1Conn:Disconnect() end
    if chams2Conn then chams2Conn:Disconnect() end
    if espPlayerConn then espPlayerConn:Disconnect() end
    if espBoxConn then espBoxConn:Disconnect() end
    if espTracerConn then espTracerConn:Disconnect() end
    if espSkelConn then espSkelConn:Disconnect() end
    
    -- Reset states
    ToggleSpeed1(false)
    ToggleFly1(false)
    ToggleNoclip(false)
    ToggleFreecam(false)
end)

-- ============================================
-- NOTIFICATION
-- ============================================
local notifFrame = Instance.new("Frame")
notifFrame.Size = UDim2.new(0, 250, 0, 40)
notifFrame.Position = UDim2.new(0.5, -125, 0, 10)
notifFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
notifFrame.BorderSizePixel = 0
notifFrame.Visible = true
notifFrame.Parent = ScreenGui

local notifCorner = Instance.new("UICorner")
notifCorner.CornerRadius = UDim.new(0, 6)
notifCorner.Parent = notifFrame

local notifLabel = Instance.new("TextLabel")
notifLabel.Size = UDim2.new(1, -20, 1, 0)
notifLabel.Position = UDim2.new(0, 10, 0, 0)
notifLabel.BackgroundTransparency = 1
notifLabel.Text = "FALLEN S.V | Loaded ⚡"
notifLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
notifLabel.Font = Enum.Font.GothamBold
notifLabel.TextSize = 13
notifLabel.Parent = notifFrame

spawn(function()
    wait(3)
    local tween = TweenService:Create(notifFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -125, 0, -50)
    })
    tween:Play()
    tween.Completed:Connect(function()
        notifFrame:Destroy()
    end)
end)
