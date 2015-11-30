local GuestLogin = class("GuestLogin" , require("app.login.Login"))

function GuestLogin:ctor()

    GuestLogin.super.ctor(self)
    --cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
end

function GuestLogin:login(login_data,callback)
   --游客登陆
    if not login_data.nick_name then
        login_data = utils.getUserSetting("LOGIN",{})
    end
    if login_data.nick_name == "" or login_data.nick_name == nil then
        local is = true
        if device.platform == "android" then
            is, login_data.nick_name = utils.callStaticMethod("Helper","getModel",{},{},"()S")
        else
            login_data.nick_name = "我的iphone"
        end
    end
    utils.http(CONFIG.API_URL,
    		{
	    		method="Amember.login",
	    		sitemid = device.deviceID,
	    		name = login_data.nick_name ~= "" and login_data.nick_name or "我的iphone",
	    		pass = "",
	    		gp = CONFIG.gp,
                channel = CONFIG.channel,
                site = device.platform == "android" and 1 or 2,
    		},function ( data )
				if callback then
					
                    callback(data)

				end
    			
    		end,"POST")
end

return GuestLogin