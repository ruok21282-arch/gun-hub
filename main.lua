-- GuN HUB V2 - TEMA NEVE (FIX: TRAVADINHAS E AUTO-SPEED CORRIGIDOS)
local IMAGE_ID = "rbxassetid://86608309240586"

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local Stats = game:GetService("Stats")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- MOTOR SPEED HACK (FIX DA VELOCIDADE ORIGINAL)
-- ==========================================
getgenv().speed = {
    enabled = false,     
    speed = 16,        
    control = false,
    friction = 2.0,    
    keybind = Enum.KeyCode.KeypadDivide 
}

local speed = getgenv().speed 
local enginePlayer = game.Players.LocalPlayer
local originalWalkSpeed = nil

local function setSpeed(player, speedValue)
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = speedValue
    end
end

local function enhanceControl(player, reset)
    local character = player.Character or player.CharacterAdded:Wait()
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        if reset then
            rootPart.CustomPhysicalProperties = nil
        else
            rootPart.CustomPhysicalProperties = PhysicalProperties.new(0.7, speed.friction, 0.5, 1.0, 0.5)
        end
    end
end

local function applySpeedBoost(player)
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    if originalWalkSpeed == nil then
        originalWalkSpeed = humanoid.WalkSpeed
    end

    if speed.enabled then
        setSpeed(player, speed.speed)
        if speed.control then
            enhanceControl(player, false)
        end
    else
        setSpeed(player, originalWalkSpeed)
        if speed.control then
            enhanceControl(player, true)
        end
    end
end

local function toggleSpeedBoost()
    speed.enabled = not speed.enabled
    applySpeedBoost(enginePlayer)
end

if enginePlayer.Character then applySpeedBoost(enginePlayer) end
enginePlayer.CharacterAdded:Connect(function() applySpeedBoost(enginePlayer) end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == speed.keybind then
        toggleSpeedBoost()
    end
end)

RunService.RenderStepped:Connect(function()
    if speed.enabled then
        setSpeed(enginePlayer, speed.speed)
    end
end)

-- ==========================================
-- VARIÁVEIS GLOBAIS DO HUB
-- ==========================================
local AIMBOT_ENABLED = false
local FOV_RADIUS = 120 
local SMOOTHNESS = 0.2 
local AIM_PART = "Head"
local VISIBLE_CHECK = false
local ESP_ENABLED = false
local MAX_ESP_DISTANCE = 500
local SHOW_FOV_VISUAL = false
local STICKY_AIM = false
local SHOW_STATS = true
local TEAM_CHECK = false 
local FLY_ENABLED = false
local FLY_SPEED = 50
local NOCLIP_ENABLED = false
local INF_JUMP_ENABLED = false

-- NOVAS VARIÁVEIS DA ABA "AIM RISK" (apenas interface, não interferem no motor)
local AIM_RISK_ENABLED = false
local AIM_RISK_FORCE = false

local isAimingToggle = false
local bv, bg = nil, nil
local ESP_Objects = {}
local currentTouches = {}

-- ==========================================
-- FUNÇÕES DE MOTOR HUB (FIX DE FÍSICA)
-- ==========================================
local function IsVisible(TargetPart)
    if not VISIBLE_CHECK then return true end
    local char = LocalPlayer.Character
    if not char then return false end
    local RayParams = RaycastParams.new()
    RayParams.FilterType = Enum.RaycastFilterType.Exclude
    RayParams.FilterDescendantsInstances = {char, TargetPart.Parent, Camera}
    local Direction = (TargetPart.Position - Camera.CFrame.Position).Unit * (TargetPart.Position - Camera.CFrame.Position).Magnitude
    local RayResult = workspace:Raycast(Camera.CFrame.Position, Direction, RayParams)
    return RayResult == nil
end

local function CleanForces()
    local char = LocalPlayer.Character
    if not char then return end
    for _, v in pairs(char:GetDescendants()) do
        if v:IsA("BodyVelocity") or v:IsA("BodyGyro") or v:IsA("BodyPosition") then
            v:Destroy()
        end
    end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then 
        hum.PlatformStand = false 
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
end

local function ToggleFly(state)
    FLY_ENABLED = state
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end
    if FLY_ENABLED then
        bv = Instance.new("BodyVelocity", hrp); bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge); bv.Velocity = Vector3.new(0, 0.1, 0)
        bg = Instance.new("BodyGyro", hrp); bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge); bg.CFrame = hrp.CFrame
        hum.PlatformStand = true
    else
        CleanForces()
        bv = nil
        bg = nil
    end
