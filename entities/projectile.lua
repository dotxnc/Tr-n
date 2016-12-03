local model_viewer = require ("lib.voxel.model_viewer")
local wall = require ("entities.wall")
local projectile_class = {
	x;
	y;
	rotation;
	timer=0;
	id;
	owner;
}
projectile_class.__index = projectile_class

local projectile_model = model_viewer:new(love.filesystem.newFile("assets/projectile.png"))

function projectile_class:new(x, y, rotation, color, owner)
	local new = setmetatable({}, projectile_class)
	new.x = x
	new.y = y
	new.rotation = rotation
	new.color = color
	new.owner = owner
	new.id = #globaltrails
	return new
end

function projectile_class:update(dt)
	self.timer = self.timer + dt
	--move
	self.x = self.x + (math.cos(math.rad(self.rotation-90)) * 6);
	self.y = self.y + (math.sin(math.rad(self.rotation-90)) * 6);

	local remove=false
	local rx,ry
	for i,v in ipairs(globaltrails) do
		if v.__index == wall.__index and v.timer > 0.15 then
			if math.dist(v.x, v.y, self.x, self.y) < 24 then
				lg.setColor(255, 0, 0)
				lg.line(v.x, v.y, self.x, self.y)
				rem(self)
				remove=true
				rx,ry = v.x,v.y
			end
		end
	end

	if remove then
		for i=#globaltrails,1,-1 do local v=globaltrails[i] if inradius(v.x, v.y, rx, ry, 50) and v.__index == wall.__index then table.remove(globaltrails, i) end i = i + 1 end
	end
end

function projectile_class:draw()
	
	lg.setColor(255,255,255,255);
	--lg.setColor(self.color[1], self.color[2], self.color[3], self.alpha)
	projectile_model.rotation = self.rotation
	projectile_model:drawModel(self.x, self.y)	

	if self.timer > 4 then
		self.timer = 0
		rem(self)
	end

end

return projectile_class
