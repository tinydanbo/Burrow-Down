Class = require "lib.hump.class"
vector = require "lib.hump.vector"
Entity = require "entity"

MindBladeProjectile = Class{__includes = Entity,
	init = function(self, x, y, dx, dy)
		Entity.init(self, x, y)
		self.velocity = vector(dx, dy)
		self.type = "playerblade"
		self.damageOnHit = 0.002
		self.totalDamage = 50
		self.alpha = 255
		self.l = x-16
		self.t = y-16
		self.w = 32
		self.h = 32
		self.decel = 1300
		self.rotation = 0
		self.dr = 0
		self.image:setFilter("nearest", "nearest")
	end,
	image = love.graphics.newImage("data/img/projectiles/mindblade.png")
}

function MindBladeProjectile:update(dt)
	self:move(self.velocity * dt)
	self.rotation = self.rotation + (self.dr * dt)
	if self.dr < 24 then
		self.dr = self.dr + (10 * dt)
	end

	if self:getState().player.level >= 18 then
		self.alpha = self.alpha - (30 * dt)
	else
		self.alpha = self.alpha - (50 * dt)
	end
	
	if self.alpha < 60 then
		self:destroy()
	end

	if self.velocity.x > 0 then
		self.velocity.x = math.max(0, self.velocity.x - (self.decel * dt))
	elseif self.velocity.x < 0 then
		self.velocity.x = math.min(0, self.velocity.x + (self.decel * dt))
	end

	if self.velocity.y > 0 then
		self.velocity.y = math.max(0, self.velocity.y - (self.decel * dt))
	elseif self.velocity.y < 0 then
		self.velocity.y = math.min(0, self.velocity.y + (self.decel * dt))
	end
end

function MindBladeProjectile:draw()
	local x,y = self.position:unpack()

	love.graphics.setColor(255, 255, 255, self.alpha)
	love.graphics.draw(self.image, x, y, self.rotation, 2, 2, 8, 8)

	Entity.draw(self)
end

function MindBladeProjectile:onHit(enemy)
	if self.totalDamage > 0 then
		local damage = self.damageOnHit * (self.dr + self.velocity:len() * 10)
		enemy:takeDamage(damage)
		self.totalDamage = self.totalDamage - damage
	end
	if enemy.movable then
		local toEnemy = self.position - enemy.position
		enemy:move(toEnemy * -0.1)
	end
end

return MindBladeProjectile