local model_viewer = require ("voxel.model_viewer")
local socket = require ("socket")
math.randomseed(socket.gettime()*1000)

local play = {
	model = nil;
	x = 100;
	y = 100;
	rotation = 0;
	color = {math.random(100, 255), math.random(100, 255), math.random(100, 255)};
	trails = {};
}


function play:init()
	self.model = model_viewer:new(love.filesystem.newFile("bike.png"))
	return play
end

local time = 0
local ctime = 0
function play:update(dt)
	time = time + dt
	ctime = ctime + dt
	if time > 0.01 then
		time = 0
		table.insert(self.trails, {
		             model = model_viewer:new(love.filesystem.newFile("trail.png"));
		             x = self.x - (math.cos(math.rad(self.rotation-90)) * 16);
		             y = self.y + 16 - (math.sin(math.rad(self.rotation-90)) * 16);
		             color = {self.color[1], self.color[2], self.color[3]};
		             timer = 0;
		             })
		self.trails[#self.trails].model.rotation = self.rotation 
	end

	if love.keyboard.isDown("d") then self.rotation = self.rotation + 300*dt end
	if love.keyboard.isDown("a") then self.rotation = self.rotation - 300*dt end

	self.x = self.x + math.cos(math.rad(self.rotation-90)) * 250*dt
	self.y = self.y + math.sin(math.rad(self.rotation-90)) * 250*dt

	self.model.rotation = self.rotation
	self.model.zoom = 0.5
end

function play:draw()
	lg.clear(25, 25, 25)
	for i,v in ipairs(self.trails) do
		v.timer = v.timer + love.timer.getDelta()
		lg.setColor(v.color[1], v.color[2], v.color[3], 255-255*(v.timer/3))
		v.model:drawModel(v.x, v.y)
		if v.timer > 3 then
			v.timer = 3
			table.remove(self.trails, i)
		end

		-- Do collision detection
		local x1,y1 = v.x - math.cos(math.rad(v.model.rotation-90))*4, v.y - math.sin(math.rad(v.model.rotation-90))*4
		local x2,y2 = v.x + math.cos(math.rad(v.model.rotation-90))*4, v.y + math.sin(math.rad(v.model.rotation-90))*4
		local p1,p2 = self.x - (math.cos(math.rad(self.rotation-90)) * 16), self.y + 16 - (math.sin(math.rad(self.rotation-90)) * 16)
		local p3,p4 = self.x + (math.cos(math.rad(self.rotation-90)) * 16), self.y + 16 + (math.sin(math.rad(self.rotation-90)) * 16)
		lg.setColor(255, 0, 0, 255)
		lg.line(x1, y1, x2, y2)
		if checkIntersect({x=x1,y=y1}, {x=x2, y=y2}, {x=p1, y=p2}, {x=p3, y=p4}) and v.timer > 1 then
			self.x = 100
			self.y = 100
		end
	end

	table.sort(self.trails, function(a,b) return a.y < b.y end)
	lg.setColor(self.color)
	self.model:drawModel(self.x, self.y)
end


return play:init()