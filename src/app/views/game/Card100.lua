local Card = class("Card")

function Card:ctor(data)
    self.sp = data.batchnode
    self.bigScale = data.scale
    data.val = checkint(data.val)
    self.value = checkint(data.val) or 0
    
    local face = display.newSprite("#room100/mj/back.png")
        :addTo(data.batchnode)
    self.face = face
    self.numSp = display.newSprite()
            :addTo(face)
            :pos(28,50)
    if self.value > 0 then
        self:setFaceSprite()
    end
end

function Card:setFaceSprite()
    -- do return end
	--change 牌的显示
	self.face:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame("room100/mj/face.png"))
    performWithDelay(self.sp,function()
        dump("room100/mj/"..self.value.."b.png")
        self.numSp:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame("room100/mj/"..self.value.."b.png"))
        self.numSp:setVisible(true)
    end,0.02)

end

function Card:changeVal(val,quick)
    val = checkint(val)
    self.value = val
    
    if val == 0 or self._fliped then
        self.face:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame("room100/mj/back.png"))
        self.numSp:setVisible(false)
        self._fliped = false
        if val == 0 then
            return
        end
    end
    if quick then
        self:setFaceSprite()
    else
        self:flip()
    end
end

function Card:flip()
    if self.value == 0 or self._fliped then return end
    dump(self.bigScale)
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


return Card