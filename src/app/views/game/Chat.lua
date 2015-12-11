local Chat = class("Chat")

function Chat:ctor(game)
    self.parts ={}
    local chat = cc.uiloader:load("chat.csb"):addTo(game, 99)
    chat:setVisible(false)
    self.parts["chat"] = chat
    self.parts["game"] = game
    self.parts["inputPanel"] = chat:getChildByTag(570)
    self.parts["inputPanel"]:setPositionY(370)
    self.parts["inputPanel"]:setVisible(false)

    self.parts["editBox"] = cc.ui.UIInput.new({
        image = "#menu/transparent.png",
        fontSize = 28,
        size = cc.size(1100, 62),
        x = self.parts["inputPanel"]:getContentSize().width /2,
        y = self.parts["inputPanel"]:getContentSize().height /2,
        listener = function(event, editbox)
            dump(event)
            local msg = editbox:getText()
            if event == "return" then
                self.parts["inputPanel"]:setVisible(false)
                self.parts["editBoxText"]:setString(msg)
                editbox:setText("")
            elseif event == "changed" then
                utils.substr(msg,30)
            end
        end
    }):addTo(self.parts["inputPanel"])
    -- self.parts["editBox"]:setMaxLength()
    self.parts["editBox"]:setFontColor(display.COLOR_BLACK)
    self.parts["editBox"]:setReturnType(cc.KEYBOARD_RETURNTYPE_SEND)
    self.parts["editBox"]:setPlaceHolder("输入要发送的聊天信息")
    -- self.parts["editBox"]:setVisible(false)


    
    local values = {"face","fast","his"}
    self.parts["values"] = values
    -- self.parts.btns ={}
    for i=1,5 do
        local btn = chat:getChildByTag(i)
        self.parts["btn"..i] = btn
        btn:setEnabled(true)
        -- btn:setTouchEnabled(true)
        btn:addTouchEventListener(handler(self,self["fun"..i]))
        if i == 4 then
            self.parts["editBoxText"] = btn:getChildByTag(298)
        end
        if i <4 then
            self.parts[values[i].."-item"] = chat:getChildByTag(i + 20)
            self.parts[values[i].."-item"]:setVisible(false)
            self.parts[values[i].."-list"] = chat:getChildByTag(i + 10)
            self.parts[values[i].."-list"]:setVisible(false)
        end
    end
    self.parts["face-list"]:setVisible(true)

    ----------------------表情----------------------------------
    self:faceFun()
    ------------------------快捷聊天----------------------------------
    for k,v in pairs(CONFIG.fastMsg) do
        item = self.parts["fast-item"]:clone()
        item:setVisible(true)
        item:getChildByTag(19):setString(v)
        item:addTouchEventListener(function ( target,event )
            if event ~= 2 then return end
            self.parts["send"]=  false
            local msg = string.trim(target:getChildByTag(19):getString())
            if #msg < 1 then return end
            self:sendMsg(msg)
            self.parts["chat"]:performWithDelay(function ( ... )
                       self.parts["send"] = true
                    end,0.5)
            end)
        self.parts["fast-list"]:pushBackCustomItem(item)
    end
 
end

----------------表情--------------------------
function Chat:faceFun(  )
    self.parts["faces"] = {1,2,3,5,6,7,9,10,11,12,13,14,16,17,19,20,30,31,32,33,34}
    local item
    local j = 1
    for k,v in pairs(self.parts["faces"]) do
        if (k - 1)%3 == 0 then 
            j = 1
            item = self.parts["face-item"]:clone()
            item:setVisible(true)
            self.parts["face-list"]:pushBackCustomItem(item)
        end
        item_face = item:getChildByTag(j)
        item_face:loadTextures("face/1".. v .. ".png","face/1".. v .. ".png","face/1".. v .. ".png",1)
        item_face:addTouchEventListener(function ( target,event )
            if event == 0 then
                target:setScale(0.95)
            elseif event == 3 or event == 2 then
                target:setScale(1)
            end
            if event ~= 2 then return false end
            utils.playSound("click")
            self.parts["send"]=  false
            self:sendFace(v)
            self.parts["chat"]:performWithDelay(function ( ... )
                   self.parts["send"] = true
                end,0.5)

        end)
        j = j+ 1
    end

    for i=j,3 do
        item:getChildByTag(i):setVisible(false)
    end
