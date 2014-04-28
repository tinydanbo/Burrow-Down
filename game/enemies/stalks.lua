Class = require "lib.hump.class"
Enemy = require "game.enemy"
vector = require "lib.hump.vector"
Timer = require "lib.hump.timer"
Fireball = require "game.projectiles.fireball"
Gamestate = require "lib.hump.gamestate"

Stalks = Class{__includes = Enemy,
	init = function(self, x, y, difficulty)
		Enemy.init(self, x, y)
		self.health = 15*(difficulty/2)
		self.l = x - 11
		self.t = y - 16
		self.w = 22
		self.h = 32
		self.hover = false
		self.wakeRange = 200
		self.moveSpeed = 10
		self.image:setFilter("nearest", "nearest")
	end,
	image = love.graphics.newImage("data/img/enemies/stalks/stalks.png")
}

function Stalks:update(dt)
	Enemy.update(self, dt)
end

function Stalks:findPlayer()
	self.desiredLocation = self:getPlayer().position
end

function Stalks:attackPlayer()
	local toPlayer = self:getPlayer().position - self.position

	if toPlayer:len() < 140 then
		local aimVector = toPlayer:normalized()

		local state = Gamestate:current()

		for i = -20, 20, 40 do
			local fragmentAimVector = aimVector:rotated(math.rad(i))
			local projectileVelocity = fragmentAimVector * 140
			local projectile = Fireball(
				self.position.x + (fragmentAimVector.x * 10), 
				self.position.y + (fragmentAimVector.y * 10), 
				projectileVelocity.x + math.random(-15, 15), 
				projectileVelocity.y + math.random(-15, 15)
			)
			state:addEntity(projectile)
		end
	end
end

function Stalks:onWake()
	Enemy.onWake(self)
	self.desiredLocation = self:getPlayer().position

	self.timer:addPeriodic(0.1 + (math.random(0, 5) / 10), function()
		self:findPlayer()
	end)

	self.timer:addPeriodic(1, function()
		self.timer:addPeriodic(0.2, function()
			self:attackPlayer()
		end, 3)
	end)
end

function Stalks:onDestroy()
	state = Gamestate:current()
	state.player:takeXP(100)

	for i = 0, math.random(25, 40), 1 do
		state:addParticle(
			SimpleParticle(
				self.position.x + math.random(-16, 16), -- x
				self.position.y + math.random(-16, 16), -- y
				math.random(4, 8), -- size
				math.random(-100, 100), -- dx 
				math.random(-100, 100), -- dy
				160, -- red
				20, -- green
				140, -- blue
				160, -- alpha
				200 -- decay
			)
		)
	end

	self.timer:clear()
	Enemy.destroy(self)
end

function Stalks:draw()
	local x,y = self.position:unpack()

	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(self.image, x-16, y-16)

	Entity.draw(self)
end

return Stalks