Class = require "lib.hump.class"
Entity = require "entity"

Clickable = Class{__includes = Entity,
	init = function(self, image, x, y)
		Entity.init(self, x, y)
		self.type = "clickable"
		self.image = image
		self.width = image:getWidth()
		self.height = image:getHeight()
	end,
}

function Clickable:update(dt)

end

function Clickable:draw()
	local x,y = self.position:unpack()

	love.graphics.draw(self.image, x-self.width/2, y-self.height/2)
end

function Clickable:isPointWithin(x, y, scale)
	local px,py = self.position:unpack()
	if x/scale > px - self.width/2 and x/scale < px + self.width/2 and
		y/scale > py - self.height/2 and y/scale < py + self.height/2 then
		return true
	else
		return false
	end
end

return Clickable