-- [[ KAYGISIZ ENGINE V8.4 | DİREKT KOORDİNAT SİSTEMİ ]] --
-- Menü Kısayolu: K Tuşu

if not game:IsLoaded() then game.Loaded:Wait() end
repeat task.wait(0.1) until game.PlaceId ~= 0

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Player = Players.LocalPlayer

-- ========================================== --
-- BÜTÜN ADALARIN KESİN KOORDİNATLARI
-- ========================================== --
local PlaceID = game.PlaceId
local IslandList = {}
local CurrentSea = "Bilinmiyor"

if PlaceID == 2753915549 then
    CurrentSea = "Sea 1"
    IslandList = {
        ["Başlangıç Adası (Starter)"] = CFrame.new(979, 16, 1373),
        ["Orman (Jungle)"] = CFrame.new(-1612, 36, 149),
        ["Korsan Köyü (Pirate Village)"] = CFrame.new(-1184, 4, 3803),
        ["Çöl (Desert)"] = CFrame.new(896, 6, 4389),
        ["Orta Şehir (Middle Town)"] = CFrame.new(-690, 15, 1523),
        ["Kar Köyü (Frozen Village)"] = CFrame.new(1184, 27, -1208),
        ["Marine Kalesi"] = CFrame.new(-4859, 20, 4296),
        ["Gökyüzü Adası (Skypiea)"] = CFrame.new(-4968, 717, -2622),
        ["Hapishane (Prison)"] = CFrame.new(4875, 5, 735),
        ["Magma Köyü"] = CFrame.new(-5291, 8, 8503),
        ["Çeşme Şehri (Fountain)"] = CFrame.new(5127, 38, 4105)
    }
elseif PlaceID == 4442272183 then
    CurrentSea = "Sea 2"
    IslandList = {
        ["Kafe (Cafe / Güvenli Bölge)"] = CFrame.new(-380, 73, 300),
        ["Gül Krallığı (Rose)"] = CFrame.new(717, 73, 908),
        ["Yeşil Bölge (Green Zone)"] = CFrame.new(-2448, 73, -3221),
        ["Mezarlık (Graveyard)"] = CFrame.new(-5735, 122, -7254),
        ["Karlı Dağ (Snow Mountain)"] = CFrame.new(868, 400, -3050),
        ["Sıcak ve Soğuk (Hot & Cold)"] = CFrame.new(-5373, 15, -5100),
        ["Lanetli Gemi (Cursed Ship)"] = CFrame.new(923, 125, 32852),
        ["Buz Kalesi (Ice Castle)"] = CFrame.new(6143, 332, -6776),
        ["Unutulmuş Ada (Forgotten)"] = CFrame.new(-3035, 237, -10175),
        ["Karanlık Arena (Dark Arena)"] = CFrame.new(3780, 22, -3565)
    }
elseif PlaceID == 7449423635 then
    CurrentSea = "Sea 3"
    IslandList = {
        ["Malikane (Mansion)"] = CFrame.new(-12482, 332, -8056),
        ["Liman Şehri (Port Town)"] = CFrame.new(-260, 49, 5322),
        ["Hidra Adası (Hydra)"] = CFrame.new(5749, 610, -253),
        ["Büyük Ağaç (Great Tree)"] = CFrame.new(2341, 237, -6990),
        ["Denizdeki Kale (Castle on Sea)"] = CFrame.new(-5035, 314, -3179),
        ["Perili Kale (Haunted Castle)"] = CFrame.new(-9515, 142, 5530),
        ["Fıstık Adası (Peanut)"] = CFrame.new(-2070, 38, -10216)
    }
end

local IslandNames = {}
for name, _ in pairs(IslandList) do table.insert(IslandNames, name) end
table.sort(IslandNames)

-- Eğer oyun Blox Fruits değilse boş kalmasın diye hata önleyici
if #IslandNames == 0 then table.insert(IslandNames, "Hata: Deniz Bulunamadı") end

-- ========================================== --
-- GLOBAL DEĞİŞKENLER VE MOTOR
-- ========================================== --
getgenv().Kaygisiz = {
    AutoFarm = false, AutoChest = false, 
    SelectedIsland = IslandNames[1], -- Dropdown'ın varsayılanı
    FarmSpeed = 300, ChestSpeed = 350, FarmDistance = 7,
    Weapon = "Melee", Skills = {Z = false, X = false, C = false, V = false},
    CurrentTween = nil
}

local function getChar() return Player.Character or Player.CharacterAdded:Wait() end

-- Sabitleyici (Yerçekimini ve düşmeyi önler)
local function stabilize()
    local root = getChar():FindFirstChild("HumanoidRootPart")
    if root then
        local bv = root:FindFirstChild("KaygisizAntiFall") or Instance.new("BodyVelocity", root)
        bv.Name = "KaygisizAntiFall"
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = Vector3.new(0, 0, 0)
        root.Velocity = Vector3.new(0, 0, 0)
    end
