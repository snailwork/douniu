local Top = class("Top")

function Top:ctor(sp)
    self.parts = {}
    self.parts["top"] = sp
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