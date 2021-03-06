local lg = love.graphics
local lm = love.math
local lf = love.filesystem
local framework = {}

framework.version = "LOVE"

function framework.load(file)
	return assert(lf.load(file), "File not found: " .. file)
end

function framework.newImage(path)
	local image = lg.newImage(path)
	image:setFilter("nearest", "nearest")
	
	return image
end

function framework:newCanvas()
	local canvas = lg.newCanvas(self.getWidth(), self.getHeight())
	canvas:setFilter("nearest", "nearest")

	return canvas
end

framework.clear				= lg.clear
framework.draw				= lg.draw
framework.getHeight			= lg.getHeight
framework.getWidth			= lg.getWidth
framework.line				= lg.line
framework.newSpriteBatch	= lg.newSpriteBatch
framework.newQuad			= lg.newQuad
framework.polygon			= lg.polygon
framework.rectangle			= lg.rectangle
framework.setColor			= lg.setColor
framework.setCanvas			= lg.setCanvas
framework.origin			= lg.origin
framework.pop				= lg.pop
framework.push				= lg.push

framework.isConvex			= lm.isConvex
framework.triangulate		= lm.triangulate

return framework
