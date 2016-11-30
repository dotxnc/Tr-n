local model_viewer = require ("lib.voxel.model_viewer")
local skiplist = require ("lib.skiplist")
local socket = require ("socket")
math.randomseed(socket.gettime()*1000)

local play = {
	model = nil;
	x = 100;
	y = 100;
	rotation = 0;
	color = {math.random(100, 255), math.random(100, 255), math.random(100, 255)};
	trails = nil;
}


function play:init()
	self.model = model_viewer:new(love.filesystem.newFile("assets/bike.png"))
	self.trails = skiplist.new(512)
	return play
end

local time = 0
local ctime = 0
function play:update(dt)
	time = time + love.timer.getDelta()
	ctime = ctime + love.timer.getDelta()
	if time > 0.02 then
		time = 0
		local trail = {
		             model = model_viewer:new(love.filesystem.newFile("assets/trail.png"));
		             x = self.x - (math.cos(math.rad(self.rotation-90)) * 16);
		             y = self.y + 16 - (math.sin(math.rad(self.rotation-90)) * 16);
		             color = {self.color[1], self.color[2], self.color[3]};
		             timer = 0;
		             id = #self.trails+1;
		             }
		trail.model.rotation = self.rotation 
		self.trails:insert(trail)
	end

	if love.keyboard.isDown("d") then self.rotation = self.rotation + 350*dt end
	if love.keyboard.isDown("a") then self.rotation = self.rotation - 350*dt end

	self.x = self.x + math.cos(math.rad(self.rotation-90)) * 250*dt
	self.y = self.y + math.sin(math.rad(self.rotation-90)) * 250*dt

	self.model.rotation = self.rotation
	self.model.zoom = 0.5

	if self.x+16 < 0 then self.x = WINDOW_W + 16 end
	if self.x-16 > WINDOW_W then self.x = -16 end
	if self.y+16 < 0 then self.y = WINDOW_H + 16 end
	if self.y-16 > WINDOW_H then self.y = -16 end
end

function play:draw()
	lg.clear(25, 25, 25)
	for i,v in self.trails:ipairs() do
		v.timer = v.timer + love.timer.getDelta()
		lg.setColor(v.color[1], v.color[2], v.color[3], 255-255*(v.timer/3))
		v.model:drawModel(v.x, v.y)
		if v.timer > 3 then
			v.timer = 3
			self.trails:delete(v)
		end

		-- Do collision detection
		local x1,y1 = v.x - math.cos(math.rad(v.model.rotation-90))*16, v.y - math.sin(math.rad(v.model.rotation-90))*16
		local x2,y2 = v.x + math.cos(math.rad(v.model.rotation-90))*16, v.y + math.sin(math.rad(v.model.rotation-90))*16
		local p1,p2 = self.x - (math.cos(math.rad(self.rotation-90)) * 16), self.y + 16 - (math.sin(math.rad(self.rotation-90)) * 16)
		local p3,p4 = self.x + (math.cos(math.rad(self.rotation-90)) * 16), self.y + 16 + (math.sin(math.rad(self.rotation-90)) * 16)
		if checkIntersect({x=x1,y=y1}, {x=x2, y=y2}, {x=p1, y=p2}, {x=p3, y=p4}) and v.timer > 1 then
			self.x = 100
			self.y = 100
		end
		
	end

	lg.setColor(self.color)
	self.model:drawModel(self.x, self.y)
end

function play:drawus()
	lg.setColor(255-self.color[1], 255-self.color[2]/2, 255-self.color[3]/2)
	lg.print("LUMAIO", math.floor(self.x)-lg.getFont():getWidth("LUMAIO")/2, math.floor(self.y)-32)
end


return play:init()