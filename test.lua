-- ============================================================
--  ZAEL APS  |  LocalScript
--  Place inside  StarterPlayerScripts
--  Game : Steal a Brainrot
-- ============================================================

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ─── CONFIG ─────────────────────────────────────────────────
local RAINBOW_SPEED = 0.18
local BORDER        = 7          -- rainbow border thickness in px

local COMMANDS = {
	"gamepass morph",
	"tiny",
	"jumpscare",
	"inverse",
	"night vision",
	"rocket",
}
local JAIL_DELAY = 3             -- seconds before jail fires

-- ─── DEVICE DETECT ──────────────────────────────────────────
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- Card outer size in pixels
-- Mobile card height is calculated exactly:
--   PAD_V*2 + TITLE + STATUS + INPUT + BTN + GAP*3 + BORDER*2 = 232
local CARD_W_PX   = isMobile and 260  or 300
local CARD_H_PX   = isMobile and 248  or 340

-- Heights of each element inside the card (pixels)
local PAD_V       = isMobile and 14   or 28    -- top + bottom padding each
local PAD_H       = isMobile and 18   or 24    -- left + right padding each
local TITLE_H     = isMobile and 48   or 72
local STATUS_H    = isMobile and 18   or 24
local INPUT_H     = isMobile and 46   or 58
local BTN_H       = isMobile and 48   or 60
local GAP         = isMobile and 10   or 14    -- vertical gap between items

-- ─── HELPERS ────────────────────────────────────────────────
local function hsvToRgb(h, s, v)
	h = h % 1
	local i  = math.floor(h * 6)
	local f  = h * 6 - i
	local p  = v * (1 - s)
	local q  = v * (1 - f * s)
	local t  = v * (1 - (1 - f) * s)
	i = i % 6
	if     i == 0 then return Color3.new(v, t, p)
	elseif i == 1 then return Color3.new(q, v, p)
	elseif i == 2 then return Color3.new(p, v, t)
	elseif i == 3 then return Color3.new(p, q, v)
	elseif i == 4 then return Color3.new(t, p, v)
	else               return Color3.new(v, p, q)
	end
end

-- ─── ADMIN CHECK ────────────────────────────────────────────
local function checkAdmin()
	local rep = game:GetService("ReplicatedStorage")

	if player:GetAttribute("IsAdmin") == true then return true end
	if player:GetAttribute("Admin")   == true then return true end

	local av = player:FindFirstChild("Admin", true)
	if av then
		if av:IsA("BoolValue")   and av.Value == true  then return true end
		if av:IsA("StringValue") and av.Value ~= ""    then return true end
	end

	local folder = rep:FindFirstChild("Admins", true)
	if folder and folder:FindFirstChild(player.Name) then return true end

	local mod = rep:FindFirstChild("AdminList", true)
	if mod and mod:IsA("ModuleScript") then
		local ok, list = pcall(require, mod)
		if ok and type(list) == "table" then
			for _, name in ipairs(list) do
				if tostring(name):lower() == player.Name:lower() then return true end
			end
		end
	end

	if _G["Admins"] and type(_G["Admins"]) == "table" then
		for _, v in ipairs(_G["Admins"]) do
			if tostring(v):lower() == player.Name:lower() then return true end
		end
	end

	return false
end

-- ─── SEND COMMAND ───────────────────────────────────────────
local function sendCommand(cmd)
	local chatGui = player.PlayerGui:WaitForChild("Chat", 8)
	if not chatGui then
		warn("[ZaelAPS] Chat GUI not found.")
		return false
	end

	local textBox = nil
	for _, d in ipairs(chatGui:GetDescendants()) do
		if d:IsA("TextBox") then textBox = d; break end
	end
	if not textBox then
		warn("[ZaelAPS] No TextBox in Chat GUI.")
		return false
	end

	textBox.Text = "/" .. cmd
	textBox:CaptureFocus()
	task.wait(0.06)

	UserInputService.InputBegan:Fire({
		KeyCode       = Enum.KeyCode.Return,
		UserInputType = Enum.UserInputType.Keyboard,
	}, false)

	task.wait(0.08)
	textBox.Text = ""
	textBox:ReleaseFocus()
	return true
end

-- ─── BUILD GUI ──────────────────────────────────────────────

-- ScreenGui
local sg = Instance.new("ScreenGui")
sg.Name         = "ZaelAPS_GUI"
sg.ResetOnSpawn = false
sg.Parent       = playerGui

