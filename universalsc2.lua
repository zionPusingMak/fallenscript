--[[
    FALLEN S.V v3 - Universal Roblox Script
    Compatible: Delta, Arceus X, Fluxus, Hydrogen, etc.
    No Drawing library - 100% Instance-based
]]

-- PROOF OF LIFE - Test if script even runs
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- State
local State = {
    Speed1 = false, Speed1Value = 50,
    Speed2 = false, Speed2Value = 50,
    Fly1 = false, Fly1Speed = 50,
    Fly2 = false, Fly2Speed = 50,
    InfiniteJump = false,
    SwimFly = false,
    JumpPower1 = false, JumpPower1Value = 100,
    JumpPower2 = false, JumpPower2Value = 100,
    Noclip = false,
    Chams1 = false, Chams2 = false,
    Xray = false,
    ESPPlayer = false, ESPBox = false,
    ESPTracer = false, ESPSkeleton = false,
    Freecam = false, FreecamSpeed = 1,
    Fullbright = false, RemoveFog = false, LowGraphics = false,
    LoopGotoActive = false,
}

local Connections = {}
local ESPObjects = {}
local ChamsObjects = {}

-- Utility
local function GetChar()
    local c = LocalPlayer.Character
    if c and c.Parent then return c end
    return nil
end

local function GetHum()
    local c = GetChar()
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function GetRoot()
    local c = GetChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end

-- ============================================
-- PLAYER FEATURES
-- ============================================

local function ToggleSpeed1(on)
    State.Speed1 = on
    if on then
        spawn(function()
            while State.Speed1 do
                local h = GetHum()
                if h then h.WalkSpeed = State.Speed1Value end
                wait()
            end
        end)
    else
        local h = GetHum()
        if h then h.WalkSpeed = 16 end
    end
end

local function ToggleSpeed2(on)
    State.Speed2 = on
    if on then
        spawn(function()
            while State.Speed2 do
                local h = GetHum()
                local r = GetRoot()
                if h and r and h.MoveDirection.Magnitude > 0 then
                    r.CFrame = r.CFrame + h.MoveDirection * State.Speed2Value * 0.016
                end
                wait()
            end
        end)
    end
end

local flyBV, flyBG
local function ToggleFly1(on)
    State.Fly1 = on
    if on then
        spawn(function()
            local root = GetRoot()
            local hum = GetHum()
            if not root then return end
            
            if hum then hum.PlatformStand = true end
            
            if flyBV then pcall(function() flyBV:Destroy() end) end
            if flyBG then pcall(function() flyBG:Destroy() end) end
            
            flyBV = Instance.new("BodyVelocity")
            flyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            flyBV.Velocity = Vector3.new(0, 0, 0)
            flyBV.Parent = root
            
            flyBG = Instance.new("BodyGyro")
            flyBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            flyBG.P = 9e4
            flyBG.D = 1000
            flyBG.Parent = root
            
            while State.Fly1 do
                local r2 = GetRoot()
                local h2 = GetHum()
                if not r2 or not r2.Parent then break end
                if h2 then h2.PlatformStand = true end
                
                local cam = Camera.CFrame
                local dir = Vector3.new(0, 0, 0)
                
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, 1, 0) end
                
                if flyBV and flyBV.Parent then
                    flyBV.Velocity = dir.Magnitude > 0 and (dir.Unit * State.Fly1Speed) or Vector3.new(0, 0, 0)
                end
                if flyBG and flyBG.Parent then flyBG.CFrame = cam end
                
                wait()
            end
            
            pcall(function() if flyBV then flyBV:Destroy() end flyBV = nil end)
            pcall(function() if flyBG then flyBG:Destroy() end flyBG = nil end)
            local h3 = GetHum()
            if h3 then h3.PlatformStand = false end
        end)
    else
        pcall(function() if flyBV then flyBV:Destroy() end flyBV = nil end)
        pcall(function() if flyBG then flyBG:Destroy() end flyBG = nil end)
        local h = GetHum()
        if h then h.PlatformStand = false end
    end
end

local function ToggleFly2(on)
    State.Fly2 = on
    if on then
        spawn(function()
            while State.Fly2 do
                local r = GetRoot()
                if r then
                    local cam = Camera.CFrame
                    local dir = Vector3.new(0, 0, 0)
                    
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, 1, 0) end
                    
                    if dir.Magnitude > 0 then
                        r.CFrame = r.CFrame + dir.Unit * State.Fly2Speed * 0.016
                    end
                end
                wait()
            end
        end)
    end
end

