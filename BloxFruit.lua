-- [[ KAYGISIZ ENGINE V3 | BLOX FRUITS KUSURSUZ ÇEKİRDEK ]] --
-- GitHub: batussaew/KAYGISIZ-Hub

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Player = Players.LocalPlayer

-- ========================================== --
-- GLOBAL KONTROLLER VE DEĞİŞKENLER
-- ========================================== --
getgenv().Kaygisiz = {
    AutoFarm = false,
    AutoChest = false,
    AntiAfk = false,
    TweenSpeed = 300,
    FarmDistance = 7,
    Weapon = "Melee",
    Skills = {Z = false, X = false, C = false, V = false},
    Connections = {} -- Unload için her şeyi burada tutacağız
}

-- ========================================== --
-- GÜVENLİK, FİZİK VE BYPASS (EN ÖNEMLİ KISIM)
-- ========================================== --
local function getChar()
    return Player.Character or Player.CharacterAdded:Wait()
end

-- Anti-Fling & Havada Sabit Kalma (Karakterin titremesini önler)
local function stabilizeCharacter()
    local char = getChar()
    if char and char:FindFirstChild("HumanoidRootPart") then
        local root = char.HumanoidRootPart
        root.Velocity = Vector3.new(0, 0, 0)
        root.RotVelocity = Vector3.new(0, 0, 0)
    end
end

local function kaygisizTween(targetPos)
    local char = getChar()
    local root = char:WaitForChild("HumanoidRootPart")
    
    local dist = (root.Position - targetPos.Position).Magnitude
    local timeToTravel = dist / getgenv().Kaygisiz.TweenSpeed
    local tweenInfo = TweenInfo.new(timeToTravel, Enum.EasingStyle.Linear)
    
    local tween = TweenService:Create(root, tweenInfo, {CFrame = targetPos})
    tween:Play()
    return tween
end

-- NOCLIP (Duvarlardan ve yerin altından geçme)
getgenv().Kaygisiz.Connections["Noclip"] = RunService.Stepped:Connect(function()
    if getgenv().Kaygisiz.AutoFarm or getgenv().Kaygisiz.AutoChest then
        local char = getChar()
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end
end)

-- ========================================== --
-- SAVAŞ VE SKİLL MANTİĞI
-- ========================================== --
local function equipWeapon()
    pcall(function()
        local char = getChar()
        if not char:FindFirstChild(getgenv().Kaygisiz.Weapon) then
            for _, tool in pairs(Player.Backpack:GetChildren()) do
                if tool:IsA("Tool") and tool.ToolTip == getgenv().Kaygisiz.Weapon then
                    char.Humanoid:EquipTool(tool)
                    break
                end
            end
        end
    end)
end

-- Blox Fruits için Garanti Tıklama ve Skill Kullanımı
local function executeAttack()
    pcall(function()
        -- Hızlı Tıklama
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
        
        -- Skiller
        if getgenv().Kaygisiz.Skills.Z then VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Z, false, game) task.wait(0.01) VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Z, false, game) end
        if getgenv().Kaygisiz.Skills.X then VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.X, false, game) task.wait(0.01) VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.X, false, game) end
        if getgenv().Kaygisiz.Skills.C then VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.C, false, game) task.wait(0.01) VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.C, false, game) end
        if getgenv().Kaygisiz.Skills.V then VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.V, false, game) task.wait(0.01) VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.V, false, game) end
    end)
end

local function getEnemy()
    local closest, minDist = nil, math.huge
    local char = getChar()
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end

    pcall(function()
        for _, v in pairs(workspace.Enemies:GetChildren()) do
            if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
                local mag = (root.Position - v.HumanoidRootPart.Position).Magnitude
                if mag < minDist then
                    minDist = mag
                    closest = v
                end
            end
        end
    end)
    return closest
end

-- ========================================== --
-- ARAYÜZ (KAYGISIZ DARK PURPLE THEME)
-- ========================================== --
local Window = Rayfield:CreateWindow({
   Name = "KAYGISIZ ENGINE | Blox Fruits",
   LoadingTitle = "Kaygısız Yükleniyor...",
   LoadingSubtitle = "Sistem Aktif",
   Theme = {
       TextColor = Color3.fromRGB(255, 255, 255),
       Background = Color3.fromRGB(15, 12, 16),
       Topbar = Color3.fromRGB(22, 20, 24),
       Shadow = Color3.fromRGB(10, 10, 10),
       NotificationBackground = Color3.fromRGB(22, 20, 24),
       TabBackground = Color3.fromRGB(22, 20, 24),
       TabBackgroundSelected = Color3.fromRGB(36, 32, 39),
       TabTextColor = Color3.fromRGB(185, 185, 185),
       SelectedTabTextColor = Color3.fromRGB(255, 255, 255),
       ElementBackground = Color3.fromRGB(36, 32, 39),
       ElementBackgroundHover = Color3.fromRGB(45, 40, 50),
       SecondaryElementBackground = Color3.fromRGB(41, 37, 45),
       SliderProgress = Color3.fromRGB(170, 85, 255),
       ToggleEnabled = Color3.fromRGB(170, 85, 255),
       DropdownSelected = Color3.fromRGB(170, 85, 255)
   },
   ConfigurationSaving = {Enabled = false},
   KeySystem = false
})

