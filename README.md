-- ID DA IMAGEM (MISIDE)
local IMAGE_ID = "rbxassetid://86608309240586"

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local Stats = game:GetService("Stats") -- Adicionado para o Ping
local Lighting = game:GetService("Lighting") -- Adicionado para Otimização
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- CONFIGURAÇÕES GERAIS (VALORES PADRÃO)
local AIMBOT_ENABLED = false
local FOV_RADIUS = 120 
local SMOOTHNESS = 0.2 
local AIM_PART = "Head"
local VISIBLE_CHECK = false
local ESP_ENABLED = false
local MAX_ESP_DISTANCE = 50
local BOX_COLOR = Color3.fromRGB(0, 255, 140)
local SHOW_FOV_VISUAL = false
local STICKY_AIM = false
local SHOW_STATS = true -- Nova opção

-- VARIÁVEIS DE CONTROLE
local isAimingToggle = false
local currentTarget = nil

-- SISTEMA RGB
local function GetRGB()
    local t = tick()
    return Color3.fromHSV(t % 5 / 5, 1, 1)
end

-- INTERFACE PRINCIPAL
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
ScreenGui.Name = "GuNHub_Mobile"

-- --- BOTÃO FLUTUANTE (FIXO) ---
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
    if not isAimingToggle then currentTarget = nil end
end)

-- --- PAINEL DE CONTROLE ---
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 380, 0, 280)
MainFrame.Position = UDim2.new(0.5, -190, 0.5, -140)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true

local MainCorner = Instance.new("UICorner", MainFrame); MainCorner.CornerRadius = UDim.new(0, 12)
local BackgroundImg = Instance.new("ImageLabel", MainFrame); BackgroundImg.Size = UDim2.new(1, 0, 1, 0); BackgroundImg.Image = IMAGE_ID; BackgroundImg.BackgroundTransparency = 1; BackgroundImg.ImageTransparency = 0.3; BackgroundImg.ScaleType = Enum.ScaleType.Crop; BackgroundImg.ZIndex = 0
local MainStroke = Instance.new("UIStroke", MainFrame); MainStroke.Thickness = 3

-- HEADER
local Header = Instance.new("Frame", MainFrame); Header.Size = UDim2.new(1, 0, 0, 35); Header.BackgroundTransparency = 0.5; Header.BackgroundColor3 = Color3.new(0,0,0); Header.ZIndex = 2
local Title = Instance.new("TextLabel", Header); Title.Size = UDim2.new(0.5, 0, 1, 0); Title.Position = UDim2.new(0, 10, 0, 0); Title.Text = "GuN HUB V1"; Title.Font = Enum.Font.GothamBold; Title.TextSize = 18; Title.BackgroundTransparency = 1; Title.TextXAlignment = Enum.TextXAlignment.Left

-- LABEL DE FPS/PING (Nova Opção Visual)
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

local function AddInput(id, text, pos, default, parent, callback)
    local label = Instance.new("TextLabel", parent); label.Size = UDim2.new(1, 0, 0, 15); label.Position = UDim2.new(0, 0, 0, pos); label.Text = text; label.TextColor3 = Color3.new(1,1,1); label.TextSize = 11; label.BackgroundTransparency = 1; label.TextXAlignment = Enum.TextXAlignment.Left; label.Font = Enum.Font.GothamBold
    local box = Instance.new("TextBox", parent); box.Size = UDim2.new(0.95, 0, 0, 25); box.Position = UDim2.new(0, 0, 0, pos + 15); box.Text = tostring(default); box.BackgroundColor3 = Color3.fromRGB(30, 30, 30); box.TextColor3 = Color3.new(1,1,1); box.Font = Enum.Font.Gotham
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6); UI_Elements[id] = box
    box.FocusLost:Connect(function() local v = tonumber(box.Text); if v then callback(v) end end)
end

local function CreateToggle(id, text, pos, parent, initial, callback)
    local btn = Instance.new("TextButton", parent); btn.Size = UDim2.new(0.95, 0, 0, 32); btn.Position = UDim2.new(0, 0, 0, pos); btn.BackgroundColor3 = initial and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0); btn.Text = text; btn.TextColor3 = Color3.new(1,1,1); btn.TextSize = 11; btn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8); UI_Elements[id] = {Btn = btn, State = initial}
    btn.MouseButton1Click:Connect(function()
        UI_Elements[id].State = not UI_Elements[id].State
        btn.BackgroundColor3 = UI_Elements[id].State and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
        callback(UI_Elements[id].State)
    end)
end