end

UserInputService.JumpRequest:Connect(function()
    if INF_JUMP_ENABLED then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and hum:GetState() ~= Enum.HumanoidStateType.Dead then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end
end)

-- ==========================================
-- INTERFACE (ESTILO SNOW ORIGINAL)
-- ==========================================
local SNOW_BLUE = Color3.fromRGB(173, 216, 230)
local SNOW_WHITE = Color3.fromRGB(255, 255, 255)
local BTN_COLOR = Color3.fromRGB(140, 190, 210)

local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
ScreenGui.Name = "GuNHub_Snow_V2_Unified"
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 380, 0, 280); MainFrame.Position = UDim2.new(0.5, -190, 0.5, -140); MainFrame.BackgroundColor3 = SNOW_BLUE; MainFrame.Active = true; MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 15)
local MainStroke = Instance.new("UIStroke", MainFrame); MainStroke.Thickness = 4; MainStroke.Color = SNOW_WHITE

local BackgroundImg = Instance.new("ImageLabel", MainFrame); BackgroundImg.Size = UDim2.new(1, 0, 1, 0); BackgroundImg.Image = IMAGE_ID; BackgroundImg.ImageTransparency = 0.7; BackgroundImg.BackgroundTransparency = 1; BackgroundImg.ScaleType = Enum.ScaleType.Crop; Instance.new("UICorner", BackgroundImg).CornerRadius = UDim.new(0, 15)

local Header = Instance.new("Frame", MainFrame); Header.Size = UDim2.new(1, 0, 0, 35); Header.BackgroundColor3 = SNOW_WHITE; Header.BackgroundTransparency = 0.8
local Title = Instance.new("TextLabel", Header); Title.Size = UDim2.new(0.5, 0, 1, 0); Title.Position = UDim2.new(0, 15, 0, 0); Title.Text = "GuN HUB SNOW"; Title.Font = Enum.Font.GothamBold; Title.TextColor3 = SNOW_WHITE; Title.BackgroundTransparency = 1; Title.TextXAlignment = Enum.TextXAlignment.Left; Title.TextSize = 18
local StatsLabel = Instance.new("TextLabel", Header); StatsLabel.Size = UDim2.new(0.5, 0, 1, 0); StatsLabel.Position = UDim2.new(0.45, 0, 0, 0); StatsLabel.Text = "FPS: 0 | PING: 0ms"; StatsLabel.Font = Enum.Font.GothamMedium; StatsLabel.TextColor3 = SNOW_WHITE; StatsLabel.BackgroundTransparency = 1; StatsLabel.TextXAlignment = Enum.TextXAlignment.Right; StatsLabel.TextSize = 12

local TabFrame = Instance.new("Frame", MainFrame); TabFrame.Size = UDim2.new(0, 90, 1, -35); TabFrame.Position = UDim2.new(0, 0, 0, 35); TabFrame.BackgroundTransparency = 0.9; TabFrame.BackgroundColor3 = SNOW_WHITE

local Content = Instance.new("Frame", MainFrame); Content.Size = UDim2.new(1, -100, 1, -45); Content.Position = UDim2.new(0, 95, 0, 40); Content.BackgroundTransparency = 1

-- Páginas
local Pages = {
    Aim = Instance.new("Frame", Content),
    AimRisk = Instance.new("Frame", Content),
    ESP = Instance.new("Frame", Content),
    Safe = Instance.new("Frame", Content),
    Risk = Instance.new("Frame", Content),
    Config = Instance.new("Frame", Content)
}
for _, p in pairs(Pages) do
    p.Size = UDim2.new(1, 0, 1, 0)
    p.BackgroundTransparency = 1
    p.Visible = false
end
Pages.Aim.Visible = true

local UI_Elements = {}

local function AddInput(id, text, pos, default, parent, callback)
    local label = Instance.new("TextLabel", parent); label.Size = UDim2.new(1, 0, 0, 15); label.Position = UDim2.new(0, 0, 0, pos); label.Text = text; label.TextColor3 = SNOW_WHITE; label.TextSize = 10; label.Font = Enum.Font.GothamBold; label.BackgroundTransparency = 1; label.TextXAlignment = Enum.TextXAlignment.Left
    local box = Instance.new("TextBox", parent); box.Size = UDim2.new(0.95, 0, 0, 25); box.Position = UDim2.new(0, 0, 0, pos + 15); box.Text = tostring(default); box.BackgroundColor3 = SNOW_WHITE; box.BackgroundTransparency = 0.8; UI_Elements[id] = box; Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)
    box.FocusLost:Connect(function() local v = tonumber(box.Text); if v then callback(v) end end)
