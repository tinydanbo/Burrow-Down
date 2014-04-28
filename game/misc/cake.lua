Class = require "lib.hump.class"
Entity = require "entity"

Cake = Class{__includes = Entity,
	init = function(self, x, y)
		Entity.init(self, x, y)
		self.type = "cake"
		self.l = x-8
		self.t = y-8
		self.w = 16
		self.h = 16
		self.image:setFilter("nearest", "nearest")
	end,
	image = love.graphics.newImage("data/img/items/cake.png")
}

function Cake:update()

end

function Cake:draw()
	local x,y = self.position:unpack()

	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(self.image, x-8, y-8)

	Entity.draw(self)
end

return Cake