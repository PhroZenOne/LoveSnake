local Player = {}

function Player:new(pos, headColor)
	local o = {
		moves = 0,
		direction = {
			x = 0,
			y = 0
		},
		inputQueue = {},
		position = {
			x = pos.x,
			y = pos.y
		},
		tail = {},
		alive = true,
		growPoints = 10,
		gamePoints = 0,
		eatAllPoints = 0,
		headColor = headColor,
		bodyColor = {255,100,200},
		eatAllColor = {0,0,0},
		moves = 0
	}
	setmetatable(o, self)
	self.__index = self
	return o
end


function Player:setDirection(dir)
	
	--not allowed to complete change of direction (would crash into itself)
	if #self.inputQueue ~= 0 then
		if (self.inputQueue[#self.inputQueue].x == -dir.x and self.inputQueue[#self.inputQueue].x ~= 0) or (self.inputQueue[#self.inputQueue].y == -dir.y and self.inputQueue[#self.inputQueue].y ~= 0) then
			return
		end
	elseif (self.direction.x == -dir.x and self.direction.x ~= 0) or (self.direction.y == -dir.y and self.direction.y ~= 0) then
		return
	end
	table.insert(self.inputQueue, dir)
	self.moves = self.moves + 1
end

function Player:getDirection()
	return self.direction
end

function Player:setPosition(dir)
	self.position.x = dir.x
	self.position.y = dir.y
end

function Player:die()
	playSound("lose")
	self.alive = false
end

function getMoves()
	return self.moves
end

function Player:grow(i)
	self.growPoints = self.growPoints + i
end

function Player:point(i)
	playSound("point")
	self.gamePoints = self.gamePoints + i
end

function Player:eatAll(i) -- when a snake has eatAllPoints it can chew through walls..
	self.eatAllPoints = self.eatAllPoints + i
	return self.eatAllPoints
end

function Player:move()
	if #self.inputQueue > 0 then
		self.direction = table.remove(self.inputQueue,1)
	end	

	local pos = self:getPosition()
	local dir = self:getDirection()

	if dir.x == 0 and dir.y == 0 then
		return { removed = {}, position = self.position, tail = self.tail}
	end

	self:setPosition({
		x = pos.x + dir.x,
		y = pos.y + dir.y
	})

	local removed = {}
	if self.growPoints == 0 then
		table.insert(removed, table.remove(self.tail))
	else
		self.growPoints = self.growPoints - 1
	end

	table.insert(self.tail, 1, pos)
	return { moved = true, removed = removed, position = self.position, tail = self.tail}
end

function Player:getTailPos()
	return self.tail[#self.tail]
end

function Player:getPosition()
	return  {
		x = self.position.x,
		y = self.position.y
	}
end

return Player