-- ── Outer (rainbow border) ──────────────────────────────────
local Outer = Instance.new("Frame")
Outer.Name            = "Outer"
Outer.Size            = UDim2.new(0, CARD_W_PX, 0, CARD_H_PX)
Outer.Position        = UDim2.new(0.5, 0, 0.5, 0)
Outer.AnchorPoint     = Vector2.new(0.5, 0.5)
Outer.BackgroundColor3 = Color3.new(1, 0.5, 0)
Outer.BorderSizePixel = 0
Outer.ClipsDescendants = true
Outer.Parent          = sg

Instance.new("UICorner", Outer).CornerRadius = UDim.new(0, 20)

-- ── Inner (black card) ──────────────────────────────────────
local Inner = Instance.new("Frame")
Inner.Name            = "Inner"
Inner.Size            = UDim2.new(1, -BORDER * 2,  1, -BORDER * 2)
Inner.Position        = UDim2.new(0,  BORDER,      0,  BORDER)
Inner.BackgroundColor3 = Color3.new(0.07, 0.07, 0.07)
Inner.BorderSizePixel = 0
Inner.ClipsDescendants = true
Inner.Parent          = Outer

Instance.new("UICorner", Inner).CornerRadius = UDim.new(0, 14)

-- ── List layout ─────────────────────────────────────────────
local list = Instance.new("UIListLayout")
list.Padding           = UDim.new(0, GAP)
list.SortOrder         = Enum.SortOrder.LayoutOrder
list.FillDirection     = Enum.FillDirection.Vertical
list.HorizontalAlignment = Enum.HorizontalAlignment.Center
list.Parent            = Inner

-- Padding inside the black card
local cp = Instance.new("UIPadding")
cp.PaddingTop    = UDim.new(0, PAD_V)
cp.PaddingBottom = UDim.new(0, PAD_V)
cp.PaddingLeft   = UDim.new(0, PAD_H)
cp.PaddingRight  = UDim.new(0, PAD_H)
cp.Parent        = Inner

-- ── Close button (X) – on Outer, flush top-right inside border
local CloseBtn = Instance.new("TextButton")
CloseBtn.Name             = "CloseBtn"
CloseBtn.Size             = UDim2.new(0, 24, 0, 24)
CloseBtn.Position         = UDim2.new(1, -BORDER - 4, 0, BORDER + 2)  -- 4px inset from rainbow right, 2px below rainbow top
CloseBtn.AnchorPoint      = Vector2.new(1, 0)
CloseBtn.BackgroundColor3 = Color3.new(0.75, 0.2, 0.2)
CloseBtn.BorderSizePixel  = 0
CloseBtn.Text             = "X"
CloseBtn.TextColor3       = Color3.new(1, 1, 1)
CloseBtn.TextScaled       = true
CloseBtn.Font             = Enum.Font.GothamBold
CloseBtn.ZIndex           = 10
CloseBtn.Parent           = Outer   -- Outer, NOT Inner – avoids ClipsDescendants

Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0.25, 0)

CloseBtn.MouseEnter:Connect(function()
	CloseBtn.BackgroundColor3 = Color3.new(0.9, 0.3, 0.3)
end)
CloseBtn.MouseLeave:Connect(function()
	CloseBtn.BackgroundColor3 = Color3.new(0.75, 0.2, 0.2)
end)

-- ── TITLE (order 1) ─────────────────────────────────────────
local Title = Instance.new("TextLabel")
Title.Name                   = "Title"
Title.Size                   = UDim2.new(1, 0, 0, TITLE_H)
Title.BackgroundTransparency = 1
Title.Text                   = "ZAEL APS"
Title.TextColor3             = Color3.new(1, 1, 1)
Title.TextScaled             = true
Title.Font                   = Enum.Font.GothamBold
Title.TextXAlignment         = Enum.TextXAlignment.Center
Title.TextYAlignment         = Enum.TextYAlignment.Center
Title.LayoutOrder            = 1
Title.Parent                 = Inner

do
	local c = Instance.new("UITextSizeConstraint")
	c.MinTextSize = 24
	c.MaxTextSize = 48
	c.Parent      = Title
end

-- ── STATUS (order 2) ────────────────────────────────────────
local Status = Instance.new("TextLabel")
Status.Name                   = "Status"
Status.Size                   = UDim2.new(1, 0, 0, STATUS_H)
Status.BackgroundTransparency = 1
Status.Text                   = ""
Status.TextColor3             = Color3.new(1, 1, 1)
Status.TextScaled             = true
Status.Font                   = Enum.Font.Gotham
Status.TextXAlignment         = Enum.TextXAlignment.Center
Status.TextYAlignment         = Enum.TextYAlignment.Center
Status.LayoutOrder            = 2
Status.Parent                 = Inner

