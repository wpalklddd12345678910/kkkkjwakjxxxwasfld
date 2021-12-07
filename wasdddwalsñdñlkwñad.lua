getgenv().OldAimPart = "UpperTorso"
getgenv().AimPart = "UpperTorso" 
getgenv().AimlockKey = "q"
getgenv().AimRadius = 30 
getgenv().ThirdPerson = true 
getgenv().FirstPerson = true
getgenv().TeamCheck = false 
getgenv().PredictMovement = true 
getgenv().PredictionVelocity = 6.3
getgenv().CheckIfJumped = false
getgenv().AutoPrediction = false



local Players, Uis, RService, SGui = game:GetService"Players", game:GetService"UserInputService", game:GetService"RunService", game:GetService"StarterGui";
local Client, Mouse, Camera, CF, RNew, Vec3, Vec2 = Players.LocalPlayer, Players.LocalPlayer:GetMouse(), workspace.CurrentCamera, CFrame.new, Ray.new, Vector3.new, Vector2.new;
local Aimlock, MousePressed, CanNotify = false, false, false;
local AimlockTarget;
local OldPre;
    
getgenv().WorldToViewportPoint = function(P)
    return Camera:WorldToViewportPoint(P)
end
    
getgenv().WorldToScreenPoint = function(P)
    return Camera.WorldToScreenPoint(Camera, P)
end
    
getgenv().GetObscuringObjects = function(T)
    if T and T:FindFirstChild(getgenv().AimPart) and Client and Client.Character:FindFirstChild("Head") then 
        local RayPos = workspace:FindPartOnRay(RNew(
            T[getgenv().AimPart].Position, Client.Character.Head.Position)
        )
        if RayPos then return RayPos:IsDescendantOf(T) end
    end
