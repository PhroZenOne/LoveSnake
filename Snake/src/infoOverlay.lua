local InfoOverlay = inheritsFrom ( Overlay )

function InfoOverlay:draw()
	love.graphics.setColor(150,150,150,255)
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
	love.graphics.setFont(smallfont)
	love.graphics.setColor(0,0,0,255)
	
	--[[
		multi line comments like this gets extra newline chars included. Bug in love2d or wrong encoding here?
		Anyway this is why the infoText below is a looong one liner.. 
	]]--
	local infoText = " Hello! And welcome to yet another snake clone.\n THE BIG DIFFERENCE in this game versus regular snake is that the\nwinner is the one that makes as few moves (changes in direction)\nas possible while still getting 100 points! GL HF!"
	love.graphics.print(infoText, self.x + 200, self.y + 100)

	local spacing = 30;
	
	love.graphics.setColor(settings.food.color)
	love.graphics.rectangle("fill", self.x+200, self.y+200, data.tile.width, data.tile.height)
	love.graphics.print("This gives you points ", self.x + 230, self.y + 200)

	love.graphics.setColor(settings.eatAll.color)
	love.graphics.rectangle("fill", self.x+200, self.y+200 + spacing , data.tile.width, data.tile.height)
	love.graphics.print("This enables you to eat walls " , self.x + 230, self.y + 200 + spacing)

	love.graphics.setColor(settings.wall.color)
	love.graphics.rectangle("fill", self.x+200, self.y + 200 + spacing * 2, data.tile.width, data.tile.height)
	love.graphics.print("This is a wall ", self.x + 230, self.y + 200 + spacing * 2)

	for i, color in ipairs(self.playerColors) do
		love.graphics.setColor(color)
		love.graphics.rectangle("fill", self.x+200, self.y+200 + spacing * (i + 2), data.tile.width, data.tile.height)
		love.graphics.print("This dot is player " .. i, self.x + 230, self.y + 200 + spacing * (i + 2))
	end
end

function InfoOverlay:setPlayerColors(colors)
	self.playerColors = colors
end

function InfoOverlay:mousepressed(mx, my, b)
	self.active = false
end

function InfoOverlay:keypressed(key)
	self.active = false
end


return InfoOverlay