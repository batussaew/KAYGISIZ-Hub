-- [[ KAYGISIZ ENGINE V2 | ULTIMATE BLOX FRUITS SCRIPT ]] --
-- GitHub: batussaew/KAYGISIZ-Hub

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Player = Players.LocalPlayer

-- Global Değişkenler (Unload yaparken durdurabilmek için)
_G.AutoFarm = false
_G.AutoChest = false
_G.AntiAfk = false
_G.TweenSpeed = 300 
_G.FarmDistance = 7 
_G.SelectedWeapon = "Melee"
_G.UseZ = false
_G.UseX = false
_G.UseC = false
_G.UseV = false

-- ========================================== --
-- TEMA VE ARAYÜZ AYARLARI (KAYGISIZ DARK PURPLE)
-- ========================================== --
local KaygisizTheme = {
    TextColor = Color3.fromRGB(255, 255, 255),
    Background = Color3.fromRGB(15, 12, 16),
    Topbar = Color3.fromRGB(22, 20, 24),
    Shadow = Color3.fromRGB(10, 10, 10),
    NotificationBackground = Color3.fromRGB(22, 20, 24),
    NotificationActionsBackground = Color3.fromRGB(22, 20, 24),
    TabBackground = Color3.fromRGB(22, 20, 24),
    TabStroke = Color3.fromRGB(41, 37, 45),
    TabBackgroundSelected = Color3.fromRGB(36, 32, 39),
    TabTextColor = Color3.fromRGB(185, 185, 185),
    SelectedTabTextColor = Color3.fromRGB(255, 255, 255),
    ElementBackground = Color3.fromRGB(36, 32, 39),
    ElementBackgroundHover = Color3.fromRGB(45, 40, 50),
    SecondaryElementBackground = Color3.fromRGB(41, 37, 45),
    ElementStroke = Color3.fromRGB(41, 37, 45),
    SecondaryElementStroke = Color3.fromRGB(41, 37, 45),
    SliderBackground = Color3.fromRGB(41, 37, 45),
    SliderProgress = Color3.fromRGB(170, 85, 255), -- Kaygısız Moru
    SliderStroke = Color3.fromRGB(41, 37, 45),
    ToggleBackground = Color3.fromRGB(41, 37, 45),
    ToggleEnabled = Color3.fromRGB(170, 85, 255), -- Kaygısız Moru
    ToggleBorders = Color3.fromRGB(41, 37, 45),
    DropdownSelected = Color3.fromRGB(170, 85, 255),
    DropdownUnselected = Color3.fromRGB(41, 37, 45),
    InputBackground = Color3.fromRGB(41, 37, 45),
    InputStroke = Color3.fromRGB(41, 37, 45),
    PlaceholderColor = Color3.fromRGB(185, 185, 185)
}

local Window = Rayfield:CreateWindow({
   Name = "KAYGISIZ ENGINE | Blox Fruits V2",
   LoadingTitle = "Kaygısız Hazırlanıyor...",
   LoadingSubtitle = "By Batu",
   Theme = KaygisizTheme,
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "KaygisizEngine",
      FileName = "BloxFruitsV2"
   },
   KeySystem = false
})

-- ========================================== --
-- CORE FONKSİYONLAR (GÜVENLİK & YARDIMCILAR)
-- ========================================== --

local function getCharacter()
    return Player.Character or Player.CharacterAdded:Wait()
end

local function kaygisizTween(targetCFrame)
    local char = getCharacter()
    local root = char:WaitForChild("HumanoidRootPart")
    local dist = (root.Position - targetCFrame.Position).Magnitude
    local tweenInfo = TweenInfo.new(dist / _G.TweenSpeed, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(root, tweenInfo, {CFrame = targetCFrame})
    tween:Play()
    return tween
end

-- NOCLIP (Duvarlardan geçme, ban yememek için şart)
local noclipLoop = RunService.Stepped:Connect(function()
    if _G.AutoFarm or _G.AutoChest then
        local char = getCharacter()
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

-- SİLAH SEÇİMİ (Melee, Sword, Blox Fruit)
local function equipWeapon()
    local char = getCharacter()
    if not char then return end
    for _, tool in pairs(Player.Backpack:GetChildren()) do
        if tool:IsA("Tool") and tool.ToolTip == _G.SelectedWeapon then
            char.Humanoid:EquipTool(tool)
            break
        end
    end
end

-- SKILL KULLANIMI VE TIKLAMA
local function useSkillsAndAttack()
    local char = getCharacter()
    if not char then return end

    -- Normal Saldırı
    local vu = game:GetService("VirtualUser")
    vu:CaptureController()
    vu:Button1Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)

    -- Skilleri Kullan
    if _G.UseZ then VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Z, false, game) task.wait(0.05) VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Z, false, game) end
    if _G.UseX then VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.X, false, game) task.wait(0.05) VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.X, false, game) end
    if _G.UseC then VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.C, false, game) task.wait(0.05) VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.C, false, game) end
    if _G.UseV then VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.V, false, game) task.wait(0.05) VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.V, false, game) end
end

local function getClosestNPC()
    local closest = nil
    local minDist = math.huge
    local char = getCharacter()
    local root = char:FindFirstChild("HumanoidRootPart")
    
    if not root then return nil end

    for _, v in pairs(workspace.Enemies:GetChildren()) do
        if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
            local mag = (root.Position - v.HumanoidRootPart.Position).Magnitude
            if mag < minDist then
                minDist = mag
                closest = v
            end
        end
    end
    return closest
