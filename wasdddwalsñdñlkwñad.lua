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
    wait(5.2)
        local pingvalue = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString()
        local split = string.split(pingvalue,'(')
        local ping = tonumber(split[1])
            local PingNumber = pingValue[1]

            if  ping < 250 then
                getgenv().PredictionVelocity = 4.677
            elseif ping < 240 then
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
                getgenv().PredictionVelocity = 5.56
            elseif ping < 140 then
                getgenv().PredictionVelocity = 5.75
            elseif ping < 130 then
                getgenv().PredictionVelocity = 6.28
            elseif ping < 120 then
                getgenv().PredictionVelocity = 6.43
            elseif ping < 110 then
                getgenv().PredictionVelocity = 6.59
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

IsFirstPerson = false
	WHeld = false
	SHeld = false
	AHeld = false
	DHeld = false
	local L_167_ = true
    local activar = false
	urspeed = 0.1
	function ChangeFaster(L_168_arg0, L_169_arg1)
		if L_168_arg0.KeyCode == Enum.KeyCode.Down and L_169_arg1 == false then
			urspeed = urspeed - 0.01
		end
	end
	function ChangeSlower(L_170_arg0, L_171_arg1)
		if L_170_arg0.KeyCode == Enum.KeyCode.Up and L_171_arg1 == false then
			urspeed = urspeed + 0.01
		end
	end
	function GChecker(L_172_arg0, L_173_arg1)
		if L_172_arg0.KeyCode == Enum.KeyCode.N and L_173_arg1 == false then
			if L_167_ == false then
				L_167_ = true
			elseif L_167_ == true then
				L_167_ = false
			end
		end
	end
	function PressW(L_178_arg0, L_179_arg1)
		if L_178_arg0.KeyCode == Enum.KeyCode.W and L_179_arg1 == false and L_167_ == true then
			WHeld = true
		end
	end
	function ReleaseW(L_180_arg0, L_181_arg1)
		if L_180_arg0.KeyCode == Enum.KeyCode.W then
			WHeld = false
		end
	end
	function PressS(L_182_arg0, L_183_arg1)
		if L_182_arg0.KeyCode == Enum.KeyCode.S and L_183_arg1 == false and L_167_ == true then
			SHeld = true
		end
	end
	function ReleaseS(L_184_arg0, L_185_arg1)
		if L_184_arg0.KeyCode == Enum.KeyCode.S then
			SHeld = false
		end
	end
	function PressA(L_186_arg0, L_187_arg1)
		if L_186_arg0.KeyCode == Enum.KeyCode.A and L_187_arg1 == false and L_167_ == true then
			AHeld = true
		end
	end
	function ReleaseA(L_188_arg0, L_189_arg1)
		if L_188_arg0.KeyCode == Enum.KeyCode.A then
			AHeld = false
		end
	end
	function PressD(L_190_arg0, L_191_arg1)
		if L_190_arg0.KeyCode == Enum.KeyCode.D and L_191_arg1 == false and L_167_ == true then
			DHeld = true
		end
	end
	function ReleaseD(L_192_arg0, L_193_arg1)
		if L_192_arg0.KeyCode == Enum.KeyCode.D then
			DHeld = false
		end
	end
	function CheckFirst(L_194_arg0, L_195_arg1)
		if L_194_arg0.KeyCode == Enum.UserInputType.MouseWheel then
			if (player.Character.Head.CFrame.p - workspace.CurrentCamera.CFrame.p).magnitude < 0.6 then
				IsFirstPerson = true
			elseif (player.Character.Head.CFrame.p - workspace.CurrentCamera.CFrame.p).magnitude > 0.6 then
				IsFirstPerson = false
			end
		end
	end
	game:GetService("UserInputService").InputBegan:connect(PressW)
	game:GetService("UserInputService").InputEnded:connect(ReleaseW)
	game:GetService("UserInputService").InputBegan:connect(PressS)
	game:GetService("UserInputService").InputEnded:connect(ReleaseS)
	game:GetService("UserInputService").InputBegan:connect(PressA)
	game:GetService("UserInputService").InputEnded:connect(ReleaseA)
	game:GetService("UserInputService").InputBegan:connect(PressD)
	game:GetService("UserInputService").InputEnded:connect(ReleaseD)
	game:GetService("UserInputService").InputChanged:connect(CheckFirst)
	game:GetService("UserInputService").InputBegan:connect(ChangeFaster)
	game:GetService("UserInputService").InputBegan:connect(ChangeSlower)
	game:GetService("RunService").Stepped:connect(
            function()
		if activar == true then
			if WHeld == true then
				game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame =
                            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -urspeed)
			end
			if SHeld == true then
				game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame =
                            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, urspeed)
			end
			if DHeld == true then
				game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame =
                            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(urspeed, 0, 0)
			end
			if AHeld == true then
				game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame =
                            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(-urspeed, 0, 0)
			end
		end
