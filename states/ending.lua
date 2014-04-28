Gamestate = require "lib.hump.gamestate"

local ending = {}

function ending:enter(oldState, mapName)
	self.image = love.graphics.newImage("data/img/ending.png")
	self.tick = 0
end

function ending:update(dt)
	self.tick = self.tick + dt
end

function ending:draw()
	love.graphics.draw(self.image, 0, 0)
end

function ending:mousereleased(x, y, button)
	if self.tick > 2 then
		Gamestate.pop()
	end
end

return ending