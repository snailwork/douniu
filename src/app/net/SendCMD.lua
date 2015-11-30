SendCMD = class("SendCMD")

function SendCMD:ctor()
end

function SendCMD:init(socket)
	self.socket = socket
end 

-------------发给qq服务器的固定字符串-----------------------------------------------------------------

function SendCMD:sendToQQServer()
    local qq_server_str = "tgw_l7_forward\r\nHost:"..CONFIG.server[1]..":"..CONFIG.port[1].."\r\n\r\n"

    local packet = ByteArray.new()
    packet:writeBuf(qq_server_str)
    self.socket:send(packet)
end

function SendCMD:heart()
    local packet = ByteArray.new()
    packet:Begin(CMD.HEART)
    packet:End()
    self.socket:send(packet)
end

--登陆 
------------------------------------------------------------------------------
function SendCMD:login()
    local packet = ByteArray.new()
    packet:Begin(CMD.LOGIN)
    packet:writeInt(USER.mid)
    packet:writeString(USER.sessionKey)
    packet:End()
    self.socket:send(packet)
end

-------------------------------游戏房间中的命令-----------------------------------------------
--快速开始 进入房间
function SendCMD:quickInRoom(server_id,typeId)
    local packet = ByteArray.new()
    packet:Begin(CMD.IN_ROOM)
    packet:writeInt(server_id)
    packet:writeInt(typeId)
    packet:End()
    self.socket:send(packet)
end

--用户请求离开房间
function SendCMD:outRoom()
    -- utils.callStaticMethod("MyGotye","outRoom",nil,nil,"()V")
    local packet = ByteArray.new()
    packet:Begin(CMD.OUT_ROOM)
    packet:End()
    self.socket:send(packet)
end
--抢庄 1103
function SendCMD:qiangZhuang(data)
    local packet = ByteArray.new()
    packet:Begin(CMD.QIANG_ZHUANG)
    packet:writeInt(data.qiang)
    packet:End()
    self.socket:send(packet)
          
end

--用户下注倍数 1105
function SendCMD:bei(data)
    local packet = ByteArray.new()
    packet:Begin(CMD.BEI)
    packet:writeInt(data.bei)
    packet:End()
    self.socket:send(packet)
          
end
--1107 牌型
function SendCMD:niu(data)
    dump(data)
    local packet = ByteArray.new()
    packet:Begin(CMD.SHOW_CARD)
    for k,v in pairs(data.cards) do
        packet:writeString(v)
    end
    packet:writeInt(data.ctype)
    packet:End()
    self.socket:send(packet)
          
end
--_type 0 ,表示使用互动道具
--用户使用互动道具 
function SendCMD:useProps(data)
    local packet = ByteArray.new()
    packet:Begin(CMD.CLEINT_REQUEST_USE_PROPERTY)
    packet:writeInt(data.mid)
    packet:writeInt(data.pcate)
    packet:writeInt(data.pframe)
    packet:writeInt(data._type)
    packet:End()
    self.socket:send(packet)
end

function SendCMD:addFriend(data)
    local packet = ByteArray.new()
    packet:Begin(CMD.CLEINT_RESPONSE_ADD_FRIEND)
     packet:writeInt(data.mid)
    packet:End()
    self.socket:send(packet)
end

function SendCMD:getCardHistory()
    local packet = ByteArray.new()
    packet:Begin(CMD.CLIENT_REQUEST_CARD_HISTORY)
    packet:End()
    self.socket:send(packet)
end

function SendCMD:buying(buying)
    local packet = ByteArray.new()
    packet:Begin(CMD.CLIENT_REQUES_BUY_CHIPS)
    packet:writeInt(buying)
    packet:End()
    self.socket:send(packet)
end

function SendCMD:misson()
    local packet = ByteArray.new()
    packet:Begin(CMD.MISSION_COM_STATUS)
    packet:End()
    self.socket:send(packet)
end

function SendCMD:saveBuying(chip)
    local packet = ByteArray.new()
    packet:Begin(CMD.CLEINT_SAVE_BUYING)
    packet:writeInt(chip)
    packet:End()
    self.socket:send(packet)
end


-------------------------------游戏房间中的命令-----------------------------------------------

