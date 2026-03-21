este script não está mais funcionando,This script is no longer working.

-- ID DA IMAGEM (MISIDE)
local IMAGE_ID = "rbxassetid://86608309240586"

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local Stats = game:GetService("Stats")
local Lighting = game:GetService("Lighting")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- CONFIGURAÇÕES GERAIS
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

-- VARIÁVEIS DE CONTROLE
local isAimingToggle = false
local lockedTarget = nil 

-- --- FUNÇÃO VISIBLE CHECK ---
local function IsVisible(TargetPart)
    if not VISIBLE_CHECK then return true end
    local char = LocalPlayer.Character
    if not char then return false end
    local RayParams = RaycastParams.new()
    RayParams.FilterType = Enum.RaycastFilterType.Exclude -- Atualizado para método moderno (Performance)
    RayParams.FilterDescendantsInstances = {char, TargetPart.Parent, Camera}
    local Direction = (TargetPart.Position - Camera.CFrame.Position).Unit * (TargetPart.Position - Camera.CFrame.Position).Magnitude
    local RayResult = workspace:Raycast(Camera.CFrame.Position, Direction, RayParams)
    return RayResult == nil
end

-- SISTEMA RGB
local function GetRGB()
    return Color3.fromHSV(tick() % 5 / 5, 1, 1)
end

-- INTERFACE PRINCIPAL
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
ScreenGui.Name = "GuNHub_Mobile"

-- --- BOTÃO LOCK ---
local AimButton = Instance.new("TextButton", ScreenGui)
AimButton.Size = UDim2.new(0, 65, 0, 65)
AimButton.Position = UDim2.new(0.8, 0, 0.5, 0)
AimButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
AimButton.Text = "OFF"
AimButton.TextColor3 = Color3.new(1, 1, 1)
AimButton.Font = Enum.Font.GothamBold
AimButton.TextSize = 14
AimButton.ZIndex = 10
AimButton.Draggable = true 

local ButtonCorner = Instance.new("UICorner", AimButton); ButtonCorner.CornerRadius = UDim.new(1, 0)
local ButtonStroke = Instance.new("UIStroke", AimButton); ButtonStroke.Thickness = 3; ButtonStroke.Color = Color3.new(1, 1, 1)

AimButton.MouseButton1Click:Connect(function()
    isAimingToggle = not isAimingToggle
    AimButton.BackgroundColor3 = isAimingToggle and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(200, 0, 0)
    AimButton.Text = isAimingToggle and "ON" or "OFF"
    if not isAimingToggle then lockedTarget = nil end 
end)

-- --- PAINEL ---
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 380, 0, 280)
MainFrame.Position = UDim2.new(0.5, -190, 0.5, -140)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true
MainFrame.Visible = true 

local MainCorner = Instance.new("UICorner", MainFrame); MainCorner.CornerRadius = UDim.new(0, 12)
local BackgroundImg = Instance.new("ImageLabel", MainFrame); BackgroundImg.Size = UDim2.new(1, 0, 1, 0); BackgroundImg.Image = IMAGE_ID; BackgroundImg.BackgroundTransparency = 0.5; BackgroundImg.ScaleType = Enum.ScaleType.Crop; BackgroundImg.ZIndex = 0
local MainStroke = Instance.new("UIStroke", MainFrame); MainStroke.Thickness = 3

-- HEADER
local Header = Instance.new("Frame", MainFrame); Header.Size = UDim2.new(1, 0, 0, 35); Header.BackgroundTransparency = 0.5; Header.BackgroundColor3 = Color3.new(0,0,0); Header.ZIndex = 2
local Title = Instance.new("TextLabel", Header); Title.Size = UDim2.new(0.5, 0, 1, 0); Title.Position = UDim2.new(0, 10, 0, 0); Title.Text = "GuN HUB V1"; Title.Font = Enum.Font.GothamBold; Title.TextSize = 18; Title.BackgroundTransparency = 1; Title.TextXAlignment = Enum.TextXAlignment.Left

local StatsLabel = Instance.new("TextLabel", Header); StatsLabel.Size = UDim2.new(0.5, 0, 1, 0); StatsLabel.Position = UDim2.new(0.45, 0, 0, 0); StatsLabel.Text = "FPS: 0 | PING: 0ms"; StatsLabel.Font = Enum.Font.GothamMedium; StatsLabel.TextSize = 12; StatsLabel.TextColor3 = Color3.new(1,1,1); StatsLabel.BackgroundTransparency = 1; StatsLabel.TextXAlignment = Enum.TextXAlignment.Right