end

local function stopMovement()
    if getgenv().Kaygisiz.CurrentTween then 
        getgenv().Kaygisiz.CurrentTween:Cancel() 
        getgenv().Kaygisiz.CurrentTween = nil
    end
    local root = getChar():FindFirstChild("HumanoidRootPart")
    if root and root:FindFirstChild("KaygisizAntiFall") then
        root.KaygisizAntiFall:Destroy()
    end
end

-- Işınlanma Motoru
local function doTween(targetCFrame, speed)
    if getgenv().Kaygisiz.CurrentTween then getgenv().Kaygisiz.CurrentTween:Cancel() end
    local root = getChar():WaitForChild("HumanoidRootPart")
    local dist = (root.Position - targetCFrame.Position).Magnitude
    
    stabilize() -- Havada asılı kalmasını sağlar
    
    local twnInfo = TweenInfo.new(dist / speed, Enum.EasingStyle.Linear)
    getgenv().Kaygisiz.CurrentTween = TweenService:Create(root, twnInfo, {CFrame = targetCFrame})
    getgenv().Kaygisiz.CurrentTween:Play()
    return getgenv().Kaygisiz.CurrentTween
end

-- Noclip (Duvardan Geçme) - Sadece farm veya chest açıkken çalışır
RunService.Stepped:Connect(function()
    if getgenv().Kaygisiz.AutoFarm or getgenv().Kaygisiz.AutoChest or getgenv().Kaygisiz.CurrentTween then
        local char = getChar()
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
            end
        end
    end
end)

