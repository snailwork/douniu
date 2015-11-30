
local LoginScene = class("LoginScene", function()

    return display.newScene("LoginScene")
end)

function LoginScene:ctor()
    -- utils.callStaticMethod("MyGotye","outRoom",nil,nil,"()V")
    self._widget = cc.uiloader:load("login.csb"):addTo(self)
    :align(display.CENTER, display.cx, display.cy)

    cc.ui.UILabel.new({
                text = CONFIG.appversion,
                size = 22,
                x = display.width-100,
                y = 20,
            })
            :addTo(self)

    NetManager.close()
    if device.platform == "android" then
        self:setKeypadEnabled(true)
        self:addNodeEventListener(cc.KEYPAD_EVENT, function ( event )
            if event.key == "back" then
                showDialogTip("","确定退出游戏吗？",{"取消","确定"},function ( flag )
                    if flag then
                        exitApp()
                    end
                end)
            end
        end)
    end
end

function LoginScene:onExit()
    if device.platform == "android" then
        self:setKeypadEnabled(false)
        self:removeNodeEventListener(cc.KEYPAD_EVENT)
    end
end

function LoginScene:onEnter()
    local frame = self._widget:getChildByName("Panel_bg")
    local qq_btn = frame:getChildByName("Button_qq")
    local qs_btn = frame:getChildByName("Button_qs")
    local guest_btn = frame:getChildByName("Button_guest")
    local wx_btn = frame:getChildByName("Button_weixin")
    
    guest_btn:addTouchEventListener(function ( sender , eventType )
         
        if eventType == ccui.TouchEventType.began then
            sender:setScale(0.9)
        elseif eventType ~= ccui.TouchEventType.moved then
            sender:setScale(1.0)
        end  

        if eventType ~= ccui.TouchEventType.ended  then
            return
        end

        utils.playSound("click")
        LoginManager.login({login_type = 0})

        CONFIG.lType = 4
        require("app.views.LoadingLayer").new():addTo(self)
    end)

    qq_btn:addTouchEventListener(function ( sender , eventType )

        if eventType == ccui.TouchEventType.began then
            sender:setScale(0.9)
        elseif eventType ~= ccui.TouchEventType.moved then
            sender:setScale(1.0)
        end  

        if eventType ~= ccui.TouchEventType.ended then
            return
        end
        utils.playSound("click")
        local callback =  function (data  , openid)
            -- LoginManager.reported("qq登陆成功 callback"..data)
            local js_data
            if device.platform == "android" then
                js_data = checktable(json.decode(data))
                if checkint(js_data.ret) < 0 then 
                    -- SceneManager.switch("LoginScene")
                    return 
                end
            else
                 js_data = checktable(data)
            end
            utils.setUserSetting("LOGIN" , {login_type = 2,nick_name = js_data.nickname , icon_url = js_data.figureurl_qq_2  , sitemid = js_data.openId})

            LoginManager.login({login_type = 2,nick_name = js_data.nickname , icon_url = js_data.figureurl_qq_2 , sitemid = js_data.openId})

            CONFIG.lType = 4
            require("app.views.LoadingLayer").new():addTo(self)
        end
        if device.platform == "ios" then
            utils.callStaticMethod("Helper" , "QQLogin" , {callback = callback})
        elseif device.platform == "android" then
            utils.callStaticMethod("QQLogin","Login",{callback = callback},{"callback"},"(I)V")
        end
       
        print("qq_btn:addTouchEventListener")

    end)
    
    qs_btn:addTouchEventListener(function ( sender , eventType )

        if eventType == ccui.TouchEventType.began then
            sender:setScale(0.9)
        elseif eventType ~= ccui.TouchEventType.moved then
            sender:setScale(1.0)
        end  

        if eventType ~= ccui.TouchEventType.ended then
            return
        end
        utils.playSound("click")
        -- LoginManager.login({login_type = 3})
        self:showQsEdit()
    end)
    if device.model == "ipad" and not CONFIG.installWchat then
        wx_btn:setVisible(false)
    else
        wx_btn:addTouchEventListener(function ( sender , eventType )    --微信登录按钮
             
            if eventType == ccui.TouchEventType.began then
                sender:setScale(0.9)
            elseif eventType ~= ccui.TouchEventType.moved then
                sender:setScale(1.0)
            end  

            if eventType ~= ccui.TouchEventType.ended  then
                return
            end

            utils.playSound("click")
            LoginManager.login({login_type = 3})

            CONFIG.lType = 4
            require("app.views.LoadingLayer").new():addTo(self)
        end)
    end
