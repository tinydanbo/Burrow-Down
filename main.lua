io.stdout:setvbuf("no")

Gamestate = require "lib.hump.gamestate"
titleState = require "states.title"

function love.load()
	love.graphics.setDefaultFilter("nearest", "nearest")
	love.window.setIcon(love.graphics.newImage("data/img/player/player.png"):getData())
	Gamestate.registerEvents({'update', 'mousereleased', 'keyreleased'})
	Gamestate.switch(titleState)
end

function love.draw()
	Gamestate.draw()
	-- love.graphics.setColor(255, 255, 255)
	-- love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 10)
end