-- Piggy Menu | Key System + ESP / Teleport / Player / Settings
local KEY = "Nurgisa_gay333"

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local lp = Players.LocalPlayer

local parentGui = (gethui and gethui()) or game:GetService("CoreGui")
pcall(function() if parentGui:FindFirstChild("PiggyMenu") then parentGui.PiggyMenu:Destroy() end end)

local gui = Instance.new("ScreenGui")
gui.Name = "PiggyMenu"
gui.ResetOnSpawn = false
gui.Parent = parentGui

------------------------------------------------------------
-- ТЕМЫ
------------------------------------------------------------
local themes = {
	["Синий"]   = {bg = Color3.fromRGB(15,25,45),  panel = Color3.fromRGB(25,45,80),  accent = Color3.fromRGB(50,120,255), text = Color3.new(1,1,1)},
	["Красный"] = {bg = Color3.fromRGB(40,12,12),  panel = Color3.fromRGB(75,25,25),  accent = Color3.fromRGB(235,50,50),  text = Color3.new(1,1,1)},
	["Белый"]   = {bg = Color3.fromRGB(240,240,240), panel = Color3.fromRGB(210,210,215), accent = Color3.fromRGB(120,120,130), text = Color3.new(0,0,0)},
	["Чёрный"]  = {bg = Color3.fromRGB(12,12,12),  panel = Color3.fromRGB(30,30,30),  accent = Color3.fromRGB(90,90,90),  text = Color3.new(1,1,1)},
	["Зелёный"] = {bg = Color3.fromRGB(12,35,18),  panel = Color3.fromRGB(25,65,35),  accent = Color3.fromRGB(50,200,90),  text = Color3.new(1,1,1)},
}
local theme = themes["Синий"]
local menuTransparency = 0
local reg = {} -- {объект, роль}

local function themed(obj, role)
	table.insert(reg, {obj, role})
	return obj
end

local function applyTheme()
	for _, r in ipairs(reg) do
		local o, role = r[1], r[2]
		if o and o.Parent then
			if role == "bg" then
				o.BackgroundColor3 = theme.bg
				o.BackgroundTransparency = menuTransparency
			elseif role == "panel" then
				o.BackgroundColor3 = theme.panel
				o.BackgroundTransparency = math.clamp(menuTransparency, 0, 0.9)
			elseif role == "accent" then
				o.BackgroundColor3 = theme.accent
			elseif role == "text" then
				o.TextColor3 = theme.text
			end
		end
	end
end

------------------------------------------------------------
-- UI-хелперы
------------------------------------------------------------
local function corner(o, r)
	local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 8); c.Parent = o
end

local function frame(parent, size, pos, role)
	local f = Instance.new("Frame")
	f.Size, f.Position, f.BorderSizePixel = size, pos or UDim2.new(), 0
	f.Parent = parent
	corner(f)
	themed(f, role or "panel")
	return f
end

local function label(parent, text, size, pos, ts)
	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1
	l.Size, l.Position = size, pos or UDim2.new()
	l.Text, l.TextSize, l.Font = text, ts or 14, Enum.Font.GothamBold
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.Parent = parent
	themed(l, "text")
	return l
end

local function button(parent, text, size, pos, cb, role)
	local b = Instance.new("TextButton")
	b.Size, b.Position, b.BorderSizePixel = size, pos or UDim2.new(), 0
	b.Text, b.TextSize, b.Font = text, 14, Enum.Font.GothamBold
	b.AutoButtonColor = true
	b.Parent = parent
	corner(b)
	themed(b, role or "accent")
	themed(b, "text")
	b.MouseButton1Click:Connect(cb)
	return b
end

