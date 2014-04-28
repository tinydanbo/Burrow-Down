Class = require "lib.hump.class"
Entity = require "entity"
Gamestate = require "lib.hump.gamestate"
Timer = require "lib.hump.timer"
ImageParticle = require "game.particles.imageParticle"

Enemy = Class{__includes = Entity,
	init = function(self, x, y)
		Entity.init(self, x, y)
		self.type = "enemy"
		self.health = 10
		self.l = x - 10
		self.t = x + 10
		self.w = 20
		self.h = 20
		self.desiredLocation = vector(x, y)
		self.moveSpeed = 10
		self.wakeRange = 100
		self.awake = false
		self.movable = true
		self.hurtSound:setVolume(0.4)
		self.destroySound:setVolume(0.5)
		self.timer = Timer.new()
	end,
	swearImage = love.graphics.newImage("data/img/speech/swear.png"),
	hurtSound = love.audio.newSource("data/sound/enemy_hurt.wav", "static"),
	destroySound = love.audio.newSource("data/sound/enemy_destroy.wav", "static")
}

function Enemy:getPlayer()
	return Gamestate.current().player
end

function Enemy:update(dt)
	self.timer:update(dt)

	local player = self:getPlayer()
	if not self.awake then
		local toPlayer = self.position - player.position
		local distance = toPlayer:len()
		if distance < self.wakeRange then
			self.awake = true
			self:onWake()
		end
	else
		local toDesired = self.desiredLocation - self.position
		local move = toDesired:normalized() * self.moveSpeed
		self:move(move * dt)
	end
end

function Enemy:onWake()

end

function Enemy:takeDamage(damage)
	self.hurtSound:rewind()
	self.hurtSound:play()
	self.health = self.health - damage
	if self.health <= 0 then
		self.destroySound:rewind()
		self.destroySound:play()
		self:onDestroy()
	end

	local rndVector = vector(math.random(-300, 300), math.random(-300, 300))
	local particleSpeed = rndVector:normalized() * 140
	self:getState():addParticle(
		ImageParticle(
			self.swearImage, 
			self.position.x + (rndVector:normalized().x * 16), 
			self.position.y + (rndVector:normalized().y * 16), 
			particleSpeed.x, 
			particleSpeed.y, 
			255, 
			800
		)
	)
end

function Enemy:onDestroy()
	self.isDestroyed = true
end

function Enemy:draw()
	local x, y = self.position:unpack()

	love.graphics.setColor(240, 100, 100)
	love.graphics.rectangle("fill", x-10, y-10, 20, 20)
end

return Enemy