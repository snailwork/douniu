local Action = class("Action")

function Action:ctor( game,action)
    self.room = game
	self.action_layer = action
    self.parts={}
    action:setPositionY(action:getPositionY() - (display.height - 720)/2)

    local keys = {"beiBtns","calculate","qiangZhuang","niu"}

    for i=1,4 do
        self.parts[keys[i]] = action:getChildByTag(i)
        self.parts[keys[i]]:setVisible(false)
        self.parts["beiBtns"]:getChildByTag(i):addTouchEventListener(handler(self, self["beiFun"]))
    end
    for i=1,2 do
        self.parts["qiangZhuang"]:getChildByTag(i):addTouchEventListener(handler(self, self["qiangZhuangFun"..i]))
        self.parts["niu"]:getChildByTag(i):addTouchEventListener(handler(self, self["niuFun"..i]))
    end
   -- self:showCalculate(true) 
end


function Action:showQiangZhuang(falg)
    self.parts["qiangZhuang"]:setVisible(falg)
end

function Action:showNiu(falg)
    self.parts["niu"]:setVisible(falg)
end

function Action:showBei(falg)
    if not falg then
        self.parts["beiBtns"]:setVisible(falg)
        return
    end
    dump(self.parts["beiData"])
    for i=1,4 do
         self.parts["beiBtns"]:getChildByTag(i):setTitleText("X"..self.parts["beiData"][i])--getChildByTag(i):getChildByTag(1):setString(self.parts["data"][i])
    end
    self.parts["beiBtns"]:setVisible(falg)
end

function Action:showCalculate(falg)
    self.parts["data"] = {}
    self:clearCalculate()
    self:showNiu(falg)
    self.parts["calculate"]:setVisible(falg)
end

function Action:setCalculate(data)
    self.parts["data"] = self.parts["data"] or {}
    local card = data.card
    local add = true
    local nilIndex 
    local num = #self.parts["data"]
    for i,v in pairs(self.parts["data"]) do
        if v == card then
            add = false
            self.parts["data"][i] = "-"
            num = 3
            self.parts["calculate"]:getChildByTag(i):setString("")
            break
        end
        if v == "-" then
            num = num -1
            nilIndex = i
            break
        end
    end
    if num >= 3 or not self.parts["calculate"]:isVisible() then 
        self.parts["calculate"]:getChildByTag(5):setString("")
        return 
    end
    if add then
        if nilIndex then
            self.parts["data"][nilIndex] = card
        else
            table.insert(self.parts["data"],card)
            nilIndex = #self.parts["data"]
        end
        self.parts["calculate"]:getChildByTag(nilIndex):setString(Card.getValue(card))
    end 
    local cards = {}
    for i,v in ipairs(self.parts["data"]) do
        table.insert(cards,v)
    end
    local val = Card.calculateValue(cards)
    self.parts["calculate"]:getChildByTag(4):setString(val)
    
    if #self.parts["data"] == 3 then
        local typeVal = "没牛"
        if val ~= 0 and val % 10 == 0 then
            for k,v in pairs(self.room.parts["seats"][USER.seatid].parts["cards"]) do
                if not table.indexof(self.parts["data"],v) then
                    table.insert(cards,v)
                end
            end
            val = self.room:calculateCtype(cards)
            typeVal = CONFIG.niuType[val]
            self.parts["ctype"] = val
        end
        self.parts["calculate"]:getChildByTag(5):setString(typeVal)
    -- else
    --     self.parts["calculate"]:getChildByTag(5):setString("")
    end
    
end

function Action:clearCalculate(data)
    for i=1,5 do
        self.parts["calculate"]:getChildByTag(i):setString("")
    end
end

function Action:btnScale(target, event )
    if event == 0 then
        target:setScale(0.9)
    elseif event == 3 or event == 2 then
        target:setScale(1)
    end
    if event ~= 2 then return false end
    utils.playSound("click")
    return true
end

-- function Action:setData(max)
--     dump(max)
--     if checkint(max) <= 0 then
--         return

--     end
--     self.parts["beiData"] = {}
--     self.parts["beiData"][4] = max
--     local step = checkint(max / 4)
--     for i=1,3 do
--         self.parts["beiData"][4-i] = max - i * step
--         if self.parts["beiData"][4-i] < 1 then
--             self.parts["beiData"][4-i] = 1
--         end
--     end
--     dump(self.parts["beiData"])
-- end

--bei
function Action:beiFun(target, event )
    if not self:btnScale(target, event) then return end
    SendCMD:bei({bei = self.parts["beiData"][checkint(target:getTag())]})
    self.room.parts["clock"]:stop()
    self:showBei(false)
end

--qiangzhuang
function Action:qiangZhuangFun1(target, event )
    if not self:btnScale(target, event) then return end
    dump(target:getName())
    -- self:showQiangzhuang(false)
    self.parts["qiangZhuang"]:setVisible(false)
    SendCMD:qiangZhuang({qiang = 0})
    self.room.parts["clock"]:stop()
end

function Action:qiangZhuangFun2(target, event )
    if not self:btnScale(target, event) then return end
    dump(target:getName())
    self.parts["qiangZhuang"]:setVisible(false)
    SendCMD:qiangZhuang({qiang = 1})
    self.room.parts["clock"]:stop()
end

--niu
function Action:niuFun1(target, event )
    if not self:btnScale(target, event) then return end
    self.room.parts["clock"]:stop()
    if #self.parts["data"] >= 3 then
         local cards = {}
        for i,v in ipairs(self.parts["data"]) do
            table.insert(cards,v)
        end
        for k,v in pairs(self.room.parts["seats"][USER.seatid].parts["cards"]) do
            if not table.indexof(self.parts["data"],v) then
                table.insert(cards,v)
            end
        end
        self.parts["ctype"] = self.parts["ctype"] or 0
        SendCMD:niu({ctype = self.parts["ctype"],cards = cards})
    end
    self:showCalculate(false)
end

function Action:niuFun2(target, event )
    if not self:btnScale(target, event) then return end
    self.room.parts["clock"]:stop()
    local cards = self.room.parts["seats"][USER.seatid].parts["cards"]
    SendCMD:niu({ctype = 0,cards = cards})
    self:showCalculate(false)
end


return Action