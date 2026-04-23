-- [[ KAYGISIZ ENGINE V5 | THE FINAL BOSS ]] --
-- GitHub: batussaew/KAYGISIZ-Hub

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Player = Players.LocalPlayer

-- ========================================== --
-- GLOBAL DEĞİŞKENLER (ANLIK DURDURMA DESTEKLİ)
-- ========================================== --
getgenv().Kaygisiz = {
    AutoFarm = false,
    AutoChest = false,
    AutoFruit = false,
    AutoBoss = false,
    AntiAfk = false,
    TweenSpeed = 300,
    FarmDistance = 5.5, -- Vurabilmen için mesafe düşürüldü
    Weapon = "Melee",
    Skills = {Z = false, X = false, C = false, V = false},
    CurrentTween = nil
}

-- ========================================== --
-- CORE SİSTEMLER
-- ========================================== --
local function getChar() return Player.Character or Player.CharacterAdded:Wait() end

local function stopMovement()
    if getgenv().Kaygisiz.CurrentTween then getgenv().Kaygisiz.CurrentTween:Cancel() end
    local root = getChar():FindFirstChild("HumanoidRootPart")
    if root then root.Velocity = Vector3.new(0,0,0) end
end

local function kaygisizTween(targetCFrame)
    local root = getChar():WaitForChild("HumanoidRootPart")
    local dist = (root.Position - targetCFrame.Position).Magnitude
    local tweenInfo = TweenInfo.new(dist / getgenv().Kaygisiz.TweenSpeed, Enum.EasingStyle.Linear)
    
    getgenv().Kaygisiz.CurrentTween = TweenService:Create(root, tweenInfo, {CFrame = targetCFrame})
    getgenv().Kaygisiz.CurrentTween:Play()
    return getgenv().Kaygisiz.CurrentTween
end

-- SİLAH KUŞANMA
local function equipWeapon()
    local char = getChar()
    if not char:FindFirstChildWhichIsA("Tool") then
        for _, tool in pairs(Player.Backpack:GetChildren()) do
            if tool:IsA("Tool") and (tool.ToolTip == getgenv().Kaygisiz.Weapon or tool.Name == getgenv().Kaygisiz.Weapon) then
                char.Humanoid:EquipTool(tool)
                break
            end
        end
    end
end

-- SALDIRI MANTIĞI
local function attackLogic(target)
    if not target or not target:FindFirstChild("HumanoidRootPart") then return end
    
    -- Kamera Kilidi (Skill isabeti için)
    workspace.CurrentCamera.CFrame = CFrame.lookAt(workspace.CurrentCamera.CFrame.Position, target.HumanoidRootPart.Position)
    
    -- Tıklama ve Skiller
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
    
    for skill, active in pairs(getgenv().Kaygisiz.Skills) do
        if active then
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode[skill], false, game)
            task.wait(0.01)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode[skill], false, game)
        end
    end
end

-- ========================================== --
-- ARAYÜZ TASARIMI
-- ========================================== --
local Window = Rayfield:CreateWindow({
   Name = "KAYGISIZ ENGINE | V5 FINAL",
   LoadingTitle = "Kaygısız Engine V5",
   LoadingSubtitle = "By Batu | Premium Hub",
   Theme = "DarkBlue",
   ConfigurationSaving = {Enabled = false}
})

local FarmTab = Window:CreateTab("Auto Farm", 4483362458)
local BossTab = Window:CreateTab("Boss & World", 4483362458)
local ConfigTab = Window:CreateTab("Ayarlar", 4483362458)

-- ========================================== --
-- AUTO FARM SEKMESİ
-- ========================================== --
FarmTab:CreateDropdown({
    Name = "Silah Seç",
    Options = {"Melee", "Sword", "Blox Fruit", "Gun"},
    CurrentOption = {"Melee"},
    Callback = function(opt) getgenv().Kaygisiz.Weapon = opt[1] end,
})

