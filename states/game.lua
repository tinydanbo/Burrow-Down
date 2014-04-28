sti = require "lib.sti"
bump = require "lib.bump"
vector = require "lib.hump.vector"
Camera = require "lib.hump.camera"
Timer = require "lib.hump.timer"
tween = require "lib.tween"

Decoration = require "game.decoration"
Player = require "game.player"
Cake = require "game.misc.cake"
TestEnemy = require "game.enemies.testEnemy"
Imp = require "game.enemies.imp"
Chompy = require "game.enemies.chompy"
Portal = require "game.misc.portal"
Stalks = require "game.enemies.stalks"
Fatso = require "game.enemies.fatso"
Knight = require "game.enemies.knight"
Hud = require "game.hud"

local game = {}

function game:enter(oldState, mapName, playerLevel, playerXp, difficulty)
	bump.initialize(32)

	self.mapState = oldState
	self.difficulty = difficulty

	self.map = sti.new("data/maps/" .. mapName)

	self.playerLevel = playerLevel
	self.playerXp = playerXp

	self.entities = {}
	self.particles = {}

	self:spawnEntities()
	self:createCollisionInfo()

	self.hud = Hud()

	if difficulty == 1 then
		self.music = love.audio.newSource("data/music/back_to_the_ocean.it", "stream")
	elseif difficulty == 2 then
		self.music = love.audio.newSource("data/music/survivors_of_the_drought.xm", "stream")
	elseif difficulty == 3 then
		self.music = love.audio.newSource("data/music/level2.it", "stream")
	elseif difficulty == 4 then
		self.music = love.audio.newSource("data/music/yes_it_is.it", "stream")
	end

	self.music:setLooping(true)
	self.music:setVolume(1)
	self.music:play()

	self.camera = Camera(self.player.position.x, self.player.position.y)
	self.camera:zoom(2)

	self.frozen = false

	if mapName == "d1m1" then
		self.hud:showMessage("Welcome! WASD = Move, L-click = shoot, R-click (hold) = charge mana")
	end

	self.defeatedDeco = Decoration(love.graphics.newImage("data/img/other/defeated.png"), 160, 360, 0, 0)
	self.clearedDeco = Decoration(love.graphics.newImage("data/img/other/dungeonclear.png"), 160, -120, 0, 0)
end

function bump.collision(item1, item2, dx, dy)
	if item1.type == "player" and item2.type == "solid" then
		item1:move(vector(dx, dy))
	elseif item1.type == "solid" and item2.type == "player" then
		item2:move(vector(-dx, -dy))
	end

	if item1.type == "player" and item2.type == "nopass" then
		item1:move(vector(dx, dy))
	elseif item1.type == "nopass" and item2.type == "player" then
		item2:move(vector(-dx, -dy))
	end

	if item1.type == "enemy" and item2.type == "solid" then
		item1:move(vector(dx, dy))
	elseif item1.type == "solid" and item2.type == "enemy" then
		item2:move(vector(-dx, -dy))
	end

	if item1.type == "enemy" and item2.type == "nopass" then
		if not item1.hover then
			item1:move(vector(dx, dy))
		end
	elseif item1.type == "nopass" and item2.type == "enemy" then
		if not item2.hover then
			item2:move(vector(-dx, -dy))
		end
	end

	if item1.type == "solid" and item2.type == "playerbullet" then
		item2:destroy()
	elseif item1.type == "playerbullet" and item2.type == "solid" then
		item1:destroy()
	end

	if item1.type == "enemy" and item2.type == "playerbullet" then
		item2:onHit(item1)
	elseif item1.type == "playerbullet" and item2.type == "enemy" then
		item1:onHit(item2)
	end

	if item1.type == "player" and item2.type == "enemy" then
		item1:move(vector(dx, dy))
	elseif item1.type == "enemy" and item2.type == "player" then
		item2:move(vector(-dx, -dy))
	end

	if item1.type == "enemybullet" and item2.type == "solid" then
		item1:destroy()
	elseif item1.type == "solid" and item2.type == "enemybullet" then
		item2:destroy()
	end

	if item1.type == "enemy" and item2.type == "playerblade" then
		item2:onHit(item1)
	elseif item1.type == "playerblade" and item2.type == "enemy" then
		item1:onHit(item2)
	end

	if item1.type == "playerblade" and item2.type == "enemybullet" then
		if item2.reflectable then
			item2.velocity = vector(-item2.velocity.x, -item2.velocity.y)
			item2.type = "playerbullet"
			item2.damageOnHit = item2.damageOnHit * 3
		end
	elseif item1.type == "enemybullet" and item2.type == "playerblade" then
		if item1.reflectable then
			item1.velocity = vector(-item1.velocity.x, -item1.velocity.y)
			item1.type = "playerbullet"
			item1.damageOnHit = item1.damageOnHit * 3
		end
	end

	if item1.type == "enemy" and item2.type == "enemy" then
		item1:move(vector(dx, dy))
	end

	if item1.type == "portal" and item2.type == "player" then
		Gamestate.current():clearMap()
	elseif item1.type == "player" and item2.type == "portal" then
		Gamestate.current():clearMap()
	end

	if item1.type == "player" and item2.type == "enemybullet" then
		item1:takeDamage(item2)
		item2:destroy()
	elseif item1.type == "enemybullet" and item2.type == "player" then
		item2:takeDamage(item1)
		item1:destroy()
	end

	if item1.type == "player" and item2.type == "cake" then
		item2:destroy()
		item1:refillHealth()
	elseif item1.type == "cake" and item2.type == "player" then
		item1:destroy()
		item2:refillHealth()
	end

	if item1.type == "enemy" and item2.type == "playerray" then
		item2:onHit(item1)
	elseif item1.type == "playerray" and item2.type == "enemy" then
		item1:onHit(item2)
	end

	if item1.type == "solid" and item2.type == "playerray" then
		item2:destroy()
	elseif item1.type == "playerray" and item2.type == "solid" then
		item1:destroy()
	end

	-- print(item1.type, item2.type)
