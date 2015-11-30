local LoadingLayer = class("LoadingLayer", function()

    return display.newLayer("LoadingLayer")
end)
local ParseXml = require("app.tools.ParseXml")

function LoadingLayer:ctor(data)
	self.data = data or {}
	self:setNodeEventEnabled(true)
	self._widget = cc.uiloader:load("loading.csb")

	self._widget:addTo(self)
		:align(display.CENTER, display.cx, display.cy)

	cc.uiloader:seekNodeByTag(self._widget , 190):setContentSize(display.width , display.height)

	self.Max_Progress = 0
	self.Min_Progress = -796
	self._cur_finish = self.Min_Progress
	self._stop_progress = false

	self:initSparkBar()
	self:initProgressBar()
	dump(CONFIG.lType)

	if CONFIG.lType == 1 then --启动游戏
		-- local login = utils.getUserSetting("LOGIN",{})
		-- if login.login_type == nil then
			CONFIG.lType = 2 --异步加载资源，然后去登陆界面
			self:updateProgress(219)
		-- else
		-- 	if login.sitemid == nil and login.login_type ~= 0 then
		-- 		CONFIG.lType = 2--异步加载资源，然后去登陆界面
		-- 		self:updateProgress(219)
		-- 	else
		-- 		CONFIG.lType = 3 --走登陆接口
		-- 		LoginManager.login({login_type = login.login_type ,nick_name = login.nick_name,pass = login.pass , icon_url = login.icon_url , sitemid = login.sitemid})
		-- 	end
		-- end

		performWithDelay(self,function ()
					cc.Director:getInstance():getTextureCache():addImage("default.png")
					self:loadRes({
					plist =  {"common","room","hall"},
					jpg = {"room-bg"},

				},500)
		end, 0.7)

		
	end
	dump(CONFIG.lType)
	if CONFIG.lType == 3 then --第一次启动，走自动登陆，需要加载资源
		self:Login()
	elseif CONFIG.lType == 4 then --登陆，不用再加载资源
		self:Login()
		self:updateProgress(500)
		CONFIG.lType = 3
	else
		-- LoginManager.login({login_type = 0 ,nick_name = "test",pass = ""})
		self:updateProgress(800)
	end

	-- self:setLoadTypeText()
	-- self:setRestText()

end

function LoadingLayer:Login( )
	self.handler = app:addEventListener("app.login", function(event)
		dump(event.data)
		app:removeEventListener(self.handler)
		if event.data.err ~= 0 then

			self:stopAllActions()

			showDialogTip("",Lang["1000-"..event.data.err],{"确定"},function ( flag )
				CONFIG.lType = 2
	    		SceneManager.switch("LoginScene")
			end , self._widget)
		
		else
			self.data = event.data
			if self.data and checkint(self.data.room_id) > 0 then
				CONFIG.lType = 4 --重连进房间
				-- self:setLoadTypeText()
			end
			self:updateProgress(100)
		end
	end)
	self.http_handler = app:addEventListener("http.login" , function ( event )
		dump(event.data)
		app:removeEventListener(self.http_handler)
		if event.data == 1 then
			self:updateProgress(100)
			return
		end
		self:stopAllActions()
		self._stop_progress = true
		local err_info = nil 
		if event.data == 1002 then
			err_info = "登录失败！没有该用户名"
		elseif event.data == 1001 then
			err_info = "登录失败！账号密码不匹配"
		else
			err_info = "登录失败！错误代码 "--..event.data
		end
		showDialogTip("提示", err_info , {"确定"} , function (isOK)
			-- SceneManager.switch("LoginScene")
			if display.getRunningScene():getName() == "LoginScene" then
				self:stopAllActions()
				self:removeFromParent()
			else
				SceneManager.switch("LoginScene")
			end

		end )
	end)
end


function LoadingLayer:onEnter()
	local acts = {}
	acts[1] = cca.delay(50)
	acts[2] = cca.cb(function ( )
		showDialogTip("提示", "网络连接出错，请检查wifi是否连接正常" , {"确定"} , function (isOK)
			-- self._cur_finish
					SceneManager.switch("LoginScene")
				end)
	end)

	if self._stop_progress == false then

		self:runAction(cca.seq(acts))
	end
end

function LoadingLayer:onExit()
	app:removeEventListener(self.handler)
	app:removeEventListener(self.http_handler)
end

-- function LoadingLayer:enterRoom(data)
-- 	self:updateProgress(300)
-- end

function LoadingLayer:initSparkBar()
	local panel_frame = cc.uiloader:seekNodeByTag(self._widget , 189)
	local logo_bk = cc.uiloader:seekNodeByTag(self._widget , 191)
	local spark = cc.uiloader:seekNodeByTag(self._widget , 200)
	spark:retain()
	spark:removeFromParent()
	local mode_logo = display.newSprite("#loading/black_logo.png")
	local clip = cc.ClippingNode:create()
	clip:setStencil(mode_logo)
	clip:setAlphaThreshold(0)
    clip:setContentSize(mode_logo:getContentSize())
    clip:setPosition(logo_bk:getPosition())
    clip:setAnchorPoint(0, 0)
    panel_frame:addChild(clip, 100)
    clip:addChild(spark, 100)
    spark:setAnchorPoint(0.5,0.5)
    spark:setPosition(-400,0)

    local seq = cc.Sequence:create(cc.MoveBy:create(1.5, cc.p(800.0 , 0.0)) ,
    								cc.DelayTime:create(0.4),
    								cc.CallFunc:create(function()
    									
    									spark:setPosition(cc.p(-400, 0))
    								end) )
    local rep = cc.RepeatForever:create(seq)
    spark:runAction(rep)
