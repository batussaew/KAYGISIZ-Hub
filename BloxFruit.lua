-- [[ KAYGISIZ ENGINE V6 | GOD MODE & BOUNTY HUNTER ]] --
-- GitHub: batussaew/KAYGISIZ-Hub

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local Player = Players.LocalPlayer

-- ========================================== --
-- GLOBAL DEĞİŞKENLER (V6 ÖZEL)
-- ========================================== --
getgenv().Kaygisiz = {
    AutoFarm = false,
    AutoPlayer = false, -- Player Farm
    SelectedPlayer = nil,
    AutoChest = false,
    AutoBoss = false,
    TweenSpeed = 300,
    FarmDistance = 6,
    Weapon = "Melee",
    Skills = {Z = false, X = false, C = false, V = false},
    CurrentTween = nil,
    DodgeTick = 0
}

-- ========================================== --
-- GELİŞMİŞ 3D DODGE VE FİZİK
-- ========================================== --
local function getChar(plr)
    local p = plr or Player
    return p.Character or p.CharacterAdded:Wait()
end

local function stopMovement()
    if getgenv().Kaygisiz.CurrentTween then getgenv().Kaygisiz.CurrentTween:Cancel() end
    local root = getChar():FindFirstChild("HumanoidRootPart")
    if root then root.Velocity = Vector3.new(0,0,0) end
end

-- Anti-Skill Dodge Algoritması (Rastgele Sarmal Hareket)
local function getDodgeOffset()
    getgenv().Kaygisiz.DodgeTick = getgenv().Kaygisiz.DodgeTick + 0.2
    local x = math.sin(getgenv().Kaygisiz.DodgeTick) * 12 -- Geniş sağ-sol
    local y = math.cos(getgenv().Kaygisiz.DodgeTick * 0.5) * 5 -- Yukarı-aşağı dalgalanma
    local z = math.cos(getgenv().Kaygisiz.DodgeTick) * 12 -- Ön-arka rotasyon
    return Vector3.new(x, getgenv().Kaygisiz.FarmDistance + y, z)
end

