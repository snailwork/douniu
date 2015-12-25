local Seat = class("Seat")


function Seat:ctor(sp,id)
    self.parts ={}
    self.parts["seat"] = sp
    self.parts["cards"] = {}
    
    sp:setVisible(false)

    local key = {"bei","niu","level","name","gold","winText","qiangZhuang"}
    local scale = 1
    for i=1,12 do
        if i <= 5 then
            if id ~= 3 then
                scale = 0.53
            end
            self.parts["card"..i] = Card.new({batchnode = self.parts["seat"]:getChildByTag(i),scale = scale}) 
        else
            self.parts[key[i-5]] = sp:getChildByTag(i)
        end
    end
    self.parts["niu"].label = self.parts["niu"]:getChildByTag(1)
    self.model = {
                mid = 0,
                seatid = id,
                icon = "",
                name = "",
                status = 0,
                baseId = id,
                sex = 0}
    --头像的遮罩
    self.parts["dealer"] = display.newSprite("#seat/dealer-light.png")
        :pos(120,120)
        :addTo(self.parts["seat"],-2)
    local head = utils.makeAvatar()
    self.parts["seat"]:addChild(head,-1)
    self.parts["head"]  = head 
    head:setPosition(120,120)
end

function Seat:changePic(pic_path)
    -- dump(pic_path)
    self.parts["head"]:setVisible(true)
    if #pic_path > 0 then
        
        utils.loadRemote(self.parts["head"].pic,pic_path,function ( succ,texture )
             if not succ then return end
            self.parts["head"].pic:setTexture(texture)
            transition.fadeIn(self.parts["head"].pic,{time = .2})
        end)
    else
        self.parts["head"].pic:setTexture(cc.Director:getInstance():getTextureCache():getTextureForKey("default.png"))
    end
end

function Seat:changeName(name)
    if not name or (name == "") then
        self.parts["name"]:setString("")
        return
    end
    self.parts["name"]:setString(utils.suffixStr(name,5))
end

function Seat:changeGold(gold)
    self.parts["gold"]:setString(utils.numAbbrZh(gold))
end

function Seat:changeBei(val)
    if checkint(val) <= 0 then
        self.parts["bei"]:setVisible(false)
    else
        self.parts["bei"]:setVisible(true)
        self.parts["bei"]:setString(val.."倍")
    end 
end

function Seat:setCardsVisible(flag)
    for i=1,5 do
        self.parts["card"..i].sp:setVisible(flag)
        if not flag then
            self.parts["card"..i]:changeVal("-")
        end
        self.parts["card"..i]:normal()
    end
end

function Seat:reset( )
    self:setCardsVisible(false)
    -- self.parts["winText"]:setVisible(false)
    self.parts["qiangZhuang"]:setVisible(false)
    self.parts["niu"]:setVisible(false)
    self.parts["bei"]:setVisible(false)
    self.parts["dealer"]:setVisible(false)
end

function Seat:sit(udata)
    -- dump(udata)
    self.parts["seat"]:setVisible(true)
	table.merge(self.model,udata)
    self:changeBei(udata.bei)
    self:changeName(udata.name)
    self:changeGold(udata.gold)
    self:changePic(udata.icon)
    -- if checkint(udata.status) == 1 or checkint(udata.status) ==  2 then
    --     self:setCardsVisible(true)
    -- else
        self:setCardsVisible(false)
    -- end
    self.parts["winText"]:setVisible(false)
    self.parts["niu"]:setVisible(false)
    self.parts["qiangZhuang"]:setVisible(false)
    self.parts["dealer"]:setVisible(false)
    -- self:showCard(1,5,{"Ac","Js","Td","Qh","Kc"},true)
end

function Seat:showCard(from,to,val,quick,callback)
    local cards = self.parts["cards"]
    self:setCardsVisible(true)
    if not val then return end
    if from == 1 then
        cards = val
    elseif from == 4 then --只有一个牌的数据
        cards[4] = val[1]
        cards[5] = val[2]
    -- elseif from == 5 then--只有一个牌的数据
    --     vals[5] = val[1]
    end
    if to >= 5 then to = 5 end
    for i=from,to do
        if cards[i] and "-" ~= cards[i] and cards[i] ~= self.parts["card"..i].value_str then
            self.parts["card"..i]:changeVal(cards[i],quick)
            if i == to and callback then
                callback()
            end
        end
    end
    self.parts["cards"] = cards
end

function Seat:qiangZhuangFun( qiang )
    self.parts["qiangZhuang"]:setVisible(true)
    if qiang == 0 then
        self.parts["qiangZhuang"]:setString("不抢")
    else
        self.parts["qiangZhuang"]:setString("抢庄")
    end
end

function Seat:showNiuType( index )
    self.parts["niu"]:setVisible(true)
    if index == 0 then
        self.parts["niu"].label:setFntFile("fonts/num-green.fnt")
        self.parts["niu"].label:setPositionY(58)
    elseif index < 10 then
        self.parts["niu"].label:setPositionY(92)
        self.parts["niu"].label:setFntFile("fonts/num-yellow.fnt")
    elseif index >= 10 then
        self.parts["niu"].label:setFntFile("fonts/num-blue.fnt")
        self.parts["niu"].label:setPositionY(84)
    end
    if index == 0 then
        self.parts["niu"].label:setString("没牛")
        for i=1,5 do
            self.parts["card"..i]:gray()
        end
    else
        self.parts["niu"].label:setString(CONFIG.niuType[index])
    end
end 


function Seat:showWin(win)
    transition.stopTarget(self.parts["winText"])
    if checkint(win) >= 0  then
        self.parts["winText"]:setFntFile("fonts/num-yellow.fnt")
        win = "+"..utils.numAbbrZh(win)
    else
        win = "-"..utils.numAbbrZh(win)
        self.parts["winText"]:setFntFile("fonts/num-green.fnt")
    end
    local _x = 25
    if table.indexof({5,4},self.model.baseId) then
        self.parts["winText"]:setPosition(25,100)
    else
        self.parts["winText"]:setPosition(178,100)
        _x = 178
    end
    self.parts["winText"]:setString(win)
    self.parts["winText"]:setVisible(true)
    transition.execute(self.parts["winText"],cc.MoveTo:create(1.5,cc.p(_x,165)),{
        easing = "SINEOUT",
        onComplete = function ( )
            self.parts["winText"]:setVisible(false)
        end
    })
end

function Seat:showWinAnimation(win)
    local img = "#room/loser.png"
    if checkint(win) >= 0  then
        img = "#room/win.png"
    end
    local win_sp = display.newSprite(img)
                :align(display.CENTER,display.cx,display.cy* 0.4)
                :addTo(display.getRunningScene(),20)

            transition.moveTo(win_sp,{
                time = 0.5,
                y = display.cy,
                easing = "SINEOUT",
                onComplete = function ( )
                    transition.fadeTo(win_sp,{
                        delay = 0.5,
                        opacity = 0,
                        time = 0.5,
                        onComplete = function ( )
                            win_sp:removeSelf()
                            
                        end
                    })
                end
            })
end

function Seat:stand( )
    local baseId = self.model.baseId
    self.model = {
        mid = 0,
        seatid = 0,
        baseId = baseId,
        icon = "",
        name = "",
        status = 0,
        sex = 0
    }
    self.parts["seat"]:setVisible(false)
end



return Seat