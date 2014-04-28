Class = require "lib.hump.class"
vector = require "lib.hump.vector"
Entity = require "entity"
Timer = require "lib.hump.timer"
Gamestate = require "lib.hump.gamestate"

SimpleParticle = require "game.particles.simpleParticle"

Fireball = Class{__includes = Entity,
	init = function(self, x, y, dx, dy)
		Entity.init(self, x, y)
		self.velocity = vector(dx, dy)
		self.type = "enemybullet"
		self.damageOnHit = 2
		self.alpha = 160
		self.l = x-4
		self.t = y-4
		self.w = 8
		self.h = 8
		self.reflectable = true
		self.timer = Timer.new()
		self.timer:addPeriodic(0.1, function()
			self:addParticle()
		end)
	end,
	image = love.graphics.newImage("data/img/projectiles/fireball.png")
}

function Fireball:addParticle()
	local state = Gamestate.current()

	state:addParticle(
		SimpleParticle(
			self.position.x, -- x 
			self.position.y, -- y
			4, -- size
			0, -- dx
			-10, -- dy
			200, -- red
			80, -- green
			80, -- blue
			160, -- alpha
			400 -- decay
		)
	)
end

function Fireball:update(dt)
	self:move(self.velocity * dt)
	self.timer:update(dt)
end

function Fireball:draw()
	local x,y = self.position:unpack()

	love.graphics.setColor(255, 255, 255)
	self.image:setFilter("nearest", "nearest")
	love.graphics.draw(self.image, x-6, y-6)

	Entity.draw(self)
end

function Fireball:destroy()
	self.timer:clear()
	Entity.destroy(self)

	for i = 0, 20, 1 do
		self:getState():addParticle(
			SimpleParticle(
				self.position.x, -- x 
				self.position.y, -- y
				math.random(2, 3), -- size
				math.random(-200, 200), -- dx
				math.random(-200, 200), -- dy
				200, -- red
				80, -- green
				80, -- blue
				160, -- alpha
				400 -- decay
			)
		)
	end
end

function Fireball:onHit(enemy)
	enemy:takeDamage(self.damageOnHit)
	self:destroy()
end

return Fireball