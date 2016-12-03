local model_viewer = require ("lib.voxel.model_viewer")
local skiplist = require ("lib.skiplist")
local socket = require ("socket")
local player = require ("entities.player")
local trail = model_viewer:new(love.filesystem.newFile("assets/trail.png"))
local imgui = require ("imgui")
require ("server")
require ("client")
math.randomseed(socket.gettime()*1000)

--- UI VARS
local ip = "localhost"
local port = "27015"
local playername = "Test"

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
globaltrails = {};
function rem(t) for i=1,#globaltrails do if globaltrails[i] == t then table.remove(globaltrails, i) end end end

localplayer = player:new(100, 100, "Lumaio")
localplayer.isLocalPlayer = true

local function sortz(a,b) if a.y < b.y then return true elseif a.y==b.y and a.id < b.id then return true else return false end end

function play:init()
	return play
end

function play:update(dt)
	table.sort(globaltrails, sortz)
	imgui.NewFrame()
	update_client()
	update_server()

	localplayer:input(dt)
	localplayer:update(dt)

	for i,v in ipairs(getplayers_client()) do
		v.player:update(dt)
	end

	--send_client("position", {x=localplayer.x, y=localplayer.y, rotation=localplayer.rotation})
end

function play:draw()
	if #self.output > 10 then table.remove(self.output, 1) end
	self.gracing = false
	lg.clear(10, 10, 10)
	for i,v in pairs(globaltrails) do
		v:update(love.timer.getDelta())
		v:draw()
	end

	localplayer:draw()
	for i,v in ipairs(getplayers_client()) do
		v.player:draw()
	end
end

function play:drawus()
	localplayer:drawus()
	for i,v in ipairs(getplayers_client()) do
		v.player:drawus()
	end

	lg.setColor(255, 255, 255)
	imgui.Text("FUCK", 10, 10)
	status, ip = imgui.InputText("IP", ip, 15)
	status, port = imgui.InputText("PORT", port, 6)
	status, playername = imgui.InputText("Player Name", playername, 32)
	if (imgui.Button("Start Server")) then start_server(tonumber(port)) end
	if (imgui.Button("Start Client")) then connect_client(ip, tonumber(port), playername) end

	imgui.Render()
	localplayer.name = playername
	lg.print(#globaltrails, 0, 20)
end

function play:mousepressed(x, y, b)
	imgui.MousePressed(b)
end

function play:mousereleased(x, y, b)
	imgui.MouseReleased(b)
end

function play:mousemoved(x, y)
	imgui.MouseMoved(x, y)
end

function play:keypressed(key)
	imgui.KeyPressed(key)
	--if key == "f1" then start_server(27015) end
	--if key == "f2" then connect_client("localhost", 27015) end
end

function play:keyreleased(key)
	imgui.KeyReleased(key)
end

function play:textinput(text)
	imgui.TextInput(text)
end


return play:init()