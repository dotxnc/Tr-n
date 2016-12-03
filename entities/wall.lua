local model_viewer = require ("lib.voxel.model_viewer")

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

local wall_model = model_viewer:new(love.filesystem.newFile("assets/trail.png"))

function wall_class:new(x, y, rotation, color, owner)
	local new = setmetatable({}, wall_class)
	new.x = x
	new.y = y
	new.rotation = rotation
	new.color = color
	new.owner = owner
	new.id = #globaltrails

	return new
end

function wall_class:update(dt)
	self.timer = self.timer + dt
end

function wall_class:draw()

	if self.timer < 2.8 then
		self.alpha = lerp(255, self.alpha, 0.98)
	else
		self.alpha = lerp(0, self.alpha, 0.5)
	end

	lg.setColor(self.color[1], self.color[2], self.color[3], self.alpha)
	wall_model.rotation = self.rotation
	wall_model:drawModel(self.x, self.y)

	if self.timer > 3 then
		rem(self)
	end
end

return wall_class
