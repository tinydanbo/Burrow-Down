Class = require "lib.hump.class"
Gamestate = require "lib.hump.gamestate"
MindBladeProjectile = require "game.projectiles.mindBladeProjectile"
SimpleParticle = require "game.particles.simpleParticle"
vector = require "lib.hump.vector"
bump = require "lib.bump"

MindBlade = Class {
	init = function(self)
		-- Do nothing... yet!
		self.projectileSpeed = 400
		self.castCost = 80
		self.shootSound = love.audio.newSource("data/sound/mind_blade.wav")
		self.shootSound:setVolume(0.2)
	end
}

function MindBlade:update(dt)

end

function MindBlade:fire()
	self.shootSound:rewind()
	self.shootSound:play()
	local state = Gamestate.current()
	local player = state.player

	local mousex, mousey = state.camera:mousepos()

	local aimVector = vector(mousex, mousey) - player.position
	aimVector:normalize_inplace()

	local projectileVelocity = aimVector * self.projectileSpeed

	local projectile = MindBladeProjectile(
		player.position.x + (aimVector.x * 15), 
		player.position.y + (aimVector.y * 15), 
		projectileVelocity.x + math.random(-15, 15), 
		projectileVelocity.y + math.random(-15, 15)
	)

	state.player:move(aimVector * -0.5)

	state:shakeCamera(5)
	state:addEntity(projectile)
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

return MindBlade