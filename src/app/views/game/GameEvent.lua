local GameEvent = class("GameEvent")

function GameEvent:ctor(room)
	self.room = room

	local cmd = {
		CMD.IN_ROOM,
		CMD.OUT_ROOM,
		CMD.ROOM_ALL_USER,
		CMD.USER_IN_ROOM,
		CMD.GAME_START,
		CMD.WHO_GET_ZHUANG,
		CMD.SECOND_CARD,
		CMD.BEI,
		CMD.QIANG_ZHUANG,
		CMD.SHOW_CARD,
		CMD.RE_LOGIN_ROOMINOF,
		CMD.RE_LOGIN,
		CMD.GAME_OVER,
		CMD.CLIENT_REQUEST_USE_FACE,
		CMD.CHAT_MSG,
	}
	self.cmd = cmd
	
	for i,v in pairs(cmd) do
	 	NetManager.addEvent(v,handler(self,self["fun"..v]))
	end
end


-- 任务送数据
function GameEvent:fun1055(data)
	--如果界面是打开的，更新界面 
	for i,v in ipairs(data.data) do
		if self.room.parts["menu"] then
			if v.status == 1 and not table.indexof({11},v.pcate) then
				self.room.parts["menu"]:updateTask(1)
			elseif (v.pcate == 11 and CONFIG.MISSION_COM.reward_frequency > 0)  then
				self.room.parts["menu"]:updateTask(1)
			end
		end
	end
end

-- 任务推送数据
function GameEvent:fun1053(data)
	--如果界面是打开的，更新界面 
	-- dump(data.data)
	if data.data.status > 0 then
		self.room.parts["menu"]:updateTask(data.data.status)
	end
end

--表情
function GameEvent:fun1032(data)
	local data = data.data
	if data.mid ~= USER.mid then
		utils.playSound("msg")
	end
	for k,u in pairs(self.room.parts["seats"]) do
        if checkint(u.model.mid) == checkint(data.mid) then
            data.name = u.model.name
            break
        end
    end
    self.room.parts["chat-layer"]:addFace(data)
end

--广播系统消息
function GameEvent:fun2002(data)
	local data = data.data
	dump(data)
	if data._type == 2 or data._type == 1 then
		self.room.parts["sysMsg"]:addChatMsg(data)
	elseif data.mid ~= USER.mid then
		utils.playSound("msg")
	end
	self.room.parts["chat-layer"]:addMsg(data)
end

--其它玩家进入
function GameEvent:fun1002(data)
	local data = data.data
	dump(data)
	for i,v in ipairs(data) do
		self.room.parts["seats"][v.seatid]:sit(v)
	end
end

--其它玩家进入
function GameEvent:fun1005(data)
	self:fun1002(data)
end
--退出房间
function GameEvent:fun1004(data)
	local data = data.data
	if data.mid == USER.mid then
		display.replaceScene(require("app.scenes.RoomlistScene").new(self.data))
	else
		for i,v in ipairs(self.room.parts["seats"]) do
			if v.model.mid == data.mid then
				v:stand()
				break
			end
		end
	end
	self:exit()
	USER.seatid = nil
end
--进入房间
function GameEvent:fun1101(data)
	local data = data.data
	dump(data)
	USER.seatid = data.seatid
    local seats = self.room.parts["seats"]
    local seat3 = seats[3]--取出第3个位置 
    seats[3] = seats[data.seatid] --取出自己位置号的位置
    seats[3].model.seatid = 3 --把id设置为3
	dump(seats[3].model)

    seats[data.seatid] = seat3
	seat3:sit(USER)
	dump(seat3.model)
	
	self.room:stopAction(self.room.parts["delay-http"])
end

--游戏开始
function GameEvent:fun1102(data)
	local data = data.data
	--开始发牌
	self.room:startDealCard(data)
	self.room.gameStatus = 1
	dump(self.room.gameStatus)
end
--抢庄
function GameEvent:fun1103(data)
	self.room.parts["dealerData"] = self.room.parts["dealerData"] or {}
	local data = data.data
	table.insert(self.room.parts["dealerData"],data)
	-- dump(self.room.parts["dealerData"])
	self.room.parts["seats"][data.seatid]:qiangZhuangFun(data.qiang)
	if data.seatid == USER.seatid then
		self.room.parts["action"]:showQiangZhuang(false)
	end
end
--抢庄时间5秒 
--选择倍数5秒
--算点数时间10秒
--谁抢到了庄 
function GameEvent:fun1104(data)
	local data = data.data
	self.room:setDealer(data.dealer)
	self.dealer = data.dealer
	-- dump(self.dealer)
	for k,v in pairs(self.room.parts["seats"]) do --抢庄图标消失
		v.parts["qiangZhuang"]:setVisible(false)
	end

	if data.dealer ~= USER.seatid then
		table.sort(data.bei,function(a,b)
	        return a < b
	    end)
		dump(data.bei)
		self.room.parts["action"].parts["beiData"] = data.bei
		performWithDelay(self.room,function ( )
			self.room.parts["action"]:showBei(true)
			self.room.parts["clock"]:start(10,function ( )
				self.room.parts["action"]:showBei(false)
			end)
	    end,4)
	end
	self.room.parts["dealerData"] = {}
end

