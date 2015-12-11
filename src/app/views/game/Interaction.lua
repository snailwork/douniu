local Interaction = class("Interaction")

function Interaction:ctor(callback,sp)
    self.callback = callback
	local menu = cc.uiloader:load("interaction.csb")
        :pos(440,440)
        :addTo(sp,21)
    self.menu = menu
    self.menus = {}
    self.panel = cc.uiloader:seekNodeByTag(menu, 1459)
    
    local mask = display.newLayer()
    self.panel:addChild(mask)
    self.panel:setTouchEnabled(false)
    -- self.panel:setEnabled(false)

    local time = 0.3
    local pos_arr = {}

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(function ( )
        self.isclose = true
        sp:performWithDelay(function ()
            self:close()
        end,0.1)
    end, cc.Handler.EVENT_TOUCH_BEGAN)
    mask:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, mask)
    for i=1,5 do
        self.menus[i] = cc.uiloader:seekNodeByTag(menu, i)
        self.menus[i]:addTouchEventListener(handler(self, self["fun"..i]))

        -- self.menus[i]:loadTextures("interaction/qinwu1.png","interaction/qinwu1.png",nil,1)

        -- self.menus[i]:setRotation(id_ration[id])
        self.menus[i]:setTouchEnabled(false)
        pos_arr[i] = cc.p(self.menus[i]:getPosition())
        self.menus[i]:setPosition(200,200)
        --移动出来
        local a21 = cc.DelayTime:create((i-1) * 0.02)
        local a1 = cc.MoveTo:create(time,pos_arr[i])
        local a11 = cc.EaseBackOut:create(a1)
        -- local a2 =  cc.RotateTo:create(time,-id_ration[id])
        local a3 = cc.FadeIn:create(time)
        -- local action = cc.Spawn:create(a11,a2,a3)
        local action = cc.Spawn:create(a11,a3)
        local action1 = transition.sequence({a21,action})
        transition.execute(self.menus[i],action1,{onComplete = function ()
                self.menus[i]:setTouchEnabled(true)
            end})
    end
end


function Interaction:close()
    self.isclose = nil
    local time = 0.3
     for k,v in pairs(self.menus) do
         --移动回来
        local a21 = cc.DelayTime:create(k * 0.02)
        local a1 = cc.MoveTo:create(time,cc.p(200,200))
        local a11 = cc.EaseBackOut:create(a1)
        -- local a2 =  cc.RotateTo:create(time,-180)
        local a3 = cc.FadeOut:create(time-0.1)
        local action = cc.Spawn:create(a11,a3)
        -- local action = cc.Spawn:create(a11,a2,a3)
        local action1 = transition.sequence({a21,action})
        transition.execute(v,action1,{onComplete = function ()
               if k == #self.menus then
                    self.menu:removeSelf()
                    if self.callback then
                        self.menus = {}
                        self.callback()
                    end
               end
            end})
    end
end


function Interaction:send(pframe)
    local data = {
        pframe = pframe,
        pcate = 1,
        _type = 0,
        mid = 0
    }
    SendCMD:useProps(data)
end

function Interaction:fun1(target, event )
    if event ~= 2 then return end
    local chips = checkint(ROOM_DATA.max_buying/ROOM_DATA.b_blind) 
    if USER.buying < chips then
        createPromptBox("您的筹码不够了!")
        return
    end
    SendCMD:giftChips({mid = 0,chips = chips})
end

function Interaction:fun2(target, event )
    if event ~= 2 then return end
    self:send(6)
end

function Interaction:fun3(target, event )
    if event ~= 2 then return end
    self:send(8)
end

function Interaction:fun4(target, event )
    if event ~= 2 then return end
    self:send(10)
end

function Interaction:fun5(target, event )
    if event ~= 2 then return end
    self:send(9)
end



return Interaction