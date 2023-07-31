Paddle = Class{}

function Paddle:init(x, y, width, height)
	self.x = x
	self.y = y
	self.width = width
	self.height = height

	self.dy = 0
	self.iceSpikeCD = 0
	self.canmove = true
	self.freeztime = 0
end

function Paddle:update(dt)

	if self.freeztime > 0 then
		self.freeztime = self.freeztime - dt
		self.canmove = false
	else
		self.canmove = true
	end
	if self.canmove == true then
		if self.dy < 0 then
			self.y = math.max(0, self.y + self.dy * dt)
		elseif self.dy > 0 then
			self.y = math.min(VIRTUAL_HEIGHT - 40, self.y + self.dy * dt)
		end
	end
end

function Paddle:render()
	love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end