end)

local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/wpalklddd12345678910/kkkkjwakjxxxwasfld/main/zzzzzzesp", true))()

loadstring(game:HttpGet("https://raw.githubusercontent.com/wpalklddd12345678910/kkkkjwakjxxxwasfld/main/wasdjlksjalkd", true))()

local Crosshair = loadstring(game:HttpGet("https://raw.githubusercontent.com/wpalklddd12345678910/kkkkjwakjxxxwasfld/main/cross", true))()

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
local section6 = tab1:CreateSector("Anti Aim", "left")
local section7 = tab1:CreateSector("Settings; Whitelist", "right")
local section8 = tab4:CreateSector("Mainly Tps", "left")
local section9 = tab4:CreateSector("Main Mountains", "left")
local section10 = tab4:CreateSector("Main Buildings", "left")
local section11 = tab4:CreateSector("Auto Buys", "right")
local section12 = tab4:CreateSector("Auto Buys 2", "right")
local section13 = tab4:CreateSector("Guns Ammo", "right")
local section14 = tab2:CreateSector("CFrame Speed", "left")
local section15 = tab3:CreateSector("Crosshair", "right")
local section16 = tab5:CreateSector("Credits", "left")
local section17 = tab5:CreateSector("Discord", "right")
local section18 = tab4:CreateSector("Local Tps", "right")
local section19 = tab3:CreateSector("Ingame Things", "right")


section14:AddToggle("CFrame Speed", false, function(cframe)
    activar = cframe
end):AddKeybind("None")

section14:AddButton("Fix CFrame", function(cframe)
    for _, v in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
        if v:IsA("Script") and v.Name ~= "Health" and v.Name ~= "Sound" and v:FindFirstChild("LocalScript") then
            v:Destroy()
        end
    end
    game.Players.LocalPlayer.CharacterAdded:Connect(function(char)
        repeat
            wait()
        until game.Players.LocalPlayer.Character
        char.ChildAdded:Connect(function(child)
            if child:IsA("Script") then 
                wait(0.1)
                if child:FindFirstChild("LocalScript") then
                    child.LocalScript:FireServer()
                end
            end
        end)
    end)

end)

local glitch = false
local clicker = false

section14:AddSlider("Speed", -10, 0, 10, 5, function(ass)
    urspeed = ass
end)

section1:AddToggle("Enabled", false, function(alr1)
    Aimlock = alr1
end):AddKeybind("None")

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

section1:AddTextbox("Bullet Prediction", "", function(lockpredictionlolxdd)
    getgenv().PredictionVelocity = lockpredictionlolxdd
end)

section2:AddTextbox("Aimlock Key", "q", function(bindasd)
    getgenv().AimlockKey = bindasd
  end)

section2:AddSlider("Aim Radius", 1, 30, 100, decimals, function(alr21)
    getgenv().AimRadius = alr21
end)

section2:AddToggle("Aim Fov", false, function(alr22)
    Aiming.ShowFOV = alr22
end):AddKeybind("None")

section2:AddToggle("Filled", false, function(alr8)
    Aiming.Filled = alr8
end)

section2:AddSlider("Transparency", 0, 0.2, 1, 10, function(alr9)
    Aiming.Transparency = alr9
end)

section3:AddToggle("Enabled", false, function(alr10)
    DaHoodSettings.SilentAim = alr10
end):AddKeybind("None")

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