local function drag(handle, target)
	local dragging, start, startPos
	handle.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging, start, startPos = true, i.Position, target.Position
			i.Changed:Connect(function()
				if i.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	UIS.InputChanged:Connect(function(i)
		if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			local d = i.Position - start
			target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
		end
	end)
end

-- Переключатель
local function toggle(parent, text, y, cb)
	local row = frame(parent, UDim2.new(1, -10, 0, 34), UDim2.new(0, 5, 0, y), "panel")
	label(row, text, UDim2.new(1, -70, 1, 0), UDim2.new(0, 10, 0, 0))
	local state = false
	local b = Instance.new("TextButton")
	b.Size, b.Position = UDim2.new(0, 50, 0, 22), UDim2.new(1, -58, 0.5, -11)
	b.Text, b.BorderSizePixel, b.Font, b.TextSize = "OFF", 0, Enum.Font.GothamBold, 12
	b.BackgroundColor3 = Color3.fromRGB(120, 40, 40)
	b.TextColor3 = Color3.new(1, 1, 1)
	b.Parent = row
	corner(b, 11)
	b.MouseButton1Click:Connect(function()
		state = not state
		b.Text = state and "ON" or "OFF"
		b.BackgroundColor3 = state and Color3.fromRGB(40, 150, 60) or Color3.fromRGB(120, 40, 40)
		cb(state)
	end)
end

-- Поле ввода числа
local function numberBox(parent, text, y, default, cb)
	local row = frame(parent, UDim2.new(1, -10, 0, 34), UDim2.new(0, 5, 0, y), "panel")
	label(row, text, UDim2.new(1, -90, 1, 0), UDim2.new(0, 10, 0, 0))
	local tb = Instance.new("TextBox")
	tb.Size, tb.Position = UDim2.new(0, 70, 0, 24), UDim2.new(1, -78, 0.5, -12)
	tb.Text, tb.Font, tb.TextSize, tb.BorderSizePixel = tostring(default), Enum.Font.GothamBold, 13, 0
	tb.BackgroundColor3, tb.TextColor3 = Color3.fromRGB(30, 30, 30), Color3.new(1, 1, 1)
	tb.ClearTextOnFocus = false
	tb.Parent = row
	corner(tb, 6)
	tb.FocusLost:Connect(function()
		local n = tonumber(tb.Text)
		if n then cb(n) else tb.Text = tostring(default) end
	end)
end

------------------------------------------------------------
-- ПОИСК ЦЕЛЕЙ (Piggy)
-- Если в игре названия другие — добавь слова в эти списки
------------------------------------------------------------
local itemWords    = {"key","red key","redkey","key code","keycode","spanner","hammer","crowbar","wrench","bat","plank","lighter","medkit","battery","wire","bucket","code","paper","rope","gasoline","fuel","tool","screwdriver","scissors","lever","gear","coin","item","pickup"}
local monsterWords = {"piggy","pig","monster","enemy","bot","boss","zombie","killer"}

local function matches(name, list)
	name = name:lower()
	for _, w in ipairs(list) do
		if name:find(w, 1, true) then return true end
	end
	return false
end

local function isPlayerModel(m)
	for _, p in ipairs(Players:GetPlayers()) do
		if p.Character and (m == p.Character or m:IsDescendantOf(p.Character)) then return true end
	end
	return false
end

local function posOf(o)
	if o:IsA("Model") then
		local ok, cf = pcall(function() return o:GetPivot() end)
		return ok and cf.Position or nil
	elseif o:IsA("BasePart") then
		return o.Position
	elseif o:IsA("Tool") then
		local h = o:FindFirstChild("Handle")
		return h and h.Position
	end
end

-- возвращает список объектов нужного типа
local function getTargets(kind)
	local res = {}
	if kind == "players" then
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
				table.insert(res, p.Character)
			end
		end
		return res
	end
	for _, o in ipairs(workspace:GetDescendants()) do
		if (o:IsA("Model") or o:IsA("BasePart") or o:IsA("Tool")) and not isPlayerModel(o) then
			if kind == "monsters" then
				if o:IsA("Model") and o:FindFirstChildOfClass("Humanoid") and matches(o.Name, monsterWords) then
					table.insert(res, o)
				end
			elseif kind == "items" then
				if (o:IsA("Tool") or matches(o.Name, itemWords)) and posOf(o) then
					if not (o.Parent and o.Parent:IsA("Model") and matches(o.Parent.Name, itemWords)) then
						table.insert(res, o)
					end
				end
			end
		end
	end
	return res
end

------------------------------------------------------------
-- ESP
------------------------------------------------------------
local espColors = {
	players  = Color3.fromRGB(80, 160, 255),
	monsters = Color3.fromRGB(255, 50, 50),
	items    = Color3.fromRGB(60, 255, 120),
}
local espOn = {players = false, monsters = false, items = false}
local espObjs = {players = {}, monsters = {}, items = {}}

local function clearESP(kind)
	for o, data in pairs(espObjs[kind]) do
		pcall(function() data.hl:Destroy() end)
		pcall(function() data.bb:Destroy() end)
	end
	espObjs[kind] = {}
end

local function addESP(kind, o)
	local adornee = o:IsA("Tool") and o:FindFirstChild("Handle") or o
	if not adornee then return end
	local hl = Instance.new("Highlight")
	hl.FillColor, hl.OutlineColor = espColors[kind], espColors[kind]
	hl.FillTransparency = 0.6
	hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	hl.Adornee = o:IsA("Tool") and adornee or o
	hl.Parent = gui

	local bb = Instance.new("BillboardGui")
	bb.Size = UDim2.new(0, 120, 0, 20)
	bb.AlwaysOnTop = true
	bb.StudsOffset = Vector3.new(0, 3, 0)
	bb.Adornee = adornee:IsA("Model") and (adornee.PrimaryPart or adornee:FindFirstChildWhichIsA("BasePart", true)) or adornee
	bb.Parent = gui
	local t = Instance.new("TextLabel")
	t.Size, t.BackgroundTransparency = UDim2.new(1, 0, 1, 0), 1
	t.Text, t.TextColor3, t.TextStrokeTransparency = o.Name, espColors[kind], 0
	t.Font, t.TextSize = Enum.Font.GothamBold, 13
	t.Parent = bb
	espObjs[kind][o] = {hl = hl, bb = bb, label = t}
end

task.spawn(function()
	while gui.Parent do
		for kind, on in pairs(espOn) do
			if on then
				local targets = getTargets(kind)
				local alive = {}
				for _, o in ipairs(targets) do
					alive[o] = true
					if not espObjs[kind][o] then addESP(kind, o) end
				end
				for o, d in pairs(espObjs[kind]) do
					if not alive[o] or not o.Parent then
						pcall(function() d.hl:Destroy() end)
						pcall(function() d.bb:Destroy() end)
						espObjs[kind][o] = nil
					elseif lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
						local p = posOf(o)
						if p then
							local dist = math.floor((lp.Character.HumanoidRootPart.Position - p).Magnitude)
							d.label.Text = o.Name .. " [" .. dist .. "m]"
						end
					end
				end
			end
		end
		task.wait(1)
	end
end)

------------------------------------------------------------
-- ТЕЛЕПОРТ
------------------------------------------------------------
local function tpTo(o)
	local char = lp.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	local p = o and posOf(o)
	if hrp and p then
		hrp.CFrame = CFrame.new(p + Vector3.new(0, 4, 0))
	end
end

local function nearest(list)
	local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	local best, bd
	for _, o in ipairs(list) do
		local p = posOf(o)
		if p then
			local d = (p - hrp.Position).Magnitude
			if not bd or d < bd then best, bd = o, d end
		end
	end
	return best
end

------------------------------------------------------------
-- ГЛАВНОЕ МЕНЮ
------------------------------------------------------------
local main = Instance.new("Frame")
main.Size, main.Position = UDim2.new(0, 400, 0, 330), UDim2.new(0.5, -200, 0.5, -165)
main.BorderSizePixel, main.Visible = 0, false
main.Parent = gui
corner(main, 12)
themed(main, "bg")

local title = frame(main, UDim2.new(1, 0, 0, 36), UDim2.new(), "accent")
label(title, "  Piggy Menu", UDim2.new(1, -80, 1, 0), UDim2.new(), 16)
drag(title, main)

button(title, "-", UDim2.new(0, 30, 0, 24), UDim2.new(1, -66, 0, 6), function()
	main.Size = main.Size.Y.Offset > 40 and UDim2.new(0, 400, 0, 36) or UDim2.new(0, 400, 0, 330)
end, "panel")
button(title, "X", UDim2.new(0, 30, 0, 24), UDim2.new(1, -33, 0, 6), function()
	for k in pairs(espObjs) do clearESP(k) end
	gui:Destroy()
end, "panel")

local tabBar = frame(main, UDim2.new(1, -10, 0, 30), UDim2.new(0, 5, 0, 42), "panel")
local pages, tabButtons = {}, {}
local tabNames = {"Visual", "Teleport", "Player", "Setting"}

local function showTab(name)
	for n, p in pairs(pages) do p.Visible = (n == name) end
	for n, b in pairs(tabButtons) do b.BackgroundTransparency = (n == name) and 0 or 0.6 end
end

for i, name in ipairs(tabNames) do
	local page = Instance.new("ScrollingFrame")
	page.Size, page.Position = UDim2.new(1, -10, 1, -86), UDim2.new(0, 5, 0, 80)
	page.BackgroundTransparency, page.BorderSizePixel = 1, 0
	page.ScrollBarThickness = 4
	page.CanvasSize = UDim2.new(0, 0, 0, 0)
	page.AutomaticCanvasSize = Enum.AutomaticSize.Y
	page.Visible = false
	page.Parent = main
	pages[name] = page

	tabButtons[name] = button(tabBar, name, UDim2.new(0.25, -4, 1, -6), UDim2.new((i - 1) * 0.25, 2, 0, 3), function()
		showTab(name)
	end)
end

-- ===== 1) VISUAL =====
do
	local p = pages["Visual"]
	toggle(p, "ESP Игроки",   0,   function(s) espOn.players  = s; if not s then clearESP("players")  end end)
	toggle(p, "ESP Монстры",  40,  function(s) espOn.monsters = s; if not s then clearESP("monsters") end end)
	toggle(p, "ESP Предметы", 80,  function(s) espOn.items    = s; if not s then clearESP("items")    end end)
