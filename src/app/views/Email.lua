local Email = class("Email", function()

    return display.newLayer("Email")
end)


function Email:ctor( parent , callback )
	self:addTo(display.getRunningScene(),100)
	self.parts = {}
	self.parts["parent"] = parent
	self.parts["callback"] = callback
	self.parts["_widget"] = cc.uiloader:load("email.csb"):addTo(self)
		:align(display.CENTER, display.cx, display.cy)

	self:setNodeEventEnabled(true)
	self.parts["gift_list"] = cc.uiloader:seekNodeByTag(self.parts["_widget"] , 687)
	self.parts["sys_list"] = cc.uiloader:seekNodeByTag(self.parts["_widget"] , 252)
	
	self.parts["sys_tab"] = cc.uiloader:seekNodeByTag(self.parts["_widget"] , 101)    --系统消息
	self.parts["sys_tab"]_label = self.parts["sys_tab"]:getChildByTag(116) --系统消息按钮翻转
	self.parts["sys_tab"]_label:setFlippedX(true)
	self.parts["gift_tab"] = cc.uiloader:seekNodeByTag(self.parts["_widget"] , 105)		--好友礼物

    function selectedEvent(sender , eventType )
		if eventType ~= ccui.CheckBoxEventType.selected then
			return
		end
		utils.playSound("click")
		self:showTab(sender:getTag())
	end
	self.parts["sys_tab"]:addTouchEventListener(selectedEvent)
	self.parts["gift_tab"]:addTouchEventListener(selectedEvent)

	function close_cb( sender , eventType )
		-- body
		if eventType ~= ccui.TouchEventType.ended then
			return
		end
		utils.playSound("click")
		self:hide()
	end

	cc.uiloader:seekNodeByTag(self.parts["_widget"] , 106):addTouchEventListener(close_cb)
	self.parts["no_chat_label"] = self.parts["_widget"]:getChildByTag(251)
	self.parts["model"] = cc.uiloader:seekNodeByTag(self.parts["_widget"] , 211)
	self.parts["no_chat_label"]:setVisible(false)
	self.parts["model"]:setVisible(false)

	local bg = cc.uiloader:seekNodeByTag(self.parts["_widget"], 122)
	bg:setContentSize(display.width,display.height)
	
	bg:setOpacity(0)
    self.parts["_widget"]:setScale(0.2)
    transition.scaleTo(self.parts["_widget"], {scale = 1, time = 0.4,easing = "BACKOUT",onComplete = function ( )
        transition.fadeIn(bg,{time = 0.2})
    end})
end
	
function Email:onEnter()
	performWithDelay(self, function ()
		self:updataAllChats()
		self:showTab(101)
		self.sch = nil
	end , 0.05)

end	

function Email:hide()
	if self.parts["callback"] then
		self.parts["callback"]()
	end
	self:removeFromParent()
end	


function Email:updataAllChats()
	self.parts["sys_list"]:removeAllChildren()
	self.parts["gift_list"]:removeAllChildren()

	local mode = self.parts["model"]
	function seek_cb( s , t )
		if t ~= ccui.TouchEventType.ended then
			return
		end
		utils.playSound("click")
		local news = s.date
		if news.id == USER.mid then
			for i,v in ipairs(CONFIG.news) do
				if tonumber(v.id) == tonumber(id) then
					table.remove(i)
					break
				end
			end
		end
		news.status = 0
		utils.setUserSetting(USER.mid.."NEWS" , CONFIG.news)
		self.parts["parent"]:updataNewsCount()
		if news ~= nil then
			self:createMsgWidget(news.msg)
			self:updataAllChats()
		end
	end
	-- dump(CONFIG.news)
	for k , v in pairs(CONFIG.news) do
		local item = mode:clone()
		item:setVisible(true)
		local icon_img = cc.uiloader:seekNodeByTag(item , 7514)
		local time_label = cc.uiloader:seekNodeByTag(item , 7515)
		local title_label = cc.uiloader:seekNodeByTag(item , 7516)
		local news_flag = cc.uiloader:seekNodeByTag(item , 7519)
		local seek_btn = cc.uiloader:seekNodeByTag(item , 7517)

		title_label:setString(v.title)
		if v.status == 0 then
			news_flag:setVisible(false)
		end
		seek_btn.date = v
		seek_btn:addTouchEventListener(seek_cb)
		if v.tab == 2 then
			self.parts["sys_list"]:pushBackCustomItem(item)
		else	
			self.parts["gift_list"]:pushBackCustomItem(item)
		end
		local month = os.date("%m" , v.time)
		local day = os.date("%d" , v.time)
		time_label:setString(month.."月"..day.."日")
	end
	mode:setVisible(false)
end

function Email:createMsgWidget( str )
	if	self.msg_ui ~= nil then
		return
	end
	showDialogTip(str,{"确定"})

end

function Email:showTab(tag)
	if tag == 101 then
		self.parts["sys_list"]:setVisible(false)
		self.parts["gift_list"]:setVisible(true)
		self.parts["sys_tab"]:setEnabled(true)
		self.parts["gift_tab"]:setEnabled(false)
		self.parts["gift_tab"]:setBright(false)
		self.parts["sys_tab"]:setBright(true)
	else
		self.parts["sys_list"]:setVisible(true)
		self.parts["gift_list"]:setVisible(false)
		self.parts["sys_tab"]:setEnabled(false)
		self.parts["gift_tab"]:setEnabled(true)
		self.parts["sys_tab"]:setBright(false)
		self.parts["gift_tab"]:setBright(true)
	end

    if self.parts["sys_list"]:getChildrenCount() > 0 then   -- 有2个其他控件
        self.parts["no_chat_label"]:setVisible(false)
    else
        self.parts["no_chat_label"]:setVisible(true)
    end

    scheduler.performWithDelayGlobal(function ()
		self.parts["sys_list"]:scrollToTop(0.1, true)
	end, 0.01)

end


return Email