-- ========================================== --
-- ARAYÜZ (GUI) - K TUŞU
-- ========================================== --
local Window = Fluent:CreateWindow({
    Title = "KAYGISIZ ENGINE",
    SubTitle = "V8.4 - Koordinat Sistemi",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.K
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main Farm", Icon = "swords" }),
    Island = Window:AddTab({ Title = "Island Farm", Icon = "map" }),
    World = Window:AddTab({ Title = "World & Chest", Icon = "box" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

Window:SelectTab(2) -- Script açıldığında direkt Ada sekmesini göstersin diye
Fluent:Notify({Title = "Sistem Aktif", Content = CurrentSea .. " Haritası Yüklendi.", Duration = 4})

-- ========================================== --
-- 2. ISLAND FARM (DİREKT KOORDİNAT SİSTEMİ)
-- ========================================== --
Tabs.Island:AddParagraph({Title = "Mevcut Konum Bilgisi", Content = "Aktif Deniz: " .. CurrentSea})

-- Ada Seçimi
Tabs.Island:AddDropdown("IslandDrop", {
    Title = "Adayı Seç", 
    Values = IslandNames, 
    Default = 1,
    Callback = function(v) 
        getgenv().Kaygisiz.SelectedIsland = v 
    end
})

-- Dümdüz Uçma Butonu
Tabs.Island:AddButton({
    Title = "Seçili Adaya Işınlan (Uçarak)",
    Callback = function()
        local seciliAda = getgenv().Kaygisiz.SelectedIsland
        local hedefCFrame = IslandList[seciliAda]
        
        if hedefCFrame then
            Fluent:Notify({Title = "Işınlanıyor", Content = seciliAda .. " konumuna gidiliyor.", Duration = 3})
            -- Uçuş hızını ayardan çeker
            doTween(hedefCFrame, getgenv().Kaygisiz.FarmSpeed)
        else
            Fluent:Notify({Title = "Hata", Content = "Ada koordinatı bulunamadı!", Duration = 3})
        end
    end
})

Tabs.Island:AddButton({Title = "İptal Et / Durdur", Callback = stopMovement})

Tabs.Island:AddSection("Deniz Değiştirme (Sea Travel)")
Tabs.Island:AddButton({Title = "Sea 1'e Git", Callback = function() TeleportService:Teleport(2753915549, Player) end})
Tabs.Island:AddButton({Title = "Sea 2'ye Git", Callback = function() TeleportService:Teleport(4442272183, Player) end})
Tabs.Island:AddButton({Title = "Sea 3'e Git", Callback = function() TeleportService:Teleport(7449423635, Player) end})

-- ========================================== --
-- 1. MAIN FARM
-- ========================================== --
Tabs.Main:AddDropdown("WeaponDrop", {
    Title = "Silah Seçimi", Values = {"Melee", "Sword", "Blox Fruit"}, Default = 1,
    Callback = function(v) getgenv().Kaygisiz.Weapon = v end
})

Tabs.Main:AddToggle("FarmToggle", {Title = "Auto Farm (Yakın Mob)", Default = false}):OnChanged(function(Value)
    getgenv().Kaygisiz.AutoFarm = Value
    if not Value then stopMovement() return end
    
    task.spawn(function()
        while getgenv().Kaygisiz.AutoFarm do
            task.wait(0.1)
            pcall(function()
                local target = nil
                for _, v in pairs(workspace.Enemies:GetChildren()) do
                    if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
                        target = v break
                    end
                end
                
                if target then
                    stabilize()
                    while getgenv().Kaygisiz.AutoFarm and target.Parent and target.Humanoid.Health > 0 do
                        local root = getChar():FindFirstChild("HumanoidRootPart")
                        local dist = (root.Position - target.HumanoidRootPart.Position).Magnitude
                        
                        if dist > 15 then
                            doTween(target.HumanoidRootPart.CFrame * CFrame.new(0, getgenv().Kaygisiz.FarmDistance, 0), getgenv().Kaygisiz.FarmSpeed)
                            task.wait(0.2)
                        else
                            if getgenv().Kaygisiz.CurrentTween then getgenv().Kaygisiz.CurrentTween:Cancel() end
                            root.CFrame = target.HumanoidRootPart.CFrame * CFrame.new(0, getgenv().Kaygisiz.FarmDistance, 0)
                            
                            local char = getChar()
                            if not char:FindFirstChildWhichIsA("Tool") then
                                for _, tool in pairs(Player.Backpack:GetChildren()) do
                                    if tool:IsA("Tool") and (tool.ToolTip == getgenv().Kaygisiz.Weapon or tool.Name == getgenv().Kaygisiz.Weapon) then
                                        char.Humanoid:EquipTool(tool) break
                                    end
                                end
                            end
                            
                            workspace.CurrentCamera.CFrame = CFrame.lookAt(workspace.CurrentCamera.CFrame.Position, target.HumanoidRootPart.Position)
                            VirtualInputManager:SendMouseButtonEvent(0,0,0,true,game,1)
                            VirtualInputManager:SendMouseButtonEvent(0,0,0,false,game,1)
                            task.wait(0.1)
                        end
                    end
                end
            end)
        end
    end)
end)

-- ========================================== --
-- 3. WORLD & CHEST & SERVER HOP
-- ========================================== --
Tabs.World:AddToggle("ChestToggle", {Title = "Auto Chest (Tüm Harita)", Default = false}):OnChanged(function(v)
    getgenv().Kaygisiz.AutoChest = v
    if not v then stopMovement() return end
    
    task.spawn(function()
        while getgenv().Kaygisiz.AutoChest do
            task.wait(0.5)
            pcall(function()
                for _, chest in pairs(workspace:GetDescendants()) do
                    if getgenv().Kaygisiz.AutoChest and chest.Name:find("Chest") and chest:IsA("Part") then
                        local twn = doTween(chest.CFrame, getgenv().Kaygisiz.ChestSpeed)
                        while twn.PlaybackState == Enum.PlaybackState.Playing and getgenv().Kaygisiz.AutoChest do task.wait(0.1) end
                        task.wait(0.3)
                    end
                end
            end)
        end
    end)
end)

Tabs.World:AddButton({Title = "Server Hop (JSON Fixli)", Callback = function()
    Fluent:Notify({Title = "Server Hop", Content = "Sunucu aranıyor...", Duration = 3})
    task.spawn(function()
        pcall(function()
            local response = game:HttpGet("https://games.roproxy.com/v1/games/" .. PlaceID .. "/servers/Public?sortOrder=Desc&limit=100")
            if response and string.find(response, '{"') then
                local decoded = HttpService:JSONDecode(response)
                for _, server in ipairs(decoded.data) do
                    if server.playing < (server.maxPlayers - 1) and server.id ~= game.JobId then
                        TeleportService:TeleportToPlaceInstance(PlaceID, server.id, Player)
                        return
                    end
                end
            end
        end)
    end)
end})

-- ========================================== --
-- 4. SETTINGS
-- ========================================== --
Tabs.Settings:AddSlider("FSpeed", {Title = "Uçuş Hızı (Farm & Adalar)", Min = 150, Max = 500, Default = 300, Callback = function(v) getgenv().Kaygisiz.FarmSpeed = v end})
Tabs.Settings:AddSlider("CSpeed", {Title = "Kutu Toplama Hızı (Chest)", Min = 150, Max = 600, Default = 350, Callback = function(v) getgenv().Kaygisiz.ChestSpeed = v end})

Tabs.Settings:AddButton({Title = "Hileyi Tamamen Kapat (Unload)", Callback = function()
    getgenv().Kaygisiz.AutoFarm = false
    getgenv().Kaygisiz.AutoChest = false
    stopMovement()
    Window:Destroy()
end})
