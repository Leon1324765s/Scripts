-- @author	/ nil (deu)
-- @date	/ July 5th, 2019
-- @desc	/ binds2

--[[
	
	new features in binds2:
	- xray
	- waypoint
	- nodes
	- precise tp
	- delete all build parts
	- undo all deletes
	
	improvements from binds1:
	- cleaner code
	- shift binds
	- plenty o' bug fixes
	- configuration section if you're into that
	
	hope you enjoy o/
	
--]]

-- prevents multiple instances of binds2 to be ran
if not _G.binds2init then

-- configuration
local binds = {
	["teleport"] = Enum.KeyCode.T,	-- teleport on top of the part you click on
	["precise"] = Enum.KeyCode.Y,	-- teleport exactly where you click
	["attach"] = Enum.KeyCode.F,	-- attach to a player
	["waypoint"] = Enum.KeyCode.G,	-- creates a waypoint where you're currently standing (shift+G to go to it)
	["clip"] = Enum.KeyCode.Z,		-- disable collisions with parts
	["delete"] = Enum.KeyCode.X,	-- click parts to delete them (U to undo)
	["null"] = Enum.KeyCode.C,		-- default behavior
	["path"] = Enum.KeyCode.V,		-- click and hold to create a part underneath you
	["build"] = Enum.KeyCode.B		-- create bricks
}

local shift_binds = {
	["build"] = Enum.KeyCode.B,		-- clear build parts
	["nodes"] = Enum.KeyCode.N,		-- create/destroy nodes
	["undoall"] = Enum.KeyCode.U,	-- undo all deletes
	["waypoint"] = Enum.KeyCode.G,	-- waypoint (teleport to)
	["delwp"] = Enum.KeyCode.H,		-- deletes waypoint
	["xray"] = Enum.KeyCode.X		-- xray
}

local build_size = Vector3.new(4, 1, 4)
local build_reflectance = 1
local build_color = Color3.fromRGB(160, 160, 160)
local build_material = Enum.Material.SmoothPlastic
local build_transparency = 0

local path_size = Vector3.new(8, 1, 8)
local path_material = Enum.Material.SmoothPlastic
local path_transparency = 0
local path_reflectance = 1
local path_color = Color3.fromRGB(160, 160, 160)

local xray_transparency = 0.5

-- services
local uis = game:GetService("UserInputService")
local ts = game:GetService("TweenService")

-- variables
_G.binds2init = true

local plr = game.Players.LocalPlayer
local mouse = plr:GetMouse()

local mode = "null"

local waypoint = nil

local noclip = false
local xray = false
local nodes_enabled = false
local shifting = false

local no_select = {
	"null", "build", "path", "teleport", "precise"
}

local colors = {
	["null"] = Color3.fromRGB(166, 166, 166),
	["clip"] = Color3.fromRGB(189, 148, 78),
	["delete"] = Color3.fromRGB(189, 102, 102),
	["build"] = Color3.fromRGB(133, 172, 189),
	["path"] = Color3.fromRGB(81, 78, 189),
	["teleport"] = Color3.fromRGB(225, 133, 255),
	["precise"] = Color3.fromRGB(225, 133, 255),
	["attach"] = Color3.fromRGB(80, 255, 162),
	["waypoint"] = Color3.fromRGB(29, 157, 255),
	["nodes"] = Color3.fromRGB(142, 255, 116)
}

local f = Instance.new("Folder", game.Workspace)
local fb = Instance.new("Folder", f)
f.Name = "binds2"
fb.Name = "build_parts"

local deleted = {}

local del = Instance.new("Folder", game.ReplicatedStorage)
del.Name = "binds2_deleted"

local attached = nil
local attaching = false

local s = Instance.new("SelectionBox", f)
s.Name = "select"
s.Color3 = colors[mode]
s.LineThickness = 0.03
s.Transparency = 0.3

