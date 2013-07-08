local Menu = {}
local MenuItem = {}

------------------------------
-- Menu Items --
------------------------------

function MenuItem:new(text, pos, height, width)
	local o = {}
	o.text = text
	o.pos = pos
	o.buttonHeight = height
	o.buttonWidth = width
	o.selected = false
	o.selectable = false
	o.disabled = false
	o.maxTextLength = 10
	self.__index = self
	setmetatable(o, self)
	return o
end

function MenuItem:setText(text)
	if string.len(text)> self.maxTextLength then
		text = string.sub(text,1,self.maxTextLength)
	end
	self.text = text
end

function MenuItem:getText()
	return self.text
end

function MenuItem:isSelected()
	return self.selected
end

function MenuItem:setDisabled(value)
	self.disabled = value
end

function MenuItem:setSelected(value)
	self.selected = value
end

function MenuItem:setSelectable(value)
	self.selectable = value
end

function MenuItem:isSelectable()
	return self.selectable
end

function MenuItem:isInside(mx, my)
	return mx >= self.pos.x and mx <= (self.pos.x + self.buttonWidth) and my >= self.pos.y and my <= (self.pos.y + self.buttonHeight)
end

function MenuItem:draw()

	love.graphics.setFont(bigfont)

	local text = {255,255,255}
	local background = {0,0,0}

	local textDisabled = {150,150,150}
	local backgroundDisabled = {200,200,200}

	local textSelected = {0,0,0}
	local backgroundSelected = {200,200,200}

	local textSelectedDisabled = {99,99,99}
	local backgroundSelectedDisabled = {200,200,200}

	if self.selected and self.disabled then
		text = textSelectedDisabled
		background = backgroundSelectedDisabled
	elseif self.disabled then
		text = textDisabled
		background = backgroundDisabled
	elseif self.selected then
		text = textSelected
		background = backgroundSelected
	end

	love.graphics.setColor(background)
	love.graphics.rectangle("fill", self.pos.x, self.pos.y, self.buttonWidth, self.buttonHeight)
	love.graphics.setColor(text)
	if self.selected then
		love.graphics.setLine(3, "rough")
		love.graphics.rectangle("line", self.pos.x+2, self.pos.y+2, self.buttonWidth-2, self.buttonHeight-2)
		love.graphics.setLine(1, "rough")
	end
	love.graphics.print(self.text, self.pos.x+10, self.pos.y+10)
	self:drawDerived()
end

function MenuItem:drawDerived()
--dummy function to be overriden by derived object.
end

function MenuItem:keypressed(key)
--dummy function to be overriden by derived object.
end

function MenuItem:mousepressed(x, y, b)
--dummy function to be overriden by derived object.
end

-------------------------------
-- Menu Items -> Button		 --
-------------------------------
MenuItemButton = inheritsFrom( MenuItem )
function MenuItemButton:mousepressed(x, y, b)
	self:target()
end

function MenuItemButton:keypressed(key)
	if key == "return" or key == "kpenter" then
		self:target()
	end
end

function MenuItemButton:isSelectable()
	if not self.disabled then
		return true
	else
		return false
	end
end

function MenuItemButton:setSelected(value)
	if value and self.target then
		forwardFunc = self.target
	end
	self.selected = value
end

-------------------------------
-- Menu Items -> StringInput --
-------------------------------
MenuItemStringInput = inheritsFrom( MenuItem )

function MenuItemStringInput:mousepressed(x, y, b)
--disable
end

function MenuItemStringInput:keypressed(key)

	if key == "backspace" then
		local str = self:getText()
		self:setText(string.sub(str, 1, string.len(str) - 1))
	elseif key:match("[A-Za-z0-9 ]") and not self:keyDisabled(key) and string.len(self:getText()) < self.maxTextLength then
		local str = self:getText()
		local newKey = key
		if love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift") then newKey = string.upper(key) end
		str = str .. newKey
		self:setText(str)
	elseif key == "kpenter" or key == "return" then
		self:callback()
	end
end

function MenuItemStringInput:setCallback(callback)
	self.callback = callback
end

function MenuItemStringInput:isSelectable()
	return true
