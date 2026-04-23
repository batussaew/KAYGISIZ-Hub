-- [[ KAYGISIZ ENGINE V8 | FLUENT UI EDITION ]] --
-- GitHub: batussaew/KAYGISIZ-Hub

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Player = Players.LocalPlayer

-- ========================================== --
-- DENİZ (SEA) VE ADA VERİTABANI
-- ========================================== --
local PlaceID = game.PlaceId
local CurrentSea = "Bilinmiyor"
local IslandList = {}

if PlaceID == 2753915549 then
    CurrentSea = "Sea 1 (First Sea)"
    IslandList = {
        ["Başlangıç Adası"] = CFrame.new(979, 16, 1373),
        ["Orman (Jungle)"] = CFrame.new(-1612, 36, 149),
        ["Korsan Köyü"] = CFrame.new(-1184, 4, 3803),
        ["Çöl (Desert)"] = CFrame.new(896, 6, 4389),
        ["Kar Adası (Frozen Village)"] = CFrame.new(1184, 27, -1208),
        ["Marine Kalesi"] = CFrame.new(-4859, 20, 4296),
        ["Skypiea"] = CFrame.new(-4968, 717, -2622),
        ["Magma Köyü"] = CFrame.new(-5291, 8, 8503)
    }
elseif PlaceID == 4442272183 then
    CurrentSea = "Sea 2 (Second Sea)"
    IslandList = {
        ["Kafe (Cafe)"] = CFrame.new(-380, 73, 300),
        ["Gül Krallığı"] = CFrame.new(717, 73, 908),
        ["Yeşil Bölge (Green Zone)"] = CFrame.new(-2448, 73, -3221),
        ["Zombi Adası"] = CFrame.new(-5735, 122, -7254),
        ["Karanlık Arena"] = CFrame.new(3780, 22, -3565),
        ["Karlı Dağ"] = CFrame.new(868, 400, -3050)
    }
elseif PlaceID == 7449423635 then
    CurrentSea = "Sea 3 (Third Sea)"
    IslandList = {
        ["Malikane (Mansion)"] = CFrame.new(-12482, 332, -8056),
        ["Liman (Port Town)"] = CFrame.new(-260, 49, 5322),
        ["Hidra Adası"] = CFrame.new(5749, 610, -253),
        ["Deniz Kalesi (Castle on the Sea)"] = CFrame.new(-5035, 314, -3179),
        ["Büyük Ağaç"] = CFrame.new(2341, 237, -6990)
    }
else
    CurrentSea = "Blox Fruits Değil"
end

local IslandNames = {}
for name, _ in pairs(IslandList) do table.insert(IslandNames, name) end

-- ========================================== --
-- GLOBAL DEĞİŞKENLER
-- ========================================== --
getgenv().Kaygisiz = {
    AutoFarm = false, AutoChest = false, AutoBoss = false, AntiAfk = false,
    FarmSpeed = 300, ChestSpeed = 350, FarmDistance = 7, Weapon = "Melee",
    Skills = {Z = false, X = false, C = false, V = false}, CurrentTween = nil
}

-- ========================================== --
-- FİZİK VE GÜVENLİK (ANTI-DÜŞME)
-- ========================================== --
local function getChar() return Player.Character or Player.CharacterAdded:Wait() end

local function stabilize()
    local root = getChar():FindFirstChild("HumanoidRootPart")
    if root then
        -- Anti-Yerçekimi (BodyVelocity) Ekleyerek Titremeyi %100 Önler
        local bv = root:FindFirstChild("KaygisizAntiFall")
        if not bv then
            bv = Instance.new("BodyVelocity")
            bv.Name = "KaygisizAntiFall"
            bv.MaxForce = Vector3.new(100000, 100000, 100000)
            bv.Parent = root
        end
        bv.Velocity = Vector3.new(0, 0, 0)
        root.Velocity = Vector3.new(0,0,0)
    end
end

local function removeStabilize()
    local root = getChar():FindFirstChild("HumanoidRootPart")
    if root and root:FindFirstChild("KaygisizAntiFall") then
        root.KaygisizAntiFall:Destroy()
    end
end

local function stopMovement()
    if getgenv().Kaygisiz.CurrentTween then 
        getgenv().Kaygisiz.CurrentTween:Cancel() 
        getgenv().Kaygisiz.CurrentTween = nil
    end
    removeStabilize()
