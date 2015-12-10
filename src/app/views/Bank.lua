local BankLayer = class("BankLayer", function()

	return display.newLayer("BankLayer")

end)

function BankLayer:ctor(callback)
	self:addTo(display.getRunningScene(),100)
    self.callback = callback
	self.bank = {}

    NetManager.addEvent(3001 , handler(self,self["fun3001"]))
    NetManager.addEvent(3011 , handler(self,self["fun3011"]))
    NetManager.addEvent(3012 , handler(self,self["fun3012"]))
    NetManager.addEvent(3013 , handler(self,self["fun3013"]))
    NetManager.addEvent(3024 , handler(self,self["fun3024"]))
    self:showBankLayer()
end

function BankLayer:onExit()
    -- body
    NetManager.removeEvent(3001)
    NetManager.removeEvent(3011)
    -- NetManager.removeEvent(3012)
    NetManager.removeEvent(3012)
    NetManager.removeEvent(3013)
    NetManager.removeEvent(3024)
end

function BankLayer:hide()
    if self.callback then
        self.callback()
    end

    self:removeFromParent()
end


function BankLayer:fun3001(data)

    -- dump(data.data)
    -- dump(data.data.err)
    -- if tonumber(data.data.err) == 0 then
    --     -- 保存
    --     print("礼物购买成功")
    -- else
    --     print("礼物购买失败")
    -- end

    if tonumber(data.data.pcate) == 2 and tonumber(data.data.pframe) == 3 then

        showAutoTip("开通银行成功")
        LoginManager.getUserProp()
    end
end

function BankLayer:fun3011(data)
    -- dump(data)
    Loading.close()
    if data.data.err ~= 0 then
        showAutoTip("存钱失败，错误码："..data.data.err)
        return
    end
    showAutoTip("存钱成功")
    USER.gold = data.data.take_chip
    USER.bankAssets = data.data.deposit_chip
    self:updateText()
    
    app:dispatchEvent({name = "app.updatachip", nil})

end

function BankLayer:fun3012(data)
    Loading.close()
    -- dump(data)
    if data.data.err ~= 0 then
        if data.data.err == -5 then
            showAutoTip("取钱失败，存款不足")
        else
            showAutoTip("取钱失败，密码错误")
        end
        return
    end
    showAutoTip("取钱成功")
    USER.gold = data.data.take_chip
    USER.bankAssets = data.data.deposit_chip
    self:updateText()

    app:dispatchEvent({name = "app.updatachip", nil})

end

function BankLayer:fun3013(data)
    Loading.close()
    if data.data.err ~= 0 then
        if data.data.err == -5 then
            showAutoTip("银行密码不正确！")
        elseif data.data.err == -4 then
            showAutoTip("赠送失败，不能赠送给自己！")

        else
            showAutoTip("赠送失败，错误码："..data.data.err)
        end
        return
    end
    showAutoTip("赠送成功")
    USER.gold = data.data.chip
    self:updateText()
    
    app:dispatchEvent({name = "app.updatachip", nil})
end    

function BankLayer:fun3024(data)
    -- dump(data)
    Loading.close()
    if data.data.err ~= 0 then
        showAutoTip("修改失败，错误码："..data.data.err)
        return
    end 
    showAutoTip("修改成功")
    self.ebox.old_pass:setText("")
    self.ebox.new_pass:setText("")
    self.ebox.agin_pass:setText("")
    -- self._widget:removeFromParent()
    -- self:showBankLayer()
end


