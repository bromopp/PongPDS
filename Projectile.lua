Projectile = Class{}

function Projectile:init(x, y, width, height, owner)
	if(x <VIRTUAL_WIDTH/2) then
		self.x = 51
		self.dx = 200
	else
		self.x = VIRTUAL_WIDTH -51
		self.dx = -200
	end
	self.y = y
	self.width = width
	self.height = height
	self.breake = false
	self.owner = owner
	self.isActive = true

end

function Projectile:update(dt)
	self.x = self.x + self.dx * dt
end

function Projectile:render()
	love.graphics.setColor(1/10, 1/10, 1, 1)
	love.graphics.circle('fill', self.x, self.y, self.width)
end

function Projectile:collides(b)
	if self.x > b.x + b.width or self.x + self.width < b.x then
		return false
	end
	if self.y > b.y + b.height or self.y + self.height < b.y then
		return false
	end
	return true
end