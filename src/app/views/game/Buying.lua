local Buying = class("Buying")

function Buying:ctor(game)
	self.data = {}
	self.parts = {}
	self.parts["game"] = game
	local sp = cc.uiloader:load("buying.csb"):addTo(game,43)
    	:align(display.CENTER, display.cx, display.cy)
    sp:setVisible(false)
    self.parts["sp"] = sp

    self.parts["panel"] = cc.uiloader:seekNodeByTag(sp, 710)
	self.parts["panel"]:setEnabled(false)
	self.parts["panel"]:setContentSize(display.width,display.height)
   	self.parts["panel"]:addTouchEventListener(handler(self, self.close))

    
    local buying = sp:getChildByTag(9)
    self.parts["buying"] = buying
   	buying:getChildByTag(456):addTouchEventListener(handler(self, self.close))
   	self.parts["buying_text"] = buying:getChildByTag(720)

    buying:getChildByTag(8):addTouchEventListener(handler(self, self.buyingFun))
    self.parts["buying-slider"] = buying:getChildByTag(716)
    self.parts["buying-slider"]:addEventListener(handler(self, self.valueChange))	
    self.parts["mid"] = CONFIG.room100info[1]["min"]
end

function Buying:show()
	self.parts["sp"]:setVisible(true)
	local half = USER.gold/2
	dump(half)
	dump(self.parts["mid"])
	if half < self.parts["mid"] then
		self.data.buying = self.parts["mid"]
	else
		self.data.buying = half
	end
	self.parts["buying-slider"]:setPercent(checkint(self.data.buying / USER.gold * 100))
	self.parts["buying_text"]:setString(utils.numAbbrZh(self.data.buying))
end

function Buying:buyingFun( target,event )
	if event == 0 then
        target:setScale(0.9)
    elseif event == 3 or event == 2 then
        target:setScale(1)
    end
    if event ~= 2 then return false end
    utils.playSound("click")
	if USER.gold < self.data.buying then
		createMessageBox("","您的金币不够带入！您需要去商城购买更多的筹码！",{"取消","去购买"},function ( flag )
	        if flag then
	        	self.parts["sp"]:setVisible(false)
	        	require("app.views.Store").new(self.parts["game"])
	        end
	    end)
	else
		self.parts["sp"]:setVisible(false)
        SendCMD:upDealer(self.data.buying)
	end

end

function Buying:close(target, event )
	dump(event)
	if event == 0 then
        target:setScale(0.9)
    elseif event == 3 or event == 2 then
        target:setScale(1)
    end
    if event ~= 2 then return false end
    utils.playSound("click")
	self.parts["sp"]:setVisible(false)
end

function Buying:valueChange(target, event )
	self.data.buying = self.parts["mid"] + target:getPercent()/100 * (USER.gold - self.parts["mid"])
	if self.data.buying < self.parts["mid"] then
		self.data.buying = self.parts["mid"]
	end
	self.parts["buying_text"]:setString(utils.numAbbrZh(self.data.buying))
	
end

return Buying