local RankingLayer = class("RankingLayer", function()

	return display.newLayer("RankingLayer")

end)

function RankingLayer:ctor( callback ,prant)
	self:addTo(display.getRunningScene(),100)
	self.parts["prant"] = prant
	Loading.create()
	self.callback = callback
	self:setNodeEventEnabled(true)
	self._widget = cc.uiloader:load("ranking.csb"):addTo(self)
		:align(display.CENTER, display.cx, display.cy)

	local bg = cc.uiloader:seekNodeByTag(self._widget , 82)
	bg:setContentSize(display.width,display.height)

	self.RANK = {}
	self:init()
	self.RankType = {}
	self.RankType.Rich = 1
	self.RankType.Win = 2
	self.curType = self.RankType.Rich
	self:setRankType(self.curType)
	cc.uiloader:seekNodeByTag(self._widget , 1833):setVisible(false)

	self.handler = app:addEventListener("app.ranking_reload", function(event)
		local data = event.data.data
		self.RANK[data.type] = data.arr
		self:reload(data.type)

	end)
	cc.uiloader:seekNodeByTag(self._widget , 263):setFontName("Helvetica-Bold")
	cc.uiloader:seekNodeByTag(self._widget , 261):setFontName("Helvetica-Bold")
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
end

function RankingLayer:onExit()
	app:removeEventListener(self.handler)

end

function RankingLayer:init()

	cc.uiloader:seekNodeByTag(self._widget , 85):addTouchEventListener(function ( s , t )
		if t == ccui.TouchEventType.ended then
			utils.playSound("click")
			self:hide()
		end
	end)

	cc.uiloader:seekNodeByTag(self._widget , 82):addTouchEventListener(function ( s , t )
		if t == ccui.TouchEventType.ended then
			utils.playSound("click")
			self:hide()
		end
	end)

	function selectedEvent(sender , eventType )
		local tag = sender:getTag()
		local ranktype = self.RankType.Rich
		if checkint(tag) == 182 then
			ranktype = self.RankType.Win
		end
		if eventType ~= 2 then return end
			utils.playSound("click")
			self:setRankType(ranktype)
	end
	local btn = cc.uiloader:seekNodeByTag(self._widget , 184)
	btn:addTouchEventListener(selectedEvent)

	btn = cc.uiloader:seekNodeByTag(self._widget , 182)
	btn:addTouchEventListener(selectedEvent)

end


function RankingLayer:reload(ranktype)
	local listview = cc.uiloader:seekNodeByTag(self._widget , 1036)
	listview:removeAllChildren()
	if self.RANK[ranktype] == nil or #self.RANK[ranktype] == 0  then
		local label = cc.ui.UILabel.new({text = "没有任何记录~", size = 28, color = display.COLOR_WHITE})
			:pos(469,257)
			:addTo(cc.uiloader:seekNodeByTag(self._widget , 83))
		return 
	end
	local mode = cc.uiloader:seekNodeByTag(self._widget , 1833)
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
				dump(USER.Ranking)
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
	self.curType = ranktype
	
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
	local rich_ck = cc.uiloader:seekNodeByTag(self._widget , 184)
	
	local win_ck = cc.uiloader:seekNodeByTag(self._widget , 182)
	

	if ranktype == self.RankType.Rich then
		rich_ck:setBright(false)
		win_ck:setBright(true)
		cc.uiloader:seekNodeByTag(self._widget , 261):setColor(cc.c3b(255,255,255))
		cc.uiloader:seekNodeByTag(self._widget , 263):setColor(cc.c3b(246,194,48))
	elseif ranktype == self.RankType.Win then
		win_ck:setBright(false)
		rich_ck:setBright(true)
		cc.uiloader:seekNodeByTag(self._widget , 261):setColor(cc.c3b(246,194,48))
		cc.uiloader:seekNodeByTag(self._widget , 263):setColor(cc.c3b(255,255,255))
	end
	
	if self.RANK[ranktype] ~= nil then
		self:reload(ranktype)
	else 
		Loading.create()
		self:httpGetTop(ranktype)
	end
end



return RankingLayer