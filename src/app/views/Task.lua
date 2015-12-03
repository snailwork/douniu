local Task = class("Task")

function Task:ctor(callback)
	self.callback = callback
	self.parts = {}
    self.parts["layer"] = cc.uiloader:load("task.csb")
        :addTo(display.getRunningScene(),100)
        :align(display.CENTER, display.cx, display.cy)

    local mask = self.parts["layer"]:getChildByTag(429)
    mask:setContentSize(display.width,display.height)
	mask:addTouchEventListener(function ( target,event )
		if event ~= 2 then return end
		utils.playSound("click")
		self:hide()
	end)

    self.parts["list-item"] = self.parts["layer"]:getChildByTag(19)
    self.parts["list-item"]:setVisible(false)

    -- self.parts["layer_panel"]:setTouchEnabled(false)
    self.parts["layer"]:getChildByTag(7):addTouchEventListener(function (target, event)
    	if event == 0 then
	        target:setScale(0.9)
	    elseif event == 3 or event == 2 then
	        target:setScale(1)
	    end
    	if event ~= 2 then return end
    	utils.playSound("click")
    	self:hide()
    end)
    
    self.parts["list"] = self.parts["layer"]:getChildByTag(18)
    self:init()
    NetManager.addEvent(1055,handler(self,self.init))
    SendCMD:misson()
end

function Task:hide(  )
	NetManager.removeEvent(1055)
	if self.parts["time-hander"] then
		scheduler.unscheduleGlobal(self.parts["time-hander"])
	end
	self.parts["time-hander"] = nil
	if self.callback then self.callback() end
	self.parts["layer"]:removeSelf()
	self.parts = nil
end

function Task:init()
	self.parts["time-items"] = {}
	local data = CONFIG.task
 	self.parts["list"]:removeAllChildren()
    local time
    
    local vals = {}
    local lastTime = {index = -1}
    for k,v in pairs(data) do
    	v.status = v.status or 0
    	if not vals[v.pcate..v.status] and v.status < 2 then
    		-- if v.pcate == 11 then
    		-- 	if CONFIG.MISSION_COM.reward_frequency > 0 then
    		-- 		v.status = 1
    		-- 	end
    		-- 	if v.status == 0 then
    		-- 		v.comNum = CONFIG.MISSION_COM.online_time
    		-- 		v.reward_frequency	= CONFIG.MISSION_COM.reward_frequency
    		-- 		vals[v.pcate..v.status] = v
    		-- 	else
	    	-- 		if v.pframe > lastTime.index then
	    	-- 			lastTime = v
	    	-- 			lastTime.comNum = CONFIG.MISSION_COM.online_time
	    	-- 			lastTime.reward_frequency	= CONFIG.MISSION_COM.reward_frequency
	    	-- 			lastTime.index = v.pframe
	    	-- 		end
	    	-- 	end
    		-- else
    			vals[v.pcate..v.status] = v
    		-- end
    	end
    end
    if not vals["110"] then
    	vals["111"] = lastTime
    end
	vals = table.values(vals)
	--完成的排前面
	table.sort(vals,function(a,b)
        return a.status > b.status
    end)

    -- dump(vals,"",5)
    self.vals = vals
    for k,v in pairs(vals) do
		v.comNum = v.comNum or 0 
		local item = self.parts["list-item"]:clone()
		item.data = v
		item:setVisible(true)
		item:getChildByTag(1):setString(v.name)
		item:getChildByTag(1):setFontName("Helvetica-Bold")
		item:getChildByTag(2):setString(v.dec)
		item:getChildByTag(4):setString("+"..utils.numAbbrZh(v.award))
		item:getChildByTag(6):setVisible(false)
		item:getChildByTag(38):setString("")
		local btn = item:getChildByTag(5)
		btn:setVisible(false)
		if v.subtype == 11 then

			time = v.needNum - v.comNum --还需要多少秒
			item.time = time
			
			if v.status == 0 and checkint(v.reward_frequency) <= 0 then
				local hour = checkint(time/3600)
				if hour <= 0 then
					hour = os.date("%M",time)..":"..os.date("%S",time)
				else
					hour = hour..":" .. os.date("%M",time)..":"..os.date("%S",time)
				end
				item:getChildByTag(38):setFontName("Helvetica-Bold")
				item:getChildByTag(38):setColor(cc.c3b(83,59,96))--cc.c3b(65,170,18)
				-- item:getChildByTag(38):setColor(cc.c3b(255,227,72))--cc.c3b(65,170,18)
				item:getChildByTag(38):setString(hour)
				table.insert(self.parts["time-items"],item)
			else
				btn:setVisible(true)
			end
		else
			if v.status == 0 then
				item:getChildByTag(6):setVisible(true)
				item:getChildByTag(38):setString(v.comNum.."/"..v.needNum)
				item:getChildByTag(6):getChildByTag(6):setPercent(checkint(v.comNum / v.needNum))
			else
				btn:setVisible(true)
			end
		end

		btn:addTouchEventListener(function (target,event )
			if event == 0 then
		        target:setScale(0.9)
		    elseif event == 3 or event == 2 then
		        target:setScale(1)
		    end
			if event ~= 2 then return true end
			utils.playSound("com-mis")
			utils.http(CONFIG.API_URL,
			{	
	    		method="Ahonor.jobDone",
	    		sesskey = USER.sessionKey,
		    	pcate = v.pcate,
		    	pframe = v.pframe,
			},function ( data )
				if data.svflag == 1 then
					if v.subtype == 11 then
						showAutoTip("恭喜您，计时礼包随机获得："..data.data.arr[4])
					else
						showAutoTip("恭喜您完成任务获得"..data.data.arr[4] .. "筹码，更多奖励等你来拿！")
					end
					USER.gold = data.data.arr[3]
					-- if data.data.arr[5] > 0 then
					-- 	-- btn:setTitleText("领奖")
					-- else
						self.parts["list"]:removeChild(item)
						self:removeItem(self.parts["list"],item)
					-- end
					-- self.game.parts["menu"]:updateTask(status)
				else
					--弹个错
					showAutoTip("领取失败！")
				end
			end)
		end)
		-- if #v.url > 0 then
		-- 	item:getChildByTag(1):loadTexture("task/" .. v.url .. ".png",1)
		-- end
		self.parts["list"]:pushBackCustomItem(item)
		self:startUpdateTime()
	end
end


function Task:startUpdateTime()
	if self.parts["time-hander"] then return end
	if #self.parts["time-items"] > 0 then
	-- if #self.parts["time-items"] > 0 and self.game:hadCard() then
		self.parts["time-hander"] = scheduler.scheduleGlobal(function (  )
			if #self.parts["time-items"] <= 0 then return end
			for k,v in pairs(self.parts["time-items"]) do
				if v then
					v.time = v.time -1 
					if v.time > 0 then
						local hour = checkint(v.time/3600)
						if hour <= 0 then
							hour = os.date("%M",v.time)..":"..os.date("%S",v.time)
						else
							hour = hour..":" .. os.date("%M",v.time)..":"..os.date("%S",v.time)
						end
						v:getChildByTag(38):setString(hour)
					else
						v.status = 1
						v:getChildByTag(38):setString("")
						self:removeItem(self.parts["list"],v) --从计时里去掉
						v:getChildByTag(5):setVisible(true)
					end
				end
			end
		end, 1)
	end
end

function Task:removeItem(list,item)
	for k,v in pairs(self.parts["time-items"]) do
		if item == v then
			table.remove(self.parts["time-items"],k)
			break
		end
	end
end

return Task