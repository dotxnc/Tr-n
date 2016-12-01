local sock = require ("lib.sock")
local player = require ("entities.player")

local players = {}
local client = nil
local uniqueID = -1

function connect_client(ip, port, name)
	client = sock.newClient(ip, port)
	client:connect()

	client:on("connect", function(data)
	          client:emit("login", name)
	          end)
	client:on("uniqueID", function(data)
	          uniqueID = data
	          end)
	client:on("newplayer", function(data)
	          if data.uid ~= uniqueID then
	          	table.insert(players, {player=player:new(data.x, data.y, data.name), uid=data.uid})
	          end
	          end)
	client:on("position", function(data)
	          for i,v in ipairs(players) do
	          	if v.uid == data.uid then
	          		v.player.nx = data.x
	          		v.player.ny = data.y
	          		v.player.rotation = data.rotation
	          	end
	          end
	          end)
end

function update_client()
	if client then client:update() end
end

function getplayers_client()
	return players
end

function send_client(event, data)
	if not client then return end
	data.uid = uniqueID
	client:emit(event, data)
end