local function ToggleInfJump(on)
    State.InfiniteJump = on
    if Connections.InfJump then Connections.InfJump:Disconnect() Connections.InfJump = nil end
    if on then
        Connections.InfJump = UserInputService.JumpRequest:Connect(function()
            local h = GetHum()
            if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
    end
end

local swimBV
local function ToggleSwimFly(on)
    State.SwimFly = on
    if on then
        spawn(function()
            local root = GetRoot()
            if not root then return end
            
            if swimBV then pcall(function() swimBV:Destroy() end) end
            swimBV = Instance.new("BodyVelocity")
            swimBV.MaxForce = Vector3.new(0, 9e9, 0)
            swimBV.Velocity = Vector3.new(0, 0, 0)
            swimBV.Parent = root
            
            while State.SwimFly do
                local h = GetHum()
                if h then h:ChangeState(Enum.HumanoidStateType.Swimming) end
                
                if swimBV and swimBV.Parent then
                    local vel = Vector3.new(0, 0, 0)
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then vel = Vector3.new(0, 50, 0) end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then vel = Vector3.new(0, -50, 0) end
                    swimBV.Velocity = vel
                end
                
                wait()
            end
            pcall(function() if swimBV then swimBV:Destroy() end swimBV = nil end)
        end)
    else
        pcall(function() if swimBV then swimBV:Destroy() end swimBV = nil end)
        local h = GetHum()
        if h then h:ChangeState(Enum.HumanoidStateType.Landed) end
    end
end

local function ToggleJumpPower1(on)
    State.JumpPower1 = on
    if on then
        spawn(function()
            while State.JumpPower1 do
                local h = GetHum()
                if h then h.JumpPower = State.JumpPower1Value h.UseJumpPower = true end
                wait()
            end
        end)
    else
        local h = GetHum()
        if h then h.JumpPower = 50 h.UseJumpPower = true end
    end
end

local function ToggleJumpPower2(on)
    State.JumpPower2 = on
    if on then
        spawn(function()
            while State.JumpPower2 do
                local h = GetHum()
                if h then h.JumpHeight = State.JumpPower2Value / 10 h.UseJumpPower = false end
                wait()
            end
        end)
    else
        local h = GetHum()
        if h then h.JumpHeight = 7.2 h.UseJumpPower = false end
    end
end

local function ToggleNoclip(on)
    State.Noclip = on
    if Connections.Noclip then Connections.Noclip:Disconnect() Connections.Noclip = nil end
    if on then
        Connections.Noclip = RunService.Stepped:Connect(function()
            local c = GetChar()
            if c then
                for _, p in pairs(c:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
            end
        end)
    end
end

-- ============================================
-- ESP FEATURES (Instance-based only)
-- ============================================

local function ClearPlayerESP(player)
    if ESPObjects[player] then
        for _, obj in pairs(ESPObjects[player]) do
            pcall(function() obj:Destroy() end)
        end
        ESPObjects[player] = nil
    end
    if ChamsObjects[player] then
        for _, obj in pairs(ChamsObjects[player]) do
            pcall(function() obj:Destroy() end)
        end
        ChamsObjects[player] = nil
    end
end

-- Chams 1: Highlight
local function MakeChams1(player)
    if player == LocalPlayer then return end
    local char = player.Character
    if not char then return end
    
    ClearPlayerESP(player)
    ChamsObjects[player] = {}
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "Chams1"
    highlight.FillColor = Color3.fromRGB(255, 50, 50)
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0
    highlight.Adornee = char
    highlight.Parent = char
    
    table.insert(ChamsObjects[player], highlight)
end

local function ToggleChams1(on)
    State.Cham1 = on
    if Connections.Cham1 then Connections.Cham1:Disconnect() Connections.Cham1 = nil end
    
    if on then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then MakeChams1(p) end
        end
        Connections.Cham1 = Players.PlayerAdded:Connect(function(p)
            p.CharacterAdded:Connect(function() wait(1) if State.Cham1 then MakeChams1(p) end end)
        end)
    else
        for _, p in pairs(Players:GetPlayers()) do
            if ChamsObjects[p] then
                for _, obj in pairs(ChamsObjects[p]) do pcall(function() obj:Destroy() end) end
                ChamsObjects[p] = nil
            end
        end
    end
end

-- Chams 2: BoxHandleAdornment
local function MakeChams2(player)
    if player == LocalPlayer then return end
    local char = player.Character
    if not char then return end
    
    ClearPlayerESP(player)
    ChamsObjects[player] = {}
    
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            local box = Instance.new("BoxHandleAdornment")
            box.Name = "Chams2"
            box.Color3 = Color3.fromRGB(255, 50, 50)
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

local function ToggleChams2(on)
    State.Cham2 = on
    if Connections.Cham2 then Connections.Cham2:Disconnect() Connections.Cham2 = nil end
    
    if on then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then MakeChams2(p) end
        end
        Connections.Cham2 = Players.PlayerAdded:Connect(function(p)
            p.CharacterAdded:Connect(function() wait(1) if State.Cham2 then MakeChams2(p) end end)
        end)
    else
        for _, p in pairs(Players:GetPlayers()) do
            if ChamsObjects[p] then
                for _, obj in pairs(ChamsObjects[p]) do pcall(function() obj:Destroy() end) end
                ChamsObjects[p] = nil
            end
        end
    end
end

-- Xray
local xrayBackup = {}
local function ToggleXray(on)
    State.Xray = on
    if on then
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and not obj:IsA("Terrain") and obj.Name ~= "HumanoidRootPart" then
                xrayBackup[obj] = {Transparency = obj.Transparency, Material = obj.Material}
                pcall(function() obj.Transparency = 0.7 obj.Material = Enum.Material.ForceField end)
            end
        end
    else
        for obj, data in pairs(xrayBackup) do
            pcall(function()
                if obj and obj.Parent then
                    obj.Transparency = data.Transparency
                    obj.Material = data.Material
                end
            end)
        end
        xrayBackup = {}
    end
end

-- ESP Player: BillboardGui with name + distance
local function MakeESPPlayer(player)
    if player == LocalPlayer then return end
    local char = player.Character
    if not char then return end
    local head = char:FindFirstChild("Head")
    if not head then return end
    
    ClearPlayerESP(player)
    ESPObjects[player] = {}
    
    local bb = Instance.new("BillboardGui")
    bb.Name = "ESP_Player"
    bb.AlwaysOnTop = true
    bb.StudsOffset = Vector3.new(0, 3, 0)
    bb.Size = UDim2.new(0, 200, 0, 40)
    bb.Adornee = head
    bb.Parent = head
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 13
    nameLabel.Text = player.Name
    nameLabel.Parent = bb
    
    local distLabel = Instance.new("TextLabel")
    distLabel.Size = UDim2.new(1, 0, 0.5, 0)
    distLabel.Position = UDim2.new(0, 0, 0.5, 0)
    distLabel.BackgroundTransparency = 1
    distLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    distLabel.TextStrokeTransparency = 0
    distLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    distLabel.Font = Enum.Font.Gotham
    distLabel.TextSize = 11
    distLabel.Name = "DistLabel"
    distLabel.Text = "0m"
    distLabel.Parent = bb
    
    table.insert(ESPObjects[player], bb)
end

local function ToggleESPPlayer(on)
    State.ESPPlayer = on
    if Connections.ESPPlayer then Connections.ESPPlayer:Disconnect() Connections.ESPPlayer = nil end
    
    if on then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then MakeESPPlayer(p) end
        end
        Connections.ESPPlayer = Players.PlayerAdded:Connect(function(p)
            p.CharacterAdded:Connect(function() wait(1) if State.ESPPlayer then MakeESPPlayer(p) end end)
        end)
        
        -- Distance updater
        spawn(function()
            while State.ESPPlayer do
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and ESPObjects[p] then
                        local pRoot = p.Character:FindFirstChild("HumanoidRootPart")
                        local myRoot = GetRoot()
                        if pRoot and myRoot then
                            local dist = (pRoot.Position - myRoot.Position).Magnitude
                            for _, obj in pairs(ESPObjects[p]) do
                                if obj:IsA("BillboardGui") then
                                    local dl = obj:FindFirstChild("DistLabel")
                                    if dl then dl.Text = math.floor(dist) .. "m" end
                                end
                            end
                        end
                    end
                end
                wait(0.1)
            end
        end)
    else
        for _, p in pairs(Players:GetPlayers()) do ClearPlayerESP(p) end
    end
end

-- ESP Box: BoxHandleAdornment around character
local function MakeESPBox(player)
    if player == LocalPlayer then return end
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    ESPObjects[player] = ESPObjects[player] or {}
    
    local box = Instance.new("BoxHandleAdornment")
    box.Name = "ESP_Box"
    box.Color3 = Color3.fromRGB(255, 255, 255)
    box.Transparency = 0.8
    box.AlwaysOnTop = true
    box.ZIndex = 10
    box.Adornee = root
    box.Size = Vector3.new(4, 6, 2)
    box.Parent = Camera
    
    table.insert(ESPObjects[player], box)
end

local function ToggleESPBox(on)
    State.ESPBox = on
    if Connections.ESPBox then Connections.ESPBox:Disconnect() Connections.ESPBox = nil end
    
    if on then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then MakeESPBox(p) end
        end
        Connections.ESPBox = Players.PlayerAdded:Connect(function(p)
            p.CharacterAdded:Connect(function() wait(1) if State.ESPBox then MakeESPBox(p) end end)
        end)
    else
        for _, p in pairs(Players:GetPlayers()) do
            if ESPObjects[p] then
                for _, obj in pairs(ESPObjects[p]) do
                    if obj.Name == "ESP_Box" then pcall(function() obj:Destroy() end) end
                end
            end
        end
    end
end

-- ESP Tracer: Part-based line from bottom screen to player
local function MakeESPTracer(player)
    if player == LocalPlayer then return end
    ESPObjects[player] = ESPObjects[player] or {}
    -- We'll use a Beam for tracers
    -- Tracers will be updated in a loop
end

local function ToggleESPTracer(on)
    State.ESPTracer = on
    if not on then
        for _, p in pairs(Players:GetPlayers()) do
            if ESPObjects[p] then
                for _, obj in pairs(ESPObjects[p]) do
                    if obj.Name == "ESP_Tracer" then pcall(function() obj:Destroy() end) end
                end
            end
        end
    end
end

-- ESP Skeleton: Beam connections between body parts
local function MakeESPSkeleton(player)
    if player == LocalPlayer then return end
    local char = player.Character
    if not char then return end
    
    -- Remove old skeleton ESP for this player
    if ESPObjects[player] then
        for _, obj in pairs(ESPObjects[player]) do
            if obj.Name:find("Skel") then pcall(function() obj:Destroy() end) end
        end
    end
    
    ESPObjects[player] = ESPObjects[player] or {}
    
    local connections = {
        {"Head", "Torso"},
        {"Torso", "Left Arm"},
        {"Torso", "Right Arm"},
        {"Torso", "Left Leg"},
        {"Torso", "Right Leg"},
    }
    
    -- Try R15 connections if R6 not found
    local torso = char:FindFirstChild("Torso")
    if not torso then
        connections = {
            {"Head", "UpperTorso"},
            {"UpperTorso", "LeftUpperArm"},
            {"UpperTorso", "RightUpperArm"},
            {"LowerTorso", "LeftUpperLeg"},
            {"LowerTorso", "RightUpperLeg"},
            {"UpperTorso", "LowerTorso"},
        }
    end
    
    for _, conn in pairs(connections) do
        local part1 = char:FindFirstChild(conn[1])
        local part2 = char:FindFirstChild(conn[2])
        
        if part1 and part2 then
            -- Create attachments
            local att0 = part1:FindFirstChild("SkelAtt") or Instance.new("Attachment")
            att0.Name = "SkelAtt"
            att0.Parent = part1
            
            local att1 = part2:FindFirstChild("SkelAtt") or Instance.new("Attachment")
            att1.Name = "SkelAtt"
            att1.Parent = part2
            
            local beam = Instance.new("Beam")
            beam.Name = "Skel_" .. conn[1] .. "_" .. conn[2]
            beam.Attachment0 = att0
            beam.Attachment1 = att1
            beam.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
            beam.Width0 = 0.15
            beam.Width1 = 0.15
            beam.Transparency = NumberSequence.new(0.3)
            beam.FaceCamera = true
            beam.Parent = part1
            
            table.insert(ESPObjects[player], beam)
        end
    end
end

local function ToggleESPSkeleton(on)
    State.ESPSkeleton = on
    if Connections.ESPSkel then Connections.ESPSkel:Disconnect() Connections.ESPSkel = nil end
    
    if on then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then MakeESPSkeleton(p) end
        end
        Connections.ESPSkel = Players.PlayerAdded:Connect(function(p)
            p.CharacterAdded:Connect(function() wait(1) if State.ESPSkeleton then MakeESPSkeleton(p) end end)
        end)
    else
        for _, p in pairs(Players:GetPlayers()) do
            if ESPObjects[p] then
                for _, obj in pairs(ESPObjects[p]) do
                    if obj.Name:find("Skel") then pcall(function() obj:Destroy() end) end
                end
            end
        end
    end
end

-- ============================================
-- TELEPORT
-- ============================================

local function TeleportTo(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return end
    local tRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    local mRoot = GetRoot()
    if tRoot and mRoot then
        mRoot.CFrame = tRoot.CFrame + Vector3.new(0, 3, 0)
    end
end

local function StartLoopGoto(target, interval)
    State.LoopGotoActive = false
    wait(0.1)
    State.LoopGotoActive = true
    spawn(function()
        while State.LoopGotoActive and target and target.Character do
            TeleportTo(target)
            wait(interval)
        end
    end)
end

local function StopLoopGoto()
    State.LoopGotoActive = false
end

local function GiveTpTool()
    local char = GetChar()
    if not char then return end
    local existing = char:FindFirstChild("TpTool")
    if existing then existing:Destroy() end
    
    local tool = Instance.new("Tool")
    tool.Name = "TpTool"
    tool.RequiresHandle = false
    tool.CanBeDropped = false
    
    tool.Activated:Connect(function()
        local mouse = LocalPlayer:GetMouse()
        if mouse.Hit then
            local root = GetRoot()
            if root then root.CFrame = mouse.Hit + Vector3.new(0, 3, 0) end
        end
    end)
    
    tool.Parent = char
end

-- ============================================
-- MISC
-- ============================================

local function ToggleFreecam(on)
    State.Freecam = on
    if on then
        local root = GetRoot()
        if root then root.Anchored = true end
        spawn(function()
            while State.Freecam do
                local sp = State.FreecamSpeed
                local cf = Camera.CFrame
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then cf = cf + cf.LookVector * sp end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then cf = cf - cf.LookVector * sp end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then cf = cf - cf.RightVector * sp end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then cf = cf + cf.RightVector * sp end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then cf = cf + Vector3.new(0, sp, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then cf = cf - Vector3.new(0, sp, 0) end
                Camera.CFrame = cf
                wait()
            end
        end)
    else
        local root = GetRoot()
        if root then root.Anchored = false end
    end
end

local function ToggleFullbright(on)
    State.Fullbright = on
    if on then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.Ambient = Color3.fromRGB(178, 178, 178)
        Lighting.OutdoorAmbient = Color3.fromRGB(178, 178, 178)
    else
        Lighting.Brightness = 1
        Lighting.Ambient = Color3.fromRGB(0, 0, 0)
        Lighting.OutdoorAmbient = Color3.fromRGB(0, 0, 0)
    end
end

local fogBackup
local function ToggleRemoveFog(on)
    State.RemoveFog = on
    if on then
        fogBackup = {FogEnd = Lighting.FogEnd, FogStart = Lighting.FogStart}
        Lighting.FogEnd = 100000
        Lighting.FogStart = 0
    else
        if fogBackup then
            Lighting.FogEnd = fogBackup.FogEnd
            Lighting.FogStart = fogBackup.FogStart
        end
    end
end

local gfxBackup = {}
local function ToggleLowGraphics(on)
    State.LowGraphics = on
    if on then
        for _, obj in pairs(Workspace:GetDescendants()) do
            pcall(function()
                if obj:IsA("BasePart") then
                    gfxBackup[obj] = {Material = obj.Material, Color = obj.Color}
                    obj.Material = Enum.Material.SmoothPlastic
                    obj.Color = Color3.fromRGB(128, 128, 128)
                elseif obj:IsA("Texture") or obj:IsA("Decal") then
                    gfxBackup[obj] = {Transparency = obj.Transparency}
                    obj.Transparency = 1
                elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
                    gfxBackup[obj] = {Enabled = obj.Enabled}
                    obj.Enabled = false
                end
            end)
        end
    else
        for obj, data in pairs(gfxBackup) do
            pcall(function()
                if obj and obj.Parent then
                    if obj:IsA("BasePart") then obj.Material = data.Material obj.Color = data.Color
                    elseif obj:IsA("Texture") or obj:IsA("Decal") then obj.Transparency = data.Transparency
                    elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then obj.Enabled = data.Enabled end
                end
            end)
        end
        gfxBackup = {}
    end
end

-- ============================================
-- GUI
-- ============================================

local Gui = Instance.new("ScreenGui")
Gui.Name = "FALLEN_SV"
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Try CoreGui first, then PlayerGui
local guiParent = nil
pcall(function() guiParent = game:GetService("CoreGui") end)
if guiParent then
    pcall(function() Gui.Parent = guiParent end)
end
if not Gui.Parent then
    pcall(function() Gui.Parent = LocalPlayer:WaitForChild("PlayerGui", 5) end)
end
if not Gui.Parent then
    Gui.Parent = LocalPlayer.PlayerGui
end

-- MAIN FRAME - Fixed size that fits all screens
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 420, 0, 340)
Main.Position = UDim2.new(0.5, -210, 0.5, -170)
Main.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Parent = Gui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 6)
mainCorner.Parent = Main

-- TITLE BAR
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, -42, 0, 26)
TitleBar.Position = UDim2.new(0, 42, 0, 0)
TitleBar.BackgroundColor3 = Color3.fromRGB(14, 14, 17)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Main

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -56, 1, 0)
TitleLabel.Position = UDim2.new(0, 8, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "FALLEN S.V"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 12
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

-- Minimize
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 24, 0, 24)
MinBtn.Position = UDim2.new(1, -52, 0, 1)
MinBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
MinBtn.BorderSizePixel = 0
MinBtn.Text = "—"
MinBtn.TextColor3 = Color3.fromRGB(160, 160, 160)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 11
MinBtn.Parent = TitleBar

Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 4)

-- Close
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(1, -26, 0, 1)
CloseBtn.BackgroundColor3 = Color3.fromRGB(160, 35, 35)
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 10
CloseBtn.Parent = TitleBar

Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 4)

