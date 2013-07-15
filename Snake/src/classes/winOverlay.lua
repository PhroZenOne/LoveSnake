local WinOverlay = inheritsFrom ( Overlay )

function WinOverlay:draw()
	love.graphics.setColor(150,150,150,255)
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
	love.graphics.setFont(smallfont)
	love.graphics.setColor(0,0,0,255)
	love.graphics.print("Yay, you managed to get " .. settings.pointsToWinLimit .. " points in " .. self.moves .. " moves. \nPress enter to continue.", self.x + 200, self.y + 100)end

function WinOverlay:setMoves(players, moves)
	self.moves = moves
	self.players = players
end

function WinOverlay:mousepressed(mx, my, b)
	self:gotoMenu()
end

function WinOverlay:keypressed(key)
	if key == "return" or key == "kpenter" then
		self:gotoMenu()
	end
end

function WinOverlay:gotoMenu()
	self.active = false
	backFunc = nil
	forwardFunc = nil
	menu:enterHighScore(self.players, self.moves)
	currentState = menu
end

return WinOverlay