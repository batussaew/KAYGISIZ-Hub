-- [[ KAYGISIZ ENGINE V7 | THE MASTERPIECE ]] --
-- GitHub: batussaew/KAYGISIZ-Hub

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")
local Player = Players.LocalPlayer

getgenv().Kaygisiz = {
    AutoFarm = false, AutoPlayer = false, AutoBoss = false,
    AutoChest = false, AutoFruit = false, AntiAfk = false,
    TweenSpeed = 300, FarmDistance = 7, Weapon = "Melee",
    Skills = {Z = false, X = false, C = false, V = false},
    CurrentTween = nil, OrbitAngle = 0
}

local function getChar() return Player.Character or Player.CharacterAdded:Wait() end

local function stopMovement()
    if getgenv().Kaygisiz.CurrentTween then 
        getgenv().Kaygisiz.CurrentTween:Cancel() 
        getgenv().Kaygisiz.CurrentTween = nil
    end
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

getgenv().Kaygisiz.Connections = {}
getgenv().Kaygisiz.Connections["Noclip"] = RunService.Stepped:Connect(function()
    if getgenv().Kaygisiz.AutoFarm or getgenv().Kaygisiz.AutoChest or getgenv().Kaygisiz.AutoPlayer or getgenv().Kaygisiz.AutoBoss then
        local char = getChar()
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
            end
        end
    end
end)

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

-- Stabil Yörünge (Orbit) Hareketi: Hasar almamak için hedefin etrafında çember çizer
local function getOrbitPosition(targetPos)
    getgenv().Kaygisiz.OrbitAngle = getgenv().Kaygisiz.OrbitAngle + 15
    local rad = math.rad(getgenv().Kaygisiz.OrbitAngle)
    local x = math.cos(rad) * 5 -- 5 birim yarıçaplı çember
    local z = math.sin(rad) * 5
    return targetPos + Vector3.new(x, getgenv().Kaygisiz.FarmDistance, z)
end

local function attackLogic()
    pcall(function()
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
    end)
end

-- ========================================== --
-- ARAYÜZ (UI)
-- ========================================== --
local Window = Rayfield:CreateWindow({
   Name = "KAYGISIZ ENGINE | V7 MASTERPIECE",
   LoadingTitle = "Bütün Özellikler Aktif",
   Theme = "DarkBlue", ConfigurationSaving = {Enabled = false}
})

local FarmTab = Window:CreateTab("Auto Farm", 4483362458)
local PVPTab = Window:CreateTab("Player Hunter", 4483362458)
local BossTab = Window:CreateTab("Boss & World", 4483362458)
local ConfigTab = Window:CreateTab("Ayarlar", 4483362458)

-- ========================================== --
-- AUTO FARM (NPC)
-- ========================================== --
FarmTab:CreateDropdown({
    Name = "Silah Seç", Options = {"Melee", "Sword", "Blox Fruit", "Gun"}, CurrentOption = {"Melee"},
    Callback = function(opt) getgenv().Kaygisiz.Weapon = opt[1] end,
})

FarmTab:CreateToggle({
   Name = "Auto Farm Başlat", CurrentValue = false,
   Callback = function(Value)
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
                                kaygisizTween(target.HumanoidRootPart.CFrame * CFrame.new(0, getgenv().Kaygisiz.FarmDistance, 0))
                                task.wait(0.2)
                            else
                                if getgenv().Kaygisiz.CurrentTween then getgenv().Kaygisiz.CurrentTween:Cancel() end
                                -- Orbit ile dön ve vur
                                local orbitPos = getOrbitPosition(target.HumanoidRootPart.Position)
                                root.CFrame = CFrame.lookAt(orbitPos, target.HumanoidRootPart.Position)
                                root.Velocity = Vector3.new(0,0,0)
                                equipWeapon()
                                attackLogic()
                                task.wait(0.1) -- UI dondurmasını engeller
                            end
                        end
                    end
                end)
            end
        end)
   end,
})

