local BankLayer = class("BankLayer", function()

	return display.newLayer("BankLayer")

end)

function BankLayer:ctor(callback)
	self:addTo(display.getRunningScene(),100)
    self.callback = callback
	self._open_widget = cc.uiloader:load("open_bank.csb"):addTo(self)
        :align(display.CENTER, display.cx, display.cy)

    local bg = cc.uiloader:seekNodeByTag(self._open_widget , 136)
    bg:setContentSize(display.width,display.height)
    
    bg:setOpacity(0)
    self._open_widget:setScale(0.2)
    transition.scaleTo(self._open_widget, {scale = 1, time = 0.4,easing = "BACKOUT",onComplete = function ( )
        transition.fadeIn(bg,{time = 0.2})
    end})

    local frame_img = self._open_widget
    self.pass_edit = cc.ui.UIInput.new({
        image = "menu/transparent.png",
        size = cc.size(400, 45),
        x = 683,
        y = 468,
        size = cc.size(400, 45)

        })
    -- self.pass_edit:setPlaceholderFont("Marker Felt" , 26)
    self.pass_edit:setPlaceHolder("请输入6到12位的银行密码")
    frame_img:addChild(self.pass_edit)
    self.pass_edit:setFontColor(cc.c3b(99,43,16))
    self.pass_edit:setInputFlag(0)

    self.again_edit = cc.ui.UIInput.new({
        image = "menu/transparent.png",
        x = 683,
        y = 384,
        size = cc.size(400, 45)

        })
    self.again_edit:setPlaceHolder("请再次输入密码")
    -- self.again_edit:setPlaceholderFont("Marker Felt" , 26)
    self.again_edit:setInputFlag(0)
    self.again_edit:setFontColor(cc.c3b(99,43,16))
    
    frame_img:addChild(self.again_edit)

    self.email_edit = cc.ui.UIInput.new({
        image = "menu/transparent.png",
        x = 683,
        y = 297,
        size = cc.size(400, 45)

        })
    self.email_edit:setPlaceHolder("请输入EMail以便于找回密码")
    -- self.email_edit:setPlaceholderFont("Marker Felt" , 26)
    self.email_edit:setFontColor(cc.c3b(99,43,16))
    frame_img:addChild(self.email_edit)

    self._open_widget:getChildByTag(235):addTouchEventListener(function (sender , eventType )
        if event == 0 then
            target:setScale(0.9)
        elseif event == 3 or event == 2 then
            target:setScale(1)
        end
        if eventType ~= ccui.TouchEventType.ended then
            return
        end
        utils.playSound("click")
        self:hide()

    end)

    self._open_widget:getChildByTag(231):addTouchEventListener(function ( sender , eventType )
        if event == 0 then
            target:setScale(0.9)
        elseif event == 3 or event == 2 then
            target:setScale(1)
        end
        if eventType ~= ccui.TouchEventType.ended then
            return
        end
        utils.playSound("click")
        self:openBank()
    end)
end


function BankLayer:hide()
    if self.callback then
        self.callback()
    end

    self:removeFromParent()
end


function BankLayer:openBank()
    local pass = self.pass_edit:getText()
    local again = self.again_edit:getText()
    local email = self.email_edit:getText()
    if #pass < 6 then
        showAutoTip("请输入6位到12位字符密码")        --创建弹框   在屏幕上部，显示一下，然后自己消失
    elseif again ~= pass then
        showAutoTip("两次密码不一致")
    elseif #email < 6 then 
        showAutoTip("请输入EMail以便于找回密码")
    else
        utils.http(CONFIG.API_URL,
        {
            method = "Abank.open",
            email = email,
            pw = pass,
            sesskey = USER.sessionKey,
                
        },function ( data )
            dump(data)  
            if data.err then
                showAutoTip("银行密码设置失败，错误码"..data.msg)
            elseif data.svflag == 1 then

                showAutoTip("银行密码设置成功")
                self._open_widget:removeFromParent()
                USER.bankpasswd = 1
                -- self:showBankLayer()
                require("app.views.Bank").new()
                performWithDelay(self,function ( ... )
                    -- body
                    self:hide()
                end,0.1)
            else
                showAutoTip("银行密码设置失败，错误码"..data.svflag)
            end
        end,"POST")
    end
end


return BankLayer