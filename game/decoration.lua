Class = require "lib.hump.class"
Entity = require "entity"

Decoration = Class{__includes = Entity,
	init = function(self, image, x, y, rotation, alpha)
		Entity.init(self, x, y)
		self.type = "decoration"
		self.x = x
		self.y = y
		self.image = image
		self.width = image:getWidth()
		self.height = image:getHeight()
		self.rotation = rotation
		self.alpha = alpha
	end,
}

function Decoration:update(dt)

end

function Decoration:draw()
	local x,y = self.position:unpack()

	love.graphics.setColor(255, 255, 255, self.alpha)
	love.graphics.draw(self.image, self.x-self.width/2, self.y-self.height/2, self.rotation)
end

return Decoration