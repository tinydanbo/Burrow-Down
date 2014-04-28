Class = require "lib.hump.class"
Enemy = require "game.enemy"
vector = require "lib.hump.vector"
Timer = require "lib.hump.timer"
Fireball = require "game.projectiles.fireball"
Gamestate = require "lib.hump.gamestate"

Chompy = Class{__includes = Enemy,
	init = function(self, x, y)
		Enemy.init(self, x, y)
		self.health = 50
		self.l = x - 16
		self.t = y - 16
		self.w = 32
		self.h = 32
		self.hover = true
		self.wakeRange = 300
		self.moveSpeed = 40
	end,
	image = love.graphics.newImage("data/img/enemies/chompy2/chompy2.png")
}

function Chompy:update(dt)
	Enemy.update(self, dt)
end

function Chompy:findPlayer()
	self.desiredLocation = self:getPlayer().position
end

function Chompy:attackPlayer()
	local toPlayer = self:getPlayer().position - self.position
	local aimVector = toPlayer:normalized()

	local state = Gamestate:current()

	local projectileVelocity = aimVector * 140

	local projectile = Fireball(
		self.position.x + (aimVector.x * 10), 
		self.position.y + (aimVector.y * 10), 
		projectileVelocity.x + math.random(-15, 15), 
		projectileVelocity.y + math.random(-15, 15)
	)

	state:addEntity(projectile)
end

function Chompy:onWake()
	Enemy.onWake(self)
	self.desiredLocation = self:getPlayer().position

	self.timer:addPeriodic(0.5 + (math.random(0, 5) / 10), function()
		self:findPlayer()
	end)

	self.timer:addPeriodic(math.random(4, 6) / 10, function()
		self:attackPlayer()
	end)
end

function Chompy:onDestroy()
	state = Gamestate:current()
	state.player:takeXP(140)

	for i = 0, math.random(10, 30), 1 do
		state:addParticle(
			SimpleParticle(
				self.position.x + math.random(-16, 16), -- x
				self.position.y + math.random(-16, 16), -- y
				math.random(4, 8), -- size
				math.random(-100, 100), -- dx 
				math.random(-100, 100), -- dy
				160, -- red
				20, -- green
				20, -- blue
				160, -- alpha
				200 -- decay
			)
		)
	end

	self.timer:clear()
	Enemy.destroy(self)
end

function Chompy:draw()
	local x,y = self.position:unpack()

	love.graphics.setColor(255, 255, 255)
	self.image:setFilter("nearest", "nearest")
	love.graphics.draw(self.image, x-16, y-16)

	Entity.draw(self)
end

return Chompy