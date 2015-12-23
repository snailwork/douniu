local Seat = class("Seat")


function Seat:ctor(sp,id)
    self.parts ={}
    self.parts["seat"] = sp
    self.parts["name"] = sp:getChildByTag(1)
     self.model = {
                mid = 0,
                icon = "",
                name = "",
                seatid = id,
                baseId = id
            }
    local head = utils.makeAvatar()
    self.parts["seat"]:addChild(head,20)
    self.parts["head"]  = head 
    head:setScale(0.8)
    head:setPosition(40,40)
    self:reset()
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



function Seat:reset( )
    self:changeName("")
    self.parts["head"]:setVisible(false)
end

function Seat:sit(udata)
    table.merge(self.model,udata)
    self:changePic(udata.icon)
    self:changeName(udata.name)
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
    self:reset()
end


return Seat