end
    
    getgenv().GetNearestTarget = function()
        -- Credits to whoever made this, i didnt make it, and my own mouse2plr function kinda sucks
        local players = {}
        local PLAYER_HOLD  = {}
        local DISTANCES = {}
        for i, v in pairs(Players:GetPlayers()) do
            if v ~= Client then
                table.insert(players, v)
            end
        end
        for i, v in pairs(players) do
            if v.Character ~= nil then
                local AIM = v.Character:FindFirstChild("Head")
                if getgenv().TeamCheck == true and v.Team ~= Client.Team then
                    local DISTANCE = (v.Character:FindFirstChild("Head").Position - game.Workspace.CurrentCamera.CFrame.p).magnitude
                    local RAY = Ray.new(game.Workspace.CurrentCamera.CFrame.p, (Mouse.Hit.p - game.Workspace.CurrentCamera.CFrame.p).unit * DISTANCE)
                    local HIT,POS = game.Workspace:FindPartOnRay(RAY, game.Workspace)
                    local DIFF = math.floor((POS - AIM.Position).magnitude)
                    PLAYER_HOLD[v.Name .. i] = {}
                    PLAYER_HOLD[v.Name .. i].dist= DISTANCE
                    PLAYER_HOLD[v.Name .. i].plr = v
                    PLAYER_HOLD[v.Name .. i].diff = DIFF
                    table.insert(DISTANCES, DIFF)
                elseif getgenv().TeamCheck == false and v.Team == Client.Team then 
                    local DISTANCE = (v.Character:FindFirstChild("Head").Position - game.Workspace.CurrentCamera.CFrame.p).magnitude
                    local RAY = Ray.new(game.Workspace.CurrentCamera.CFrame.p, (Mouse.Hit.p - game.Workspace.CurrentCamera.CFrame.p).unit * DISTANCE)
                    local HIT,POS = game.Workspace:FindPartOnRay(RAY, game.Workspace)
                    local DIFF = math.floor((POS - AIM.Position).magnitude)
                    PLAYER_HOLD[v.Name .. i] = {}
                    PLAYER_HOLD[v.Name .. i].dist= DISTANCE
                    PLAYER_HOLD[v.Name .. i].plr = v
                    PLAYER_HOLD[v.Name .. i].diff = DIFF
                    table.insert(DISTANCES, DIFF)
                end
            end
        end
        
        if unpack(DISTANCES) == nil then
            return nil
        end
        
        local L_DISTANCE = math.floor(math.min(unpack(DISTANCES)))
        if L_DISTANCE > getgenv().AimRadius then
            return nil
        end
        
        for i, v in pairs(PLAYER_HOLD) do
            if v.diff == L_DISTANCE then
                return v.plr
            end
        end
        return nil
    end
    
    Mouse.KeyDown:Connect(function(a)
        if not (Uis:GetFocusedTextBox()) then 
            if a == AimlockKey and AimlockTarget == nil then
                pcall(function()
                    if MousePressed ~= true then MousePressed = true end 
                    local Target;Target = GetNearestTarget()
                    if Target ~= nil then 
                        AimlockTarget = Target
                    end
                end)
            elseif a == AimlockKey and AimlockTarget ~= nil then
                if AimlockTarget ~= nil then AimlockTarget = nil end
                if MousePressed ~= false then 
                    MousePressed = false 
                end
            end
        end
    end)
    
    RService.RenderStepped:Connect(function()
        if getgenv().ThirdPerson == true and getgenv().FirstPerson == true then 
            if (Camera.Focus.p - Camera.CoordinateFrame.p).Magnitude > 1 or (Camera.Focus.p - Camera.CoordinateFrame.p).Magnitude <= 1 then 
                CanNotify = true 
            else 
                CanNotify = false 
            end
        elseif getgenv().ThirdPerson == true and getgenv().FirstPerson == false then 
            if (Camera.Focus.p - Camera.CoordinateFrame.p).Magnitude > 1 then 
                CanNotify = true 
            else 
                CanNotify = false 
            end
        elseif getgenv().ThirdPerson == false and getgenv().FirstPerson == true then 
            if (Camera.Focus.p - Camera.CoordinateFrame.p).Magnitude <= 1 then 
                CanNotify = true 
            else 
                CanNotify = false 
            end
        end
        if Aimlock == true and MousePressed == true then 
            if AimlockTarget and AimlockTarget.Character and AimlockTarget.Character:FindFirstChild(getgenv().AimPart) then 
                if getgenv().FirstPerson == true then
                    if CanNotify == true then
                        if getgenv().PredictMovement == true then 
                            Camera.CFrame = CF(Camera.CFrame.p, AimlockTarget.Character[getgenv().AimPart].Position + AimlockTarget.Character[getgenv().AimPart].Velocity/PredictionVelocity)
                        elseif getgenv().PredictMovement == false then 
                            Camera.CFrame = CF(Camera.CFrame.p, AimlockTarget.Character[getgenv().AimPart].Position)
                        end
                    end
                elseif getgenv().ThirdPerson == true then 
                    if CanNotify == true then
                        if getgenv().PredictMovement == true then 
                            Camera.CFrame = CF(Camera.CFrame.p, AimlockTarget.Character[getgenv().AimPart].Position + AimlockTarget.Character[getgenv().AimPart].Velocity/PredictionVelocity)
                        elseif getgenv().PredictMovement == false then 
                            Camera.CFrame = CF(Camera.CFrame.p, AimlockTarget.Character[getgenv().AimPart].Position)
                        end
                    end 
                end
            end
        end
         if getgenv().CheckIfJumped == true then
       if AimlockTarget.Character.Humanoid.FloorMaterial == Enum.Material.Air then

           getgenv().AimPart = "RightFoot"
       else
         getgenv().AimPart = getgenv().OldAimPart

       end
    end
end)


