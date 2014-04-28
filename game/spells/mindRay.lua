Class = require "lib.hump.class"
Gamestate = require "lib.hump.gamestate"
MindRayProjectile = require "game.projectiles.mindRayProjectile"
SimpleParticle = require "game.particles.simpleParticle"
vector = require "lib.hump.vector"
bump = require "lib.bump"

MindRay = Class {
	init = function(self)
		-- Do nothing... yet!
		self.projectileSpeed = 600
		self.castCost = 5
		self.shootSound = love.audio.newSource("data/sound/mind_ray.wav")
		self.shootSound:setVolume(0.2)
	end
}

function MindRay:update(dt)

end

function MindRay:fire()
	self.shootSound:rewind()
	self.shootSound:play()
	local state = Gamestate.current()
	local player = state.player

	local mousex, mousey = state.camera:mousepos()

	local aimVector = vector(mousex, mousey) - player.position
	aimVector:normalize_inplace()

	local projectileVelocity = aimVector * self.projectileSpeed

	local projectile = MindRayProjectile(
		player.position.x + (aimVector.x * 15), 
		player.position.y + (aimVector.y * 15), 
		projectileVelocity.x, 
		projectileVelocity.y
	)

	state.player:move(aimVector * -0.5)

	state:shakeCamera(5)
	state:addEntity(projectile)
	state:addParticle(
		SimpleParticle(
			player.position.x + (aimVector.x * 10), -- x
			player.position.y + (aimVector.y * 10), -- y
			4, -- size
			0, -- dx 
			0, -- dy
			255, -- red
			255, -- green
			255, -- blue
			160, -- alpha
			500 -- decay
		)
	)
end

return MindRay