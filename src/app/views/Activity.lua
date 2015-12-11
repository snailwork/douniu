local Activity = class("Activity")

function Activity:ctor(callback,hall)
	self.callback = callback
	self.parts = {}
	self.parts["hall"] =  hall
    self.parts["layer"] = cc.uiloader:load("activity.csb")
        :addTo(display.getRunningScene(),101)
        :align(display.CENTER, display.cx, display.cy)

    local mask = self.parts["layer"]:getChildByTag(124)
    mask:setContentSize(display.width,display.height)
	
	mask:setEnabled(true)
	mask:addTouchEventListener(function ( target,event )
		if event ~= 2 then return end
		utils.playSound("click")
		self:hide()
	end)

    self.parts["layer_panel"] = self.parts["layer"]:getChildByTag(122)
    
    self.parts["list-item"] = self.parts["layer_panel"]:getChildByTag(211)
    self.parts["list-item"]:setVisible(false)

    self.parts["layer_panel"]:getChildByTag(106):addTouchEventListener(function (target, event)
    	if event == 0 then
	        target:setScale(0.9)
	    elseif event == 3 or event == 2 then
	        target:setScale(1)
	    end
    	if event ~= 2 then return end
    	utils.playSound("click")
    	self:hide()
    end)
    
    self.parts["list"] = self.parts["layer_panel"]:getChildByTag(685)

	if #CONFIG.activity > 0 then
		self:init()
		self.parts["layer"]:getChildByTag(251):setVisible(false)
	end
end

function Activity:hide(  )
	if self.callback then self.callback() end
	self.parts["layer"]:removeSelf()
	self.parts = nil
end

function Activity:init()
	self.parts["list"]:setVisible(true)
    for k,v in pairs(CONFIG.activity) do
		local item = self.parts["list-item"]:clone()
		-- dump(v)
		item:setVisible(true)
		utils.loadImage(CONFIG.activityImgUrl .. v.icon , function ( succ, ccimage )
            if succ then
                local ret,errMessage = xpcall(function ( )
                    item:getChildByTag(1):loadTexture(ccimage)
                end,function (  )
                	-- dump("load img error")
            	end)
            end
        end)
		item:getChildByTag(2):setString(v.des)
		item:getChildByTag(3):setString(v.title)
		item:getChildByTag(3):setFontName("Helvetica-Bold")
		item:addTouchEventListener(function (target, event)
	    	if event ~= 2 or self.parts["click"] then return end
	    	self.parts["click"] = true
	    	scheduler.performWithDelayGlobal(function ( ... )
	    		if self and self.parts then
	    			self.parts["click"] = nil
	    		end
	    	end,1)
	    	utils.playSound("click")
	    	-- display.pause()
	    	-- self.parts["top_mask"]:setEnabled(true)
	    	-- utils.callStaticMethod("Helper","openURL",{url = v.img},{"url"},"(S)V")
	    	local url = CONFIG.activityUrl .. v.file .. "?sesskey=" .. USER.sessionKey
	    	utils.callStaticMethod("WebViewBridge", "open", {url = url,callback = function ( data )
	    		--webview 返回数据
	    		-- self.parts["top_mask"]:setEnabled(false)
	    		-- dump(data)
	    		if data == "load" then
	    			--取一次用户数据
                    utils.http(CONFIG.API_URL,
                        {
                            method="Amember.load",
                            sesskey=USER.sessionKey,

                        },function ( data )
                            if data.err  then
                                --网络错误处理
                            elseif data.svflag == 1 then
                                data = data.data
                                utils.__merge(USER,data.aUser)
                                utils.__merge(GAME,data.aGame)
                                app:dispatchEvent({name = "app.updatachip", nil})
                            end

                    end,"POST")
                elseif data == "quickstart" then
                	scheduler.performWithDelayGlobal(function ( ... )
	                	CONFIG.LOADING_TYPE = LOADING_TAG.Load_Fast_Enter_Room
	    				SceneManager.switch("GameScene")
	    			end,0.3)
	    		end
	    	end }, {"url","callback"}, "(SI)Z")
	    end)
		
		self.parts["list"]:pushBackCustomItem(item)
	end
end

return Activity