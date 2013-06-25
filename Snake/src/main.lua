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
	bigfont = love.graphics.newFont(50)
	smallfont = love.graphics.newFont(20)
	
	-- Global "classes"
	Overlay = require "overlay" -- overlay class
	InfoOverlay = require "infoOverlay"
	GameOverOverlay = require "gameOverOverlay"
	WinOverlay = require "winOverlay"
	Items = require "items" -- list if items on the map
	Player = require "player"
	Game = require  "game"
	Menu = require "menu"
	
	-- setup
	data.loadHighScore()	
	love.graphics.setLine(1, "rough") -- default "smooth" makes everything blurry. :(
	
	menu = Menu:new(data.offset.x1, data.offset.y1, data.screenSize.width, data.screenSize.height)
	menu:setHomePage()
	currentState = menu
end

function startGame(numberOfPlayers)
	map = dofile "map.lua" -- dofile instead of require; if the player restarts we do a new read from map.lua
	game = Game:new(numberOfPlayers)
	currentState = game
end

function love.draw()
	love.graphics.setColor(255,255,255,255)
	love.graphics.draw(backgroundImage)
	currentState:draw()
end

function love.mousepressed(x, y, button)
	-- first handle back and forward buttons (offscreen)
	if y > (data.screenSize.height + data.offset.y1) then
		if x > (data.screenSize.width + (data.offset.x1 * 2)) / 2 and backFunc then
			backFunc()
		elseif forwardFunc then
			forwardFunc()
		end
	end
	
	currentState:mousepressed(x, y, button)
end

function love.keypressed(key)
	currentState:keypressed(key)
end

function love.update(dt)
	currentState:update(dt)
end