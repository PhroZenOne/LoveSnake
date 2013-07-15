local GameOverOverlay = inheritsFrom ( Overlay )

function GameOverOverlay:draw()
	love.graphics.setColor(100,100,100,100)
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
	love.graphics.setFont(bigfont)
	love.graphics.setColor(0,0,0,150)
	love.graphics.print("Game Over. :( \n Press escape to exit or \nany other key to restart!", self.x + 100, self.y + 100)
end

function GameOverOverlay:keypressed(key)
	if key == "escape" then
		currentState = menu
		return
	end
	startGame(self.players)
	self.active = false
end
	
function GameOverOverlay:setPlayers(players)
	self.players = players
end

return GameOverOverlay