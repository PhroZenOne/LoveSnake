local Overlay = {}

function Overlay:new(x, y, width, height)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.items = {}
	o.x = x
	o.y = y
	o.width = width
	o.height = height
	o.active = true
	return o
end

function Overlay:isActive()
	return self.active
end

function Overlay:update(dt)

end

function Overlay:mousepressed(mx, my, b)

end

function Overlay:keypressed(key)

end

function Overlay:draw()
	love.graphics.setColor(100,100,100,100)
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
	love.graphics.setFont(bigfont)
	love.graphics.setColor(0,0,0,150)
	love.graphics.print(self.text, self.x + 300, self.y + 200)
end


return Overlay