section3:AddTextbox("Bullet Prediction", "", function(silentpredictionlolxdd)
    DaHoodSettings.Prediction = silentpredictionlolxdd
end)

section4:AddToggle("Enabled", false, function(alr15)
    Aiming.ShowFOV = alr15
end):AddKeybind("None")

section4:AddToggle("Filled", false, function(alr16)
    Aiming.Filled = alr16
end)

section4:AddDropdown("Adjust Fov, Round To;", {"Legit Adjust", "Rage Adjust", "Custom"}, "Custom", false, function(alr17)
    if alr17 == "Legit Adjust" then
        Aiming.FOV = 13
        Aiming.FOVSides = 2.775
        Aiming.Transparency = 0.3
    elseif alr17 == "Rage Adjust" then
        Aiming.FOV = 70
        Aiming.FOVSides = 40
        Aiming.Transparency = 0.3
    elseif alr17 == "Custom" then
        Aiming.FOV = 30
        Aiming.FOVSides = 98
        Aiming.Transparency = 0.3
    end
end)

section4:AddSlider("Size", 1, 30, 300, decimals, function(alr18)
    Aiming.FOV = alr18
end)

section4:AddSlider("Round", 1, 40, 40, decimals, function(alr19)
    Aiming.FOVSides = alr19
end)

