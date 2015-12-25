local GameScene = class("GameScene100", function()
    return display.newScene("GameScene100")
end)
local Seat = require("app.views.game.Seat100")
local GameEvent = require("app.views.game.GameEvent")
local Menu = require("app.views.game.Menu100")
local Action = require("app.views.game.Action100")
local SysMsg = require("app.views.game.SysMsg")
local Chat = require("app.views.game.Chat")
local Interaction = require("app.views.game.Interaction")
local Clock = require("app.views.game.Clock100")


function GameScene:ctor()
   
    CONFIG.lType = 15
    require("app.views.LoadingLayer").new():addTo(self,919)

    local layer = cc.uiloader:load("room100.csb"):addTo(self)
    	:align(display.CENTER, display.cx, display.cy)
    self.parts  ={}
    self.parts["users"] = {}
    self.parts["layer"] = layer
    self.parts["delay"] = {}
    self.parts["add-golds"] = {}
    self.parts["values"] = {100,1000,10000,100000,500000,2000000}

    self.parts["seatPanel"] = layer:getChildByTag(342)
    self.parts["seats"] = {}
    self.parts["seats_"] = {1}
    self.parts["clock"] = Clock.new(layer:getChildByTag(116))
    self.parts["menu"] = Menu.new(self,layer:getChildByTag(302)) 
    self.parts["action"] = Action.new(self,layer:getChildByTag(268)) 

    self.parts["chat-layer"] =  Chat.new(self)
    self.parts["chat-layer"].parts["chat"]:zorder(999)
    self.parts["show_win"] = layer:getChildByTag(799)
    self.parts["show_win"]:setOpacity(0)

    local seat
    for i=1,5 do
        seat =Seat.new(self.parts["seatPanel"]:getChildByTag(i),i)
        table.insert(self.parts["seats"],seat)
        seat.parts["seat"]:setTouchEnabled(true)
        seat.parts["seat"]:addTouchEventListener(handler(self,self.onSeatClick))
    end
    
    for i=12,19 do
        seat = require("app.views.game.Seat100_").new(self.parts["seatPanel"]:getChildByTag(i)) 
        seat.parts["seat"]:setTouchEnabled(true)
        seat.parts["seat"]:addTouchEventListener(handler(self,self.sitClick))
        table.insert(self.parts["seats_"],seat)
    end
    layer:getChildByTag(265):setTouchEnabled(true)
  

    utils.stopMusic()
	self.parts["batchChip"] = Chip:getBatchNode()
        :pos(display.cx,display.cy)
		:addTo(layer,10)

    self.parts["batchAddChip"] =Chip:getBatchNode()
        :pos(display.cx,display.cy)
        :addTo(layer,5)
    self.parts["seatPanel"]:zorder(6)
    layer:getChildByTag(376):zorder(7) --dealer
    layer:getChildByTag(302):zorder(8) --menu
    self.parts["show_win"]:zorder(9) --win界面

	self.parts["event"] = GameEvent.new(self)
    self.parts["sysMsg"] = SysMsg.new(layer:getChildByTag(385))
    SendCMD:inRoom100(1000,CONFIG.room100info[1].beginRid)
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

function GameScene:sitClick(target,event)
    dump(event)
    if event == 0 then
        return true
    elseif event == 2 then
        target:setTouchEnabled(false)
        performWithDelay(target,function()
                target:setTouchEnabled(true)
            end, 0.5)
        -- if checkint(target.model.mid) > 0 then
        --     --显示用户信息
        --     local user_info = require("app.views.UserInfo").new(
        --         {mid = target.model.mid , name = target.model.name, vip = target.model.vip, gold = target.model.gold , icon = target.model.icon},
        --         function ( ... )
        --         self.parts["user_info"] = nil
        --     end)
        --     self.parts["user_info"] = user_info
        -- else
            SendCMD:sit(checkint(target:getTag()) - 10)
        -- end
    end
end


function GameScene:onSeatClick(target,event)
    dump(event)
    if event == 0 then
        return true
    elseif event == 2 then
        utils.playSound("click")
        if checkint(self.parts["action"].parts["data"]) == 0 then return end
        local data = {
            seatid = checkint(target:getTag()),
            gold = self.parts["values"][self.parts["action"].parts["data"]]
        }
        
        dump(self.parts["action"].parts["data"])
        dump(self.parts["values"][self.parts["action"].parts["data"]])
        SendCMD:chipin(data)
       
    end
end


function GameScene:onExit()
    if device.platform == "android" then
        self:setKeypadEnabled(false)
        self:removeNodeEventListener(cc.KEYPAD_EVENT)
    end
    app:removeEventListener(self.parts["menu"].parts["handler"])
    
    utils.stopMusic()
end

function GameScene:addGold(data)
    dump(data)
    local seat = self.parts["seatPanel"]:getChildByTag(data.seatid)
    local c 
    if data.mid  == USER.mid then
        app:dispatchEvent({name = "app.updatachip", nil})
        local point = self.parts["batchAddChip"]:convertToNodeSpace(self.parts["seatPanel"]:getChildByTag(10):convertToWorldSpace(cc.p(40,-82)))
        local to_point = self.parts["batchAddChip"]:convertToNodeSpace(seat:convertToWorldSpace(cc.p(120,120)))
        c = Chip:new(point.x,point.y,self.parts["batchAddChip"])
        c:setScale(0.8)
        to_point.x =  to_point.x + math.random(-100,40)
        to_point.y =  to_point.y + math.random(-100,40)
        local action = transition.sequence({
                    cc.FadeIn:create(0.03),
                    transition.newEasing(cc.MoveTo:create(0.5,to_point),"OUT"),
                })
        c:runAction(action)
    else
        local point = self.parts["batchAddChip"]:convertToNodeSpace(seat:convertToWorldSpace(cc.p(120,120)))
        c = Chip:new(point.x + math.random(-100,40),point.y + math.random(-100,40),self.parts["batchAddChip"])
        c:setScale(0.8)
    end
    table.insert(self.parts["add-golds"],c)