end

-- ===== 2) TELEPORT =====
do
	local p = pages["Teleport"]
	label(p, "К ближайшему:", UDim2.new(1, 0, 0, 20), UDim2.new(0, 8, 0, 0))
	button(p, "К предмету", UDim2.new(1, -10, 0, 32), UDim2.new(0, 5, 0, 24), function() tpTo(nearest(getTargets("items")))    end)
	button(p, "К монстру",  UDim2.new(0.5, -8, 0, 32), UDim2.new(0, 5, 0, 62),  function() tpTo(nearest(getTargets("monsters"))) end)
	button(p, "К игроку",   UDim2.new(0.5, -8, 0, 32), UDim2.new(0.5, 3, 0, 62), function() tpTo(nearest(getTargets("players")))  end)

	label(p, "Выбрать игрока:", UDim2.new(1, 0, 0, 20), UDim2.new(0, 8, 0, 104))
	local list = Instance.new("Frame")
	list.Size, list.Position = UDim2.new(1, -10, 0, 0), UDim2.new(0, 5, 0, 128)
	list.AutomaticSize = Enum.AutomaticSize.Y
	list.BackgroundTransparency = 1
	list.Parent = p
	local ll = Instance.new("UIListLayout"); ll.Padding = UDim.new(0, 4); ll.Parent = list

	local function refresh()
		for _, c in ipairs(list:GetChildren()) do
			if c:IsA("TextButton") then c:Destroy() end
		end
		for _, pl in ipairs(Players:GetPlayers()) do
			if pl ~= lp then
				button(list, pl.DisplayName .. " (@" .. pl.Name .. ")", UDim2.new(1, 0, 0, 28), nil, function()
					if pl.Character then tpTo(pl.Character) end
				end, "panel")
			end
		end
	end
	button(p, "Обновить", UDim2.new(0, 90, 0, 22), UDim2.new(1, -100, 0, 103), refresh, "panel")
	refresh()
	Players.PlayerAdded:Connect(refresh)
	Players.PlayerRemoving:Connect(function() task.wait(0.2); refresh() end)
