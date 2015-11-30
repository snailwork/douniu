
local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

function MainScene:ctor()
    cc.ui.UILabel.new({
            UILabelType = 2, text = "Hello, World", size = 64})
        :align(display.CENTER, display.cx, display.cy)
        :addTo(self)
    
end

function MainScene:onEnter()
	-- display.replaceScene(require("app.scenes.GameScene").new())
	require("app.views.LoadingLayer").new():addTo(display.getRunningScene())
end

function MainScene:onExit()
end

return MainScene
