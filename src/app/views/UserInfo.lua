local UserInfo = class("UserInfo", function()

	return display.newLayer("UserInfo")

end)
--3cb2e2
function UserInfo:ctor(data,callback)
	self:addTo(display.getRunningScene(),101)
	self.callback = callback
	self:setNodeEventEnabled(true)
	self.data = data
	self.parts = {}
	local panel
	if self:isSelf() then
		self.data = USER
	end
	panel = cc.uiloader:load("userinfo.csb"):addTo(self)
    panel:align(display.CENTER, display.cx, display.cy)
	self.parts["panel"] = panel


    local panel_bg = panel:getChildByTag(147)    --容器
    panel_bg:setContentSize(display.width,display.height)
    
    panel_bg:setOpacity(0)
	panel:setScale(0.2)
	transition.scaleTo(panel, {scale = 1, time = 0.4,easing = "BACKOUT",onComplete = function ( )
		transition.fadeIn(panel_bg,{time = 0.2})
	end})
    
	panel:getChildByTag(501):addTouchEventListener(handler(self,self.close))     --关闭按钮
	panel_bg:addTouchEventListener(function (target, event)
        if event ~= ccui.TouchEventType.ended then
            return
        end
        utils.playSound("click")
        self:hide()
    end)

	self.parts["base-info"] = panel:getChildByTag(444)     --基本信息
	self.parts["list"] = self.parts["base-info"]:getChildByTag(598):getChildByTag(487)
	
	self.parts["list-item"] = self.parts["base-info"]:getChildByTag(598):getChildByTag(1123)     --道具信息
	self.parts["list-item"]:setVisible(false)
	
	
	self.parts["base-info"]:getChildByTag(241):setVisible(false)
	if self:isSelf() then
		self.parts["base-info"]:getChildByTag(598):setVisible(false)
		self.parts["list"]:setVisible(false)
		self.parts["base-info"]:getChildByTag(243):addTouchEventListener(handler(self,self.setName))   --修改信息
		self.parts["base-info"]:getChildByTag(240):addTouchEventListener(handler(self,self.setSex))   --修改性别
	else
		
		self.parts["base-info"]:getChildByTag(242):setVisible(false)
		if checkint(USER.seatid) > 0 then           --在游戏房间里看别人的信息
			self:initProps()
		else
			self.parts["base-info"]:getChildByTag(598):setVisible(false)
		end
	end

	local head = utils.makeAvatar(data)     --头像
		:align(display.CENTER,189,395)
		:addTo(self.parts["base-info"],-1)
    self.parts["head"] = head
    head:setScale(1.22)
	self:getUserData()
end

function UserInfo:setName(target, event)
	if event ~= ccui.TouchEventType.ended then
		return	
	end
	utils.playSound("click")
	if self.parts["base-info"]:getChildByTag(241):isVisible() then
		self.parts["base-info"]:getChildByTag(241):setVisible(false)
		self.parts["ebox_name"]:setEnabled(false)
		self.parts["ebox_name"]:setVisible(false)
		-- self.parts["base-info"]:getChildByTag(1):setString("")
		self:saveInfo({name = string.trim(self.parts["ebox_name"]:getText())})
		return
	end
	self.parts["base-info"]:getChildByTag(1):setString("")
	self.parts["base-info"]:getChildByTag(241):setVisible(true)

	if not self.parts["ebox_name"] then 
		self.parts["ebox_name"] = cc.ui.UIInput.new({
			image = "menu/transparent.png",
			listener = function(event, editbox)    --键盘确定响应方法
				if event == "ended" then
					dump(event)
					self:saveInfo({name = string.trim(editbox:getText())})
				end
			end,
			align = cc.TEXT_ALIGNMENT_LEFT,
			x = 450,
			y = 450,
			size = cc.size(260,50),
		}):addTo(self.parts["base-info"])
		self.parts["ebox_name"]:setFontColor(cc.c3b(206,82,28))
	end
	
	self.parts["ebox_name"]:setEnabled(true)
	self.parts["ebox_name"]:setVisible(true)
	self.parts["ebox_name"]:setText(USER.name)
end


function UserInfo:saveInfo(data)
	if data.name and data.name ~= USER.name and data.name ~= "" then
		flag = true
	else
		data.name = nil
	end
	if checkint(self.data.sex) ~= checkint(USER.sex) then
		flag = true
	end
	if flag then
		if data.name and data.name ~= USER.name then    --改名字了
			showDialogTip("您已修改了昵称，需要消耗20万筹码，是否保存信息！",{"取消","确定"},function ( flag )
				    if flag then
				    	if USER.gold < 200000 then
							showAutoTip("您的筹码不足，修改昵称时需要消耗20万！")
							return
						end
				       self:changeInfo(data)
				    end
				end)
		else
			self:changeInfo(data)
		end
	else
		self.parts["base-info"]:getChildByTag(1):setString(USER.name)
	end