FarmTab:CreateToggle({
   Name = "AUTO FARM (Anlık Durdurma Destekli)",
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
                        if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                            target = v break
                        end
                    end
                    
                    if target and getgenv().Kaygisiz.AutoFarm then
                        equipWeapon()
                        local tween = kaygisizTween(target.HumanoidRootPart.CFrame * CFrame.new(0, getgenv().Kaygisiz.FarmDistance, 0))
                        repeat 
                            if not getgenv().Kaygisiz.AutoFarm then break end
                            attackLogic(target)
                            task.wait()
                        until not target or target.Humanoid.Health <= 0 or not getgenv().Kaygisiz.AutoFarm
                    end
                end)
            end
        end)
   end,
})

-- ========================================== --
-- BOSS & WORLD SEKMESİ
-- ========================================== --
BossTab:CreateToggle({
   Name = "Auto BOSS Hunter",
   CurrentValue = false,
   Callback = function(Value)
        getgenv().Kaygisiz.AutoBoss = Value
        if not Value then stopMovement() end
        
        task.spawn(function()
            while getgenv().Kaygisiz.AutoBoss do
                task.wait(0.5)
                for _, v in pairs(workspace.Enemies:GetChildren()) do
                    if v:FindFirstChild("Humanoid") and v.Humanoid.MaxHealth >= 50000 and v.Humanoid.Health > 0 then
                        while v.Humanoid.Health > 0 and getgenv().Kaygisiz.AutoBoss do
                            equipWeapon()
                            kaygisizTween(v.HumanoidRootPart.CFrame * CFrame.new(0, 7, 0))
                            attackLogic(v)
                            task.wait()
                        end
                    end
                end
            end
        end)
   end,
})

BossTab:CreateToggle({
   Name = "Fruit Sniper (Meyve Bulucu)",
   CurrentValue = false,
   Callback = function(Value)
        getgenv().Kaygisiz.AutoFruit = Value
        task.spawn(function()
            while getgenv().Kaygisiz.AutoFruit do
                task.wait(1)
                for _, v in pairs(workspace:GetChildren()) do
                    if v:IsA("Tool") and v.Name:find("Fruit") then
                        kaygisizTween(v.Handle.CFrame).Completed:Wait()
                        fireclickdetector(v:FindFirstChildWhichIsA("ClickDetector")) -- Eğer varsa
                        task.wait(0.5)
                        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StoreFruit", v.Name, v)
                    end
                end
            end
        end)
   end,
})

BossTab:CreateButton({
   Name = "SERVER HOP (Yeni Sunucuya Geç)",
   Callback = function()
        local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100")).data
        for _, s in pairs(servers) do
            if s.playing < s.maxPlayers and s.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, Player)
            end
        end
   end,
})

-- ========================================== --
-- AYARLAR & GÜVENLİK
-- ========================================== --
ConfigTab:CreateToggle({
   Name = "Auto Chest (Kutu Topla)",
   CurrentValue = false,
   Callback = function(Value)
        getgenv().Kaygisiz.AutoChest = Value
        if not Value then stopMovement() end
        task.spawn(function()
            while getgenv().Kaygisiz.AutoChest do
                for _, v in pairs(workspace:GetDescendants()) do
                    if getgenv().Kaygisiz.AutoChest and v.Name:find("Chest") and v:IsA("Part") then
                        local twn = kaygisizTween(v.CFrame)
                        twn.Completed:Wait()
                        task.wait(0.3)
                    end
                end
                task.wait(1)
            end
        end)
   end,
})

ConfigTab:CreateButton({
   Name = "Hileyi Tamamen Kapat (Unload)",
   Callback = function()
        getgenv().Kaygisiz.AutoFarm = false
        getgenv().Kaygisiz.AutoChest = false
        stopMovement()
        Rayfield:Destroy()
   end,
})

Rayfield:LoadConfiguration()
