local model_viewer = require ("lib.voxel.model_viewer")

local player = {
	x,y,color,dcolor,rotation=0,speed=250,turnspeed=350,model,name,time=0,ctime=0,rtime=0,gracing=false,nx=0,ny=0
}
--                RED          ORANGE         YELLOW         GREEN        BLUE         INDIGO        VIOLET
local rainbow = {{255, 0, 0}, {255, 127, 0}, {255, 255, 0}, {0, 255, 0}, {0, 0, 255}, {75, 0, 130}, {148, 0, 211}}
local rainbowindex = 1
player.__index = player


function player:input(dt)
	if love.keyboard.isDown("d") then self.rotation = self.rotation + self.turnspeed*dt end
	if love.keyboard.isDown("a") then self.rotation = self.rotation - self.turnspeed*dt end
end

function player:update(dt)
	if self.speed > 550 then self.speed = 650 end
	self.time = self.time + love.timer.getDelta()
	self.ctime = self.ctime + love.timer.getDelta()
	local spawntime = 0.05/(self.speed*1/60)
	if self.time > spawntime then
		self.time = 0
		local trail = {
		             x = self.x - (math.cos(math.rad(self.rotation-90)) * 16);
		             y = self.y + 16 - (math.sin(math.rad(self.rotation-90)) * 16);
		             color = {self.color[1], self.color[2], self.color[3]};
		             timer = 0;
		             id = #globaltrails+1;
		             }
		trail.rotation = self.rotation 
		globaltrails:insert(trail)
	end

	if self.isLocalPlayer then
		self.x = self.x + math.cos(math.rad(self.rotation-90)) * self.speed*dt
		self.y = self.y + math.sin(math.rad(self.rotation-90)) * self.speed*dt
	else
		self.x = lerp(self.nx, self.x, 0.5)
		self.y = lerp(self.ny, self.y, 0.5)
	end

	self.model.rotation = self.rotation
	self.model.zoom = 0.5

	local loop = false
	if self.isLocalPlayer then
		if self.x+16 < 0 then self.x = WINDOW_W + 16 loop=true end
		if self.x-16 > WINDOW_W then self.x = -16 loop=true end
		if self.y+16 < 0 then self.y = WINDOW_H + 16 loop=true end
		if self.y-16 > WINDOW_H then self.y = -16 loop=true end

	end

	if self.gracing then
		self.rtime = self.rtime + dt
		self.color[1] = lerp(self.color[1], rainbow[rainbowindex][1], 0.1);
		self.color[2] = lerp(self.color[2], rainbow[rainbowindex][2], 0.1);
		self.color[3] = lerp(self.color[3], rainbow[rainbowindex][3], 0.1);
		if self.rtime > 0.1 then
			self.rtime = 0
			rainbowindex = rainbowindex+1
			if rainbowindex > 7 then rainbowindex = 1 end
		end
		self.speed = self.speed + 50*dt
		self.turnspeed = self.turnspeed + 50*dt
	else

		self.color[1] = lerp(self.color[1], self.dcolor[1], 0.1);
		self.color[2] = lerp(self.color[2], self.dcolor[2], 0.1);
		self.color[3] = lerp(self.color[3], self.dcolor[3], 0.1);
	end
	if self.isLocalPlayer then send_client("position", {x=self.x, y=self.y, rotation=self.rotation, force=loop}) end
end

function player:draw()
	self.gracing = false
	lg.setColor(self.color)
	self.model:drawModel(self.x, self.y)

	for i,v in globaltrails:ipairs() do
		-- Do collision detection
		lg.setColor(0, 255, 0)
		if self.isLocalPlayer then
			if math.dist(v.x, v.y, self.x, self.y) < 30 then
				local x1,y1 = v.x - math.cos(math.rad(v.rotation-90))*16, v.y - math.sin(math.rad(v.rotation-90))*16
				local x2,y2 = v.x + math.cos(math.rad(v.rotation-90))*16, v.y + math.sin(math.rad(v.rotation-90))*16
				local p1,p2 = self.x - (math.cos(math.rad(self.rotation-90)) * 10), self.y + 20 - (math.sin(math.rad(self.rotation-90)) * 10)
				local p3,p4 = self.x + (math.cos(math.rad(self.rotation-90)) * 10), self.y + 16 + (math.sin(math.rad(self.rotation-90)) * 10)
				lg.setColor(255, 0, 0)
				lg.line(p1, p2, p3, p4)
				if math.doLinesIntersect({x=x1,y=y1}, {x=x2, y=y2}, {x=p1, y=p2}, {x=p3, y=p4}) and v.timer > 0. then
					self.x = 100
					self.y = 100
					self.speed = 250
					self.turnspeed = 350
					send_client("position", {x=self.x, y=self.y, rotation=self.rotation, force=true})
				else
				end
			end
		end
		
		-- gracing
		if math.dist(self.x, self.y+8, v.x, v.y-8) <= 24 and v.timer > 0.5 then
			self.gracing = true
		end
	end

end

function player:drawus()

	lg.setColor(255-self.color[1], 255-self.color[2]/2, 255-self.color[3]/2)
	lg.print(self.name, math.floor(self.x)-lg.getFont():getWidth(self.name)/2, math.floor(self.y)-32)
	lg.print(self.speed, 0, 50)
end


function player:new(x, y, name)
	local new = setmetatable({}, player)

	new.x = x;
	new.y = y;
	new.name = name;
	new.model = model_viewer:new(love.filesystem.newFile("assets/bike.png"));
	new.color =  {math.random(100, 255), math.random(100, 255), math.random(100, 255)};
	new.dcolor = {new.color[1], new.color[2], new.color[3]}
	return new
end

return player
