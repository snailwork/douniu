local QsLogin = class("QsLogin")


function QsLogin:ctor()
   
end

function QsLogin:login(data,callback)
    --游客登陆
    local login_data = utils.getUserSetting("LOGIN",{})

    utils.http(CONFIG.API_URL,
    		{
	    		method="Amember.login",
	    		sitemid=data.sitemid,
	    		pass = data.pass,
	    		gp = CONFIG.gp,
                channel = CONFIG.channel,
                site = device.platform == "android" and 1 or 2,
    		},function ( data )
				if callback then
					callback(data)
				end
    			
    		end,"POST")
end

return QsLogin