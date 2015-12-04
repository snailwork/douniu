
local HallScene = class("HallScene", function()
    return display.newScene("HallScene")
end)

function HallScene:ctor()
    self.parts= {}
    self.parts["item"] = {}
    local hall = cc.uiloader:load("hall.csb"):addTo(self)
    self.parts["hall"] = hall
    local top = require("app.views.Top").new(hall:getChildByTag(182),self)
    self.parts["top"] = top
    
    local listview = hall:getChildByTag(294):getChildByTag(504)
    self.parts["listview"] = listview
    local model = hall:getChildByTag(294):getChildByTag(1)
    self.parts["model"] = model
    model:setVisible(false)
   
    for i=1,9 do
        if i <= 3 then
    	   hall:getChildByTag(i):addTouchEventListener(handler(self, self["fun"..i]))
        else
           hall:getChildByTag(508):getChildByTag(i):addTouchEventListener(handler(self, self["fun"..i]))
        end
    end
    self:initOnLine()

    if device.platform == "android" then
        self:setKeypadEnabled(true)
        self:addNodeEventListener(cc.KEYPAD_EVENT, handler(self,self.androidBack))
    end
end

function HallScene:initOnLine(  )
    utils.http(CONFIG.API_URL , 
            {
                method = "Alogin.getOnline",
                sesskey = USER.sessionKey,
                
                },
            function (data )
                if data.svflag ~= 1 then
                    -- createPromptBox("获取排行榜数据出错!")
                else
                    for k,v in pairs(data.data.arr) do
                        -- dump(v)
                        local item = self.parts["model"]:clone()
                        item:setVisible(true)

                        item:getChildByTag(1):setString(v[2])
                        item:getChildByTag(2):setString(utils.numAbbrZh(v[5]))
                        if v[7] == 1 then
                            if checkint(v[12]) == 0 then
                                item:getChildByTag(3):setString("大厅")
                            else
                                item:getChildByTag(3):setString("房间:"..v[12])
                            end
                        else
                            item:getChildByTag(3):setColor(cc.c3b(149,149,149))
                            item:getChildByTag(3):setString("不在线")
                        end

                        item:addTouchEventListener(function (target, event)
                            if event ~= ccui.TouchEventType.ended then
                                return
                            end
                            utils.playSound("click")
                            local user_info = require("app.views.UserInfo").new(
                                {mid = v[1], name = v[2], vip = v[4], gold = v[5] , icon = v[3]},function ( ... )
                                                                            self.parts["item"]["UserInfo"] = nil
                                                                        end)
                            
                            self.parts["item"]["UserInfo"] = user_info
                    end)

                        local icon = display.newSprite("default.png")
                        icon:setPosition(cc.p(78 , 45))
                        item:addChild(icon)
                        icon:setAnchorPoint(cc.p(0.5 , 0.5))
                        -- v[2] = "http://s0.hao123img.com/res/r/image/2015-06-05/f977d95f1e32030f9b2531b4d9c35cf0.jpg"
                        utils.loadImage(v[2] , function ( succ, ccimage )
                            if succ then
                                 local ret,errMessage = xpcall(function ( ... )
                                    icon:setTexture(ccimage)
                                    local size = icon:getContentSize()
                                    if size.width > size.height then
                                        scale = 78/size.width
                                    elseif size.height > size.width then
                                        scale = 78/size.height
                                    else
                                        scale = 78/size.height
                                    end
                                    icon:setScale(scale)
                                end,function ( ... )
                                end)
                                
                                
                            end
                        end)

                        local size = icon:getContentSize()
                        if size.width > size.height then
                            scale = 78/size.width
                        elseif size.height > size.width then
                            scale = 78/size.height
                        else
                            scale = 78/size.height
                        end
                        icon:setScale(scale)

                        local headMask = "#rank/mask.png"
                        head = display.newSprite(headMask)
                            :pos(78 , 45)
                            :addTo(item)

                        self.parts["listview"]:pushBackCustomItem(item)
                    end
                end
            end,"POST")
    
end

function HallScene:updataNewsCount()
    local count = 0
    for k , v in ipairs(CONFIG.news) do
        if v.status == 1 then
            count = count + 1
        end
    end
    if count > 0 then
        self.parts["top"].parts["count_img"]:setVisible(true)
    else    
        self.parts["top"].parts["count_img"]:setVisible(false)
    end
end

function HallScene:btnScale(target, event )
    if event == 0 then
        target:setScale(0.9)
    elseif event == 3 or event == 2 then
        target:setScale(1)
    end
    if event ~= 2 then return false end
    utils.playSound("click")
    return true
end

--100
function HallScene:fun1(target, event )
    if not self:btnScale(target, event) then return end
    display.replaceScene(require("app.scenes.GameScene").new())
    
end

--douniu RoomlistScene
function HallScene:fun2(target, event )
    if not self:btnScale(target, event) then return end
    display.replaceScene(require("app.scenes.RoomlistScene").new(self.data))
end
--slot
function HallScene:fun3(target, event )
    if not self:btnScale(target, event) then return end
end
--shop
function HallScene:fun4(target, event )
    if not self:btnScale(target, event) then return end
    self.parts["top"].parts["head"]:setVisible(false)
    self.parts["hall"]:setOpacity(0)
    performWithDelay(self.parts["hall"],function ( ... )
        self.parts["hall"]:setOpacity(255)
        self.parts["top"].parts["head"]:setVisible(true)
    end,1)
    self.parts["item"]["Store"] =require("app.views.Store").new(function (  )
            self.parts["item"]["Store"] = nil
        end)
end

--more
function HallScene:fun5(target, event )
    if not self:btnScale(target, event) then return end
end

--task
function HallScene:fun6(target, event )
    if not self:btnScale(target, event) then return end
    self.parts["item"]["Task"] = require("app.views.Task").new(function (  )
            self.parts["item"]["Task"] = nil
        end)
end

--bank
function HallScene:fun7(target, event )
    if not self:btnScale(target, event) then return end
    if USER.bankpasswd ~= nil and USER.bankpasswd ~= "" and USER.bankpasswd ~= 0 then
        self.parts["item"]["Bank"] = require("app.views.Bank").new(function (  )
            self.parts["item"]["Bank"] = nil
        end)
    else
        self.parts["item"]["OpenBank"] = require("app.views.OpenBank").new(function (  )
            self.parts["item"]["OpenBank"] = nil
        end)
    end

end
--activity
function HallScene:fun8(target, event )
    if not self:btnScale(target, event) then return end
end

--rank
function HallScene:fun9(target, event )
    if not self:btnScale(target, event) then return end
    self.parts["item"]["Ranking"] =require("app.views.Ranking").new(function (  )
            self.parts["item"]["Ranking"] = nil
        end,self)
end

function HallScene:showFeedback(about)
    self.parts["item"]["feedback"] = require("app.views.FeedBack").new(function ()
        self.parts["item"]["feedback"] = nil
    end,about)
end

function HallScene:onExit()
    self.parts["top"]:hide()
end

function HallScene:androidBack(event)
    if event.key == "back" then
        for k , v in pairs(self.parts["item"]) do
            if v then
                v:hide()
                if k == "trumpet" then
                    self.parts["systemnews"]:setVisible(true)
                end
                return
            end
        end
        showDialogTip("确定退出游戏吗？",{"取消","确定"},function ( flag )
            if flag then
                exitApp()
            end
        end)
    end
end


return HallScene
