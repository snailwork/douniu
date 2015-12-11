local SysMsg = class("SysMsg")

function SysMsg:ctor(sp)
    self.sp = sp
    self.sp:setPositionY(display.height - 50)
    self.sp:setVisible(false)
	self.moveItem = cc.uiloader:seekNodeByTag(sp, 336)
    self.msgs = {}
end

--add msg
function SysMsg:addChatMsg(data)
    table.insert(self.msgs,data)
    self:showChatMsg(self.msgs[1])--启动滚动
end

function SysMsg:getChatMsg()
    if #self.msgs > 0 then
        return self.msgs[1]
    else
        return nil
    end
end

function SysMsg:showChatMsg(data)
    if self.moveItem.scroll then return end --如果已经在滚动了，就排队
    data.seatid = data.seatid or 10
    self.moveItem.scroll = true
    table.remove(self.msgs,1) --移除掉滚动的
    self.sp:setVisible(true)
    local msg
    local color = display.COLOR_WHITE
    if data._type == 2 or data.mid == 0 then
        msg =  "[系统]：" .. data.msg
        color = cc.c3b(255, 35, 35)
    elseif data._type == 1 then
        color = cc.c3b(27, 166, 255)  --蓝
        msg =  "[喇叭] "..data.name .."：" .. data.msg
    -- elseif data.mid == USER.mid then
    --     msg =  "我：" .. data.msg
    else
        msg = data.name .. "：" .. data.msg
    end
    transition.stopTarget(self.moveItem)
    
    self.moveItem:setColor(color)
  	self.moveItem:setString(msg)
    local width = self.moveItem:getContentSize().width
    
    
    local showWidth = 660
    local xx = showWidth - width
    local time = width / showWidth * 2.5
    if width > showWidth then
        self.moveItem:setAnchorPoint(0,0.5)
        self.moveItem:setPositionX(0)
        self:moveText(time,xx)
    else
        self.moveItem:setAnchorPoint(0.5,0.5)
        self.moveItem:setPositionX(230)
        self.sp:performWithDelay(function()
                self.moveItem.scroll = false
                local msg = self:getChatMsg()
                if msg then
                    self:showChatMsg(msg)
                else
                    self.sp:setVisible(false)
                end
            end, 4)
    end
end

function SysMsg:moveText(time,xx)
    self.moveItem:setPositionX(0)
    transition.moveBy(self.moveItem, {
        delay = 2,
        time  = time,
        x     = xx,
        onComplete = function ( )
            self.sp:performWithDelay(function()
                self.moveItem.scroll = false
                local msg = self:getChatMsg()
                if msg then
                    self:showChatMsg(msg)
                else
                    self.sp:setVisible(false)
                end
            end, 2)
        end
    })

end


return SysMsg