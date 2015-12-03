local StoreLayer = class("StoreLayer", function()

	return display.newLayer("StoreLayer")

end)

function StoreLayer:ctor(data,callback)
	self.parts = {callback = callback}

	self:addTo(display.getRunningScene(),100)
	local store = cc.uiloader:load("store.csb"):addTo(self)
		:align(display.CENTER, display.cx, display.cy)
	self.parts["store"] = store

	store:getChildByTag(202):setString(utils.numAbbrZh(USER.gold))
 	self.parts["list-item"] = store:getChildByTag(69)
    self.parts["list-item"]:setVisible(false)
    self.parts["list"] = store:getChildByTag(206)

	NetManager.addEvent(3001 , handler(self,self["fun3001"]))
	store:getChildByTag(1):addTouchEventListener(function ( target,event )
		dump(event)
		 if event == 0 then
	        target:setScale(0.9)
	    elseif event == 3 or event == 2 then
	        target:setScale(1)
	    end
		if event ~= ccui.TouchEventType.ended then
			return
		end
		utils.playSound("click")
		self:hide()
	end)

	self:init()
end

function StoreLayer:onExit()
	NetManager.removeEvent(3001)
end

function StoreLayer:fun3001(data)
	data = data.data
	local str = "赠送"
	if self.mid == USER.mid then
		str = "购买"
		self.parts["store"]:getChildByTag(202):setString(utils.numAbbrZh(USER.gold))
	end
	app:dispatchEvent({name = "app.updatachip",data = nil})
	if data.err == -6 then
		createPromptBox(str.."失败,筹码不足")
	elseif data.err ~= 0 then	
		createPromptBox(str.."失败,错误码："..data.err)
	else
		createPromptBox(str.."成功")
		GAME.gold = data.chip
	end
	Loading.close()
end	

function StoreLayer:hide()
	if self.callback then
		self.callback()
	end
	self:removeFromParent()
	self.callback = nil
end

function StoreLayer:buy(target,event )
	if event ~= ccui.TouchEventType.ended then
		return
	end
	utils.playSound("click")
	StoreLayer.buy(target.data)
end

function StoreLayer:init()
	-- body
	local listview = self.parts["list"]
	local mode = self.parts["list-item"]
	local index = 0


	local panel_item = nil	
	for k , v in pairs(CONFIG.storeItems) do
		if tonumber(v.id) > 50  then
			if index  > 3 or index == 0 then
				index = 1
				panel_item = mode:clone()
				panel_item:setVisible(true)
				listview:pushBackCustomItem(panel_item)
			end
			local item = panel_item:getChildByTag(index)
			index = index + 1
			item.data = v
			-- if not info then
			-- 	item:setVisible(false)
			-- end
			item:addTouchEventListener(handler(self,self.buy))

			
			item:getChildByTag(1):setString((tonumber(v.content["2"]) / 10000).."万")
			item:getChildByTag(2):setString("1:"..math.floor(checkint(v.content["2"]) / checkint(v.cost)))
			local icon = item:getChildByTag(3)
			local i = tonumber(info.id) - 50
			if tonumber(info.id) > 50 then
				icon:loadTexture("store/gold"..i..".png" , ccui.TextureResType.plistType )
			end
			item:getChildByTag(4):setString("￥"..v.cost)

		end
	end
	for i=index,3 do
		panel_item:getChildByTag(i):setVisible(false)
	end
end


function StoreLayer.buy(data)
	local payFun = function ( ... )
		if data.wchat then
			require("app.scenes.store.WChat").buyItem(data)
		elseif device.platform == "ios" then
			-- local prodid = StoreLayer.getAppStoreProductByItemId(id)
			IOSPAY.id = data.id
			local good = data
			Loading.create()
			utils.http(CONFIG.API_URL,
	    		{
	         	method="Amember.getOrder",
	         	sesskey = USER.sessionKey,
	         	type=4,
	         	id=data.id,
	         	},function (data)
	         		Loading.close()
	         		if data.svflag == 1 then
	         			IOSPAY.orderid = data.data.string
	         			IOSPAY.cardid = data.data.cardid
	         			IosStore.buyItem(good)
	         		else
	         			createPromptBox("请求订单号失败")
	         		end	
	         	end,"POST")	
		else
			require("app.scenes.store.Alipay").buyItem(data)
		end
	end
	if CONFIG.WCHAT_PAY then
		data.wchat = true
		local pay = cc.uiloader:load("pay.csb"):addTo(display.getRunningScene(),100)
		pay:getChildByTag(400):setContentSize(display.width,display.height)
		pay:getChildByTag(327):setPositionY(display.height)
		local price = cc.uiloader:seekNodeByTag(pay , 341)
		price:setString(data.cost)
		cc.uiloader:seekNodeByTag(pay , 342):setPositionX(price:getPositionX() + price:getContentSize().width / 2 + 16)

		local  appPayBtn = cc.uiloader:seekNodeByTag(pay , 332)
		local  wchatPayBtn = cc.uiloader:seekNodeByTag(pay , 331)
		
		appPayBtn:getChildByTag(1):setVisible(false)
		wchatPayBtn:getChildByTag(2):setColor(display.COLOR_WHITE)

		wchatPayBtn:addTouchEventListener(function ( target,event )
			if event ~= 2 then return end
    		utils.playSound("click")
			data.wchat = true
			wchatPayBtn:getChildByTag(1):setVisible(true)
			appPayBtn:getChildByTag(1):setVisible(false)
			wchatPayBtn:getChildByTag(2):setColor(display.COLOR_WHITE)
			appPayBtn:getChildByTag(2):setColor(cc.c3b(102,102,102))
		end)

		appPayBtn:addTouchEventListener(function ( target,event )
			if event ~= 2 then return end
    		utils.playSound("click")
			data.wchat = false

			appPayBtn:getChildByTag(2):setColor(display.COLOR_WHITE)
			wchatPayBtn:getChildByTag(2):setColor(cc.c3b(102,102,102))
			appPayBtn:getChildByTag(1):setVisible(true)
			wchatPayBtn:getChildByTag(1):setVisible(false)
		end)
		
		if device.platform == "ios" then
			appPayBtn:getChildByTag(395):loadTexture("pay/apple.png",1)
			appPayBtn:getChildByTag(2):setString("APP")
		end

		cc.uiloader:seekNodeByTag(pay , 333):addTouchEventListener(function ( target,event )
			if event == 0 then
		        target:setScale(0.9)
		    elseif event == 3 or event == 2 then
		        target:setScale(1)
		    end
			if event ~= 2 then return end
			payFun()
			pay:removeFromParent()
		end)

		cc.uiloader:seekNodeByTag(pay , 329):addTouchEventListener(function ( target,event )
			if event == 0 then
		        target:setScale(0.9)
		    elseif event == 3 or event == 2 then
		        target:setScale(1)
		    end
			if event ~= 2 then return end
    		utils.playSound("click")
			pay:removeFromParent()
		end)
	else
		payFun()
	end
	
end	


return StoreLayer