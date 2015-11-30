

--创建messbox
--param1: title
--param2: msg
--param3: {"取消" , "确定"}
--param4: callfun

function showDialogTip(... )
	dump(arg)
	-- do return end
	local message_box = require("app.tools.dialog").new(arg)
	
end

function showAutoTip( ... )
	-- bar_bk:setPosition(cc.p(display.cx , display.height + bar_bk:getContentSize().height / 2))
	local text = display.newTTFLabel({text = arg[1], size = 30,})
	local width = text:getContentSize().width
	if width < 900 then
		width = 900
	end
	local bar_bk = display.newScale9Sprite("#common/sys-tip.png" , display.cx , display.height+35,cc.size(width,70) ):addTo(display.getRunningScene() , 1000)
	-- local bar_bk = display.newScale9Sprite("#hall/tips.png" , display.cx , display.height+95,cc.size(text:getContentSize().width + 50,95) ):addTo(display.getRunningScene() , 1000)
	text:pos(bar_bk:getContentSize().width/2,bar_bk:getContentSize().height / 2)
	text:addTo(bar_bk)

	local acts = {}
	acts[1] = cca.moveBy(0.3 , 0 , -bar_bk:getContentSize().height)
	acts[2] = cca.delay(2.0)
	acts[3] = cca.moveBy(0.3 , 0 , bar_bk:getContentSize().height)
	acts[4] = cca.cb(function()
		bar_bk:removeFromParent()
	end)
	bar_bk:runAction(cca.seq(acts))
end


