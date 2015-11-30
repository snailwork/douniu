
ParseSocket = class("ParseSocket")

function ParseSocket:ctor()

end

function ParseSocket:removeEvent()
	self.socketEvent:removeEventListenersByEvent("onServerData")
end

function ParseSocket:heart()
	return scheduler.scheduleGlobal(function()
		self.timeout_num = self.timeout_num or 0
		if not self.neddHeart then 
			self.timeout_num = 0
			if self.tid then
				scheduler.unscheduleGlobal(self.tid)
				self.tid = nil
			end
			return 
		end
        if self.timeout_num >= 5 then
        	self:reCon("连接超时，请重新连接")
        else
        	SendCMD:heart()
        	self.timeout_num = self.timeout_num + 1
        end
    end, 9)
end

function ParseSocket:reCon ( msg )
	msg = msg or "网络连接被断开，请重新登陆！"
	self.neddHeart = false
    showDialogTip("",msg,{"确定"},function ( flag )
		NetManager.close()
		SceneManager.switch("LoginScene")
	end)
end

function ParseSocket:init(socketEvent)
	self.socketEvent = socketEvent

    -- self.tid = self:heart()

	socketEvent:addEventListener("closed", function(event)
		dump(1111)
		self.neddHeart = false
		if not USER.relogin then
			self:reCon()
		end
	end)
	socketEvent:addEventListener("close", function(event)
		self.neddHeart = false
	end)
	socketEvent:addEventListener("failure", function(event)
		dump(222222)
		self:reCon()
	end)
			
	socketEvent:addEventListener("onServerData", function(event)
			local packet = event.data
			packet:setPos(1)
			local cmd = packet:getBeginCmd()
			if DEBUG > 0 and cmd > 0 then
				dump("cmd -----》》》  "..cmd)
			end
			if self["fun"..cmd] then
				self["fun"..cmd](self,packet,cmd)
			else
				if cmd == 10006 then
					self.timeout_num = 0
				else
					socketEvent:dispatchEvent({name = cmd})
					-- print("no this cmd "..cmd)
				end
			end
		end)  

end

-- function ParseSocket:readPlayer(packet)
-- 	return {
-- 		mid = packet:readInt(),
-- 		plaformid = packet:readInt(),
-- 		iconid = packet:readInt(),
-- 		sex = packet:readInt(),

-- 		name = packet:readString(),
-- 		icon = packet:readString(),

-- 		yellowVip =  packet:readInt(),
-- 		yearVip =  packet:readInt(),
-- 		vip =  packet:readInt(),
		
-- 		gold =  packet:readLongInt(),
-- 		score =  packet:readInt(),
-- 		playNum =  packet:readInt(),
-- 		winNum =  packet:readInt(),
-- 		goldRank =  packet:readInt(),
-- 		winRank =  packet:readInt(), --赢点排名

-- 		giftPcate = packet:readInt(),
-- 		giftFrame = packet:readInt(),
-- 		banned = packet:readInt(),
-- 	}
-- end

--玩家进入
function ParseSocket:fun1005(packet ,cmd)
	local data = {
		mid = packet:readInt(),
		plaformid = packet:readInt(),
		iconid = packet:readInt(),
		sex = packet:readInt(),

		name = packet:readString(),
		icon = packet:readString(),
		vip =  packet:readInt(),
		gold =  packet:readLongInt(),
		score =  packet:readLongInt(),
		playNum =  packet:readInt(),
		winNum =  packet:readInt(),
		goldRank =  packet:readInt(),
		winRank =  packet:readInt(), --赢点排名

		giftPcate = packet:readInt(),
		giftFrame = packet:readInt(),
		banned = packet:readInt(),

		yellowVip =  packet:readInt(),
		yearVip =  packet:readInt(),
		seatid = packet:readInt()
	}
	self.socketEvent:dispatchEvent({name = cmd,data = data})
end

--推送房间里玩家信息
function ParseSocket:fun1002(packet ,cmd)
	local data = {	
		status = packet:readInt(),
		round = packet:readInt(),
		seatid = packet:readInt(),

		mid = packet:readInt(),
		plaformid = packet:readInt(),
		iconid = packet:readInt(),
		sex = packet:readInt(),

		name = packet:readString(),
		icon = packet:readString(),

		yellowVip =  packet:readInt(),
		yearVip =  packet:readInt(),
		vip =  packet:readInt(),
		
		gold =  packet:readLongInt(),
		score =  packet:readInt(),
		playNum =  packet:readInt(),
		winNum =  packet:readInt(),
		goldRank =  packet:readInt(),
		winRank =  packet:readInt(), --赢点排名

		giftPcate = packet:readInt(),
		giftFrame = packet:readInt(),
		banned = packet:readInt(),
	}
	-- utils.__merge(data,self:readPlayer(packet))
	dump(data)
	-- app:dispatchEvent({name = cmd,data = data})
	self.socketEvent:dispatchEvent({name = cmd,data = data})
end