-- COMPONENTES DA INTERFACE (MANTIDOS)
AddInput("FOV", "RAIO DO FOV:", 0, FOV_RADIUS, AimPage, function(v) FOV_RADIUS = v end)
AddInput("SMOOTH", "SUAVIDADE (SMOOTH):", 45, SMOOTHNESS, AimPage, function(v) SMOOTHNESS = v end)
CreateToggle("AIMON", "ATIVAR AIMBOT", 95, AimPage, AIMBOT_ENABLED, function(v) AIMBOT_ENABLED = v end)
CreateToggle("VISCHECK", "VISIBLE CHECK", 135, AimPage, VISIBLE_CHECK, function(v) VISIBLE_CHECK = v end)
CreateToggle("SHOWFOV", "EXIBIR FOV VISUAL", 175, AimPage, SHOW_FOV_VISUAL, function(v) SHOW_FOV_VISUAL = v end)

CreateToggle("ESPON", "ATIVAR ESP", 0, ESPPage, ESP_ENABLED, function(v) ESP_ENABLED = v end)
AddInput("ESPDIST", "DISTÂNCIA ESP:", 40, MAX_ESP_DISTANCE, ESPPage, function(v) MAX_ESP_DISTANCE = math.clamp(v, 0, 1000) end)

CreateToggle("STICKY", "STICKY AIM (TRAVAR)", 0, SafePage, STICKY_AIM, function(v) STICKY_AIM = v end)

-- NOVAS OPÇÕES NA ABA CONFIG
CreateToggle("STATS", "EXIBIR FPS/PING", 100, ConfigPage, SHOW_STATS, function(v) SHOW_STATS = v; StatsLabel.Visible = v end)

local BoostBtn = Instance.new("TextButton", ConfigPage); BoostBtn.Size = UDim2.new(0.95, 0, 0, 35); BoostBtn.Position = UDim2.new(0, 0, 0, 140); BoostBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255); BoostBtn.Text = "OTIMIZAR PING/FPS"; BoostBtn.TextColor3 = Color3.new(1, 1, 1); BoostBtn.Font = Enum.Font.GothamBold; Instance.new("UICorner", BoostBtn)
BoostBtn.MouseButton1Click:Connect(function()
    settings().Network.IncomingReplicationLag = 0
    workspace.InterpolationThrottling = Enum.InterpolationThrottlingMode.Enabled
    for _, e in pairs(Lighting:GetChildren()) do if e:IsA("BlurEffect") or e:IsA("SunRaysEffect") or e:IsA("DepthOfFieldEffect") then e.Enabled = false end end
    collectgarbage("collect")
end)

-- --- SISTEMA DE SALVAR/CARREGAR (MANTIDO) ---
local function SaveSettings()
    local data = {
        FOV = FOV_RADIUS, SMOOTH = SMOOTHNESS, AIM_ON = AIMBOT_ENABLED,
        VISIBLE = VISIBLE_CHECK, SHOW_FOV = SHOW_FOV_VISUAL,
        ESP_ON = ESP_ENABLED, ESP_DIST = MAX_ESP_DISTANCE, STICKY = STICKY_AIM
    }
    pcall(function() writefile("GuNHub_Config.json", HttpService:JSONEncode(data)) end)
end

local function LoadSettings()
    if isfile("GuNHub_Config.json") then
        local success, data = pcall(function() return HttpService:JSONDecode(readfile("GuNHub_Config.json")) end)
        if success and data then
            FOV_RADIUS = data.FOV or FOV_RADIUS; SMOOTHNESS = data.SMOOTH or SMOOTHNESS
            AIMBOT_ENABLED = data.AIM_ON or false; VISIBLE_CHECK = data.VISIBLE or false
            SHOW_FOV_VISUAL = data.SHOW_FOV or false; ESP_ENABLED = data.ESP_ON or false
            MAX_ESP_DISTANCE = data.ESP_DIST or MAX_ESP_DISTANCE; STICKY_AIM = data.STICKY or false
            
            UI_Elements.FOV.Text = tostring(FOV_RADIUS)
            UI_Elements.SMOOTH.Text = tostring(SMOOTHNESS)
            UI_Elements.ESPDIST.Text = tostring(MAX_ESP_DISTANCE)
            UI_Elements.AIMON.Btn.BackgroundColor3 = AIMBOT_ENABLED and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
            UI_Elements.VISCHECK.Btn.BackgroundColor3 = VISIBLE_CHECK and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
            UI_Elements.SHOWFOV.Btn.BackgroundColor3 = SHOW_FOV_VISUAL and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
            UI_Elements.ESPON.Btn.BackgroundColor3 = ESP_ENABLED and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
            UI_Elements.STICKY.Btn.BackgroundColor3 = STICKY_AIM and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
        end
    end
end

local SaveBtn = Instance.new("TextButton", ConfigPage); SaveBtn.Size = UDim2.new(0.95, 0, 0, 35); SaveBtn.Position = UDim2.new(0, 0, 0, 10); SaveBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); SaveBtn.Text = "SALVAR CONFIGURAÇÕES"; SaveBtn.TextColor3 = Color3.new(1, 1, 1); SaveBtn.Font = Enum.Font.GothamBold; Instance.new("UICorner", SaveBtn)
SaveBtn.MouseButton1Click:Connect(SaveSettings)

