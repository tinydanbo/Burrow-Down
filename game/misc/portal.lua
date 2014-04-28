Class = require "lib.hump.class"
Entity = require "entity"

Portal = Class{__includes = Entity,
	init = function(self, x, y)
		Entity.init(self, x, y)
		self.type = "portal"
		self.l = x-26
		self.t = y-26
		self.w = 52
		self.h = 52
	end,
	image = love.graphics.newImage("data/img/other/portal.png")
}

function Portal:update()

end

function Portal:draw()
	local x,y = self.position:unpack()

	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(self.image, x-32, y-32)

	Entity.draw(self)
end

return Portal