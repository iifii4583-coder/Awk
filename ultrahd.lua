-- Ultra HD Admin Tek Script
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- RemoteEvent (otomatik)
local event = Instance.new("RemoteEvent")
event.Name = "UltraAdminEvent"
event.Parent = ReplicatedStorage

-- Şifre
local PASSWORD = "ADMİN123"
local approved = {}

-- Target sistemi
local function getTargets(sender,arg)
	local targets = {}
	if not arg then return targets end
	if arg == "me" then table.insert(targets,sender)
	elseif arg == "all" then for _,p in pairs(Players:GetPlayers()) do table.insert(targets,p) end
	elseif arg == "others" then for _,p in pairs(Players:GetPlayers()) do if p~=sender then table.insert(targets,p) end end
	else for _,p in pairs(Players:GetPlayers()) do if string.lower(p.Name)==string.lower(arg) then table.insert(targets,p) end end
	end
	return targets
end

-- Skybox
local function setSky(id)
	local sky = Lighting:FindFirstChildOfClass("Sky") or Instance.new("Sky",Lighting)
	local asset = "rbxassetid://"..id
	sky.SkyboxBk = asset
	sky.SkyboxDn = asset
	sky.SkyboxFt = asset
	sky.SkyboxLf = asset
	sky.SkyboxRt = asset
	sky.SkyboxUp = asset
end

-- Komutları çalıştıran fonksiyon
local function runCommand(player,message)
	if not approved[player.UserId] then return end
	local args = string.split(message," ")
	local cmd = string.lower(args[1])
	local targets = getTargets(player,args[2])

	if cmd==":sky" and args[2] then setSky(args[2]) return end

	for _,target in pairs(targets) do
		if target.Character then
			local hum = target.Character:FindFirstChildOfClass("Humanoid")
			local root = target.Character:FindFirstChild("HumanoidRootPart")
			if not hum or not root then return end

			-- Temel hareket ve sağlık
			if cmd==":speed" and args[3] then hum.WalkSpeed = tonumber(args[3])
			elseif cmd==":jump" and args[3] then hum.JumpPower = tonumber(args[3])
			elseif cmd==":heal" then hum.Health = hum.MaxHealth
			elseif cmd==":kill" then hum.Health = 0
			elseif cmd==":freeze" then root.Anchored=true
			elseif cmd==":unfreeze" then root.Anchored=false
			elseif cmd==":invisible" then for _,v in pairs(target.Character:GetDescendants()) do if v:IsA("BasePart") then v.Transparency=1 end end
			elseif cmd==":visible" then for _,v in pairs(target.Character:GetDescendants()) do if v:IsA("BasePart") then v.Transparency=0 end end
			elseif cmd==":sit" then hum.Sit=true

			-- Efektler
			elseif cmd==":fire" then Instance.new("Fire",root)
			elseif cmd==":sparkles" then Instance.new("Sparkles",root)
			elseif cmd==":explode" then local ex=Instance.new("Explosion"); ex.Position=root.Position; ex.Parent=workspace
			elseif cmd==":particle" then local p=Instance.new("ParticleEmitter"); p.Parent=root

			-- Araçlar
			elseif cmd==":givealltools" then for _,tool in pairs(ServerStorage:GetChildren()) do if tool:IsA("Tool") then tool:Clone().Parent=target.Backpack end end

			-- Troll komutlar
			elseif cmd==":noclip" then
				local function noclipLoop()
					if hum then
						hum.PlatformStand=true
						for _,v in pairs(target.Character:GetDescendants()) do
							if v:IsA("BasePart") then
								v.CanCollide=false
							end
						end
					end
				end
				RunService.Stepped:Connect(noclipLoop)
			elseif cmd==":god" then
				hum.MaxHealth=math.huge
				hum.Health=math.huge
			elseif cmd==":bring" and args[3] then
				local t2=getTargets(player,args[3])[1]
				if t2 and t2.Character then target.Character:MoveTo(t2.Character:GetPivot().Position) end
			elseif cmd==":teleport" and args[3] then
				local t2=getTargets(player,args[3])[1]
				if t2 and t2.Character then target.Character:MoveTo(t2.Character:GetPivot().Position) end
			end
		end
	end
end

-- Player ekleme ve GUI
Players.PlayerAdded:Connect(function(player)
	local screenGui = Instance.new("ScreenGui",player:WaitForChild("PlayerGui"))
	screenGui.ResetOnSpawn=false
	local frame = Instance.new("Frame",screenGui)
	frame.Size=UDim2.new(0,350,0,200)
	frame.Position=UDim2.new(0.5,-175,0.5,-100)
	frame.BackgroundColor3=Color3.fromRGB(20,20,20)

	-- Şifre
	local passBox = Instance.new("TextBox",frame)
	passBox.Size=UDim2.new(1,-20,0,30)
	passBox.Position=UDim2.new(0,10,0,10)
	passBox.PlaceholderText="Şifreyi gir"
	local loginBtn = Instance.new("TextButton",frame)
	loginBtn.Size=UDim2.new(1,-20,0,30)
	loginBtn.Position=UDim2.new(0,10,0,50)
	loginBtn.Text="Giriş"

	-- Komut kutusu
	local cmdBox = Instance.new("TextBox",frame)
	cmdBox.Size=UDim2.new(1,-20,0,30)
	cmdBox.Position=UDim2.new(0,10,0,90)
	cmdBox.PlaceholderText="Komut gir"
	local execBtn = Instance.new("TextButton",frame)
	execBtn.Size=UDim2.new(1,-20,0,30)
	execBtn.Position=UDim2.new(0,10,0,130)
	execBtn.Text="Çalıştır"

	-- Login
	loginBtn.MouseButton1Click:Connect(function()
		if passBox.Text==PASSWORD then
			approved[player.UserId]=true
			loginBtn.Text="Başarılı!"
		else
			loginBtn.Text="Yanlış Şifre!"
		end
	end)

	-- Execute
	execBtn.MouseButton1Click:Connect(function()
		if approved[player.UserId] then
			event:FireServer(cmdBox.Text)
			cmdBox.Text=""
		end
	end)
end)

-- RemoteEvent listener
event.OnServerEvent:Connect(runCommand)