-- SIDEBAR
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 42, 1, 0)
Sidebar.Position = UDim2.new(0, 0, 0, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(10, 10, 13)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Main

Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 6)

local sideLayout = Instance.new("UIListLayout")
sideLayout.SortOrder = Enum.SortOrder.LayoutOrder
sideLayout.Padding = UDim.new(0, 3)
sideLayout.Parent = Sidebar

local sidePad = Instance.new("UIPadding")
sidePad.PaddingTop = UDim.new(0, 6)
sidePad.PaddingLeft = UDim.new(0, 3)
sidePad.PaddingRight = UDim.new(0, 3)
sidePad.Parent = Sidebar

-- Category data
local Cats = {
    {N = "Player", I = "👤", O = 1},
    {N = "ESP", I = "👁", O = 2},
    {N = "Teleport", I = "📍", O = 3},
    {N = "Misc", I = "⚙", O = 4},
}

local SideBtns = {}
local Pages = {}
local ActivePage = "Player"

local function SwitchPage(name)
    ActivePage = name
    for n, b in pairs(SideBtns) do
        local isActive = (n == name)
        b.BackgroundColor3 = isActive and Color3.fromRGB(35, 35, 42) or Color3.fromRGB(22, 22, 26)
    end
    for n, p in pairs(Pages) do
        p.Visible = (n == name)
    end
end

for _, cat in pairs(Cats) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -6, 0, 34)
    btn.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
    btn.BorderSizePixel = 0
    btn.Text = cat.I
    btn.TextSize = 16
    btn.Font = Enum.Font.Gotham
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.LayoutOrder = cat.O
    btn.Parent = Sidebar
    
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    
    btn.MouseButton1Click:Connect(function() SwitchPage(cat.N) end)
    SideBtns[cat.N] = btn
end

-- CONTENT AREA
local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -42, 1, -26)
ContentArea.Position = UDim2.new(0, 42, 0, 26)
ContentArea.BackgroundTransparency = 1
ContentArea.BorderSizePixel = 0
ContentArea.Parent = Main

-- Create pages
for _, cat in pairs(Cats) do
    local scroll = Instance.new("ScrollingFrame")
    scroll.Name = cat.N
    scroll.Size = UDim2.new(1, -6, 1, -6)
    scroll.Position = UDim2.new(0, 3, 0, 3)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 2
    scroll.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.Visible = (cat.N == "Player")
    scroll.Parent = ContentArea
    
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 2)
    layout.Parent = scroll
    
    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 3)
    pad.PaddingRight = UDim.new(0, 3)
    pad.PaddingTop = UDim.new(0, 3)
    pad.PaddingBottom = UDim.new(0, 3)
    pad.Parent = scroll
    
    Pages[cat.N] = scroll
end

-- ============================================
-- SWITCH COMPONENT
-- ============================================

local function MakeSwitch(parent, name, order, callback)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 26)
    f.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
    f.BorderSizePixel = 0
    f.LayoutOrder = order
    f.Parent = parent
    
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 4)
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.65, 0, 1, 0)
    lbl.Position = UDim2.new(0, 8, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = name
    lbl.TextColor3 = Color3.fromRGB(190, 190, 190)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = f
    
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(0, 34, 0, 16)
    bg.Position = UDim2.new(1, -42, 0.5, -8)
    bg.BackgroundColor3 = Color3.fromRGB(40, 40, 46)
    bg.BorderSizePixel = 0
    bg.Parent = f
    
    Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)
    
    local ind = Instance.new("Frame")
    ind.Size = UDim2.new(0, 12, 0, 12)
    ind.Position = UDim2.new(0, 2, 0, 2)
    ind.BackgroundColor3 = Color3.fromRGB(180, 180, 180)
    ind.BorderSizePixel = 0
    ind.Parent = bg
    
    Instance.new("UICorner", ind).CornerRadius = UDim.new(1, 0)
    
    local on = false
    
    bg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            on = not on
            local targetBg = on and Color3.fromRGB(0, 120, 80) or Color3.fromRGB(40, 40, 46)
            local targetPos = on and UDim2.new(0, 20, 0, 2) or UDim2.new(0, 2, 0, 2)
            local targetCol = on and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 180)
            
            TweenService:Create(bg, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {BackgroundColor3 = targetBg}):Play()
            TweenService:Create(ind, TweenInfo.new(0.25, Enum.EasingStyle.Back), {Position = targetPos, BackgroundColor3 = targetCol}):Play()
            
            callback(on)
        end
    end)
end

local function MakeSwitchInput(parent, name, order, default, callback)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 26)
    f.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
    f.BorderSizePixel = 0
    f.LayoutOrder = order
    f.Parent = parent
    
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 4)
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.35, 0, 1, 0)
    lbl.Position = UDim2.new(0, 8, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = name
    lbl.TextColor3 = Color3.fromRGB(190, 190, 190)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = f
    
    local inp = Instance.new("TextBox")
    inp.Size = UDim2.new(0, 40, 0, 18)
    inp.Position = UDim2.new(1, -86, 0.5, -9)
    inp.BackgroundColor3 = Color3.fromRGB(30, 30, 34)
    inp.BorderSizePixel = 0
    inp.Text = tostring(default)
    inp.TextColor3 = Color3.fromRGB(255, 255, 255)
    inp.Font = Enum.Font.Gotham
    inp.TextSize = 10
    inp.Parent = f
    
    Instance.new("UICorner", inp).CornerRadius = UDim.new(0, 3)
    
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(0, 34, 0, 16)
    bg.Position = UDim2.new(1, -42, 0.5, -8)
    bg.BackgroundColor3 = Color3.fromRGB(40, 40, 46)
    bg.BorderSizePixel = 0
    bg.Parent = f
    
    Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)
    
    local ind = Instance.new("Frame")
    ind.Size = UDim2.new(0, 12, 0, 12)
    ind.Position = UDim2.new(0, 2, 0, 2)
    ind.BackgroundColor3 = Color3.fromRGB(180, 180, 180)
    ind.BorderSizePixel = 0
    ind.Parent = bg
    
    Instance.new("UICorner", ind).CornerRadius = UDim.new(1, 0)
    
    local on = false
    
    inp.FocusLost:Connect(function()
        local num = tonumber(inp.Text)
        if num then callback(on, num) end
    end)
    
    bg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            on = not on
            local num = tonumber(inp.Text) or default
            local targetBg = on and Color3.fromRGB(0, 120, 80) or Color3.fromRGB(40, 40, 46)
            local targetPos = on and UDim2.new(0, 20, 0, 2) or UDim2.new(0, 2, 0, 2)
            local targetCol = on and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 180)
            
            TweenService:Create(bg, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {BackgroundColor3 = targetBg}):Play()
            TweenService:Create(ind, TweenInfo.new(0.25, Enum.EasingStyle.Back), {Position = targetPos, BackgroundColor3 = targetCol}):Play()
            
            callback(on, num)
        end
    end)
end

-- ============================================
-- POPULATE PAGES
-- ============================================

-- PLAYER
local pPage = Pages["Player"]
MakeSwitchInput(pPage, "Speed", 1, 50, function(o, v) State.Speed1Value = v ToggleSpeed1(o) end)
MakeSwitchInput(pPage, "Speed2", 2, 50, function(o, v) State.Speed2Value = v ToggleSpeed2(o) end)
MakeSwitchInput(pPage, "Fly", 3, 50, function(o, v) State.Fly1Speed = v ToggleFly1(o) end)
MakeSwitchInput(pPage, "Fly2", 4, 50, function(o, v) State.Fly2Speed = v ToggleFly2(o) end)
MakeSwitch(pPage, "Infinite Jump", 5, ToggleInfJump)
MakeSwitch(pPage, "Swim Fly", 6, ToggleSwimFly)
MakeSwitchInput(pPage, "Jump Power", 7, 100, function(o, v) State.JumpPower1Value = v ToggleJumpPower1(o) end)
MakeSwitchInput(pPage, "Jump Power2", 8, 100, function(o, v) State.JumpPower2Value = v ToggleJumpPower2(o) end)
MakeSwitch(pPage, "Noclip", 9, ToggleNoclip)

-- ESP
local ePage = Pages["ESP"]
MakeSwitch(ePage, "Chams", 1, ToggleChams1)
MakeSwitch(ePage, "Chams2", 2, ToggleChams2)
MakeSwitch(ePage, "Xray", 3, ToggleXray)
MakeSwitch(ePage, "ESP Player", 4, ToggleESPPlayer)
MakeSwitch(ePage, "ESP Box", 5, ToggleESPBox)
MakeSwitch(ePage, "ESP Tracer", 6, ToggleESPTracer)
MakeSwitch(ePage, "ESP Skeleton", 7, ToggleESPSkeleton)

-- TELEPORT
local tPage = Pages["Teleport"]

-- Goto
local gotoF = Instance.new("Frame")
gotoF.Size = UDim2.new(1, 0, 0, 50)
gotoF.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
gotoF.BorderSizePixel = 0
gotoF.LayoutOrder = 1
gotoF.Parent = tPage

Instance.new("UICorner", gotoF).CornerRadius = UDim.new(0, 4)

local gotoLbl = Instance.new("TextLabel")
gotoLbl.Size = UDim2.new(1, -16, 0, 16)
gotoLbl.Position = UDim2.new(0, 8, 0, 3)
gotoLbl.BackgroundTransparency = 1
gotoLbl.Text = "Goto Player"
gotoLbl.TextColor3 = Color3.fromRGB(190, 190, 190)
gotoLbl.Font = Enum.Font.Gotham
gotoLbl.TextSize = 10
gotoLbl.TextXAlignment = Enum.TextXAlignment.Left
gotoLbl.Parent = gotoF

local gotoDrop = Instance.new("TextButton")
gotoDrop.Size = UDim2.new(0.6, -12, 0, 22)
gotoDrop.Position = UDim2.new(0, 8, 0, 22)
gotoDrop.BackgroundColor3 = Color3.fromRGB(30, 30, 34)
gotoDrop.BorderSizePixel = 0
gotoDrop.Text = "Select Player"
gotoDrop.TextColor3 = Color3.fromRGB(160, 160, 160)
gotoDrop.Font = Enum.Font.Gotham
gotoDrop.TextSize = 9
gotoDrop.Parent = gotoF

Instance.new("UICorner", gotoDrop).CornerRadius = UDim.new(0, 3)

local gotoTP = Instance.new("TextButton")
gotoTP.Size = UDim2.new(0.4, -8, 0, 22)
gotoTP.Position = UDim2.new(0.6, 0, 0, 22)
gotoTP.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
gotoTP.BorderSizePixel = 0
gotoTP.Text = "Teleport"
gotoTP.TextColor3 = Color3.fromRGB(18, 18, 22)
gotoTP.Font = Enum.Font.GothamBold
gotoTP.TextSize = 9
gotoTP.Parent = gotoF

Instance.new("UICorner", gotoTP).CornerRadius = UDim.new(0, 3)

-- Goto dropdown list
local gotoList = Instance.new("Frame")
gotoList.Size = UDim2.new(0.6, -12, 0, 0)
gotoList.Position = UDim2.new(0, 8, 0, 44)
gotoList.BackgroundColor3 = Color3.fromRGB(25, 25, 28)
gotoList.BorderSizePixel = 0
gotoList.ClipsDescendants = true
gotoList.Visible = false
gotoList.ZIndex = 50
gotoList.Parent = gotoF

local gotoListLayout = Instance.new("UIListLayout")
gotoListLayout.SortOrder = Enum.SortOrder.LayoutOrder
gotoListLayout.Parent = gotoList

