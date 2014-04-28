Class = require "lib.hump.class"
Enemy = require "game.enemy"
vector = require "lib.hump.vector"

TestEnemy = Class{__includes = Enemy,
	init = function(self, x, y)
		Enemy.init(self, x, y)
		self.health = 10
		self.l = x - 10
		self.t = y - 10
		self.w = 20
		self.h = 20
	end
}

function TestEnemy:update(dt)

end

function TestEnemy:draw()
	local x,y = self.position:unpack()

	love.graphics.setColor(200, 100, 100)
	love.graphics.rectangle("fill", x-10, y-10, 20, 20)

	Entity.draw(self)
end

return TestEnemy