end

-- ===== 3) PLAYER =====
do
	local p = pages["Player"]
	local speedOn, jumpOn = false, false
	local speedVal, jumpVal = 50, 100

	toggle(p, "SpeedHack", 0, function(s)
		speedOn = s
		if not s then
			local h = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
			if h then h.WalkSpeed = 16 end
		end
	end)
	numberBox(p, "Скорость", 40, speedVal, function(n) speedVal = math.clamp(n, 0, 300) end)

	toggle(p, "Jump Power", 80, function(s)
		jumpOn = s
		if not s then
			local h = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
			if h then h.UseJumpPower = true; h.JumpPower = 50 end
		end
	end)
	numberBox(p, "Сила прыжка", 120, jumpVal, function(n) jumpVal = math.clamp(n, 0, 500) end)

	RunService.Heartbeat:Connect(function()
		local h = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
		if not h then return end
		if speedOn then h.WalkSpeed = speedVal end
		if jumpOn then h.UseJumpPower = true; h.JumpPower = jumpVal end
	end)
end

-- ===== 4) SETTING =====
do
	local p = pages["Setting"]
	label(p, "Тема меню:", UDim2.new(1, 0, 0, 20), UDim2.new(0, 8, 0, 0))
	local order = {"Синий", "Красный", "Белый", "Чёрный", "Зелёный"}
	for i, n in ipairs(order) do
		local col = (i - 1) % 2
		local row = math.floor((i - 1) / 2)
		button(p, n, UDim2.new(0.5, -8, 0, 30), UDim2.new(col * 0.5, col == 0 and 5 or 3, 0, 24 + row * 36), function()
			theme = themes[n]
			applyTheme()
		end)
	end

	label(p, "Прозрачность меню:", UDim2.new(1, 0, 0, 20), UDim2.new(0, 8, 0, 142))
	local bar = frame(p, UDim2.new(1, -20, 0, 14), UDim2.new(0, 10, 0, 168), "panel")
	local fill = frame(bar, UDim2.new(0, 0, 1, 0), nil, "accent")
	local knob = Instance.new("Frame")
	knob.Size, knob.BackgroundColor3, knob.BorderSizePixel = UDim2.new(0, 18, 0, 18), Color3.new(1, 1, 1), 0
	knob.Position = UDim2.new(0, -9, 0.5, -9)
	knob.Parent = bar
	corner(knob, 9)

	local pct = label(p, "0%", UDim2.new(1, 0, 0, 20), UDim2.new(0, 10, 0, 190))

	local sliding = false
	local function setFromX(x)
		local rel = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
		fill.Size = UDim2.new(rel, 0, 1, 0)
		knob.Position = UDim2.new(rel, -9, 0.5, -9)
		menuTransparency = rel * 0.8 -- максимум 80%, чтобы меню не пропало
		pct.Text = math.floor(rel * 100) .. "%"
		applyTheme()
	end
	bar.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			sliding = true; setFromX(i.Position.X)
		end
	end)
	UIS.InputChanged:Connect(function(i)
		if sliding and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			setFromX(i.Position.X)
		end
	end)
	UIS.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			sliding = false
		end
	end)
end

showTab("Visual")
applyTheme()

------------------------------------------------------------
-- КЛЮЧ
------------------------------------------------------------
local keyFrame = Instance.new("Frame")
keyFrame.Size, keyFrame.Position = UDim2.new(0, 320, 0, 170), UDim2.new(0.5, -160, 0.5, -85)
keyFrame.BorderSizePixel = 0
keyFrame.Parent = gui
corner(keyFrame, 12)
themed(keyFrame, "bg")

local kt = label(keyFrame, "Введите ключ", UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 0, 10), 18)
kt.TextXAlignment = Enum.TextXAlignment.Center

local box = Instance.new("TextBox")
box.Size, box.Position = UDim2.new(1, -40, 0, 34), UDim2.new(0, 20, 0, 50)
box.PlaceholderText, box.Text = "Ключ...", ""
box.Font, box.TextSize, box.BorderSizePixel = Enum.Font.GothamBold, 14, 0
box.BackgroundColor3, box.TextColor3 = Color3.fromRGB(35, 35, 35), Color3.new(1, 1, 1)
box.ClearTextOnFocus = false
box.Parent = keyFrame
corner(box, 8)

local status = label(keyFrame, "", UDim2.new(1, 0, 0, 18), UDim2.new(0, 0, 0, 90), 13)
status.TextXAlignment = Enum.TextXAlignment.Center

local function check()
	if box.Text == KEY then
		status.Text = "Ключ верный!"
		status.TextColor3 = Color3.fromRGB(60, 220, 90)
		task.wait(0.5)
		keyFrame:Destroy()
		main.Visible = true
	else
		status.Text = "Неверный ключ"
		status.TextColor3 = Color3.fromRGB(240, 60, 60)
	end
end
button(keyFrame, "Войти", UDim2.new(1, -40, 0, 34), UDim2.new(0, 20, 0, 118), check)
box.FocusLost:Connect(function(enter) if enter then check() end end)
drag(keyFrame, keyFrame)-- Piggy Menu | Key System + ESP / Teleport / Player / Settings
local KEY = "Nurgisa_gay333"

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local lp = Players.LocalPlayer

