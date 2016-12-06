local lovox = require ("lib.lovox")
local ModelData = lovox.modelData

local wall = require ("entities.wall")
local projectile = require("entities.projectile")
local player = {
	x,y,color,dcolor,rotation=0,speed=250,turnspeed=350,model,name,time=0,ctime=0,rtime=0,gracing=false,nx=0,ny=0,lastShoot=0
}
--                RED          ORANGE         YELLOW         GREEN        BLUE         INDIGO        VIOLET
local rainbow = {{255, 0, 0}, {255, 127, 0}, {255, 255, 0}, {0, 255, 0}, {0, 0, 255}, {75, 0, 130}, {148, 0, 211}}
local rainbowindex = 1
player.__index = player


function player:input(dt)
	if love.keyboard.isDown("d") then self.rotation = self.rotation + self.turnspeed*dt end
	if love.keyboard.isDown("a") then self.rotation = self.rotation - self.turnspeed*dt end
	if love.mouse.isDown(1) and self.lastShoot > 0.25 and not require("imgui").GetWantCaptureMouse() then
		self.lastShoot = 0
		table.insert(globaltrails, projectile:new(self.x+2, self.y+16, self.rotation, { self.color[1], self.color[2], self.color[3] }, self, self.speed))
		send_client("shoot", {x=self.x+2, y = self.y+16, rotation=self.rotation, speed=self.speed}) -- this refuses to work wtf
	end
end


function player:update(dt)
	if self.speed > 650 then self.speed = 650 end
	self.time = self.time + dt
	self.ctime = self.ctime + dt
	self.lastShoot = self.lastShoot + dt;
	local spawntime = 0.1/(self.speed*1/60)
	if self.time > spawntime then
		self.time = 0
		table.insert(globaltrails, wall:new(self.x-(math.cos(math.rad(self.rotation-90))), self.y+16-(math.sin(math.rad(self.rotation-90))), self.rotation, {self.color[1], self.color[2], self.color[3]}, self))
	end

	if self.isLocalPlayer then
		self.x = self.x + math.cos(math.rad(self.rotation-90)) * self.speed*dt
		self.y = self.y + math.sin(math.rad(self.rotation-90)) * self.speed*dt
	else
		self.x = lerp(self.nx, self.x, 0.5)
		self.y = lerp(self.ny, self.y, 0.5)
	end

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

		self.color[1] = lerp(self.color[1], self.dcolor[1] , 0.1);
		self.color[2] = lerp(self.color[2], self.dcolor[2], 0.1);
		self.color[3] = lerp(self.color[3], self.dcolor[3], 0.1);
	end


		self.color[1] = lerp(self.color[1], self.color[1] -25 + math.sin(love.timer.getTime()) * 50, 0.1);
		self.color[2] = lerp(self.color[2], self.color[2] -25 + math.sin(love.timer.getTime()) * 50, 0.1);
		self.color[3] = lerp(self.color[3], self.color[3] -25 + math.sin(love.timer.getTime()) * 50, 0.1);

	if self.isLocalPlayer then send_client("position", {x=self.x, y=self.y, rotation=self.rotation, force=loop}) end
end

function player:draw()
	self.gracing = false
	lg.setColor(self.color)
	self.model.color = self.color
	self.model:draw(self.x+2, self.y+16, 1, math.rad(self.rotation), 1.5, 2)

	for i,v in ipairs(globaltrails) do
		-- Do collision detection
		lg.setColor(0, 255, 0)
		if self.isLocalPlayer then
			if v.owner == self and v.timer < 0.25 then goto skip end
			if math.dist(v.x, v.y, self.x, self.y) < 15 then
				local x1,y1 = v.x - math.cos(math.rad(v.rotation-90))*16, v.y - math.sin(math.rad(v.rotation-90))*16
				local x2,y2 = v.x + math.cos(math.rad(v.rotation-90))*16, v.y + math.sin(math.rad(v.rotation-90))*16
				local p1,p2 = self.x + 2 - (math.cos(math.rad(self.rotation-90)) * 16), self.y + 16 - (math.sin(math.rad(self.rotation-90)) * 16) -- back
				local p3,p4 = self.x + 2 + (math.cos(math.rad(self.rotation-90)) * 16), self.y + 16 + (math.sin(math.rad(self.rotation-90)) * 16) -- front
				if math.doLinesIntersect({x=x1,y=y1}, {x=x2, y=y2}, {x=p1, y=p2}, {x=p3, y=p4}) and v.timer > 0 then
					self.x = 100
					self.y = 100
					self.speed = 250
					self.turnspeed = 350
					send_client("position", {x=self.x, y=self.y, rotation=self.rotation, force=true})
				else
				end
			end
		end
		::skip::
		
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

	local p1,p2 = self.x + 2 - (math.cos(math.rad(self.rotation-90)) * 16), self.y + 16 - (math.sin(math.rad(self.rotation-90)) * 16) -- back
	local p3,p4 = self.x + 2 + (math.cos(math.rad(self.rotation-90)) * 16), self.y + 16 + (math.sin(math.rad(self.rotation-90)) * 16) -- front
	--lg.line(p1, p2, p3, p4)
end


function player:new(x, y, name)
	local new = setmetatable({}, player)

	new.x = x;
	new.y = y;
	new.name = name;
	new.model = lovox.model(lovox.modelData("assets/bike"))
	new.model.layer_spacing = 0.5
	new.color =  {rainbow[#rainbow][math.random(3)], rainbow[#rainbow][math.random(3)], rainbow[#rainbow][math.random(3)]};
	new.dcolor = {new.color[1], new.color[2], new.color[3]}
	return new
end

return player
