local InfoOverlay = inheritsFrom ( Overlay )

function InfoOverlay:draw()
	love.graphics.setColor(200,200,200,255)
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
	love.graphics.setFont(smallfont)
	love.graphics.setColor(0,0,0,255)

	--[[
	multi line comments like this gets extra newline chars included. Bug in love2d or wrong encoding here?
	Anyway this is why the infoText below is a looong one liner..
	]]--
	local infoText = "Hello! And welcome to yet another snake clone.\nTHE BIG DIFFERENCE in this game versus regular snake is that the\nwinner is the one that makes as few moves (changes in direction)\nas possible while still getting " .. settings.pointsToWinLimit .. " points! GL HF!"
	love.graphics.print(infoText, self.x + 50, self.y + 50)

	local spacing = 25;
	local xPadding = 50;
	local yPadding = 150;

	love.graphics.setColor(settings.food.color)
	love.graphics.rectangle("fill", self.x+xPadding, self.y+yPadding, data.tile.width, data.tile.height)
	love.graphics.print("This gives you " .. settings.food.points .. " points ", self.x + xPadding + 30, self.y + yPadding)

	love.graphics.setColor(settings.eatAll.color)
	love.graphics.rectangle("fill", self.x+xPadding, self.y+yPadding + spacing , data.tile.width, data.tile.height)
	love.graphics.print("Eat to get " .. settings.eatAll.points .. " points and enables you to eat ONE wall \nblock (and yes, they do stack!). " , self.x + xPadding + 30, self.y + yPadding + spacing)

	love.graphics.setColor(settings.wall.color)
	love.graphics.rectangle("fill", self.x+xPadding, self.y + yPadding + spacing * 3, data.tile.width, data.tile.height)
	love.graphics.print("This is a wall (eat for " .. settings.wall.points .. "p)", self.x + xPadding + 30, self.y + yPadding + spacing * 3)

	for i, color in ipairs(self.playerColors) do
		love.graphics.setColor(color)
		love.graphics.rectangle("fill", self.x+xPadding, self.y+yPadding + spacing * (i + 3), data.tile.width, data.tile.height)
		love.graphics.print("This dot is player " .. i, self.x + xPadding + 30, self.y + yPadding + spacing * (i + 3))
	end

	for i, color in ipairs(self.playerColors) do
		love.graphics.setColor(color)
		if i == 1 then
			local playerOneText = "Player 1: Use your arrows to steer."
			love.graphics.print(playerOneText, self.x + xPadding,  self.y + yPadding + spacing * 8)
		elseif i == 2 then
			local playerTwoText = "Player 1: Use the WASD-keys to steer."
			love.graphics.print(playerTwoText, self.x + xPadding,  self.y + yPadding + spacing * 9)
		end
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