local selGoto = nil

local function RefreshGoto()
    for _, c in pairs(gotoList:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    local ord = 1
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1, 0, 0, 18)
            b.BackgroundColor3 = Color3.fromRGB(35, 35, 38)
            b.BorderSizePixel = 0
            b.Text = p.Name
            b.TextColor3 = Color3.fromRGB(180, 180, 180)
            b.Font = Enum.Font.Gotham
            b.TextSize = 9
            b.LayoutOrder = ord
            b.ZIndex = 51
            b.Parent = gotoList
            b.MouseButton1Click:Connect(function()
                selGoto = p
                gotoDrop.Text = p.Name
                gotoList.Visible = false
            end)
            ord = ord + 1
        end
    end
end

gotoDrop.MouseButton1Click:Connect(function()
    RefreshGoto()
    gotoList.Visible = not gotoList.Visible
end)

gotoTP.MouseButton1Click:Connect(function()
    if selGoto then TeleportTo(selGoto) end
end)

-- Loop Goto
local loopF = Instance.new("Frame")
loopF.Size = UDim2.new(1, 0, 0, 72)
loopF.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
loopF.BorderSizePixel = 0
loopF.LayoutOrder = 2
loopF.Parent = tPage

Instance.new("UICorner", loopF).CornerRadius = UDim.new(0, 4)

local loopLbl = Instance.new("TextLabel")
loopLbl.Size = UDim2.new(1, -16, 0, 16)
loopLbl.Position = UDim2.new(0, 8, 0, 3)
loopLbl.BackgroundTransparency = 1
loopLbl.Text = "Loop Goto"
loopLbl.TextColor3 = Color3.fromRGB(190, 190, 190)
loopLbl.Font = Enum.Font.Gotham
loopLbl.TextSize = 10
loopLbl.TextXAlignment = Enum.TextXAlignment.Left
loopLbl.Parent = loopF

local loopDrop = Instance.new("TextButton")
loopDrop.Size = UDim2.new(0.4, -10, 0, 22)
loopDrop.Position = UDim2.new(0, 8, 0, 22)
loopDrop.BackgroundColor3 = Color3.fromRGB(30, 30, 34)
loopDrop.BorderSizePixel = 0
loopDrop.Text = "Select"
loopDrop.TextColor3 = Color3.fromRGB(160, 160, 160)
loopDrop.Font = Enum.Font.Gotham
loopDrop.TextSize = 9
loopDrop.Parent = loopF

Instance.new("UICorner", loopDrop).CornerRadius = UDim.new(0, 3)

local loopInt = Instance.new("TextBox")
loopInt.Size = UDim2.new(0.2, -6, 0, 22)
loopInt.Position = UDim2.new(0.4, 0, 0, 22)
loopInt.BackgroundColor3 = Color3.fromRGB(30, 30, 34)
loopInt.BorderSizePixel = 0
loopInt.Text = "1"
loopInt.TextColor3 = Color3.fromRGB(255, 255, 255)
loopInt.Font = Enum.Font.Gotham
loopInt.TextSize = 9
loopInt.Parent = loopF

Instance.new("UICorner", loopInt).CornerRadius = UDim.new(0, 3)

local loopStart = Instance.new("TextButton")
loopStart.Size = UDim2.new(0.4, -8, 0, 22)
loopStart.Position = UDim2.new(0.6, 0, 0, 22)
loopStart.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
loopStart.BorderSizePixel = 0
loopStart.Text = "Loop"
loopStart.TextColor3 = Color3.fromRGB(18, 18, 22)
loopStart.Font = Enum.Font.GothamBold
loopStart.TextSize = 9
loopStart.Parent = loopF

Instance.new("UICorner", loopStart).CornerRadius = UDim.new(0, 3)

local loopStop = Instance.new("TextButton")
loopStop.Size = UDim2.new(1, -16, 0, 22)
loopStop.Position = UDim2.new(0, 8, 0, 46)
loopStop.BackgroundColor3 = Color3.fromRGB(150, 35, 35)
loopStop.BorderSizePixel = 0
loopStop.Text = "Stop Loop"
loopStop.TextColor3 = Color3.fromRGB(255, 255, 255)
loopStop.Font = Enum.Font.GothamBold
loopStop.TextSize = 9
loopStop.Parent = loopF

Instance.new("UICorner", loopStop).CornerRadius = UDim.new(0, 3)

-- Loop dropdown
local loopList = Instance.new("Frame")
loopList.Size = UDim2.new(0.4, -10, 0, 0)
loopList.Position = UDim2.new(0, 8, 0, 44)
loopList.BackgroundColor3 = Color3.fromRGB(25, 25, 28)
loopList.BorderSizePixel = 0
loopList.ClipsDescendants = true
loopList.Visible = false
loopList.ZIndex = 50
loopList.Parent = loopF

local loopListLayout = Instance.new("UIListLayout")
loopListLayout.SortOrder = Enum.SortOrder.LayoutOrder
loopListLayout.Parent = loopList

local selLoop = nil

local function RefreshLoop()
    for _, c in pairs(loopList:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    local ord = 1
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1, 0, 0, 18)
            b.BackgroundColor3 = Color3.fromRGB(35, 35, 38)
            b.BorderSizePixel = 0
            b.Text = p.Name
            b.TextColor3 = Color3.fromRGB(180, 180, 180)
            b.Font = Enum.Font.Gotham
            b.TextSize = 9
            b.LayoutOrder = ord
            b.ZIndex = 51
            b.Parent = loopList
            b.MouseButton1Click:Connect(function()
                selLoop = p
                loopDrop.Text = p.Name
                loopList.Visible = false
            end)
            ord = ord + 1
        end
    end
end

loopDrop.MouseButton1Click:Connect(function()
    RefreshLoop()
    loopList.Visible = not loopList.Visible
end)

loopStart.MouseButton1Click:Connect(function()
    if selLoop then
        StopLoopGoto()
        local intv = tonumber(loopInt.Text) or 1
        StartLoopGoto(selLoop, intv)
    end
end)

loopStop.MouseButton1Click:Connect(StopLoopGoto)

-- TpTool
local tpToolBtn = Instance.new("TextButton")
tpToolBtn.Size = UDim2.new(1, 0, 0, 26)
tpToolBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
tpToolBtn.BorderSizePixel = 0
tpToolBtn.Text = "Give TpTool"
tpToolBtn.TextColor3 = Color3.fromRGB(190, 190, 190)
tpToolBtn.Font = Enum.Font.GothamBold
tpToolBtn.TextSize = 10
tpToolBtn.LayoutOrder = 3
tpToolBtn.Parent = tPage

Instance.new("UICorner", tpToolBtn).CornerRadius = UDim.new(0, 4)
tpToolBtn.MouseButton1Click:Connect(GiveTpTool)

-- MISC
local mPage = Pages["Misc"]
MakeSwitchInput(mPage, "Freecam", 1, 1, function(o, v) State.FreecamSpeed = v ToggleFreecam(o) end)
MakeSwitch(mPage, "Fullbright", 2, ToggleFullbright)
MakeSwitch(mPage, "Remove Fog", 3, ToggleRemoveFog)
MakeSwitch(mPage, "Low Graphics", 4, ToggleLowGraphics)

-- ============================================
-- MIN ICON
-- ============================================
local MinIcon = Instance.new("TextButton")
MinIcon.Size = UDim2.new(0, 42, 0, 42)
MinIcon.Position = UDim2.new(0, 10, 0, 10)
MinIcon.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
MinIcon.BorderSizePixel = 0
MinIcon.Text = "🌃"
MinIcon.TextSize = 22
MinIcon.Visible = false
MinIcon.Parent = Gui

Instance.new("UICorner", MinIcon).CornerRadius = UDim.new(0, 6)

-- ============================================
-- DRAG
-- ============================================
local function MakeDrag(dragPart, frame)
    local dragging, dragInput, dragStart, startPos
    
    dragPart.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
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
    
    dragPart.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

MakeDrag(TitleBar, Main)
MakeDrag(MinIcon, MinIcon)

-- ============================================
-- MINIMIZE / CLOSE
-- ============================================
MinBtn.MouseButton1Click:Connect(function()
    Main.Visible = false
    MinIcon.Visible = true
end)

MinIcon.MouseButton1Click:Connect(function()
    Main.Visible = true
    MinIcon.Visible = false
end)

CloseBtn.MouseButton1Click:Connect(function()
    -- Reset all
    ToggleSpeed1(false) ToggleSpeed2(false)
    ToggleFly1(false) ToggleFly2(false)
    ToggleInfJump(false) ToggleSwimFly(false)
    ToggleJumpPower1(false) ToggleJumpPower2(false)
    ToggleNoclip(false) ToggleFreecam(false)
    ToggleFullbright(false) ToggleRemoveFog(false)
    ToggleLowGraphics(false) ToggleXray(false)
    StopLoopGoto()
    
    -- Clear ESP
    for _, p in pairs(Players:GetPlayers()) do ClearPlayerESP(p) end
    
    -- Disconnect all
    for k, conn in pairs(Connections) do
        if conn and typeof(conn) == "RBXScriptConnection" then conn:Disconnect() end
    end
    
    Gui:Destroy()
end)

-- ============================================
-- NOTIFICATION
-- ============================================
local notif = Instance.new("Frame")
notif.Size = UDim2.new(0, 200, 0, 32)
notif.Position = UDim2.new(0.5, -100, 0, 8)
notif.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
notif.BorderSizePixel = 0
notif.Parent = Gui

Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 5)

local notifTxt = Instance.new("TextLabel")
notifTxt.Size = UDim2.new(1, -12, 1, 0)
notifTxt.Position = UDim2.new(0, 6, 0, 0)
notifTxt.BackgroundTransparency = 1
notifTxt.Text = "FALLEN S.V | Loaded ⚡"
notifTxt.TextColor3 = Color3.fromRGB(255, 255, 255)
notifTxt.Font = Enum.Font.GothamBold
notifTxt.TextSize = 11
notifTxt.Parent = notif

spawn(function()
    wait(3)
    pcall(function()
        local t = TweenService:Create(notif, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.new(0.5, -100, 0, -40)
        })
        t:Play()
        t.Completed:Connect(function() notif:Destroy() end)
    end)
end)

-- Initial page
SwitchPage("Player")

print("[FALLEN S.V] Script loaded successfully!")    SwimFly = false,
    JumpPower1 = false, JumpPower1Value = 100,
    JumpPower2 = false, JumpPower2Value = 100,
    Noclip = false,
    Chams1 = false, Chams2 = false,
    Xray = false,
    ESPPlayer = false, ESPBox = false,
    ESPTracer = false, ESPSkeleton = false,
    Freecam = false, FreecamSpeed = 1,
    Fullbright = false, RemoveFog = false, LowGraphics = false,
    LoopGotoActive = false,
}

local ESPObjects = {}
local ChamsObjects = {}
local ESPDrawings = {}
local LoopGotoConn = nil
local noclipConn, infJumpConn, swimBV

-- ============================================
-- UTILITY
-- ============================================
local function GetCharacter()
    local char = LocalPlayer.Character
    if char and char.Parent then return char end
    return LocalPlayer.CharacterAdded:Wait()
end

local function GetHumanoid()
    local char = GetCharacter()
    return char:FindFirstChildOfClass("Humanoid")
end

local function GetRootPart()
    local char = GetCharacter()
    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("Head")
end

local function GetOtherPlayers()
    local list = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(list, p) end
    end
    return list
end

-- ============================================
-- PLAYER FEATURES
-- ============================================

