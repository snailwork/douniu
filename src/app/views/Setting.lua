local SettingLayer = class("SettingLayer", function()

    return display.newLayer("SettingLayer")
end)

function SettingLayer:ctor(hall,callback)
	self:addTo(display.getRunningScene(),100)
	self.callback = callback
	self.hall = hall
	self:setNodeEventEnabled(true)
	self._widget = cc.uiloader:load("setting.csb"):addTo(self)
	:align(display.CENTER, display.cx-14, display.cy)



	local list = cc.uiloader:seekNodeByTag(self._widget , 1112)
	local vals = {"music_enabled","sound_enabled","vibrate_enabled"}

	for i=1,8 do
		if i > 1 and i < 5 then
			local btn = cc.uiloader:seekNodeByTag(list , i)
			btn:addEventListener(handler(self,self["fun"..i]))
			btn:setSelected(utils.getUserSetting(vals[i-1],false))
		else
			cc.uiloader:seekNodeByTag(list , i):addTouchEventListener(handler(self,self["fun"..i]))
		end
	end
	if utils.getUserSetting("music_enabled",false) then
		--做个场景判断播放不同的音乐
		utils.playMusic("hallBack")
	end

	cc.uiloader:seekNodeByTag(self._widget , 1372):setString(USER.name)
	if device.platform == "android" then
		cc.uiloader:seekNodeByTag(list , 1398):removeFromParent(true)
		cc.uiloader:seekNodeByTag(list , 8):removeFromParent(true)
		-- cc.uiloader:seekNodeByTag(list , 1386):setContentSize(738,)
		--有版本需要更新
		if hall.parts["version"] then
	 	else
	 		cc.uiloader:seekNodeByTag(list , 205):setVisible(false)
	 		cc.uiloader:seekNodeByTag(list , 206):setString("当前的版本号："..CONFIG.appversion)
		end
	elseif device.platform == "ios" then
		cc.uiloader:seekNodeByTag(list , 1385):removeFromParent(true)

		cc.uiloader:seekNodeByTag(list , 1392):setString("    版本号：")
		cc.uiloader:seekNodeByTag(list , 206):setString(CONFIG.appversion)
		cc.uiloader:seekNodeByTag(list , 205):setVisible(false)
	end
	 
	function close_cb(s , t)
		if t ~= ccui.TouchEventType.ended then
			return
		end
		utils.playSound("click")
		self:hide()
	end
	cc.uiloader:seekNodeByTag(self._widget , 67):addTouchEventListener(close_cb)
	local bg = cc.uiloader:seekNodeByTag(self._widget , 82)
	bg:setContentSize(display.width + 100,display.height)
	bg:addTouchEventListener(close_cb)

	bg:setOpacity(0)
    self._widget:setScale(0.2)
    transition.scaleTo(self._widget, {scale = 1, time = 0.4,easing = "BACKOUT",onComplete = function ( )
        transition.fadeIn(bg,{time = 0.2})
    end})
    
end
--关于
function SettingLayer:fun7( target,event )
	if event ~= ccui.TouchEventType.ended then return end
	self.hall:showFeedback(true)
end
--反馈
function SettingLayer:fun5( target,event )
	if event ~= ccui.TouchEventType.ended then return end
	self.hall:showFeedback()
end
--评论
function SettingLayer:fun8( target,event )
	if event ~= ccui.TouchEventType.ended then return end
	if device.platform == "android" then
		device.openURL(CONFIG.SHARE_URL)
	else
		utils.toAppstoreGrade(CONFIG.itunesId )
	end
end
--版本
function SettingLayer:fun6( target,event )
	if event ~= ccui.TouchEventType.ended then return end
	if device.platform == "ios" then return end
	if self.hall.parts["version"] then
		-- if device.platform == "ios" then
		-- 	utils.toAppstoreGrade(CONFIG.itunesId )
		-- else
			device.openURL(CONFIG.UPDATA_URL)
		-- end
	else
		createPromptBox("已经是最新版本了！")
	end
end


function SettingLayer:fun4( target,event )
 	utils.playSound("click")
    utils.setUserSetting("vibrate_enabled",target:isSelected() and true or false)
end

function SettingLayer:fun3( target,event )
	utils.playSound("click")
    utils.setUserSetting("sound_enabled",target:isSelected() and true or false)
end

function SettingLayer:fun2( target,event )
	utils.playSound("click")
	utils.setUserSetting("music_enabled",target:isSelected() and true or false)
    if target:isSelected() then
    	--做个场景判断播放不同的音乐
    	-- if display.getRunningScene():getName() == "hall" then
    		utils.playMusic("hallBack")
    	-- else
    		-- utils.playMusic("roomBack")
    	-- end	
    else
    	utils.stopMusic()
    end
end

function SettingLayer:fun1(target,event )
	if event ~= ccui.TouchEventType.ended then return end
	utils.playSound("click")
	display.replaceScene(require("app.scenes.LoginScene").new(self.data))
end

function SettingLayer:hide( ... )
	-- body
	if self.callback then
		self.callback()
	end
	self:removeFromParent()
end


return SettingLayer