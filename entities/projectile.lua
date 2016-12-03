local model_viewer = require ("lib.voxel.model_viewer")

local projectile_class = {
	x;
	y;
	rotation;
	timer=0;
	id;
	owner;
}
projectile_class.__index = projectile_class

local projectile_model = model_viewer:new(love.filesystem.newFile("assets/trail.png"))

function projectile_class:new(x, y, rotation, color, owner)
	local new = setmetatable({}, projectile_class)
	new.x = x
	new.y = y
	new.rotation = rotation
	new.color = color
	new.owner = owner
	return new
end

function projectile_class:update(dt)
	self.timer = self.timer + dt
	--move
	self.x = self.x + (math.cos(math.rad(self.rotation-90)) * 6);
	self.y = self.y + (math.sin(math.rad(self.rotation-90)) * 6);	
	if self.timer > 3 then
		self.timer = 3
		globaltrails:delete(self)
	end

end

function projectile_class:draw()
	
	lg.setColor(255,255,255,255);
	--lg.setColor(self.color[1], self.color[2], self.color[3], self.alpha)
	projectile_model.rotation = self.rotation
	projectile_model:drawModel(self.x, self.y)

end

return projectile_class