section4:AddSlider("Transparency", 0, 0.2, 1, 10, function(alr20)
    Aiming.Transparency = alr20
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

section11:AddDropdown("Guns", {"Revolver", "Double Barrel", "AK", "AR", "SMG"}, default, false, function(v)
    if v == "Revolver" then
        local plr = game.Players.LocalPlayer
        local savedarmourpos = plr.Character.HumanoidRootPart.Position
                plr.Character.HumanoidRootPart.CFrame = CFrame.new(-639, 10, -118)
                wait(.2)
        
                fireclickdetector(game.Workspace.Ignored.Shop['[Revolver] - $1300'].ClickDetector)
                plr.Character.HumanoidRootPart.CFrame = CFrame.new(savedarmourpos)
    elseif v == "Double Barrel" then
        local plr = game.Players.LocalPlayer
        local savedarmourpos = plr.Character.HumanoidRootPart.Position
                plr.Character.HumanoidRootPart.CFrame = CFrame.new(-1040, 11, -257)
                wait(.2)
        
                fireclickdetector(game.Workspace.Ignored.Shop['[Double-Barrel SG] - $1400'].ClickDetector)
                plr.Character.HumanoidRootPart.CFrame = CFrame.new(savedarmourpos)
    elseif v == "AK" then
        local plr = game.Players.LocalPlayer
        local savedarmourpos = plr.Character.HumanoidRootPart.Position
                plr.Character.HumanoidRootPart.CFrame = CFrame.new(-584, -0, -753)
                wait(.2)
        
                fireclickdetector(game.Workspace.Ignored.Shop['[AK47] - $2250'].ClickDetector)
                plr.Character.HumanoidRootPart.CFrame = CFrame.new(savedarmourpos)
    elseif v == "SMG" then
        local plr = game.Players.LocalPlayer
        local savedarmourpos = plr.Character.HumanoidRootPart.Position
                plr.Character.HumanoidRootPart.CFrame = CFrame.new(-577, -0, -718)
                wait(.2)
        
                fireclickdetector(game.Workspace.Ignored.Shop['[SMG] - $750'].ClickDetector)
                plr.Character.HumanoidRootPart.CFrame = CFrame.new(savedarmourpos)
    end
end)

section11:AddDropdown("Other Stuff", {"High Medium Armor", "Tool While Jailed", "Knife", "Mask"}, default, false, function(v)
    if v == "High Medium Armor" then
        local plr = game.Players.LocalPlayer
        local savedarmourpos = plr.Character.HumanoidRootPart.Position
            plr.Character.HumanoidRootPart.CFrame = CFrame.new(-927, -41, 567)
            wait(.2)
    
            fireclickdetector(game.Workspace.Ignored.Shop['[High-Medium Armor] - $2300'].ClickDetector)
            plr.Character.HumanoidRootPart.CFrame = CFrame.new(savedarmourpos)
    elseif v == "Tool While Jailed" then
        game:GetService("Players").LocalPlayer.Character.BodyEffects.Cuff:Destroy()
    elseif v == "Knife" then
        local plr = game.Players.LocalPlayer
        local savedarmourpos = plr.Character.HumanoidRootPart.Position
                plr.Character.HumanoidRootPart.CFrame = CFrame.new(-277, 21, -238)
                wait(.2)
        
                fireclickdetector(game.Workspace.Ignored.Shop['[Knife] - $150'].ClickDetector)
                plr.Character.HumanoidRootPart.CFrame = CFrame.new(savedarmourpos)
    elseif v == "Mask" then
        local d = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
        local k = game.Workspace.Ignored.Shop["[Surgeon Mask] - $25"]
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = k.Head.CFrame + Vector3.new(0, 3, 0)
        if (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - k.Head.Position).Magnitude <= 50 then
            wait(.2)
            fireclickdetector(k:FindFirstChild("ClickDetector"), 4)
            toolf = game.Players.LocalPlayer.Backpack:WaitForChild("Mask")
            toolf.Parent = game.Players.LocalPlayer.Character
            wait()
            game.Players.LocalPlayer.Character:WaitForChild("Mask")
            game:GetService("VirtualUser"):ClickButton1(Vector2.new())
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(d)
            end
        end
    end)

    section12:AddDropdown("Guns 2", {"DrumGun", "Rpg", "Flame", "Grenade Launcher"}, default, false, function(v)
        if v == "DrumGun" then
            local plr = game.Players.LocalPlayer
            local savedarmourpos = plr.Character.HumanoidRootPart.Position
                    plr.Character.HumanoidRootPart.CFrame = CFrame.new(-83, 15, -84)
                    wait(.2)
            
                    fireclickdetector(game.Workspace.Ignored.Shop['[DrumGun] - $3000'].ClickDetector)
                    plr.Character.HumanoidRootPart.CFrame = CFrame.new(savedarmourpos)        
        elseif v == "Rpg" then
            local plr = game.Players.LocalPlayer
            local savedarmourpos = plr.Character.HumanoidRootPart.Position
                    plr.Character.HumanoidRootPart.CFrame = CFrame.new(-792, -46, -932)
                    wait(.2)
            
                    fireclickdetector(game.Workspace.Ignored.Shop['[RPG] - $6000'].ClickDetector)
                    plr.Character.HumanoidRootPart.CFrame = CFrame.new(savedarmourpos)
        elseif v == "Flame" then
            local plr = game.Players.LocalPlayer
            local savedarmourpos = plr.Character.HumanoidRootPart.Position
                    plr.Character.HumanoidRootPart.CFrame = CFrame.new(-166, 53, -98)
                    wait(.2)
            
                    fireclickdetector(game.Workspace.Ignored.Shop['[Flamethrower] - $25000'].ClickDetector)
                    plr.Character.HumanoidRootPart.CFrame = CFrame.new(savedarmourpos)
        elseif v == "Grenade Launcher" then
            local plr = game.Players.LocalPlayer
            local savedarmourpos = plr.Character.HumanoidRootPart.Position
                    plr.Character.HumanoidRootPart.CFrame = CFrame.new(-966, -11, 471)
                    wait(.2)
            
                    fireclickdetector(game.Workspace.Ignored.Shop['[GrenadeLauncher] - $10000'].ClickDetector)
                    plr.Character.HumanoidRootPart.CFrame = CFrame.new(savedarmourpos)
        end
    end)

    section13:AddDropdown("Ammo", {"Rev Ammo", "Db Ammo", "AK Ammo", "SMG Ammo", "DrumGun Ammo", "RPG Ammo", "Flame Ammo", "GrenadeL Ammo"}, default, false, function(v)
        if v == "Rev Ammo" then
            local plr = game.Players.LocalPlayer
            local savedarmourpos = plr.Character.HumanoidRootPart.Position
                    plr.Character.HumanoidRootPart.CFrame = CFrame.new(-638, 15, -120)
                    wait(.2)
            
                    fireclickdetector(game.Workspace.Ignored.Shop['12 [Revolver Ammo] - $75'].ClickDetector)
                    plr.Character.HumanoidRootPart.CFrame = CFrame.new(savedarmourpos)        
        elseif v == "Db Ammo" then
            local plr = game.Players.LocalPlayer
            local savedarmourpos = plr.Character.HumanoidRootPart.Position
                    plr.Character.HumanoidRootPart.CFrame = CFrame.new(-1046, 15, -258)
                    wait(.2)
            
                    fireclickdetector(game.Workspace.Ignored.Shop['18 [Double-Barrel SG Ammo] - $60'].ClickDetector)
                    plr.Character.HumanoidRootPart.CFrame = CFrame.new(savedarmourpos)
        elseif v == "AK Ammo" then
            local plr = game.Players.LocalPlayer
            local savedarmourpos = plr.Character.HumanoidRootPart.Position
                    plr.Character.HumanoidRootPart.CFrame = CFrame.new(-587, -1, -751)
                    wait(.2)
            
                    fireclickdetector(game.Workspace.Ignored.Shop['90 [AK47 Ammo] - $80'].ClickDetector)
                    plr.Character.HumanoidRootPart.CFrame = CFrame.new(savedarmourpos)
        elseif v == "SMG Ammo" then
            local plr = game.Players.LocalPlayer
            local savedarmourpos = plr.Character.HumanoidRootPart.Position
                    plr.Character.HumanoidRootPart.CFrame = CFrame.new(-810, -47, -940)
                    wait(.2)
            
                    fireclickdetector(game.Workspace.Ignored.Shop['80 [SMG Ammo] - $60'].ClickDetector)
                    plr.Character.HumanoidRootPart.CFrame = CFrame.new(savedarmourpos)
        elseif v == "DrumGun Ammo" then
            local plr = game.Players.LocalPlayer
            local savedarmourpos = plr.Character.HumanoidRootPart.Position
                    plr.Character.HumanoidRootPart.CFrame = CFrame.new(-83, 15, -84)
                    wait(.2)
            
                    fireclickdetector(game.Workspace.Ignored.Shop['100 [DrumGun Ammo] - $200'].ClickDetector)
                    plr.Character.HumanoidRootPart.CFrame = CFrame.new(savedarmourpos)
        elseif v == "RPG Ammo" then
            local plr = game.Players.LocalPlayer
            local savedarmourpos = plr.Character.HumanoidRootPart.Position
                    plr.Character.HumanoidRootPart.CFrame = CFrame.new(-118, -40, -274)
                    wait(.2)
            
                    fireclickdetector(game.Workspace.Ignored.Shop['5 [RPG Ammo] - $1000'].ClickDetector)
                    plr.Character.HumanoidRootPart.CFrame = CFrame.new(savedarmourpos)
        elseif v == "Flame Ammo" then
            local plr = game.Players.LocalPlayer
            local savedarmourpos = plr.Character.HumanoidRootPart.Position
                    plr.Character.HumanoidRootPart.CFrame = CFrame.new(-134, 53, -101)
                    wait(.2)
            
                    fireclickdetector(game.Workspace.Ignored.Shop['140 [Flamethrower Ammo] - $1550'].ClickDetector)
                    plr.Character.HumanoidRootPart.CFrame = CFrame.new(savedarmourpos)
        elseif v == "GrenadeL Ammo" then
            local plr = game.Players.LocalPlayer
            local savedarmourpos = plr.Character.HumanoidRootPart.Position
                    plr.Character.HumanoidRootPart.CFrame = CFrame.new(-966, -11, 471)
                    wait(.2)
            
                    fireclickdetector(game.Workspace.Ignored.Shop['12 [GrenadeLauncher Ammo] - $3000'].ClickDetector)
                    plr.Character.HumanoidRootPart.CFrame = CFrame.new(savedarmourpos)
        end
    end)
    
section18:AddTextbox("Tp to player", "Player", function(tpplayer)
local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
local pl2 = (tpplayer)
pl.CFrame = game.Players[tpplayer].Character.HumanoidRootPart.CFrame
end)

section15:AddToggle("Enable", false, function(crossxd)
    getgenv().CursorConfig.CrosshairEnabled = crossxd
end)

section15:AddToggle("Rainbow", false, function(rainbow)
    getgenv().CursorConfig.Rainbow = rainbow
end)

section15:AddSlider("Size", 0, 0, 100, 100, function(crossxd1)
    getgenv().CursorConfig.CrosshairSize = crossxd1
end)

section15:AddSlider("Gap", 0, 0, 100, 100, function(crossxd2)
    getgenv().CursorConfig.CrosshairGap = crossxd2
end)

section15:AddSlider("Thickness", 0, 0, 50, 50, function(crossxd3)
    getgenv().CursorConfig.CrosshairThickness = crossxd3
end)

section15:AddSlider("Transparency", 0, 0, 1, 100, function(crossxd3)
    getgenv().CursorConfig.CrosshairTransparency = crossxd3
    getgenv().CursorConfig.OutlineTransparency = crossxd3
end)

section15:AddColorpicker("Crosshair Colour", Color3.fromRGB(28, 56, 139), function(loool)
    getgenv().CursorConfig.CrosshairColor = loool
end)

section19:AddDropdown("Faces", {"Super Happy Face", "Playful Vampire", "Blizzard Beast Mode", "Troublemaker", "Beast Mode", "Radioactive Beast Mode", "Madness Face", "Faceless"}, default, false, function(v)
    if v == "Super Happy Face" then
    game.Players.LocalPlayer.Character.Head.face.Texture = "rbxassetid://494290547"
    elseif v == "Playful Vampire" then
    game.Players.LocalPlayer.Character.Head.face.Texture = "rbxassetid://2409281591"
    elseif v == "Blizzard Beast Mode" then
    game.Players.LocalPlayer.Character.Head.face.Texture = "rbxassetid://209712379"
    elseif v == "Troublemaker" then
    game.Players.LocalPlayer.Character.Head.face.Texture = "rbxassetid://22920500"
    elseif v == "Beast Mode" then
    game.Players.LocalPlayer.Character.Head.face.Texture = "rbxassetid://127959433"
    elseif v == "Radioactive Beast Mode" then
    game.Players.LocalPlayer.Character.Head.face.Texture = "rbxassetid://2225757922"
    elseif v == "Madness Face" then
    game.Players.LocalPlayer.Character.Head.face.Texture = "rbxassetid://42070872"
    elseif v == "Faceless" then
    for i,v in pairs(game.Players.LocalPlayer.Character.Head:GetChildren()) do
    if (v:IsA("Decal")) then
    v:Destroy()
    end
    end
    end
end)

section4:AddLabel("Hats")

section19:AddDropdown("Valks", {"Ice valk", "Valk", "Black Valk", "Purple Valk", "Green Valk", "Sparkle Valk"}, default, false, function(v)
if v == "Ice valk" then
loadstring(game:HttpGet("https://raw.githubusercontent.com/SpotzsAlt/xf/main/dwa"))()
elseif v == "Valk" then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/SpotzsAlt/xf/main/dwo"))()
elseif v == "Black Valk" then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/SpotzsAlt/xf/main/dwe"))()
elseif v == "Purple Valk" then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/SpotzsAlt/xf/main/dlol"))()
elseif v == "Green Valk" then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/wpalklddd12345678910/kfue/main/emerald"))()
elseif v == "Sparkle Valk" then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/wpalklddd12345678910/kfue/main/destellante"))()
end
end)
section19:AddDropdown("Hats", {"Frozen Horns", "Fire Horns"}, default, false, function(v)
if v == "Frozen Horns" then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/SpotzsAlt/xf/main/Frozen%20Horns", true))()
elseif v == "Fire Horns" then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/SpotzsAlt/xf/main/fire", true))()
end
end)

section16:AddLabel("Credits to Spotzs")
section16:AddLabel("Credits to Keo")
section16:AddLabel("Credits to Mnwans")
section16:AddLabel("Credits to Jans")

section17:AddButton("Join Discord", function(a)
end)
section17:AddButton("Copy Invite to Clipboard", function()
        setclipboard('https://discord.gg/3CVuRWW79E')
end)
