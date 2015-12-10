local GameScene = class("GameScene", function()
    return display.newScene("GameScene")
end)
local Seat = require("app.views.game.Seat")
local GameEvent = require("app.views.game.GameEvent")
local Menu = require("app.views.game.Menu")
local Action = require("app.views.game.Action")
local SysMsg = require("app.views.game.SysMsg")
local Chat = require("app.views.game.Chat")
local Interaction = require("app.views.game.Interaction")
local Clock = require("app.views.game.Clock")


function GameScene:ctor(data)
    data = data or {typeId = 29}
    -- data = {typeId = 29}
    for k,v in pairs(CONFIG.roominfo) do
        if v.min <= USER.gold then
            data.typeId = v.typeId
        end
    end
    CONFIG.lType = 15
    require("app.views.LoadingLayer").new():addTo(self,919)

    local layer = cc.uiloader:load("room.csb"):addTo(self)
    -- local room = cc.CSLoader:createNode("room.csb"):addTo(self)
    	:align(display.CENTER, display.cx, display.cy)
    self.parts  ={}
    self.parts["layer"] = layer
    self.parts["delay"] = {}
    self.parts["seatPanel"] = layer:getChildByTag(342)
    self.parts["dealer_card"] = layer:getChildByTag(377)
    self.parts["dealer_card"]:setVisible(false)
    self.parts["dealer"] = layer:getChildByTag(376)
    -- self.parts["dealer"]:setVisible(false)
    self.parts["dealer"]:setOpacity(0)
    self.parts["seats"] = {}
    self.parts["clock"] = Clock.new(layer:getChildByTag(116))
    self.parts["menu"] = Menu.new(self,layer:getChildByTag(302)) 
    self.parts["action"] = Action.new(self,layer:getChildByTag(268)) 
    -- layer:getChildByTag(302):setTouchEnabled(false)

    self.parts["chat-layer"] =  Chat.new(self)
    self.parts["chat-layer"].parts["chat"]:zorder(999)
    
    -- self.parts["inputPanel"] = layer:getChildByTag(239)
    -- self.parts["inputPanel"]:zorder(1000)
    -- self.parts["inputPanel"]:setVisible(false)
    -- self.parts["input"] = self.parts["inputPanel"]:getChildByTag(240)

    local seat
    for i=1,5 do
        seat =Seat.new(self.parts["seatPanel"]:getChildByTag(i),i)
        table.insert(self.parts["seats"],seat)
        if i == 3 then
            for j=1,5 do
                seat.parts["seat"]:getChildByTag(j+20):addTouchEventListener(handler(self,self.setCalculate))
                seat.parts["seat"]:setTouchEnabled(true)
                seat.parts["seat"]:addTouchEventListener(self:onSeatClick(seat))
            end
        end

    end
    layer:getChildByTag(265):setTouchEnabled(true)
  

    utils.stopMusic()
	self.parts["batchChip"] = Chip:getBatchNode()
        :pos(display.cx,display.cy)
		:addTo(layer,10)

	self.parts["event"] = GameEvent.new(self)
    self.parts["sysMsg"] = SysMsg.new(layer:getChildByTag(385))
    SendCMD:quickInRoom(1000,data.typeId)
    -- self.parts["delay-http"] = performWithDelay(self,function ( ... )
    --     showDialogTip("网络连接出错，请检查wifi是否连接正常" , {"确定"} , function (isOK)
    --             display.replaceScene(require("app.scenes.LoginScene").new(self.data))
    --         end)
    -- end,5)

    if device.platform == "android" then
        self:setKeypadEnabled(true)
        self:addNodeEventListener(cc.KEYPAD_EVENT, function(event)
            if event.key == "back" then
                self:yourTrun()
            end
        end)
    end
end


function GameScene:onSeatClick(seat_)
    return function(target,event)
        dump(event)
        if event == 0 then
            return true
        elseif event == 2 then
            utils.playSound("click")
            target:setTouchEnabled(false)
            performWithDelay(target,function()
                    target:setTouchEnabled(true)
                end, 0.5)
            if checkint(seat_.model.mid) > 0 then
                --显示用户信息
                local user_info = require("app.views.UserInfo").new(
                    {mid = seat_.model.mid , name = seat_.model.name, vip = seat_.model.vip, gold = seat_.model.gold , icon = seat_.model.icon},
                    function ( ... )
                    self.parts["user_info"] = nil
                end)
                self.parts["user_info"] = user_info
            end
        end
    end
end