-- functions
init = function()
	local sg = Instance.new("ScreenGui", game.Players.LocalPlayer.PlayerGui)
	sg.Name = "binds2"
	sg.ResetOnSpawn = false
	sg.DisplayOrder = 100
	
	local main = Instance.new("Frame", sg)
	main.Name = "main"
	main.AnchorPoint = Vector2.new(0, 1)
	main.Position = UDim2.new(0, 15, 1, -15)
	main.BackgroundTransparency = 1
	main.Size = UDim2.new(0, 250, 0, 16)
	
	local label = Instance.new("TextLabel", main)
	label.Name = "label"
	label.Text = "mode:"
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.SourceSansBold
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextStrokeTransparency = 0.8
	label.TextScaled = true
	label.Size = UDim2.new(0, 39, 1, 0)
	label.TextXAlignment = Enum.TextXAlignment.Left
	
	local ml = Instance.new("TextLabel", main)
	ml.Name = "mode"
	ml.Text = mode
	ml.BackgroundTransparency = 1
	ml.TextColor3 = colors[mode]
	ml.Font = Enum.Font.SourceSansBold
	ml.TextStrokeTransparency = 0.8
	ml.TextScaled = true
	ml.Position = UDim2.new(0, 42, 0, 0)
	ml.Size = UDim2.new(1, -42, 1, 0)
	ml.TextXAlignment = Enum.TextXAlignment.Left
	
	print("[binds2] initialized")
end

createNode = function(user, class)
	local b = Instance.new("BillboardGui")
	b.Name = "node"
	b.LightInfluence = 0
	b.Size = UDim2.new(4, 0, 1, 0)
	b.ZIndexBehavior = Enum.ZIndexBehavior.Global
	b.AlwaysOnTop = true
	b.Parent = user
	
	if class == "nodes" and user:IsA("Player") then
		b.Parent = user.Character.HumanoidRootPart
	end
	
	local m = Instance.new("Frame", b)
	m.Name = "main"
	m.Size = UDim2.new(1, 0, 1, 0)
	m.BackgroundTransparency = 1
	
	local i = Instance.new("Frame", m)
	i.Name = "indicator"
	i.BackgroundColor3 = colors[class]
	i.Size = UDim2.new(0, 7, 0, 7)
	i.AnchorPoint = Vector2.new(0.5, 0.5)
	i.Position = UDim2.new(0.5, 0, 0.5, 0)
	i.BorderSizePixel = 0
	
	local l = Instance.new("TextLabel", m)
	l.Name = "label"
	l.TextColor3 = Color3.fromRGB(255, 255, 255)
	l.Font = Enum.Font.SourceSansBold
	l.TextSize = 14
	l.TextStrokeTransparency = 0.6
	l.Size = UDim2.new(1, 0, 1, 0)
	l.AnchorPoint = Vector2.new(0.5, 0.2)
	l.Position = UDim2.new(0.5, 0, 0.5, 0)
	l.BackgroundTransparency = 1
	
		
	if class == "nodes" then
		l.Text = user.Name
	elseif class == "waypoint" then
		l.Text = "waypoint"
	end
end

