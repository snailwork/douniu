local RankingLayer = class("RankingLayer", function()

	return display.newLayer("RankingLayer")

end)

function RankingLayer:ctor( callback ,prant)
	self:addTo(display.getRunningScene(),100)
	self.parts={}
	self.RankType = {}
	self.RANK = {}
	self.parts["prant"] = prant

	Loading.create()
	self.callback = callback
	self:setNodeEventEnabled(true)
	self.parts["widget"] = cc.uiloader:load("ranking.csb"):addTo(self)
		:align(display.CENTER, display.cx, display.cy)

	self.parts["panel"] = self.parts["widget"]:getChildByTag(83)


	local bg = self.parts["widget"]:getChildByTag(82)
	bg:setContentSize(display.width,display.height)

	bg:setOpacity(0)
	self.parts["widget"]:setScale(0.2)
	transition.scaleTo(self.parts["widget"], {scale = 1, time = 0.4,easing = "BACKOUT",onComplete = function ( )
		transition.fadeIn(bg,{time = 0.2})
	end})

	self.parts["panel"]:getChildByTag(85):addTouchEventListener(function ( s , t )
		if t == ccui.TouchEventType.ended then
			utils.playSound("click")
			self:hide()
		end
	end)

	bg:addTouchEventListener(function ( s , t )
		if t == ccui.TouchEventType.ended then
			utils.playSound("click")
			self:hide()
		end
	end)

	function selectedEvent(sender , eventType )
		if eventType ~= 2 then return end
		utils.playSound("click")
		self:setRankType(checkint(sender:getTag()) == 182 and 1 or 2)
	end
	
	self.parts["win_ck"] = self.parts["panel"]:getChildByTag(184)
	self.parts["rich_ck"] = self.parts["panel"]:getChildByTag(182)
	self.parts["win_ck"]:setTouchEnabled(true)
	self.parts["rich_ck"]:setTouchEnabled(true)
	self.parts["win_ck"]:setEnabled(true)
	self.parts["rich_ck"]:setEnabled(true)
	
	self.parts["win_ck"].label = cc.uiloader:seekNodeByTag(self.parts["widget"] , 261)
	self.parts["rich_ck"].label = cc.uiloader:seekNodeByTag(self.parts["widget"] , 263)

	self.parts["win_ck"].label:setFontName("Helvetica-Bold")
	self.parts["rich_ck"].label:setFontName("Helvetica-Bold")


	self.parts["win_ck"]:addTouchEventListener(selectedEvent)
	self.parts["rich_ck"]:addTouchEventListener(selectedEvent)
	
	self.handler = app:addEventListener("app.ranking_reload", function(event)
		local data = event.data.data
		self.RANK[data.type] = data.arr
		self:reload(data.type)

	end)
	
	self.parts["model"] = self.parts["panel"]:getChildByTag(1833)
	self.parts["listview"] = self.parts["panel"]:getChildByTag(1036)
	self.parts["model"]:setVisible(false)
	

	self:setRankType(1)
end

function RankingLayer:hide()
	if self.callback then
		self.callback()
	end
	if self.perHandler then
		scheduler.unscheduleGlobal(self.perHandler)
	end
	self.perHandler = nil
	self:removeFromParent()
	if self.handler then
		app:removeEventListener(self.handler)
	end
	self.handler = nil
end

function RankingLayer:onExit()
	dump("onExit")
	if self.handler then
		app:removeEventListener(self.handler)
	end
	self.handler = nil

end


