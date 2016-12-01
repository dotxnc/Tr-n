local sock = require ("lib.sock")
local player = require ("entities.player")

local players = {}
local client = nil
local uniqueID = -1

function connect_client(ip, port)
	client = sock.newClient(ip, port)
	client:connect()

	client:on("connect", function(data)
	          client:emit("login", "Lumaio")
	          end)
	client:on("uniqueID", function(data)
	          uniqueID = data
	          end)
	client:on("newplayer", function(data)
	          table.insert(players, {player=player:new(data.x, data.y, data.name), uid=data.uid})
	          end)
	client:on("playerpos", function(data)

	          end)
end

function update_client()
	if client then client:update() end
end

function getplayers_client()
	return players
end
