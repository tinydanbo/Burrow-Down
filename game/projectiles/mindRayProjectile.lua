Class = require "lib.hump.class"
vector = require "lib.hump.vector"
SimpleParticle = require "game.particles.simpleParticle"
Entity = require "entity"

MindRayProjectile = Class{__includes = Entity,
	init = function(self, x, y, dx, dy)
		Entity.init(self, x, y)
		self.velocity = vector(dx, dy)
		self.type = "playerray"
		self.damageOnHit = 0.8
		self.alpha = 160
		self.l = x-8
		self.t = y-8
		self.w = 16
		self.h = 16
	end,
	image = love.graphics.newImage("data/img/projectiles/mindshot.png")
}

function MindRayProjectile:update(dt)
	self:move(self.velocity * dt)
	self:getState():addParticle(
			SimpleParticle(
				self.position.x, -- x 
				self.position.y, -- y
				12, -- size
				0, -- dx
				0, -- dy
				255, -- red
				255, -- green
				255, -- blue
				100, -- alpha
				400 -- decay
			)
		)
	if self.damageOnHit > 0 then
		self.damageOnHit = self.damageOnHit - (0.8 * dt)
	elseif self.damageOnHit < 0 then
		self.damageOnHit = 0
	end
end

function MindRayProjectile:draw()
	local x,y = self.position:unpack()

	love.graphics.setColor(255, 255, 255, 100)
	love.graphics.circle("fill", x, y, 12)

	Entity.draw(self)
end

function MindRayProjectile:onHit(enemy)
	enemy:takeDamage(self.damageOnHit)
	if math.random(1, 10) > 8 then
		self:destroy()
	end
end

function MindRayProjectile:destroy()
	Entity.destroy(self)

	for i = 0, 5, 1 do
		self:getState():addParticle(
			SimpleParticle(
				self.position.x, -- x 
				self.position.y, -- y
				1, -- size
				math.random(-200, 200), -- dx
				math.random(-200, 200), -- dy
				255, -- red
				255, -- green
				255, -- blue
				160, -- alpha
				400 -- decay
			)
		)
	end
end

return MindRayProjectile