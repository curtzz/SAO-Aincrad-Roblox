-- DialogueUI.client.lua
-- LocalScript: shows NPC dialogue panel with typewriter effect and choices

local Players           = game:GetService("Players")
local UserInputService  = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

local DialogueRegistry = require(ReplicatedStorage.Modules.DialogueRegistry)

-- ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name          = "DialogueUI"
screenGui.ResetOnSpawn  = false
screenGui.Enabled       = false
screenGui.Parent        = player.PlayerGui

-- Bottom panel (full width, height 200)
local panel = Instance.new("Frame")
panel.Name              = "DialoguePanel"
panel.AnchorPoint       = Vector2.new(0, 1)
panel.Position          = UDim2.new(0, 0, 1, 0)
panel.Size              = UDim2.new(1, 0, 0, 200)
panel.BackgroundColor3  = Color3.new(1, 1, 1)
panel.BackgroundTransparency = 0.1
panel.BorderSizePixel   = 0
panel.Parent            = screenGui

-- Portrait area (160×160)
local portraitBox = Instance.new("Frame")
portraitBox.Name             = "PortraitBox"
portraitBox.Size             = UDim2.new(0, 160, 0, 160)
portraitBox.Position         = UDim2.new(0, 10, 0.5, -80)
portraitBox.BackgroundColor3 = Color3.fromRGB(180, 180, 200)
portraitBox.BorderSizePixel  = 0
portraitBox.Parent           = panel

local portraitImg = Instance.new("ImageLabel")
portraitImg.Size             = UDim2.new(1, 0, 1, 0)
portraitImg.BackgroundTransparency = 1
portraitImg.Image            = "rbxassetid://0"
portraitImg.Parent           = portraitBox

local npcNameLbl = Instance.new("TextLabel")
npcNameLbl.Size              = UDim2.new(0, 160, 0, 24)
npcNameLbl.Position          = UDim2.new(0, 10, 0, 170)
npcNameLbl.BackgroundTransparency = 1
npcNameLbl.Text              = ""
npcNameLbl.Font              = Enum.Font.GothamBold
npcNameLbl.TextSize          = 16
npcNameLbl.TextColor3        = Color3.fromRGB(30, 30, 30)
npcNameLbl.TextXAlignment    = Enum.TextXAlignment.Center
npcNameLbl.Parent            = panel

-- Dialogue text area
local textArea = Instance.new("TextLabel")
textArea.Name              = "DialogueText"
textArea.Position          = UDim2.new(0, 180, 0, 20)
textArea.Size              = UDim2.new(1, -240, 1, -40)
textArea.BackgroundTransparency = 1
textArea.Text              = ""
textArea.Font              = Enum.Font.Gotham
textArea.TextSize          = 17
textArea.TextColor3        = Color3.fromRGB(30, 30, 30)
textArea.TextWrapped       = true
textArea.TextXAlignment    = Enum.TextXAlignment.Left
textArea.TextYAlignment    = Enum.TextYAlignment.Top
textArea.Parent            = panel

-- Advance button
local advanceBtn = Instance.new("TextButton")
advanceBtn.Name            = "AdvanceBtn"
advanceBtn.Size            = UDim2.new(0, 40, 0, 30)
advanceBtn.Position        = UDim2.new(1, -48, 1, -38)
advanceBtn.BackgroundTransparency = 1
advanceBtn.Text            = "▶"
advanceBtn.TextSize        = 20
advanceBtn.TextColor3      = Color3.fromRGB(30, 30, 30)
advanceBtn.Font            = Enum.Font.GothamBold
advanceBtn.Visible         = false
advanceBtn.Parent          = panel

-- Choice container
local choiceContainer = Instance.new("Frame")
choiceContainer.Name            = "ChoiceContainer"
choiceContainer.Position        = UDim2.new(0, 180, 0, 20)
choiceContainer.Size            = UDim2.new(1, -240, 1, -40)
choiceContainer.BackgroundTransparency = 1
choiceContainer.Visible         = false
choiceContainer.Parent          = panel

local choiceLayout = Instance.new("UIListLayout")
choiceLayout.SortOrder = Enum.SortOrder.LayoutOrder
choiceLayout.Padding   = UDim.new(0, 6)
choiceLayout.Parent    = choiceContainer

-- State
local currentNpcId     = nil
local currentLines     = nil
local currentLineIndex = 1
local isTyping         = false
local fullText         = ""
local advanceDialogueRemote