function RankingLayer:reload(ranktype)
	local listview = self.parts["listview"]
	listview:removeAllChildren()
	if self.RANK[ranktype] == nil or #self.RANK[ranktype] == 0  then
		local label = cc.ui.UILabel.new({text = "没有任何记录~", size = 28, color = display.COLOR_WHITE})
			:pos(469,257)
			:addTo(self.parts["panel"])
		return 
	end
	local mode = self.parts["model"]

	for k , v in pairs(self.RANK[ranktype]) do
		local item = mode:clone()
		item.data = v
		item:setVisible(true)
	
		if v[7] == checkint(1) then
			if checkint(v[12]) == 0 then
				item:getChildByTag(485):getChildByTag(486):setString("大厅")
			else
				item:getChildByTag(485):getChildByTag(486):setString("房间:"..v[12])
			end
		else
			item:getChildByTag(485):getChildByTag(486):setColor(cc.c3b(149,149,149))
			item:getChildByTag(485):getChildByTag(486):setString("不在线")
		end
		
		local icon = display.newSprite("default.png")
		icon:setPosition(cc.p(210 , 45))
		item:addChild(icon)
		icon:setAnchorPoint(cc.p(0.5 , 0.5))
		-- v[2] = "http://s0.hao123img.com/res/r/image/2015-06-05/f977d95f1e32030f9b2531b4d9c35cf0.jpg"
		utils.loadImage(v[2] , function ( succ, ccimage )
            if succ then
                 local ret,errMessage = xpcall(function ( ... )
                    icon:setTexture(ccimage)
                    local size = icon:getContentSize()
			        if size.width > size.height then
			            scale = 78/size.width
			        elseif size.height > size.width then
			            scale = 78/size.height
			        else
			            scale = 78/size.height
			        end
			        icon:setScale(scale)
                end,function ( ... )
                end)
                
              	
            end
        end)

		local size = icon:getContentSize()
        if size.width > size.height then
            scale = 78/size.width
        elseif size.height > size.width then
            scale = 78/size.height
        else
            scale = 78/size.height
        end
        icon:setScale(scale)
        local headMask = "#rank/mask.png"
		local chipStr = v[5]
		local head
	    if v[1] == USER.mid  then
	    	chipStr = USER.gold
	    	if k == #self.RANK[ranktype] then
	    		headMask = "#rank/mask_me.png"
	    		item:getChildByTag(485):setVisible(false)
	    		item:getChildByTag(485):getChildByTag(486):setString("")
		    	listview:insertCustomItem(item,0)
		    	item:setBackGroundImage("rank/bg_me.png",1)
		    else
		    	listview:pushBackCustomItem(item)
		    	
	    	end
	    else
			listview:pushBackCustomItem(item)
		end


		head = display.newSprite(headMask)
			:pos(210 , 45)
			:addTo(item)
		-- if checkint(v[10]) > 0  and not CONFIG.storeVipCard then
	 --        display.newSprite("#vip/"..v[10] ..".png")
	 --            :pos(41,44)
	 --            :addTo(head)
	 --            :setScale(scale)
	 --    end
	    
		-- if k > 3 or (v[1] == USER.mid and k > 3) then
			local rankingText = k
			if v[1] == USER.mid then
				if USER.Ranking then
					rankingText = USER.Ranking[ranktype]
				else
					rankingText = 0
				end
				if checkint(rankingText) == 0 then
					rankingText = ""
				end
			end
			item:getChildByTag(294):setVisible(false)
			item:getChildByTag(293):setString(rankingText)
		-- else
		-- 	item:getChildByTag(294):loadTextures("rank/"..k..".png")
			
		-- end
		item:getChildByTag(292):setString(v[3])
		if ranktype == 2 then
			chipStr = v[4]
		end
		item:getChildByTag(291):setFontName("Helvetica-Bold")
		item:getChildByTag(291):setString(utils.numAbbrZh(chipStr))

		item:addTouchEventListener(function (target, event)
			if event ~= ccui.TouchEventType.ended then
	            return
	        end
	        utils.playSound("click")
			self.parts["prant"].parts["item"]["UserInfo"] = require("app.views.UserInfo").new(
	            										{mid = v[1], name = v[3], vip = v[10], gold = v[5] , icon = v[2], other = nil},
	            										function ( ... )
												           self.parts["prant"].parts["item"]["UserInfo"] = nil
												        end)
		end)

	end

	scheduler.performWithDelayGlobal(function ()
		listview:scrollToTop(0.1, false)
	end, 0.05)
end

function RankingLayer:httpGetTop(ranktype)
	function back_cb(data)
		Loading.close()
		if data.svflag ~= 1 then
			createPromptBox("获取排行榜数据出错!")
			return
		end
		app:dispatchEvent({name = "app.ranking_reload",data = data})
		
	end
	utils.http(CONFIG.API_URL , 
		{method = "Afriend.getTop",
    		sesskey = USER.sessionKey,
    		type = ranktype},
		back_cb,"POST")
end

function RankingLayer:setRankType(ranktype)
	dump(ranktype)
	local win_ck = self.parts["win_ck"]
	local rich_ck = self.parts["rich_ck"]

	if ranktype == 1 then
		rich_ck:setBright(false)
		win_ck:setBright(true)

		self.parts["rich_ck"].label:setColor(cc.c3b(255,255,255))
		self.parts["win_ck"].label:setColor(cc.c3b(246,194,48))
	elseif ranktype == 2 then
		win_ck:setBright(false)
		rich_ck:setBright(true)
		
		self.parts["win_ck"].label:setColor(cc.c3b(255,255,255))
		self.parts["rich_ck"].label:setColor(cc.c3b(246,194,48))
	end
	
	if self.RANK[ranktype] ~= nil then
		self:reload(ranktype)
	else 
		Loading.create()
		self:httpGetTop(ranktype)
	end
end



return RankingLayer