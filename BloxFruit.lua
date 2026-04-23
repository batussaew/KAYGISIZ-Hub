-- [[ KAYGISIZ ENGINE V10 | ULTIMATE OVERRIDE ]] --
-- Menü Kısayolu: K Tuşu

if not game:IsLoaded() then game.Loaded:Wait() end

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Player = Players.LocalPlayer

-- ========================================== --
-- BÜTÜN ADALARIN KESİN KOORDİNATLARI (MANUEL SİSTEM)
-- ========================================== --
local IslandDB = {
    ["Sea 1"] = {
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
    },
    ["Sea 2"] = {
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
    },
    ["Sea 3"] = {
        ["Malikane (Mansion)"] = CFrame.new(-12482, 332, -8056),
        ["Liman Şehri (Port Town)"] = CFrame.new(-260, 49, 5322),
        ["Hidra Adası (Hydra)"] = CFrame.new(5749, 610, -253),
        ["Büyük Ağaç (Great Tree)"] = CFrame.new(2341, 237, -6990),
        ["Denizdeki Kale (Castle on Sea)"] = CFrame.new(-5035, 314, -3179),
        ["Perili Kale (Haunted Castle)"] = CFrame.new(-9515, 142, 5530),
        ["Fıstık Adası (Peanut)"] = CFrame.new(-2070, 38, -10216)
    }
}

-- İsimleri Çekme Fonksiyonu
local function getIslandNames(seaName)
    local list = {}
    for name, _ in pairs(IslandDB[seaName]) do table.insert(list, name) end
    table.sort(list)
    return list
end

-- ========================================== --
-- GLOBAL DEĞİŞKENLER VE MOTOR
-- ========================================== --
getgenv().Kaygisiz = {
    AutoFarm = false, AutoChest = false, 
    CurrentSeaMode = "Sea 1", -- Varsayılan
    SelectedIsland = "", 
    FarmSpeed = 300, ChestSpeed = 350, FarmDistance = 7,
    Weapon = "Melee", Skills = {Z = false, X = false, C = false, V = false},
    CurrentTween = nil
}

getgenv().Kaygisiz.SelectedIsland = getIslandNames("Sea 1")[1]

local function getChar() return Player.Character or Player.CharacterAdded:Wait() end

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

local function doTween(targetCFrame, speed)
    if getgenv().Kaygisiz.CurrentTween then getgenv().Kaygisiz.CurrentTween:Cancel() end
    local root = getChar():WaitForChild("HumanoidRootPart")
    local dist = (root.Position - targetCFrame.Position).Magnitude
    
    stabilize()
    
    local twnInfo = TweenInfo.new(dist / speed, Enum.EasingStyle.Linear)
    getgenv().Kaygisiz.CurrentTween = TweenService:Create(root, twnInfo, {CFrame = targetCFrame})
    getgenv().Kaygisiz.CurrentTween:Play()
    return getgenv().Kaygisiz.CurrentTween
end

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
    SubTitle = "V10 - Manuel Override Sistemi",
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

Window:SelectTab(2)
Fluent:Notify({Title = "V10 Yüklendi", Content = "ID bypass edildi, denizi manuel seçin.", Duration = 5})

-- ========================================== --
-- 2. ISLAND FARM (ID BYPASS - MANUAL OVERRIDE)
-- ========================================== --
Tabs.Island:AddParagraph({Title = "Bilgi", Content = "Oyun ID okuması devre dışı bırakıldı. Hangi denizdeyseniz aşağıdan kendiniz seçin."})

-- DENİZ SEÇİMİ (BURASI ADALARI GÜNCELLEYECEK)
local IslandDropdown -- Önceden tanımlıyoruz ki içi güncellenebilsin

Tabs.Island:AddDropdown("SeaOverride", {
    Title = "1. Bulunduğun Denizi Seç", 
    Values = {"Sea 1", "Sea 2", "Sea 3"}, 
    Default = 1,
    Callback = function(seaName) 
        getgenv().Kaygisiz.CurrentSeaMode = seaName
        local newIslands = getIslandNames(seaName)
        getgenv().Kaygisiz.SelectedIsland = newIslands[1]
        
        -- Deniz değişince alt kısımdaki ada listesini güncelle
        if IslandDropdown then
            IslandDropdown:SetValues(newIslands)
            IslandDropdown:SetValue(newIslands[1])
        end
    end
})

-- ADA SEÇİMİ (DİNAMİK)
IslandDropdown = Tabs.Island:AddDropdown("IslandDrop", {
    Title = "2. Gitmek İstediğin Adayı Seç", 
    Values = getIslandNames("Sea 1"), 
    Default = 1,
    Callback = function(v) 
        getgenv().Kaygisiz.SelectedIsland = v 
    end
})

Tabs.Island:AddButton({
    Title = "Seçili Adaya Uç",
    Callback = function()
        local seciliDeniz = getgenv().Kaygisiz.CurrentSeaMode
        local seciliAda = getgenv().Kaygisiz.SelectedIsland
        local hedefCFrame = IslandDB[seciliDeniz][seciliAda]
        
        if hedefCFrame then
            Fluent:Notify({Title = "Işınlanıyor", Content = seciliAda .. " konumuna gidiliyor.", Duration = 3})
            doTween(hedefCFrame, getgenv().Kaygisiz.FarmSpeed)
        else
            Fluent:Notify({Title = "Hata", Content = "Ada bulunamadı!", Duration = 3})
        end
    end
})

Tabs.Island:AddButton({Title = "Uçuşu / Farmı Durdur", Callback = stopMovement})

Tabs.Island:AddSection("Farklı Denize Geçiş (Loadlama)")
Tabs.Island:AddButton({Title = "Sea 1 Sunucusuna Geç", Callback = function() TeleportService:Teleport(2753915549, Player) end})
Tabs.Island:AddButton({Title = "Sea 2 Sunucusuna Geç", Callback = function() TeleportService:Teleport(4442272183, Player) end})
Tabs.Island:AddButton({Title = "Sea 3 Sunucusuna Geç", Callback = function() TeleportService:Teleport(7449423635, Player) end})

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
-- 3. WORLD & CHEST
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

Tabs.World:AddButton({Title = "Server Hop (Güvenli Bypass)", Callback = function()
    Fluent:Notify({Title = "Server Hop", Content = "Sunucu aranıyor...", Duration = 3})
    task.spawn(function()
        pcall(function()
            local response = game:HttpGet("https://games.roproxy.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100")
            if response and string.find(response, '{"') then
                local decoded = HttpService:JSONDecode(response)
                for _, server in ipairs(decoded.data) do
                    if server.playing < (server.maxPlayers - 1) and server.id ~= game.JobId then
                        TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, Player)
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
Tabs.Settings:AddSlider("FSpeed", {Title = "Uçuş Hızı (Farm & Adalar)", Min = 150, Max = 500, Default = 300, Callback = function(v) getgenv().Kaygisiz.FarmSpeed = v end