local parentGui = (gethui and gethui()) or game:GetService("CoreGui")
pcall(function() if parentGui:FindFirstChild("PiggyMenu") then parentGui.PiggyMenu:Destroy() end end)

local gui = Instance.new("ScreenGui")
gui.Name = "PiggyMenu"
gui.ResetOnSpawn = false
gui.Parent = parentGui

------------------------------------------------------------
-- ТЕМЫ
------------------------------------------------------------
local themes = {
	["Синий"]   = {bg = Color3.fromRGB(15,25,45),  panel = Color3.fromRGB(25,45,80),  accent = Color3.fromRGB(50,120,255), text = Color3.new(1,1,1)},
	["Красный"] = {bg = Color3.fromRGB(40,12,12),  panel = Color3.fromRGB(75,25,25),  accent = Color3.fromRGB(235,50,50),  text = Color3.new(1,1,1)},
	["Белый"]   = {bg = Color3.fromRGB(240,240,240), panel = Color3.fromRGB(210,210,215), accent = Color3.fromRGB(120,120,130), text = Color3.new(0,0,0)},
	["Чёрный"]  = {bg = Color3.fromRGB(12,12,12),  panel = Color3.fromRGB(30,30,30),  accent = Color3.fromRGB(90,90,90),  text = Color3.new(1,1,1)},
	["Зелёный"] = {bg = Color3.fromRGB(12,35,18),  panel = Color3.fromRGB(25,65,35),  accent = Color3.fromRGB(50,200,90),  text = Color3.new(1,1,1)},
}
local theme = themes["Синий"]
local menuTransparency = 0
local reg = {} -- {объект, роль}

local function themed(obj, role)
	table.insert(reg, {obj, role})
	return obj
end

local function applyTheme()
	for _, r in ipairs(reg) do
		local o, role = r[1], r[2]
		if o and o.Parent then
			if role == "bg" then
				o.BackgroundColor3 = theme.bg
				o.BackgroundTransparency = menuTransparency
			elseif role == "panel" then
				o.BackgroundColor3 = theme.panel
				o.BackgroundTransparency = math.clamp(menuTransparency, 0, 0.9)
			elseif role == "accent" then
				o.BackgroundColor3 = theme.accent
			elseif role == "text" then
				o.TextColor3 = theme.text
			end
		end
	end
end

------------------------------------------------------------
-- UI-хелперы
------------------------------------------------------------
local function corner(o, r)
	local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 8); c.Parent = o
end

local function frame(parent, size, pos, role)
	local f = Instance.new("Frame")
	f.Size, f.Position, f.BorderSizePixel = size, pos or UDim2.new(), 0
	f.Parent = parent
	corner(f)
	themed(f, role or "panel")
	return f
end

local function label(parent, text, size, pos, ts)
	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1
	l.Size, l.Position = size, pos or UDim2.new()
	l.Text, l.TextSize, l.Font = text, ts or 14, Enum.Font.GothamBold
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.Parent = parent
	themed(l, "text")
	return l
end

local function button(parent, text, size, pos, cb, role)
	local b = Instance.new("TextButton")
	b.Size, b.Position, b.BorderSizePixel = size, pos or UDim2.new(), 0
	b.Text, b.TextSize, b.Font = text, 14, Enum.Font.GothamBold
	b.AutoButtonColor = true
	b.Parent = parent
	corner(b)
	themed(b, role or "accent")
	themed(b, "text")
	b.MouseButton1Click:Connect(cb)
	return b
end