end

local function CreateToggle(id, text, pos, parent, callback)
    local btn = Instance.new("TextButton", parent); btn.Size = UDim2.new(0.95, 0, 0, 30); btn.Position = UDim2.new(0, 0, 0, pos); btn.BackgroundColor3 = BTN_COLOR; btn.Text = text; btn.TextColor3 = SNOW_WHITE; btn.Font = Enum.Font.GothamBold; btn.TextSize = 11; Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    UI_Elements[id] = btn
    btn.MouseButton1Click:Connect(function()
        local state = not (btn.BackgroundColor3 == SNOW_WHITE)
        btn.BackgroundColor3 = state and SNOW_WHITE or BTN_COLOR
        btn.TextColor3 = state and Color3.fromRGB(80,80,80) or SNOW_WHITE
        callback(state)
    end)
end

-- Aba AIMBOT (original)
AddInput("FOV", "RAIO DO FOV:", 0, FOV_RADIUS, Pages.Aim, function(v) FOV_RADIUS = v end)
AddInput("SMOOTH", "SUAVIDADE:", 45, SMOOTHNESS, Pages.Aim, function(v) SMOOTHNESS = v end)
CreateToggle("AIMON", "ATIVAR AIMBOT", 95, Pages.Aim, function(v) AIMBOT_ENABLED = v end)
CreateToggle("VISCHECK", "VISIBLE CHECK", 130, Pages.Aim, function(v) VISIBLE_CHECK = v end)
CreateToggle("SHOWFOV", "EXIBIR FOV VISUAL", 165, Pages.Aim, function(v) SHOW_FOV_VISUAL = v end)

-- Nova aba AIM RISK (adicionada com sucesso)
CreateToggle("AIMRISK_EN", "ATIVAR AIM RISK", 0, Pages.AimRisk, function(v) AIM_RISK_ENABLED = v end)
CreateToggle("AIMRISK_FORCE", "FORÇAR AIM (TESTE)", 40, Pages.AimRisk, function(v) AIM_RISK_FORCE = v end)

-- Aba ESP (original)
CreateToggle("ESPON", "ATIVAR ESP", 0, Pages.ESP, function(v) ESP_ENABLED = v end)
AddInput("ESPDIST", "DISTÂNCIA ESP:", 35, MAX_ESP_DISTANCE, Pages.ESP, function(v) MAX_ESP_DISTANCE = v end)
CreateToggle("TEAMCHK", "TEAM CHECK", 85, Pages.ESP, function(v) TEAM_CHECK = v end)

-- Aba SAFE (original)
CreateToggle("STICKY", "STICKY AIM", 0, Pages.Safe, function(v) STICKY_AIM = v end)

-- Aba RISK (original)
CreateToggle("FLYON", "ATIVAR FLY (OLZ)", 0, Pages.Risk, function(v) ToggleFly(v) end)
AddInput("FLYSPD", "VELOCIDADE FLY:", 35, FLY_SPEED, Pages.Risk, function(v) FLY_SPEED = v end)
CreateToggle("NOCLIP", "ATIVAR NOCLIP (LUNA)", 80, Pages.Risk, function(v) NOCLIP_ENABLED = v end)
CreateToggle("INFJUMP", "ATIVAR INF. JUMP", 115, Pages.Risk, function(v) INF_JUMP_ENABLED = v end)
CreateToggle("SPEEDON", "ATIVAR SPEED HACK", 150, Pages.Risk, function(v)
    speed.enabled = v
    applySpeedBoost(enginePlayer)
end)
AddInput("SPEEDVAL", "VELOCIDADE DO SPEED:", 185, speed.speed, Pages.Risk, function(v)
    speed.speed = v
    if speed.enabled then applySpeedBoost(enginePlayer) end
end)

-- Aba CONFIG (original)
CreateToggle("STATS", "EXIBIR FPS/PING", 0, Pages.Config, function(v) SHOW_STATS = v; StatsLabel.Visible = v end)

