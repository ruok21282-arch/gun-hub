--[[ 
    GuN HUB LITE - PROTECTED VERSION
    Unauthorized copying is prohibited.
]]

local _0x52754e = game:GetService("\80\108\97\121\101\114\115")
local _0x52754f = game:GetService("\82\117\110\83\101\114\118\105\99\101")
local _0x527550 = workspace.CurrentCamera
local _0x527551 = _0x52754e.LocalPlayer

local _0xConfig = { _A = false, _E = false, _R = 100, _S = 0.15 }

local _0xUI = Instance.new("ScreenGui", game:GetService("CoreGui"))
local _0xM = Instance.new("Frame", _0xUI)
_0xM.Size = UDim2.new(0, 200, 0, 180)
_0xM.Position = UDim2.new(0.3, 0, 0.3, 0)
_0xM.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
_0xM.BorderSizePixel = 2
_0xM.Draggable = true
_0xM.Active = true

local _0xMini = Instance.new("TextButton", _0xUI)
_0xMini.Size = UDim2.new(0, 45, 0, 45)
_0xMini.Position = UDim2.new(0.02, 0, 0.4, 0)
_0xMini.Text = "GuN"
_0xMini.Visible = false
_0xMini.Draggable = true

local _0xH = Instance.new("Frame", _0xM)
_0xH.Size = UDim2.new(1, 0, 0, 30)
_0xH.BackgroundColor3 = Color3.fromRGB(45, 45, 45)

local _0xCls = Instance.new("TextButton", _0xH)
_0xCls.Size = UDim2.new(0, 30, 0, 30)
_0xCls.Position = UDim2.new(1, -30, 0, 0)
_0xCls.Text = "-"
_0xCls.BackgroundColor3 = Color3.fromRGB(200, 50, 50)

_0xCls.MouseButton1Click:Connect(function() _0xM.Visible = false; _0xMini.Visible = true end)
_0xMini.MouseButton1Click:Connect(function() _0xM.Visible = true; _0xMini.Visible = false end)

local function _0xNewOp(_0xT, _0xP, _0xCb)
    local _0xB = Instance.new("TextButton", _0xM)
    _0xB.Size = UDim2.new(0.9, 0, 0, 35)
    _0xB.Position = UDim2.new(0.05, 0, 0, _0xP)
    _0xB.Text = _0xT .. ": OFF"
    _0xB.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    local _0xSt = false
    _0xB.MouseButton1Click:Connect(function()
        _0xSt = not _0xSt
        _0xB.Text = _0xT .. (_0xSt and ": ON" or ": OFF")
        _0xB.BackgroundColor3 = _0xSt and Color3.fromRGB(30, 150, 30) or Color3.fromRGB(60, 60, 60)
        _0xCb(_0xSt)
    end)
end

_0xNewOp("AIMBOT", 45, function(_0xV) _0xConfig._A = _0xV end)
_0xNewOp("ESP LINE", 90, function(_0xV) _0xConfig._E = _0xV end)

local _0xFOV = Drawing.new("Circle")
_0xFOV.Thickness = 1; _0xFOV.Color = Color3.new(1, 1, 1); _0xFOV.Visible = false

local _0xLns = {}

_0x52754f.RenderStepped:Connect(function()
    _0xFOV.Radius = _0xConfig._R
    _0xFOV.Position = Vector2.new(_0x527550.ViewportSize.X/2, _0x527550.ViewportSize.Y/2)
    _0xFOV.Visible = _0xConfig._A
    
    for _, _0xP in pairs(_0x52754e:GetPlayers()) do
        if _0xP ~= _0x527551 and _0xP.Character and _0xP.Character:FindFirstChild("HumanoidRootPart") then
            if not _0xLns[_0xP] then
                local _0xL = Drawing.new("Line")
                _0xL.Thickness = 1; _0xL.Color = Color3.new(1, 1, 1)
                _0xLns[_0xP] = _0xL
            end
            local _0xR = _0xP.Character.HumanoidRootPart
            local _0xVp, _0xOn = _0x527550:WorldToViewportPoint(_0xR.Position)
            if _0xConfig._E and _0xOn then
                _0xLns[_0xP].From = Vector2.new(_0x527550.ViewportSize.X / 2, _0x527550.ViewportSize.Y)
                _0xLns[_0xP].To = Vector2.new(_0xVp.X, _0xVp.Y)
                _0xLns[_0xP].Visible = true
            else _0xLns[_0xP].Visible = false end
        elseif _0xLns[_0xP] then _0xLns[_0xP].Visible = false end
    end

    if _0xConfig._A then
        local _0xT = nil; local _0xD = _0xConfig._R
        for _, _0xP in pairs(_0x52754e:GetPlayers()) do
            if _0xP ~= _0x527551 and _0xP.Character and _0xP.Character:FindFirstChild("Head") and _0xP.Character.Humanoid.Health > 0 then
                local _0xVp, _0xOn = _0x527550:WorldToViewportPoint(_0xP.Character.Head.Position)
                if _0xOn then
                    local _0xM = (Vector2.new(_0xVp.X, _0xVp.Y) - _0xFOV.Position).Magnitude
                    if _0xM < _0xD then _0xD = _0xM; _0xT = _0xP end
                end
            end
        end
        if _0xT then
            _0x527550.CFrame = _0x527550.CFrame:Lerp(CFrame.new(_0x527550.CFrame.Position, _0xT.Character.Head.Position), _0xConfig._S)
        end
    end
end)