shift = function(task)
	if task == "build" then
		for _,v in pairs(fb:GetChildren()) do
			v:Destroy()
		end
	elseif task == "nodes" then
		if not nodes_enabled then
			for _,v in pairs(game.Players:GetPlayers()) do
				if v ~= plr then
					createNode(v, "nodes")
				end
			end
			nodes_enabled = true
		else
			nodes_enabled = false
			for _,v in pairs(game.Players:GetPlayers()) do
				if v ~= plr and v.Character:FindFirstChild("HumanoidRootPart") then
					if v.Character.HumanoidRootPart:FindFirstChild("node") then
						v.Character.HumanoidRootPart.node:Destroy()
					end
				end
			end
		end
	elseif task == "waypoint" then
		if not waypoint then
			local p = Instance.new("Part", f)
			p.Anchored = true
			p.CanCollide = false
			p.Size = Vector3.new(1, 1, 1)
			p.Color = Color3.fromRGB(255, 255, 255)
			p.Material = Enum.Material.Neon
			p.CFrame = plr.Character.HumanoidRootPart.CFrame
			
			createNode(p, "waypoint")
			waypoint = p
		else
			plr.Character.HumanoidRootPart.CFrame = waypoint.CFrame
		end
	elseif task == "delwp" then
		if waypoint then
			waypoint:Destroy()
			waypoint = nil
		end
	elseif task == "xray" then
		search = function(model)
			for _,v in pairs(model:GetChildren()) do
				if #v:GetChildren() > 0 then
					search(v)
				end
				
				if not v.Parent:FindFirstChild("Humanoid") then
					if v:IsA("BasePart") and v.CFrame.Y > plr.Character.HumanoidRootPart.CFrame.Y and not v.Parent:IsA("Accessory") and not xray then
						if not v:FindFirstChild("xrayTransparency") then
							local ot = Instance.new("NumberValue", v)
							ot.Name = "xrayTransparency"
							ot.Value = v.Transparency
						end
						
						v.Transparency = xray_transparency				
					elseif v:IsA("BasePart") and xray and v:FindFirstChild("xrayTransparency") then
						v.Transparency = v.xrayTransparency.Value
						v.xrayTransparency:Destroy()
					end
				end
			end
		end
		
		if not xray then
			search(game.Workspace)
			xray = true
		else
			search(game.Workspace)
			xray = false
		end
	elseif task == "undoall" then
		for _,v in pairs(del:GetChildren()) do
			if v:FindFirstChild("bindsParent") then
				v.Parent = v.bindsParent.Value
				v.bindsParent:Destroy()
			end
		end
		
		deleted = {}
	end
end

update = function(old, new)
	-- updates the ui
	if new ~= "attach" then
		attached = nil
		attaching = false
	end
	
	local label = plr:WaitForChild("PlayerGui").binds2.main.mode
	local twn = ts:Create(label, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {TextColor3 = colors[new]})
	twn:Play()
	
	if new == "precise" then
		label.Text = "precise teleport"
	else
		label.Text = new
	end
	
	mode = new
end

