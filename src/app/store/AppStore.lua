local AppStore = class("AppStore")


-- 请求http发货
function AppStore.reqHttpDispatch()
    -- body
    if IOSPAY.receipt_data == nil then
        return
    end

    utils.http(CONFIG.API_URL,
                {
                    method = "Amember.getOrder",
                    type = 4,
                    iosstring = IOSPAY.receipt_data,
                    orderid = IOSPAY.orderid,  
                    sesskey = USER.sessionKey,
                    ver = CONFIG.appversion,
                        
                }, function (data)
                    if data.svflag == 1 then
                        createPromptBox("购买成功，请查收")
                        IOSPAY.receipt_data = nil
                        IOSPAY.to_mid = nil
                        IOSPAY.orderid = 0
                        IOSPAY.cardid = 0
                        utils.setUserSetting("IOSPAY" , IOSPAY)
                        MY_MATURE_PACK[IOSPAY.good.id..""] = true
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
                                    app:dispatchEvent({name = "app.updatachip", data = {id=IOSPAY.good.id}})
                                    app:dispatchEvent({name = "updateBroke", 
                                        data = {
                                            success = true,
                                        }
                                    })
                                end

                        end,"POST")

                        Loading.close()
                    else
                        app:dispatchEvent({name = "updateBroke"})
                        IOSPAY.count = IOSPAY.count + 1
                        if IOSPAY.count >= 5 then
                            IOSPAY.receipt_data = nil
                            IOSPAY.to_mid = nil
                            IOSPAY.orderid = 0
                            IOSPAY.cardid = 0
                            createPromptBox("服务器繁忙")
                            utils.setUserSetting("IOSPAY" , IOSPAY)
                            Loading.close()
                            return
                        end   
                        createPromptBox("服务器发货失败，正在重新请求")
                        AppStore.reqHttpDispatch()
                    end
                end , "POST")
end


function AppStore.initStore()

   function transactionCallback(event)
        local transaction = event.transaction
        Loading.close()
        if transaction.state == "purchased" then
            local receipt = transaction.receipt
            local params = {
                productId = transaction.productIdentifier,
                transactionIdentifier = transaction.transactionIdentifier,
                sandbox = DEBUG > 1 and 1 or 0
            }

            params["receipt_data"] = crypto.encodeBase64(transaction.receipt)  --出来的结果带有换行符
            params["receipt_data"] = string.gsub(params["receipt_data"], "\n", "")
            params["pf"] = "appstore"
            params["to_mid"] = USER.mid

            local data = {}
            IOSPAY.receipt_data = params["receipt_data"]
            IOSPAY.to_mid = USER.mid 
            utils.setUserSetting("IOSPAY" , IOSPAY)
            Loading.create("正在通知服务器发货...")

            IOSPAY.count = 0
            AppStore.reqHttpDispatch()
            
            
        elseif  transaction.state == "restored" then
        elseif transaction.state == "failed" then
            Loading.close()
            showDialogTip("提示" , "支付失败，请重试" , {"确定"})
            app:dispatchEvent({name = "updateBroke"})
        else
            --取消支付会触发
            createPromptBox("取消支付")
            app:dispatchEvent({name = "updateBroke"})
        end
        Store.finishTransaction(transaction)
    end
    Store.init(transactionCallback)

    AppStore.products = {}
end


function AppStore.loadProducts(data)
    local productIds = {}
    for i,r in ipairs(data) do
        table.insert(productIds, r.proid)
    end
    Store.loadProducts(productIds, function ( products )
        for k,v in pairs(products["products"]) do
            AppStore.products[v.productIdentifier] = v.productIdentifier
        end
    end)
end



function AppStore.buyItem( good)
    IOSPAY.good = good
    local proid = good.img
    if not Store.canMakePurchases() then
        createPromptBox("您当前不能支付")
        return
    end

    Loading.create( "连接App Store中…")

    if AppStore.products[proid] then
        Store.purchase(proid)
        --transition.removeAction(tid)
    else
        -- dump(proid)
        Store.loadProducts({proid}, function ( data )
            -- dump(data)
            if data.errorCode then
                showDialogTip("提示" , data.errorString ,{"确定"})
                Loading.close()
            elseif data['invalidProductsId'] then
                transition.removeAction(tid)
                showDialogTip("提示" , "该商品当前无法购买" ,{"确定"})
                Loading.close()
                return
            end
            --transition.removeAction(tid)
            AppStore.products[proid] = data["products"][1].productIdentifier
            Store.purchase(proid)
        end)
    end

end



return AppStore