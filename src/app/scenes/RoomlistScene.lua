
local RoomlistScene = class("RoomlistScene", function()
    return display.newScene("RoomlistScene")
end)

function RoomlistScene:ctor()
	local roomlist = cc.uiloader:load("roomlist.csb"):addTo(self)
    local top = require("app.views.Top").new(roomlist:getChildByTag(182))
    
    local listview = roomlist:getChildByTag(181)
    local model = roomlist:getChildByTag(165)
    model:setVisible(false)
    local index = 0
    local j = 1
	local panel_item
    for k,v in pairs(CONFIG.roominfo) do
    	if index  > 2 or index == 0 then
			index = 1
			panel_item = model:clone()
			panel_item:setVisible(true)
			listview:pushBackCustomItem(panel_item)
		end
		local item = panel_item:getChildByTag(index)
        item:setTag(j)
		item:getChildByTag(2):setString(utils.numAbbrZh(v.blind))
		item:getChildByTag(3):setString("进房下限".. utils.numAbbrZh(v.min))
        item:addTouchEventListener(handler(self, self["toPlay"]))
		index = index + 1
        j = j+ 1
    end
    if index == 2 then
    	panel_item:getChildByTag(index):setVisible(false)
    end
    for i=1,2 do
    	roomlist:getChildByTag(i):addTouchEventListener(handler(self, self["fun"..i]))
    end
   
    
end

function RoomlistScene:toPlay(target, event )
    if not self:btnScale(target, event) then return end
    display.replaceScene(require("app.scenes.GameScene").new(CONFIG.roominfo[checkint(target:getTag())]))
end

function RoomlistScene:btnScale(target, event )
    if event == 0 then
        target:setScale(0.9)
    elseif event == 3 or event == 2 then
        target:setScale(1)
    end
    if event ~= 2 then return false end
    utils.playSound("click")
    return true
end

--quick start
function RoomlistScene:fun1(target, event )
    if not self:btnScale(target, event) then return end
    display.replaceScene(require("app.scenes.GameScene").new())
    
end

--close
function RoomlistScene:fun2(target, event )
    if not self:btnScale(target, event) then return end
    display.replaceScene(require("app.scenes.HallScene").new())
end

function RoomlistScene:onEnter()
	
end

function RoomlistScene:onExit()
end

return RoomlistScene
