local Top = class("Top")

function Top:ctor(sp,prant)
    self.parts = {}
    self.parts["top"] = sp
    self.parts["prant"] = prant
    local vals = {"LV:"..USER.level,USER.name,USER.gold}
    for i=1,7 do
        if i <= 3 then
            sp:getChildByTag(i):setString(vals[i])
        else
            sp:getChildByTag(i):addTouchEventListener(handler(self, self["fun"..i]))
        end
    end

    local head = utils.makeAvatar({icon = USER.icon,border = "#gold/border1.png"})
        :pos(-570,-54)
        :addTo(sp)
    self.parts["head"] = head

     self.handler = app:addEventListener("app.updatachip", function(event)
            vals = {"LV:"..USER.level,USER.name,USER.gold}
            dump(vals)
            for i=1,3 do
                dump(sp:getChildByTag(i))
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

    self.parts["top"] = sp:getChildByTag(5):getChildByTag(277)
    self.parts["top"]:setVisible(false)
end

function Top:hide()
    dump("Top:hide()")
    dump("Top:hide()")
    dump("Top:hide()")
    dump("Top:hide()")
    dump("Top:hide()")
    dump("Top:hide()")
    dump("Top:hide()")
    dump("Top:hide()")
    app:removeEventListener(self.handler)
    app:removeEventListener(self.handlerUpic)
    self.parts["top"]:removeSelf()
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
end

--email
function Top:fun5(target, event )
    if not self:btnScale(target, event) then return end
    self.parts["prant"].parts["item"]["Email"] = require("app.views.Email").new(self.parts["prant"],function ()
         self.parts["prant"].parts["item"]["Email"] = nil
    end)
end

--seting
function Top:fun6(target, event )
    if not self:btnScale(target, event) then return end
    self.parts["prant"].parts["item"]["setting"] = require("app.views.Setting").new(self.parts["prant"],function ()
         self.parts["prant"].parts["item"]["setting"] = nil
    end)
end

function Top:fun7(target, event )
    if not self:btnScale(target, event) then return end
    self.parts["prant"].parts["item"]["UserInfo"] =require("app.views.UserInfo").new(USER,function (  )
            self.parts["prant"].parts["item"]["UserInfo"] = nil
        end)
end


return Top