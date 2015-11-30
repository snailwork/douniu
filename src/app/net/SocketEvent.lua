local SocketEvent = class("SocketEvent")

local REQ_REQUEST = 0    -- 读包头
local REQ_BODY = 2       -- 读包数据
local REQ_DONE = 3       -- 完成 
local PACKET_HEADER_SIZE = 6 -- 头部6字节
local PACKET_BUFFER_SIZE = 1024*16 -- 最大接收buf

-- local SocketTCP = require("framework.cc.net.SocketTCP")
local ByteArray = require("app.net.MyByteArray")


local function getcmd(self)
    self.readPacket:setPos(5)
    return self.readPacket:readShort()
end

local function getbodylen(self)
    self.readPacket:setPos(3)
    return self.readPacket:readShort()
end

local function reset(self)
    self.nStatus = REQ_REQUEST
    self.nBodyLen = 0
    self.readPacket = ByteArray.new(ByteArray.ENDIAN_LITTLE)
end

local function parse_body(self)
    if self.buf:getAvailable() < self.nBodyLen then
        return false
    end
    if self.nBodyLen ~= 0 then
        self.buf:readBytes(self.readPacket, self.readPacket:getLen() + 1, self.nBodyLen - 1)
    end
    return true
end

local function read_header(self)
    if self.buf:getAvailable() < PACKET_HEADER_SIZE then
        return false
    end
    self.buf:readBytes(self.readPacket, 1, 1)
    self.readPacket:setPos(1)
    local qs = self.readPacket:readShort()
    -- print("QS = %d", qs) --QS 读short的话 21329
    if qs ~= 21329 then
        return false
    end
    self.buf:readBytes(self.readPacket, self.readPacket:getLen() + 1, PACKET_HEADER_SIZE-3)
    self.nBodyLen = getbodylen(self) 
    -- print(string.format("SERVERDebug  recv cmd=%d,len=%d", getcmd(self), self.nBodyLen))
    if self.nBodyLen >= 0 and self.nBodyLen < (PACKET_BUFFER_SIZE - PACKET_HEADER_SIZE) then
        return true
    end
    return false
end

local loopParse 
    loopParse= function(self)
    if not self.socket.isConnected then
        return
    end
    -- 读头
    if (self.nStatus == REQ_REQUEST) then
        if not read_header(self) then
            reset(self)
            if self.buf:getAvailable() >= PACKET_HEADER_SIZE then
                loopParse(self)
            end
            return
        end
        self.nStatus = REQ_BODY
    end

    -- 包体
    if self.nStatus == REQ_BODY then
        if not parse_body(self) then
            return
        end
        self.nStatus = REQ_DONE
    end

    -- 完成向外派发事件并继续读取
    if self.nStatus == REQ_DONE then
        self:processServerMsg()
        reset(self)
        loopParse(self)
    end
end


function SocketEvent:ctor()
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    -- 当前读取的状态
    self.nStatus = REQ_REQUEST
    -- 包体的长度
    self.nBodyLen = 0
    -- 接收缓冲区
    self.buf = ByteArray.new(ByteArray.ENDIAN_LITTLE)
    -- 读取包
    self.readPacket = ByteArray.new(ByteArray.ENDIAN_LITTLE)
    self.socket = nil
end

function SocketEvent:init( host,pot,__retryConnectWhenFailure)
	local socket = SocketTCP.new(host, pot, __retryConnectWhenFailure)
    self.socket = socket
    socket:addEventListener(SocketTCP.EVENT_CONNECTED, handler(self, self.onConnect))
    socket:addEventListener(SocketTCP.EVENT_CLOSE, handler(self, self.onClose))
    socket:addEventListener(SocketTCP.EVENT_CLOSED, handler(self, self.onClosed))
    socket:addEventListener(SocketTCP.EVENT_CONNECT_FAILURE, handler(self, self.onConnectFailure))
    socket:addEventListener(SocketTCP.EVENT_DATA, handler(self, self.onData))
    socket:connect()
    
end

-- function SocketEvent:connect(host,pot,__retryConnectWhenFailure)
--     self.socket.__host = host
--     self.socket.__port = pot
--     self.socket.__retryConnectWhenFailure = __retryConnectWhenFailure
--     self.socket:connect()
-- end


function SocketEvent:removeEvent()
    self.socket:removeEventListenersByEvent(SocketTCP.EVENT_CONNECTED)
    self.socket:removeEventListenersByEvent(SocketTCP.EVENT_CLOSE)
    self.socket:removeEventListenersByEvent(SocketTCP.EVENT_CLOSED)
    self.socket:removeEventListenersByEvent(SocketTCP.EVENT_CONNECT_FAILURE)
    self.socket:removeEventListenersByEvent(SocketTCP.EVENT_DATA)
end

function SocketEvent:close()
    if self.socket ~= nil then
        self.socket:close()
        
    end
end

function SocketEvent:send(packet)
    if not self.socket or not self.socket.tcp then
        print("connection not exist")
        return
    end
    if self.socket.isConnected then

        self.socket:send(packet:getPack())
    end
end

function SocketEvent:onClose(__event)
    print(__event.target.host .."  --- socket status: ".. __event.name)
    self:dispatchEvent({name = "close"})
    
end

function SocketEvent:onClosed(__event)
    print("onClosed --> socket status: ".. __event.name)
    self:dispatchEvent({name = "closed"})
    self.socket = nil
end

function SocketEvent:onConnectFailure(__event)
    SocketEvent.contented = false
    print("socket status: ".. __event.name)
    self:dispatchEvent({name = "failure"})
end

function SocketEvent:onConnect(__event)
    print("socket status: ".. __event.name)
    --保持一个先连接上的，其它的关闭
    if SocketEvent.contented then
        self:close()
        self:removeEvent()
    else
        self:dispatchEvent({name = "contented"})
        SocketEvent.contented = true
    end

end

function SocketEvent:onData(__event)
    -- dump(__event)
    local oldPos = 1
    if self.buf:getAvailable() == 0 then
        self.buf = ByteArray.new(ByteArray.ENDIAN_LITTLE)
        self.buf:setPos(1)
    else
        oldPos =  self.buf:getPos()
        self.buf:setPos(#self.buf._buf + 1)
    end
    self.buf:writeBuf(__event.data)
    self.buf:setPos(oldPos)
    loopParse(self)
end

--解析接收报文
function SocketEvent:processServerMsg()
    self.readPacket:setPos(1)
    local packet = self.readPacket
    self:dispatchEvent({name = "onServerData", data= packet})
end

return SocketEvent
