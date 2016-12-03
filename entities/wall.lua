local lovox = require ("lib.lovox")
local ModelData = lovox.modelData

local wall_class = {
	x;
	y;
	rotation;
	color={255, 0, 0};
	timer=0;
	id;
	owner;
	alpha=0;
}
wall_class.__index = wall_class


function wall_class:new(x, y, rotation, color, owner)
	local new = setmetatable({}, wall_class)
	new.x = x
	new.y = y
	new.rotation = rotation
	new.color = color
	new.owner = owner
	new.id = #globaltrails
	new.wall_model = lovox.model(ModelData("assets/trail"))--model_viewer:new(love.filesystem.newFile("assets/trail.png"))

	return new
end

local z = 0
function wall_class:update(dt)
	self.timer = self.timer + dt
	z = math.cos(love.timer.getTime()) * 10
end
function wall_class:draw()

	if self.timer < 2.8 then
		self.alpha = lerp(255, self.alpha, 0.98)
	else
		self.alpha = lerp(0, self.alpha, 0.7)
	end

	self.wall_model.color = {self.color[1], self.color[2], self.color[3], self.alpha}
	--wall_model.rotation = self.rotation
	self.wall_model:draw(self.x-lg.getWidth()/2, self.y-lg.getHeight()/2, 1, math.rad(self.rotation), 2, 2)

	if self.timer > 3 then
		rem(self)
	end
end

return wall_class
