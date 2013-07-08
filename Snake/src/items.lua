local Items = {}
local ItemTypes = {
	wall = {
		type = "wall",
		draw = function(self, coords)
			love.graphics.setColor(settings.wall.color)
			love.graphics.rectangle("fill", coords.x, coords.y, coords.width, coords.height) 
		end,
		collide = function(self, player)
			if player.eatAllPoints == 0 then
		 		player:die()
		 		return true
		 	else 
		 		
		 		player:point(settings.wall.points)
		 		player:eatAll(-1)
		 		player:grow(settings.wall.grow)
		 		return false
			end
		end
	},
	space = {
		type = "space",
		draw = function(self, coords)
			love.graphics.setColor(255,255,255,255)
			love.graphics.rectangle("line", coords.x, coords.y, coords.width, coords.height) 
		end,
		collide = function(self, player) return false end
	},
	snakeHead = {
		type = "snake",
		draw = function(self, coords)
			love.graphics.setColor(self.owner.headColor)
			love.graphics.rectangle("fill", coords.x, coords.y, coords.width, coords.height) 
		end,
		collide = function(self, player) player:die() return true end
	},
	snake = {
		type = "snake",
		draw = function(self, coords)
			if self.owner.eatAllPoints > 0 then
				love.graphics.setColor(self.owner.eatAllColor)
			else 
				love.graphics.setColor(self.owner.bodyColor)
			end
			love.graphics.rectangle("fill", coords.x, coords.y, coords.width, coords.height) 
		end,
		collide = function(self, player) player:die() return true end
	},
	food = {
		type = "consumable",
		draw = function(self, coords)
			love.graphics.setColor(settings.food.color)
			love.graphics.rectangle("fill", coords.x, coords.y, coords.width, coords.height) 
		end,
		collide = function(self, player, game) 
			player:grow(settings.food.grow)
			player:point(settings.food.points)
			game.itemsOnMap.fooditems = game.itemsOnMap.fooditems - 1 
			return true
		end
	},
	eatAll = {
		type = "consumable",
		draw = function(self, coords)
			love.graphics.setColor(settings.eatAll.color)
			love.graphics.rectangle("fill", coords.x, coords.y, coords.width, coords.height) 
		end,
		collide = function(self, player, game) 
			player:point(settings.eatAll.points)
			player:eatAll(1)
			game.itemsOnMap.eatAll = game.itemsOnMap.eatAll - 1 
			return true
		end
	}
}

function Items:new(type, owner)
	local itemType = ItemTypes[type]
	local o = {}
	setmetatable(o, self)
	self.__index = self
	
	o.collide = itemType.collide
	o.draw = itemType.draw
	o.type = itemType.type --TODO find out a nice way to do "instance of".
	o.owner = owner
	
	return o
end

return Items