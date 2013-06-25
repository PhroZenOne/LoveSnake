local InputHandler = {}

InputHandler.functions = {
	setPlayerUpDir = 		function(player) player:setDirection({x = 0,  y = -1})	end,
	setPlayerLeftDir = 		function(player) player:setDirection({x = -1, y = 0})	end,
	setPlayerRightDir = 	function(player) player:setDirection({x = 1,  y = 0})	end,
	setPlayerDownDir = 		function(player) player:setDirection({x = 0,  y = 1})	end,
}

InputHandler.player1Keys = {
	up = InputHandler.functions.setPlayerUpDir,
	down = InputHandler.functions.setPlayerDownDir,
	left = InputHandler.functions.setPlayerLeftDir,
	right = InputHandler.functions.setPlayerRightDir
}

InputHandler.player2Keys = {
	w = InputHandler.functions.setPlayerUpDir,
	s = InputHandler.functions.setPlayerDownDir,
	a = InputHandler.functions.setPlayerLeftDir,
	d = InputHandler.functions.setPlayerRightDir
}

return InputHandler