-- NAVEGAÇÃO
local TabFrame = Instance.new("Frame", MainFrame); TabFrame.Size = UDim2.new(0, 80, 1, -35); TabFrame.Position = UDim2.new(0, 0, 0, 35); TabFrame.BackgroundTransparency = 0.7; TabFrame.BackgroundColor3 = Color3.new(0,0,0); TabFrame.ZIndex = 2

local function CreateTab(name, pos)
    local btn = Instance.new("TextButton", TabFrame); btn.Size = UDim2.new(1, 0, 0, 40); btn.Position = UDim2.new(0, 0, 0, pos); btn.Text = name; btn.TextColor3 = Color3.fromRGB(255, 105, 180); btn.BackgroundTransparency = 1; btn.Font = Enum.Font.GothamBold; btn.TextSize = 13
    return btn
end

local AimTab = CreateTab("AIMBOT", 0); local ESPTab = CreateTab("ESP", 40); local SafeTab = CreateTab("SAFE", 80); local ConfigTab = CreateTab("CONFIG", 120)

local Content = Instance.new("Frame", MainFrame); Content.Size = UDim2.new(1, -90, 1, -45); Content.Position = UDim2.new(0, 85, 0, 40); Content.BackgroundTransparency = 1; Content.ZIndex = 3
local AimPage = Instance.new("Frame", Content); AimPage.Size = UDim2.new(1, 0, 1, 0); AimPage.BackgroundTransparency = 1
local ESPPage = Instance.new("Frame", Content); ESPPage.Size = UDim2.new(1, 0, 1, 0); ESPPage.BackgroundTransparency = 1; ESPPage.Visible = false
local SafePage = Instance.new("Frame", Content); SafePage.Size = UDim2.new(1, 0, 1, 0); SafePage.BackgroundTransparency = 1; SafePage.Visible = false
local ConfigPage = Instance.new("Frame", Content); ConfigPage.Size = UDim2.new(1, 0, 1, 0); ConfigPage.BackgroundTransparency = 1; ConfigPage.Visible = false

local UI_Elements = {}

local function UpdateVisuals()
    UI_Elements.AIMON.Btn.BackgroundColor3 = AIMBOT_ENABLED and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
    UI_Elements.VISCHECK.Btn.BackgroundColor3 = VISIBLE_CHECK and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
    UI_Elements.SHOWFOV.Btn.BackgroundColor3 = SHOW_FOV_VISUAL and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
    UI_Elements.ESPON.Btn.BackgroundColor3 = ESP_ENABLED and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
    UI_Elements.STICKY.Btn.BackgroundColor3 = STICKY_AIM and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
    UI_Elements.STATS.Btn.BackgroundColor3 = SHOW_STATS and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
end

local function AddInput(id, text, pos, default, parent, callback)
    local label = Instance.new("TextLabel", parent); label.Size = UDim2.new(1, 0, 0, 15); label.Position = UDim2.new(0, 0, 0, pos); label.Text = text; label.TextColor3 = Color3.new(1,1,1); label.TextSize = 10; label.BackgroundTransparency = 1; label.TextXAlignment = Enum.TextXAlignment.Left; label.Font = Enum.Font.GothamBold
    local box = Instance.new("TextBox", parent); box.Size = UDim2.new(0.95, 0, 0, 25); box.Position = UDim2.new(0, 0, 0, pos + 15); box.Text = tostring(default); box.BackgroundColor3 = Color3.fromRGB(30, 30, 30); box.TextColor3 = Color3.new(1,1,1); box.Font = Enum.Font.Gotham; UI_Elements[id] = box
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)
    box.FocusLost:Connect(function() local v = tonumber(box.Text); if v then callback(v) end end)
end

local function CreateToggle(id, text, pos, parent, callback)
    local btn = Instance.new("TextButton", parent); btn.Size = UDim2.new(0.95, 0, 0, 30); btn.Position = UDim2.new(0, 0, 0, pos); btn.BackgroundColor3 = Color3.fromRGB(150, 0, 0); btn.Text = text; btn.TextColor3 = Color3.new(1,1,1); btn.TextSize = 11; btn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8); UI_Elements[id] = {Btn = btn}
    btn.MouseButton1Click:Connect(function()
        local state = not (btn.BackgroundColor3 == Color3.fromRGB(0, 150, 0))
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
        callback(state)
    end)
