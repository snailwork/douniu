local Menu = class("Menu")

function Menu:ctor(game,menu)
    self.parts = {}
    self.parts["menu"] = menu
    self.parts["game"] = game
    local mask = display.newLayer()
        :addTo(menu,-1)
    -- self.parts["panel"]:setTouchEnabled(false)

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(function ( ... )
        self:close()
    end, cc.Handler.EVENT_TOUCH_BEGAN)

    mask:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, mask)
    self.parts["mask"] = mask
    self.parts["listener"] = listener

    
    self.parts["ctype"] = menu:getChildByTag(119)
    self.parts["ctype"]:setVisible(false)
    self.parts["menuLayer"] = menu:getChildByTag(232)
    self.parts["menuLayer"]:setVisible(false)
    self.parts["taskBtn"] = menu:getChildByTag(2)
    for i=1,5 do
        if i < 3 then
            self.parts["menuLayer"]:getChildByTag(i):addTouchEventListener(handler(self, self["menuLayerFun"..i]))
        end
        menu:getChildByTag(i):addTouchEventListener(handler(self, self["fun"..i]))
    end

    self.parts["handler"] = app:addEventListener("app.updateTask",function (event)
        if event.status > 0 then
            self:timeTask()
        else
            self.parts["animationItem"]:removeSelf()
            -- self.parts["taskBtn"]:removeAllChildren()
            self.parts["taskBtn"]:setOpacity(255)
        end
    end)

   
end

function Menu:timeTask( )
    local timeText = self.parts["menu"]:getChildByTag(351)
    local hour,time
    for i,v in pairs(CONFIG.task) do
        if checkint(v.subtype) == 11 and checkint(v.status) < 2 then
            v.comNum = v.comNum or 0 
            time = v.needNum - v.comNum --还需要多少秒
            local handler_ = schedule(self.parts["menu"],function ( )
                if self.parts["game"].gameStatus ~= 1 then return end
                time = time -1
                if time > 0 then
                    hour = checkint(time/3600)
                    if hour <= 0 then
                        hour = os.date("%M",time)..":"..os.date("%S",time)
                    else
                        hour = hour..":" .. os.date("%M",time)..":"..os.date("%S",time)
                    end
                    timeText:setString(hour)
                else
                    timeText:setString("")
                    self.parts["menu"]:stopAction(handler_)
                    self.parts["taskBtn"]:setOpacity(0)

                    local animationItem = cc.CSLoader:createNode("taskAni.csb")
                        :align(display.CENTER, 1138,654)
                        :addTo(self.parts["menu"])

                    self.parts["animationItem"] = animationItem
                    local tl = cc.CSLoader:createTimeline("taskAni.csb")
                    animationItem:runAction(tl)
                    -- tl:setTimeSpeed(0.05)
                    tl:gotoFrameAndPlay(0,50,true)
                end
            end,1)

            break
        end
    end

end

function Menu:btnScale(target, event )
    if event == 0 then
        target:setScale(0.9)
    elseif event == 3 or event == 2 then
        target:setScale(1)
    end
    if event ~= 2 then return false end
    utils.playSound("click")
    return true
end
--退出
function Menu:menuLayerFun1(target, event )
    if not self:btnScale(target, event) then return end
    if self.parts["game"].parts["seats"][USER.seatid].parts["card1"].sp:isVisible() then
        showAutoTip("游戏正在进行中，不能退出房间！")
        return
    end
    self.parts["menuLayer"]:setVisible(false)
    SendCMD:outRoom()
end
--换桌
function Menu:menuLayerFun2(target, event )
    if not self:btnScale(target, event) then return end
    if self.parts["game"].parts["seats"][USER.seatid].parts["card1"].sp:isVisible() then
        showAutoTip("游戏正在进行中，不能切换房间！")
        return
    end
    self.parts["menuLayer"]:setVisible(false)
    local typeId = 29
    for k,v in pairs(CONFIG.roominfo) do
        if v.min <= USER.gold then
            typeId = v.typeId
        end
    end
    for i,v in ipairs(self.parts["game"].parts["seats"]) do
        if v.model.mid == USER.mid then
            v:reset()
        else
            v:stand()
        end
    end
    SendCMD:quickInRoom(1000,typeId)
end

--没牛
function Menu:fun7(target, event )
    if not self:btnScale(target, event) then return end
    SendCMD:noNiu()
end

--有牛
function Menu:fun6(target, event )
    if not self:btnScale(target, event) then return end
    SendCMD:yesNiu()
end


--show menuLayer
function Menu:fun1(target, event )
    if not self:btnScale(target, event) then return end
    self.parts["menuLayer"]:setVisible(true)
    if self.parts["game"].parts["seats"][USER.seatid].parts["card1"].sp:isVisible() then
        self.parts["menuLayer"]:getChildByTag(1):getChildByTag(331):loadTexture("menu/back-dis.png",1)
        self.parts["menuLayer"]:getChildByTag(2):getChildByTag(333):loadTexture("menu/change-dis.png",1)
    else
        self.parts["menuLayer"]:getChildByTag(1):getChildByTag(331):loadTexture("menu/back-hall.png",1)
        self.parts["menuLayer"]:getChildByTag(2):getChildByTag(333):loadTexture("menu/change-room.png",1)
    end

end

--task
function Menu:fun2(target, event )
    if not self:btnScale(target, event) then return end
    self.parts["task"] = require("app.views.Task").new(function ( ... )
            self.parts["task"] = nil
        end)
end

--宝箱
function Menu:fun3(target, event )
  if not self:btnScale(target, event) then return end
end
--card type
function Menu:fun4(target, event )
    if not self:btnScale(target, event) then return end
    self.parts["ctype"]:setVisible(true)
end

--chat
function Menu:fun5(target, event )
   if not self:btnScale(target, event) then return end
    self.parts["game"].parts["chat-layer"]:show()
end

function Menu:close()
    self:yourTrun()
end

function Menu:yourTrun()
    local flag = false
    if self.parts["game"].parts["chat-layer"].parts["chat"]:isVisible() then
        flag = true
    end
    self.parts["game"].parts["chat-layer"]:hide()

    if self.parts["menuLayer"]:isVisible() then
        flag = true
    end
    self.parts["menuLayer"]:setVisible(false)

    if self.parts["ctype"]:isVisible() then
        flag = true
    end
    self.parts["ctype"]:setVisible(false)
    
    if self.parts["task"] then
        self.parts["task"]:hide()
        flag = true
    end
    self.parts["task"] = nil

    return flag
end

return Menu