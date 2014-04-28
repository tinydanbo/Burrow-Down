Class = require "lib.hump.class"
Enemy = require "game.enemy"
vector = require "lib.hump.vector"
Timer = require "lib.hump.timer"
Spark = require "game.projectiles.spark"
Gamestate = require "lib.hump.gamestate"

Fatso = Class{__includes = Enemy,
	init = function(self, x, y)
		Enemy.init(self, x, y)
		self.health = 140
		self.l = x - 12
		self.t = y - 14
		self.w = 24
		self.h = 28
		self.hover = false
		self.wakeRange = 240
		self.moveSpeed = 10
	end,
	image = love.graphics.newImage("data/img/enemies/fatso/fatso.png")
}

function Fatso:update(dt)
	Enemy.update(self, dt)
end

function Fatso:findPlayer()
	self.desiredLocation = self:getPlayer().position
end

function Fatso:attackPlayer()
	local toPlayer = self:getPlayer().position - self.position
	local aimVector = toPlayer:normalized()

	local state = Gamestate:current()

	for i = -60, 60, 30 do
		local fragmentAimVector = aimVector:rotated(math.rad(i))
		local projectileVelocity = fragmentAimVector * 140
		local projectile = Spark(
			self.position.x + (aimVector.x * 10), 
			self.position.y + (aimVector.y * 10), 
			projectileVelocity.x + math.random(-15, 15), 
			projectileVelocity.y + math.random(-15, 15)
		)
		state:addEntity(projectile)
	end
end

function Fatso:onWake()
	Enemy.onWake(self)
	self.desiredLocation = self:getPlayer().position

	self.timer:addPeriodic(0.5 + (math.random(0, 5) / 10), function()
		self:findPlayer()
	end)

	self.timer:addPeriodic(math.random(8, 12) / 10, function()
		self:attackPlayer()
	end)
end

function Fatso:onDestroy()
	state = Gamestate:current()
	state.player:takeXP(500)

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

function Fatso:draw()
	local x,y = self.position:unpack()

	love.graphics.setColor(255, 255, 255)
	self.image:setFilter("nearest", "nearest")
	love.graphics.draw(self.image, x-16, y-16)

	Entity.draw(self)
end

return Fatso