end

-- ABAS
AddInput("FOV", "RAIO DO FOV:", 0, FOV_RADIUS, AimPage, function(v) FOV_RADIUS = v end)
AddInput("SMOOTH", "SUAVIDADE:", 45, SMOOTHNESS, AimPage, function(v) SMOOTHNESS = v end)
CreateToggle("AIMON", "ATIVAR AIMBOT", 95, AimPage, function(v) AIMBOT_ENABLED = v end)
CreateToggle("VISCHECK", "VISIBLE CHECK", 130, AimPage, function(v) VISIBLE_CHECK = v end)
CreateToggle("SHOWFOV", "EXIBIR FOV VISUAL", 165, AimPage, function(v) SHOW_FOV_VISUAL = v end)

CreateToggle("ESPON", "ATIVAR ESP", 0, ESPPage, function(v) ESP_ENABLED = v end)
AddInput("ESPDIST", "DISTÂNCIA ESP:", 35, MAX_ESP_DISTANCE, ESPPage, function(v) MAX_ESP_DISTANCE = v end)

CreateToggle("STICKY", "STICKY AIM", 0, SafePage, function(v) STICKY_AIM = v; if not v then lockedTarget = nil end end)

CreateToggle("STATS", "EXIBIR FPS/PING", 0, ConfigPage, function(v) SHOW_STATS = v; StatsLabel.Visible = v end)

-- SALVAR/CARREGAR
local function SaveConfig()
    local data = {FOV = FOV_RADIUS, SMOOTH = SMOOTHNESS, AIM_ON = AIMBOT_ENABLED, VISIBLE = VISIBLE_CHECK, SHOW_FOV = SHOW_FOV_VISUAL, ESP_ON = ESP_ENABLED, ESP_DIST = MAX_ESP_DISTANCE, STICKY = STICKY_AIM, S_STATS = SHOW_STATS}
    pcall(function() writefile("GuNHub_Config.json", HttpService:JSONEncode(data)) end)
end

local function LoadConfig()
    if isfile("GuNHub_Config.json") then
        local success, data = pcall(function() return HttpService:JSONDecode(readfile("GuNHub_Config.json")) end)
        if success then
            FOV_RADIUS = data.FOV or FOV_RADIUS; SMOOTHNESS = data.SMOOTH or SMOOTHNESS
            AIMBOT_ENABLED = data.AIM_ON; VISIBLE_CHECK = data.VISIBLE; SHOW_FOV_VISUAL = data.SHOW_FOV
            ESP_ENABLED = data.ESP_ON; MAX_ESP_DISTANCE = data.ESP_DIST; STICKY_AIM = data.STICKY; SHOW_STATS = data.S_STATS
            UI_Elements.FOV.Text = tostring(FOV_RADIUS); UI_Elements.SMOOTH.Text = tostring(SMOOTHNESS); UI_Elements.ESPDIST.Text = tostring(MAX_ESP_DISTANCE)
            UpdateVisuals()
        end
    end
end

local SaveBtn = Instance.new("TextButton", ConfigPage); SaveBtn.Size = UDim2.new(0.95, 0, 0, 35); SaveBtn.Position = UDim2.new(0, 0, 0, 40); SaveBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); SaveBtn.Text = "SALVAR CONFIGURAÇÕES"; SaveBtn.TextColor3 = Color3.new(1, 1, 1); SaveBtn.Font = Enum.Font.GothamBold; Instance.new("UICorner", SaveBtn)
SaveBtn.MouseButton1Click:Connect(SaveConfig)

local LoadBtn = Instance.new("TextButton", ConfigPage); LoadBtn.Size = UDim2.new(0.95, 0, 0, 35); LoadBtn.Position = UDim2.new(0, 0, 0, 80); LoadBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); LoadBtn.Text = "CARREGAR CONFIGURAÇÕES"; LoadBtn.TextColor3 = Color3.new(1, 1, 1); LoadBtn.Font = Enum.Font.GothamBold; Instance.new("UICorner", LoadBtn)
LoadBtn.MouseButton1Click:Connect(LoadConfig)

-- --- GESTO 3 TOQUES ---
local currentTouches = {}
local holdStartTime = 0
local isHolding3 = false

