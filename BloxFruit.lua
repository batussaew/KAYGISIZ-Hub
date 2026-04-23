-- [[ KAYGISIZ ENGINE V1 | PREMIUM BLOX FRUITS SCRIPT ]] --
-- GitHub: batussaew/KAYGISIZ-Hub

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

-- Global Ayarlar
_G.AutoFarm = false
_G.AutoChest = false
_G.TweenSpeed = 300 -- Anti-Cheat için güvenli limit (300 civarı iyidir)
_G.FarmDistance = 7 -- NPC'nin ne kadar üstünde duracağı

-- ========================================== --
-- CORE FONKSİYONLAR (BAN BYPASS SİSTEMİ)
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

-- Noclip: Objelerin içinden geçerek takılmayı ve AC Kick'ini önleme
RunService.Stepped:Connect(function()
    if _G.AutoFarm or _G.AutoChest then
        local char = getCharacter()
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide == true then
                part.CanCollide = false
            end
        end
    end
end)

-- Otomatik Saldırı Simülasyonu
local function autoAttack()
    local vu = game:GetService("VirtualUser")
    vu:CaptureController()
    vu:Button1Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end

-- ========================================== --
-- OYUN MANTIKLARI (LOGIC)
-- ========================================== --

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
-- RAYFIELD ARAYÜZ (GUI) TASARIMI
-- ========================================== --

local Window = Rayfield:CreateWindow({
   Name = "KAYGISIZ ENGINE | Blox Fruits",
   LoadingTitle = "Kaygısız Yükleniyor...",
   LoadingSubtitle = "By Batu",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "KaygisizEngine",
      FileName = "BloxFruits"
   },
   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true
   },
   KeySystem = false -- Key sistemini şimdilik kapalı tuttuk
})

-- SAKMELER (TABS)
local FarmTab = Window:CreateTab("Auto Farm", 4483362458)
local ChestTab = Window:CreateTab("Auto Chest", 4483362458)
local PlayerTab = Window:CreateTab("Oyuncu", 4483362458)

-- ========================================== --
-- AUTO FARM BÖLÜMÜ
-- ========================================== --

FarmTab:CreateSection("Ana Farm Ayarları")

FarmTab:CreateToggle({
   Name = "Otomatik Farm (En Yakın)",
   CurrentValue = false,
   Flag = "ToggleFarm",
   Callback = function(Value)
        _G.AutoFarm = Value
        while _G.AutoFarm do
            task.wait(0.1)
            local target = getClosestNPC()
            if target and target:FindFirstChild("HumanoidRootPart") then
                -- Güvenli irtifada uç ve vur
                kaygisizTween(target.HumanoidRootPart.CFrame * CFrame.new(0, _G.FarmDistance, 0))
                autoAttack()
            end
        end
   end,
})

FarmTab:CreateSlider({
   Name = "Uçuş Hızı (Tween Speed)",
   Range = {100, 500},
   Increment = 10,
   Suffix = "Hız",
   CurrentValue = 300,
   Flag = "SliderSpeed",
   Callback = function(Value)
        _G.TweenSpeed = Value
   end,
})

-- ========================================== --
-- AUTO CHEST BÖLÜMÜ
-- ========================================== --

ChestTab:CreateSection("Kutu Toplama Modu")

ChestTab:CreateToggle({
   Name = "Otomatik Kutu Topla",
   CurrentValue = false,
   Flag = "ToggleChest",
   Callback = function(Value)
        _G.AutoChest = Value
        while _G.AutoChest do
            task.wait(0.5)
            local char = getCharacter()
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then return end

            local chestFound = false
            for _, obj in pairs(workspace:GetChildren()) do
                if obj.Name:match("Chest") and obj:IsA("Part") then
                    chestFound = true
                    kaygisizTween(obj.CFrame)
                    task.wait(0.5) -- Kutuyu aldıktan sonra AC şüphelenmesin diye ufak bekleme
                    break -- Bir sonraki döngüde diğerine geçer
                end
            end
            
            if not chestFound then
                Rayfield:Notify({
                   Title = "Bilgi",
                   Content = "Haritada kutu kalmadı, yenilerinin doğması bekleniyor...",
                   Duration = 3,
                   Image = 4483362458,
                })
                task.wait(5) -- Kutu yoksa 5 saniye dinlen (Performans için)
            end
        end
   end,
})

-- ========================================== --
-- OYUNCU (PLAYER) BÖLÜMÜ
-- ========================================== --

PlayerTab:CreateSection("Karakter Ayarları")

PlayerTab:CreateButton({
   Name = "Anti-AFK Aktif Et",
   Callback = function()
        Player.Idled:Connect(function()
            local vu = game:GetService("VirtualUser")
            vu:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
            task.wait(1)
            vu:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        end)
        Rayfield:Notify({Title = "Başarılı", Content = "Anti-AFK Çalışıyor, oyundan düşmeyeceksin.", Duration = 3})
   end,
})

Rayfield:LoadConfiguration()
