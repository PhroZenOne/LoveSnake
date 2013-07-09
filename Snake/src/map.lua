local Map = {}
function Map:new(width, height)
	local map = {}
	setmetatable(map, self)
	self.__index = self
	
		-- all 0 to begin with
	for y=1, height do
		for x=1, width do
			if not map[y] then map[y] = {} end
			map[y][x] = Items:new("space")
		end
	end

	--add some random walls.
	math.randomseed(12314) --same seed gives same map always. :)
	for y=1, height do
		for x=1, width do
			if math.random(1000) > 997 then
				local width, height  = math.random(50), 0
				if math.random(2) == 2 then
					width, height = height, width
				end
				for yy = y, y + height do
					for xx = x, x + width do
						if map[yy] and map[yy][xx] then map[yy][xx] = Items:new("wall") end
					end
				end

			end
		end
	end
	return map
end
return Map