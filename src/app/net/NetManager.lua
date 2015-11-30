
NetManager = class("NetManager")
SocketEvent = require("app.net.SocketEvent")

--连接3个socket，保持一个先连接上的，其它的关闭
function NetManager.connectToServer()
	SocketEvent.contented = false
	local parseSocket
	if not NetManager.parseSocket then
		SendCMD = SendCMD.new()
		parseSocket = ParseSocket.new()
		NetManager.parseSocket = parseSocket
	else
		parseSocket = NetManager.parseSocket
	end
	local sockets = {}
	for i=2,#CONFIG.server do
		scheduler.performWithDelayGlobal(function ( ... ) --异步去连接，只使用最快连接上的那个socket
			sockets[i-1] = SocketEvent.new()
			sockets[i-1]:init(CONFIG.server[i],CONFIG.port[i],false)
			sockets[i-1]:addEventListener("contented", function(event)
				if not SocketEvent.contented then
					NetManager.socketEvent = sockets[i-1]
					--初始化发送和解释socket
					parseSocket:init(sockets[i-1])
					SendCMD:init(sockets[i-1])
					SendCMD:sendToQQServer()
					SendCMD:login()
				else
					sockets[i-1] = nil
				end
			end)
		end,0)
	end
end

function NetManager.close()

	if NetManager.socketEvent == nil then
		return
	end

	NetManager.socketEvent:close()
	NetManager.parseSocket:removeEvent()
end

function NetManager.addEvent(cmd,fun)
	NetManager.socketEvent:addEventListener(cmd.."",fun)
end

function NetManager.removeEvent(cmd)
	NetManager.socketEvent:removeEventListenersByEvent(cmd.."")
end

return NetManager