end

local function doTween(targetCFrame, speed)
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
-- SİLAH VE SALDIRI
-- ========================================== --
local function equipWeapon()
    pcall(function()
        local char = getChar()
        if not char:FindFirstChildWhichIsA("Tool") then
            for _, tool in pairs(Player.Backpack:GetChildren()) do
                if tool:IsA("Tool") and (tool.ToolTip == getgenv().Kaygisiz.Weapon or tool.Name == getgenv().Kaygisiz.Weapon) then
                    char.Humanoid:EquipTool(tool) break
                end
            end
        end
    end)
end

local function attackTarget(targetPos)
    pcall(function()
        workspace.CurrentCamera.CFrame = CFrame.lookAt(workspace.CurrentCamera.CFrame.Position, targetPos)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
        for skill, active in pairs(getgenv().Kaygisiz.Skills) do
            if active then
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode[skill], false, game)
                task.wait(0.01)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode[skill], false, game)
            end
        end
    end)
end

-- ========================================== --
-- SERVER HOP (REQUEST BYPASS)
-- ========================================== --
local function serverHop()
    local httprequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
    if httprequest then
        local req = httprequest({Url = "https://games.roproxy.com/v1/games/" .. PlaceID .. "/servers/Public?sortOrder=Desc&limit=100", Method = "GET"})
        if req and req.Body then
            local body = HttpService:JSONDecode(req.Body)
            if body and body.data then
                for _, v in pairs(body.data) do
                    if v.playing < v.maxPlayers - 1 and v.id ~= game.JobId then
                        TeleportService:TeleportToPlaceInstance(PlaceID, v.id, Player)
                        return
                    end
                end
            end
        end
    end
    -- Fallback
    TeleportService:Teleport(PlaceID, Player)
end

-- ========================================== --
-- ARAYÜZ (FLUENT UI)
-- ========================================== --
local Window = Fluent:CreateWindow({
    Title = "KAYGISIZ ENGINE",
    SubTitle = "V8 Fluent Edition",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark"
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main Farm", Icon = "swords" }),
    Island = Window:AddTab({ Title = "Island Farm", Icon = "map" }),
    World = Window:AddTab({ Title = "World & Chest", Icon = "box" }),
    Settings = Window:AddTab({ Title = "Farm Settings", Icon = "settings" })
}

Window:SelectTab(1)
Fluent:Notify({ Title = "Sistem Aktif", Content = "Deniz Algılandı: " .. CurrentSea, Duration = 5 })

-- ========================================== --
-- 1. MAIN FARM SEKMESİ
-- ========================================== --
Tabs.Main:AddDropdown("WeaponDrop", {
    Title = "Silah Seçimi", Values = {"Melee", "Sword", "Blox Fruit", "Gun"}, Default = 1,
    Callback = function(Value) getgenv().Kaygisiz.Weapon = Value end
})

local ToggleFarm = Tabs.Main:AddToggle("FarmToggle", {Title = "Auto Farm (Yakın Mob)", Default = false})
ToggleFarm:OnChanged(function(Value)
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
                    while getgenv().Kaygisiz.AutoFarm and target.Parent and target.Humanoid.Health > 0 do
                        local root = getChar():FindFirstChild("HumanoidRootPart")
                        local dist = (root.Position - target.HumanoidRootPart.Position).Magnitude
                        
                        if dist > 20 then
                            doTween(target.HumanoidRootPart.CFrame * CFrame.new(0, getgenv().Kaygisiz.FarmDistance, 0), getgenv().Kaygisiz.FarmSpeed)
                            task.wait(0.2)
                        else
                            if getgenv().Kaygisiz.CurrentTween then getgenv().Kaygisiz.CurrentTween:Cancel() end
                            stabilize() -- Yerçekimini sıfırla, titremeyi önle
                            root.CFrame = target.HumanoidRootPart.CFrame * CFrame.new(0, getgenv().Kaygisiz.FarmDistance, 0)
                            equipWeapon()
                            attackTarget(target.HumanoidRootPart.Position)
                            task.wait(0.1)
                        end
                    end
                end
            end)
        end
    end)
end)

-- ========================================== --
-- 2. ISLAND FARM & TRAVEL SEKMESİ
-- ========================================== --
Tabs.Island:AddParagraph({Title = "Mevcut Konum", Content = "Şu anda bulunduğun deniz: " .. CurrentSea})