end


--加聊天记录
function Chat:addMsg(data)
     dump(data)
    if self.parts["his-list"]:getChildrenCount() >= 50 then
        self.parts["his-list"]:removeItem(1)
    end
    local item
    local name = data.name
    if data._type == 2 or data.mid == 0 then
        name = "[系统]"
    elseif data._type == 1  then
        name = "[喇叭] " .. data.name
    end
    item = self.parts["his-item"]:clone()
    item:setVisible(true)
    lable = item:getChildByTag(288)
    lable:setString(name.."："..data.msg)
    item:getChildByTag(37):setVisible(false)
    item:getChildByTag(42):setVisible(false)

    self.parts["his-list"]:pushBackCustomItem(item)
    self.parts["his-list"]:scrollToBottom(0.1,false)

end

--加聊天记录 表情
function Chat:addFace(data)
    if self.parts["his-list"]:getChildrenCount() >= 50 then
        self.parts["his-list"]:removeItem(1)
    end

    local item
   
    item = self.parts["his-item"]:clone()
    item:setVisible(true)
    item:getChildByTag(42):setString(data.name .. "：")
    item:getChildByTag(37):loadTexture("face/1".. data.pframe .. ".png",1)
    item:getChildByTag(37):setScale(0.8)
    item:getChildByTag(37):setPositionX(item:getChildByTag(42):getContentSize().width+10)
    
    self.parts["his-list"]:pushBackCustomItem(item)
    self.parts["his-list"]:scrollToBottom(0.1,false)
end

function Chat:show()
    self.parts["chat"]:setVisible(true)
end

function Chat:hide()
    self.parts["inputPanel"]:setVisible(false)
    self.parts["chat"]:setVisible(false)
end

--msg
function Chat:sendMsg(msg)
    SendCMD:sendChat({_type = 0,msg = msg})
end

--face
function Chat:sendFace(pframe)
    SendCMD:sendFace({pcate = 1,pframe = pframe})
end

function Chat:setButStatus(index)
    for i=1,3 do
        self.parts["btn"..i]:setBright(true)
        self.parts["btn"..i]:getChildByTag(1):loadTexture("chat/"..self.parts["values"][i]..".png",1)

        self.parts[self.parts["values"][i].."-list"]:setVisible(false)
    end
    self.parts["btn"..index]:setBright(false)
    self.parts[self.parts["values"][index].."-list"]:setVisible(true)
    self.parts["btn"..index]:getChildByTag(1):loadTexture("chat/"..self.parts["values"][index].."-down.png",1)
end

function Chat:fun1(target,event )
    if event ~= 2 then return end
    utils.playSound("click")
    self:setButStatus(1)
end

function Chat:fun2(target,event )
    if event ~= 2 then return end
    utils.playSound("click")
    self:setButStatus(2)
end

function Chat:fun3( target,event )
    if event ~= 2 then return end
    utils.playSound("click")
   self:setButStatus(3)
end

function Chat:fun5( target,event)
    if event == 0 then
        target:setScale(0.9)
    elseif event == 3 or event == 2 then
        target:setScale(1)
    end
    if event ~= 2 then return end
    utils.playSound("click")
    self.parts["send"]=  false
    local msg = self.parts["editBoxText"]:getString()
    if #msg < 1 then return end
    self.parts["editBoxText"]:setString("")
    self:sendMsg(msg)
    self.parts["chat"]:performWithDelay(function ( ... )
               self.parts["send"] = true
            end,0.5)
end

function Chat:fun4( target,event )
    self.parts["inputPanel"]:setVisible(true)
    self.parts["editBox"]:touchDownAction(self.parts["editBox"],2)
    self.parts["editBox"]:setText(self.parts["editBoxText"]:getString())
    
    dump("touchDownAction")
end

return Chat