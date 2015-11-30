local Alipay = class("Alipay")



function Alipay.buyItem( goods )

    Loading.create()
    local callback = function ( data1 )
        Loading.close()
        data1  = json.decode(data1)
       scheduler.performWithDelayGlobal(function()
            if checkint(data1) == 8000 then
                --正在处理中
                showDialogTip("", "您的订单已经在处理中，请稍后！",{"确定"})
                MY_MATURE_PACK[goods.id ..""] = true
            elseif checkint(data1) == 4000 then
                --订单支付成功
                showDialogTip("", "系统繁忙，请稍后再试！",{"确定"})
            elseif checkint(data1) == 9000 then
                --订单支付成功
                showDialogTip("", "订单支付成功",{"确定"})
                MY_MATURE_PACK[goods.id ..""] = true
                for i=1,4 do
                    scheduler.performWithDelayGlobal(function()
                        --取一次用户数据
                        utils.http(CONFIG.API_URL,
                            {
                                method="Amember.load",
                                sesskey=USER.sessionKey,

                            },function ( data )
                                if data.err  then
                                    --网络错误处理
                                elseif data.svflag == 1 then
                                    data = data.data
                                    utils.__merge(USER,data.aUser)
                                    utils.__merge(GAME,data.aGame)
                                    app:dispatchEvent({name = "app.updatachip", data = {id=goods.id}})
                                    app:dispatchEvent({name = "updateBroke", 
                                        data = {
                                            success = true,
                                        }
                                    })
                                end

                        end,"POST")
                    end, 4 * i)
                end
                return
            elseif checkint(data1) == 6001 then
                --用户中途取消
                showDialogTip("", "支付已取消！",{"确定"})
            elseif checkint(data1) == 6002 then
                --网络连接出错
                showDialogTip("", "网络连接出错！请重试！", {"确定"})
            else
                --订单支付失败
                showDialogTip("", "订单支付失败！请重试！",{"确定"})
            end
            
            app:dispatchEvent({name = "updateBroke"})
        end, 0.3)
    end
     -- utils.callStaticMethod("QQLogin","Login",{callback = callback},{"callback"},"(I)V")
    local args = {prop_id = goods.id ,sessionKey = USER.sessionKey,api_url = CONFIG.API_URL,callback = callback}
    utils.callStaticMethod("ali/AliPayBridge","pay",args,{"prop_id","sessionKey","api_url","callback"},"(ISSI)V")

end



return Alipay