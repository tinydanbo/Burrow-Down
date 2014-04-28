Class = require "lib.hump.class"
vector = require "lib.hump.vector"
Entity = require "entity"

SimpleParticle = Class{__includes = Entity,
	init = function(self, x, y, size, dx, dy, r, g, b, a, decay)
		Entity.init(self, x, y)
		self.size = size
		self.velocity = vector(dx, dy)
		self.red = r
		self.green = g
		self.blue = b
		self.alpha = a
		self.decay = decay
	end
}

function SimpleParticle:update(dt)
	self.alpha = self.alpha - (self.decay * dt)
	if self.alpha < 0 then
		self:destroy()
	end

	self.position = self.position + (self.velocity * dt)
end


function SimpleParticle:draw()
	local x, y = self.position:unpack()

	love.graphics.setColor(self.red, self.green, self.blue, self.alpha)
	love.graphics.circle("fill", self.position.x, self.position.y, self.size)
end

return SimpleParticle