-- --决定庄家
-- function GameScene:decisionDealer()
--     self.scheduler = schedule(self,self.onEnterFrame,0.2)
-- end

local index = 1
function GameScene:onEnterFrame()
    local data = self.parts["qiangData"]
    -- for i,v in ipairs(self.parts["dealerData"]) do
    --     table.insert(data,self.parts["seats"][v])
    -- end
    -- for i,v in ipairs(self.parts["seats"]) do
    --     if v.model.mid > 0 then
    --         table.insert(data,v)
    --     end
    -- end
    table.sort(data,function(a,b) --从小到大的座位号排序
        return a.model.baseId < b.model.baseId
    end)
    -- data = self.parts["seats"]
    for i,v in ipairs(data) do
        if i == index then
            v.parts["dealer"]:setVisible(true)
            if v.model.seatid == self.parts["dealer-seatid"] then
                    for i1,v1 in ipairs(data) do
                        if v1.model.seatid ~= self.parts["dealer-seatid"] then
                            v1.parts["dealer"]:setVisible(false)
                        end
                    end
                self.parts["dealer-seatid"] = -1
                -- transition.stopTarget(self.scheduler)
                transition.removeAction(self.scheduler)
                performWithDelay(self,function ( )
                    v.parts["dealer"]:setVisible(false)
                   
                    self.parts["dealer"]:setScale(4)
                    self:setDealerPos(v)
                    transition.fadeIn(self.parts["dealer"],{scale = 1,time = 0.1,})
                    transition.scaleTo(self.parts["dealer"],{scale = 1,time = 0.3,})
                end,1)
                index = 1
                break
            end
        else
            v.parts["dealer"]:setVisible(false)
        end
    end
    index  = index + 1
    if index > #data then
        index = 1
    end
end

function GameScene:setDealerPos(seat)
    local _x = -22
    if table.indexof({5,4},seat.model.seatid) then
        _x = 55
    end
    self.parts["dealer"]:setPosition(seat.parts["seat"]:getPositionX() + _x,seat.parts["seat"]:getPositionY()+60)
end

function GameScene:setDealer(seatid)
    if not self.parts["dealerData"] then return end
    local qiang = {}
    for i,v in ipairs(self.parts["dealerData"]) do
        if v.qiang == 1 then
            table.insert(qiang,self.parts["seats"][v.seatid])
        end
    end
    if #qiang == 0 then
        for i,v in ipairs(self.parts["seats"]) do
            if v.model.mid > 0 then
                table.insert(qiang,v)
            end
        end
    end
    -- dump(qiang)
    self.parts["qiangData"] = qiang
    if self.scheduler then
        transition.removeAction(self.scheduler)
    end
    if #qiang > 1 then
        self.scheduler = schedule(self,self.onEnterFrame,0.2)
        performWithDelay(self,function ( )
            self.parts["dealer-seatid"] = seatid
        end,2)
    else
        local seat = self.parts["seats"][seatid]
        seat.parts["dealer"]:setVisible(true)
        performWithDelay(self,function ( )
            seat.parts["dealer"]:setVisible(false)
            self:setDealerPos(seat)
            self.parts["dealer"]:setScale(4)
            transition.fadeIn(self.parts["dealer"],{scale = 1,time = 0.1,})
            transition.scaleTo(self.parts["dealer"],{scale = 1,time = 0.3,})
         end,1)
    end
    
    dump(seatid)
end

function GameScene:clear()
    for i=1,5 do
        self.parts["seatPanel"]:getChildByTag(i):setVisible(false)
    end
end


function GameScene:onExit()
    if device.platform == "android" then
        self:setKeypadEnabled(false)
        self:removeNodeEventListener(cc.KEYPAD_EVENT)
    end
    utils.stopMusic()
end


