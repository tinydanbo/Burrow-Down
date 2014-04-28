Class = require "lib.hump.class"
Enemy = require "game.enemy"
vector = require "lib.hump.vector"
Timer = require "lib.hump.timer"
Fireball = require "game.projectiles.fireball"
Gamestate = require "lib.hump.gamestate"

Imp = Class{__includes = Enemy,
	init = function(self, x, y, difficulty)
		Enemy.init(self, x, y)
		self.health = 7*(difficulty/2)
		self.l = x - 5
		self.t = y - 9
		self.w = 12
		self.h = 20
		self.hover = false
		self.wakeRange = 200
		self.moveSpeed = 20
		self.image:setFilter("nearest", "nearest")
	end,
	image = love.graphics.newImage("data/img/enemies/imp/imp.png")
}

function Imp:update(dt)
	Enemy.update(self, dt)
end

function Imp:findPlayer()
	self.desiredLocation = self:getPlayer().position
end

function Imp:attackPlayer()
	local toPlayer = self:getPlayer().position - self.position

	if toPlayer:len() < 200 then
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
end

function Imp:onWake()
	Enemy.onWake(self)
	self.desiredLocation = self:getPlayer().position

	self.timer:addPeriodic(0.5 + (math.random(0, 5) / 10), function()
		self:findPlayer()
	end)

	self.timer:addPeriodic(math.random(12, 20) / 10, function()
		self:attackPlayer()
	end)
end

function Imp:onDestroy()
	state = Gamestate:current()
	state.player:takeXP(75)

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

function Imp:draw()
	local x,y = self.position:unpack()

	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(self.image, x-12, y-12)

	Entity.draw(self)
end

return Imp