-- events
mouse.Button1Down:connect(function()
	local mt = mouse.Target
	
	-- modes that don't require mouse.Target to exist or not
	if mode == "path" then
		if not f:FindFirstChild("path") then
			local p = Instance.new("Part", f)
			p.Name = "path"
			p.Size = path_size
			p.Material = path_material
			p.Transparency = path_transparency
			p.Reflectance = path_reflectance
			p.Color = path_color
			p.Anchored = true
			p.TopSurface = Enum.SurfaceType.Smooth
			p.BottomSurface = Enum.SurfaceType.Smooth
		end
	elseif mode == "waypoint" then
		if not waypoint and plr.Character:FindFirstChild("HumanoidRootPart") then
			local p = Instance.new("Part", f)
			p.Name = "waypoint"
			p.Size = Vector3.new(1, 1, 1)
			p.Anchored = true
			p.CanCollide = false
			p.Material = Enum.Material.Neon
			p.CFrame = plr.Character.HumanoidRootPart.CFrame
			
			createNode(p, "waypoint")
			waypoint = p
		elseif waypoint and f:FindFirstChild("waypoint") and plr.Character:FindFirstChild("HumanoidRootPart") then
			f.waypoint.CFrame = plr.Character.HumanoidRootPart.CFrame
		end
	end
	
	if mt then
		if mode == "clip" then
			if not mt:FindFirstChild("clipTransparency") and not mt:FindFirstChild("collidable") then
				if not mt:FindFirstChild("xrayTransparency") then
					local ct = Instance.new("NumberValue", mt)
					ct.Name = "clipTransparency"
					ct.Value = mt.Transparency
				end
				
				local cv = Instance.new("BoolValue", mt)
				cv.Name = "collidable"
				cv.Value = mt.CanCollide
				
				mt.Transparency = 0.5
				mt.CanCollide = false
			end
		elseif mode == "delete" then
			-- don't actually delete so it retains all children
			local stv = Instance.new("ObjectValue", mt)
			stv.Name = "bindsParent"
			stv.Value = mt.Parent
			
			table.insert(deleted, #deleted + 1, mt)
			mt.Parent = del
		elseif mode == "build" then
			local p = Instance.new("Part", fb)
			p.Size = build_size
			p.Reflectance = build_reflectance
			p.Color = build_color
			p.Material = build_material
			p.Transparency = build_transparency
			p.Anchored = true
			p.CFrame = mouse.Hit
		elseif mode == "teleport" then
			plr.Character:MoveTo(mouse.Hit.Position)
		elseif mode == "precise" then
			plr.Character:FindFirstChild("HumanoidRootPart").CFrame = mouse.Hit
		elseif mode == "attach" then
			if mt.Parent:FindFirstChild("Humanoid") then
				attached = mt.Parent
				attaching = true
			end
		end
	end
end)

mouse.Button1Up:connect(function()
	if mode == "path" and f:FindFirstChild("path") then
		f.path:Destroy()
	end
end)

mouse.Button2Down:connect(function()
	local mt = mouse.Target
	if mt and mode == "clip" then
		if mt:FindFirstChild("xrayTransparency") or mt:FindFirstChild("clipTransparency") and mt:FindFirstChild("collidable") then
			if mt:FindFirstChild("xrayTransparency") then
				mt.Transparency = xray_transparency
				mt.CanCollide = mt.collidable.Value
			
				mt.collidable:Destroy()
			else
				mt.Transparency = mt.clipTransparency.Value
				mt.CanCollide = mt.collidable.Value
				
				mt.clipTransparency:Destroy()
				mt.collidable:Destroy()
			end
		end
	end
end)

game.Players.PlayerAdded:connect(function(player)
	player.CharacterAdded:connect(function(char)
		spawn(function()
			repeat wait() until char:FindFirstChild("HumanoidRootPart")
			if nodes_enabled then
				createNode(player, "nodes")
			end
		end)
	end)
end)

game.Players.PlayerRemoving:connect(function(player)
	if attached and attaching then
		if attached.Name == player.Name then
			attached = nil
			attaching = false
		end
	end
end)

game:GetService("RunService").RenderStepped:connect(function()
	local sel = true
	for _,v in pairs(no_select) do
		if mode == v then
			sel = false
			s.Adornee = nil
		end
	end
	
	if attaching and attached then
		pcall(function()
			plr.Character.HumanoidRootPart.CFrame = attached.HumanoidRootPart.CFrame
		end)
	end
	
	local mt = mouse.Target
	if mt and sel then
		s.Adornee = mouse.Target
		s.Color3 = colors[mode]
	elseif not mt and sel then
		s.Adornee = nil
	end
	
	if mode == "path" then
		if f:FindFirstChild("path") and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
			pcall(function()
				f.path.Position = Vector3.new(plr.Character.HumanoidRootPart.Position.X, plr.Character.HumanoidRootPart.Position.Y - 3.1, plr.Character.HumanoidRootPart.Position.Z)
			end)
		end
	end
end)

uis.InputBegan:connect(function(input, gpe)
	if not gpe and input.UserInputType == Enum.UserInputType.Keyboard then
		if input.KeyCode == Enum.KeyCode.LeftShift then
			shifting = true
		elseif input.KeyCode == Enum.KeyCode.U and not shifting then
			if #deleted >= 1 and deleted[#deleted]:FindFirstChild("bindsParent") then
				deleted[#deleted].Parent = deleted[#deleted].bindsParent.Value
				deleted[#deleted].bindsParent:Destroy()
				table.remove(deleted, #deleted)
			end
		else
			if shifting then
				for i,v in pairs(shift_binds) do
					if input.KeyCode == v then
						shift(i)
					end
				end
			else
				for i,v in pairs(binds) do
					if input.KeyCode == v then
						update(mode, i)
					end
				end
			end
		end
	end
end)

uis.InputEnded:connect(function(input, gpe)
	if not gpe and input.UserInputType == Enum.UserInputType.Keyboard then
		if input.KeyCode == Enum.KeyCode.LeftShift then
			if shifting then
				shifting = false
			end
		end
	end
end)

init()

end -- don't delete me!