function BankLayer:showBankLayer()
	-- body
    self._widget = cc.uiloader:load("bank.csb"):addTo(self)
    :align(display.CENTER, display.cx, display.cy)
    local take_chip = cc.uiloader:seekNodeByTag(self._widget , 301)
    local deposit_chip = cc.uiloader:seekNodeByTag(self._widget , 302)
    self.take_chip = take_chip
    self.deposit_chip = deposit_chip

    local bg = cc.uiloader:seekNodeByTag(self._widget , 136)
    bg:setContentSize(display.width,display.height)
    bg:addTouchEventListener(function (target, event)
         if event ~= ccui.TouchEventType.ended then
            return
        end
        utils.playSound("click")
        self:hide()
    end)

    bg:setOpacity(0)
    self._widget:setScale(0.2)
    transition.scaleTo(self._widget, {scale = 1, time = 0.4,easing = "BACKOUT",onComplete = function ( )
        transition.fadeIn(bg,{time = 0.2})
    end})

    self.Memory = {}
    self:initPanel()
    self:initEditBox()
    self:registerEditBox()
    self:setTag(self.panel_tab.inchip[1])
    self:initButton()
    self.take_chip:setString( "携带：".. utils.numAbbrZh(USER.gold)) 
    self.deposit_chip:setString( "存款："..utils.numAbbrZh(USER.bankAssets) )

    self.old_take_chip = USER.gold
    self.old_bank_chip = USER.bankAssets

    cc.uiloader:seekNodeByTag(self._widget , 106):addTouchEventListener(function (target, event)
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

    

end

function BankLayer:initPanel()
    -- body
    function touch_cb(sender , eventType)
        if eventType ~= ccui.TouchEventType.ended then
            return
        end

        self:setTag(sender)
        utils.playSound("click")
        -- body
    end
   
    self.panel_tab = {}
    self.panel_tab.inchip = {}
    self.panel_tab.outchip = {}
    self.panel_tab.givechip = {}
    self.panel_tab.memory = {}
    self.panel_tab.new_pass = {}

    self.panel_tab.inchip[1] = cc.uiloader:seekNodeByTag(self._widget , 101)     --存入
    self.panel_tab.outchip[1] = cc.uiloader:seekNodeByTag(self._widget , 102)      --取出
    self.panel_tab.givechip[1] = cc.uiloader:seekNodeByTag(self._widget , 103)  --赠送
    self.panel_tab.memory[1] = cc.uiloader:seekNodeByTag(self._widget , 104)    --纪录
    self.panel_tab.new_pass[1] = cc.uiloader:seekNodeByTag(self._widget , 105)  --修改密码
    local password_label = cc.uiloader:seekNodeByTag(self.panel_tab.inchip[1] , 116)    --修改密码  翻转
    password_label:setFlippedX(true)

    self.panel_tab.inchip[2] = cc.uiloader:seekNodeByTag(self._widget , 556)    --in模块
    self.panel_tab.outchip[2] = cc.uiloader:seekNodeByTag(self._widget , 592)   --out模块
    self.panel_tab.givechip[2] = cc.uiloader:seekNodeByTag(self._widget , 658)  --give模块
    self.panel_tab.memory[2] = cc.uiloader:seekNodeByTag(self._widget , 666)    --memery模块
    self.panel_tab.new_pass[2] = cc.uiloader:seekNodeByTag(self._widget , 606)  --password模块

    for k , v in pairs(self.panel_tab) do
        v[1]:addTouchEventListener(touch_cb)
        -- v[1]:loadTextures("buying/b-tab.png","buying/b-tab-down.png","buying/b-tab-down.png",1)
        -- v[1]:setBright(false)
    end
end


function BankLayer:setTag(tab)
    -- body
    self:setEditBox(true)
    for k ,v in pairs(self.panel_tab) do

        v[1]:setEnabled(true)
        v[1]:setBright(true)
        v[2]:setVisible(false)
        v[2]:setEnabled(false)
        if v[1] == tab then

            v[2]:setVisible(true)
            v[2]:setEnabled(true)
        end
    end

    tab:setEnabled(false)
    tab:setBright(false)

    for k , v in pairs(self.ebox) do

        v:setText("")
    end
    self.take_chip:setVisible(true)
    self.deposit_chip:setVisible(true)
    if tab == self.panel_tab.memory[1] then
        self.take_chip:setVisible(false)
        self.deposit_chip:setVisible(false)
        self:httpGetBankRecord(0)
    end
end

function BankLayer:setEditBox(flag)
    self.ebox.givechip:setVisible(flag)
    self.ebox.target_mid:setVisible(flag)
    self.ebox.give_pass:setVisible(flag)
end


function BankLayer:showStore()
    local storelayer = require("app.scenes.hall.StoreLayer").new({mid = USER.mid , tab = 2})
    storelayer:addTo(display.getRunningScene(),50)
    -- storelayer:setTabByIndex(2)
end

function BankLayer:giveChip(chip , mid , pass)
    -- body
    if #(chip.."") < 0 then
        showAutoTip("请输入要转账筹码数!")
        return
    elseif mid == USER.mid then
        showAutoTip("赠送失败，不能赠送给自己！")
        return

    elseif #mid < 3 then
        showAutoTip("请输入正确的对方ID!")
        return
    elseif #pass < 6 or #pass > 12 then
        showAutoTip("请输入6到12位的银行密码!")
        return
    elseif checkint(chip) < 10000 then
        showAutoTip("最少赠送筹码数为1万！请重新输入！")
        return
    elseif checkint(chip) > 20e8 then
        showAutoTip("最多赠送筹码数为20亿！请重新输入！")
        return

    end
    self:setEditBox(false)
    chip = checkint(chip)

    Loading.create()
    utils.http(CONFIG.API_URL,
        {
            method = "Amember.getMemBasInfo",
            sesskey =  USER.sessionKey,
            mid = mid
        } , function (data )
            Loading.close()
            if tonumber(data.svflag) ~= 1 then
                self:setEditBox(true)
                showAutoTip("没有找到对方的ID!")
            else
                if not data.data.arr[1] or data.data.arr[1] == "" then
                    showAutoTip("没有找到对方的ID")
                    self:setEditBox(true)
                else
                        createMessageBox("你确定要转账"..chip.."筹码，给玩家"..data.data.arr[1].."吗？",{"取消","确定"} , function (isok)
                        self:setEditBox(true)
                        if isok then
                            Loading.create()
                            SendCMD:turnChip({mid = mid , chip = chip , pass = pass})
                        end
                    end)
                end

            end    

        end,"POST")
end

function BankLayer:changePassWord(old , new , again)
   
    if #old < 6 or #old > 12 then
        showAutoTip("请输入6到12位的银行密码")
    elseif #new < 6 or #new > 12 then
        showAutoTip("请输入6到12位新的银行密码")
    elseif new ~= again then
        showAutoTip("两次密码输入不一致")
    else
        SendCMD:changeBankPassWord({old = old , new = new})
        Loading.create()
    end

    -- body
end


function BankLayer:initButton()
    -- body
    self.btn = {}
    self.btn.chipin = cc.uiloader:seekNodeByTag(self.panel_tab.inchip[2] , 589)      --每个模块下的 确定 按钮
    self.btn.chipout = cc.uiloader:seekNodeByTag(self.panel_tab.outchip[2] , 594)
    self.btn.newpass = cc.uiloader:seekNodeByTag(self.panel_tab.new_pass[2] , 608)
    self.btn.givechip = cc.uiloader:seekNodeByTag(self.panel_tab.givechip[2] , 665)

    function touch_cb(sender , eventType)
        -- body
        if eventType ~= ccui.TouchEventType.ended then
            return
        end
        utils.playSound("click")

        if sender:getTag() == 589 then
            local chip = self.ebox.inchip:getText()
            chip = checkint(chip) * 10000
           
            if chip < 10000 or chip > 1000000000 then
                showAutoTip("存入金币数必须大于1万并且不能超过10亿")
            else
                SendCMD:saveChip({chip = chip})
                Loading.create()
            end
        elseif sender:getTag() == 594 then
            local chip = self.ebox.outchip:getText()
            local pass = self.ebox.outchip_pass:getText()
            chip = checkint(chip) * 10000
            if chip < 0 then
                showAutoTip("请输入取出金币数!")
            elseif #pass < 6 or #pass > 12 then
                showAutoTip("请输入6到12位的银行密码!")
            else
                Loading.create()
                --pass = "1"
                SendCMD:takeChip({chip = chip , pass = pass})
            end
        elseif sender:getTag() == 665 then
            local chip = self.ebox.givechip:getText()
            local mid = self.ebox.target_mid:getText()
            local pass = self.ebox.give_pass:getText()
            chip = checkint(chip) * 10000
            self:giveChip(chip , mid , pass)
        elseif sender:getTag() == 608 then
            local old = self.ebox.old_pass:getText()
            local new = self.ebox.new_pass:getText()
            local again = self.ebox.agin_pass:getText()
            self:changePassWord(old , new , again)

        end
    end

    for k , v in pairs(self.btn) do 
        v:addTouchEventListener(touch_cb)
    end
end

function BankLayer:registerEditBox( ... )
    local edit_cb = function ( strEventName,pSender )
        if strEventName == "changed" then

            local str = pSender:getText()
            local gold = USER.gold
            if checkint(gold) < checkint(str) * 10000 then

                pSender:setText(math.floor(gold/10000))
            -- elseif checkint(str) <= 0 then
                -- pSender:setText("")
            end        
        end
    
    end
    
    self.ebox.inchip:registerScriptEditBoxHandler(edit_cb)
    self.ebox.givechip:registerScriptEditBoxHandler(edit_cb)

    
    local outchip_cb = function ( strEventName , pSender )
        
        if strEventName == "changed" then

            local str = pSender:getText()
            local chip = USER.bankAssets
            if checkint(chip) < checkint(str)* 10000 then
                pSender:setText(math.floor(chip/10000)) 
            -- elseif checkint(str) <= 0 then
                -- pSender:setText("")
            end
        end
    end
    self.ebox.outchip:registerScriptEditBoxHandler(outchip_cb)

end    

function BankLayer:initEditBox()

    -- local img_bk = cc.uiloader:seekNodeByTag(self.panel_tab.inchip[2] , 590)
    local model_panel = cc.uiloader:seekNodeByTag(self.panel_tab.inchip[2] , 589)
    self.ebox = {}

    --  存入金币
    self.ebox.inchip = cc.ui.UIInput.new({
        image = "menu/transparent.png",
        x = 380,
        y = 272,
        size = cc.size(517, 45)
        -- fontSize = 16,
        })

    model_panel:getParent():addChild(self.ebox.inchip)
    self.ebox.inchip:setFontColor(display.COLOR_WHITE)
    self.ebox.inchip:setInputMode(2)
    self.ebox.inchip:setMaxLength(12)
    -- img_bk:setVisible(false)
    self.ebox.inchip:setPlaceHolder("请输入存入筹码数")

    -- 取出金币
    model_panel = cc.uiloader:seekNodeByTag(self.panel_tab.outchip[2] , 594)
    self.ebox.outchip = cc.ui.UIInput.new({
        image = "menu/transparent.png",
        x = 380,
        y = 298,
        size = cc.size(517, 45)
        })
    model_panel:getParent():addChild(self.ebox.outchip)
    self.ebox.outchip:setInputMode(2)
    self.ebox.outchip:setFontColor(display.COLOR_WHITE)
    self.ebox.outchip:setMaxLength(12)
    -- img_bk:setVisible(false)
    self.ebox.outchip:setPlaceHolder("请输入取出筹码数")

    -- 银行密码
    -- img_bk = cc.uiloader:seekNodeByTag(self.panel_tab.outchip[2] , 605)
    self.ebox.outchip_pass = cc.ui.UIInput.new({
        image = "menu/transparent.png",
        x = 380,
        y = 170,
        size = cc.size(517, 45)
        })
    model_panel:getParent():addChild(self.ebox.outchip_pass)
    self.ebox.outchip_pass:setInputFlag(0)
    self.ebox.outchip_pass:setFontColor(display.COLOR_WHITE)
    self.ebox.outchip_pass:setMaxLength(15)
    -- img_bk:setVisible(false)
    self.ebox.outchip_pass:setPlaceHolder("请输入银行密码")

    -- 旧密码
    model_panel = cc.uiloader:seekNodeByTag(self.panel_tab.new_pass[2] , 608)
    self.ebox.old_pass = cc.ui.UIInput.new({
        image = "menu/transparent.png",
        x = 410,
        y = 360,
        size = cc.size(517, 45)
        })
    model_panel:getParent():addChild(self.ebox.old_pass)
    self.ebox.old_pass:setInputFlag(0)
    self.ebox.old_pass:setFontColor(display.COLOR_WHITE)
    self.ebox.old_pass:setMaxLength(10)
    -- img_bk:setVisible(false)
    self.ebox.old_pass:setPlaceHolder("请输入银行密码")

    -- 新密码
    -- model_panel = cc.uiloader:seekNodeByTag(self.panel_tab.new_pass[2] , 608)
    self.ebox.new_pass = cc.ui.UIInput.new({
        image = "menu/transparent.png",
        x = 410,
        y = 265,
        size = cc.size(517, 45)
        })
    model_panel:getParent():addChild(self.ebox.new_pass)
    self.ebox.new_pass:setInputFlag(0)
    self.ebox.new_pass:setFontColor(display.COLOR_WHITE)
    self.ebox.new_pass:setMaxLength(10)
    -- img_bk:setVisible(false)
    self.ebox.new_pass:setPlaceHolder("请输入新的银行密码")

    -- 重复密码
    -- img_bk = cc.uiloader:seekNodeByTag(self.panel_tab.new_pass[2] , 613)
    self.ebox.agin_pass = cc.ui.UIInput.new({
        image = "menu/transparent.png",
        x = 410,
        y = 169,
        size = cc.size(517, 45)
        })
    model_panel:getParent():addChild(self.ebox.agin_pass)
    self.ebox.agin_pass:setInputFlag(0)
    self.ebox.agin_pass:setFontColor(display.COLOR_WHITE)
    self.ebox.agin_pass:setMaxLength(10)
    -- img_bk:setVisible(false)
    self.ebox.agin_pass:setPlaceHolder("请再次输入银行密码")

    -- 对方ID
    model_panel = cc.uiloader:seekNodeByTag(self.panel_tab.givechip[2] , 665)
    self.ebox.target_mid = cc.ui.UIInput.new({
        image = "menu/transparent.png",
        x = 414,
        y = 362,
        size = cc.size(517, 45)
        })
    model_panel:getParent():addChild(self.ebox.target_mid)
    self.ebox.target_mid:setInputMode(2)
    self.ebox.target_mid:setFontColor(display.COLOR_WHITE)
    self.ebox.target_mid:setMaxLength(10)
    -- img_bk:setVisible(false)
    self.ebox.target_mid:setPlaceHolder("请输入赠送ID")

    -- 赠送筹码
    -- img_bk = cc.uiloader:seekNodeByTag(self.panel_tab.givechip[2] , 662)
    self.ebox.givechip = cc.ui.UIInput.new({
        image = "menu/transparent.png",
        x = 414,
        y = 266,
        size = cc.size(517, 45)
        })
    model_panel:getParent():addChild(self.ebox.givechip)
    self.ebox.givechip:setInputMode(2)
    self.ebox.givechip:setFontColor(display.COLOR_WHITE)
    self.ebox.givechip:setMaxLength(10)
    -- img_bk:setVisible(false)
    self.ebox.givechip:setPlaceHolder("请输入赠送筹码数")

    -- 银行密码
    -- img_bk = cc.uiloader:seekNodeByTag(self.panel_tab.givechip[2] , 664)
    self.ebox.give_pass = cc.ui.UIInput.new({
        image = "menu/transparent.png",
        x = 414,
        y = 171,
        size = cc.size(517, 45),
        fontSize = 20
        })
    model_panel:getParent():addChild(self.ebox.give_pass)
    self.ebox.give_pass:setInputFlag(0)
    self.ebox.give_pass:setFontColor(display.COLOR_WHITE)
    self.ebox.give_pass:setMaxLength(10)
    -- img_bk:setVisible(false)
    self.ebox.give_pass:setPlaceHolder("请输入银行密码")

end

-- 请求银行记录
function BankLayer:httpGetBankRecord(page)
    -- body
    Loading.create()    
    utils.http(CONFIG.API_URL,
        {
            method = "Abank.get",
            page = page,
            sesskey = USER.sessionKey,

        },function ( data )
            Loading.close() 
            if data.svflag == 1 then
                for k , v in pairs(data.data.arr) do
                    self.Memory[k] = {}
                    local pot = string.split(v, ",")
                    self.Memory[k].action_id = string.trim(pot[1]) 
                    self.Memory[k].player_id = string.trim(pot[2])
                    self.Memory[k].chip = string.trim(pot[3])
                    self.Memory[k].take_chip = string.trim(pot[4])
                    self.Memory[k].bank_chip = string.trim(pot[5])
                    self.Memory[k].action_time = string.trim(pot[6])
                    -- self.Memory[k].what = pot[7]
                    self.Memory[k].user_name = string.trim(pot[8])

                end
                self:updataBankRecord()
            end
        end,"POST")

end


function BankLayer:updataBankRecord()
    -- body
    local listview = cc.uiloader:seekNodeByTag( self.panel_tab.memory[2] , 687)
    listview:removeAllChildren()

    local mode = cc.uiloader:seekNodeByTag(self.panel_tab.memory[2] , 211)
    mode:setVisible(false)
    
    -- dump(self.Memory)
    if #self.Memory == 0 then
        local item = mode:clone() 
        item:setVisible(true)
        listview:pushBackCustomItem(item)
        local label = item:getChildByName("Text_51")
        label:setString("没有任何记录~")
        item:getChildByName("gold"):setVisible(false)
        item:getChildByName("time"):setVisible(false)
    else
        for k , v in pairs(self.Memory) do
            local item = mode:clone()
            item:setVisible(true)
            listview:pushBackCustomItem(item)       
            item:getChildByTag(481):setString(os.date("%m-%d %H:%M",tonumber(v.action_time)))

            local str = ""      
            if v.action_id == "0" then
                str = "存 入："
            elseif v.action_id == "1" then
                str = "取 出："
            end
            if v.action_id == "0" or v.action_id == "1" then
                -- str = str..utils.numAbbrZh(v.chip).."筹码"
            else
                if v.action_id == "2" then
                    str = str.."赠送给："..v.user_name.."  ("..v.player_id..")"
                else
                    str = str.."收 到："..v.user_name.."  ("..v.player_id..")"
                end    
                -- str = str.." "..utils.numAbbrZh(v.chip).."筹码"
            end

            item:getChildByTag(212):setString(str)
            item:getChildByTag(480):setString(utils.numAbbrZh(v.chip).."金币")

        end    
    end
end

function BankLayer:updateText() 
    -- body
    local take_chip = self.take_chip
    local deposit_chip = self.deposit_chip
    
    take_chip:stopAllActions()
    deposit_chip:stopAllActions()
    
    local offset_take = USER.gold - self.old_take_chip
    local offset_bankAssets = USER.bankAssets - self.old_bank_chip
    
    -- dump(USER.bankAssets)
    -- dump(self.old_bank_chip)

    function stoprun()
        take_chip:setString( "携带：".. utils.numAbbrZh(USER.gold))
        deposit_chip:setString( "存款："..utils.numAbbrZh(USER.bankAssets) )
        self.old_take_chip = USER.gold
        self.old_bank_chip = USER.bankAssets
    end

    function updata()
        -- body
        self.old_take_chip = self.old_take_chip + checkint(offset_take / 20)
        self.old_bank_chip = self.old_bank_chip + checkint(offset_bankAssets / 20)
        take_chip:setString( "携带：".. utils.numAbbrZh(self.old_take_chip))
        deposit_chip:setString( "存款："..utils.numAbbrZh(self.old_bank_chip) )
    end

    local acts = {} 
    for i = 1 , 40 do
        
        if i % 2 == 0 then
            acts[i] = cca.cb(updata)
        else
            acts[i] = cca.delay(0.05)
        end
    end
    acts[41] = cca.cb(stoprun)
    take_chip:runAction(cca.seq(acts))
end    


return BankLayer