local LoadBtn = Instance.new("TextButton", ConfigPage); LoadBtn.Size = UDim2.new(0.95, 0, 0, 35); LoadBtn.Position = UDim2.new(0, 0, 0, 55); LoadBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); LoadBtn.Text = "CARREGAR CONFIGURAÇÕES"; LoadBtn.TextColor3 = Color3.new(1, 1, 1); LoadBtn.Font = Enum.Font.GothamBold; Instance.new("UICorner", LoadBtn)
LoadBtn.MouseButton1Click:Connect(LoadSettings)

-- --- SISTEMA DE TOQUE (3 DEDOS / 1.5 SEGUNDOS) ---
local touchCount = 0
local startTime = 0
local holding = false

UserInputService.TouchStarted:Connect(function(touch, processed)
    touchCount = touchCount + 1
    if touchCount == 3 then
        startTime = tick()
        holding = true
        task.spawn(function()
            while holding and touchCount == 3 do
                if tick() - startTime >= 1.5 then
                    MainFrame.Visible = not MainFrame.Visible
                    holding = false 
                    break
                end
                task.wait(0.1)
            end
        end)
    end
end)

UserInputService.TouchEnded:Connect(function()
    touchCount = math.max(0, touchCount - 1)
    if touchCount < 3 then holding = false end
end)

-- --- LOGICA AIMBOT / ESP / RENDER (MOTOR MANTIDO) ---
local function isPartVisible(part)
    if not VISIBLE_CHECK then return true end
    local char = LocalPlayer.Character
    if not char then return false end
    local rayParams = RaycastParams.new(); rayParams.FilterType = Enum.RaycastFilterType.Blacklist; rayParams.FilterDescendantsInstances = {char, Camera}
    local rayResult = workspace:Raycast(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position), rayParams)
    return not rayResult or rayResult.Instance:IsDescendantOf(part.Parent)
end

local FOVCircle = Drawing.new("Circle"); FOVCircle.Thickness = 2; FOVCircle.Color = Color3.new(1,1,1); FOVCircle.Transparency = 0.7; FOVCircle.Filled = false

RunService.RenderStepped:Connect(function(deltaTime) -- deltaTime adicionado para o FPS
    local rgb = GetRGB()
    MainStroke.Color = rgb; Title.TextColor3 = rgb; ButtonStroke.Color = rgb
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2); FOVCircle.Radius = FOV_RADIUS; FOVCircle.Visible = SHOW_FOV_VISUAL
    
    -- Atualização de Stats (FPS/Ping)
    if SHOW_STATS then
        local fps = math.floor(1 / deltaTime)
        local ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
        StatsLabel.Text = string.format("FPS: %d | PING: %dms", fps, ping)
    end

    if AIMBOT_ENABLED and isAimingToggle then
        if STICKY_AIM and currentTarget and currentTarget.Character and currentTarget.Character:FindFirstChild(AIM_PART) then
            local part = currentTarget.Character[AIM_PART]
            local pos, onS = Camera:WorldToViewportPoint(part.Position)
            if not onS or (Vector2.new(pos.X, pos.Y) - FOVCircle.Position).Magnitude > FOV_RADIUS or not isPartVisible(part) then
                currentTarget = nil
            end
        else
            local target = nil; local shortestDist = FOV_RADIUS
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild(AIM_PART) then
                    local part = p.Character[AIM_PART]
                    local pos, onS = Camera:WorldToViewportPoint(part.Position)
                    if onS then
                        local d = (Vector2.new(pos.X, pos.Y) - FOVCircle.Position).Magnitude
                        if d < shortestDist and isPartVisible(part) then target = p; shortestDist = d end
                    end
                end
            end
            currentTarget = target
        end
        if currentTarget then Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, currentTarget.Character[AIM_PART].Position), SMOOTHNESS) end
    end
end)

-- NAVEGAÇÃO
AimTab.MouseButton1Click:Connect(function() AimPage.Visible = true; ESPPage.Visible = false; SafePage.Visible = false; ConfigPage.Visible = false end)
ESPTab.MouseButton1Click:Connect(function() AimPage.Visible = false; ESPPage.Visible = true; SafePage.Visible = false; ConfigPage.Visible = false end)
SafeTab.MouseButton1Click:Connect(function() AimPage.Visible = false; ESPPage.Visible = false; SafePage.Visible = true; ConfigPage.Visible = false end)
ConfigTab.MouseButton1Click:Connect(function() AimPage.Visible = false; ESPPage.Visible = false; SafePage.Visible = false; ConfigPage.Visible = true end)