end

function  LoginScene:showQsEdit()
    -- body

    local qs_edit = cc.uiloader:load("qs_login.csb")
    :align(display.CENTER, display.cx, display.cy)
    qs_edit:addTo(self)

    --dump(frame_panel)
    local bg = qs_edit:getChildByName("Panel_20")
    
    if bg:getContentSize().height < display.height then
        bg:setScale( display.height/bg:getContentSize().height)
    end

    local frame_panel = qs_edit:getChildByName("Panel_frame")
    frame_panel:setScale(0.1)
    frame_panel:runAction(cca.scaleTo(0.1 , 1.0)) --cc.ScaleTo:create(0.2, 1.0))
    local frame_img = cc.uiloader:seekNodeByTag(qs_edit, 100)
    local login_btn = cc.uiloader:seekNodeByTag(qs_edit , 105)
    local colse_btn = cc.uiloader:seekNodeByTag(qs_edit, 106)


    local edit_cb = function ( strEventName,pSender )
        -- body

        if strEventName == "changed" then

            local str = pSender:getText()

            str = utils.substr(str , 12)

            pSender:setText(str)
        
        end
    end
    local edit_user = cc.ui.UIInput.new({
        image = "bank_input.png",
        x = 489,
        y = 346,
        size = cc.size(463,55),
        listener = edit_cb,
        })

    frame_img:addChild(edit_user)
    edit_user:setInputMode(1)
    edit_user:setPlaceHolder("请输入用户名")

    local edit_password = cc.ui.UIInput.new({
        image = "bank_input.png",
        x = 489,
        y = 244,
        size = cc.size(463,55),
        listener = edit_cb,

        })

    edit_password:setInputFlag(0)
    edit_password:setPlaceHolder("请输入密码")
    frame_img:addChild(edit_password)

    function close_cb ( sender , eventType )
        if eventType ~= ccui.TouchEventType.ended then
            return
        end
        utils.playSound("click")
        local acts = {}
        acts[1] = cca.seq(cca.scaleTo(0.1 , 0.4))
        acts[2] = cca.callFunc(function ()
            qs_edit:removeFromParent()
        end)
        frame_panel:runAction(cca.seq(acts))
    end

    colse_btn:addTouchEventListener(close_cb)

    login_btn:addTouchEventListener(function ( sender , eventType )

        if eventType ~= ccui.TouchEventType.ended then
        
            return
        end
            
        utils.playSound("click")

        CONFIG.LOADING_TYPE = LOADING_TAG.Login

        local name = edit_user:getText()
        local pass = edit_password:getText()

        if name == "" or name == nil or pass == "" or pass == nil then

            createPromptBox("请输入用户名和密码")
            return
        end
        require("app.scenes.hall.LoadingLayer").new():addTo(self)
        LoginManager.login({login_type = 1,sitemid = name , pass = pass})

        utils.setUserSetting("LOGIN" , {login_type = 1,user = name ,sitemid = name , pass = pass })
        qs_edit:removeFromParent()
        
    end)

    local info = utils.getUserSetting("LOGIN",{})

    edit_user:setText(info.user and info.user or "")

    edit_password:setText(info.pass and info.pass or "")

end


return LoginScene