Class = require "lib.hump.class"
vector = require "lib.hump.vector"
Entity = require "entity"
Timer = require "lib.hump.timer"
Gamestate = require "lib.hump.gamestate"

SimpleParticle = require "game.particles.simpleParticle"

Spark = Class{__includes = Entity,
	init = function(self, x, y, dx, dy)
		Entity.init(self, x, y)
		self.velocity = vector(dx, dy)
		self.type = "enemybullet"
		self.damageOnHit = 1
		self.alpha = 160
		self.l = x-2
		self.t = y-2
		self.w = 4
		self.h = 4
		self.reflectable = false
		self.timer = Timer.new()
		self.timer:addPeriodic(0.05, function()
			self:addParticle()
		end)
	end,
	image = love.graphics.newImage("data/img/projectiles/spark.png")
}

function Spark:addParticle()
	local state = Gamestate.current()

	state:addParticle(
		SimpleParticle(
			self.position.x, -- x 
			self.position.y, -- y
			2, -- size
			0, -- dx
			0, -- dy
			255, -- red
			245, -- green
			104, -- blue
			80, -- alpha
			200 -- decay
		)
	)
end

function Spark:update(dt)
	self:move(self.velocity * dt)
	self.timer:update(dt)
end

function Spark:draw()
	local x,y = self.position:unpack()

	love.graphics.setColor(255, 255, 255)
	self.image:setFilter("nearest", "nearest")
	love.graphics.draw(self.image, x-4, y-4)

	Entity.draw(self)
end

function Spark:onDestroy()
	self.timer:clear()
	Entity.destroy(self)
end

function Spark:onHit(enemy)
	enemy:takeDamage(self.damageOnHit)
	self:destroy()
end

return Spark