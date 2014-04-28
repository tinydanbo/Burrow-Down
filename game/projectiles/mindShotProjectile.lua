Class = require "lib.hump.class"
vector = require "lib.hump.vector"
SimpleParticle = require "game.particles.simpleParticle"
Entity = require "entity"

MindShotProjectile = Class{__includes = Entity,
	init = function(self, x, y, dx, dy, damageOnHit)
		Entity.init(self, x, y)
		self.velocity = vector(dx, dy)
		self.type = "playerbullet"
		self.damageOnHit = damageOnHit
		self.alpha = 160
		self.l = x-6
		self.t = y-6
		self.w = 12
		self.h = 12
	end,
	image = love.graphics.newImage("data/img/projectiles/mindshot.png")
}

function MindShotProjectile:update(dt)
	self:move(self.velocity * dt)
end

function MindShotProjectile:draw()
	local x,y = self.position:unpack()

	love.graphics.setColor(255, 255, 255)
	self.image:setFilter("nearest", "nearest")
	love.graphics.draw(self.image, x-6, y-6)

	Entity.draw(self)
end

function MindShotProjectile:onHit(enemy)
	enemy:takeDamage(self.damageOnHit)
	self:destroy()
end

function MindShotProjectile:destroy()
	Entity.destroy(self)

	for i = 0, 5, 1 do
		self:getState():addParticle(
			SimpleParticle(
				self.position.x, -- x 
				self.position.y, -- y
				2, -- size
				math.random(-200, 200), -- dx
				math.random(-200, 200), -- dy
				100, -- red
				80, -- green
				200, -- blue
				160, -- alpha
				400 -- decay
			)
		)
	end
end

return MindShotProjectile