if getgenv().AutoPrediction == true then
    wait(1.1)
        local pingvalue = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString()
        local split = string.split(pingvalue,'(')
        local ping = tonumber(split[1])
            local PingNumber = pingValue[1]

            if  ping < 250 then
                getgenv().PredictionVelocity = 4.677
            elseif ping < 249 then
                getgenv().PredictionVelocity = 4.677
            elseif ping < 248 then
                getgenv().PredictionVelocity = 4.677
            elseif ping < 247 then
                getgenv().PredictionVelocity = 4.677
            elseif ping < 246 then
                getgenv().PredictionVelocity = 4.677
            elseif ping < 245 then
                getgenv().PredictionVelocity = 4.677
            elseif ping < 244 then
                getgenv().PredictionVelocity = 4.677
            elseif ping < 243 then
                getgenv().PredictionVelocity = 4.677
            elseif ping < 242 then
                getgenv().PredictionVelocity = 4.677
            elseif ping < 241 then
                getgenv().PredictionVelocity = 4.677
            elseif ping < 240 then
                getgenv().PredictionVelocity = 4.788
            elseif ping < 239 then
                getgenv().PredictionVelocity = 4.788
            elseif ping < 238 then
                getgenv().PredictionVelocity = 4.788
            elseif ping < 237 then
                getgenv().PredictionVelocity = 4.788
            elseif ping < 236 then
                getgenv().PredictionVelocity = 4.788
            elseif ping < 235 then
                getgenv().PredictionVelocity = 4.788
            elseif ping < 234 then
                getgenv().PredictionVelocity = 4.788
            elseif ping < 233 then
                getgenv().PredictionVelocity = 4.788
            elseif ping < 232 then
                getgenv().PredictionVelocity = 4.788
            elseif ping < 231 then
                getgenv().PredictionVelocity = 4.788
            elseif ping < 230 then
                getgenv().PredictionVelocity = 4.788
            elseif ping < 220 then
                getgenv().PredictionVelocity = 4.788
            elseif ping < 210 then
                getgenv().PredictionVelocity = 4.788
            elseif ping < 200 then
                getgenv().PredictionVelocity = 5.188
            elseif ping < 150 then
                getgenv().PredictionVelocity = 5.37
            elseif ping < 140 then
                getgenv().PredictionVelocity = 5.4
            elseif ping < 130 then
                getgenv().PredictionVelocity = 5.89
            elseif ping < 120 then
                getgenv().PredictionVelocity = 6.34
            elseif ping < 110 then
                getgenv().PredictionVelocity = 6.43
            elseif ping < 105 then
                getgenv().PredictionVelocity = 6.7
            elseif ping < 90 then
                getgenv().PredictionVelocity = 7
            elseif ping < 80 then
                getgenv().PredictionVelocity = 7
            elseif ping < 70 then
                getgenv().PredictionVelocity = 8
            elseif ping < 60 then
                getgenv().PredictionVelocity = 8
            elseif ping < 50 then
                getgenv().PredictionVelocity = 8.125
            elseif ping < 40 then
                getgenv().PredictionVelocity = 8.543
            end
end

local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/wpalklddd12345678910/kkkkjwakjxxxwasfld/main/zzzzzzesp", true))()

loadstring(game:HttpGet("https://raw.githubusercontent.com/wpalklddd12345678910/kkkkjwakjxxxwasfld/main/wasdjlksjalkd", true))()

local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/thtduddawithmiclo12ud2222/Ui/main/NoCursor"))()
local window = library:CreateWindow("Untitled", Vector2.new(492, 626), Enum.KeyCode.V)

local tab1 = window:CreateTab("Aim Stuff")
local tab2 = window:CreateTab("Rage Cheats")
local tab3 = window:CreateTab("Miscellaneous")
local tab4 = window:CreateTab("Teleports")
local tab5 = window:CreateTab("Credits")

local section1 = tab1:CreateSector("Aimbot", "left")
local section2 = tab1:CreateSector("Aimbot; Settings", "right")
local section3 = tab1:CreateSector("Silent Aim", "left")
local section4 = tab1:CreateSector("Silent Aim; Settings", "right")
local section5 = tab1:CreateSector("Silent Aimbot", "left")
local section6 = tab1:CreateSector("Silent Aimbot; Settings", "right")
local section6 = tab1:CreateSector("Anti Aim", "left")
local section7 = tab1:CreateSector("Whitelist; Settings", "right")
local section8 = tab4:CreateSector("Mainly Tps", "left")
local section9 = tab4:CreateSector("Main Mountains", "left")
local section10 = tab4:CreateSector("Main Buildings", "left")

section1:AddTextbox("Aimlock Key", "q", function(bindasd)
    getgenv().AimlockKey = bindasd
  end)

section1:AddToggle("Enabled", false, function(alr1)
    Aimlock = alr1
end)

section1:AddToggle("Ping Based Prediction", false, function(alr2)
    getgenv().AutoPrediction = alr2
end)

section1:AddToggle("Airshot Function", false, function(alr3)
    getgenv().CheckIfJumped = alr3
end)

section1:AddToggle("Team Check", false, function(alr4)
    getgenv().TeamCheck = alr4
end)

section1:AddDropdown("Hitbox", {"Head", "UpperTorso", "HumanoidRootPart", "LowerTorso", "LeftUpperLeg", "RightUpperLeg", "LeftLowerLeg", "RightLowerLeg", "LeftFoot", "RightFoot"}, default, false, function(alr5)
    getgenv().AimPart = alr5
end)

section2:AddSlider("Aim Radius", 1, 30, 100, decimals, function(alr21)
    getgenv().AimRadius = alr21
end)

section2:AddToggle("Aim Fov", false, function(alr22)
    Aiming.ShowFOV = alr22
end)

section2:AddToggle("Filled", false, function(alr8)
    Aiming.Filled = alr8
end)

section2:AddSlider("Transparency", 0, 0.2, 1, 10, function(alr9)
    Aiming.Transparency = alr9
end)

