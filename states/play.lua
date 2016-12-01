local model_viewer = require ("lib.voxel.model_viewer")
local skiplist = require ("lib.skiplist")
local socket = require ("socket")
local player = require ("entities.player")
local sock = require ("lib.sock")
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

local clients = {}
isserver = false
server = nil
client = nil

function start_server()
	server = sock.newServer("*", 27015)
	server:on("connect", function(data, client)
	          for i,v in ipairs(clients) do client:emit("newplayer") end
	          table.insert(clients, client)
	          print("server added new player")
	end)
	print("initialized server")
	isserver = true
end

function start_client()
	client = sock.newClient("localhost", 27015)
	client:on("connect", function(data) print("connected to server") end)
	client:on("disconnect", function(data) print("disconnected to server") end)
	client:on("newplayer", function(data) if not isserver then table.insert(clients, data) print("Client added new player") end end)
	client:connect()
	print("initialized client?")
end

function play:init()
	globaltrails = skiplist.new(512)
	return play
end

local time = 0
local ctime = 0
local rtime = 0
function play:update(dt)
	localplayer:input(dt)
	localplayer:update(dt)

	if server then server:update(dt) end
	if client then client:update(dt) end
end

function play:draw()
	if #self.output > 10 then table.remove(self.output, 1) end
	self.gracing = false
	lg.clear(10, 10, 10)
	for i,v in globaltrails:ipairs() do
		v.timer = v.timer + love.timer.getDelta()
		lg.setColor(v.color[1], v.color[2], v.color[3], 255-255*(v.timer/3))
		v.model:drawModel(v.x, v.y)
		if v.timer > 3 then
			v.timer = 3
			globaltrails:delete(v)
		end
	end

	localplayer:draw()
end

function play:drawus()
	localplayer:drawus()
end

function play:keypressed(key)
	if key == "f1" then start_server() end
	if key == "f2" then start_client() end
end


return play:init()