local FarmTab = Window:CreateTab("Auto Farm", 4483362458)
local ChestTab = Window:CreateTab("Auto Chest", 4483362458)
local ConfigTab = Window:CreateTab("Ayarlar", 4483362458)

-- ========================================== --
-- FARM SEKMESİ
-- ========================================== --
FarmTab:CreateDropdown({
    Name = "Silahını Seç",
    Options = {"Melee", "Sword", "Blox Fruit", "Gun"},
    CurrentOption = {"Melee"},
    MultipleOptions = false,
    Flag = "WeaponSelect",
    Callback = function(opt) getgenv().Kaygisiz.Weapon = opt[1] end,
})

FarmTab:CreateSection("Skiller")
FarmTab:CreateToggle({Name = "Z Skilli", CurrentValue = false, Flag = "sz", Callback = function(v) getgenv().Kaygisiz.Skills.Z = v end})
FarmTab:CreateToggle({Name = "X Skilli", CurrentValue = false, Flag = "sx", Callback = function(v) getgenv().Kaygisiz.Skills.X = v end})
FarmTab:CreateToggle({Name = "C Skilli", CurrentValue = false, Flag = "sc", Callback = function(v) getgenv().Kaygisiz.Skills.C = v end})
FarmTab:CreateToggle({Name = "V Skilli", CurrentValue = false, Flag = "sv", Callback = function(v) getgenv().Kaygisiz.Skills.V = v end})

FarmTab:CreateSection("Başlat")
FarmTab:CreateToggle({
   Name = "Auto Farm (En Yakın Yaratık)",
   CurrentValue = false,
   Flag = "FarmToggle",
   Callback = function(Value)
        getgenv().Kaygisiz.AutoFarm = Value
        if Value then
            getgenv().Kaygisiz.Connections["FarmLoop"] = RunService.Heartbeat:Connect(function()
                if getgenv().Kaygisiz.AutoFarm then
                    local target = getEnemy()
                    if target and target:FindFirstChild("HumanoidRootPart") then
                        stabilizeCharacter()
                        equipWeapon()
                        -- Yaratığın üstüne ışınlan ve vur
                        kaygisizTween(target.HumanoidRootPart.CFrame * CFrame.new(0, getgenv().Kaygisiz.FarmDistance, 0))
                        executeAttack()
                    end
                end
            end)
        else
            if getgenv().Kaygisiz.Connections["FarmLoop"] then
                getgenv().Kaygisiz.Connections["FarmLoop"]:Disconnect()
            end
        end
   end,
})

-- ========================================== --
-- CHEST SEKMESİ
-- ========================================== --
ChestTab:CreateToggle({
   Name = "Auto Chest Başlat",
   CurrentValue = false,
   Flag = "ChestToggle",
   Callback = function(Value)
        getgenv().Kaygisiz.AutoChest = Value
        spawn(function()
            while getgenv().Kaygisiz.AutoChest do
                task.wait(1)
                pcall(function()
                    for _, v in pairs(workspace:GetDescendants()) do
                        if v.Name:match("Chest") and v:IsA("Part") then
                            if getgenv().Kaygisiz.AutoChest then
                                stabilizeCharacter()
                                kaygisizTween(v.CFrame)
                                task.wait(0.5) -- Kutuyu almak için bekle
                            end
                        end
                    end
                end)
            end
        end)
   end,
})

-- ========================================== --
-- AYARLAR VE UNLOAD (GÜVENLİ KAPANIŞ)
-- ========================================== --
ConfigTab:CreateSlider({
   Name = "Işınlanma Hızı (Bypass İçin)",
   Range = {150, 450},
   Increment = 10,
   Suffix = "Hız",
   CurrentValue = 300,
   Flag = "TwnSpd",
   Callback = function(Value) getgenv().Kaygisiz.TweenSpeed = Value end,
})

ConfigTab:CreateToggle({
   Name = "Anti-AFK (5 Saniyede Bir Zıpla)",
   CurrentValue = false,
   Flag = "AfkToggle",
   Callback = function(Value)
        getgenv().Kaygisiz.AntiAfk = Value
        spawn(function()
            while getgenv().Kaygisiz.AntiAfk do
                task.wait(5)
                pcall(function()
                    local char = getChar()
                    if char and char:FindFirstChild("Humanoid") then
                        char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end)
            end
        end)
   end,
})

ConfigTab:CreateButton({
   Name = "Hileyi Temizle (Unload)",
   Callback = function()
        -- Her şeyi durdur ve sil
        getgenv().Kaygisiz.AutoFarm = false
        getgenv().Kaygisiz.AutoChest = false
        getgenv().Kaygisiz.AntiAfk = false
        
        for k, v in pairs(getgenv().Kaygisiz.Connections) do
            if v then v:Disconnect() end
        end
        
        Rayfield:Destroy()
   end,
})