end

function MenuItemStringInput:keyDisabled(key)
	local keyDisable = { -- taken from https://love2d.org/forums/viewtopic.php?f=4&t=8765
		"up","down","left","right","home","end","pageup","pagedown",
		"insert","tab","clear","delete",
		"f1","f2","f3","f4","f5","f6","f7","f8","f9","f10","f11","f12","f13","f14","f15",
		"kpenter", "return",
		"numlock","scrollock","ralt","lalt","rmeta","lmeta","lsuper","rsuper","mode","compose", "lshift", "rshift", "lctrl", "rctrl", "capslock",      --Modifier keys
		"pause","escape","help","print","sysreq","break","menu","power","euro","undo"
	}

	return table.contains(keyDisable, key)
end
------------------------------
-- Menu --
------------------------------
function Menu:new(x, y, width, height)
	o = {}
	setmetatable(o, self)
	self.__index = self
	o.items = {}
	o.x = x
	o.y = y
	o.mousePos = {x = 0, y = 0}
	o.width = width
	o.height = height
	return o
end


function Menu:update(dt)
	local mx, my = love.mouse.getPosition()
	if self.mousePos.x ~= mx or self.mousePos.y ~= my then
		for i, menuItem in ipairs(self.items) do
			if menuItem:isInside(mx-self.x, my-self.y) and menuItem:isSelectable() then
				self:unselectAll()
				menuItem:setSelected(true)
			end
		end
		self.mousePos.x = mx
		self.mousePos.y = my
	end
end

function Menu:unselectAll()
	for i, menuItem in ipairs(self.items) do
		menuItem:setSelected(false)
	end
end

function Menu:mousepressed(mx, my, b)
	for i, menuItem in ipairs(self.items) do
		if menuItem:isInside(mx-self.x, my-self.y) then menuItem:mousepressed(mx-self.x, my-self.y, b) end
	end
end

function Menu:keypressed(key)
	if key == "escape" and backFunc then
		backFunc()
		return
	end

	if key == "up" then
		local prevItem = nil
		for i, menuItem in ipairs(self.items) do
			if menuItem:isSelected() and prevItem then
				self:unselectAll()
				prevItem:setSelected(true)
				break
			end
			if menuItem:isSelectable() then
				prevItem = menuItem
			end
		end
	end

	if key == "down" then
		local selectNext = false
		for i, menuItem in ipairs(self.items) do
			if menuItem:isSelected() then
				selectNext = true
			elseif selectNext and menuItem:isSelectable() then
				self:unselectAll()
				menuItem:setSelected(true)
				break
			end
		end
	end

	for i, menuItem in ipairs(self.items) do
		if menuItem:isSelected() then menuItem:keypressed(key) end
	end
end

function Menu:draw()

	love.graphics.setColor(48, 156, 225)
	love.graphics.push()
	love.graphics.translate(self.x, self.y)

	-- Menu items --
	for i, menuItem in pairs(self.items) do
		menuItem:draw()
	end

	-- Border.
	love.graphics.setColor(72, 131, 168)
	love.graphics.rectangle("line", 0, 0, self.width, self.height)

	love.graphics.pop()
end

function Menu:setHomePage()

	backFunc = function ()
		love.event.push("quit")   -- actually causes the app to quit
	end

	local height = 70

	local newGame = MenuItemButton:new("New Game", {x = 0, y = 0 * height}, height, self.width)
	newGame.target = function()
		self:setSelectPlayersPage()
	end
	newGame:setSelected(true)


	local quit = MenuItemButton:new("Quit", {x = 0, y = 3 * height}, height, self.width)
	quit.target = function()
		love.event.push("quit")
	end

	local highScore = MenuItemButton:new("HighScore", {x = 0, y = 2 * height}, height, self.width)
	highScore.target = function()
		self:setHighScoreSelectPlayersPage()
	end

	local resumeGame = MenuItemButton:new("Resume Game", {x = 0, y = 1 * height}, height, self.width)
	resumeGame.drawDerived = function(self)
		if not game and not self.disabled then resumeGame:setDisabled(true) end
	end
	resumeGame.target = function()
		if game then
			currentState = game
		end
	end

	self.items = {newGame, resumeGame, highScore, quit }