section3:AddToggle("Enabled", false, function(alr10)
    DaHoodSettings.SilentAim = alr10
end)

section3:AddToggle("Ping Based Prediction", false, function(alr11)
    DaHoodSettings.AutoPrediction = alr11
end)

section3:AddToggle("Visible Check", false, function(alr12)
    Aiming.VisibleCheck = alr12
end)

section3:AddToggle("K0d Check", false, function(alr13)
    Aiming.Check().K0d = alr13
end)

section3:AddToggle("Grabbed Check", false, function(alr14)
    Aiming.Check().Grabbed = alr14
end)

section3:AddDropdown("Hitbox", {"Head", "UpperTorso", "HumanoidRootPart", "LowerTorso", "LeftUpperLeg", "RightUpperLeg", "LeftLowerLeg", "RightLowerLeg", "LeftFoot", "RightFoot"}, default, false, function(silenthitbox)
    Aiming.TargetPart = silenthitbox
end)

section4:AddLabel("FOV")

section4:AddToggle("Enabled", false, function(alr15)
    Aiming.ShowFOV = alr15
end)

section4:AddToggle("Filled", false, function(alr16)
    Aiming.Filled = alr16
end)

section4:AddDropdown("Adjust Fov, Round To;", {"Legit Adjust", "Rage Adjust", "Custom"}, "Custom", false, function(alr17)
    if alr17 == "Legit Adjust" then
        Aiming.FOV = 13
        Aiming.FOVSides = 2.775
        Aiming.Transparency = 5
    elseif alr17 == "Rage Adjust" then
        Aiming.FOV = 70
        Aiming.FOVSides = 40
        Aiming.Transparency = 0.3
    elseif alr17 == "Custom" then
        Aiming.FOV = 30
        Aiming.FOVSides = 98
        Aiming.Transparency = 5
    end
end)

section4:AddSlider("Size", 1, 30, 100, decimals, function(alr18)
    Aiming.FOV = alr18
end)

section4:AddSlider("Round", 1, 1, 40, decimals, function(alr19)
    Aiming.FOVSides = alr19
end)

section4:AddSlider("Transparency", 0, 1, 1, 10, function(alr20)
    Aiming.Transparency = alr20
end)

