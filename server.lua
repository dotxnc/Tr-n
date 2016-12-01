local sock = require ("lib.sock")
local player = require ("entities.player")

local clients = {}
local server = nil

function start_server(port)
	server = sock.newServer("*", port)

	server:on("connect", function() print("client connected") end)
	server:on("login", function(data, client)
	          local pd = {player=player:new(math.random(0, 1280), math.random(0, 720), data), client=client, uid=#clients+1}
	          table.insert(clients, pd)
	          client:emit("uniqueID", #clients)
	          --client:emit("newplayer", {x=pd.player.x, y=pd.player.y, name=pd.player.name, uid=pd.uid})

	          for i,v in ipairs(clients) do
	          	if v.client ~= client then
	          		v.client:emit("newplayer", {x=v.player.x,y=v.player.y,name=v.player.name,uid=v.uid})
	          	end
	          end
	          print("FUUUUUUCK")
	          server:log("info", "player created with uid " .. pd.uid)
	          end)
end

function update_server()
	if server then server:update() end
end