UserInputService.TouchStarted:Connect(function(touch)
    currentTouches[touch] = true
    local count = 0
    for _ in pairs(currentTouches) do count = count + 1 end
    if count == 3 then
        isHolding3 = true
        holdStartTime = tick()
        task.spawn(function()
            while isHolding3 do
                if tick() - holdStartTime >= 1.5 then
                    MainFrame.Visible = not MainFrame.Visible
                    isHolding3 = false
                    break
                end
                task.wait(0.1)
            end
        end)
    end
end)

UserInputService.TouchEnded:Connect(function(touch)
    currentTouches[touch] = nil
    isHolding3 = false
end)

-- --- MOTOR DO ESP (OTIMIZADO) ---
-- Unificamos todos os desenhos em um único loop para poupar FPS
local ESP_Table = {}

local function RemoveESP(player)
    if ESP_Table[player] then
        ESP_Table[player].Box:Remove()
        ESP_Table[player] = nil
    end
end

local function CreateESP(player)
    if player == LocalPlayer then return end
    local Box = Drawing.new("Square")
    Box.Visible = false
    Box.Thickness = 1
    Box.Transparency = 1
    Box.Filled = false
    ESP_Table[player] = {Box = Box}
end

Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(RemoveESP)
for _, p in pairs(Players:GetPlayers()) do CreateESP(p) end

-- --- MOTOR ÚNICO (CORE) ---
-- Colocar tudo em um só loop centralizado evita "Spam" de conexões no motor do jogo
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.Transparency = 0.7
FOVCircle.Filled = false

RunService.RenderStepped:Connect(function(dt)
    local rgb = GetRGB()
    local camPos = Camera.CFrame.Position
    
    -- UI Visuals
    MainStroke.Color = rgb; ButtonStroke.Color = rgb; Title.TextColor3 = rgb
    if SHOW_STATS then 
        StatsLabel.Text = string.format("FPS: %d | PING: %dms", math.floor(1/dt), math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())) 
    end
    
    -- FOV Visual
    FOVCircle.Radius = FOV_RADIUS
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    FOVCircle.Visible = SHOW_FOV_VISUAL
    FOVCircle.Color = rgb
    
    -- Loop ESP unificado (Muito mais leve)
    for player, data in pairs(ESP_Table) do
        local char = player.Character
        if ESP_ENABLED and char and char:FindFirstChild("HumanoidRootPart") then
            local root = char.HumanoidRootPart
            local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
            local dist = (camPos - root.Position).Magnitude
            
            if onScreen and dist <= MAX_ESP_DISTANCE then
                local size = (Camera.ViewportSize.Y / dist) * 2.5
                data.Box.Size = Vector2.new(size * 0.6, size)
                data.Box.Position = Vector2.new(pos.X - data.Box.Size.X / 2, pos.Y - data.Box.Size.Y / 2)
                data.Box.Color = rgb
                data.Box.Visible = true
            else
                data.Box.Visible = false
            end
        else
            data.Box.Visible = false
        end
    end
    
    -- Motor Aimbot
    if AIMBOT_ENABLED and isAimingToggle then
        if STICKY_AIM and lockedTarget and lockedTarget.Character and lockedTarget.Character:FindFirstChild(AIM_PART) then
            local targetPart = lockedTarget.Character[AIM_PART]
            local pos, onS = Camera:WorldToViewportPoint(targetPart.Position)
            local mag = (Vector2.new(pos.X, pos.Y) - FOVCircle.Position).Magnitude
            if not onS or mag > FOV_RADIUS * 1.5 or lockedTarget.Character.Humanoid.Health <= 0 or not IsVisible(targetPart) then
                lockedTarget = nil
            end
        else
            lockedTarget = nil
            local dist = FOV_RADIUS
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild(AIM_PART) and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                    local targetPart = p.Character[AIM_PART]
                    local pos, onS = Camera:WorldToViewportPoint(targetPart.Position)
                    local mag = (Vector2.new(pos.X, pos.Y) - FOVCircle.Position).Magnitude
                    if onS and mag < dist and IsVisible(targetPart) then
                        dist = mag
                        lockedTarget = p
                    end
                end
            end
        end

        if lockedTarget then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, lockedTarget.Character[AIM_PART].Position), SMOOTHNESS)
        end
    end
end)

LoadConfig()
local function TabNav(btn, pg) btn.MouseButton1Click:Connect(function() AimPage.Visible = false; ESPPage.Visible = false; SafePage.Visible = false; ConfigPage.Visible = false; pg.Visible = true end) end
TabNav(AimTab, AimPage); TabNav(ESPTab, ESPPage); TabNav(SafeTab, SafePage); TabNav(ConfigTab, ConfigPage)