-- ==========================================
-- SISTEMA DE SAVE/LOAD
-- ==========================================
local function UpdatePanelVisuals()
    local function SetState(btn, state)
        if btn then
            btn.BackgroundColor3 = state and SNOW_WHITE or BTN_COLOR
            btn.TextColor3 = state and Color3.fromRGB(80,80,80) or SNOW_WHITE
        end
    end
    SetState(UI_Elements.AIMON, AIMBOT_ENABLED); SetState(UI_Elements.VISCHECK, VISIBLE_CHECK)
    SetState(UI_Elements.SHOWFOV, SHOW_FOV_VISUAL); SetState(UI_Elements.ESPON, ESP_ENABLED)
    SetState(UI_Elements.TEAMCHK, TEAM_CHECK); SetState(UI_Elements.STICKY, STICKY_AIM)
    SetState(UI_Elements.FLYON, FLY_ENABLED); SetState(UI_Elements.NOCLIP, NOCLIP_ENABLED)
    SetState(UI_Elements.INFJUMP, INF_JUMP_ENABLED); SetState(UI_Elements.STATS, SHOW_STATS)
    SetState(UI_Elements.SPEEDON, speed.enabled)
    SetState(UI_Elements.AIMRISK_EN, AIM_RISK_ENABLED)
    SetState(UI_Elements.AIMRISK_FORCE, AIM_RISK_FORCE)

    UI_Elements.FOV.Text = tostring(FOV_RADIUS)
    UI_Elements.SMOOTH.Text = tostring(SMOOTHNESS)
    UI_Elements.FLYSPD.Text = tostring(FLY_SPEED)
    UI_Elements.ESPDIST.Text = tostring(MAX_ESP_DISTANCE)
    UI_Elements.SPEEDVAL.Text = tostring(speed.speed)
end

local function SaveConfig()
    local data = {
        FOV = FOV_RADIUS, SMOOTH = SMOOTHNESS, AIM_ON = AIMBOT_ENABLED, VISIBLE = VISIBLE_CHECK,
        SHOW_FOV = SHOW_FOV_VISUAL, ESP_ON = ESP_ENABLED, ESP_DIST = MAX_ESP_DISTANCE,
        STICKY = STICKY_AIM, S_STATS = SHOW_STATS, T_CHECK = TEAM_CHECK,
        FLY_ON = FLY_ENABLED, FLY_SPD = FLY_SPEED, NOCLIP = NOCLIP_ENABLED,
        INF_JUMP = INF_JUMP_ENABLED, S_ON = speed.enabled, S_VAL = speed.speed,
        AIM_RISK_EN = AIM_RISK_ENABLED, AIM_RISK_FORCE = AIM_RISK_FORCE
    }
    writefile("GuNHub_Config.json", HttpService:JSONEncode(data))
end

local function LoadConfig()
    if isfile("GuNHub_Config.json") then
        local data = HttpService:JSONDecode(readfile("GuNHub_Config.json"))
        FOV_RADIUS = data.FOV; SMOOTHNESS = data.SMOOTH; AIMBOT_ENABLED = data.AIM_ON; VISIBLE_CHECK = data.VISIBLE
        SHOW_FOV_VISUAL = data.SHOW_FOV; ESP_ENABLED = data.ESP_ON; MAX_ESP_DISTANCE = data.ESP_DIST
        STICKY_AIM = data.STICKY; SHOW_STATS = data.S_STATS; TEAM_CHECK = data.T_CHECK
        FLY_ENABLED = data.FLY_ON; FLY_SPEED = data.FLY_SPD; NOCLIP_ENABLED = data.NOCLIP
        INF_JUMP_ENABLED = data.INF_JUMP or false
        speed.enabled = data.S_ON or false; speed.speed = data.S_VAL or 16
        AIM_RISK_ENABLED = data.AIM_RISK_EN or false
        AIM_RISK_FORCE = data.AIM_RISK_FORCE or false

        UpdatePanelVisuals(); ToggleFly(FLY_ENABLED); applySpeedBoost(enginePlayer)
    end
end

-- Botões de salvar/carregar (corrigidos)
local SBtn = Instance.new("TextButton", Pages.Config); SBtn.Size = UDim2.new(0.95, 0, 0, 35); SBtn.Position = UDim2.new(0, 0, 0, 40); SBtn.Text = "SALVAR CONFIG"; SBtn.BackgroundColor3 = SNOW_WHITE; SBtn.BackgroundTransparency = 0.5; SBtn.Font = Enum.Font.GothamBold; Instance.new("UICorner", SBtn); SBtn.MouseButton1Click:Connect(SaveConfig)
local LBtn = Instance.new("TextButton", Pages.Config); LBtn.Size = UDim2.new(0.95, 0, 0, 35); LBtn.Position = UDim2.new(0, 0, 0, 80); LBtn.Text = "CARREGAR CONFIG"; LBtn.BackgroundColor3 = SNOW_WHITE; LBtn.BackgroundTransparency = 0.5; LBtn.Font = Enum.Font.GothamBold; Instance.new("UICorner", LBtn); LBtn.MouseButton1Click:Connect(LoadConfig)

