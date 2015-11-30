local Loading = class("Loading")


function Loading:ctor()
	Loading.layer = nil
end


function Loading.create(data)
	data = data or {}
	if Loading.layer ~= nil then
		return
	end
	local anim_name = "loading_s"
	if not display.getAnimationCache(anim_name) then --缓存loding动画
		local frames = display.newFrames("loading/".."%02d.png", 1, 12)
	    display.setAnimationCache(anim_name, display.newAnimation(frames, 0.1))
	end

	local parent = data.parent and data.parent or display.getRunningScene()

	Loading.layer = cc.uiloader:load("loading_s.csb"):addTo(parent, 1001) --display.newLayer():addTo(display.getRunningScene(),99)
	:align(display.CENTER, display.cx, display.cy)

	local bg = cc.uiloader:seekNodeByTag(Loading.layer , 18)
	bg:setContentSize(display.width,display.height)
	

	display.newSprite() --播放logind动画
		:align(display.CENTER,display.cx,display.cy)
		:addTo(Loading.layer)
		:playAnimationForever(display.getAnimationCache(anim_name))

	local acts = {}
	if data.delayTime then
		acts[1] = cca.delay(data.delayTime)
		acts[2] = cca.cb(function ()
			if data.cb then
				data.cb()
			end	
			Loading.close()
		end)
		Loading.layer:runAction(cca.seq(acts))
	end
end

function Loading.close()
	-- body
	if Loading.layer == nil then
		return
	end

	Loading.layer:removeFromParent()

	Loading.layer = nil

end

return Loading