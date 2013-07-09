local sound = {}

local dir = "sounds"
--assuming that our path is full of lovely files (it should at least contain main.lua in this case)
local files = love.filesystem.enumerate(dir)
for k, file in ipairs(files) do
    sound[string.gsub(file, "%.mp3$", "")] = love.audio.newSource(dir .. "/" .. file, "static") 
end

return sound