-- Speed 1: WalkSpeed
local function ToggleSpeed1(enable)
    State.Speed1 = enable
    if enable then
        spawn(function()
            while State.Speed1 do
                local hum = GetHumanoid()
                if hum then hum.WalkSpeed = State.Speed1Value end
                RunService.Heartbeat:Wait()
            end
        end)
    else
        local hum = GetHumanoid()
        if hum then hum.WalkSpeed = 16 end
    end
end

-- Speed 2: CFrame
local function ToggleSpeed2(enable)
    State.Speed2 = enable
    if enable then
        spawn(function()
            while State.Speed2 do
                local hum = GetHumanoid()
                local root = GetRootPart()
                if hum and root and hum.MoveDirection.Magnitude > 0 then
                    root.CFrame = root.CFrame + hum.MoveDirection * State.Speed2Value * 0.016
                end
                RunService.Heartbeat:Wait()
            end
        end)
    end
end

-- Fly 1: BodyVelocity + PlatformStand
local flyBV, flyBG
local function ToggleFly1(enable)
    State.Fly1 = enable
    if enable then
        local root = GetRootPart()
        local hum = GetHumanoid()
        if not root then return end
        
        if hum then hum.PlatformStand = true end
        
        if flyBV then flyBV:Destroy() end
        if flyBG then flyBG:Destroy() end
        
        flyBV = Instance.new("BodyVelocity")
        flyBV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        flyBV.Velocity = Vector3.new(0, 0.1, 0)
        flyBV.Parent = root
        
        flyBG = Instance.new("BodyGyro")
        flyBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        flyBG.P = 9e4
        flyBG.D = 1000
        flyBG.Parent = root
        
        spawn(function()
            while State.Fly1 do
                local currentRoot = GetRootPart()
                local currentHum = GetHumanoid()
                if not currentRoot or not currentRoot.Parent then
                    State.Fly1 = false
                    break
                end
                
                if currentHum then currentHum.PlatformStand = true end
                
                local camCF = Camera.CFrame
                local dir = Vector3.new(0, 0, 0)
                
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + camCF.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - camCF.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - camCF.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + camCF.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, 1, 0) end
                
                if flyBV and flyBV.Parent then
                    flyBV.Velocity = dir.Magnitude > 0 and dir.Unit * State.Fly1Speed or Vector3.new(0, 0.1, 0)
                end
                if flyBG and flyBG.Parent then flyBG.CFrame = camCF end
                
                RunService.Heartbeat:Wait()
            end
            
            if flyBV then flyBV:Destroy() flyBV = nil end
            if flyBG then flyBG:Destroy() flyBG = nil end
            local hum2 = GetHumanoid()
            if hum2 then hum2.PlatformStand = false end
        end)
    else
        if flyBV then flyBV:Destroy() flyBV = nil end
        if flyBG then flyBG:Destroy() flyBG = nil end
        local hum = GetHumanoid()
        if hum then hum.PlatformStand = false end
    end
end

-- Fly 2: CFrame
local function ToggleFly2(enable)
    State.Fly2 = enable
    if enable then
        spawn(function()
            while State.Fly2 do
                local root = GetRootPart()
                if root then
                    local camCF = Camera.CFrame
                    local dir = Vector3.new(0, 0, 0)
                    
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + camCF.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - camCF.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - camCF.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + camCF.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, 1, 0) end
                    
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
local function ToggleInfiniteJump(enable)
    State.InfiniteJump = enable
    if enable then
        infJumpConn = UserInputService.JumpRequest:Connect(function()
            local hum = GetHumanoid()
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
    else
        if infJumpConn then infJumpConn:Disconnect() infJumpConn = nil end
    end
end

-- Swim Fly
local function ToggleSwimFly(enable)
    State.SwimFly = enable
    if enable then
        local root = GetRootPart()
        if not root then return end
        
        if swimBV then swimBV:Destroy() end
        swimBV = Instance.new("BodyVelocity")
        swimBV.MaxForce = Vector3.new(0, math.huge, 0)
        swimBV.Velocity = Vector3.new(0, 0, 0)
        swimBV.Parent = root
        
        spawn(function()
            while State.SwimFly do
                local hum = GetHumanoid()
                if hum then hum:ChangeState(Enum.HumanoidStateType.Swimming) end
                
                if swimBV and swimBV.Parent then
                    local vel = Vector3.new(0, 0, 0)
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then vel = Vector3.new(0, 50, 0) end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then vel = Vector3.new(0, -50, 0) end
                    swimBV.Velocity = vel
                end
                
                RunService.Heartbeat:Wait()
            end
            if swimBV then swimBV:Destroy() swimBV = nil end
        end)
    else
        if swimBV then swimBV:Destroy() swimBV = nil end
        local hum = GetHumanoid()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Landed) end
    end
end

-- Jump Power 1
local function ToggleJumpPower1(enable)
    State.JumpPower1 = enable
    if enable then
        spawn(function()
            while State.JumpPower1 do
                local hum = GetHumanoid()
                if hum then hum.JumpPower = State.JumpPower1Value hum.UseJumpPower = true end
                RunService.Heartbeat:Wait()
            end
        end)
    else
        local hum = GetHumanoid()
        if hum then hum.JumpPower = 50 hum.UseJumpPower = true end
    end
end

-- Jump Power 2: JumpHeight method
local function ToggleJumpPower2(enable)
    State.JumpPower2 = enable
    if enable then
        spawn(function()
            while State.JumpPower2 do
                local hum = GetHumanoid()
                if hum then hum.JumpHeight = State.JumpPower2Value / 10 hum.UseJumpPower = false end
                RunService.Heartbeat:Wait()
            end
        end)
    else
        local hum = GetHumanoid()
        if hum then hum.JumpHeight = 7.2 hum.UseJumpPower = false end
    end
end