local function drag(handle, target)
	local dragging, start, startPos
	handle.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging, start, startPos = true, i.Position, target.Position
			i.Changed:Connect(function()
				if i.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	UIS.InputChanged:Connect(function(i)
		if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			local d = i.Position - start
			target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
		end
	end)
end

-- Переключатель
local function toggle(parent, text, y, cb)
	local row = frame(parent, UDim2.new(1, -10, 0, 34), UDim2.new(0, 5, 0, y), "panel")
	label(row, text, UDim2.new(1, -70, 1, 0), UDim2.new(0, 10, 0, 0))
	local state = false
	local b = Instance.new("TextButton")
	b.Size, b.Position = UDim2.new(0, 50, 0, 22), UDim2.new(1, -58, 0.5, -11)
	b.Text, b.BorderSizePixel, b.Font, b.TextSize = "OFF", 0, Enum.Font.GothamBold, 12
	b.BackgroundColor3 = Color3.fromRGB(120, 40, 40)
	b.TextColor3 = Color3.new(1, 1, 1)
	b.Parent = row
	corner(b, 11)
	b.MouseButton1Click:Connect(function()
		state = not state
		b.Text = state and "ON" or "OFF"
		b.BackgroundColor3 = state and Color3.fromRGB(40, 150, 60) or Color3.fromRGB(120, 40, 40)
		cb(state)
	end)
end

-- Поле ввода числа
local function numberBox(parent, text, y, default, cb)
	local row = frame(parent, UDim2.new(1, -10, 0, 34), UDim2.new(0, 5, 0, y), "panel")
	label(row, text, UDim2.new(1, -90, 1, 0), UDim2.new(0, 10, 0, 0))
	local tb = Instance.new("TextBox")
	tb.Size, tb.Position = UDim2.new(0, 70, 0, 24), UDim2.new(1, -78, 0.5, -12)
	tb.Text, tb.Font, tb.TextSize, tb.BorderSizePixel = tostring(default), Enum.Font.GothamBold, 13, 0
	tb.BackgroundColor3, tb.TextColor3 = Color3.fromRGB(30, 30, 30), Color3.new(1, 1, 1)
	tb.ClearTextOnFocus = false
	tb.Parent = row
	corner(tb, 6)
	tb.FocusLost:Connect(function()
		local n = tonumber(tb.Text)
		if n then cb(n) else tb.Text = tostring(default) end
	end)
end

------------------------------------------------------------
-- ПОИСК ЦЕЛЕЙ (Piggy)
-- Если в игре названия другие — добавь слова в эти списки
------------------------------------------------------------
local itemWords    = {"key","red key","redkey","key code","keycode","spanner","hammer","crowbar","wrench","bat","plank","lighter","medkit","battery","wire","bucket","code","paper","rope","gasoline","fuel","tool","screwdriver","scissors","lever","gear","coin","item","pickup"}
local monsterWords = {"piggy","pig","monster","enemy","bot","boss","zombie","killer"}

local function matches(name, list)
	name = name:lower()
	for _, w in ipairs(list) do
		if name:find(w, 1, true) then return true end
	end
	return false
end

local function isPlayerModel(m)
	for _, p in ipairs(Players:GetPlayers()) do
		if p.Character and (m == p.Character or m:IsDescendantOf(p.Character)) then return true end
	end
	return false
end

local function posOf(o)
	if o:IsA("Model") then
		local ok, cf = pcall(function() return o:GetPivot() end)
		return ok and cf.Position or nil
	elseif o:IsA("BasePart") then
		return o.Position
	elseif o:IsA("Tool") then
		local h = o:FindFirstChild("Handle")
		return h and h.Position
	end
end

-- возвращает список объектов нужного типа
local function getTargets(kind)
	local res = {}
	if kind == "players" then
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
				table.insert(res, p.Character)
			end
		end
		return res
	end
	for _, o in ipairs(workspace:GetDescendants()) do
		if (o:IsA("Model") or o:IsA("BasePart") or o:IsA("Tool")) and not isPlayerModel(o) then
			if kind == "monsters" then
				if o:IsA("Model") and o:FindFirstChildOfClass("Humanoid") and matches(o.Name, monsterWords) then
					table.insert(res, o)
				end
			elseif kind == "items" then
				if (o:IsA("Tool") or matches(o.Name, itemWords)) and posOf(o) then
					if not (o.Parent and o.Parent:IsA("Model") and matches(o.Parent.Name, itemWords)) then
						table.insert(res, o)
					end
				end
			end
		end
	end
	return res
end

------------------------------------------------------------
-- ESP
------------------------------------------------------------
local espColors = {
	players  = Color3.fromRGB(80, 160, 255),
	monsters = Color3.fromRGB(255, 50, 50),
	items    = Color3.fromRGB(60, 255, 120),
}
local espOn = {players = false, monsters = false, items = false}
local espObjs = {players = {}, monsters = {}, items = {}}

local function clearESP(kind)
	for o, data in pairs(espObjs[kind]) do
		pcall(function() data.hl:Destroy() end)
		pcall(function() data.bb:Destroy() end)
	end
	espObjs[kind] = {}
end

local function addESP(kind, o)
	local adornee = o:IsA("Tool") and o:FindFirstChild("Handle") or o
	if not adornee then return end
	local hl = Instance.new("Highlight")
	hl.FillColor, hl.OutlineColor = espColors[kind], espColors[kind]
	hl.FillTransparency = 0.6
	hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	hl.Adornee = o:IsA("Tool") and adornee or o
	hl.Parent = gui

	local bb = Instance.new("BillboardGui")
	bb.Size = UDim2.new(0, 120, 0, 20)
	bb.AlwaysOnTop = true
	bb.StudsOffset = Vector3.new(0, 3, 0)
	bb.Adornee = adornee:IsA("Model") and (adornee.PrimaryPart or adornee:FindFirstChildWhichIsA("BasePart", true)) or adornee
	bb.Parent = gui
	local t = Instance.new("TextLabel")
	t.Size, t.BackgroundTransparency = UDim2.new(1, 0, 1, 0), 1
	t.Text, t.TextColor3, t.TextStrokeTransparency = o.Name, espColors[kind], 0
	t.Font, t.TextSize = Enum.Font.GothamBold, 13
	t.Parent = bb
	espObjs[kind][o] = {hl = hl, bb = bb, label = t}
end

task.spawn(function()
	while gui.Parent do
		for kind, on in pairs(espOn) do
			if on then
				local targets = getTargets(kind)
				local alive = {}
				for _, o in ipairs(targets) do
					alive[o] = true
					if not espObjs[kind][o] then addESP(kind, o) end
				end
				for o, d in pairs(espObjs[kind]) do
					if not alive[o] or not o.Parent then
						pcall(function() d.hl:Destroy() end)
						pcall(function() d.bb:Destroy() end)
						espObjs[kind][o] = nil
					elseif lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
						local p = posOf(o)
						if p then
							local dist = math.floor((lp.Character.HumanoidRootPart.Position - p).Magnitude)
							d.label.Text = o.Name .. " [" .. dist .. "m]"
						end
					end
				end
			end
		end
		task.wait(1)
	end
end)

------------------------------------------------------------
-- ТЕЛЕПОРТ
------------------------------------------------------------
local function tpTo(o)
	local char = lp.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	local p = o and posOf(o)
	if hrp and p then
		hrp.CFrame = CFrame.new(p + Vector3.new(0, 4, 0))
	end
end

local function nearest(list)
	local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	local best, bd
	for _, o in ipairs(list) do
		local p = posOf(o)
		if p then
			local d = (p - hrp.Position).Magnitude
			if not bd or d < bd then best, bd = o, d end
		end
	end
	return best
end

------------------------------------------------------------
-- ГЛАВНОЕ МЕНЮ
------------------------------------------------------------
local main = Instance.new("Frame")
main.Size, main.Position = UDim2.new(0, 400, 0, 330), UDim2.new(0.5, -200, 0.5, -165)
main.BorderSizePixel, main.Visible = 0, false
main.Parent = gui
corner(main, 12)
themed(main, "bg")

local title = frame(main, UDim2.new(1, 0, 0, 36), UDim2.new(), "accent")
label(title, "  Piggy Menu", UDim2.new(1, -80, 1, 0), UDim2.new(), 16)
drag(title, main)

button(title, "-", UDim2.new(0, 30, 0, 24), UDim2.new(1, -66, 0, 6), function()
	main.Size = main.Size.Y.Offset > 40 and UDim2.new(0, 400, 0, 36) or UDim2.new(0, 400, 0, 330)
end, "panel")
button(title, "X", UDim2.new(0, 30, 0, 24), UDim2.new(1, -33, 0, 6), function()
	for k in pairs(espObjs) do clearESP(k) end
	gui:Destroy()
end, "panel")

local tabBar = frame(main, UDim2.new(1, -10, 0, 30), UDim2.new(0, 5, 0, 42), "panel")
local pages, tabButtons = {}, {}
local tabNames = {"Visual", "Teleport", "Player", "Setting"}

local function showTab(name)
	for n, p in pairs(pages) do p.Visible = (n == name) end
	for n, b in pairs(tabButtons) do b.BackgroundTransparency = (n == name) and 0 or 0.6 end
end

for i, name in ipairs(tabNames) do
	local page = Instance.new("ScrollingFrame")
	page.Size, page.Position = UDim2.new(1, -10, 1, -86), UDim2.new(0, 5, 0, 80)
	page.BackgroundTransparency, page.BorderSizePixel = 1, 0
	page.ScrollBarThickness = 4
	page.CanvasSize = UDim2.new(0, 0, 0, 0)
	page.AutomaticCanvasSize = Enum.AutomaticSize.Y
	page.Visible = false
	page.Parent = main
	pages[name] = page

	tabButtons[name] = button(tabBar, name, UDim2.new(0.25, -4, 1, -6), UDim2.new((i - 1) * 0.25, 2, 0, 3), function()
		showTab(name)
	end)
end

-- ===== 1) VISUAL =====
do
	local p = pages["Visual"]
	toggle(p, "ESP Игроки",   0,   function(s) espOn.players  = s; if not s then clearESP("players")  end end)
	toggle(p, "ESP Монстры",  40,  function(s) espOn.monsters = s; if not s then clearESP("monsters") end end)
	toggle(p, "ESP Предметы", 80,  function(s) espOn.items    = s; if not s then clearESP("items")    end end)
