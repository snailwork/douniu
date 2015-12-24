local Action = class("Action")

function Action:ctor( game,action)
    self.room = game
	self.action_layer = action
    self.parts={}
    action:setPositionY(action:getPositionY() - (display.height - 720)/2)
    action:getChildByTag(571):setString(utils.numAbbrZh(USER.gold))
    

    for i=1,6 do
        self.parts[i] = action:getChildByTag(i)
        self.parts[i]["dealer"] = display.newSprite("#seat/dealer-light.png")
        :pos(49,51)
        :addTo(self.parts[i])
        self.parts[i]["dealer"]:setVisible(false)

        self.parts[i]:getChildByTag(1):setFontName("Helvetica-Bold")
        self.parts[i]:addTouchEventListener(handler(self, self.chipin))
    end
    action:getChildByTag(571):setString(utils.numAbbrZh(USER.gold))
    self.handler = app:addEventListener("app.updatachip", function(event)
            action:getChildByTag(571):setString(utils.numAbbrZh(USER.gold))
        end)
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

function Action:setDealer(isDealer )
    if isDealer then
        self.parts[7]:getChildByTag(1):setString("申请下庄")
    else
        self.parts[7]:getChildByTag(1):setString("申请上庄")
    end
end


function Action:chipin(target, event )
    if target:getChildByTag(2):isVisible() then return end
    if not self:btnScale(target, event) then return end
    local index = checkint(target:getTag())
    self.parts["data"] = index
    -- SendCMD:chipin(target:getChildByTag(1):getString())
   for i=1,6 do
        self.parts[i]["dealer"]:setVisible(false)
    end
    self.parts[index]["dealer"]:setVisible(true)
end

function Action:startChipin(falg)
    for i=1,6 do
        if USER.gold > self.room.parts["values"][i] then
            self.parts[i]:getChildByTag(2):setVisible(false)
        end
    end
end

function Action:stopChipin(falg)
     for i=1,6 do
        self.parts[i]["dealer"]:setVisible(false)
        self.parts[i]:getChildByTag(2):setVisible(true)
    end
end



return Action