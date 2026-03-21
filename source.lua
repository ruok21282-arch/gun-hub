--[[ 
    GuN HUB LITE - FIXED & PROTECTED
]]

local _0xS = {
    P = game:GetService("\80\108\97\121\101\114\115"),
    R = game:GetService("\82\117\110\83\101\114\118\105\99\101"),
    C = workspace.CurrentCamera,
    L = game:GetService("\80\108\97\121\101\114\115").LocalPlayer
}

local _0xV = {
    A = false,
    E = false,
    F = 100, -- Raio do FOV
    S = 0.15 -- Suavidade
}

local _0xUI = Instance.new("ScreenGui", game:GetService("CoreGui"))
local _0xM = Instance.new("Frame", _0xUI)
_0xM.Size = UDim2.new(0, 200, 0, 180)
_0xM.Position = UDim2.new(0.3, 0, 0.3, 0)
_0xM.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
_0xM.BorderSizePixel = 2
_0xM.Active = true
_0xM.Draggable = true

local _0xMini = Instance.new("TextButton", _0xUI)
_0xMini.Size = UDim2.new(0, 45, 0, 45)
_0xMini.Position = UDim2.new(0.02, 0, 0.4, 0)
_0xMini.Text = "GuN"
_0xMini.Visible = false
_0xMini.Draggable = true
_0xMini.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
_0xMini.TextColor3 = Color3.new(1, 1, 1)

local _0xH = Instance.new("Frame", _0xM)
_0xH.Size = UDim2.new(1, 0, 0, 30)
_0xH.BackgroundColor3 = Color3.fromRGB(45, 45, 45)

local _0xT = Instance.new("TextLabel", _0xH)
_0xT.Size = UDim2.new(0.7, 0, 1, 0)
_0xT.Position = UDim2.new(0, 10, 0, 0)
_0xT.Text = "GuN LITE"
_0xT.TextColor3 = Color3.new(1, 1, 1)
_0xT.BackgroundTransparency = 1
_0xT.TextXAlignment = Enum.TextXAlignment.Left

local _0xCls = Instance.new("TextButton", _0xH)
_0xCls.Size = UDim2.new(0, 30, 0, 30)
_0xCls.Position = UDim2.new(1, -30, 0, 0)
_0xCls.Text = "-"
_0xCls.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
_0xCls.TextColor3 = Color3.new(1, 1, 1)

_0xCls.MouseButton1Click:Connect(function() _0xM.Visible = false; _0xMini.Visible = true end)
_0xMini.MouseButton1Click:Connect(function() _0xM.Visible = true; _0xMini.Visible = false end)

local function _0xNew(_0xTxt, _0xPos, _0xCall)
    local _0xB = Instance.new("TextButton", _0xM)
    _0xB.Size = UDim2.new(0.9, 0, 0, 35)
    _0xB.Position = UDim2.new(0.05, 0, 0, _0xPos)
    _0xB.Text = _0xTxt .. ": OFF"
    _0xB.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    _0xB.TextColor3 = Color3.new(1, 1, 1)
    local _0xSt = false
    _0xB.MouseButton1Click:Connect(function()
        _0xSt = not _0xSt
        _0xB.Text = _0xTxt .. (_0xSt and ": ON" or ": OFF")
        _0xB.BackgroundColor3 = _0xSt and Color3.fromRGB(30, 150, 30) or Color3.fromRGB(60, 60, 60)
        _0xCall(_0xSt)
    end)
end

_0xNew("AIMBOT", 45, function(_0xZ) _0xV.A = _0xZ end)
_0xNew("ESP LINE", 90, function(_0xZ) _0xV.E = _0xZ end)

local _0xFOV = Drawing.new("Circle")
_0xFOV.Thickness = 1; _0xFOV.Color = Color3.new(1, 1, 1); _0xFOV.Transparency = 0.5; _0xFOV.Filled = false

local _0xLns = {}

_0xS.R.RenderStepped:Connect(function()
    _0xFOV.Radius = _0xV.F
    _0xFOV.Position = Vector2.new(_0xS.C.ViewportSize.X/2, _0xS.C.ViewportSize.Y/2)
    _0xFOV.Visible = _0xV.A
    
    for _, _0xP in pairs(_0xS.P:GetPlayers()) do
        if _0xP ~= _0xS.L and _0xP.Character and _0xP.Character:FindFirstChild("HumanoidRootPart") then
            if not _0xLns[_0xP] then
                local _0xLine = Drawing.new("Line")
                _0xLine.Thickness = 1; _0xLine.Color = Color3.new(1, 1, 1); _0xLine.Transparency = 1
                _0xLns[_0xP] = _0xLine
            end
            local _0xRoot = _0xP.Character.HumanoidRootPart
            local _0xPos, _0xOn = _0xS.C:WorldToViewportPoint(_0xRoot.Position)
            if _0xV.E and _0xOn then
                _0xLns[_0xP].From = Vector2.new(_0xS.C.ViewportSize.X / 2, _0xS.C.ViewportSize.Y)
                _0xLns[_0xP].To = Vector2.new(_0xPos.X, _0xPos.Y)
                _0xLns[_0xP].Visible = true
            else _0xLns[_0xP].Visible = false end
        elseif _0xLns[_0xP] then _0xLns[_0xP].Visible = false end
    end

    if _0xV.A then
        local _0xTarg = nil; local _0xDist = _0xV.F
        for _, _0xP in pairs(_0xS.P:GetPlayers()) do
            if _0xP ~= _0xS.L and _0xP.Character and _0xP.Character:FindFirstChild("Head") and _0xP.Character.Humanoid.Health > 0 then
                local _0xPos, _0xOn = _0xS.C:WorldToViewportPoint(_0xP.Character.Head.Position)
                if _0xOn then
                    local _0xMag = (Vector2.new(_0xPos.X, _0xPos.Y) - _0xFOV.Position).Magnitude
                    if _0xMag < _0xDist then _0xDist = _0xMag; _0xTarg = _0xP end
                end
            end
        end
        if _0xTarg then
            _0xS.C.CFrame = _0xS.C.CFrame:Lerp(CFrame.new(_0xS.C.CFrame.Position, _0xTarg.Character.Head.Position), _0xV.S)
        end
    end
end)

_0xS.P.PlayerRemoving:Connect(function(_0xP) if _0xLns[_0xP] then _0xLns[_0xP]:Remove() _0xLns[_0xP] = nil end end)