--进房间
function ParseSocket:fun1101(packet ,cmd)
	local data = {
		err = packet:readInt(),
		version = packet:readInt(),
		
	}
	if data.err == 0 then
		packet:readInt()
		data.seatid = packet:readInt()
		self.socketEvent:dispatchEvent({name = cmd,data = data})
	else
		showDialogTip("进入房间失败！",{"返回大厅"},function ( flag )
			display.replaceScene(require("app.scenes.HallScene").new())
			end)
	end
	dump(data)
end

--游戏开始
function ParseSocket:fun1102(packet ,cmd)
	local data = {
		packet:readString(),
		packet:readString(),
		packet:readString()
	}
	dump(data)
	self.socketEvent:dispatchEvent({name = cmd,data = data})
end

--抢庄
function ParseSocket:fun1103(packet ,cmd)
	local data = {
		seatid = packet:readInt(),
		qiang = packet:readInt(),
	}
	dump(data)
	self.socketEvent:dispatchEvent({name = cmd,data = data})
end

--谁抢到了庄
function ParseSocket:fun1104(packet ,cmd)
	local data = {
		dealer = packet:readInt(),
		bei = {}
	}
	dump(data)
	if data.dealer ~= checkint(USER.seatid) then
		for i=1,4 do
			data.bei[i] = packet:readInt()
		end
	end
	dump(data)
	self.socketEvent:dispatchEvent({name = cmd,data = data})
end

--倍数
function ParseSocket:fun1105(packet ,cmd)
	local data = {
		err = packet:readInt(),
		
	}
	if data.err == 0 then
		data.seatid = packet:readInt()
		data.bei = packet:readInt()
		self.socketEvent:dispatchEvent({name = cmd,data = data})
	end
	dump(data)
end

--发第二次牌
function ParseSocket:fun1106(packet ,cmd)
	local data = {
		packet:readString(),
		packet:readString()
	}
	dump(data)
	self.socketEvent:dispatchEvent({name = cmd,data = data})
end
--亮牌
function ParseSocket:fun1107(packet ,cmd)
	local data = {
		seatid = packet:readInt(),
		cards = {
			packet:readString(),
			packet:readString(),
			packet:readString(),
			packet:readString(),
			packet:readString()
		},
		ctype = packet:readInt()
	}
	dump(data)
	self.socketEvent:dispatchEvent({name = cmd,data = data})
end

--游戏结算
function ParseSocket:fun1108(packet ,cmd)
	local num = packet:readInt()
	local data = {}
	for i=1,num do
		data[i] = {
			seatid = packet:readInt(),
			win = packet:readLongInt(),
			gold = packet:readLongInt(),
		}
	end
	dump(data)
	self.socketEvent:dispatchEvent({name = cmd,data = data})
end

--重连 房间数据
function ParseSocket:fun1109(packet ,cmd)
	local data = {
		roomStatus = packet:readInt(),
	}
	dump(data)
	if data.roomStatus ~= 1 then
		return
	end
	data.dealer = packet:readInt()
	data.gameStatus = packet:readInt()
	data.seats = {}
	local num = packet:readInt()
	dump(num)
	for i=1,num do
		dump(i)
		data.seats[i] = {
			seatid = packet:readInt(),
			qiang = packet:readInt(),
			bei = packet:readInt(),
			isShowCard = packet:readInt(),
		}
		-- dump(data)
		if data.seats[i].isShowCard == 1 then
			data.seats[i].cards = {
				packet:readString(),	
				packet:readString(),
				packet:readString(),
				packet:readString(),
				packet:readString(),
			}
			data.seats[i].ctype = packet:readInt()
		end
		
	end
	dump(data)
	self.socketEvent:dispatchEvent({name = cmd,data = data})
end

--重连 用户数据
function ParseSocket:fun1110(packet ,cmd)
	local num = packet:readInt()
	local cards = {}
	local bei = {}
	for i=1,num do
		cards[i] = packet:readString()
	end
	num = packet:readInt()
	for i=1,num do
		bei[i] = packet:readInt()
	end
	local data = {
		cards = cards,
		bei= bei
	}
	dump(data)
	-- USER.reLoginCards = data
	self.socketEvent:dispatchEvent({name = cmd,data = data})
end
--重连进房间
function ParseSocket:fun1999(packet ,cmd)
	-- SendCMD:quickInRoom(1000)
end

--退出房间
function ParseSocket:fun1004(packet ,cmd)
	self.socketEvent:dispatchEvent({name = cmd})
end

--login
function ParseSocket:fun1000(packet ,cmd)
	local data = {err = packet:readInt()}
	USER.relogin = nil
	dump(data)
	if data.err ~= 0 then
		self.neddHeart =  false
		if data.err ==  3 then
			USER.relogin = true
		elseif data.err == 4 or data.err == 5 then
			--服务器停服
			showDialogTip("","服务器维护中，请稍后！",{"确定"},function ( flag )
				NetManager.close()
				SceneManager.switch("LoginScene")
			end)
			return
		end
		self:reCon(ERR_INFO["1000-"..data.err])
	else
		self.neddHeart =  true
	end
	app:dispatchEvent({name = "app.login",data = data})
end

return ParseSocket