end

function LoadingLayer:initProgressBar()
	local panel_frame = cc.uiloader:seekNodeByTag(self._widget , 189)
	local progress_frame = cc.uiloader:seekNodeByTag(self._widget , 201)
	self.progress_bar_ = display.newSprite("#loading/bar.png")
	local progress_mode = display.newSprite("#loading/bar.png")
	local clip = cc.ClippingNode:create()
	clip:setStencil(progress_mode)
	clip:setAlphaThreshold(0)
	clip:setContentSize(progress_mode:getContentSize())
	clip:setPosition(progress_frame:getPosition())
	clip:setAnchorPoint(cc.p(0,0))
	panel_frame:addChild(clip , 3)
	clip:addChild(self.progress_bar_ , 100)
	self.progress_bar_:setAnchorPoint(cc.p(0.5 , 0.5))
	self.progress_bar_:setPosition(cc.p(self.Min_Progress, 0.0))
	self:updateProgress(100)
end

function LoadingLayer:loadRes(data,progress)
	progres = progress or 800
	-- local com = 0
	data.plist = data.plist or {}
	data.png = data.png or {}
	data.jpg = data.jpg or {}
	local num = #data.plist + #data.png + #data.jpg
	local update = progress/num
	local asyc = function ( plist, image )
		-- com =  com + 1 
		-- if com == num then
			-- self:updateProgress(progres)
		-- end
		-- dump(update)
		self:updateProgress(update)
	end
	for i,v in ipairs(data.plist) do
		display.addSpriteFrames(v..".plist",v..".png",asyc)
	end
	for i,v in ipairs(data.png) do
		display.addImageAsync(v..".png",asyc)
	end
	data.jpg = data.jpg or {}
	for i,v in ipairs(data.jpg) do
		display.addImageAsync(v..".jpg",asyc)
	end
	--data.csb = data.csb or {}
	-- for i,v in ipairs(data.csb) do
	-- 	cc.uiloader:load(v..".csb")
	-- end
	
end

function LoadingLayer:updateProgress( finish )
	if self.progress_bar_ then
		self.progress_bar_:stopAllActions()
	end
	if finish <=0 or not self.progress_bar_ or self._stop_progress == true then return end
	
	self._cur_finish = self._cur_finish + finish
	if self._cur_finish > self.Max_Progress then
		self._cur_finish = self.Max_Progress
	end
	-- dump(self._cur_finish)
	self.progress_bar_:stopAllActions()
	function cb()
		-- body
		if self._cur_finish >= self.Max_Progress then
			self._stop_progress = true
			self:changeScene()
		end
	end
	local acts = {}
	acts[1] = cca.moveTo(1.0, self._cur_finish , 0 )
	acts[2] = cca.delay(0.3)
	acts[3] = cca.cb(cb)
	self.progress_bar_:runAction(cca.seq(acts))
end

local loadingType = {
	
}

function LoadingLayer:setLoadTypeText()
	local vals = {"正在加载资源...","正在进入游戏...","正在登陆游戏...","正在进入房间...","正在切换房间..."}
	local load_text = cc.uiloader:seekNodeByTag(self._widget , 206)
	load_text:setString(vals[CONFIG.lType])
	
end

function LoadingLayer:setRestText()
	local label = cc.uiloader:seekNodeByTag(self._widget , 194)
	local size
	local index
	if CONFIG.lType == 2 or
		CONFIG.lType == 0 or
		CONFIG.lType == 1 then

		size = #LOGIN_TIPS
		index = math.random() * 20 % size + 1
		index = math.floor(index)
		if LOGIN_TIPS[index] == nil then
			index = 1
		end
		label:setString(LOGIN_TIPS[index])	
	else
		size = #LOADING_TIPS
		index = math.random() * 20 % size + 1
		index = math.floor(index)
		if LOADING_TIPS[index] == nil then
			index = 1
		end
		label:setString(LOADING_TIPS[index])	
	end

end


function LoadingLayer:stop()

end

function LoadingLayer:changeScene()
	-- display.replaceScene(require("app.scenes.GameScene").new(self.data))
	-- do return end
	dump(CONFIG.lType)
	if CONFIG.lType == 3 then
		display.replaceScene(require("app.scenes.RoomlistScene").new(self.data))
		-- display.replaceScene(require("app.scenes.HallScene").new(self.data))
	elseif table.indexof({4,5},CONFIG.lType) then
		display.replaceScene(require("app.scenes.GameScene").new(self.data))
	elseif CONFIG.lType == 2 then
		display.replaceScene(require("app.scenes.LoginScene").new(self.data))
	else
		self:removeFromParent(true)
	end
end

return LoadingLayer