end

-- ========================================== --
-- SEKMELER (TABS)
-- ========================================== --
local FarmTab = Window:CreateTab("Auto Farm", 4483362458)
local ChestTab = Window:CreateTab("Auto Chest", 4483362458)
local SettingsTab = Window:CreateTab("Ayarlar", 4483362458)

-- ========================================== --
-- AUTO FARM BÖLÜMÜ
-- ========================================== --
FarmTab:CreateSection("Savaş Stratejisi")

FarmTab:CreateDropdown({
    Name = "Silah Seçimi",
    Options = {"Melee", "Sword", "Blox Fruit", "Gun"},
    CurrentOption = {"Melee"},
    MultipleOptions = false,
    Flag = "WeaponDropdown",
    Callback = function(Option)
        _G.SelectedWeapon = Option[1]
    end,
})

FarmTab:CreateSection("Kullanılacak Skiller")
FarmTab:CreateToggle({Name = "Z Yeteneğini Kullan", CurrentValue = false, Flag = "SkillZ", Callback = function(v) _G.UseZ = v end})
FarmTab:CreateToggle({Name = "X Yeteneğini Kullan", CurrentValue = false, Flag = "SkillX", Callback = function(v) _G.UseX = v end})
FarmTab:CreateToggle({Name = "C Yeteneğini Kullan", CurrentValue = false, Flag = "SkillC", Callback = function(v) _G.UseC = v end})
FarmTab:CreateToggle({Name = "V Yeteneğini Kullan", CurrentValue = false, Flag = "SkillV", Callback = function(v) _G.UseV = v end})

FarmTab:CreateSection("Farm Başlat")
FarmTab:CreateToggle({
   Name = "Otomatik Farm (En Yakın)",
   CurrentValue = false,
   Flag = "ToggleFarm",
   Callback = function(Value)
        _G.AutoFarm = Value
        spawn(function()
            while _G.AutoFarm do
                task.wait(0.1)
                local target = getClosestNPC()
                if target and target:FindFirstChild("HumanoidRootPart") then
                    equipWeapon()
                    kaygisizTween(target.HumanoidRootPart.CFrame * CFrame.new(0, _G.FarmDistance, 0))
                    useSkillsAndAttack()
                end
            end
        end)
   end,
})

-- ========================================== --
-- AUTO CHEST BÖLÜMÜ (DÜZELTİLMİŞ)
-- ========================================== --
ChestTab:CreateSection("Sandık Avcısı")

ChestTab:CreateToggle({
   Name = "Otomatik Sandık (Auto Chest)",
   CurrentValue = false,
   Flag = "ToggleChest",
   Callback = function(Value)
        _G.AutoChest = Value
        spawn(function()
            while _G.AutoChest do
                task.wait(0.5)
                local chestFound = false
                
                -- Chest'leri düzgün bulma mantığı
                for _, obj in pairs(workspace:GetChildren()) do
                    if obj.Name:match("Chest") and obj:IsA("Part") or obj:IsA("Model") and obj.Name:match("Chest") then
                        local targetPart = obj:IsA("Part") and obj or obj.PrimaryPart or obj:FindFirstChildWhichIsA("Part")
                        if targetPart then
                            chestFound = true
                            local tween = kaygisizTween(targetPart.CFrame)
                            tween.Completed:Wait() -- Sandığa ulaşana kadar bekle
                            task.wait(0.2) -- Aldıktan sonra azıcık dinlen
                            break
                        end
                    end
                end
                
                if not chestFound then
                    Rayfield:Notify({Title = "KAYGISIZ ENGINE", Content = "Haritada sandık kalmadı, bekleniyor...", Duration = 3})
                    task.wait(5)
                end
            end
        end)
   end,
})

-- ========================================== --
-- AYARLAR VE DİĞER (ANTI-AFK / UNLOAD)
-- ========================================== --
SettingsTab:CreateSection("Güvenlik & Sistem")

SettingsTab:CreateSlider({
   Name = "Uçuş Hızı (Tween Speed)",
   Range = {100, 500},
   Increment = 10,
   Suffix = "Hız",
   CurrentValue = 300,
   Flag = "SliderSpeed",
   Callback = function(Value) _G.TweenSpeed = Value end,
})

SettingsTab:CreateToggle({
   Name = "Anti-AFK (5 Saniyede Bir Zıpla)",
   CurrentValue = false,
   Flag = "ToggleAFK",
   Callback = function(Value)
        _G.AntiAfk = Value
        spawn(function()
            while _G.AntiAfk do
                task.wait(5)
                local char = getCharacter()
                if char and char:FindFirstChild("Humanoid") then
                    char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end)
   end,
})

SettingsTab:CreateSection("Kapatma")

SettingsTab:CreateButton({
   Name = "Hileyi Kapat (Unload)",
   Callback = function()
        -- Bütün döngüleri durdur
        _G.AutoFarm = false
        _G.AutoChest = false
        _G.AntiAfk = false
        
        -- Noclip'i iptal et
        if noclipLoop then noclipLoop:Disconnect() end
        
        -- Arayüzü Yok Et
        Rayfield:Destroy()
        print("KAYGISIZ ENGINE: Hile başarıyla kapatıldı.")
   end,
})

Rayfield:LoadConfiguration()