section5:AddButton("Silent Aimbot", function()

end)
section8:AddDropdown("Teleports", {"Admin Guns 1", "Admin Guns 2", "Food Admin", "Ufo", "Ufo 2", "Ufo 3"}, default, false, function(v)
    if v == "Admin Guns 1" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(-873, -34, -537)
            pl.CFrame = location
    elseif v == "Admin Guns 2" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(-808, -39, -932)
            pl.CFrame = location
    elseif v == "Food Admin" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(-786, -39, -932)
            pl.CFrame = location
    elseif v == "Ufo" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(71, 139, -691)
            pl.CFrame = location
    elseif v == "Ufo 2" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(-30, 132, -742)
            pl.CFrame = location
    elseif v == "Ufo 3" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(173, 157, -731)
            pl.CFrame = location
    end
end)
section9:AddDropdown("Mountains", {"Rev Mountain", "Db Mountain", "Lmg Mountain", "AK Mountain", "Tactical Mountain"}, default, false, function(v)
    if v == "Rev Mountain" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(-681, 167, -55)
            pl.CFrame = location
    elseif v == "Db Mountain" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(-1073, 110, -136)
            pl.CFrame = location
    elseif v == "Lmg Mountain" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(-720, 122, -350)
            pl.CFrame = location
    elseif v == "AK Mountain" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(-721, 123, -660)
            pl.CFrame = location
    elseif v == "Tactical Mountain" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(503, 139, -755)
            pl.CFrame = location
    end
end)
section9:AddDropdown("Mountains 2", {"Gstation Mountain", "Bathroom Mountain", "Cementery Mountain", "Cementery Mountain 2", "Flowers Mountain"}, default, false, function(v)
    if v == "Gstation Mountain" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(654, 159, -400)
            pl.CFrame = location
    elseif v == "Bathroom Mountain" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(391, 130, -205)
            pl.CFrame = location
    elseif v == "Cementery Mountain" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(438, 122, -26)
            pl.CFrame = location
    elseif v == "Cementery Mountain 2" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(91, 111, -39)
            pl.CFrame = location
    elseif v == "Flowers Mountain" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(151, 137, -329)
            pl.CFrame = location
    end
end)
section9:AddDropdown("Mountains 3", {"Tommy Mountain", "Jail Mountain", "Furniture Mountain", "Playground Mountain", "Box Mountain"}, default, false, function(v)
    if v == "Tommy Mountain" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(-136, 128, -31)
            pl.CFrame = location
    elseif v == "Jail Mountain" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(-260, 130, 42)
            pl.CFrame = location
    elseif v == "Furniture Mountain" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(-509, 152, -36)
            pl.CFrame = location
    elseif v == "Playground Mountain" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(-310, 103, -681)
            pl.CFrame = location
    elseif v == "Box Mountain" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(-272, 126, -948)
            pl.CFrame = location
    end
end)
section9:AddDropdown("Mountains 4", {"Circus Mountain", "Circus Mountain 2", "School Mountain", "Grenade Mountain", "Casino Mountain"}, default, false, function(v)
    if v == "Circus Mountain" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(248, 122, -869)
            pl.CFrame = location
    elseif v == "Circus Mountain 2" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(-38, 115, -875)
            pl.CFrame = location
    elseif v == "Grenade Mountain" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(-891, 136, 528)
            pl.CFrame = location
    elseif v == "Casino Mountain" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(-848, 113, -28)
            pl.CFrame = location
    elseif v == "School Mountain" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(-610, 147, 478)
            pl.CFrame = location
    end
end)
section10:AddDropdown("Buildings", {"Rev building", "Rev building 2", "Rev building 3", "Rpg building", "Bank Building"}, default, false, function(v)
    if v == "Rev building" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(-584, 80, -78)
            pl.CFrame = location
    elseif v == "Rev building 2" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(-496, 48, -213)
            pl.CFrame = location
    elseif v == "Rev building 3" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(-647, 80, -204)
            pl.CFrame = location
    elseif v == "Rpg building" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(-222, 80, -466)
            pl.CFrame = location
    elseif v == "Bank Building" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(-321, 80, -273)
            pl.CFrame = location
    end
end)
section10:AddDropdown("Buildings 2", {"Flowers Building", "Playground Building", "Playground Building 2", "Tommy Building", "Cementery Building"}, default, false, function(v)
    if v == "Flowers Building" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(-111, 80, -314)
            pl.CFrame = location
    elseif v == "Playground Building" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(-225, 80, -626)
            pl.CFrame = location
    elseif v == "Playground Building 2" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(-222, 80, -859)
            pl.CFrame = location
    elseif v == "Tommy Building" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(-30, 80, -79)
            pl.CFrame = location
    elseif v == "Cementery Building" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(122, 80, -90)
            pl.CFrame = location
    end
end)
section10:AddDropdown("Buildings 3", {"AK Building", "AK Building 2", "Gstation Bulding", "Tactical Building", "School Roof"}, default, false, function(v)
    if v == "AK Building" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(-586, 66, -681)
            pl.CFrame = location
    elseif v == "AK Building 2" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(-415, 71, -655)
            pl.CFrame = location
    elseif v == "Gstation Building" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(560, 106, -408)
            pl.CFrame = location
    elseif v == "Tactical Building" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(434, 106, -629)
            pl.CFrame = location
    elseif v == "School Roof" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(-605, 68, 353)
            pl.CFrame = location
    end
end)
section8:AddDropdown("Threes", {"Bank Three", "Ak Three", "Playground Three", "Gym Three", "Flowers Three", "Tactical Three", "Gstation Three", "Cementery Three", "Cementery Three 2", "Jail Three", "School Three", "Circus Three"}, default, false, function(v)
    if v == "Bank Three" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(-376, 98, -444)
            pl.CFrame = location
    elseif v == "Ak Three" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(-404, 98, -719)
            pl.CFrame = location
    elseif v == "Playground Three" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(-345, 98, -769)
            pl.CFrame = location
    elseif v == "Gym Three" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(-63, 98, -535)
            pl.CFrame = location
    elseif v == "Flowers Three" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(-44, 99, -289)
            pl.CFrame = location
    elseif v == "Gstation Three" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(641, 102, -193)
            pl.CFrame = location
    elseif v == "Cementery Three" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(326, 99, -114)
            pl.CFrame = location
    elseif v == "Cementery Three 2" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(110, 99, -213)
            pl.CFrame = location
    elseif v == "Jail Three" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(-418, 94, 67)
            pl.CFrame = location
    elseif v == "School Three" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(-537, 75, 162)
            pl.CFrame = location
    elseif v == "Circus Three" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(320, 100, -962)
            pl.CFrame = location
    elseif v == "Tactical Three" then
            local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
            local location = CFrame.new(387, 125, -492)
            pl.CFrame = location
    end
end)