-- ========================================== --
-- PLAYER HUNTER (PVP)
-- ========================================== --
PVPTab:CreateToggle({
   Name = "Otomatik Oyuncu Avla (En Yakın)", CurrentValue = false,
   Callback = function(Value)
        getgenv().Kaygisiz.AutoPlayer = Value
        if not Value then stopMovement() return end
        
        task.spawn(function()
            while getgenv().Kaygisiz.AutoPlayer do
                task.wait(0.1)
                pcall(function()
                    local target, dist = nil, math.huge
                    for _, v in pairs(Players:GetPlayers()) do
                        if v ~= Player and v.Character and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 and v.Character:FindFirstChild("HumanoidRootPart") then
                            local d = (getChar().HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude
                            if d < dist then dist = d; target = v end
                        end
                    end
                    
                    if target then
                        while getgenv().Kaygisiz.AutoPlayer and target.Character and target.Character.Humanoid.Health > 0 do
                            local root = getChar():FindFirstChild("HumanoidRootPart")
                            local d = (root.Position - target.Character.HumanoidRootPart.Position).Magnitude
                            if d > 20 then
                                kaygisizTween(target.Character.HumanoidRootPart.CFrame * CFrame.new(0, getgenv().Kaygisiz.FarmDistance, 0))
                                task.wait(0.1)
                            else
                                if getgenv().Kaygisiz.CurrentTween then getgenv().Kaygisiz.CurrentTween:Cancel() end
                                local orbitPos = getOrbitPosition(target.Character.HumanoidRootPart.Position)
                                root.CFrame = CFrame.lookAt(orbitPos, target.Character.HumanoidRootPart.Position)
                                root.Velocity = Vector3.new(0,0,0)
                                equipWeapon()
                                attackLogic()
                                task.wait(0.05)
                            end
                        end
                    end
                end)
            end
        end)
   end,
})

-- ========================================== --
-- BOSS & WORLD (CHEST & FRUIT)
-- ========================================== --
BossTab:CreateToggle({
   Name = "Auto BOSS Hunter", CurrentValue = false,
   Callback = function(Value)
        getgenv().Kaygisiz.AutoBoss = Value
        if not Value then stopMovement() return end
        task.spawn(function()
            while getgenv().Kaygisiz.AutoBoss do
                task.wait(1)
                pcall(function()
                    for _, v in pairs(workspace.Enemies:GetChildren()) do
                        if v:FindFirstChild("Humanoid") and v.Humanoid.MaxHealth >= 50000 and v.Humanoid.Health > 0 then
                            while getgenv().Kaygisiz.AutoBoss and v.Humanoid.Health > 0 do
                                local root = getChar():FindFirstChild("HumanoidRootPart")
                                local dist = (root.Position - v.HumanoidRootPart.Position).Magnitude
                                if dist > 20 then
                                    kaygisizTween(v.HumanoidRootPart.CFrame * CFrame.new(0, getgenv().Kaygisiz.FarmDistance, 0))
                                    task.wait(0.2)
                                else
                                    if getgenv().Kaygisiz.CurrentTween then getgenv().Kaygisiz.CurrentTween:Cancel() end
                                    local orbitPos = getOrbitPosition(v.HumanoidRootPart.Position)
                                    root.CFrame = CFrame.lookAt(orbitPos, v.HumanoidRootPart.Position)
                                    equipWeapon()
                                    attackLogic()
                                    task.wait(0.1)
                                end
                            end
                        end
                    end
                end)
            end
        end)
   end,
})

BossTab:CreateToggle({
   Name = "Auto Chest (Kutuları Topla)", CurrentValue = false,
   Callback = function(Value)
        getgenv().Kaygisiz.AutoChest = Value
        if not Value then stopMovement() return end
        task.spawn(function()
            while getgenv().Kaygisiz.AutoChest do
                task.wait(0.5)
                pcall(function()
                    for _, v in pairs(workspace:GetDescendants()) do
                        if getgenv().Kaygisiz.AutoChest and v.Name:find("Chest") and v:IsA("Part") then
                            local twn = kaygisizTween(v.CFrame)
                            while twn.PlaybackState == Enum.PlaybackState.Playing and getgenv().Kaygisiz.AutoChest do task.wait(0.1) end
                            task.wait(0.3)
                        end
                    end
                end)
            end
        end)
   end,
})

BossTab:CreateToggle({
   Name = "Fruit Sniper", CurrentValue = false,
   Callback = function(Value)
        getgenv().Kaygisiz.AutoFruit = Value
        task.spawn(function()
            while getgenv().Kaygisiz.AutoFruit do
                task.wait(1)
                pcall(function()
                    for _, v in pairs(workspace:GetChildren()) do
                        if v:IsA("Tool") and v.Name:find("Fruit") then
                            local twn = kaygisizTween(v.Handle.CFrame)
                            while twn.PlaybackState == Enum.PlaybackState.Playing and getgenv().Kaygisiz.AutoFruit do task.wait(0.1) end
                            task.wait(0.5)
                            game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StoreFruit", v.Name, v)
                        end
                    end
                end)
            end
        end)
   end,
})

BossTab:CreateButton({
   Name = "Server Hop (Sunucu Değiştir)",
   Callback = function()
        local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100")).data
        for _, s in pairs(servers) do
            if s.playing < s.maxPlayers and s.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, Player) break
            end
        end
   end,
})

-- ========================================== --
-- AYARLAR VE SKİLLER
-- ========================================== --
ConfigTab:CreateSection("Yetenek Ayarları")
ConfigTab:CreateToggle({Name = "Z Skill Kullan", CurrentValue = false, Callback = function(v) getgenv().Kaygisiz.Skills.Z = v end})
ConfigTab:CreateToggle({Name = "X Skill Kullan", CurrentValue = false, Callback = function(v) getgenv().Kaygisiz.Skills.X = v end})
ConfigTab:CreateToggle({Name = "C Skill Kullan", CurrentValue = false, Callback = function(v) getgenv().Kaygisiz.Skills.C = v end})
ConfigTab:CreateToggle({Name = "V Skill Kullan", CurrentValue = false, Callback = function(v) getgenv().Kaygisiz.Skills.V = v end})

ConfigTab:CreateSection("Sistem")
ConfigTab:CreateButton({
   Name = "Hileyi Tamamen Kapat (Unload)",
   Callback = function()
        getgenv().Kaygisiz.AutoFarm = false
        getgenv().Kaygisiz.AutoPlayer = false
        getgenv().Kaygisiz.AutoBoss = false
        getgenv().Kaygisiz.AutoChest = false
        stopMovement()
        if getgenv().Kaygisiz.Connections["Noclip"] then getgenv().Kaygisiz.Connections["Noclip"]:Disconnect() end
        Rayfield:Destroy()
   end,
})

Rayfield:LoadConfiguration()
