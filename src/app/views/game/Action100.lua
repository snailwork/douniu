local Action = class("Action")

function Action:ctor( game,action)
    self.room = game
	self.action_layer = action
    self.parts={}
    action:setPositionY(action:getPositionY() - (display.height - 720)/2)

    for i=1,6 do
        self.parts[i]:getChildByTag(1):setFontName("Helvetica-Bold")
        self.parts[i]:addTouchEventListener(handler(self, self.chipin))
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
    self.parts["data"] = checkint(target:getTag())
    -- SendCMD:chipin(target:getChildByTag(1):getString())
end

function Action:startChipin(falg)
    for i=1,6 do
        self.parts[i]:getChildByTag(2):setVisible(false)
    end
end

function Action:stopChipin(falg)
     for i=1,6 do
        self.parts[i]:getChildByTag(2):setVisible(true)
    end
end



return Action