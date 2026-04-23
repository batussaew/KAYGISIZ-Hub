-- [[ KAYGISIZ HUB - Blox Fruits Base Script ]] --
-- GitHub: batussaew/KAYGISIZ-Hub

local TweenService = game:GetService("TweenService")
local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- Ayarlar
_G.AutoFarm = true
_G.AttackSpeed = 0.1
_G.TeleportSpeed = 250 -- AC Bypass için ideal hız

-- Yumuşak Işınlanma Fonksiyonu (Byfron Bypass Destekli)
function kaygisizTween(targetCFrame)
    local distance = (RootPart.Position - targetCFrame.Position).Magnitude
    local info = TweenInfo.new(distance / _G.TeleportSpeed, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(RootPart, info, {CFrame = targetCFrame})
    tween:Play()
    return tween
end

-- En Yakın NPC'yi Bulma
function getClosestNPC()
    local closestNPC = nil
    local shortestDistance = math.huge
    
    -- Workspace içindeki yaratıkları tara
    for _, v in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
        if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
            local distance = (RootPart.Position - v.HumanoidRootPart.Position).Magnitude
            if distance < shortestDistance then
                shortestDistance = distance
                closestNPC = v
            end
        end
    end
    return closestNPC
end

-- Ana Loop (Auto-Farm)
spawn(function()
    while task.wait(_G.AttackSpeed) do
        if _G.AutoFarm then
            local target = getClosestNPC()
            if target then
                -- NPC'nin 5 birim üstüne git (Vurulmamak için)
                kaygisizTween(target.HumanoidRootPart.CFrame * CFrame.new(0, 5, 0))
                
                -- Otomatik Saldırı (VirtualUser simülasyonu)
                local vu = game:GetService("VirtualUser")
                vu:CaptureController()
                vu:Button1Down(Vector2.new(0, 0), game.Workspace.CurrentCamera.CFrame)
            end
        end
    end
end)

-- Anti-AFK (KYK Yurdunda Script Bırakanlar İçin)
Player.Idled:Connect(function()
    local vu = game:GetService("VirtualUser")
    vu:Button2Down(Vector2.new(0, 0), game.Workspace.CurrentCamera.CFrame)
    task.wait(1)
    vu:Button2Up(Vector2.new(0, 0), game.Workspace.CurrentCamera.CFrame)
end)

print("KAYGISIZ Hub Başarıyla Yüklendi!")
