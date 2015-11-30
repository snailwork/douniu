local WChatLogin = class("WChatLogin")

function WChatLogin:login(data,callback)
    --微信登陆
    utils.callStaticMethod("Wchat","login",{callback=function ( data )
        -- dump(data)
        if device.platform == "android" then
            data  = json.decode(data)
        end
        -- dump(data)
        if data.errCode ~= 0 then
            SceneManager.switch("LoginScene")
            return
        end
        utils.http(CONFIG.API_URL,
                {
                    method="Amember.login",
                    code=data.code,
                    type = 1,
                    gp = CONFIG.gp,
                    channel = CONFIG.channel,
                    site = device.platform == "android" and 1 or 2,
                },function ( data )
                    if callback then
                        callback(data)
                    end
                    
                end,"POST")

    end},{"callback"},"(I)V")

    
end

return WChatLogin