end

function UserInfo:changeInfo(data)
	utils.http(CONFIG.API_URL,
		{
			method = "Amember.updateName",
			sesskey = USER.sessionKey,
			name = data.name,
			sex = data.sex,

		},function ( data )

		    if data.svflag == 1 then
		 		self.parts["base-info"]:getChildByTag(241):setVisible(false)
		 		self.parts["base-info"]:getChildByTag(1):setString(data.data.arr[1])
		 		if self.parts["ebox_name"] then
			 		self.parts["ebox_name"]:setVisible(false)
			 		self.parts["ebox_name"]:setEnabled(false)
			 	end
		    	USER.gold = data.data.arr[2]
		    	USER.sex = checkint(data.data.arr[3])      --改性别
		    	USER.name = data.data.arr[1]    --修改大厅   名字 
		    	app:dispatchEvent({name = "app.updatachip"})     --发事件
		    	self.data  = USER
		    	SendCMD:bindUser({name = USER.name,icon= USER.icon})

		    elseif data.svflag == 1002 then
		    	showAutoTip("昵称已存在，请重新输入！")
		    end
	end,"POST")

end

function UserInfo:uploadPic( v )
	-- 打开拍照的
	utils.callStaticMethod("ImagePickerBridge","showPicker",{callback = function (data)   --相册或照相机响应的方法
    	network.uploadFile(function(evt)               --上传照片
				if evt.name == "completed" then
					local request = evt.request
					-- dump(request:getResponseStatusCode())
		            if request:getResponseStatusCode() == 200  then
		            	local data = json.decode(request:getResponseString())
		            	if data.svflag == 1 then
			            	local upic = data.data.icon
			            	USER["icon"] = upic
			            	cc.Director:getInstance():getTextureCache():removeTextureForKey(device.writablePath.."upic_cache/"..crypto.md5(upic))
			            	
		            		SendCMD:bindUser({name = "",icon= upic})
					        -- cc.Director:getInstance():getTextureCache():removeTextureForKey(device.writablePath.."upic_cache/"..crypto.md5(upic))   --这一句 删了头像再加头像 把新头像给删了 会变成一片白
		            		utils.loadRemote(self.parts["head"].pic,upic,function ( succ,texture )   												
		            			app:dispatchEvent({name = "app.updataupic"}) --更新相片   --大厅头像更新
					            if not succ then return end
					            self.parts["head"].pic:setTexture(texture)
					            transition.fadeIn(self.parts["head"].pic,{time = .2})    --基本信息页面  头像更新
					        end)

					    else
					    	showAutoTip("上传失败，请重试！")
					    end
		            end
				end

			end,
			CONFIG.API_URL,
			{	
				fileFieldName="img",
				-- fileFieldName="buffer",
				filePath=data,
				contentType = "multipart/form-data",
				-- contentType="Image/jpeg",
				extra={ {"api" , json.encode({
											 type= 1 ,
											 method ="Amember.updateIcon",
									    	 sesskey = USER.sessionKey,
									    	 photo = "p0"                   --传的第几张图片
									    })
						}
				}
			}
		)
    end},{"callback"},"(I)V")
end

function UserInfo:setSex(target,event)
	if event ~= 2 then return end
	utils.playSound("click") 
	if self.data.sex == 0 then
		self.data.sex = 1
		self.parts["base-info"]:getChildByTag(502):loadTexture("userinfo/girl.png",1)
	else
		self.data.sex = 0
		self.parts["base-info"]:getChildByTag(502):loadTexture("userinfo/boy.png",1)
	end
	self:saveInfo({sex = self.data.sex})
end

--是别人的时候生成互动道具
function UserInfo:initProps( )
	
	local model = self.parts["list-item"]

	local propsImg = {"kiss","flower","egg","dog"}
	local vals = {6,8,9,10}
	for i,v in ipairs(propsImg) do
		dump(v)
		local item = model:clone()
		self.parts["list"]:pushBackCustomItem(item)
		item:setVisible(true)
		item:addTouchEventListener(function (target,event )
			if event == 0 then
		        target:setScale(0.9)
		    elseif event == 3 or event == 2 then
		        target:setScale(1)
		    end
			if event ~= ccui.TouchEventType.ended then
				return
			end
			if USER.gold < checkint(v.price) then
		        showAutoTip("筹码不足!")
		        return
		    end
		    local data = {
		        pframe = vals[i],
		        pcate = 1,
		        _type = 0,
		        mid = self.data.mid
		    }
		    SendCMD:useProps(data)
	        self:hide()
		end)
		
      	item:getChildByTag(1):loadTexture("interaction/"..v..".png",1)
	end
end

function UserInfo:close(target , event)
	
	if event ~= ccui.TouchEventType.ended then
		return
	end
	utils.playSound("click")
	self:hide()