-- ==========================================
-- MOTORES DE RENDERIZAÇÃO E FÍSICA
-- ==========================================
local FOVCircle = Drawing.new("Circle"); FOVCircle.Thickness = 2; FOVCircle.Color = SNOW_WHITE; FOVCircle.Filled = false

local function CreateESP(p)
    if p == LocalPlayer then return end
    local box = Drawing.new("Square"); box.Thickness = 1.5; box.Color = Color3.new(1,1,1); box.Filled = false; box.Visible = false
    ESP_Objects[p] = {Box = box}
end
Players.PlayerAdded:Connect(CreateESP); for _, p in pairs(Players:GetPlayers()) do CreateESP(p) end

RunService.Stepped:Connect(function()
    if NOCLIP_ENABLED and LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
    end
end)

RunService.RenderStepped:Connect(function(dt)
    if SHOW_STATS then StatsLabel.Text = string.format("FPS: %d | PING: %dms", math.floor(1/dt), math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())) end
    FOVCircle.Radius = FOV_RADIUS; FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2); FOVCircle.Visible = SHOW_FOV_VISUAL

    if FLY_ENABLED and bv and bg and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum.MoveDirection.Magnitude > 0.1 then
            bv.Velocity = (Camera.CFrame.LookVector * (hum.MoveDirection:Dot(Camera.CFrame.LookVector) > 0 and 1 or -1) * FLY_SPEED)
            bg.CFrame = Camera.CFrame
        else
            bv.Velocity = Vector3.new(0, 0.1, 0)
        end
    end

    for p, v in pairs(ESP_Objects) do
        if ESP_ENABLED and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local root = p.Character.HumanoidRootPart; local pos, onS = Camera:WorldToViewportPoint(root.Position); local dist = (Camera.CFrame.Position - root.Position).Magnitude
            if onS and dist <= MAX_ESP_DISTANCE then
                local size = (Camera.ViewportSize.Y / dist) * 2.5
                v.Box.Size = Vector2.new(size * 0.6, size); v.Box.Position = Vector2.new(pos.X - v.Box.Size.X/2, pos.Y - v.Box.Size.Y/2); v.Box.Visible = true
            else v.Box.Visible = false end
        else v.Box.Visible = false end
    end

    if AIMBOT_ENABLED and isAimingToggle then
        local target = nil; local dist = FOV_RADIUS
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild(AIM_PART) and p.Character.Humanoid.Health > 0 then
                local pos, onS = Camera:WorldToViewportPoint(p.Character[AIM_PART].Position); local mag = (Vector2.new(pos.X, pos.Y) - FOVCircle.Position).Magnitude
                if onS and mag < dist and IsVisible(p.Character[AIM_PART]) then dist = mag; target = p end
            end
        end
        if target then Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Character[AIM_PART].Position), SMOOTHNESS) end
    end
end)

-- GESTO DE 3 TOQUES
UserInputService.TouchStarted:Connect(function(touch) currentTouches[touch] = true end)
UserInputService.TouchEnded:Connect(function(touch) currentTouches[touch] = nil end)
task.spawn(function()
    while true do
        local count = 0; for _ in pairs(currentTouches) do count = count + 1 end
        if count == 3 then
            local startTime = tick()
            while true do
                local currentCount = 0; for _ in pairs(currentTouches) do currentCount = currentCount + 1 end
                if currentCount < 3 then break end
                if tick() - startTime >= 1.5 then MainFrame.Visible = not MainFrame.Visible; break end
                task.wait()
            end
        end
        task.wait(0.1)
    end
end)

-- Criação das abas (corrigindo a ordem e posições)
local function makeTab(name, pos, page)
    local btn = Instance.new("TextButton", TabFrame)
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.Position = UDim2.new(0, 0, 0, pos)
    btn.Text = name
    btn.TextColor3 = SNOW_WHITE
    btn.BackgroundTransparency = 1
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do p.Visible = false end
        page.Visible = true
    end)
end

makeTab("AIMBOT", 0, Pages.Aim)
makeTab("AIM RISK", 40, Pages.AimR