end

function bump.getBBox(item)
	return item.l, item.t, item.w, item.h
end

function game:playerDeath()
	self.frozen = true
	self.music:stop()
	if self.mapState then
		self.mapState:onDeath(self.player.level, self.player.xp)
	end
	tween(2, self.defeatedDeco, {alpha = 255, y = 120}, 'outQuad', function()
		Timer.add(2, function()
			Gamestate.pop()
		end)
	end)
end

function game:clearMap()
	self.frozen = true
	if self.mapState then
		self.mapState:onClear(self.player.level, self.player.xp)
	end
	tween(1, self.clearedDeco, {alpha = 255, y = 120}, 'outQuad', function()
		Timer.add(2, function()
			self.music:stop()
			Gamestate.pop()
		end)
	end)
end

function game:createCollisionInfo()
	self.solids = {}

	local layer = self.map.layers["Solids"]
	for _, object in ipairs(layer.objects) do
		local solid = {
			type="solid",
			l=layer.x+object.x,
			t=layer.y+object.y,
			w=object.width,
			h=object.height
		}
		bump.add(solid)
		table.insert(self.solids, solid)
	end

	self.nopass = {}

	local layer = self.map.layers["NoPass"]
	for _, object in ipairs(layer.objects) do
		local nopass = {
			type="nopass",
			l=layer.x+object.x,
			t=layer.y+object.y,
			w=object.width,
			h=object.height
		}
		bump.add(nopass)
		table.insert(self.nopass, nopass)
	end
end

function game:spawnEntities()
	local layer = self.map.layers["Entities"]
	for _, object in ipairs(layer.objects) do
		local objx = layer.x + object.x + (object.width / 2)
		local objy = layer.y + object.y + (object.height / 2)
		if object.type == "player" then
			self.player = Player(objx, objy, self.playerLevel, self.playerXp)
			bump.add(self.player)
		elseif object.type == "testEnemy" then
			self:addEntity(TestEnemy(objx, objy))
		elseif object.type == "imp" then
			self:addEntity(Imp(objx, objy, self.difficulty))
		elseif object.type == "chompy" then
			self:addEntity(Chompy(objx, objy))
		elseif object.type == "stalks" then
			self:addEntity(Stalks(objx, objy, self.difficulty))
		elseif object.type == "fatso" then
			self:addEntity(Fatso(objx, objy))
		elseif object.type == "knight" then
			self:addEntity(Knight(objx, objy))
		elseif object.type == "portal" then
			self:addEntity(Portal(objx, objy))
		elseif object.type == "cake" then
			self:addEntity(Cake(objx, objy))
		end
	end
end

function game:addEntity(entity)
	bump.add(entity)
	table.insert(self.entities, entity)
end

function game:addParticle(particle)
	table.insert(self.particles, particle)
end

function game:updateCamera(dt)
	local mousex, mousey = self.camera:mousepos()

	self.camera:lookAt((self.player.position.x * 3 + mousex) / 4, (self.player.position.y * 3 + mousey) / 4)
end

function game:shakeCamera(strength)
	-- self.camera:move(strength, strength)
end

function game:updateEntities(dt)
	local i = 1
	local entityTable = self.entities
	while i <= #entityTable do
		entityTable[i]:update(dt)
		if entityTable[i].isDestroyed then
			bump.remove(entityTable[i])
			table.remove(entityTable, i)
		else
			i = i + 1
		end
	end

	local i = 1
	local entityTable = self.particles
	while i <= #entityTable do
		entityTable[i]:update(dt)
		if entityTable[i].isDestroyed then
			table.remove(entityTable, i)
		else
			i = i + 1
		end
	end
end

function game:update(dt)
	Timer.update(dt)
	tween.update(dt)

	if not self.frozen then
		if self.player then
			self.player:update(dt)
		end

		self:updateEntities(dt)

		bump.collide()

		self:updateCamera(dt)
		self.hud:update(dt)
	end
end

function game:draw()
	self.camera:attach()
		self.map:drawLayer(self.map.layers["World"])

		self.player:draw()

		for _, object in ipairs(self.particles) do
			object:draw()
		end
		for _, object in ipairs(self.entities) do
			object:draw()
		end
	self.camera:detach()

	love.graphics.push()
		love.graphics.scale(2, 2)
		self.hud:draw()
		self.defeatedDeco:draw()
		self.clearedDeco:draw()
	love.graphics.pop()
end

function game:mousereleased(x, y, button)
	if not self.frozen then
		self.player:onClick(x, y, button)
	end
end

function game:keyreleased(key)
	if not self.frozen and (key == "1" or key == "2" or key == "3") then
		self.player:onKey(key)
	end
end

return game