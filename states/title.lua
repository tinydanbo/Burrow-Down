Gamestate = require "lib.hump.gamestate"
Decoration = require "game.decoration"
Clickable = require "game.clickable"
mapState = require "states.map"
tween = require "lib.tween"

local title = {}

function title:enter(oldState, mapName)
	self.bgImage = love.graphics.newImage("data/img/title/title_bg.png")
	self.title = Decoration(
		love.graphics.newImage("data/img/title/title_name.png"),
		200,
		130,
		0,
		255
	)
	self.text = Decoration(
		love.graphics.newImage("data/img/title/title_text.png"),
		500,
		120,
		0, 
		255
	)
	self.mask = {
		alpha = 255
	}
	self.start = Clickable(
		love.graphics.newImage("data/img/title/title_start.png"),
		28,
		225
	)
	self.about = Clickable(
		love.graphics.newImage("data/img/title/title_about.png"),
		230,
		225
	)
	self.quit = Clickable(
		love.graphics.newImage("data/img/title/title_quit.png"),
		290,
		227
	)
	self.state = "menu"
	tween(1, self.mask, {alpha = 0}, 'linear', function()

	end)
end

function title:update(dt)
	tween.update(dt)
end

function title:draw()
	love.graphics.setColor(255, 255, 255)

	love.graphics.push()
		love.graphics.scale(2, 2)
		love.graphics.draw(self.bgImage, 0, 0)
		self.start:draw()
		self.about:draw()
		self.quit:draw()
		self.title:draw()
		self.text:draw()
	love.graphics.pop()

	love.graphics.setColor(0, 0, 0, self.mask.alpha)
	love.graphics.rectangle("fill", 0, 0, 640, 480)
end

function title:mousereleased(x, y, button)
	if self.state == "menu" then
		if self.start:isPointWithin(x, y, 2) then
			tween(1, self.mask, {alpha = 255}, 'linear', function()
				self.mask.alpha = 0
				Gamestate.push(mapState)
			end)
		elseif self.about:isPointWithin(x, y, 2) then
			self.state = "transition"
			tween(1, self.text, {x = 160}, 'outQuad', function()
				self.state = "about"
			end)
			tween(1, self.title, {x = -500}, 'outQuad')
			tween(1, self.start.position, {x = -500}, 'outQuad')
			tween(1, self.about.position, {x = -500}, 'outQuad')
			tween(1, self.quit.position, {x = -500}, 'outQuad')
		elseif self.quit:isPointWithin(x, y, 2) then
			love.event.quit()
		end
	elseif self.state == "about" then
		self.state = "transition"
		tween(1, self.text, {x = 500}, 'inQuad', function()
			self.state = "menu"
		end)
		tween(1, self.title, {x = 200}, 'outQuad')
		tween(1, self.start.position, {x = 28}, 'outQuad')
		tween(1, self.about.position, {x = 230}, 'outQuad')
		tween(1, self.quit.position, {x = 290}, 'outQuad')
	end
end

return title