end

function GameScene:moveToSeat(data,callback)
    local seat,to_seat,to_point
   
    seat = self.parts["seats"][1]
    if checkint(USER.seatid) == 0 and data.mid == USER.mid then
        to_seat = self.parts["seatPanel"]:getChildByTag(10)
        to_point = self.parts["batchChip"]:convertToNodeSpace(to_seat:convertToWorldSpace(cc.p(40,-82)))
    else--if data.to_seatid >= 0 and data.to_seatid < 10 then
        to_seat = self.parts["seatPanel"]:getChildByTag(data.to_seatid + 10)
        -- if data.to_seatid == 1 then
        --     to_point = self.parts["batchChip"]:convertToNodeSpace(to_seat:convertToWorldSpace(cc.p(120,120)))
        -- else
            to_point = self.parts["batchChip"]:convertToNodeSpace(to_seat:convertToWorldSpace(cc.p(40,40)))
        -- end
    end

    -- if not seat or not to_seat then return end
    local point = self.parts["batchChip"]:convertToNodeSpace(seat:convertToWorldSpace(cc.p(120,120)))
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

function GameScene:startDice()
    --显示摇骰子的按钮

end


function GameScene:stopDice()
    --显示摇骰子的按钮

end


--
function GameScene:showWin(data)
    if checkint(USER.seatid) == 1 then

        self.parts["show_win"]:getChildByTag(3):setString("闲家")
    else
        self.parts["show_win"]:getChildByTag(3):setString("庄家")
    end

    if data.meWin > 0 then
        self.parts["show_win"]:getChildByTag(800):loadTexture("room/win.png",1)
    else
        self.parts["show_win"]:getChildByTag(800):loadTexture("room/loser.png",1)
    end
    local meWin = utils.numAbbrZh(data.meWin)
    if data.meWin > 0 then
        meWin = "+"..meWin
    else
        meWin = "-"..meWin
    end
    local win = utils.numAbbrZh(data.win)
     if data.win > 0 then
        win = "+"..win
    else
        win = "-"..win
    end
    self.parts["show_win"]:getChildByTag(2):setString(meWin)
    self.parts["show_win"]:getChildByTag(4):setString(win)
    self.parts["show_win"]:setPositionY(200)
    self.parts["show_win"]:setOpacity(255)
    transition.moveTo(self.parts["show_win"],{
        time = 0.5,
        y = 335,
        easing = "SINEOUT",
        onComplete = function ( )
            transition.fadeTo(self.parts["show_win"],{
                delay = 0.5,
                opacity = 0,
                time = 0.5,
                onComplete = function ( )
                    -- win_sp:removeSelf()
                    self.parts["show_win"]:setOpacity(0)
                    self.parts["show_win"]:setPositionY(200)
                end
            })
        end
    })
end

--游戏开始时发牌动画
function GameScene:startDealCard(start)
    dump(start)
    local data = self.parts["seats"]
    local dataSort = {}
    for i=start,#data do
        dataSort[#dataSort +1 ] = data[i]
    end
    for i=1,start-1 do
        dataSort[#dataSort +1 ] = data[i]
    end
    data = dataSort
    
    local batch = self.parts["batchChip"]
    local time,action
    time = 0.3
    start_point = cc.p(0,0)
   for i,v in ipairs(data) do
        performWithDelay(self,function (  )
            for j=1,5 do
                self.parts["delay"][#self.parts["delay"] +1 ] = performWithDelay(self,function (  )
                    -- utils.playSound("startDealCard"..j)
                    local card = display.newSprite("#room100/mj/back.png")
                    card:setPositionY(100)
                    batch:addChild(card)
                    local convert_sp = v.parts["seat"]:getChildByTag(j)
                    action = cc.MoveTo:create(time,batch:convertToNodeSpace(convert_sp:convertToWorldSpace(cc.p(0,0))) )

                  
                    if checkint(v.model.seatid) == checkint(USER.seatid) then
                        transition.scaleTo(card,{scale = 1,time = time,})
                    end
                    transition.execute(card,action,{onComplete = function ( )
                        card:removeSelf(true)
                        convert_sp:setVisible(true)
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


-- function GameScene:calculateCtype(cards)
--     if #cards ~= 5 then return 0 end
--     dump(cards)
--     local niu = false
--     local four = {}
--     local values = {}
--     local val
--      for i,v in pairs(cards) do --四张，炸弹
--         if v and v ~= "-" then
--             four[v] = four[v] or {}
--             table.insert(four[v],v)
--             table.insert(values,v)
--         end
--     end
--     for i,v in pairs(four) do
--         if #v == 4 then
--             niu = true
--             break
--         end
--     end
--     if niu then
--         return 12
--     end
--     table.sort(values)
--     if values[1] == values[2] and values[1] == 10 and values[3] == 9 and values[4] == 8 and values[5] == 3 then
--         return 11
--     end
--     ----------------------------------------------------------
--     val = Card100.calculateValue(table.slice(cards,1,3)) --点数 0点牛牛
--     if val > 0 and  val % 10 == 0 then
--         val = Card100.calculateValue(table.slice(cards,4,5)) --点数 0点牛牛
--         if val > 0 and  val % 10 == 0 then
--             return 10
--         else
--             return val % 10
--         end
--     else
--         return 0
--     end
-- end



return GameScene