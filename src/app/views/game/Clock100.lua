local Clock  =  class("Clock")

function Clock:ctor(sp)
    self.parts ={}
    self.parts["clock"] = sp
    self.parts["text"] = sp:getChildByTag(1)
    self.parts["text"]:setString("")
   
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
    self.parts["text"]:setString(second)
    self.parts["tid"] = schedule(self.parts["clock"],self:timer(second,callback),1)
end

function Clock:stop()
    self.parts["text"]:setString("")
    transition.stopTarget(self.parts["clock"])

    if self.parts["tid"] then
        self.parts["clock"]:stopAction(self.parts["tid"])
        self.parts["tid"] = nil
    end
end


return Clock