local FeedBackLayer = class("FeedBackLayer", function()

    return display.newLayer("FeedBackLayer")
end)

function FeedBackLayer:ctor(callback,data)
	self:addTo(display.getRunningScene(),100)
	self.callback = callback
	if data.about then
		self._widget = cc.uiloader:load("about.csb"):addTo(self)
		local text = cc.uiloader:seekNodeByTag(self._widget , 232)
		-- text:setContentSize(810,1700)
		text:setString(string.format(text:getString(),CONFIG.appversion))
	elseif data.more then
		self._widget = cc.uiloader:load("more.csb"):addTo(self)
		cc.uiloader:seekNodeByTag(self._widget , 87):addTouchEventListener(function ( target , event)
			device.openURL(CONFIG.UPDATA_URL)
		end)
	else
		self._widget = cc.uiloader:load("feedback.csb"):addTo(self)
	end
	self._widget:align(display.CENTER, display.cx, display.cy)
	
	function close_cb( s , t)
		if t ~= ccui.TouchEventType.ended then
			return
		end
		utils.playSound("click")
		self:hide()
	end
	cc.uiloader:seekNodeByTag(self._widget , 471):setTouchEnabled(true)
	cc.uiloader:seekNodeByTag(self._widget , 235):addTouchEventListener(function ( target , event)
		if event == 0 then
	        target:setScale(0.9)
	    elseif event == 3 or event == 2 then
	        target:setScale(1)
	    end
	    if event ~= 2 then return false end
		close_cb( target , event)
	end)
	local bg = cc.uiloader:seekNodeByTag(self._widget , 136)
	bg:addTouchEventListener(close_cb)
	bg:setContentSize(display.width,display.height)
	
	bg:setOpacity(0)
    self._widget:setScale(0.2)
    transition.scaleTo(self._widget, {scale = 1, time = 0.4,easing = "BACKOUT",onComplete = function ( )
        transition.fadeIn(bg,{time = 0.2})
    end})
    
end

function FeedBackLayer:hide( ... )
	if self.callback then
		self.callback()
	end
	self:removeFromParent()
end


return FeedBackLayer