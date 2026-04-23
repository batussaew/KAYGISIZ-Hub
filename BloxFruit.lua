-- [[ KAYGISIZ ENGINE V8.2 | FLUENT EDITION (STABLE) ]] --
-- Menü Kısayolu: K Tuşu

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Player = Players.LocalPlayer

-- ========================================== --
-- DİNAMİK ADA VE DENİZ VERİTABANI
-- ========================================== --
local PlaceID = game.PlaceId
local IslandList = {}
local CurrentSea = "Bilinmiyor"

if PlaceID == 2753915549 then
    CurrentSea = "Sea 1"
    IslandList = {
        ["Starter Island"] = CFrame.new(979, 16, 1373),
        ["Jungle"] = CFrame.new(-1612, 36, 149),
        ["Pirate Village"] = CFrame.new(-1184, 4, 3803),
        ["Desert"] = CFrame.new(896, 6, 4389),
        ["Frozen Village"] = CFrame.new(1184, 27, -1208),
        ["Marine Fortress"] = CFrame.new(-4859, 20, 4296),
        ["Skypiea"] = CFrame.new(-4968, 717, -2622),
        ["Magma Village"] = CFrame.new(-5291, 8, 8503)
    }
elseif PlaceID == 4442272183 then
    CurrentSea = "Sea 2"
    IslandList = {
        ["Cafe"] = CFrame.new(-380, 73, 300),
        ["Kingdom of Rose"] = CFrame.new(717, 73, 908),
        ["Green Zone"] = CFrame.new(-2448, 73, -3221),
        ["Graveyard"] = CFrame.new(-5735, 122, -7254),
        ["Dark Arena"] = CFrame.new(3780, 22, -3565),
        ["Snow Mountain"] = CFrame.new(868, 400, -3050),
        ["Hot and Cold"] = CFrame.new(-5373, 15, -5100),
        ["Ice Castle"] = CFrame.new(6143, 332, -6776),
        ["Forgotten Island"] = CFrame.new(-3035, 237, -10175)
    }
elseif PlaceID == 7449423635 then
    CurrentSea = "Sea 3"
    IslandList = {
        ["Mansion"] = CFrame.new(-12482, 332, -8056),
        ["Port Town"] = CFrame.new(-260, 49, 5322),
        ["Hydra Island"] = CFrame.new(5749, 610, -253),
        ["Castle on the Sea"] = CFrame.new(-5035, 314, -3179),
        ["Floating Turtle"] = CFrame.new(-13274, 531, -7579),
        ["Great Tree"] = CFrame.new(2341, 237, -6990)
    }
end

local IslandNames = {}
for name, _ in pairs(IslandList) do 
    table.insert(IslandNames, name) 
end
table.sort(IslandNames)

if #IslandNames == 0 then
    table.insert(IslandNames, "Ada Bulunamadı")
end

-- ========================================== --
-- GLOBAL AYARLAR
-- ========================================== --
getgenv().Kaygisiz = {
    AutoFarm = false, AutoChest = false, SelectedIsland = IslandNames[1],
    FarmSpeed = 300, ChestSpeed = 350, FarmDistance = 7,
    Weapon = "Melee", Skills = {Z = false, X = false, C = false, V = false},
    CurrentTween = nil
}

