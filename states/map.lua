Gamestate = require "lib.hump.gamestate"
game = require "states.game"
Clickable = require "game.clickable"
tween = require "lib.tween"
endingState = require "states.ending"

local map = {}

function map:enter()
	self.backgroundImage = love.graphics.newImage("data/img/big/world_map_bg.png")
	self.state = "ready"
	self.difficultyLocked = false
	self.player = {
		x = 64,
		y = 68
	}
	self.playerLevel = 1
	self.playerXp = 0
	self.playerImage = love.graphics.newImage("data/img/player/player.png")
	self.nodes = {
		d1m1 = {
			name = "d1m1",
			difficulty = 1,
			map = 1,
			x = 64,
			y = 48+20,
			state = "unexplored"
		},
		d1m2 = {
			name = "d1m2",
			difficulty = 1,
			map = 2,
			x = 64*2,
			y = 48+20,
			state = "unexplored"
		},
		d1m3 = {
			name = "d1m3",
			difficulty = 1,
			map = 3,
			x = 64*3,
			y = 48+20,
			state = "unexplored"
		},
		d1m4 = {
			name = "d1m4",
			difficulty = 1,
			map = 4,
			x = 64*4,
			y = 48+20,
			state = "unexplored"
		},
		d2m2 = {
			name = "d2m2",
			difficulty = 2,
			map = 2,
			x = 64*2,
			y = (48*2)+20,
			state = "unexplored"
		},
		d2m3 = {
			name = "d2m3",
			difficulty = 2,
			map = 3,
			x = 64*3,
			y = (48*2)+20,
			state = "unexplored"
		},
		d2m4 = {
			name = "d2m4",
			difficulty = 2,
			map = 4,
			x = 64*4,
			y = (48*2)+20,
			state = "unexplored"
		},
		d3m3 = {
			name = "d3m3",
			difficulty = 3,
			map = 3,
			x = 64*3,
			y = (48*3)+20,
			state = "unexplored"
		},
		d3m4 = {
			name = "d3m4",
			difficulty = 3,
			map = 4,
			x = 64*4,
			y = (48*3)+20,
			state = "unexplored"
		},
		d4m4 = {
			name = "d4m4",
			difficulty = 4,
			map = 4,
			x = 64*4,
			y = (48*4)+20,
			state = "unexplored"
		},
	}
	self.decreaseDifficulty = Clickable(love.graphics.newImage("data/img/other/decrease_difficulty.png"), 160, 60)
	self.maintainDifficulty = Clickable(love.graphics.newImage("data/img/other/maintain_difficulty.png"), 160, 120)
	self.increaseDifficulty = Clickable(love.graphics.newImage("data/img/other/increase_difficulty.png"), 160, 180)
	self.difficultyWarning = Clickable(love.graphics.newImage("data/img/other/noob_alarm.png"), 160, 180)
	self.currentNode = self.nodes.d1m1
end

function map:update(dt)
	tween.update(dt)
end

function map:draw()
	love.graphics.push()
		love.graphics.scale(2, 2)
		love.graphics.draw(self.backgroundImage, 0, 0)

		for k, object in pairs(self.nodes) do
			local x = object.x
			local y = object.y
			love.graphics.setColor(20, 20, 20)
			love.graphics.rectangle("fill", x-10, y-10, 20, 20)
			if object.state == "unexplored" then
				love.graphics.setColor(255, 255, 255)
			elseif object.state == "cleared" then
				love.graphics.setColor(40, 150, 40)
			elseif object.state == "died" then
				love.graphics.setColor(150, 40, 40)
			end
			love.graphics.rectangle("fill", x-8, y-8, 16, 16)
		end

		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(self.playerImage, self.player.x-8, self.player.y-8)

		if self.state == "difficulty_select" then

			love.graphics.setColor(0, 0, 0, 240)
			love.graphics.rectangle("fill", 0, 0, 320, 240)
			love.graphics.setColor(255, 255, 255, 255)
			if self.currentNode.difficulty > 1 then
				self.decreaseDifficulty:draw()
			end

			self.maintainDifficulty:draw()
			
			if self.currentNode.difficulty < 4 then
				self.increaseDifficulty:draw()
				if self.difficultyLocked then
					self.difficultyWarning:draw()
				end
			end
		end

	love.graphics.pop()
end

function map:onClear(level, xp)

	self.playerLevel = level
	self.playerXp = xp

	self.currentNode.state = "cleared"
	self.difficultyLocked = false

	if self.currentNode.map == 4 then
		self.state = "game_cleared"
	else
		self.state = "difficulty_select"
	end
end

function map:onDeath(level, xp)
	
	self.playerLevel = level
	self.playerXp = xp

	self.currentNode.state = "died"
	self.difficultyLocked = true

	if self.currentNode.map == 4 then
		self.state = "game_cleared"
	else
		self.state = "difficulty_select"
	end
end

function map:mousereleased(x, y, button)
	if button == "l" then
		if self.state == "difficulty_select" then
			if self.decreaseDifficulty:isPointWithin(x, y, 2) and self.currentNode.difficulty > 1 then
				self:doDecreaseDifficulty()
			elseif self.maintainDifficulty:isPointWithin(x, y, 2) then
				self:doMaintainDifficulty()
			elseif self.increaseDifficulty:isPointWithin(x, y, 2) and self.currentNode.difficulty < 4 and not self.difficultyLocked then
				self:doIncreaseDifficulty()
			end
		elseif self.state == "ready" then
			Gamestate.push(game, self.currentNode.name, self.playerLevel, self.playerXp, self.currentNode.difficulty)
		elseif self.state == "game_cleared" then
			Gamestate.switch(endingState)
		end
	end
end

function map:moveToNextNode(difficulty, map)
	self.state = "moving"

	local nextNodeName = "d"..difficulty.."m"..map
	local nextNode = self.nodes[nextNodeName]

	tween(2, self.player, {x = nextNode.x, y = nextNode.y}, 'outQuad', function()
		self.currentNode = nextNode
		self.state = "ready"
	end)
end

function map:doDecreaseDifficulty()
	self:moveToNextNode(self.currentNode.difficulty-1, self.currentNode.map+1)
end

function map:doMaintainDifficulty()
	self:moveToNextNode(self.currentNode.difficulty, self.currentNode.map+1)	
end

function map:doIncreaseDifficulty()
	self:moveToNextNode(self.currentNode.difficulty+1, self.currentNode.map+1)
end

return map