end

function Menu:setHighScoreSelectPlayersPage()
	backFunc = function ()
		self:setHomePage()
	end

	local height = 70
	local onePlayer = MenuItemButton:new("One Player", {x = 0, y = 0 * height}, height, self.width)

	onePlayer.target = function(x, y, b)
		self:setHighScorePage(1)
	end
	onePlayer:setSelected(true)

	local twoPlayer = MenuItemButton:new("Two Players", {x = 0, y = 1 * height}, height, self.width)
	twoPlayer.target = function(x, y, b)
		self:setHighScorePage(2)
	end

	self.items = {onePlayer, twoPlayer}
end

function Menu:enterHighScore(players, moves)
	backFunc = nil
	forwardFunc = nil

	local scoreList = data.highScore[players];
	local newHighScore = false

	for i = 1, #scoreList do
		if scoreList[i].moves > moves then
			self:setNewHighScoreEntryPage(players, moves)
			newHighScore =  true
		end
	end

	if not newHighScore then
		self:setHighScorePage(players)
	end
end

function Menu:setNewHighScoreEntryPage(players, moves)

	backFunc = function ()
		self:setHomePage()
	end

	local function addHighScore(players, moves, nick)
		local tmp = nil
		local next = nil
		for i = 1, #data.highScore[players] do
			if data.highScore[players][i].moves > moves then
				tmp = data.highScore[players][i]
				if not next then
					data.highScore[players][i] = {moves = moves, nick = nick}
				else
					data.highScore[players][i] = next
				end
				next = tmp
			end
		end
		data.saveHighScore()
	end

	local height = 70
	local title = MenuItem:new("Gratz! Your moves: " .. moves, {x = 0, y = 0 * height}, height, self.width)
	local below = MenuItem:new("Write your name below: ", {x = 0, y = 1 * height}, height, self.width)
	local input = MenuItemStringInput:new("", {x = 0, y = 2 * height}, height, self.width)

	local continue = MenuItemButton:new("press enter to continue", {x = 0, y = 3 * height}, height, self.width)
	input:setSelected(true)
	continue.isSelectable = function() return false end
	local function validateAndContinue()
		if input.text ~= "" then
			addHighScore(players, moves, input.text)
			self:setHighScorePage(players)
		end
	end
	input:setCallback(validateAndContinue)
	continue.target = validateAndContinue
	forwardFunc = validateAndContinue

	self.items = {title, below, input, continue}
end

function Menu:setHighScorePage(players)
	self.items = {}
	backFunc = function () self:setHighScoreSelectPlayersPage() end
	forwardFunc = function () self:setHomePage() end

	local height = 70
	self.items = {
		MenuItem:new(" ....... " .. players .. " PLAYER HIGH SCORE ....... ", {x = 0, y = 0}, height, self.width)
	}

	for i, score in ipairs(data.highScore[players]) do
		local item = MenuItem:new(score.moves .. " " .. score.nick, {x = 0, y = i * height}, height, self.width)
		table.insert(self.items, item)
	end

	local back = MenuItemButton:new("back", {x = 0, y = 6 * height}, height, self.width)
	back.selected = true
	back.target = function() self:setHomePage() end
	table.insert(self.items, back)

end

function Menu:setSelectPlayersPage()
	backFunc = function ()
		self:setHomePage()
	end

	local moveToGame = function (players)
		self:setHomePage()
		startGame(players)
		backFunc = function ()
			self:setHomePage()
			currentState = menu
		end
		forwardFunc = nil
	end

	local height = 70
	local onePlayer = MenuItemButton:new("One Player", {x = 0, y = 0 * height}, height, self.width)

	onePlayer.target = function(x, y, b)
		moveToGame(1)
	end
	onePlayer:setSelected(true)

	local twoPlayer = MenuItemButton:new("Two Players", {x = 0, y = 1 * height}, height, self.width)
	twoPlayer.target = function(x, y, b)
		moveToGame(2)
	end

	self.items = {onePlayer, twoPlayer}
end

return Menu