-- Noclip
local function ToggleNoclip(enable)
    State.Noclip = enable
    if enable then
        noclipConn = RunService.Stepped:Connect(function()
            local char = GetCharacter()
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
    else
        if noclipConn then noclipConn:Disconnect() noclipConn = nil end
    end
end

-- ============================================
-- ESP FEATURES (Using Drawing Library)
-- ============================================

local function ClearPlayerESP(player)
    if ESPDrawings[player] then
        for _, d in pairs(ESPDrawings[player]) do
            if d then pcall(function() d:Remove() end) end
        end
        ESPDrawings[player] = nil
    end
    if ChamsObjects[player] then
        for _, obj in pairs(ChamsObjects[player]) do
            if obj then pcall(function() obj:Destroy() end) end
        end
        ChamsObjects[player] = nil
    end
end

-- Chams 1: Highlight
local function CreateChams1(player)
    if player == LocalPlayer or not player.Character then return end
    ClearPlayerESP(player)
    ChamsObjects[player] = {}
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "Chams1"
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0
    highlight.Adornee = player.Character
    highlight.Parent = player.Character
    
    table.insert(ChamsObjects[player], highlight)
end

local function RemoveChams(player)
    if ChamsObjects[player] then
        for _, obj in pairs(ChamsObjects[player]) do
            if obj then pcall(function() obj:Destroy() end) end
        end
        ChamsObjects[player] = nil
    end
end

local chams1Conn
local function ToggleChams1(enable)
    State.Cham1 = enable
    if enable then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then CreateChams1(p) end
        end
        chams1Conn = Players.PlayerAdded:Connect(function(p)
            p.CharacterAdded:Connect(function()
                wait(1)
                if State.Cham1 and p.Character then CreateChams1(p) end
            end)
        end)
    else
        if chams1Conn then chams1Conn:Disconnect() chams1Conn = nil end
        for _, p in pairs(Players:GetPlayers()) do RemoveChams(p) end
    end
end

-- Chams 2: BoxHandleAdornment
local function CreateChams2(player)
    if player == LocalPlayer or not player.Character then return end
    RemoveChams(player)
    ChamsObjects[player] = {}
    
    for _, part in pairs(player.Character:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            local box = Instance.new("BoxHandleAdornment")
            box.Name = "Chams2"
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
            if p ~= LocalPlayer and p.Character then CreateChams2(p) end
        end
        chams2Conn = Players.PlayerAdded:Connect(function(p)
            p.CharacterAdded:Connect(function()
                wait(1)
                if State.Cham2 and p.Character then CreateChams2(p) end
            end)
        end)
    else
        if chams2Conn then chams2Conn:Disconnect() chams2Conn = nil end
        for _, p in pairs(Players:GetPlayers()) do RemoveChams(p) end
    end
end

-- Xray
local xrayBackup = {}
local function ToggleXray(enable)
    State.Xray = enable
    if enable then
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and not obj:IsA("Terrain") and obj.Name ~= "HumanoidRootPart" then
                xrayBackup[obj] = {Transparency = obj.Transparency, Material = obj.Material}
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

-- ESP Drawing System
local function CreatePlayerDrawings(player)
    if player == LocalPlayer then return end
    ESPDrawings[player] = {}
    
    -- ESP Player: Name text + Distance text
    local nameText = Drawing.new("Text")
    nameText.Size = 13
    nameText.Center = true
    nameText.Outline = true
    nameText.OutlineColor = Color3.fromRGB(0, 0, 0)
    nameText.Color = Color3.fromRGB(255, 255, 255)
    nameText.Font = 2
    nameText.Visible = false
    ESPDrawings[player].NameText = nameText
    
    local distText = Drawing.new("Text")
    distText.Size = 11
    distText.Center = true
    distText.Outline = true
    distText.OutlineColor = Color3.fromRGB(0, 0, 0)
    distText.Color = Color3.fromRGB(200, 200, 200)
    distText.Font = 2
    distText.Visible = false
    ESPDrawings[player].DistText = distText
    
    -- ESP Box: 4 lines
    local boxLines = {}
    for i = 1, 4 do
        local line = Drawing.new("Line")
        line.Thickness = 1
        line.Color = Color3.fromRGB(255, 255, 255)
        line.Transparency = 0.5
        line.Visible = false
        boxLines[i] = line
    end
    ESPDrawings[player].BoxLines = boxLines
    
    -- ESP Tracer: 1 line
    local tracerLine = Drawing.new("Line")
    tracerLine.Thickness = 1
    tracerLine.Color = Color3.fromRGB(255, 255, 255)
    tracerLine.Transparency = 0.5
    tracerLine.Visible = false
    ESPDrawings[player].TracerLine = tracerLine
    
    -- ESP Skeleton: multiple lines
    local skelLines = {}
    for i = 1, 6 do
        local line = Drawing.new("Line")
        line.Thickness = 2
        line.Color = Color3.fromRGB(255, 255, 255)
        line.Transparency = 0.3
        line.Visible = false
        skelLines[i] = line
    end
    ESPDrawings[player].SkelLines = skelLines
end

-- Skeleton connections (R6 and R15 compatible)
local SkeletonConnections = {
    R6 = {
        {1, "Head", "Torso"},
        {2, "Torso", "Left Arm"},
        {3, "Torso", "Right Arm"},
        {4, "Torso", "Left Leg"},
        {5, "Torso", "Right Leg"},
    },
    R15 = {
        {1, "Head", "UpperTorso"},
        {2, "UpperTorso", "LeftUpperArm"},
        {3, "UpperTorso", "RightUpperArm"},
        {4, "LowerTorso", "LeftUpperLeg"},
        {5, "LowerTorso", "RightUpperLeg"},
        {6, "UpperTorso", "LowerTorso"},
    }
}

local espUpdateConn
local function StartESPUpdate()
    if espUpdateConn then espUpdateConn:Disconnect() end
    
    espUpdateConn = RunService.RenderStepped:Connect(function()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and ESPDrawings[player] then
                local char = player.Character
                local root = char:FindFirstChild("HumanoidRootPart")
                local head = char:FindFirstChild("Head")
                local hum = char:FindFirstChildOfClass("Humanoid")
                
                if root and head and hum and hum.Health > 0 then
                    local rootPos, rootVisible = Camera:WorldToScreenPoint(root.Position)
                    local headPos, headVisible = Camera:WorldToScreenPoint(head.Position + Vector3.new(0, 0.5, 0))
                    local legPos, legVisible = Camera:WorldToScreenPoint(root.Position - Vector3.new(0, 3, 0))
                    
                    local myRoot = GetRootPart()
                    local dist = myRoot and (root.Position - myRoot.Position).Magnitude or 0
                    
                    -- ESP Player
                    if State.ESPPlayer and (rootVisible or headVisible or legVisible) then
                        ESPDrawings[player].NameText.Position = Vector2.new(headPos.X, headPos.Y - 15)
                        ESPDrawings[player].NameText.Text = player.Name
                        ESPDrawings[player].NameText.Visible = true
                        
                        ESPDrawings[player].DistText.Position = Vector2.new(headPos.X, headPos.Y - 2)
                        ESPDrawings[player].DistText.Text = math.floor(dist) .. "m"
                        ESPDrawings[player].DistText.Visible = true
                    else
                        ESPDrawings[player].NameText.Visible = false
                        ESPDrawings[player].DistText.Visible = false
                    end
                    
                    -- ESP Box
                    if State.ESPBox and (rootVisible or headVisible or legVisible) then
                        local boxTop = headPos.Y - 5
                        local boxBottom = legPos.Y + 5
                        local boxLeft = rootPos.X - (boxBottom - boxTop) * 0.3
                        local boxRight = rootPos.X + (boxBottom - boxTop) * 0.3
                        
                        local lines = ESPDrawings[player].BoxLines
                        -- Top
                        lines[1].From = Vector2.new(boxLeft, boxTop)
                        lines[1].To = Vector2.new(boxRight, boxTop)
                        lines[1].Visible = true
                        -- Bottom
                        lines[2].From = Vector2.new(boxLeft, boxBottom)
                        lines[2].To = Vector2.new(boxRight, boxBottom)
                        lines[2].Visible = true
                        -- Left
                        lines[3].From = Vector2.new(boxLeft, boxTop)
                        lines[3].To = Vector2.new(boxLeft, boxBottom)
                        lines[3].Visible = true
                        -- Right
                        lines[4].From = Vector2.new(boxRight, boxTop)
                        lines[4].To = Vector2.new(boxRight, boxBottom)
                        lines[4].Visible = true
                    else
                        for _, l in pairs(ESPDrawings[player].BoxLines) do l.Visible = false end
                    end
                    
                    -- ESP Tracer
                    if State.ESPTracer and (rootVisible or headVisible or legVisible) then
                        local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                        ESPDrawings[player].TracerLine.From = screenCenter
                        ESPDrawings[player].TracerLine.To = Vector2.new(rootPos.X, legPos.Y)
                        ESPDrawings[player].TracerLine.Visible = true
                    else
                        ESPDrawings[player].TracerLine.Visible = false
                    end
                    
                    -- ESP Skeleton
                    if State.ESPSkeleton then
                        local isR15 = char:FindFirstChild("UpperTorso") ~= nil
                        local connections = isR15 and SkeletonConnections.R15 or SkeletonConnections.R6
                        
                        for i, conn in pairs(connections) do
                            local part1 = char:FindFirstChild(conn[2])
                            local part2 = char:FindFirstChild(conn[3])
                            
                            if part1 and part2 then
                                local p1, v1 = Camera:WorldToScreenPoint(part1.Position)
                                local p2, v2 = Camera:WorldToScreenPoint(part2.Position)
                                
                                if (v1 or v2) and ESPDrawings[player].SkelLines[i] then
                                    ESPDrawings[player].SkelLines[i].From = Vector2.new(p1.X, p1.Y)
                                    ESPDrawings[player].SkelLines[i].To = Vector2.new(p2.X, p2.Y)
                                    ESPDrawings[player].SkelLines[i].Visible = true
                                end
                            end
                        end
                    else
                        for _, l in pairs(ESPDrawings[player].SkelLines) do l.Visible = false end
                    end
                else
                    -- Character dead or nil, hide all
                    if ESPDrawings[player] then
                        ESPDrawings[player].NameText.Visible = false
                        ESPDrawings[player].DistText.Visible = false
                        ESPDrawings[player].TracerLine.Visible = false
                        for _, l in pairs(ESPDrawings[player].BoxLines) do l.Visible = false end
                        for _, l in pairs(ESPDrawings[player].SkelLines) do l.Visible = false end
                    end
                end
            end
        end
    end)
end

local function InitESP()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then CreatePlayerDrawings(p) end
    end
    
    Players.PlayerAdded:Connect(function(p)
        CreatePlayerDrawings(p)
    end)
    
    Players.PlayerRemoving:Connect(function(p)
        ClearPlayerESP(p)
    end)
    
    StartESPUpdate()
end

local function ToggleESPPlayer(enable) State.ESPPlayer = enable end
local function ToggleESPBox(enable) State.ESPBox = enable end
local function ToggleESPTracer(enable) State.ESPTracer = enable end
local function ToggleESPSkeleton(enable) State.ESPSkeleton = enable end

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

local function StartLoopGoto(targetPlayer, interval)
    State.LoopGotoActive = true
    spawn(function()
        while State.LoopGotoActive and targetPlayer and targetPlayer.Character do
            TeleportToPlayer(targetPlayer)
            wait(interval)
        end
    end)
end

local function StopLoopGoto()
    State.LoopGotoActive = false
end

local function GiveTpTool()
    local char = GetCharacter()
    if not char then return end
    
    -- Remove existing TpTool
    local existing = char:FindFirstChild("TpTool")
    if existing then existing:Destroy() end
    
    local tool = Instance.new("Tool")
    tool.Name = "TpTool"
    tool.RequiresHandle = false
    tool.CanBeDropped = false
    
    tool.Activated:Connect(function()
        local mouse = LocalPlayer:GetMouse()
        if mouse.Hit then
            local root = GetRootPart()
            if root then root.CFrame = mouse.Hit + Vector3.new(0, 3, 0) end
        end
    end)
    
    tool.Parent = char
end

-- ============================================
-- MISC FEATURES
-- ============================================

local freecamActive = false
local function ToggleFreecam(enable)
    State.Freecam = enable
    local root = GetRootPart()
    
    if enable then
        if root then root.Anchored = true end
        
        spawn(function()
            while State.Freecam do
                local speed = State.FreecamSpeed
                local cf = Camera.CFrame
                
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then cf = cf + cf.LookVector * speed end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then cf = cf - cf.LookVector * speed end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then cf = cf - cf.RightVector * speed end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then cf = cf + cf.RightVector * speed end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then cf = cf + Vector3.new(0, speed, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then cf = cf - Vector3.new(0, speed, 0) end
                
                Camera.CFrame = cf
                RunService.RenderStepped:Wait()
            end
        end)
    else
        if root then root.Anchored = false end
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
        Lighting.Ambient = Color3.fromRGB(0, 0, 0)
        Lighting.OutdoorAmbient = Color3.fromRGB(0, 0, 0)
    end
end

local fogBackup
local function ToggleRemoveFog(enable)
    State.RemoveFog = enable
    if enable then
        fogBackup = {FogEnd = Lighting.FogEnd, FogStart = Lighting.FogStart, FogColor = Lighting.FogColor}
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
                graphicsBackup[obj] = {Material = obj.Material, Color = obj.Color}
                obj.Material = Enum.Material.SmoothPlastic
                obj.Color = Color3.fromRGB(128, 128, 128)
            elseif obj:IsA("Texture") or obj:IsA("Decal") then
                graphicsBackup[obj] = {Transparency = obj.Transparency}
                obj.Transparency = 1
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
                graphicsBackup[obj] = {Enabled = obj.Enabled}
                obj.Enabled = false
            end
        end
    else
        for obj, data in pairs(graphicsBackup) do
            if obj and obj.Parent then
                pcall(function()
                    if obj:IsA("BasePart") then obj.Material = data.Material obj.Color = data.Color
                    elseif obj:IsA("Texture") or obj:IsA("Decal") then obj.Transparency = data.Transparency
                    elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then obj.Enabled = data.Enabled end
                end)
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

pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- Calculate safe position
local viewportSize = Camera.ViewportSize
local guiWidth, guiHeight = 460, 380
local guiX = math.clamp((viewportSize.X - guiWidth) / 2, 10, viewportSize.X - guiWidth - 10)
local guiY = math.clamp((viewportSize.Y - guiHeight) / 2, 10, viewportSize.Y - guiHeight - 10)

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, guiWidth, 0, guiHeight)
MainFrame.Position = UDim2.new(0, guiX, 0, guiY)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 8)
mainCorner.Parent = MainFrame

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, -40, 0, 28)
TitleBar.Position = UDim2.new(0, 40, 0, 0)
TitleBar.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -60, 1, 0)
TitleLabel.Position = UDim2.new(0, 8, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "FALLEN S.V"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 13
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

-- Minimize Button
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 26, 0, 26)
MinimizeBtn.Position = UDim2.new(1, -56, 0, 1)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MinimizeBtn.BorderSizePixel = 0
MinimizeBtn.Text = "—"
MinimizeBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 12
MinimizeBtn.Parent = TitleBar

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 4)
minCorner.Parent = MinimizeBtn

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 26, 0, 26)
CloseBtn.Position = UDim2.new(1, -28, 0, 1)
CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 11
CloseBtn.Parent = TitleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 4)
closeCorner.Parent = CloseBtn

-- ============================================
-- LEFT SIDEBAR
-- ============================================
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 40, 1, 0)
Sidebar.Position = UDim2.new(0, 0, 0, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local sidebarCorner = Instance.new("UICorner")
sidebarCorner.CornerRadius = UDim.new(0, 8)
sidebarCorner.Parent = Sidebar

local sidebarLayout = Instance.new("UIListLayout")
sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
sidebarLayout.Padding = UDim.new(0, 4)
sidebarLayout.Parent = Sidebar

local sidebarPadding = Instance.new("UIPadding")
sidebarPadding.PaddingTop = UDim.new(0, 8)
sidebarPadding.PaddingLeft = UDim.new(0, 4)
sidebarPadding.PaddingRight = UDim.new(0, 4)
sidebarPadding.Parent = Sidebar

-- Sidebar Buttons Data
local Categories = {
    {Name = "Player", Icon = "👤", Order = 1},
    {Name = "ESP", Icon = "👁", Order = 2},
    {Name = "Teleport", Icon = "📍", Order = 3},
    {Name = "Misc", Icon = "⚙", Order = 4},
}

local SidebarButtons = {}
local ContentFrames = {}
local ActiveCategory = "Player"

local function SwitchCategory(catName)
    ActiveCategory = catName
    for name, btn in pairs(SidebarButtons) do
        if name == catName then
            TweenService:Create(btn, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                BackgroundColor3 = Color3.fromRGB(40, 40, 48)
            }):Play()
        else
            TweenService:Create(btn, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                BackgroundColor3 = Color3.fromRGB(25, 25, 30)
            }):Play()
        end
    end
    for name, frame in pairs(ContentFrames) do
        frame.Visible = (name == catName)
    end
end

for _, cat in pairs(Categories) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -8, 0, 36)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    btn.BorderSizePixel = 0
    btn.Text = cat.Icon
    btn.TextSize = 18
    btn.Font = Enum.Font.Gotham
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.LayoutOrder = cat.Order
    btn.Parent = Sidebar
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        SwitchCategory(cat.Name)
    end)
    
    SidebarButtons[cat.Name] = btn