do
	local c = Instance.new("UITextSizeConstraint")
	c.MinTextSize = 10
	c.MaxTextSize = 18
	c.Parent      = Status
end

-- ── INPUT (order 3) ─────────────────────────────────────────
local InputOuter = Instance.new("Frame")
InputOuter.Name            = "InputOuter"
InputOuter.Size            = UDim2.new(1, 0, 0, INPUT_H)
InputOuter.BackgroundColor3 = Color3.new(1, 0.5, 0)
InputOuter.BorderSizePixel = 0
InputOuter.LayoutOrder     = 3
InputOuter.Parent          = Inner

Instance.new("UICorner", InputOuter).CornerRadius = UDim.new(0, 10)

local InputInner = Instance.new("Frame")
InputInner.Name            = "InputInner"
InputInner.Size            = UDim2.new(1, -6, 1, -6)
InputInner.Position        = UDim2.new(0, 3, 0, 3)
InputInner.BackgroundColor3 = Color3.new(0.07, 0.07, 0.07)
InputInner.BorderSizePixel = 0
InputInner.Parent          = InputOuter

Instance.new("UICorner", InputInner).CornerRadius = UDim.new(0, 7)

local TextBox = Instance.new("TextBox")
TextBox.Name                  = "TextBox"
TextBox.Size                  = UDim2.new(1, 0, 1, 0)
TextBox.BackgroundTransparency = 1
TextBox.Text                  = ""
TextBox.PlaceholderText       = "type user here"
TextBox.TextColor3            = Color3.new(1, 1, 1)
TextBox.PlaceholderColor3     = Color3.new(0.6, 0.6, 0.6)
TextBox.TextScaled            = true
TextBox.Font                  = Enum.Font.GothamBold
TextBox.TextXAlignment        = Enum.TextXAlignment.Center
TextBox.TextYAlignment        = Enum.TextYAlignment.Center
TextBox.ClearTextOnFocus      = false
TextBox.Parent                = InputInner

do
	local c = Instance.new("UITextSizeConstraint")
	c.MinTextSize = 12
	c.MaxTextSize = 22
	c.Parent      = TextBox
end
do
	local p = Instance.new("UIPadding")
	p.PaddingLeft  = UDim.new(0, 10)
	p.PaddingRight = UDim.new(0, 10)
	p.Parent       = TextBox
end

-- ── ACTIVATE BUTTON (order 4) ───────────────────────────────
local ActBtn = Instance.new("TextButton")
ActBtn.Name             = "ActBtn"
ActBtn.Size             = UDim2.new(1, 0, 0, BTN_H)
ActBtn.BackgroundColor3 = Color3.new(0.18, 0.80, 0.31)
ActBtn.BorderSizePixel  = 0
ActBtn.Text             = "Activate"
ActBtn.TextColor3       = Color3.new(1, 1, 1)
ActBtn.TextScaled       = true
ActBtn.Font             = Enum.Font.GothamBold
ActBtn.TextXAlignment   = Enum.TextXAlignment.Center
ActBtn.TextYAlignment   = Enum.TextYAlignment.Center
ActBtn.LayoutOrder      = 4
ActBtn.Parent           = Inner

Instance.new("UICorner", ActBtn).CornerRadius = UDim.new(0, 14)

do
	local c = Instance.new("UITextSizeConstraint")
	c.MinTextSize = 18
	c.MaxTextSize = 30
	c.Parent      = ActBtn
end

-- ─── RAINBOW LOOP ───────────────────────────────────────────
local rainbowTargets = { Outer, InputOuter }
local hue            = 0
local rainbowConn    = nil

local function startRainbow()
	if rainbowConn then return end
	rainbowConn = RunService.Heartbeat:Connect(function(dt)
		hue = (hue + dt * RAINBOW_SPEED) % 1
		local c = hsvToRgb(hue, 1, 1)
		for _, f in ipairs(rainbowTargets) do
			f.BackgroundColor3 = c
		end
	end)
end

local function stopRainbow()
	if rainbowConn then rainbowConn:Disconnect(); rainbowConn = nil end
end

