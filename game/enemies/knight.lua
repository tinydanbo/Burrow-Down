Class = require "lib.hump.class"
Enemy = require "game.enemy"
vector = require "lib.hump.vector"
Spark = require "game.projectiles.spark"
SimpleParticle = require "game.particles.simpleParticle"

Knight = Class{__includes = Enemy,
	init = function(self, x, y)
		Enemy.init(self, x, y)
		self.health = 60
		self.l = x - 10
		self.t = y - 10
		self.w = 20
		self.h = 20
		self.moveSpeed = 0
		self.wakeRange = 400
		self.charge = 0
		self.movable = false
	end,
	image = love.graphics.newImage("data/img/enemies/knight/knight.png")
}

function Knight:fire()
	local state = self:getState()

	for i = 0, 3, 1 do
		local rndVector = vector(math.random(-300, 300), math.random(-300, 300))
		local projectileSpeed = rndVector:normalized() * 140
		state:addEntity(Spark(self.position.x, self.position.y, projectileSpeed.x, projectileSpeed.y))
	end
end

function Knight:takeDamage(damage)
	Enemy.takeDamage(self, damage)
	self.charge = self.charge + damage*6
end

function Knight:onDestroy()
	state = Gamestate:current()

	self:fire()
	self:fire()
	self:fire()

	state:addParticle(
		SimpleParticle(
			self.position.x, -- x
			self.position.y, -- y
			14, -- size
			0, -- dx 
			0, -- dy
			240, -- red
			220, -- green
			180, -- blue
			160, -- alpha
			200 -- decay
		)
	)

	self.timer:clear()
	Enemy.destroy(self)
end

function Knight:update(dt)
	if self.awake then
		self.charge = self.charge + (40 * dt)
		if self.charge > 100 then
			self:fire()
			self.charge = 0
		end
	end
	Enemy.update(self, dt)
end

function Knight:draw()
	local x,y = self.position:unpack()

	love.graphics.setColor(150, 150, 150+self.charge)
	self.image:setFilter("nearest", "nearest")
	love.graphics.draw(self.image, x-16, y-16)

	Entity.draw(self)
end

return Knight