if #IslandNames > 0 then
    local selectedIsland = IslandNames[1]
    Tabs.Island:AddDropdown("IslandDrop", {
        Title = "Adayı Seç", Values = IslandNames, Default = 1,
        Callback = function(Value) selectedIsland = Value end
    })
    
    Tabs.Island:AddButton({
        Title = "Adaya Işınlan",
        Callback = function()
            if IslandList[selectedIsland] then
                doTween(IslandList[selectedIsland], getgenv().Kaygisiz.FarmSpeed)
                Fluent:Notify({Title="Işınlanıyor", Content=selectedIsland .. " hedefine gidiliyor.", Duration=3})
            end
        end
    })
end

Tabs.Island:AddSection("Deniz Değiştirme (Sea Travel)")
Tabs.Island:AddButton({Title = "Sea 1'e Git (Town)", Callback = function()
    -- Oyun içi kaptana ışınlanma veya doğrudan teleport (Roblox bypass)
    TeleportService:Teleport(2753915549, Player)
end})
Tabs.Island:AddButton({Title = "Sea 2'ye Git (Cafe)", Callback = function()
    TeleportService:Teleport(4442272183, Player)
end})
Tabs.Island:AddButton({Title = "Sea 3'e Git (Mansion)", Callback = function()
    TeleportService:Teleport(7449423635, Player)
end})

-- ========================================== --
-- 3. WORLD & CHEST SEKMESİ
-- ========================================== --
local ToggleChest = Tabs.World:AddToggle("ChestToggle", {Title = "Auto Chest", Default = false})
ToggleChest:OnChanged(function(Value)
    getgenv().Kaygisiz.AutoChest = Value
    if not Value then stopMovement() return end
    
    task.spawn(function()
        while getgenv().Kaygisiz.AutoChest do
            task.wait(0.5)
            pcall(function()
                for _, v in pairs(workspace:GetDescendants()) do
                    if getgenv().Kaygisiz.AutoChest and v.Name:find("Chest") and v:IsA("Part") then
                        local twn = doTween(v.CFrame, getgenv().Kaygisiz.ChestSpeed)
                        while twn.PlaybackState == Enum.PlaybackState.Playing and getgenv().Kaygisiz.AutoChest do task.wait(0.1) end
                        task.wait(0.3)
                    end
                end
            end)
        end
    end)
end)

Tabs.World:AddButton({Title = "Server Hop (Sunucu Değiştir)", Callback = function()
    Fluent:Notify({Title="Server Hop", Content="Yeni sunucu aranıyor...", Duration=3})
    serverHop()
end})

-- ========================================== --
-- 4. FARM SETTINGS SEKMESİ (HIZ VE SKİLLER)
-- ========================================== --
Tabs.Settings:AddSlider("FSpeed", {
    Title = "Auto Farm Hızı", Min = 150, Max = 500, Default = 300,
    Callback = function(Value) getgenv().Kaygisiz.FarmSpeed = Value end
})

Tabs.Settings:AddSlider("CSpeed", {
    Title = "Auto Chest Hızı", Min = 150, Max = 600, Default = 350,
    Callback = function(Value) getgenv().Kaygisiz.ChestSpeed = Value end
})

Tabs.Settings:AddSection("Kullanılacak Skiller")
Tabs.Settings:AddToggle("sz", {Title="Z Yeteneği", Default=false}):OnChanged(function(v) getgenv().Kaygisiz.Skills.Z = v end)
Tabs.Settings:AddToggle("sx", {Title="X Yeteneği", Default=false}):OnChanged(function(v) getgenv().Kaygisiz.Skills.X = v end)
Tabs.Settings:AddToggle("sc", {Title="C Yeteneği", Default=false}):OnChanged(function(v) getgenv().Kaygisiz.Skills.C = v end)
Tabs.Settings:AddToggle("sv", {Title="V Yeteneği", Default=false}):OnChanged(function(v) getgenv().Kaygisiz.Skills.V = v end)

Tabs.Settings:AddButton({Title = "Hileyi Tamamen Kapat (Unload)", Callback = function()
    getgenv().Kaygisiz.AutoFarm = false
    getgenv().Kaygisiz.AutoChest = false
    stopMovement()
    Window:Destroy()
end})
