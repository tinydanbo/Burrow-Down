Class = require "lib.hump.class"
vector = require "lib.hump.vector"
Entity = require "entity"

ImageParticle = Class{__includes = Entity,
	init = function(self, image, x, y, dx, dy, a, decay)
		Entity.init(self, x, y)
		self.velocity = vector(dx, dy)
		self.alpha = a
		self.decay = decay
		self.image = image
		self.image:setFilter("nearest", "nearest")
	end,
}

function ImageParticle:update(dt)
	self.alpha = self.alpha - (self.decay * dt)
	if self.alpha < 0 then
		self:destroy()
	end
	self.position = self.position + (self.velocity * dt)
end


function ImageParticle:draw()
	local x, y = self.position:unpack()

	love.graphics.setColor(255, 255, 255, self.alpha)
	love.graphics.draw(self.image, self.position.x, self.position.y)
end

return ImageParticle