local function kaygisizTween(targetCFrame)
    local root = getChar():WaitForChild("HumanoidRootPart")
    local dist = (root.Position - targetCFrame.Position).Magnitude
    local tween = TweenService:Create(root, TweenInfo.new(dist / getgenv().Kaygisiz.TweenSpeed, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
    getgenv().Kaygisiz.CurrentTween = tween
    tween:Play()
    return tween
end

-- ========================================== --
-- SALDIRI VE HEDEFLEME
-- ========================================== --
local function attackLogic()
    VirtualUser:CaptureController()
    VirtualUser:Button1Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    
    local vim = game:GetService("VirtualInputManager")
    for skill, active in pairs(getgenv().Kaygisiz.Skills) do
        if active then
            vim:SendKeyEvent(true, Enum.KeyCode[skill], false, game)
            task.wait(0.01)
            vim:SendKeyEvent(false, Enum.KeyCode[skill], false, game)
        end
    end
end

-- En Yakın Oyuncuyu Bul (PvP için)
local function getClosestPlayer()
    local target, dist = nil, math.huge
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= Player and v.Character and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
            local d = (getChar().HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude
            if d < dist then
                dist = d
                target = v
            end
        end
    end
    return target
end

-- ========================================== --
-- ARAYÜZ TASARIMI (V6)
-- ========================================== --
local Window = Rayfield:CreateWindow({
   Name = "KAYGISIZ ENGINE | V6 GOD MODE",
   LoadingTitle = "Bounty Hunter Edition",
   Theme = "DarkBlue",
   ConfigurationSaving = {Enabled = false}
})

local FarmTab = Window:CreateTab("Auto Farm", 4483362458)
local PVPTab = Window:CreateTab("Player Hunter", 4483362458)
local ConfigTab = Window:CreateTab("Ayarlar", 4483362458)

-- ========================================== --
-- NPC FARM (GELİŞMİŞ DODGE İLE)
-- ========================================== --
FarmTab:CreateDropdown({
    Name = "Silah Seç",
    Options = {"Melee", "Sword", "Blox Fruit", "Gun"},
    CurrentOption = {"Melee"},
    Callback = function(opt) getgenv().Kaygisiz.Weapon = opt[1] end,
})

FarmTab:CreateToggle({
   Name = "Auto Farm (God Dodge)",
   CurrentValue = false,
   Callback = function(Value)
        getgenv().Kaygisiz.AutoFarm = Value
        if not Value then stopMovement() end
        
        task.spawn(function()
            while getgenv().Kaygisiz.AutoFarm do
                task.wait(0.1)
                pcall(function()
                    local target = nil
                    for _, v in pairs(workspace.Enemies:GetChildren()) do
                        if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then target = v break end
                    end
                    
                    if target and getgenv().Kaygisiz.AutoFarm then
                        local root = getChar().HumanoidRootPart
                        while getgenv().Kaygisiz.AutoFarm and target.Parent and target.Humanoid.Health > 0 do
                            -- 3D Spiral Dodge Hareketini Uygula
                            local dodgePos = target.HumanoidRootPart.Position + getDodgeOffset()
                            root.CFrame = CFrame.lookAt(dodgePos, target.HumanoidRootPart.Position)
                            
                            -- Silah ve Saldırı
                            attackLogic()
                            task.wait(0.1)
                        end
                    end
                end)
            end
        end)
   end,
})

-- ========================================== --
-- PLAYER HUNTER (BOUNTY FARM)
-- ========================================== --
PVPTab:CreateSection("Oyuncu Avcısı")

PVPTab:CreateToggle({
   Name = "Otomatik Oyuncu Avla (En Yakın)",
   CurrentValue = false,
   Callback = function(Value)
        getgenv().Kaygisiz.AutoPlayer = Value
        if not Value then stopMovement() end
        
        task.spawn(function()
            while getgenv().Kaygisiz.AutoPlayer do
                task.wait(0.1)
                local targetPlayer = getClosestPlayer()
                if targetPlayer and getgenv().Kaygisiz.AutoPlayer then
                    local targetChar = targetPlayer.Character
                    while getgenv().Kaygisiz.AutoPlayer and targetChar and targetChar.Humanoid.Health > 0 do
                        local root = getChar().HumanoidRootPart
                        -- Oyuncunun arkasına veya üstüne dodge yaparak yapış
                        local dodgePos = targetChar.HumanoidRootPart.Position + getDodgeOffset()
                        root.CFrame = CFrame.lookAt(dodgePos, targetChar.HumanoidRootPart.Position)
                        
                        attackLogic()
                        task.wait(0.05) -- PvP için daha hızlı tepki
                    end
                end
            end
        end)
   end,
})

-- ========================================== --
-- AYARLAR VE SKİLLER
-- ========================================== --
ConfigTab:CreateSection("Yetenek Ayarları")
ConfigTab:CreateToggle({Name = "Z Skill", CurrentValue = false, Callback = function(v) getgenv().Kaygisiz.Skills.Z = v end})
ConfigTab:CreateToggle({Name = "X Skill", CurrentValue = false, Callback = function(v) getgenv().Kaygisiz.Skills.X = v end})
ConfigTab:CreateToggle({Name = "C Skill", CurrentValue = false, Callback = function(v) getgenv().Kaygisiz.Skills.C = v end})
ConfigTab:CreateToggle({Name = "V Skill", CurrentValue = false, Callback = function(v) getgenv().Kaygisiz.Skills.V = v end})

ConfigTab:CreateSection("Sistem")
ConfigTab:CreateButton({
   Name = "Hileyi Unload Et",
   Callback = function()
        getgenv().Kaygisiz.AutoFarm = false
        getgenv().Kaygisiz.AutoPlayer = false
        stopMovement()
        Rayfield:Destroy()
   end,
})

Rayfield:LoadConfiguration()
