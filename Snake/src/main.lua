function love.load()
	require "utils"

	settings = {
		mapSize = {
			x = 50,
			y = 30
		},
		speed = 10,
		pointsToWinLimit = 50,
		food = {
			color = {0,255,0,255},
			grow = 7,
			points = 3
		},
		eatAll = {
			points = 1,
			color = {0,0,0,255}
		},
		wall = {
			color = {222,222,111,255},
			points = 1,
			grow = 5
		}
	}

	-- Global objects
	backgroundImage = love.graphics.newImage("images/background.png")
	data = require "data" --hold the calculated tilesize etc.
	input = require  "input" -- handles game user input.
	sound = require "sound"
	bigfont = love.graphics.newFont(50)
	smallfont = love.graphics.newFont(20)
	map = nil -- populated in startGame


	-- Global "classes"
	package.path = './classes/?.lua;' .. package.path
	Overlay = require "classes.overlay" -- overlay class
	InfoOverlay = require "classes.infoOverlay"
	GameOverOverlay = require "classes.gameOverOverlay"
	WinOverlay = require "classes.winOverlay"
	Items = require "classes.items" -- list if items on the map
	Player = require "classes.player"
	Game = require  "classes.game" -- Implements mousepressed, keypressed, draw and update
	Menu = require "classes.menu" -- Implements mousepressed, keypressed, draw and update
	Map = require "classes.map"

	-- setup
	data.loadHighScore()
	love.graphics.setLine(1, "rough") -- default "smooth" makes everything blurry. :(

	menu = Menu:new(data.offset.x1, data.offset.y1, data.screenSize.width, data.screenSize.height)
	menu:setHomePage()
	currentState = menu
end

function startGame(numberOfPlayers)
	map = Map:new(settings.mapSize.x, settings.mapSize.y)
	game = Game:new(numberOfPlayers)
	currentState = game
end

function love.draw()
	if(currentState) then
		love.graphics.setColor(255,255,255,255)
		love.graphics.draw(backgroundImage)
		currentState:draw()
	end
end

function love.mousepressed(x, y, button)
	if(currentState) then
		-- first handle back and forward buttons (offscreen)
		if y > (data.screenSize.height + data.offset.y1) then
			playSound("menu")
			if x > (data.screenSize.width + (data.offset.x1 * 2)) / 2 and backFunc then
				backFunc()
			elseif forwardFunc then
				forwardFunc()
			end
		end
		currentState:mousepressed(x, y, button)
	end
end


function love.keypressed(key)
	if(currentState) then currentState:keypressed(key) end
end

function love.update(dt)
	if(currentState) then currentState:update(dt) end
end