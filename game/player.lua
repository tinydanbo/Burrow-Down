Class = require "lib.hump.class"
vector = require "lib.hump.vector"
MindShot = require "game.spells.mindShot"
MindBlade = require "game.spells.mindBlade"
MindRay = require "game.spells.mindRay"
ImageParticle = require "game.particles.imageParticle"
ManaParticle = require "game.particles.manaParticle"
Entity = require "entity"
Timer = require "lib.hump.timer"

Player = Class{__includes = Entity,
	init = function(self, x, y, playerLevel, playerXp)
		Entity.init(self, x, y)
		self.type = "player"
		self.l = x-4
		self.t = y
		self.w = 8
		self.h = 8
		self.mana = 100
		self.maxMana = 100
		self.timer = Timer.new()
		self.invulnerable = false
		self.health = 10
		self.maxHealth = 10
		self.image:setFilter("nearest", "nearest")
		self.rechargeParticleAccumulate = 0
		self.faceLeft = false
		self.dead = false
		self.spells = {
			MindShot()
		}
		self.level = playerLevel
		self.xp = playerXp
		self:applyLevels()
		self.requiredXpLevels = {
			673, 690, 707, 724, 741, 
			858, 975, 1193, 1311, 1529, 
			1747, 1939, 2138, 2345, 2660, 
			2983, 3314, 3753, 4001, 99999999
		}
		self.currentSpell = self.spells[1]
		self.shotSwitchSound:setVolume(0.25)
		self.bladeSwitchSound:setVolume(0.25)
		self.raySwitchSound:setVolume(0.25)
		self.hurtSound:setVolume(0.5)
	end,
	moveSpeed = 100,
	image = love.graphics.newImage("data/img/player/player.png"),
	silenceImage = love.graphics.newImage("data/img/speech/silence.png"),
	heartImage = love.graphics.newImage("data/img/speech/heart.png"),
	shotSwitchSound = love.audio.newSource("data/sound/player/shot.ogg", "static"),
	bladeSwitchSound = love.audio.newSource("data/sound/player/blade.ogg", "static"),
	raySwitchSound = love.audio.newSource("data/sound/player/ray.ogg", "static"),
	hurtSound = love.audio.newSource("data/sound/player_hurt.wav", "static"),
	levelUpSound = love.audio.newSource("data/sound/level_up.wav", "static")
}

function Player:refillHealth()
	self:getState():addParticle(ImageParticle(self.heartImage, self.position.x, self.position.y-16, 0, -100, 255, 400))
	self.health = self.maxHealth
end

function Player:takeDamage(bullet)
	if not self.invulnerable and not self.dead then
		self.hurtSound:rewind()
		self.hurtSound:play()
		if self.level < 5 then
			self.mana = self.maxMana
		end
		self.health = self.health - bullet.damageOnHit
		if self.health <= 0 then
			self.health = 0
			self:die()
		else
			self.invulnerable = true
			self.timer:add(0.6, function()
				self.invulnerable = false
			end)
		end
	end
end

function Player:takeXP(xp)
	if self.level < 7 then
		self.mana = self.mana + (xp / 5)
		if self.mana > self.maxMana then
			self.mana = self.maxMana
		end
	end
	self.xp = self.xp + xp
	local requiredXp = self.requiredXpLevels[self.level]
	if self.xp > requiredXp then
		self.levelUpSound:rewind()
		self.levelUpSound:play()
		self.xp = self.xp - requiredXp
		self:applyLevel(true)
	end
end

function Player:applyLevel(drawMessage)
	self.mana = self.maxMana
	self.level = self.level + 1
	if self.level == 2 then
		self.maxMana = self.maxMana + 20
		self.mana = self.mana + 20
		if drawMessage then
			self:getState().hud:showMessage("+20 Mana!")
		end
	elseif self.level == 3 then
		table.insert(self.spells, MindBlade())
		if drawMessage then
			self:getState().hud:showMessage("You can now use [Mind Blade] - press 2 to switch!")
		end
	elseif self.level == 4 then
		self.maxHealth = self.maxHealth + 2
		self.health = self.health + 2
		if drawMessage then
			self:getState().hud:showMessage("+2 Health!")
		end
	elseif self.level == 5 then
		if drawMessage then
			self:getState().hud:showMessage("Mind Shot is now more powerful.")
		end
	elseif self.level == 6 then
		if drawMessage then
			self:getState().hud:showMessage("Mana regenerates faster when not charging.")
		end
	elseif self.level == 7 then
		self.maxMana = self.maxMana + 20
		self.mana = self.mana + 20
		if drawMessage then
			self:getState().hud:showMessage("+20 Mana!")
		end
	elseif self.level == 8 then
		table.insert(self.spells, MindRay())
		if drawMessage then
			self:getState().hud:showMessage("You can now use [Mind Ray] - press 3 to switch!")
		end
	elseif self.level == 9 then
		self.maxHealth = self.maxHealth + 2
		self.health = self.health + 2
		if drawMessage then
			self:getState().hud:showMessage("+2 Health!")
		end
	elseif self.level == 10 then
		self.maxMana = self.maxMana + 50
		self.mana = self.mana + 50
		if drawMessage then
			self:getState().hud:showMessage("+50 Mana!")
		end
	elseif self.level == 11 then
		self.maxMana = self.maxMana + 20
		self.mana = self.mana + 20
		if drawMessage then
			self:getState().hud:showMessage("+20 Mana!")
		end
	elseif self.level == 12 then
		if drawMessage then
			self:getState().hud:showMessage("Mana regenerates faster when charging.")
		end
	elseif self.level == 13 then
		if drawMessage then
			self:getState().hud:showMessage("Mind Shot is now even more powerful.")
		end
	elseif self.level == 14 then
		self.maxHealth = self.maxHealth + 2
		self.health = self.health + 2
		if drawMessage then
			self:getState().hud:showMessage("+2 Health!")
		end
	elseif self.level == 15 then
		self.spells[3].castCost = self.spells[3].castCost * 0.8
		if drawMessage then
			self:getState().hud:showMessage("Mind Ray now costs less mana.")
		end
	elseif self.level == 16 then
		self.maxMana = self.maxMana + 20
		self.mana = self.mana + 20
		if drawMessage then
			self:getState().hud:showMessage("+20 Mana!")
		end
	elseif self.level == 17 then
		self.maxHealth = self.maxHealth + 2
		self.health = self.health + 2
		if drawMessage then
			self:getState().hud:showMessage("+2 Health!")
		end
	elseif self.level == 18 then
		if drawMessage then
			self:getState().hud:showMessage("Mind Blade now lasts longer.")
		end
	elseif self.level == 19 then
		if drawMessage then
			self:getState().hud:showMessage("You regenerate mana faster when close to death.")
		end
	elseif self.level == 20 then
		self.maxHealth = self.maxHealth + 2
		self.health = self.health + 2
		self.maxMana = self.maxMana + 20
		self.mana = self.mana + 20
		if drawMessage then
			self:getState().hud:showMessage("+2 Mana, +20 Health!")
		end
	end