end

function UserInfo:getUserData( )
    utils.http(CONFIG.API_URL,
    	{
	    	method = "Amember.getProfile",
	    	mid = self.data.mid,
	    	sesskey = USER.sessionKey,
	    		
    	},function ( data )
    		if data.svflag == 1 and data.data then
    			dump(data.data)
	    	    self.data.maxhs = data.data.arr[1]
	    		self.data.maxwin = data.data.arr[2]
	    		self.data.maxchip = data.data.arr[3] 
	    		self.data.winUSER = data.data.arr[4]
	    		self.data.sumUSER = data.data.arr[5]
	    		self.data.sex = checkint(data.data.arr[6])
	    		self.data.age = checkint(data.data.arr[7])
	    		self.data.sign = data.data.arr[8]
	    		self.data.p1 = data.data.arr[9][1]
	    		self.data.p2 = data.data.arr[9][2]
	    		self.data.p3 = data.data.arr[9][3]
	    		self.data.exp = data.data.arr[10]
				self:updataBasicInfo()
			end
    	end,"POST")

end

function UserInfo:updataBasicInfo()

    self.data.level = 1
    self.data.currExp = 1
    self.data.currLevelUpExp = 1
    self.data.preExp = 0
    if checkint(self.data.exp) > 0 then
    	
    	for i,v in ipairs(CONFIG.level) do
    		if checkint(self.data.exp) >= checkint(v.exp_all) then
    			self.data.level = i
    			self.data.currLevelUpExp = checkint(v.exp_all) - self.data.preExp
    			self.data.currExp = checkint(self.data.exp) - self.data.preExp
    		else
    			if i == 1 then
    				self.data.currExp = self.data.exp
    				self.data.currLevelUpExp = checkint(v.exp_all)
    			end
    			break
    		end
    		self.data.preExp = checkint(v.exp_all)
    	end
	    self.parts["base-info"]:getChildByTag(4):setPercent(checkint(self.data.currExp/self.data.currLevelUpExp*100))
	else
		self.parts["base-info"]:getChildByTag(4):setPercent(0)
	end

	local chipstr = checkint(self.data.gold) > 1e6 and utils.numAbbrZh(self.data.gold) or utils.formatNumber(self.data.gold)
    local  data = {}
    data[1] = self.data.name
    data[2] = "$"..chipstr
    if self:isSelf() then
    	data[3] = utils.numAbbrZh(USER.bankAssets)
    else
    	data[3] = 0
    end
    
	-- data[4] = utils.suffixStr(self.data.sign,18)
	data[4] = nil
    if checkint(self.data.sumUSER) == 0 or checkint(self.data.winUSER)  == 0 then
		data[5] ="0%"
	else
		local rate = self.data.winUSER * 100 / self.data.sumUSER
		data[5] = string.format("%.2f" , rate) .. "%"
	end
    data[6] = self.data.sumUSER.."局"
    data[7] = "$"..( checkint(self.data.maxwin) > 1e6 and utils.numAbbrZh(self.data.maxwin) or utils.formatNumber(self.data.maxwin))
    data[8] = self.data.winUSER.."局"
    -- data[8] = "$".. (checkint(self.data.maxchip) > 1e6 and utils.numAbbrZh(self.data.maxchip) or utils.formatNumber(self.data.maxchip))
    data[9] = "ID: " .. self.data.mid
    data[10] = "LV: " .. self.data.level

    for i=1,10  do
    	if data[i] ~= nil then
    		self.parts["base-info"]:getChildByTag(i):setString(data[i].."")
    	end
    end
	if checkint(self.data.sex) == 1 then      --0男 1女 2保密
    	self.parts["base-info"]:getChildByTag(502):setVisible(true)
    	self.parts["base-info"]:getChildByTag(502):loadTexture("userinfo/boy.png", 1)
    -- elseif checkint(self.data.sex) == 2 then
    	-- self.parts["base-info"]:getChildByTag(502):setVisible(false)
    end

  	local j = 1
  	for i,v in ipairs(self.data.maxhs) do
    	if #(v.."") == 2 then
    		Card.new({batchnode = self.parts["base-info"]:getChildByTag(590):getChildByTag(i),val = v})
    		self.parts["base-info"]:getChildByTag(590):getChildByTag(i):setScale(0.55)
    		j = j + 1
    	end
    end
   	for i =j,5 do
   		Card.new({batchnode = self.parts["base-info"]:getChildByTag(590):getChildByTag(i)})
   		self.parts["base-info"]:getChildByTag(590):getChildByTag(i):setScale(0.55)
   	end
end

function UserInfo:isSelf()
	if self.data.mid == USER.mid then
		return true
	end
	return false
end

function UserInfo:hide(back )
	-- body
	if self.callback then
		self.callback(back)
	end
	self:removeFromParent()
end

return UserInfo