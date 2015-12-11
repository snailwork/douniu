local Card = class("Card")

function Card:ctor(data)
    self.sp = data.batchnode
    self.bigScale = data.scale
    if data.val then
	   self:parseValue(data.val)
    end
    self:getFaceSprite(data.batchnode)
    self.mask = display.newSprite("#card/face_mask.png"):addTo(data.batchnode)
    self.mask:setVisible(false)
end

function Card:parseValue(val)
	self.value_str = val or "-"
	if self.value_str ~= "-" then
    	self.value = string.sub(val,1,1)
    	self.suit = string.sub(val,2,2)
    	--区分j q k
    	if table.indexof({"J","Q","K"},self.value) then
    		self.b_suit = self.value_str
    	else
    		self.b_suit = self.suit
    	end
    else
        self.value = nil
    end
end

function Card.getValue(val)
    return checkint(CONFIG.cardVal[Card.getFace(val)])
end

function Card.calculateValue(cards)
    local val = 0
    for k,v in pairs(cards) do
        if v ~= "-" then 
            val = val + checkint(CONFIG.cardVal[Card.getFace(v)])
        end
    end
    return val
end

function Card.getFace(val)
    if val == "-" then return 0 end
    return string.sub(val,1,1)
end

function Card.getSuit(val)
    if val == "-" then return nil end
    return string.sub(val,2,2)
end

function Card:getFaceSprite(sp)
	local face
    local numX = 28
    local suitX = 66
    if self.value and self.value ~= "-" then
        face = display.newSprite("#card/face.png")
        if sp then
            sp:addChild(face)
        end
        local face_str = self.value
    --区分红黑
        if table.indexof({"c","h"},self.suit) then
            face_str = "0"..self.value
        end
        self.numSp = display.newSprite("#card/"..face_str..".png")
            :addTo(face)
            :pos(numX,144)
        --小花色
        self.sSuitSp = display.newSprite("#card/"..self.suit.."s.png")
            :addTo(face)
            :pos(numX,98)
        --大花色
        self.bSuitSp = display.newSprite("#card/"..self.b_suit..".png")
            :addTo(face)
            :pos(suitX,80)
    else
        face = display.newSprite("#card/back.png")
        if sp then
            sp:addChild(face)
        end
        self.numSp = display.newSprite()
            :addTo(face)
            :pos(numX,144)
        --小花色
        self.sSuitSp = display.newSprite()
            :addTo(face)
            :pos(numX, 98)
        --大花色
        self.bSuitSp = display.newSprite()
            :addTo(face)
            :pos(suitX,80)
    end
    -- face:pos(24, 23)
	self.face = face
    return face
end

function Card:setFaceSprite()
	local face_str = self.value
	--区分红黑
	if table.indexof({"c","h"},self.suit) then
		face_str = "0"..self.value
	end
    if not face_str then return end
	--change 牌的显示
	self.face:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame("card/face.png"))
    performWithDelay(self.sp,function()
        self.numSp:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame("card/"..face_str..".png"))
        self.sSuitSp:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame("card/"..self.suit.."s.png"))
        self.bSuitSp:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame("card/"..self.b_suit..".png"))
        self.numSp:setVisible(true)
        self.sSuitSp:setVisible(true)
        self.bSuitSp:setVisible(true)
    end,0.02)

end


function Card:changeVal(val,quick)
    self:normal()
    self.value_str = val or "-"
    -- if val == self.value_str and val ~= "-" then
    --     self:setFaceSprite()
    --     return
    -- end
    if val == "-" or self._fliped then
        self.face:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame("card/back.png"))
        self.numSp:setVisible(false)
        self.sSuitSp:setVisible(false)
        self.bSuitSp:setVisible(false)
        self._fliped = false
        if val == "-" then
        	self.value  = nil
        	self.suit = nil
        	self.b_suit = nil
            return
        end
    end
    self:parseValue(val)
    if quick then
        self:setFaceSprite()
    else
        self:flip()
    end
end

function Card:flip()
    if self.value_str == "-" or self._fliped then return end
    local time = 0.15
    local a1 = cc.ScaleBy:create(time,-0.01,1.2)
    local a2 = cc.ScaleTo:create(time,self.bigScale and self.bigScale or 1,self.bigScale and self.bigScale or 1)
    local action = transition.sequence({a1,a2})
    self.sp:runAction(action)
    performWithDelay(self.sp,function()
        self:setFaceSprite()
    end,time)
    self._fliped = true
end

function Card:gray()
    self.mask:setVisible(true)
end

function Card:normal()
    self.mask:setVisible(false)
end

return Card