Class = require "lib.hump.class"
vector = require "lib.hump.vector"
Gamestate = require "lib.hump.gamestate"

Entity = Class {
	init = function(self, x, y)
		self.position = vector(x, y)
	end,
	isDestroyed = false
}

function Entity:getState()
	return Gamestate:current()
end

function Entity:move(v)
	self.position = self.position + v

	if self.l and self.t then
		self.l = self.l + v.x
		self.t = self.t + v.y
	end
end

function Entity:draw()
	if self.l and self.t then
		-- love.graphics.setColor(255, 0, 0)
		-- love.graphics.rectangle("line", self.l, self.t, self.w, self.h)
	end
end

function Entity:destroy()
	self.isDestroyed = true
end

return Entity