------------------------------聊天命令--------------------------
--表情
function SendCMD:sendFace(data)
    
    local packet = ByteArray.new()
    packet:Begin(CMD.CLIENT_REQUEST_USE_FACE)
    packet:writeInt(data.pcate)
    packet:writeInt(data.pframe)
    packet:End()
    self.socket:send(packet)
end
--聊天
function SendCMD:sendChat(data)
    
    local packet = ByteArray.new()
    packet:Begin(CMD.CLIENT_REQUEST_CHAT_MESSAGE)
    packet:writeString(data.msg)
    packet:writeInt(data._type)
    packet:End()
    self.socket:send(packet)
end



---

-------------------------------游戏大厅的命令-----------------------------------------------

--购买礼物
--mid 等于自己的mid 就是购买礼物给自己， 是别人的mid 就是购买礼物送给别人
-- pcate ＝ 2  and pframe ＝ 3  是银行， 购买此礼物表示开通银行
function SendCMD:buyGift(data)
    
    data.num = data.num or 1
    local packet = ByteArray.new()
    packet:Begin(CMD.CLIENT_REQUEST_PRESENT_GIFT)
    packet:writeInt(data.mid)
    packet:writeInt(data.pcate)
    packet:writeInt(data.pframe)
    packet:writeInt(data.num)
    packet:End()
    self.socket:send(packet)  
end

--存钱   筹码
function SendCMD:saveChip(data) 
    
    local packet = ByteArray.new()
    packet:Begin(CMD.BANK_SAVE_MONEY)
    packet:writeInt(data.chip)
    packet:End()
    self.socket:send(packet)
end

--取钱   筹码 ， 密码
function SendCMD:takeChip(data)
    
    local packet = ByteArray.new()
    packet:Begin(CMD.BANK_TAKE_MONEY)
    packet:writeInt(data.chip)
    packet:writeString(data.pass)
    packet:End()
    self.socket:send(packet)
end

--转账    对方mid ， 筹码 ， 密码
function SendCMD:turnChip(data)
    
    local packet = ByteArray.new()
    packet:Begin(CMD.BANK_TURN_MONEY)
    packet:writeInt(data.mid)
    packet:writeInt(data.chip)
    packet:writeString(data.pass)
    packet:End()
    self.socket:send(packet)
end

--修改银行密码
function SendCMD:changeBankPassWord(data)
    -- body
    
    local packet = ByteArray.new()
    packet:Begin(CMD.CLIENT_REQUES_UPDATE_PASSWD)
    packet:writeString(data.old)
    packet:writeString(data.new)
    packet:End()
    self.socket:send(packet)
end

--使用道具(礼物)
function SendCMD:useProp(data)
    
    local packet = ByteArray.new()
    packet:Begin(CMD.CLEINT_REQUEST_USE_PROPERTY)
    packet:writeInt(data.mid)
    packet:writeInt(data.pcate)
    packet:writeInt(data.pframe)
    packet:writeInt(data.type)
    packet:End()
    self.socket:send(packet)
end

function SendCMD:bindUser(data)
    
    local packet = ByteArray.new()
    packet:Begin(CMD.BIND_USER_AND_UPDATE_UICON)
    packet:writeString(data.name)
    packet:writeString(data.icon)
    packet:End()
    self.socket:send(packet)
end


function SendCMD:giftChips(data)
    local packet = ByteArray.new()
    packet:Begin(CMD.CLIENT_REQUEST_GIFT_CHIPS)
    packet:writeInt(data.mid)
    packet:writeInt(data.chips)
    packet:End()
    self.socket:send(packet)
end

function SendCMD:sendHongBao(data)
    local packet = ByteArray.new()
    packet:Begin(CMD.CLIENT_SEND_HONGBAO)
    -- packet:writeInt(data.type)
    packet:writeInt(data.chips)
    packet:writeInt(data.num)
    packet:writeString("")
    packet:End()
    self.socket:send(packet)
end

function SendCMD:getHongBao(id)
    local packet = ByteArray.new()
    packet:Begin(CMD.CLIENT_GET_HONGBAO)
    packet:writeString(id)
    packet:End()
    self.socket:send(packet)
end


return SendCMD