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
globaltrails = nil;
globalProjectiles = nil;
localplayer = player:new(100, 100, "Lumaio")
localplayer.isLocalPlayer = true

function play:init()
	globaltrails = skiplist.new(512)
	globalProjectiles = skiplist.new(512)
	return play
end

function play:update(dt)
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

	-- trails
	for i,v in globaltrails:ipairs() do
		v.timer = v.timer + love.timer.getDelta()

		if v.timer < 2.8 then
			v.alpha = lerp(255, v.alpha, 0.98)
		else
			v.alpha = lerp(0, v.alpha, 0.5)
		end

		lg.setColor(v.color[1], v.color[2], v.color[3], v.alpha)
		trail.rotation = v.rotation
		trail:drawModel(v.x, v.y)

		if v.timer > 3 then
			v.timer = 3
			globaltrails:delete(v)
		end
	end

	-- projectiles
	for i,v in globalProjectiles:ipairs() do
		if v.isProjectile then
				v.timer = v.timer + love.timer.getDelta()
			v.x = v.x + (math.cos(math.rad(v.rotation-90)) * 6);
			v.y = v.y + (math.sin(math.rad(v.rotation-90)) * 6);
			trail.rotation = v.rotation
			trail:drawModel(v.x, v.y)

			if v.timer > 3 then
				v.timer = 3
				globalProjectiles:delete(v)
			end
		end
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
	lg.print(globaltrails.size, 0, 20)
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