-- ─── DRAG (hold-to-drag, mouse + touch) ────────────────────
-- Convert Outer from centre-anchor to top-left anchor once so
-- that pixel-position dragging works correctly.
do
	local vp       = workspace.CurrentCamera.ViewportSize
	local absPos   = Outer.AbsolutePosition                          -- top-left corner in screen px
	Outer.AnchorPoint = Vector2.new(0, 0)
	Outer.Position    = UDim2.new(0, absPos.X, 0, absPos.Y)
end

local dragActive   = false
local dragOffset   = Vector2.new(0, 0)   -- cursor pos minus frame top-left at grab time
local dragConn     = nil                 -- the per-frame mover

local function dragStart(inputObj)
	-- don't start drag if the tap is on the close button or the textbox
	if inputObj.UserInputType == Enum.UserInputType.MouseButton1
	   or inputObj.UserInputType == Enum.UserInputType.Touch then

		local cursor = UserInputService:GetMouseLocation()
		dragOffset   = cursor - Outer.AbsolutePosition
		dragActive   = true

		-- every frame while held: move frame to cursor - offset
		dragConn = RunService.Heartbeat:Connect(function()
			if not dragActive then return end
			local cur = UserInputService:GetMouseLocation()
			Outer.Position = UDim2.new(0, cur.X - dragOffset.X,
			                           0, cur.Y - dragOffset.Y)
		end)
	end
end

local function dragEnd()
	dragActive = false
	if dragConn then dragConn:Disconnect(); dragConn = nil end
end

-- Mouse / touch down on the Outer frame starts drag
Outer.InputBegan:Connect(function(inputObj, gameProcessed)
	dragStart(inputObj)
end)

-- Release anywhere on screen ends drag
UserInputService.InputEnded:Connect(function(inputObj)
	if inputObj.UserInputType == Enum.UserInputType.MouseButton1
	   or inputObj.UserInputType == Enum.UserInputType.Touch then
		dragEnd()
	end
end)

-- ─── CLOSE ──────────────────────────────────────────────────
CloseBtn.Activated:Connect(function()
	stopRainbow()
	sg:Destroy()
end)

-- ─── ACTIVATE LOGIC ─────────────────────────────────────────
local GREEN = Color3.new(0.18, 0.80, 0.31)
local RED   = Color3.new(0.78, 0.20, 0.20)
local GRAY  = Color3.new(0.40, 0.40, 0.40)
local WHITE = Color3.new(1,    1,    1)

local busy = false

ActBtn.Activated:Connect(function()
	if busy then return end

	local username = TextBox.Text:match("^%s*(.-)%s*$")
	if username == "" then
		ActBtn.BackgroundColor3 = RED
		Status.Text       = "Enter a username!"
		Status.TextColor3 = Color3.new(1, 0.45, 0.45)
		task.wait(0.5)
		ActBtn.BackgroundColor3 = GREEN
		task.wait(1.2)
		Status.Text = ""
		return
	end

	-- admin gate
	if not checkAdmin() then
		ActBtn.BackgroundColor3 = RED
		Status.Text       = "You don't have admin!"
		Status.TextColor3 = Color3.new(1, 0.4, 0.4)
		task.wait(0.5)
		ActBtn.BackgroundColor3 = GREEN
		task.wait(2.2)
		Status.Text = ""
		return
	end

	-- lock
	busy = true
	ActBtn.BackgroundColor3 = GRAY
	ActBtn.Text = "Running..."

	-- fire each command in order
	for _, cmd in ipairs(COMMANDS) do
		local full = cmd .. " " .. username
		Status.Text       = "-> /" .. full
		Status.TextColor3 = Color3.new(0.5, 1, 0.5)
		sendCommand(full)
		task.wait(0.65)
	end

	-- 3 second countdown
	for t = JAIL_DELAY, 1, -1 do
		Status.Text       = "Jailing in " .. t .. "s..."
		Status.TextColor3 = Color3.new(1, 1, 0.35)
		task.wait(1)
	end

	-- jail
	local jailFull = "jail " .. username
	Status.Text       = "-> /" .. jailFull
	Status.TextColor3 = Color3.new(0.5, 1, 0.5)
	sendCommand(jailFull)

	task.wait(0.8)

	-- done
	Status.Text       = "Done! " .. username .. " jailed."
	Status.TextColor3 = Color3.new(0.4, 1, 0.5)
	ActBtn.BackgroundColor3 = WHITE
	task.wait(0.18)
	ActBtn.BackgroundColor3 = GREEN
	ActBtn.Text = "Activate"
	busy = false

	task.wait(3)
	Status.Text = ""
end)

-- ─── GO ─────────────────────────────────────────────────────
startRainbow()
print("[ZaelAPS] Ready.")
