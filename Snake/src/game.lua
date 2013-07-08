local Game = {}

function Game:new(numberOfPlayers)
	local o = {}
	setmetatable(o, self)
	self.__index = self

	o.numberOfPlayers = numberOfPlayers
	o.players = {}

	for i = 1, numberOfPlayers do
		table.insert(o.players, Player:new({x = 20, y = 10 * i}, {math.random(255),math.random(255),math.random(255)}))
	end
	
	o.dtsum = 0
	
	local playerColors = {}
	for i, player in ipairs(o.players) do
		table.insert(playerColors, player.headColor)
	end
	o.overlay = InfoOverlay:new(data.offset.x1, data.offset.y1, data.screenSize.width, data.screenSize.height)
	o.overlay:setPlayerColors(playerColors)
	o.totalPoints = 0
	o.totalMoves = 0
	o.playersDead = 0
	o.itemsOnMap = {
		fooditems = 0,
		eatAll = 0
	}
	return o
end

function Game:mousepressed(x, y, b)
	if self.overlay and self.overlay.active then
		self.overlay:mousepressed(x, y, b)
	end
end

function Game:keypressed(key)
	if self.overlay and self.overlay.active then
		self.overlay:keypressed(key)
		return
	end
	if key == "escape" then
		currentState = menu
		return
	end
	if not self.stopGame then
		if input.player1Keys[key] then
			input.player1Keys[key](self.players[1])
		end
		if(2 == self.numberOfPlayers) and input.player2Keys[key] then
			input.player2Keys[key](self.players[2])
		end
	end
end

function Game:stepGame()
	self.dtsum = 0
	self:movePlayers(map)
	self:updateItems(map)
end

function Game:update(dt)
	if not self.stopGame then
		if not self.dtsum then
			self:stepGame()
		end

		self.dtsum = self.dtsum + dt
		if self.dtsum > 1 / settings.speed then
			self:stepGame()
		end
		if self.overlay then
			self.overlay:update(dt)
		end
	end
end

function Game:movePlayers(map)
	self.playersDead = 0
	self.totalPoints = 0
	self.totalMoves = 0
	if not self.stopGame then
		for i, player in ipairs(self.players) do
			if(i > self.numberOfPlayers) then break end
			self.totalPoints = self.totalPoints + player.gamePoints
			self.totalMoves = self.totalMoves + player.moves
			if player.alive then
				local result = player:move()
				if result.moved then
					-- clear space that the player left.
					for i = 1, #result.removed do
						local removed = result.removed[i];
						map[removed.y][removed.x] = Items:new("space")
					end
					
					-- check if the new position is outside of the map
					if result.position.y > #map or result.position.x > #map[1] or result.position.x < 1 or result.position.y < 1 then

						-- is there a way to do "proper" modulo on an array that is 1-index based? i.e.
						-- result.position.y %= map.length() in java. If so, the garbage below should be replaced

						result.position.y = result.position.y <= 0 and #map or result.position.y  >= #map + 1 and 1 or result.position.y
						result.position.x = result.position.x <= 0 and #map[1] or result.position.x  >= #map[1] + 1 and 1 or result.position.x
						
						player:setPosition(result.position) 
					end
					
					if not map[result.position.y][result.position.x]:collide(player, self) then
						map[result.position.y][result.position.x] = Items:new("snakeHead", player)
					end
					
					-- draw tail
					for i = 1, #result.tail do
						local tail = result.tail[i];
						map[tail.y][tail.x] = Items:new("snake", player)
					end
				else
					-- draw the start position
					map[result.position.y][result.position.x] = Items:new("snakeHead", player)
				end
			else
				self.playersDead = self.playersDead + 1
			end
		end
	end
	if self.playersDead == #self.players then
		self.overlay = GameOverOverlay:new(data.offset.x1, data.offset.y1, data.screenSize.width, data.screenSize.height)
		self.overlay:setPlayers(#self.players)
		self.stopGame = true
	end
	if self.totalPoints >= settings.pointsToWinLimit then
		self.stopGame = true
		playSound("win")
		self.overlay = WinOverlay:new(data.offset.x1, data.offset.y1, data.screenSize.width, data.screenSize.height)
		self.overlay:setMoves(#self.players, self.totalMoves)
	end
end

function Game:updateItems(map)
	if self.itemsOnMap.fooditems < 3 then
		self:putItemOnMap(Items:new("food"), map)
		self.itemsOnMap.fooditems = self.itemsOnMap.fooditems + 1
	end
	if self.itemsOnMap.eatAll < 2 then
		self:putItemOnMap(Items:new("eatAll"), map)
		self.itemsOnMap.eatAll = self.itemsOnMap.eatAll + 1
	end
end

function Game:putItemOnMap(item, map)
	emptySpaces = {}
	-- find all placed that has space.
	for y, row in ipairs(map) do
		for x, item in ipairs(row) do
			if item.type == "space" then
				table.insert(emptySpaces, {x = x, y = y})
			end
		end
	end
	if #emptySpaces > 0 then
		cords = emptySpaces[math.random(#emptySpaces)];
		map[cords.y][cords.x] = item
	end
end

function Game:draw()

	-- draw snakes, walls and Items.
	for y=1, #map do
		for x=1, #map[y] do
			map[y][x]:draw({
				x = x * data.tile.width + data.tileOffset.x,
				y = y * data.tile.height + data.tileOffset.y,
				width = data.tile.width,
				height = data.tile.height
			})
		end
	end

	love.graphics.setFont(smallfont)
	-- draw interface
	love.graphics.setColor(0,0,0)
	love.graphics.print("POINTS: " .. self.totalPoints, data.offset.x1 + 100, data.offset.y1 - 25)
	love.graphics.print("MOVES: " .. self.totalMoves, data.offset.x1 + 300, data.offset.y1 - 25)
	if self.overlay and self.overlay:isActive() then
		self.overlay:draw()
	end
end

return Game