end

function Player:applyLevels()
	local playerLevel = self.level
	self.level = 1
	for i = 2, playerLevel, 1 do
		self:applyLevel(false)
	end
end

function Player:die()
	self.dead = true
	self:getState():playerDeath()
end

function Player:update(dt)

	if not self.dead then
		self.timer:update(dt)

		if love.mouse.isDown("l") and self.spells[3] and self.currentSpell == self.spells[3] then
			if self.mana > self.currentSpell.castCost then
				self.mana = self.mana - self.currentSpell.castCost	
				self.currentSpell:fire()
			end
			self.moveSpeed = 5
		elseif love.mouse.isDown("r") then
			if self.rechargeParticleAccumulate > 4 and self.mana < self.maxMana then
				self.rechargeParticleAccumulate = 0
				local vec = vector(math.random(-200, 200), math.random(-200, 200)):normalized()
				local particlePosition = vec * 30
				self:getState():addParticle(
					ManaParticle(
						self.position.x + particlePosition.x, 
						self.position.y + particlePosition.y
					)
				)
			end
			self.rechargeParticleAccumulate = self.rechargeParticleAccumulate + (20 * dt)
			if self.level >= 12 then
				self.mana = self.mana + (200 * dt)
			else
				self.mana = self.mana + (80 * dt)
			end
			self.moveSpeed = 20
		else
			if self.level >= 19 and self.health < 4 then
				self.mana = self.mana + (20 * dt)
			elseif self.level >= 6 then
				self.mana = self.mana + (7 * dt)
			else
				self.mana = self.mana + (3 * dt)
			end
			self.moveSpeed = 100
		end
		if self.mana > self.maxMana then
			self.mana = self.maxMana
		end

		local desiredDirection = vector(0, 0)
		if love.keyboard.isDown("w", "up") then
			desiredDirection.y = -1
		elseif love.keyboard.isDown("s", "down") then
			desiredDirection.y = 1
		end

		if love.keyboard.isDown("a", "left") then
			desiredDirection.x = -1
			self.faceLeft = true
		elseif love.keyboard.isDown("d", "right") then
			desiredDirection.x = 1
			self.faceLeft = false
		end

		self:move(desiredDirection * (self.moveSpeed * dt))
	end
end

function Player:draw()
	local x,y = self.position:unpack()

	if self.invulnerable then
		love.graphics.setColor(255, 100, 255)
	else
		love.graphics.setColor(255, 255, 255)
	end

	if self.faceLeft then
		love.graphics.draw(self.image, x, y, 0, -1, 1, 8, 8)
	else
		love.graphics.draw(self.image, x, y, 0, 1, 1, 8, 8)
	end

	Entity.draw(self)
end

function Player:onClick(x, y, button)
	if button == "l" then
		if self.mana > self.currentSpell.castCost then
			self.mana = self.mana - self.currentSpell.castCost	
			self.currentSpell:fire()
		else
			self:getState():addParticle(ImageParticle(self.silenceImage, self.position.x, self.position.y-16, 0, -100, 255, 400))
		end
	end
end

function Player:onKey(key)
	if key == "1" and self.spells[1] then
		self.currentSpell = self.spells[1]
		self.shotSwitchSound:play()
	elseif key == "2" and self.spells[2] then
		self.currentSpell = self.spells[2]
		self.bladeSwitchSound:play()
	elseif key == "3" and self.spells[3] then
		self.currentSpell = self.spells[3]
		self.raySwitchSound:play()
	end
end

return Player