function GameScene:moveToSeat(seatid,to_seatid,callback)
    local seat,to_seat
    for i,v in ipairs(self.parts["seats"]) do
        if v.model.seatid == seatid then
            seat = v.parts["seat"]
        elseif v.model.seatid == to_seatid then
            to_seat = v.parts["seat"]
        end
    end
    if not seat or not to_seat then return end
    -- local seat = self.parts["seatPanel"]:getChildByTag(seatid)
    -- local to_seat = self.parts["seatPanel"]:getChildByTag(to_seatid)
    local point = self.parts["batchChip"]:convertToNodeSpace(seat:convertToWorldSpace(cc.p(120,120)))
    local to_point = self.parts["batchChip"]:convertToNodeSpace(to_seat:convertToWorldSpace(cc.p(120,120)))
    local t,action = 0.4
    local distance = cc.pGetDistance(point,to_point)
    local num = math.random(15,30)
    if distance < 400 then
        distance = 400
    end
    t = t * distance / 200 - ((distance / 200)/ 5 )
    for i=1,num do
        local c = Chip:new(point.x + math.random(-40,40),point.y + math.random(-40,40),self.parts["batchChip"])
        -- to_point.x = to_point.x + math.random(-10,10)
        -- to_point.y = to_point.y + math.random(-10,10)
        action = transition.sequence({
                    -- cc.DelayTime:create(( i ) * 0.03 ),
                    cc.FadeIn:create(( i ) * 0.03),
                    cc.Spawn:create({
                        transition.newEasing(cc.MoveTo:create(t,to_point),"OUT"),
                        transition.sequence({
                            cc.DelayTime:create(t/1.5),
                            transition.newEasing(cc.FadeTo:create(t/2,0),"IN"),
                            })
                    }),
                    cc.CallFunc:create(function() 
                        c:removeSelf()
                        if i == num and callback then
                            callback()
                        end
                    end)
                })
        c:runAction(action)
    end
end

--游戏开始时发牌动画
function GameScene:startDealCard(cards)
    self.parts["dealer"]:setOpacity(0)
    self.parts["dealer_card"]:setVisible(true)
    local data = {}
    for i,v in ipairs(self.parts["seats"]) do
        v:reset()
        if v.model.mid > 0 then
            if v.model.mid == USER.mid then
                 table.insert(data,1,v)
            else
                table.insert(data,v)
            end
        end
    end
    
    -- data = self.parts["seats"]
    -- USER.seatid = 3

    local batch = self.parts["batchChip"]
    local time,action
    time = 0.5
    start_point = cc.p(0,0)
   for i,v in ipairs(data) do
        performWithDelay(self,function (  )
            for j=1,5 do
                self.parts["delay"][#self.parts["delay"] +1 ] = performWithDelay(self,function (  )
                    -- utils.playSound("startDealCard"..j)
                    local card = display.newSprite("#card/back.png")
                    card:setPositionY(100)
                    card:setScale(0.53)
                    batch:addChild(card)
                    local convert_sp = v.parts["seat"]:getChildByTag(j)
                    action = cc.MoveTo:create(time,batch:convertToNodeSpace(convert_sp:convertToWorldSpace(cc.p(0,0))) )

                    if #data == i and j == 5 then
                        self.parts["dealer_card"]:setVisible(false)
                    end
                    if checkint(v.model.seatid) == checkint(USER.seatid) then
                        transition.scaleTo(card,{scale = 1,time = time,})
                    end
                    transition.execute(card,action,{onComplete = function ( )
                        card:removeSelf(true)
                        convert_sp:setVisible(true)
                        if v.model.mid == USER.mid and j == 5 then
                            self.parts["delay"][#self.parts["delay"] +1 ] = performWithDelay(self,function()
                                self.parts["seats"][USER.seatid]:showCard(1,3,cards,false,function ( )
                                    
                                    self.parts["action"]:showQiangZhuang(true)
                                    self.parts["clock"]:start(10,function ( )
                                        self.parts["action"]:showQiangZhuang(false)
                                    end)
                                end)
                            end, 0.1)
                        end
                    end})
                end,j*0.1)
            end
        -- v:showNiuType(i)
        end,i*0.3)
    end

end

--加聊天表情
function GameScene:addChatFace(data)
    if self.parts["chat-layer"] then
        for k,u in pairs(self.parts["seats"]) do
            if checkint(u.model.mid) == checkint(data.mid) then
                data.name = u.model.name
                break
            end
        end
        self.parts["chat-layer"]:addFace(data)
    end
end

function GameScene:playInteraction(data)
    local props = display.newSprite(data.png)
        :addTo(self.parts["seatPanel"],40)
        :pos(data.seat.sp:getPosition())
        
    transition.moveTo(props,{
            x = self.parts["croupier"]:getPositionX(),
            y = self.parts["croupier"]:getPositionY(),
            time = 0.5,
            onComplete = function (  )
                props:removeSelf()
                local _props = {}
                _props[6] = "kiss"
                _props[8] = "rouse"
                _props[9] = "egg"
                _props[10] = "dog"
                if data.pframe ~= 10 then
                    utils.playSound(_props[data.pframe])
                end
                local animation = cc.CSLoader:createNode(_props[data.pframe]..".csb")
                    :align(display.CENTER, 86, 86)
                    :addTo(self.parts["croupier"],20)
                local tl = cc.CSLoader:createTimeline(_props[data.pframe]..".csb")
                animation:runAction(tl) 
                tl:setTimeSpeed(0.5)
                tl:gotoFrameAndPlay(0,false)
                self:performWithDelay(function ( ... )
                    animation:removeSelf()
                end,1)
            end
        })