local function clearChoices()
	for _, child in ipairs(choiceContainer:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end
end

local function closeDialogue()
	screenGui.Enabled = false
	clearChoices()
	advanceBtn.Visible = false
	choiceContainer.Visible = false
	textArea.Text = ""
	currentNpcId  = nil
	currentLines  = nil
	isTyping      = false
end

local function typeText(text, callback)
	isTyping   = true
	textArea.Text = ""
	advanceBtn.Visible = false
	for i = 1, #text do
		if not isTyping then break end
		textArea.Text = text:sub(1, i)
		task.wait(0.03)
	end
	textArea.Text = text
	isTyping = false
	if callback then callback() end
end

local function parseChoiceText(line)
	-- "[CHOICE: Option A / Option B]"
	local inner = line:match("%[CHOICE: (.+)%]")
	if not inner then return nil end
	local choices = {}
	for opt in inner:gmatch("([^/]+)") do
		local trimmed = opt:match("^%s*(.-)%s*$")
		if trimmed ~= "" then
			table.insert(choices, trimmed)
		end
	end
	return choices
end

local function showChoices(choiceKeys, entry)
	clearChoices()
	textArea.Text = ""
	advanceBtn.Visible = false
	choiceContainer.Visible = true

	for i, choiceKey in ipairs(choiceKeys) do
		local btn = Instance.new("TextButton")
		btn.Size             = UDim2.new(1, 0, 0, 40)
		btn.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
		btn.BorderSizePixel  = 0
		btn.Text             = choiceKey
		btn.Font             = Enum.Font.Gotham
		btn.TextSize         = 14
		btn.TextColor3       = Color3.new(1, 1, 1)
		btn.LayoutOrder      = i
		btn.Parent           = choiceContainer

		local capturedKey = choiceKey
		btn.MouseButton1Click:Connect(function()
			choiceContainer.Visible = false
			clearChoices()

			-- Fire to server
			if advanceDialogueRemote then
				advanceDialogueRemote:FireServer(currentNpcId, capturedKey)
			end

			-- Show reply
			local reply = ""
			if entry.Choices and entry.Choices[capturedKey] then
				reply = entry.Choices[capturedKey].Reply or ""
			end
			typeText(reply, function()
				advanceBtn.Visible = true
				-- After advancing from reply, close
				advanceBtn.MouseButton1Click:Wait()
				closeDialogue()
			end)
		end)
	end
end

local function showLine(lineIndex)
	if not currentLines then return end
	if lineIndex > #currentLines then
		closeDialogue()
		return
	end

	local line = currentLines[lineIndex]
	local choiceOptions = parseChoiceText(line)

	if choiceOptions then
		local entry = DialogueRegistry[currentNpcId]
		showChoices(choiceOptions, entry)
	else
		advanceBtn.Visible = false
		typeText(line, function()
			advanceBtn.Visible = true
		end)
	end
end

local function advanceLine()
	if isTyping then
		-- Skip typewriter: show full text immediately
		isTyping = false
		textArea.Text = fullText
		advanceBtn.Visible = true
		return
	end
	currentLineIndex = currentLineIndex + 1
	showLine(currentLineIndex)
end

advanceBtn.MouseButton1Click:Connect(advanceLine)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if not screenGui.Enabled then return end
	if input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.Return then
		advanceLine()
	end
end)

task.spawn(function()
	local remotes = ReplicatedStorage:WaitForChild("Remotes", 30)
	if not remotes then return end

	local openDialogueRemote = remotes:WaitForChild("OpenDialogue",    30)
	advanceDialogueRemote     = remotes:WaitForChild("AdvanceDialogue", 30)

	openDialogueRemote.OnClientEvent:Connect(function(data)
		local npcId        = data.npcId
		local flagAlreadySet = data.flagAlreadySet or false

		local entry = DialogueRegistry[npcId]
		if not entry then return end

		currentNpcId    = npcId
		currentLines    = entry.Lines
		currentLineIndex = 1

		-- Set portrait and name
		portraitImg.Image = entry.Portrait or "rbxassetid://0"
		npcNameLbl.Text   = entry.Name or npcId

		-- If flag already set, jump to last line
		if flagAlreadySet and #currentLines > 1 then
			currentLineIndex = #currentLines
		end

		clearChoices()
		choiceContainer.Visible = false
		screenGui.Enabled = true
		showLine(currentLineIndex)
	end)
end)
