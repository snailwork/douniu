local Top = class("Top")

function Top:ctor(sp,prant)
    self.parts = {}
    self.parts["top"] = sp
    self.parts["prant"] = prant
    local vals = {USER.level,USER.name,USER.gold}
    for i=1,5 do
        if i < 3 then
            sp:getChildByTag(i):setString(vals[i])
        else
            sp:getChildByTag(i):addTouchEventListener(handler(self, self["fun"..i]))
        end
    end

    local head = utils.makeAvatar({icon = USER.icon,border = "#gold/border1.png"})
        :pos(-570,54)
        :addTo(sp)

     self.handler = app:addEventListener("app.updatachip", function(event)
            vals = {USER.level,USER.name,USER.gold}
            for i=1,3 do
                sp:getChildByTag(i):setString(vals[i])
            end
        end)

    self.handlerUpic = app:addEventListener("app.updataupic", function(event)
        utils.loadRemote(head.pic,USER.icon,function ( succ,texture,sprite )
            if not succ then 
                head.pic:setTexture(cc.Director:getInstance():getTextureCache():getTextureForKey("default.png"))
                return 
            end
            sprite:setTexture(texture)
            transition.fadeIn(sprite,{time = .2})
        end)
    end)
end

function Top:hide()
    app:removeEventListener(self.handler)
    app:removeEventListener(self.handlerUpic)
end

function Top:btnScale(target, event )
    if event == 0 then
        target:setScale(0.9)
    elseif event == 3 or event == 2 then
        target:setScale(1)
    end
    if event ~= 2 then return false end
    utils.playSound("click")
    return true
end

--buy
function Top:fun4(target, event )
    if not self:btnScale(target, event) then return end
    self.parts["prant"].parts["item"]["Store"] =require("app.views.Store").new(function (  )
            self.parts["prant"].parts["item"]["Store"] = nil
        end)
    self.parts["prant"].parts["item"]["Store"]
end

--email
function Top:fun5(target, event )
    if not self:btnScale(target, event) then return end
    
end

--seting
function Top:fun6(target, event )
    if not self:btnScale(target, event) then return end
    
end


return Top