
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
    showDialogTip(msg,{"确定"},function ( flag )
		NetManager.close()
		display.replaceScene(require("app.scenes.LoginScene").new(self.data))
	end)
end

function ParseSocket:init(socketEvent)
	self.socketEvent = socketEvent

    -- self.tid = self:heart()

	socketEvent:addEventListener("closed", function(event)
		self.neddHeart = false
		if not USER.relogin then
			self:reCon()
		end
	end)
	socketEvent:addEventListener("close", function(event)
		self.neddHeart = false
	end)
	socketEvent:addEventListener("failure", function(event)
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
	data.seatid = CONFIG.seat[data.seatid]
	self.socketEvent:dispatchEvent({name = cmd,data = {data}})
end

--推送房间里玩家信息
function ParseSocket:fun1002(packet ,cmd)
	local data = {}
	local status = packet:readInt()
	local num = packet:readInt()
	for i=1,num do
		data[i] = {	
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
			score =  packet:readLongInt(),
			playNum =  packet:readInt(),
			winNum =  packet:readInt(),
			goldRank =  packet:readInt(),
			winRank =  packet:readInt(), --赢点排名

			giftPcate = packet:readInt(),
			giftFrame = packet:readInt(),
			banned = packet:readInt(),
		}
		data[i].seatid = CONFIG.seat[data[i].seatid]
		data[i].status = status
	end
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
		data.seatid = CONFIG.seat[data.seatid]
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
	data.seatid = CONFIG.seat[data.seatid]
	dump(data)
	self.socketEvent:dispatchEvent({name = cmd,data = data})
end

--谁抢到了庄
function ParseSocket:fun1104(packet ,cmd)
	local data = {
		dealer = packet:readInt(),
		bei = {}
	}
	data.dealer = CONFIG.seat[data.dealer]
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
		data.seatid = CONFIG.seat[data.seatid]
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
	data.seatid = CONFIG.seat[data.seatid]
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
		dump(data[i])
		data[i].seatid = CONFIG.seat[data[i].seatid]
	end
	dump(data)
	self.socketEvent:dispatchEvent({name = cmd,data = data})
end

--重连 房间数据
function ParseSocket:fun1109(packet ,cmd)
	local data = {
		roomStatus = packet:readInt(),
	}
	if data.roomStatus ~= 1 then
		return
	end
	data.dealer = packet:readInt()
	data.dealer = CONFIG.seat[data.dealer]
	data.dealer = data.dealer or 0
	data.gameStatus = packet:readInt()
	data.seats = {}
	local num = packet:readInt()
	for i=1,num do
		data.seats[i] = {
			seatid = packet:readInt(),
			qiang = packet:readInt(),
			bei = packet:readInt(),
			isShowCard = packet:readInt(),
		}
		data.seats[i].seatid = CONFIG.seat[data.seats[i].seatid]
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
	display.replaceScene(require("app.scenes.GameScene").new())
end

--退出房间
function ParseSocket:fun1004(packet ,cmd)
	local data = {
		mid = packet:readInt()
	}
	dump(data)
	self.socketEvent:dispatchEvent({name = cmd,data = data})
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
			showDialogTip("服务器维护中，请稍后！",{"确定"},function ( flag )
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


-- --任务数据推送
function ParseSocket:fun1036(packet,cmd)
	local data = {
		online_time = packet:readInt(),
		reward_frequency = packet:readInt(),
		-- hot_online_time = packet:readInt(),
		-- hot_reward_frequency = packet:readInt(),
	}
	
	CONFIG.MISSION_COM = data
	if data.reward_frequency > 0 or data.hot_reward_frequency > 0 then
		self.socketEvent:dispatchEvent({name = 1053,data = {status = 1}})
	end
end 

--任务数据
function ParseSocket:fun1201(packet,cmd)
	local data = {}
	local num = packet:readInt()
	for i=1,num do
		data[i] = {
			pcate = packet:readInt(),
			pframe = packet:readInt(),
			status = packet:readInt(), --0未完成 1完成 2领取过奖励
			comNum = packet:readInt()
		}
		if CONFIG.task[data[i].pcate..data[i].pframe] then 
			CONFIG.task[data[i].pcate..data[i].pframe].status = data[i].status
			CONFIG.task[data[i].pcate..data[i].pframe].comNum = data[i].comNum --完成的次数，时间任务就是已经完成的时间（已经过了的时间）
		end
	end
	dump(data)
	self.socketEvent:dispatchEvent({name = cmd,data = data})
end
--任务完成推送
function ParseSocket:fun1202(packet,cmd)
	local data = {
		pcate = packet:readInt(),
		pframe = packet:readInt(),
		status = packet:readInt(), --0未完成 1完成 2领取过奖励
		comNum = packet:readInt()
	}
	if CONFIG.task[data.pcate..data.pframe] then
		CONFIG.task[data.pcate..data.pframe].status = data.status
		CONFIG.task[data.pcate..data.pframe].comNum = data.comNum
	end
	
	self.socketEvent:dispatchEvent({name = cmd,data = data})
	if data.status > 0 then
		utils.playSound("mis-com-tip")
		if data.pcate == 11 then
			app:dispatchEvent({name = "app.updateTask",{status = 0}})
		end
	end
end

--广播系统消息
function ParseSocket:fun2002(packet,cmd)
	--type 0，房间聊天 1，喇叭 2，系统消息
	local data = {	
		_type = packet:readInt(),
		mid = packet:readInt(),
		name = packet:readString(),
		msg = packet:readString(),
	}
	dump(data)
	self.socketEvent:dispatchEvent({name = cmd,data = data})
end


--聊天
function ParseSocket:fun2001(packet,cmd)
	local data = {
		err = packet:readInt(), --0，成功 1，失败
		time = packet:readInt(), --还有多少秒可以发消息
	}
	
	if  data.time > 0 then
		showAutoTip("您被禁言了",{"确定"})
	end
end

--表情
function ParseSocket:fun1032(packet,cmd)
	local data = {
		mid = packet:readInt(),
		pcate =  packet:readInt(),
		pframe =  packet:readInt(),
	}
	
	dump(data)
	self.socketEvent:dispatchEvent({name = cmd,data = data})
end

return ParseSocket

