Class = require "lib.hump.class"
Gamestate = require "lib.hump.gamestate"
MindShotProjectile = require "game.projectiles.mindShotProjectile"
SimpleParticle = require "game.particles.simpleParticle"
vector = require "lib.hump.vector"
bump = require "lib.bump"

MindShot = Class {
	init = function(self)
		-- Do nothing... yet!
		self.projectileSpeed = 240
		self.castCost = 5
		self.shootSound = love.audio.newSource("data/sound/mind_shot.wav")
		self.shootSound:setVolume(0.2)
	end
}

function MindShot:update(dt)

end

function MindShot:fireLv1(aimVector, state)
	local player = state.player
	local projectileVelocity = aimVector * self.projectileSpeed

	local projectile = MindShotProjectile(
		player.position.x + (aimVector.x * 15), 
		player.position.y + (aimVector.y * 15), 
		projectileVelocity.x + math.random(-15, 15), 
		projectileVelocity.y + math.random(-15, 15),
		2
	)

	state:addEntity(projectile)
end

function MindShot:fireLv2(aimVector, state)
	local player = state.player

	for i = -10, 10, 10 do
		local shotVector = aimVector:rotated(math.rad(i))
		local projectileVelocity = shotVector * (self.projectileSpeed * 1.1)
		local projectile = MindShotProjectile(
			player.position.x + (shotVector.x * 15), 
			player.position.y + (shotVector.y * 15), 
			projectileVelocity.x + math.random(-15, 15), 
			projectileVelocity.y + math.random(-15, 15),
			1.2
		)
		state:addEntity(projectile)
	end
end

function MindShot:fireLv3(aimVector, state)
	local player = state.player

	for i = -20, 20, 10 do
		local shotVector = aimVector:rotated(math.rad(i))
		local projectileVelocity = shotVector * (self.projectileSpeed * 1.1)
		local projectile = MindShotProjectile(
			player.position.x + (shotVector.x * 15), 
			player.position.y + (shotVector.y * 15), 
			projectileVelocity.x + math.random(-15, 15), 
			projectileVelocity.y + math.random(-15, 15),
			1
		)
		state:addEntity(projectile)
	end
end

function MindShot:fire()
	self.shootSound:rewind()
	self.shootSound:play()
	local state = Gamestate.current()
	local player = state.player

	local mousex, mousey = state.camera:mousepos()

	local aimVector = vector(mousex, mousey) - player.position
	aimVector:normalize_inplace()

	if player.level >= 13 then
		self:fireLv3(aimVector, state)
	elseif player.level >= 5 then
		self:fireLv2(aimVector, state)
	else
		self:fireLv1(aimVector, state)
	end

	state.player:move(aimVector * -0.5)

	state:shakeCamera(5)
	state:addParticle(
		SimpleParticle(
			player.position.x + (aimVector.x * 15), -- x
			player.position.y + (aimVector.y * 15), -- y
			8, -- size
			0, -- dx 
			0, -- dy
			160, -- red
			160, -- green
			255, -- blue
			160, -- alpha
			500 -- decay
		)
	)
end

return MindShot