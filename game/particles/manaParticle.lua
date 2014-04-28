Class = require "lib.hump.class"
vector = require "lib.hump.vector"
Entity = require "entity"

ManaParticle = Class{__includes = Entity,
	init = function(self, x, y)
		Entity.init(self, x, y)
		self.size = 1
	end,
}

function ManaParticle:update(dt)
	if self.size < 4 then
		self.size = self.size + (10 * dt)
	end

	local toPlayer = self:getState().player.position - self.position

	if toPlayer:len() < 1 then
		self:destroy()
	else
		local speed = toPlayer:normalized() * 2
		self:move(speed)
	end
end


function ManaParticle:draw()
	local x, y = self.position:unpack()

	love.graphics.setColor(180, 180, 255, 160)
	love.graphics.circle("fill", x, y, self.size)
end

return ManaParticle