local model_viewer = require ("lib.voxel.model_viewer")
local skiplist = require ("lib.skiplist")
local socket = require ("socket")
local player = require ("entities.player")
local trail = model_viewer:new(love.filesystem.newFile("assets/trail.png"))
require ("server")
require ("client")
math.randomseed(socket.gettime()*1000)

local play = {
	model = nil;
	x = 100;
	y = 100;
	rotation = 0;
	color = {};
	dcolor = {};
	speed = 250;
	turnspeed = 350;
	output = {};
}
globaltrails = nil;

localplayer = player:new(100, 100, "Lumaio")
localplayer.isLocalPlayer = true

function play:init()
	globaltrails = skiplist.new(512)
	return play
end

function play:update(dt)
	update_client()
	update_server()

	localplayer:input(dt)
	localplayer:update(dt)

	for i,v in ipairs(getplayers_client()) do
		v.player:update(dt)
	end

	send_client("position", {x=localplayer.x, y=localplayer.y, rotation=localplayer.rotation})
end

function play:draw()
	if #self.output > 10 then table.remove(self.output, 1) end
	self.gracing = false
	lg.clear(10, 10, 10)
	for i,v in globaltrails:ipairs() do
		v.timer = v.timer + love.timer.getDelta()
		lg.setColor(v.color[1], v.color[2], v.color[3], 255-255*(v.timer/3))
		trail.rotation = v.rotation
		trail:drawModel(v.x, v.y)
		if v.timer > 3 then
			v.timer = 3
			globaltrails:delete(v)
		end
	end

	localplayer:draw()
	for i,v in ipairs(getplayers_client()) do
		v.player:draw()
	end
end

function play:drawus()
	localplayer:drawus()
	if server then lg.print("SERVER", 0, 50) end
	if client then lg.print("CLIENT", 0, 75) end
	for i,v in ipairs(getplayers_client()) do
		v.player:drawus()
	end
end

function play:keypressed(key)
	if key == "f1" then start_server(27015) end
	if key == "f2" then connect_client("localhost", 27015) end
end


return play:init()