end

function GameScene:sendInteraction(data)
   
    local to_seat,from_seat
    for k,v in pairs(self.parts["seats"]) do
        if v.model.mid == data.to_mid then
            to_seat = v
        elseif v.model.mid == data.mid then
            from_seat = v
            v.model.gold = data.gold
        end
    end
    if data.mid == USER.mid then
        USER.gold = data.gold
    end
        
    local png
    local _props = {}
    
    _props[6] = "#interaction/qinwu1.png"
    _props[8] = "#interaction/hua.png"
    _props[9] = "#interaction/jidan.png"
    _props[10] = "#interaction/fenggou2.png"
    png = _props[data.pframe]
     
    if not from_seat or not to_seat then return end
    local props = display.newSprite(png)
        :addTo(self.parts["seatPanel"],40)
        :pos(from_seat.sp:getPosition())

    transition.moveTo(props,{
            x = to_seat.sp:getPositionX(),
            y = to_seat.sp:getPositionY(),
            time = 0.5,
            -- easing = "BACKOUT",
            onComplete = function (  )
                props:removeSelf()
                
                _props[6] = "kiss"
                _props[8] = "rouse"
                _props[9] = "egg"
                _props[10] = "dog"
                if data.pframe ~= 10 then
                    utils.playSound(_props[data.pframe])
                end
                local animation = cc.CSLoader:createNode(_props[data.pframe]..".csb")
                    :align(display.CENTER, 86, 86)
                    :addTo(self.parts["croupier"],20)
                local tl = cc.CSLoader:createTimeline(_props[data.pframe]..".csb")
                animation:runAction(tl) 
                tl:setTimeSpeed(0.5)
                tl:gotoFrameAndPlay(0,false)
                self:performWithDelay(function ( ... )
                    animation:removeSelf()
                end,1)
            end
        })
end


function GameScene:yourTrun(flag)
    local flag = true
    

    if self.parts["menu"]:yourTrun() then
        flag = false
    end
    if self.parts["user_info"] then
        flag = false
        if self.parts["user_info"].store then
            self.parts["user_info"].store:hide()
            self.parts["user_info"].store = nil
        end
        self.parts["user_info"]:hide()
        self.parts["user_info"] = nil
    end
    self.parts["user_info"] = nil
    
    if flag then
        showDialogTip("确定退出房间吗？",{"取消","确定"},function ( flag )
            if flag then
                SendCMD:outRoom()
            end
        end)
    end
end


function GameScene:calculateCtype(cards)
    if #cards ~= 5 then return 0 end
    dump(cards)
    local niu = true
    for i,v in pairs(cards) do --五小牛
        if Card.getValue(v) > 3 then
            niu = false
            break
        end
    end
    if niu then
        return 14
    end
    ----------------------------------------------------------
    niu =true
    for i,v in pairs(cards) do --五花牛
        dump(Card.getValue(v))
        if Card.getValue(v) < 10 then
            niu = false
            break
        end
    end
    if niu then
        return 13
    end
    ----------------------------------------------------------
    local four = {}
    local val
     for i,v in pairs(cards) do --四张，炸弹
        if v and v ~= "-" then
            val = Card.getFace(v)
            four[val] = four[val] or {}
            table.insert(four[val],v)
        end
    end
    for i,v in pairs(four) do
        if #v == 4 then
            niu = true
            break
        end
    end
    if niu then
        return 12
    end
    ----------------------------------------------------------
    val = Card.calculateValue(table.slice(cards,1,3)) --点数 0点牛牛
    if val > 0 and  val % 10 == 0 then
        val = Card.calculateValue(table.slice(cards,4,5)) --点数 0点牛牛
        if val > 0 and  val % 10 == 0 then
            return 10
        else
            return val % 10
        end
    else
        return 0
    end
end

function GameScene:setCalculate(target, event )
    if event ~= 2 then return false end
    local index = checkint(target:getTag()) - 20
    local card = self.parts["seats"][USER.seatid].parts["card"..index]
    if not card.value_str or card.value_str == "-" then
        return
    end
    self.parts["action"]:setCalculate({card = card.value_str,index = index})
end

return GameScene