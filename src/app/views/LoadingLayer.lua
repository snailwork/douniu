local LoadingLayer = class("LoadingLayer", function()

    return display.newLayer("LoadingLayer")
end)

function LoadingLayer:ctor(data)
	self.data = data or {}
	self:setNodeEventEnabled(true)
	self._widget = cc.uiloader:load("loading.csb")
	self.loadingProgress = 0
	self._widget:addTo(self)
		:align(display.CENTER, display.cx, display.cy)

	dump(CONFIG.lType)

	if CONFIG.lType == 1 then --启动游戏
		local login = utils.getUserSetting("LOGIN",{})
		if login.login_type == nil then
			CONFIG.lType = 2 --异步加载资源，然后去登陆界面
		else
			if login.sitemid == nil and login.login_type ~= 0 then
				CONFIG.lType = 2--异步加载资源，然后去登陆界面
			else
				CONFIG.lType = 3 --走登陆接口
				LoginManager.login({login_type = login.login_type ,nick_name = login.nick_name,pass = login.pass , icon_url = login.icon_url , sitemid = login.sitemid})
			end
		end

		cc.Director:getInstance():getTextureCache():addImage("default.png")
		self:loadRes({
			plist =  {"common","room","hall"},
			jpg = {"room-bg"},
		})
	end
	if CONFIG.lType == 3 then --第一次启动，走自动登陆，需要加载资源
		self:Login()
	elseif CONFIG.lType == 4 then --登陆，不用再加载资源
		self.loadingProgress = 500
		self:Login()
	elseif CONFIG.lType == 2 then
		self.loadingProgress = 300 --加载完就直接去登陆界面
	else
		performWithDelay(self,function ( )
			self:changeScene()
		end,2)
	end

	self:setLoadTypeText()

	for i=1,3 do
		self._widget:getChildByTag(i):setVisible(false)
	end
	local index = 1
	schedule(self,function (  )
		if index > 3 then
			index = 1
			for i=1,3 do
				self._widget:getChildByTag(i):setVisible(false)
			end
		else
			self._widget:getChildByTag(index):setVisible(true)
			index = index + 1
		end
	end,0.5)
end

function LoadingLayer:Login(a,b )
	
	dump(self.loadingProgress)
	self.handler = app:addEventListener("app.login", function(event)
		dump(self.loadingProgress)
		app:removeEventListener(self.handler)
		if event.data.err ~= 0 then

			self:stopAllActions()

			showDialogTip("",Lang["1000-"..event.data.err],{"确定"},function ( flag )
				CONFIG.lType = 2
				display.replaceScene(require("app.scenes.LoginScene").new(self.data))
			end , self._widget)
		
		else
			self.data = event.data
			if self.data and checkint(self.data.room_id) > 0 then
				CONFIG.lType = 5 --重连进房间
			end
		end

		self.loadingProgress = self.loadingProgress + 150
		if self.loadingProgress == 800 then
			self:changeScene()
		end

	end)
	self.http_handler = app:addEventListener("http.login" , function ( event )
		dump(self)
		dump(self.loadingProgress)
		app:removeEventListener(self.http_handler)
		if event.data == 1 then
			self.loadingProgress = self.loadingProgress + 150
			if self.loadingProgress == 800 then
				self:changeScene()
			end
			return
		end
		
		local err_info = nil 
		if event.data == 1002 then
			err_info = "登录失败！没有该用户名"
		elseif event.data == 1001 then
			err_info = "登录失败！账号密码不匹配"
		else
			err_info = "登录失败！错误代码 "--..event.data
		end
		showDialogTip( err_info , {"确定"} , function (isOK)
			if display.getRunningScene():getName() == "LoginScene" then
				self:removeFromParent()
			else
				display.replaceScene(require("app.scenes.LoginScene").new(self.data))
			end

		end )
	end)
end


function LoadingLayer:onExit()
	dump("onExit")
	dump("onExit")
	dump("onExit")
	dump("onExit")
	app:removeEventListener(self.handler)
	app:removeEventListener(self.http_handler)
	self:stopAllActions()
end

function LoadingLayer:loadRes(data)
	data.plist = data.plist or {}
	data.png = data.png or {}
	data.jpg = data.jpg or {}

	local com = 0
	local num = #data.plist + #data.png + #data.jpg

	local asyc = function ( plist, image )
		com =  com + 1 

		if com == num then
			self.loadingProgress = self.loadingProgress + 500
			if self.loadingProgress == 800 then
				self:changeScene()
			end
		end
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
end



function LoadingLayer:setLoadTypeText()
	dump(self.loadingProgress)
	self._widget:getChildByTag(194):setString(CONFIG.loadingTips[math.random(1,#CONFIG.loadingTips)])
	
end

function LoadingLayer:changeScene()
	-- display.replaceScene(require("app.scenes.GameScene").new(self.data))
	-- do return end
	self:stopAllActions()
	dump(CONFIG.lType)
	if table.indexof({3,4},CONFIG.lType) then
		-- display.replaceScene(require("app.scenes.RoomlistScene").new(self.data))
		display.replaceScene(require("app.scenes.HallScene").new(self.data))
	elseif CONFIG.lType == 5 then
		display.replaceScene(require("app.scenes.GameScene").new(self.data))
	elseif CONFIG.lType == 2 then
		display.replaceScene(require("app.scenes.LoginScene").new(self.data))
	else
		self:removeFromParent(true)
	end
end

return LoadingLayer