end

-- ===== 2) TELEPORT =====
do
	local p = pages["Teleport"]
	label(p, "К ближайшему:", UDim2.new(1, 0, 0, 20), UDim2.new(0, 8, 0, 0))
	button(p, "К предмету", UDim2.new(1, -10, 0, 32), UDim2.new(0, 5, 0, 24), function() tpTo(nearest(getTargets("items")))    end)
	button(p, "К монстру",  UDim2.new(0.5, -8, 0, 32), UDim2.new(0, 5, 0, 62),  function() tpTo(nearest(getTargets("monsters"))) end)
	button(p, "К игроку",   UDim2.new(0.5, -8, 0, 32), UDim2.new(0.5, 3, 0, 62), function() tpTo(nearest(getTargets("players")))  end)

	label(p, "Выбрать игрока:", UDim2.new(1, 0, 0, 20), UDim2.new(0, 8, 0, 104))
	local list = Instance.new("Frame")
	list.Size, list.Position = UDim2.new(1, -10, 0, 0), UDim2.new(0, 5, 0, 128)
	list.AutomaticSize = Enum.AutomaticSize.Y
	list.BackgroundTransparency = 1
	list.Parent = p
	local ll = Instance.new("UIListLayout"); ll.Padding = UDim.new(0, 4); ll.Parent = list

	local function refresh()
		for _, c in ipairs(list:GetChildren()) do
			if c:IsA("TextButton") then c:Destroy() end
		end
		for _, pl in ipairs(Players:GetPlayers()) do
			if pl ~= lp then
				button(list, pl.DisplayName .. " (@" .. pl.Name .. ")", UDim2.new(1, 0, 0, 28), nil, function()
					if pl.Character then tpTo(pl.Character) end
				end, "panel")
			end
		end
	end
	button(p, "Обновить", UDim2.new(0, 90, 0, 22), UDim2.new(1, -100, 0, 103), refresh, "panel")
	refresh()
	Players.PlayerAdded:Connect(refresh)
	Players.PlayerRemoving:Connect(function() task.wait(0.2); refresh() end)
