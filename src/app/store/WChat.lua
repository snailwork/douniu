local WChat = class("WChat")



function WChat.buyItem( goods )
    if not CONFIG.installWchat then
        showDialogTip("", "您没有安装微信客户端，不能使用微信支付！",{"确定"})
        return
    end
    Loading.create()
    scheduler.performWithDelayGlobal(function()
        Loading.close()
        end,10)
    local delayUpateGold 
    local index = 1
    delayUpateGold = function (  )
        scheduler.performWithDelayGlobal(function()
            if index > 10 then return end
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
                        if GAME.gold >= data.aGame.gold then
                            delayUpateGold()
                        end
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
            index = index + 1 
        end, 4)
    end

    local callback = function ( data1 )
        Loading.close()
        if device.platform == "android" then
            data1  = json.decode(data1)
        end
        scheduler.performWithDelayGlobal(function()
            if checkint(data1.errCode) == 0 then
                --订单支付成功
                showDialogTip("", "订单支付成功",{"确定"})
                MY_MATURE_PACK[goods.id ..""] = true
                delayUpateGold()
            elseif checkint(data1.errCode) == 1234 then
                showDialogTip("", "您没有安装微信客户端，不能使用微信支付！",{"确定"})
                app:dispatchEvent({name = "updateBroke"})
            else
                --订单支付失败
                showDialogTip("", "订单支付失败！请重试！",{"确定"})
                app:dispatchEvent({name = "updateBroke"})
            end
        end, 0.3)
    end
    -- utils.callStaticMethod("Wchat","pay",{callback = callback},{"callback"},"(I)V")
    -- Loading.close()
    -- do return end
    local prodid = goods.id
    -- if device.platform == "ios" then
    --     prodid = goods.img
    -- end
    utils.http(CONFIG.API_URL,{
            method="Amember.getOrder",
            sesskey=USER.sessionKey,
            id = prodid,
            type = 6,
        },function ( data )
            if data.svflag == 1 then
                local args = {callback = callback,notify_url = data.data.string,orderid = data.data.cardid.."",price =( goods.cost * 100) .. ""}
                utils.callStaticMethod("Wchat","pay",args,{"callback","notify_url","orderid","price"},"(ISSS)V")
            end
        end)

end



return WChat