end

-- ============================================
-- CONTENT AREA
-- ============================================
local ContentArea = Instance.new("Frame")
ContentArea.Name = "ContentArea"
ContentArea.Size = UDim2.new(1, -40, 1, -28)
ContentArea.Position = UDim2.new(0, 40, 0, 28)
ContentArea.BackgroundTransparency = 1
ContentArea.BorderSizePixel = 0
ContentArea.Parent = MainFrame

-- Create content frames for each category
for _, cat in pairs(Categories) do
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = cat.Name .. "Content"
    scrollFrame.Size = UDim2.new(1, -8, 1, -8)
    scrollFrame.Position = UDim2.new(0, 4, 0, 4)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 3
    scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scrollFrame.Visible = (cat.Name == "Player")
    scrollFrame.Parent = ContentArea
    
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 3)
    layout.Parent = scrollFrame
    
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 4)
    padding.PaddingRight = UDim.new(0, 4)
    padding.PaddingTop = UDim.new(0, 4)
    padding.PaddingBottom = UDim.new(0, 4)
    padding.Parent = scrollFrame
    
    ContentFrames[cat.Name] = scrollFrame
end

-- ============================================
-- GUI COMPONENTS
-- ============================================

local function CreateSwitch(parent, name, order, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 28)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    frame.BorderSizePixel = 0
    frame.LayoutOrder = order
    frame.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Position = UDim2.new(0, 8, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.Font = Enum.Font.Gotham
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    -- Switch background
    local switchBg = Instance.new("Frame")
    switchBg.Size = UDim2.new(0, 36, 0, 18)
    switchBg.Position = UDim2.new(1, -44, 0.5, -9)
    switchBg.BackgroundColor3 = Color3.fromRGB(45, 45, 52)
    switchBg.BorderSizePixel = 0
    switchBg.Parent = frame
    
    local switchCorner = Instance.new("UICorner")
    switchCorner.CornerRadius = UDim.new(1, 0)
    switchCorner.Parent = switchBg
    
    -- Switch indicator
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 14, 0, 14)
    indicator.Position = UDim2.new(0, 2, 0, 2)
    indicator.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    indicator.BorderSizePixel = 0
    indicator.Parent = switchBg
    
    local indCorner = Instance.new("UICorner")
    indCorner.CornerRadius = UDim.new(1, 0)
    indCorner.Parent = indicator
    
    local enabled = false
    
    local function UpdateSwitch()
        local targetBgColor = enabled and Color3.fromRGB(0, 130, 90) or Color3.fromRGB(45, 45, 52)
        local targetIndPos = enabled and UDim2.new(0, 20, 0, 2) or UDim2.new(0, 2, 0, 2)
        local targetIndColor = enabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
        
        TweenService:Create(switchBg, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = targetBgColor
        }):Play()
        TweenService:Create(indicator, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = targetIndPos,
            BackgroundColor3 = targetIndColor
        }):Play()
    end
    
    switchBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            enabled = not enabled
            UpdateSwitch()
            callback(enabled)
        end
    end)
    
    return frame
end

local function CreateSwitchWithInput(parent, name, order, defaultVal, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 28)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    frame.BorderSizePixel = 0
    frame.LayoutOrder = order
    frame.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.35, 0, 1, 0)
    label.Position = UDim2.new(0, 8, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.Font = Enum.Font.Gotham
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local input = Instance.new("TextBox")
    input.Size = UDim2.new(0, 45, 0, 20)
    input.Position = UDim2.new(1, -94, 0.5, -10)
    input.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    input.BorderSizePixel = 0
    input.Text = tostring(defaultVal)
    input.TextColor3 = Color3.fromRGB(255, 255, 255)
    input.Font = Enum.Font.Gotham
    input.TextSize = 10
    input.PlaceholderText = "Num"
    input.Parent = frame
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 4)
    inputCorner.Parent = input
    
    -- Switch
    local switchBg = Instance.new("Frame")
    switchBg.Size = UDim2.new(0, 36, 0, 18)
    switchBg.Position = UDim2.new(1, -44, 0.5, -9)
    switchBg.BackgroundColor3 = Color3.fromRGB(45, 45, 52)
    switchBg.BorderSizePixel = 0
    switchBg.Parent = frame
    
    local switchCorner = Instance.new("UICorner")
    switchCorner.CornerRadius = UDim.new(1, 0)
    switchCorner.Parent = switchBg
    
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 14, 0, 14)
    indicator.Position = UDim2.new(0, 2, 0, 2)
    indicator.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    indicator.BorderSizePixel = 0
    indicator.Parent = switchBg
    
    local indCorner = Instance.new("UICorner")
    indCorner.CornerRadius = UDim.new(1, 0)
    indCorner.Parent = indicator
    
    local enabled = false
    
    local function UpdateSwitch()
        local targetBgColor = enabled and Color3.fromRGB(0, 130, 90) or Color3.fromRGB(45, 45, 52)
        local targetIndPos = enabled and UDim2.new(0, 20, 0, 2) or UDim2.new(0, 2, 0, 2)
        local targetIndColor = enabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
        
        TweenService:Create(switchBg, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = targetBgColor
        }):Play()
        TweenService:Create(indicator, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = targetIndPos,
            BackgroundColor3 = targetIndColor
        }):Play()
    end
    
    input.FocusLost:Connect(function()
        local num = tonumber(input.Text)
        if num then callback(enabled, num) end
    end)
    
    switchBg.InputBegan:Connect(function(inputEvent)
        if inputEvent.UserInputType == Enum.UserInputType.MouseButton1 or inputEvent.UserInputType == Enum.UserInputType.Touch then
            enabled = not enabled
            UpdateSwitch()
            local num = tonumber(input.Text) or defaultVal
            callback(enabled, num)
        end
    end)
    
    return frame
end

-- ============================================
-- POPULATE CATEGORIES
-- ============================================

-- PLAYER
local playerFrame = ContentFrames["Player"]
CreateSwitchWithInput(playerFrame, "Speed", 1, 50, function(on, val) State.Speed1Value = val ToggleSpeed1(on) end)
CreateSwitchWithInput(playerFrame, "Speed2", 2, 50, function(on, val) State.Speed2Value = val ToggleSpeed2(on) end)
CreateSwitchWithInput(playerFrame, "Fly", 3, 50, function(on, val) State.Fly1Speed = val ToggleFly1(on) end)
CreateSwitchWithInput(playerFrame, "Fly2", 4, 50, function(on, val) State.Fly2Speed = val ToggleFly2(on) end)
CreateSwitch(playerFrame, "Infinite Jump", 5, ToggleInfiniteJump)
CreateSwitch(playerFrame, "Swim Fly", 6, ToggleSwimFly)
CreateSwitchWithInput(playerFrame, "Jump Power", 7, 100, function(on, val) State.JumpPower1Value = val ToggleJumpPower1(on) end)
CreateSwitchWithInput(playerFrame, "Jump Power2", 8, 100, function(on, val) State.JumpPower2Value = val ToggleJumpPower2(on) end)
CreateSwitch(playerFrame, "Noclip", 9, ToggleNoclip)

-- ESP
local espFrame = ContentFrames["ESP"]
CreateSwitch(espFrame, "Chams", 1, ToggleChams1)
CreateSwitch(espFrame, "Chams2", 2, ToggleChams2)
CreateSwitch(espFrame, "Xray", 3, ToggleXray)
CreateSwitch(espFrame, "ESP Player", 4, ToggleESPPlayer)
CreateSwitch(espFrame, "ESP Box", 5, ToggleESPBox)
CreateSwitch(espFrame, "ESP Tracer", 6, ToggleESPTracer)
CreateSwitch(espFrame, "ESP Skeleton", 7, ToggleESPSkeleton)

-- TELEPORT
local tpFrame = ContentFrames["Teleport"]

-- Goto Section
local gotoFrame = Instance.new("Frame")
gotoFrame.Size = UDim2.new(1, 0, 0, 55)
gotoFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
gotoFrame.BorderSizePixel = 0
gotoFrame.LayoutOrder = 1
gotoFrame.Parent = tpFrame

local gotoCorner = Instance.new("UICorner")
gotoCorner.CornerRadius = UDim.new(0, 4)
gotoCorner.Parent = gotoFrame

local gotoLabel = Instance.new("TextLabel")
gotoLabel.Size = UDim2.new(1, -16, 0, 18)
gotoLabel.Position = UDim2.new(0, 8, 0, 4)
gotoLabel.BackgroundTransparency = 1
gotoLabel.Text = "Goto Player"
gotoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
gotoLabel.Font = Enum.Font.Gotham
gotoLabel.TextSize = 11
gotoLabel.TextXAlignment = Enum.TextXAlignment.Left
gotoLabel.Parent = gotoFrame

local gotoDropdown = Instance.new("TextButton")
gotoDropdown.Size = UDim2.new(0.65, -12, 0, 24)
gotoDropdown.Position = UDim2.new(0, 8, 0, 24)
gotoDropdown.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
gotoDropdown.BorderSizePixel = 0
gotoDropdown.Text = "Select Player"
gotoDropdown.TextColor3 = Color3.fromRGB(180, 180, 180)
gotoDropdown.Font = Enum.Font.Gotham
gotoDropdown.TextSize = 10
gotoDropdown.Parent = gotoFrame

local ddCorner = Instance.new("UICorner")
ddCorner.CornerRadius = UDim.new(0, 4)
ddCorner.Parent = gotoDropdown

local gotoTeleBtn = Instance.new("TextButton")
gotoTeleBtn.Size = UDim2.new(0.35, -8, 0, 24)
gotoTeleBtn.Position = UDim2.new(0.65, 0, 0, 24)
gotoTeleBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
gotoTeleBtn.BorderSizePixel = 0
gotoTeleBtn.Text = "Teleport"
gotoTeleBtn.TextColor3 = Color3.fromRGB(18, 18, 22)
gotoTeleBtn.Font = Enum.Font.GothamBold
gotoTeleBtn.TextSize = 10
gotoTeleBtn.Parent = gotoFrame

local tpCorner = Instance.new("UICorner")
tpCorner.CornerRadius = UDim.new(0, 4)
tpCorner.Parent = gotoTeleBtn

-- Dropdown list
local gotoListFrame = Instance.new("Frame")
gotoListFrame.Size = UDim2.new(0.65, -12, 0, 0)
gotoListFrame.Position = UDim2.new(0, 8, 0, 48)
gotoListFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
gotoListFrame.BorderSizePixel = 0
gotoListFrame.ClipsDescendants = true
gotoListFrame.Visible = false
gotoListFrame.ZIndex = 50
gotoListFrame.Parent = gotoFrame

local gotoListLayout = Instance.new("UIListLayout")
gotoListLayout.SortOrder = Enum.SortOrder.LayoutOrder
gotoListLayout.Parent = gotoListFrame

local selectedGotoPlayer = nil

local function RefreshGotoList()
    for _, child in pairs(gotoListFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    local order = 1
    for _, p in pairs(GetOtherPlayers()) do
        if p.Character then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 20)
            btn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            btn.BorderSizePixel = 0
            btn.Text = p.Name
            btn.TextColor3 = Color3.fromRGB(200, 200, 200)
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 10
            btn.LayoutOrder = order
            btn.ZIndex = 51
            btn.Parent = gotoListFrame
            
            btn.MouseButton1Click:Connect(function()
                selectedGotoPlayer = p
                gotoDropdown.Text = p.Name
                gotoListFrame.Visible = false
            end)
            order = order + 1
        end
    end
end