--倍数
function GameEvent:fun1105(data)
	local data = data.data
	self.room.parts["seats"][data.seatid]:changeBei(data.bei)
	if data.seatid == USER.seatid then
		self.room.parts["action"]:showBei(false)
	end
end

--发第二次牌
function GameEvent:fun1106(data)
	local data = data.data
	dump(data)
	dump(USER.seatid)
	self.room.parts["seats"][USER.seatid]:showCard(4,5,data)
	self.room.parts["action"]:showCalculate(true)
	self.room.parts["clock"]:start(10,function ( )
			self.room.parts["action"]:showCalculate(false)
		end)
end

--亮牌
function GameEvent:fun1107(data)
	local data = data.data
	dump(data,"",5)
	self.room.parts["seats"][data.seatid]:showCard(1,5,data.cards)
	self.room.parts["seats"][data.seatid]:showNiuType(data.ctype)
	if data.seatid == USER.seatid then
		self.room.parts["action"]:showCalculate(false)
	end
end

--游戏结束
function GameEvent:fun1108(data)
	local allData = data.data
	self.room.gameStatus = 0
	dump(self.room.gameStatus)
	self.room.parts["dealer"]:setOpacity(0)
	local toDealerData = {}
	local toIdleData = {}
	local dealer = self.dealer
	
	for i,v in ipairs(allData) do --分出需要移动金币到庄还是到闲家
		if v.seatid == dealer then

		else
			if v.win < 0 then
				table.insert(toDealerData,v)
			else
				table.insert(toIdleData,v)
			end
		end
		if v.seatid == checkint(USER.seatid) then --赢和输的
			self.room.parts["seats"][v.seatid]:showWinAnimation(v.win)
		end
	end
	local toIdle
	local toDealer
	local showWin
	toDealer = function ( data ) --先移动金币给庄家
		for i,v in ipairs(data) do
			self.room:moveToSeat(v.seatid,dealer,function (  )
				if #toIdleData > 0 then
					toIdle(toIdleData)
				else
					showWin()
				end
			end)
		end
	end

	toIdle = function ( data ) --再移动金币给闲家
		for i,v in ipairs(data) do
			self.room:moveToSeat(dealer,v.seatid,function (  )
				showWin()
			end)
		end
	end

	showWin = function ( ) --结算输赢 清理桌面 修改金币
		local seat
		for i,v in ipairs(allData ) do
			seat = self.room.parts["seats"][v.seatid]
			seat:reset()
			seat:showWin(v.win)
			seat:changeGold(v.gold)

		end
	end
	
	--移动金币开始
	performWithDelay(self.room,function ( )
		if #toDealerData > 0 then
			toDealer(toDealerData)
		else
			toIdle(toIdleData)
		end
	end,1.8)
	
end

--房间信息
function GameEvent:fun1109(data)
	local data = data.data
	local seats = self.room.parts["seats"]
	if data.roomStatus == 0 then
		for i,v in ipairs(seats) do
			v:reset()
		end
		return
	end
	self.room.gameStatus = data.gameStatus
	self.dealer = data.dealer
	dump(self.room.gameStatus)
	if data.dealer > 0 then
		local seat = seats[data.dealer]
		local dealer = self.room.parts["dealer"]
		dealer:setOpacity(255)
		self.room:setDealerPos(seat)
	end

	for i,v in ipairs(data.seats) do
		if data.gameStatus == 1 then
			if v.qiang == -1 then
				if v.seatid == USER.seatid then
					self.room.parts["action"]:showQiangZhuang(true)
					self.room.parts["clock"]:start(10,function ( )
                        self.room.parts["action"]:showQiangZhuang(false)
                    end)
				end
			else
				seats[v.seatid]:qiangZhuangFun(v.qiang)
			end
		end

		if data.gameStatus >= 2 then
			if v.seatid ~= data.dealer then
				if v.bei == 0 then
					if v.seatid == USER.seatid then
						self.room.parts["action"]:showBei(true)
						self.room.parts["clock"]:start(10,function ( )
							self.room.parts["action"]:showBei(false)
						end)
					end
				else
					seats[v.seatid]:changeBei(v.bei)
				end
			end
		end

		if data.gameStatus == 4 then
			if v.seatid == USER.seatid then
				if v.isShowCard == 0 then
					self.room.parts["action"]:showCalculate(true)
					self.room.parts["clock"]:start(10,function ( )
							self.room.parts["action"]:showCalculate(false)
						end)
				else
					--设置下牌型
					seats[v.seatid]:showNiuType(v.ctype)
				end
			elseif v.cards and #v.cards > 0 then
				seats[v.seatid]:showCard(1,#v.cards,v.cards)
				seats[v.seatid]:showNiuType(v.ctype)
			end
		end

	end

end

--重发的手牌
function GameEvent:fun1110(data)
	local data = data.data
	
	table.sort(data.bei,function(a,b)
        return a < b
    end)
	dump(data.bei)
	self.room.parts["action"].parts["beiData"] = data.bei
	self.room.parts["seats"][USER.seatid]:showCard(1,#data.cards,data.cards)
end



function GameEvent:exit( )
	for i,v in pairs(self.cmd) do
		NetManager.removeEvent(v)
	end
	self.room = nil
end

return GameEvent