end

-- ===== 3) PLAYER =====
do
	local p = pages["Player"]
	local speedOn, jumpOn = false, false
	local speedVal, jumpVal = 50, 100

	toggle(p, "SpeedHack", 0, function(s)
		speedOn = s
		if not s then
			local h = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
			if h then h.WalkSpeed = 16 end
		end
	end)
	numberBox(p, "Скорость", 40, speedVal, function(n) speedVal = math.clamp(n, 0, 300) end)

	toggle(p, "Jump Power", 80, function(s)
		jumpOn = s
		if not s then
			local h = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
			if h then h.UseJumpPower = true; h.JumpPower = 50 end
		end
	end)
	numberBox(p, "Сила прыжка", 120, jumpVal, function(n) jumpVal = math.clamp(n, 0, 500) end)

	RunService.Heartbeat:Connect(function()
		local h = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
		if not h then return end
		if speedOn then h.WalkSpeed = speedVal end
		if jumpOn then h.UseJumpPower = true; h.JumpPower = jumpVal end
	end)
end

-- ===== 4) SETTING =====
do
	local p = pages["Setting"]
	label(p, "Тема меню:", UDim2.new(1, 0, 0, 20), UDim2.new(0, 8, 0, 0))
	local order = {"Синий", "Красный", "Белый", "Чёрный", "Зелёный"}
	for i, n in ipairs(order) do
		local col = (i - 1) % 2
		local row = math.floor((i - 1) / 2)
		button(p, n, UDim2.new(0.5, -8, 0, 30), UDim2.new(col * 0.5, col == 0 and 5 or 3, 0, 24 + row * 36), function()
			theme = themes[n]
			applyTheme()
		end)
	end

	label(p, "Прозрачность меню:", UDim2.new(1, 0, 0, 20), UDim2.new(0, 8, 0, 142))
	local bar = frame(p, UDim2.new(1, -20, 0, 14), UDim2.new(0, 10, 0, 168), "panel")
	local fill = frame(bar, UDim2.new(0, 0, 1, 0), nil, "accent")
	local knob = Instance.new("Frame")
	knob.Size, knob.BackgroundColor3, knob.BorderSizePixel = UDim2.new(0, 18, 0, 18), Color3.new(1, 1, 1), 0
	knob.Position = UDim2.new(0, -9, 0.5, -9)
	knob.Parent = bar
	corner(knob, 9)

	local pct = label(p, "0%", UDim2.new(1, 0, 0, 20), UDim2.new(0, 10, 0, 190))

	local sliding = false
	local function setFromX(x)
		local rel = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
		fill.Size = UDim2.new(rel, 0, 1, 0)
		knob.Position = UDim2.new(rel, -9, 0.5, -9)
		menuTransparency = rel * 0.8 -- максимум 80%, чтобы меню не пропало
		pct.Text = math.floor(rel * 100) .. "%"
		applyTheme()
	end
	bar.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			sliding = true; setFromX(i.Position.X)
		end
	end)
	UIS.InputChanged:Connect(function(i)
		if sliding and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			setFromX(i.Position.X)
		end
	end)
	UIS.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			sliding = false
		end
	end)
end

showTab("Visual")
applyTheme()

------------------------------------------------------------
-- КЛЮЧ
------------------------------------------------------------
local keyFrame = Instance.new("Frame")
keyFrame.Size, keyFrame.Position = UDim2.new(0, 320, 0, 170), UDim2.new(0.5, -160, 0.5, -85)
keyFrame.BorderSizePixel = 0
keyFrame.Parent = gui
corner(keyFrame, 12)
themed(keyFrame, "bg")

local kt = label(keyFrame, "Введите ключ", UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 0, 10), 18)
kt.TextXAlignment = Enum.TextXAlignment.Center

local box = Instance.new("TextBox")
box.Size, box.Position = UDim2.new(1, -40, 0, 34), UDim2.new(0, 20, 0, 50)
box.PlaceholderText, box.Text = "Ключ...", ""
box.Font, box.TextSize, box.BorderSizePixel = Enum.Font.GothamBold, 14, 0
box.BackgroundColor3, box.TextColor3 = Color3.fromRGB(35, 35, 35), Color3.new(1, 1, 1)
box.ClearTextOnFocus = false
box.Parent = keyFrame
corner(box, 8)

local status = label(keyFrame, "", UDim2.new(1, 0, 0, 18), UDim2.new(0, 0, 0, 90), 13)
status.TextXAlignment = Enum.TextXAlignment.Center

local function check()
	if box.Text == KEY then
		status.Text = "Ключ верный!"
		status.TextColor3 = Color3.fromRGB(60, 220, 90)
		task.wait(0.5)
		keyFrame:Destroy()
		main.Visible = true
	else
		status.Text = "Неверный ключ"
		status.TextColor3 = Color3.fromRGB(240, 60, 60)
	end
end
button(keyFrame, "Войти", UDim2.new(1, -40, 0, 34), UDim2.new(0, 20, 0, 118), check)
box.FocusLost:Connect(function(enter) if enter then check() end end)
drag(keyFrame, keyFrame)
