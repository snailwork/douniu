local FeedBackLayer = class("FeedBackLayer", function()

    return display.newLayer("FeedBackLayer")
end)

function FeedBackLayer:ctor(callback,about)
	self:addTo(display.getRunningScene(),100)
	self.callback = callback
	if about then
		self._widget = cc.uiloader:load("about.csb"):addTo(self)
		local text = cc.uiloader:seekNodeByTag(self._widget , 7023)
		-- text:setContentSize(810,1700)
		text:setString(string.format(text:getString(),CONFIG.appversion))
	else
		self._widget = cc.uiloader:load("feedback.csb"):addTo(self)
	end
	

	function close_cb( s , t)
		if t ~= ccui.TouchEventType.ended then
			return
		end
		utils.playSound("click")
		self:hide()
	end
	cc.uiloader:seekNodeByTag(self._widget , 1000):setTouchEnabled(true)
	cc.uiloader:seekNodeByTag(self._widget , 4296):addTouchEventListener(close_cb)
	local bg = cc.uiloader:seekNodeByTag(self._widget , 66)
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