-- ========================================== --
-- FİZİK VE GÜVENLİK
-- ========================================== --
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
    getgenv().Kaygisiz.CurrentTween = TweenService:Create(root, TweenInfo.new(dist / speed, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
    getgenv().Kaygisiz.CurrentTween:Play()
    return getgenv().Kaygisiz.CurrentTween
end

RunService.Stepped:Connect(function()
    if getgenv().Kaygisiz.AutoFarm or getgenv().Kaygisiz.AutoChest then
        local char = getChar()
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
            end
        end
    end
end)

-- ========================================== --
-- GÜVENLİ SERVER HOP (JSON HATASI ÇÖZÜMÜ)
-- ========================================== --
local function safeServerHop()
    Fluent:Notify({Title = "Server Hop", Content = "Sunucu aranıyor, lütfen bekle...", Duration = 3})
    
    task.spawn(function()
        local success, err = pcall(function()
            local url = "https://games.roproxy.com/v1/games/" .. PlaceID .. "/servers/Public?sortOrder=Desc&limit=100"
            local response = game:HttpGet(url)
            
            -- Gelen veri gerçekten JSON formatında mı diye kontrol et (HTML hatalarını engeller)
            if response and string.find(response, '{"') then
                local decoded = HttpService:JSONDecode(response)
                if decoded and decoded.data then
                    for _, server in ipairs(decoded.data) do
                        if server.playing < (server.maxPlayers - 1) and server.id ~= game.JobId then
                            TeleportService:TeleportToPlaceInstance(PlaceID, server.id, Player)
                            return
                        end
                    end
                end
            else
                Fluent:Notify({Title = "Hata", Content = "Proxy engellendi, tekrar dene.", Duration = 3})
            end
        end)
        
        if not success then
            Fluent:Notify({Title = "Sistem Hatası", Content = "Sunucu listesi alınamadı.", Duration = 3})
        end
    end)
end

-- ========================================== --
-- ARAYÜZ KURULUMU (K TUŞU)
-- ========================================== --
local Window = Fluent:CreateWindow({
    Title = "KAYGISIZ ENGINE",
    SubTitle = "Fluent Edition V8.2",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.K -- MENÜ KISAYOL TUŞU BURADA K OLARAK AYARLANDI
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main Farm", Icon = "swords" }),
    Island = Window:AddTab({ Title = "Island Farm", Icon = "map" }),
    World = Window:AddTab({ Title = "World & Chest", Icon = "box" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

Window:SelectTab(1)
Fluent:Notify({Title = "Hoş Geldin!", Content = CurrentSea .. " Haritası Yüklendi.", Duration = 5})

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
                            
                            -- Silah Kuşan ve Vur
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
-- 2. ISLAND FARM (DİNAMİK DENİZ)
-- ========================================== --
Tabs.Island:AddParagraph({Title = "Mevcut Konum Bilgisi", Content = "Aktif Deniz: " .. CurrentSea})

Tabs.Island:AddDropdown("IslandDrop", {
    Title = "Adayı Seç", Values = IslandNames, Default = 1,
    Callback = function(v) getgenv().Kaygisiz.SelectedIsland = v end
})

Tabs.Island:AddButton({
    Title = "Seçili Adaya Işınlan",
    Callback = function()
        if IslandList[getgenv().Kaygisiz.SelectedIsland] then
            Fluent:Notify({Title = "Işınlanıyor", Content = getgenv().Kaygisiz.SelectedIsland .. " hedefine gidiliyor.", Duration = 3})
            doTween(IslandList[getgenv().Kaygisiz.SelectedIsland], getgenv().Kaygisiz.FarmSpeed)
        end
    end
})

Tabs.Island:AddSection("Deniz Değiştirme (Sea Travel)")
Tabs.Island:AddButton({Title = "Sea 1'e Git", Callback = function() TeleportService:Teleport(2753915549, Player) end})
Tabs.Island:AddButton({Title = "Sea 2'ye Git", Callback = function() TeleportService:Teleport(4442272183, Player) end})
Tabs.Island:AddButton({Title = "Sea 3'e Git", Callback = function() TeleportService:Teleport(7449423635, Player) end})

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

Tabs.World:AddButton({Title = "Server Hop (Kusursuz)", Callback = safeServerHop})

-- ========================================== --
-- 4. SETTINGS
-- ========================================== --
Tabs.Settings:AddSlider("FSpeed", {Title = "Farm Işınlanma Hızı", Min = 150, Max = 500, Default = 300, Callback = function(v) getgenv().Kaygisiz.FarmSpeed = v end})
Tabs.Settings:AddSlider("CSpeed", {Title = "Chest Işınlanma Hızı", Min = 150, Max = 600, Default = 350, Callback = function(v) getgenv().Kaygisiz.ChestSpeed = v end})

Tabs.Settings:AddSection("Sistem Kontrolü")
Tabs.Settings:AddButton({Title = "Hileyi Tamamen Kapat (Unload)", Callback = function()
    getgenv().Kaygisiz.AutoFarm = false
    getgenv().Kaygisiz.AutoChest = false
    stopMovement()
    Window:Destroy()
end})
