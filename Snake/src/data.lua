local data = {}

--[[
 the numbers 64, 964, 949 and 94 corresponds to pixel position on 
 screen so that the game board fits the background image.
 (left, right, bottom and top).
  ]]--

data.offset = {
	x1 = 64,
	y1 = 94,
	x2 = 964,
	y2 = 649
}

data.screenSize = {
	width = data.offset.x2 - data.offset.x1,
	height = data.offset.y2 - data.offset.y1
}

data.tile = {
	width = data.screenSize.width / settings.mapSize.x,
	height = data.screenSize.height / settings.mapSize.y
}

data.tileOffset = {
	x = data.offset.x1 - data.tile.width,
	y = data.offset.y1 - data.tile.height
}

data.highScore = { -- these are the default values, will overridden by highscore file on load
	{
		{moves = 75, nick = "Duke Nukem"},
		{moves = 150, nick = "Lara Croft"},
		{moves = 300, nick = "Gordon Freeman"},
		{moves = 400, nick = "Pac-man"},
		{moves = 500, nick = "Link"}
	},
	{
		{moves = 75, nick = "Beavis & Butthead"},
		{moves = 150, nick = "Tom & Jerry"},
		{moves = 300, nick = "Batman & Robin"},
		{moves = 400, nick = "M & Ms"},
		{moves = 500, nick = "Duke & Pacman"}
	}
}

data.loadHighScore = function()
	if love.filesystem.exists("highscore.save") then
		data.highScore = Tserial.unpack( love.filesystem.read( "highscore.save" ) )
	end
end

data.saveHighScore = function()
	love.filesystem.write( "highscore.save", Tserial.pack(data.highScore) )
end

return data