gotoDropdown.MouseButton1Click:Connect(function()
    RefreshGotoList()
    gotoListFrame.Visible = not gotoListFrame.Visible
end)

gotoTeleBtn.MouseButton1Click:Connect(function()
    if selectedGotoPlayer then TeleportToPlayer(selectedGotoPlayer) end
end)

-- Loop Goto Section
local loopFrame = Instance.new("Frame")
loopFrame.Size = UDim2.new(1, 0, 0, 80)
loopFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
loopFrame.BorderSizePixel = 0
loopFrame.LayoutOrder = 2
loopFrame.Parent = tpFrame

local loopCorner = Instance.new("UICorner")
loopCorner.CornerRadius = UDim.new(0, 4)
loopCorner.Parent = loopFrame

local loopLabel = Instance.new("TextLabel")
loopLabel.Size = UDim2.new(1, -16, 0, 18)
loopLabel.Position = UDim2.new(0, 8, 0, 4)
loopLabel.BackgroundTransparency = 1
loopLabel.Text = "Loop Goto"
loopLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
loopLabel.Font = Enum.Font.Gotham
loopLabel.TextSize = 11
loopLabel.TextXAlignment = Enum.TextXAlignment.Left
loopLabel.Parent = loopFrame

local loopDropdown = Instance.new("TextButton")
loopDropdown.Size = UDim2.new(0.45, -10, 0, 24)
loopDropdown.Position = UDim2.new(0, 8, 0, 24)
loopDropdown.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
loopDropdown.BorderSizePixel = 0
loopDropdown.Text = "Select"
loopDropdown.TextColor3 = Color3.fromRGB(180, 180, 180)
loopDropdown.Font = Enum.Font.Gotham
loopDropdown.TextSize = 10
loopDropdown.Parent = loopFrame

local lddCorner = Instance.new("UICorner")
lddCorner.CornerRadius = UDim.new(0, 4)
lddCorner.Parent = loopDropdown

local loopIntervalInput = Instance.new("TextBox")
loopIntervalInput.Size = UDim2.new(0.25, -8, 0, 24)
loopIntervalInput.Position = UDim2.new(0.45, 0, 0, 24)
loopIntervalInput.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
loopIntervalInput.BorderSizePixel = 0
loopIntervalInput.Text = "1"
loopIntervalInput.TextColor3 = Color3.fromRGB(255, 255, 255)
loopIntervalInput.Font = Enum.Font.Gotham
loopIntervalInput.TextSize = 10
loopIntervalInput.PlaceholderText = "Sec"
loopIntervalInput.Parent = loopFrame

local liCorner = Instance.new("UICorner")
liCorner.CornerRadius = UDim.new(0, 4)
liCorner.Parent = loopIntervalInput

local loopStartBtn = Instance.new("TextButton")
loopStartBtn.Size = UDim2.new(0.3, -6, 0, 24)
loopStartBtn.Position = UDim2.new(0.7, 0, 0, 24)
loopStartBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
loopStartBtn.BorderSizePixel = 0
loopStartBtn.Text = "Loop"
loopStartBtn.TextColor3 = Color3.fromRGB(18, 18, 22)
loopStartBtn.Font = Enum.Font.GothamBold
loopStartBtn.TextSize = 10
loopStartBtn.Parent = loopFrame

local lsCorner = Instance.new("UICorner")
lsCorner.CornerRadius = UDim.new(0, 4)
lsCorner.Parent = loopStartBtn

local loopStopBtn = Instance.new("TextButton")
loopStopBtn.Size = UDim2.new(1, -16, 0, 24)
loopStopBtn.Position = UDim2.new(0, 8, 0, 52)
loopStopBtn.BackgroundColor3 = Color3.fromRGB(160, 40, 40)
loopStopBtn.BorderSizePixel = 0
loopStopBtn.Text = "Stop Loop"
loopStopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
loopStopBtn.Font = Enum.Font.GothamBold
loopStopBtn.TextSize = 10
loopStopBtn.Parent = loopFrame

local lstCorner = Instance.new("UICorner")
lstCorner.CornerRadius = UDim.new(0, 4)
lstCorner.Parent = loopStopBtn

-- Loop dropdown list
local loopListFrame = Instance.new("Frame")
loopListFrame.Size = UDim2.new(0.45, -10, 0, 0)
loopListFrame.Position = UDim2.new(0, 8, 0, 48)
loopListFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
loopListFrame.BorderSizePixel = 0
loopListFrame.ClipsDescendants = true
loopListFrame.Visible = false
loopListFrame.ZIndex = 50
loopListFrame.Parent = loopFrame

local loopListLayout = Instance.new("UIListLayout")
loopListLayout.SortOrder = Enum.SortOrder.LayoutOrder
loopListLayout.Parent = loopListFrame

local selectedLoopPlayer = nil

local function RefreshLoopList()
    for _, child in pairs(loopListFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    local order = 1
    for _, p in pairs(GetOtherPlayers()) do
        if p.Character then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 20)
            btn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            btn.BorderSizePixel = 0
            btn.Text = p.Name
            btn.TextColor3 = Color3.fromRGB(200, 200, 200)
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 10
            btn.LayoutOrder = order
            btn.ZIndex = 51
            btn.Parent = loopListFrame
            btn.MouseButton1Click:Connect(function()
                selectedLoopPlayer = p
                loopDropdown.Text = p.Name
                loopListFrame.Visible = false
            end)
            order = order + 1
        end
    end
end

loopDropdown.MouseButton1Click:Connect(function()
    RefreshLoopList()
    loopListFrame.Visible = not loopListFrame.Visible
end)

loopStartBtn.MouseButton1Click:Connect(function()
    if selectedLoopPlayer then
        StopLoopGoto()
        local interval = tonumber(loopIntervalInput.Text) or 1
        StartLoopGoto(selectedLoopPlayer, interval)
    end
end)

loopStopBtn.MouseButton1Click:Connect(function()
    StopLoopGoto()
end)

-- TpTool Button
local tptoolFrame = Instance.new("Frame")
tptoolFrame.Size = UDim2.new(1, 0, 0, 32)
tptoolFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
tptoolFrame.BorderSizePixel = 0
tptoolFrame.LayoutOrder = 3
tptoolFrame.Parent = tpFrame

local ttCorner = Instance.new("UICorner")
ttCorner.CornerRadius = UDim.new(0, 4)
ttCorner.Parent = tptoolFrame

local tptoolBtn = Instance.new("TextButton")
tptoolBtn.Size = UDim2.new(1, -16, 0, 24)
tptoolBtn.Position = UDim2.new(0, 8, 0, 4)
tptoolBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
tptoolBtn.BorderSizePixel = 0
tptoolBtn.Text = "Give TpTool"
tptoolBtn.TextColor3 = Color3.fromRGB(18, 18, 22)
tptoolBtn.Font = Enum.Font.GothamBold
tptoolBtn.TextSize = 11
tptoolBtn.Parent = tptoolFrame

local ttbCorner = Instance.new("UICorner")
ttbCorner.CornerRadius = UDim.new(0, 4)
ttbCorner.Parent = tptoolBtn

tptoolBtn.MouseButton1Click:Connect(GiveTpTool)

-- MISC
local miscFrame = ContentFrames["Misc"]
CreateSwitchWithInput(miscFrame, "Freecam", 1, 1, function(on, val) State.FreecamSpeed = val ToggleFreecam(on) end)
CreateSwitch(miscFrame, "Fullbright", 2, ToggleFullbright)
CreateSwitch(miscFrame, "Remove Fog", 3, ToggleRemoveFog)
CreateSwitch(miscFrame, "Low Graphics", 4, ToggleLowGraphics)

-- ============================================
-- MINIMIZED ICON
-- ============================================
local MinIcon = Instance.new("TextButton")
MinIcon.Name = "MinIcon"
MinIcon.Size = UDim2.new(0, 45, 0, 45)
MinIcon.Position = UDim2.new(0, 10, 0, 10)
MinIcon.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
MinIcon.BorderSizePixel = 0
MinIcon.Text = "🌃"
MinIcon.TextSize = 24
MinIcon.Visible = false
MinIcon.Parent = ScreenGui

local minIconCorner = Instance.new("UICorner")
minIconCorner.CornerRadius = UDim.new(0, 8)
minIconCorner.Parent = MinIcon

-- ============================================
-- DRAGGING
-- ============================================
local function MakeDraggable(dragPart, frame)
    local dragging = false
    local dragInput, dragStart, startPos
    
    dragPart.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
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
    
    dragPart.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

MakeDraggable(TitleBar, MainFrame)
MakeDraggable(MinIcon, MinIcon)

-- ============================================
-- RESIZE HANDLE
-- ============================================
local resizeHandle = Instance.new("TextButton")
resizeHandle.Size = UDim2.new(0, 16, 0, 16)
resizeHandle.Position = UDim2.new(1, -16, 1, -16)
resizeHandle.BackgroundTransparency = 1
resizeHandle.Text = "⇲"
resizeHandle.TextColor3 = Color3.fromRGB(100, 100, 100)
resizeHandle.TextSize = 12
resizeHandle.Parent = MainFrame

local isResizing = false
local resizeStartPos, resizeStartSize

resizeHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isResizing = true
        resizeStartPos = input.Position
        resizeStartSize = MainFrame.Size
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isResizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - resizeStartPos
        local newWidth = math.clamp(resizeStartSize.X.Offset + delta.X, 300, 700)
        local newHeight = math.clamp(resizeStartSize.Y.Offset + delta.Y, 250, 600)
        MainFrame.Size = UDim2.new(0, newWidth, 0, newHeight)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isResizing = false
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
    -- Cleanup
    if noclipConn then noclipConn:Disconnect() end
    if infJumpConn then infJumpConn:Disconnect() end
    if espUpdateConn then espUpdateConn:Disconnect() end
    if flyBV then flyBV:Destroy() end
    if flyBG then flyBG:Destroy() end
    if swimBV then swimBV:Destroy() end
    StopLoopGoto()
    
    -- Reset features
    ToggleSpeed1(false)
    ToggleFly1(false)
    ToggleNoclip(false)
    ToggleFreecam(false)
    ToggleFullbright(false)
    ToggleRemoveFog(false)
    ToggleLowGraphics(false)
    ToggleXray(false)
    
    -- Clear ESP drawings
    for _, player in pairs(Players:GetPlayers()) do
        ClearPlayerESP(player)
    end
    
    ScreenGui:Destroy()
end)

-- ============================================
-- INIT
-- ============================================

-- Initialize ESP system
InitESP()

-- Set initial active category
SwitchCategory("Player")

-- Notification
local notifFrame = Instance.new("Frame")
notifFrame.Size = UDim2.new(0, 220, 0, 36)
notifFrame.Position = UDim2.new(0.5, -110, 0, 8)
notifFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
notifFrame.BorderSizePixel = 0
notifFrame.Parent = ScreenGui

local notifCorner = Instance.new("UICorner")
notifCorner.CornerRadius = UDim.new(0, 6)
notifCorner.Parent = notifFrame

local notifLabel = Instance.new("TextLabel")
notifLabel.Size = UDim2.new(1, -16, 1, 0)
notifLabel.Position = UDim2.new(0, 8, 0, 0)
notifLabel.BackgroundTransparency = 1
notifLabel.Text = "FALLEN S.V | Loaded ⚡"
notifLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
notifLabel.Font = Enum.Font.GothamBold
notifLabel.TextSize = 12
notifLabel.Parent = notifFrame

spawn(function()
    wait(3)
    local tween = TweenService:Create(notifFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -110, 0, -50)
    })
    tween:Play()
    tween.Completed:Connect(function() notifFrame:Destroy() end)
end)
