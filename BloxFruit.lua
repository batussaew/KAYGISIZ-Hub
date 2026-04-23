-- [[ KAYGISIZ ENGINE V4 | PERFECT BLOX FRUITS SCRIPT ]] --
-- GitHub: batussaew/KAYGISIZ-Hub

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Player = Players.LocalPlayer

-- ========================================== --
-- GLOBAL DEĞİŞKENLER
-- ========================================== --
getgenv().Kaygisiz = {
    AutoFarm = false,
    AutoChest = false,
    AntiAfk = false,
    TweenSpeed = 300,
    FarmDistance = 10, -- Biraz daha yüksekten ve uzaktan vurması için arttırıldı
    Weapon = "Melee",
    Skills = {Z = false, X = false, C = false, V = false},
    Connections = {}
}

-- ========================================== --
-- YARDIMCI FONKSİYONLAR
-- ========================================== --
local function getChar()
    return Player.Character or Player.CharacterAdded:Wait()
end

local function stabilizeCharacter()
    local char = getChar()
    if char and char:FindFirstChild("HumanoidRootPart") then
        local root = char.HumanoidRootPart
        root.Velocity = Vector3.new(0, 0, 0)
        root.RotVelocity = Vector3.new(0, 0, 0)
    end
end

-- Sadece uzak mesafeler için Tween
local function kaygisizTween(targetCFrame)
    local char = getChar()
    local root = char:WaitForChild("HumanoidRootPart")
    local dist = (root.Position - targetCFrame.Position).Magnitude
    
    local timeToTravel = dist / getgenv().Kaygisiz.TweenSpeed
    local tweenInfo = TweenInfo.new(timeToTravel, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(root, tweenInfo, {CFrame = targetCFrame})
    tween:Play()
    return tween, dist
end

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

local function executeAttack()
    pcall(function()
        -- Düz Vuruş
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
        
        -- Skiller
        if getgenv().Kaygisiz.Skills.Z then VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Z, false, game) task.wait(0.05) VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Z, false, game) end
        if getgenv().Kaygisiz.Skills.X then VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.X, false, game) task.wait(0.05) VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.X, false, game) end
        if getgenv().Kaygisiz.Skills.C then VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.C, false, game) task.wait(0.05) VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.C, false, game) end
        if getgenv().Kaygisiz.Skills.V then VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.V, false, game) task.wait(0.05) VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.V, false, game) end
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
-- ARAYÜZ (KAYGISIZ DARK PURPLE)
-- ========================================== --
local Window = Rayfield:CreateWindow({
   Name = "KAYGISIZ ENGINE | Blox Fruits V4",
   LoadingTitle = "Kaygısız Yükleniyor...",
   LoadingSubtitle = "Kusursuz Çekirdek",
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
FarmTab:CreateToggle({Name = "Z Skilli Kullan", CurrentValue = false, Flag = "sz", Callback = function(v) getgenv().Kaygisiz.Skills.Z = v end})
FarmTab:CreateToggle({Name = "X Skilli Kullan", CurrentValue = false, Flag = "sx", Callback = function(v) getgenv().Kaygisiz.Skills.X = v end})
FarmTab:CreateToggle({Name = "C Skilli Kullan", CurrentValue = false, Flag = "sc", Callback = function(v) getgenv().Kaygisiz.Skills.C = v end})
FarmTab:CreateToggle({Name = "V Skilli Kullan", CurrentValue = false, Flag = "sv", Callback = function(v) getgenv().Kaygisiz.Skills.V = v end})

FarmTab:CreateSection("Başlat")
local farmAngle = 0
FarmTab:CreateToggle({
   Name = "Auto Farm Başlat",
   CurrentValue = false,
   Flag = "FarmToggle",
   Callback = function(Value)
        getgenv().Kaygisiz.AutoFarm = Value
        if Value then
            getgenv().Kaygisiz.Connections["FarmLoop"] = RunService.Heartbeat:Connect(function()
                if getgenv().Kaygisiz.AutoFarm then
                    local target = getEnemy()
                    local char = getChar()
                    if target and target:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("HumanoidRootPart") then
                        stabilizeCharacter()
                        equipWeapon()
                        
                        local root = char.HumanoidRootPart
                        local targetRoot = target.HumanoidRootPart
                        local dist = (root.Position - targetRoot.Position).Magnitude
                        
                        -- Aimbot: Kamerayı ve karakteri hedefe kilitle
                        workspace.CurrentCamera.CFrame = CFrame.lookAt(workspace.CurrentCamera.CFrame.Position, targetRoot.Position)
                        
                        if dist > 30 then
                            -- Uzaktaysa önce Tween ile yanına git
                            kaygisizTween(targetRoot.CFrame * CFrame.new(0, getgenv().Kaygisiz.FarmDistance, 0))
                        else
                            -- Yakındaysa etrafında dairesel hareket yap (Strafing / Kiting)
                            farmAngle = farmAngle + 0.1
                            local offsetX = math.sin(farmAngle) * 8
                            local offsetZ = math.cos(farmAngle) * 8
                            
                            local dodgePosition = targetRoot.Position + Vector3.new(offsetX, getgenv().Kaygisiz.FarmDistance, offsetZ)
                            -- Yüzünü yaratığa dönerek hareket et
                            root.CFrame = CFrame.lookAt(dodgePosition, targetRoot.Position)
                            
                            executeAttack()
                        end
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
   Name = "Auto Chest (Tüm Harita)",
   CurrentValue = false,
   Flag = "ChestToggle",
   Callback = function(Value)
        getgenv().Kaygisiz.AutoChest = Value
        spawn(function()
            while getgenv().Kaygisiz.AutoChest do
                task.wait(1)
                pcall(function()
                    local foundChest = false
                    -- Tüm haritayı derinlemesine tara
                    for _, v in pairs(workspace:GetDescendants()) do
                        if getgenv().Kaygisiz.AutoChest and (v.Name:find("Chest") or v.Name:find("chest")) then
                            local targetPart = nil
                            
                            if v:IsA("Part") or v:IsA("MeshPart") then
                                targetPart = v
                            elseif v:IsA("Model") then
                                targetPart = v.PrimaryPart or v:FindFirstChildWhichIsA("Part") or v:FindFirstChildWhichIsA("MeshPart")
                            end
                            
                            if targetPart then
                                foundChest = true
                                stabilizeCharacter()
                                local tween = kaygisizTween(targetPart.CFrame)
                                if tween then tween.Completed:Wait() end
                                task.wait(0.3) -- Alması için zaman tanı
                            end
                        end
                    end
                    
                    if not foundChest then
                        task.wait(3)
                    end
                end)
            end
        end)
   end,
})

-- ========================================== --
-- AYARLAR VE UNLOAD
-- ========================================== --
ConfigTab:CreateSlider({
   Name = "Işınlanma Hızı",
   Range = {150, 450},
   Increment = 10,
   Suffix = "Hız",
   CurrentValue = 300,
   Flag = "TwnSpd",
   Callback = function(Value) getgenv().Kaygisiz.TweenSpeed = Value end,
})

ConfigTab:CreateToggle({
   Name = "Anti-AFK (Zıplama Koruması)",
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
        getgenv().Kaygisiz.AutoFarm = false
        getgenv().Kaygisiz.AutoChest = false
        getgenv().Kaygisiz.AntiAfk = false
        
        for k, v in pairs(getgenv().Kaygisiz.Connections) do
            if v then v:Disconnect() end
        end
        
        Rayfield:Destroy()
   end,
})
