local Dialog = class("Dialog", function ()
	-- body
	return display.newLayer("Dialog")
end)


function Dialog:ctor(arg)

	self:setNodeEventEnabled(true)
	self._widget = cc.uiloader:load("dialog.csb")
		:addTo(self)
		:align(display.CENTER, display.cx, display.cy)
	
	self:addTo(display.getRunningScene(),300)

	local panel_frame = cc.uiloader:seekNodeByTag(self._widget , 68)
	panel_frame:setContentSize(display.width,display.height)
	self._frame_bk = cc.uiloader:seekNodeByTag(self._widget , 69)

	local text_label = cc.uiloader:seekNodeByTag(self._frame_bk , 101)
	local cancel_btn = cc.uiloader:seekNodeByTag(self._frame_bk , 2)
	local ok_btn = cc.uiloader:seekNodeByTag(self._frame_bk , 1)

	local btn_msg = arg[2]
	self.callback = arg[3]
	text_label:setString(arg[1])
	if btn_msg[2] == nil then
		cancel_btn:setVisible(false)
		ok_btn:setPositionX(330.0)
		if btn_msg[1] ~= nil then
			ok_btn:setTitleText(btn_msg[1])
		else
			ok_btn:setTitleText("确定")
		end
	else
		cancel_btn:setTitleText(btn_msg[1])
		ok_btn:setTitleText(btn_msg[2])
	end

	function btncb( s , type )
		if type ~= ccui.TouchEventType.ended then
			return
		end
		utils.playSound("click")
		local isok = false
		if s:getTag() == 1 then
			isok = true
		end
		self:hide(isok)
	end
	ok_btn:addTouchEventListener(btncb)
	cancel_btn:addTouchEventListener(btncb)

	panel_frame:addTouchEventListener(function ( s , t )
		if t ~= ccui.TouchEventType.ended then
			return
		end
		utils.playSound("click")
		self:hide(false)
	end)

	if device.platform == "android" then
        self:setKeypadEnabled(true)
        self:addNodeEventListener(cc.KEYPAD_EVENT, function(event)
            -- dump(event)
            if event.key == "back" then
                self:hide(false)
            end
        end)
    end
end

function Dialog:onExit()
	-- body
	if device.platform == "android" then
		self:removeNodeEventListener(cc.KEYPAD_EVENT)
	end
end

function Dialog:hide(isok)
	isok = isok or false
	self._widget:removeFromParent()
	if self["callback"] ~= nil then

		self.callback(isok)
	end
end


return Dialog

