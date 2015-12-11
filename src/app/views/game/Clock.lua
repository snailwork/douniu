local Clock  =  class("Clock")

function Clock:ctor(sp)
    sp:setVisible(false)
    self.parts ={}
    self.parts["clock"] = sp
    self.parts["text"] = sp:getChildByTag(1)

    local progress = cc.ProgressTimer:create(display.newSprite("#room/clock.png"))
    progress:setType(display.PROGRESS_TIMER_RADIAL)
    -- progress:setReverseDirection(true)
    progress:setPosition(58,58)
    sp:addChild(progress)

    self.parts["progress"] = progress
    -- self:start(10)
end


function Clock:timer(val,callback)
    return function()
        val = val - 1
        self.parts["text"]:setString(val)
        if val <= 0 then
            if callback then
                callback()
            end
            
            self:stop()
        elseif utils.getUserSetting("vibrate_enabled",true) and checkint(val) == checkint(self.parts["second"]) then
            device.vibrate()
            -- utils.playSound("harr-trun")
        end
       
    end
end

function Clock:start(second,callback)
    self:stop()
    self.parts["second"] = second or 10
    self.parts["clock"]:setVisible(true)
    color1 = 38
    color2 =230
    local is_delay = 1--second/self.parts["second"]
    
    self.parts["progress"]:getSprite():setColor(cc.c3b(color1,color2,0))
    local a1 = cc.ProgressFromTo:create(second,100 - is_delay * 100,100)
    self.parts["progress"]:runAction(a1)
    self.parts["step"] = 8

    if second < 15 then
        self.parts["step"] = 10
    end
    if is_delay ~= 1 then
        self.parts["step"] = self.parts["step"] * self.parts["second"] / second
    end
    self.parts["text"]:setString(second)
    self.parts["set_color_id"] = schedule(self.parts["clock"],self:_setColor(),0.3)
    self.parts["tid"] = schedule(self.parts["clock"],self:timer(second,callback),1)
end

local color1 = 38
local color2 = 230
function Clock:_setColor( )
    return function ()

        self.parts["progress"]:getSprite():setColor(cc.c3b(color1,color2,0))
        if color1 >= 240 then
            self.parts["step"] = - math.abs(self.parts["step"])
            color1= 255
        end
        if self.parts["step"] < 0 then
            color2 = color2 + self.parts["step"]
            if color2 <= 0 then
                color2 = 0
            end
        else
            color1 = color1 + self.parts["step"]
        end
    end

end

function Clock:stop()
    color1 = 38
    color2 =230
    self.parts["text"]:setString("")
    transition.stopTarget(self.parts["progress"])
    transition.stopTarget(self.parts["clock"])
    self.parts["progress"]:getSprite():setColor(cc.c3b(color1,color2,0))
    if self.parts["set_color_id"] then
        self.parts["clock"]:stopAction(self.parts["set_color_id"])
        -- transition.removeAction(self.parts["set_color_id"])
        self.parts["set_color_id"] = nil
    end
    
    if self.parts["tid"] then
        self.parts["clock"]:stopAction(self.parts["tid"])
        -- transition.removeAction(self.parts["tid"])
        self.parts["tid"] = nil
    end
    self.parts["clock"]:setVisible(false)
end


return Clock