Class = require "lib.hump.class"
vector = require "lib.hump.vector"
Gamestate = require "lib.hump.gamestate"

Hud = Class {
	init = function(self)
		self.portrait = love.graphics.newImage("data/img/portraits/skully.png")
		self.barFrame = love.graphics.newImage("data/img/hud/bar_frame.png")
		self.bar = love.graphics.newImage("data/img/hud/bar.png")
		self.spell1 = love.graphics.newImage("data/img/hud/spell-icons/mindshot.png")
		self.spell2 = love.graphics.newImage("data/img/hud/spell-icons/mindblade.png")
		self.spell3 = love.graphics.newImage("data/img/hud/spell-icons/mindray.png")
		self.font = love.graphics.newFont("data/fonts/04b03.ttf", 8)
		self.levelMessage = ""
		self.levelAlpha = 0
	end
}

function Hud:update(dt)
	if self.levelAlpha > 0 then
		self.levelAlpha = self.levelAlpha - (50 * dt)
	end
end

function Hud:draw()
	local player = Gamestate:current().player

	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(self.portrait, 8, 8)

	local healthScale = player.health / player.maxHealth

	-- health
	love.graphics.setColor(200, 60, 60)
	love.graphics.draw(self.bar, 8+32+2, 8, 0, healthScale, 1)
	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(self.barFrame, 8+32+2, 8)

	local manaScale = player.mana / player.maxMana

	-- mana
	love.graphics.setColor(60, 60, 200)
	love.graphics.draw(self.bar, 8+32+2, 8+10+2, 0, manaScale, 1)
	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(self.barFrame, 8+32+2, 8+10+2)

	-- spells
	love.graphics.setColor(255, 255, 255)

	if player.spells[1] then
		if player.currentSpell == player.spells[1] then
			love.graphics.setColor(255, 255, 255)
		else
			love.graphics.setColor(255, 255, 255, 80)
		end
		love.graphics.draw(self.spell1, 8+32+2, 8+20+4)
	end

	if player.spells[2] then
		if player.currentSpell == player.spells[2] then
			love.graphics.setColor(255, 255, 255)
		else
			love.graphics.setColor(255, 255, 255, 80)
		end
		love.graphics.draw(self.spell2, 8+32+4+16, 8+20+4)
	end

	if player.spells[3] then
		if player.currentSpell == player.spells[3] then
			love.graphics.setColor(255, 255, 255)
		else
			love.graphics.setColor(255, 255, 255, 80)
		end
		love.graphics.draw(self.spell3, 8+32+6+32, 8+20+4)
	end

	-- text!

	self:drawOutlineText("Lv"..tostring(player.level), 20, 34, 255)
	self:drawOutlineText(tostring(player.health).."/"..tostring(player.maxHealth), 112, 12, 255)
	self:drawOutlineText(tostring(math.floor(player.mana)).."/"..tostring(player.maxMana), 112, 24, 255)

	local requiredXp = player.requiredXpLevels[player.level]
	self:drawOutlineText("XP : "..tostring(player.xp).. " / "..tostring(requiredXp), 8, 230)

	if self.levelAlpha > 0 then
		self:drawOutlineText(self.levelMessage, 8, 218, self.levelAlpha)
	end
end

function Hud:showMessage(string)
	self.levelMessage = string
	self.levelAlpha = 255
end

function Hud:drawOutlineText(string, x, y, alpha)
	-- lol
	love.graphics.setFont(self.font)
	love.graphics.setColor(40, 40, 40)
	for bx = x-1, x+1, 1 do
		for by = y-1, y+1, 1 do
			love.graphics.print(string, bx, by)
		end
	end
	love.graphics.setColor(255, 255, 255, alpha)
	love.graphics.print(string, x, y)
end

return Hud