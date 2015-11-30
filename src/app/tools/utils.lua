local utils = {}
 
require("lfs")
local __cachedir = device.writablePath.."upic_cache/"
if not lfs.touch(__cachedir) then
    lfs.mkdir(__cachedir)
end

function utils.__merge(parant,val)
        for k,v in pairs(val) do 
           if type(v) == "table" then
                if not parant[k] then
                    parant[k] = {}
                end
                utils.__merge(parant[k],v)
            else
                parant[k] = v
            end
        end
    end
--[[--test empty value
### Example:
### Parameters:
-   anything
### Returns:
-   bool
]]
function utils.empty(v)
    return  v == nil or v == false or v == "" or v == 0
end
--[[--
convert Lua table to CCArray
### Example:
    utils.table2array({1,2,3})
### Parameters:
-   lua table
### Returns:
-   CCArray]]
function utils.table2array(t)
    local arr = CCArray:create()
    local count = #t
    for i = 1, count do
        arr:addObject(t[i])
    end
    return arr
end

--[[--convert  CCArray to Lua table
### Example:
    utils.array2table((CCArray) arr)
### Parameters:
-   CCArray
### Returns:
-   Lua table ]]
function utils.array2table(arr)
    if tolua.type(arr) ~= "CCArray" then return end
    local t = {}
    for i = 1,  arr:count() do
        table.insert(t, arr:objectAtIndex(i-1))
    end
    return t
end

--[[--convert hex to ccc3
### Example:
    utils.hex2ccc3("#FFFFFF") -- return ccc3(255, 255, 255)
### Parameters:
-   string
### Returns:
-   c3b]]
function utils.hex2ccc3(hex)
    if string.sub(hex,1,1) ~= "#" then return nil end
    hex = string.sub(hex,2)
    local r,g,b = string.sub(hex,1,2),string.sub(hex,3,4),string.sub(hex,5,6)
    r = tonumber("0x"..r)
    g = tonumber("0x"..g)
    b = tonumber("0x"..b)
    return cc.c3b(r,g,b)
end

function utils.distance(x1,y1,x2,y2)
  local a = x1 - x2
  local b = y1 - y2
  return math.sqrt(math.pow(a, 2) + math.pow(b, 2))
end

function utils.distancePoints(p1,p2)
  return utils.distance(p1.x,p1.y,p2.x,p2.y)
end

function utils.parse_query(query)
    local parsed = {}
    local pos = 0

    query = string.gsub(query, "&amp;", "&")
    query = string.gsub(query, "&lt;", "<")
    query = string.gsub(query, "&gt;", ">")

    local function ginsert(qstr)
        local first, last = string.find(qstr, "=")
        if first then
            parsed[string.sub(qstr, 0, first-1)] = string.sub(qstr, first+1)
        end
    end

    while true do
        local first, last = string.find(query, "&", pos)
        if first then
            ginsert(string.sub(query, pos, first-1));
            pos = last+1
        else
            ginsert(string.sub(query, pos));
            break;
        end
    end
    return parsed
end

--[[--

数字格式化为亿/万单位,(英文环境下为 M/K单位)

### Example:

    utils.numAbbr("123456789") -- return "1.2亿"
    utils.numAbbr("123456") -- return "12.3万"

### Parameters:

-   number int/string  待格式的数值
-   digit int 小数点后位数

### Returns:

-   string

]]
function utils.numAbbr(num, digit)
    digit = digit or 1
    num = checkint(num) 
    local s
    if(num >= 1e7 ) then
        s = string.format("%gM", string.format("%."..digit.."f",num / 1e6));
    elseif(num >= 1e5 ) then
        s = string.format("%gK", string.format("%."..digit.."f",num / 1e3));
    else
        s = tostring(num)
    end
    
    return s
end

function utils.numAbbrZh(num , digit)
    digit = digit or 1
    num = checkint(num)
    num = math.abs(num)
    local s
    if(num >= 1e8 ) then
        s = string.format("%g亿",string.format("%.1f",num / 1e8))
    elseif(num >= 1e4 ) then
        s = string.format("%g万",string.format("%.1f",num / 1e4))
    else
        s = tostring(num)
    end
    return s
end



function utils.formatNumber(num)
    return string.formatnumberthousands(num)
end

function utils.playSound(filename,isloop,suffix)
    if not utils.getUserSetting("sound_enabled",true) then return end
    if filename == nil then return end
    -- if device.platform ~= "android" then
    --     if not suffix then
    --         filename = filename..".mp3"
    --     else
    --         filename = filename .. suffix
    --     end
    --     return audio.playSound("res/mp3/"..filename,isloop)
    -- else
    --     filename = filename..".ogg"
    --     return audio.playSound("res/ogg/"..filename,isloop)
    -- end
    if filename == "check" then
        filename = filename..".m4a"
    else
        filename = filename..".mp3"
    end
    return audio.playSound("res/sound/"..filename,isloop)
end

function utils.stopSound(playSoundBack)
    if playSoundBack then
        audio.stopSound(playSoundBack)
    end
end


local _curr_music = nil
function utils.playMusic(filename,isloop,time)
    if not utils.getUserSetting("music_enabled",false) then return end
    
    if filename == nil then return end
    -- if device.platform ~= "android" then
    --     filename = filename..".mp3";
    -- else
    --     filename = filename..".ogg";
    -- end
    filename = filename..".mp3"
    audio.setMusicVolume(1)
    audio.playMusic("res/music/"..filename,isloop)
    _curr_music = filename
end

function utils.pauseMusic()
    audio.pauseMusic()

end

function utils.resumeMusic()
    -- body
    if not utils.getUserSetting("music_enabled",false) then return end
    if _curr_music then
        audio.resumeMusic()
        return
    end
end

function utils.stopMusic()
    -- body
    _curr_music = nil
    audio.stopMusic()
end

-- cb里返回的为正常业务数据,如cb的code > 0 则表示业务错误, 网络错误内部消化
-- silent 控制是否接管处理网络错误true则抛到业务层处理
-- retryTimes 控制网络错误后的重试次数
local MaxRetryTimes,RetryTimes = 3, 3
function utils.http(url,params,cb,method,silent,retryTimes)
    method = method or "GET"
    if type(params) == "function" then -- 无参数情况下
        params,cb = cb,params
    end
    if type(cb) ~= "function" then
        cb = function()end;
    end
    params = checktable(params)
    if retryTimes then
        RetryTimes = retryTimes
    end
    local function listener(event)
        local request = event.request
        if event.name == "completed" then
             --网络相关错误
            if (request:getResponseStatusCode() ~= 200 and request:getResponseStatusCode() ~= 304) then 
                print(string.format("网络错误:http_code:%d,error_code:%d,msg:%s",
                request:getResponseStatusCode(),request:getErrorCode(),request:getErrorMessage()))
                RetryTimes = RetryTimes - 1
                if silent then 
                    RetryTimes = MaxRetryTimes; 
                    cb({err= checknumber(request:getErrorCode()), msg=request:getErrorMessage()})
                else
                    showDialogTip("网络错误","请您检查网络或稍后重试",{"确定"},function(e)
                        RetryTimes = MaxRetryTimes
                        if e.buttonIndex == 2 then
                            utils.http(url,params,cb,method, silent)
                        else
                            cb({err= checknumber(request:getErrorCode()), msg=request:getErrorMessage()})
                        end
                    end,{"white","green"}, {block = true})
                end
                return
            end
            RetryTimes = MaxRetryTimes
            local data = request:getResponseString()
            if string.find(data,"{") then
                data = checktable(json.decode(data))
            end
            -- 业务逻辑相关错误
            if DEBUG > 0 then
                dump("url ===========" .. url)
                dump(data,"",5)
                dump(request:getResponseStatusCode()  .. "code ===========".. request:getResponseString())
            end
            if data == "3" then
                --TODO session过期
                cb({err= 3, msg="sission error"})
                return
            end
            cb(data,request:getResponseStatusCode())
        elseif event.name == "progress"  then
            if params.progress then
                cb(event)
            end
        else 
            cb({err= checknumber(request:getErrorCode()), msg=request:getErrorMessage()})
        end
    end
    
    local req
    if method and string.upper(method) == "POST" then
        req = network.createHTTPRequest(listener,url,"POST");
        local postData = json.encode(params)
        req:addPOSTValue("api", postData)
        if DEBUG > 0 then
            local json_params = utils.http_build_query(params)
            dump("api调用 --- > " ..url.. "?"..json_params)
        end
    else
        url = url .. "?api=".. json.encode(params)
        req = network.createHTTPRequest(listener,url,"GET");
        if DEBUG > 0 then
            dump("api调用 --- > " ..url)
        end
    end
    
    req:setAcceptEncoding(2)
    req:start()
end

function utils.http_build_query(params)
    local query = ""
    for k, v in pairs(params) do
        query = query..string.format("%s=%s&", k, string.urlencode(v))
    end
    return string.sub(query, 1, string.len(query) - 1)
end

function utils.isnan(x)
    return x ~= x
end

--中文按一个字算
function utils.substr(s,len)
    local str_len = string.len(s)
    if len > str_len then len = str_len end
    local cut_s,i = "",1
    local cut_len = 0
    while len>0  do
        local byte = string.byte(s,i)
        if not byte then break end
        if byte >= 240 then --这是苹果的表情
            cut_s = cut_s .. string.sub(s,i,i+3)
            i=i+4
        elseif byte > 127 then
            cut_s = cut_s .. string.sub(s,i,i+2)
            i=i+3
        else
            cut_s = cut_s .. string.char(byte)
            i = i+1
        end
        len = len -1
        cut_len = cut_len + 1
    end
    return cut_s,cut_len
end

function utils.suffixStr(s,len,suff)
    local s,s_len = utils.substr(s, string.len(s))
    if s_len > len then
        s = utils.substr(s,len-1) .. "…"
    end
    return s
end

function utils.lenMaxToSuffixStr(txt,max)
    local s_len = string.lenbyte(txt)
    if s_len>=2*max-3 and #txt>s_len then
        txt = utils.suffixStr(txt,max)
    elseif s_len>=2*max-2 then
        txt = utils.suffixStr(txt,2*max-3)
    end
    return txt
end


function utils.isURL(url)
    url = _s(url)
    return (string.find(url, "http://") or string.find(url, "http://"))
end

local _setting_file , _setting_cache = device.writablePath .. "user_setting",nil
local _sign_key = "zengcheng"

local function _getAllSetting(  )
    if not _setting_cache  then
        local str = io.readfile(_setting_file) or ""
        if string.byte(str) ~= 123 and str ~= "" then
            if device.platform == "ios" then
                str = crypto.decryptAES256(str,_sign_key)
            else
                str = crypto.decryptXXTEA(str,_sign_key)
            end
        end
       _setting_cache =  checktable(json.decode(str))
    end
    return _setting_cache
end

function utils.getUserSetting( key,default_val )
    local setting = _getAllSetting()
    if setting[key] ~= nil then
        return setting[key]
    elseif default_val then
        return default_val
    end
    return nil
end

function utils.setUserSetting( key,val )
    local setting = _getAllSetting()
    setting[key] = val
    local str = json.encode(setting)
    if device.platform == "ios" then
        str = crypto.encryptAES256(str,_sign_key)
    else
        str = crypto.encryptXXTEA(str,_sign_key)
    end
    return io.writefile(_setting_file,str)
end

function utils.saveFile( path,val )
    local str = json.encode(val)
    if device.platform == "ios" then
        str = crypto.encryptAES256(str,_sign_key)
    else
        str = crypto.encryptXXTEA(str,_sign_key)
    end
    return io.writefile(path,str)
end

function utils.makeAvatar(data)
    data = data or {}

    data           = checktable(data)
    data.icon      = data.icon or ""
    size            = data.size or cc.size(121, 121)
    callback        = data.callback or function(succ, texture, sprite)
            if not succ then return end
                scheduler.performWithDelayGlobal(function()
                    if not sprite or tolua.isnull(sprite) then return end
                    local opacity = sprite:getOpacity()
                    opacity = opacity or 255
                    sprite:setOpacity(255)
                    sprite:setTexture(texture)
                    sprite:stopAllActions()
                    sprite:setOpacity(20)
                    transition.fadeTo(sprite,{
                        time = 0.2,
                        opacity = opacity
                    })
            end, 0.5)
        end
    local head  = display.newNode()
    head:setCascadeOpacityEnabled(true)
    head._size  = size
    head:setContentSize(size)
    head:align(display.CENTER)
    if not data.border then
        data.border = "#gold/border.png"
    end
    head.border = display.newSprite(data.border, size.width/2, size.height/2)
        :addTo(head,5)
    
    local maskPic = "#gold/head-mask.png"
    local def_pic = "default.png"
    local pic = display.newSprite(def_pic)
    local mask    = display.newSprite(maskPic)

    local avatar  = cc.ClippingNode:create(mask)
    avatar:setAlphaThreshold(0.01)
    avatar:setPosition(size.width/2, size.height/2)
    avatar:addChild(pic)
    
    head:addChild(avatar)
    head.avatar = avatar
    head.pic = pic
    if pic:getContentSize().width > size.width then
        pic:setScale(size.width/pic:getContentSize().width)
    end
    -- dump(data.icon)
    -- mask:setScale(size.width/mask:getContentSize().width)
    if data.icon ~= "" then
        utils.loadRemote(pic,data.icon, callback)
    else
        -- head.border:setVisible(false)
    end
    return  head, pic
end

function utils.readeFile( path)
    local str = io.readfile(path) or ""
    if str ~= "" then
        if device.platform == "ios" then
            str = crypto.decryptAES256(str,_sign_key)
        else
            str = crypto.decryptXXTEA(str,_sign_key)
        end
    end
    return checktable(json.decode(str))
end




function utils.loadRemote(sprite,url, callback)
    if tolua.isnull(sprite) or tolua.type(sprite) ~= "cc.Sprite" then
        print("error params@CCSprite.loadRemote")
        return
    end
    local shareCache = cc.Director:getInstance():getTextureCache()
    if not string.find(url,"http://") and not string.find(url,"https://") then
        if io.exists(url) then
            local texture = shareCache:addImage(url)
            sprite:setTexture(texture)
        end
        if type(callback) == "function" then
            callback(false,nil,sprite,false)
        end
        return sprite
    end
    callback = callback or function(succ,texture,sprite,isCache)
        if not succ then return end
        -- 这两句判断可以去掉,暂时保留
        if tolua.type(texture) ~= "cc.Texture2D" then return end
        if not sprite or tolua.isnull(sprite)  or tolua.type(sprite) ~= "cc.Sprite"  then return end
        sprite:setTexture(texture)
        transition.fadeIn(sprite,{time = .2})
    end

    local _key = crypto.md5(url)
    local texture = shareCache:getTextureForKey(_key)
    if not texture then
        texture = shareCache:getTextureForKey(__cachedir .. _key)
        -- texture = shareCache:getTextureForKey(device.writablePath .. _key)
    end
    if texture  and not tolua.isnull(texture)  and tolua.type(texture) == "cc.Texture2D" then
        if type(callback) == "function" then
            callback(true, texture, sprite, true)
        end
        return sprite
    end

    utils.loadImage(url,function(succ, ccimage, isCache)
        if succ then
            local texture
            if tolua.type(ccimage) == "cc.Image" then
                texture = shareCache:addUIImage(ccimage,_key)
                ccimage = nil
            elseif type(ccimage) == "string"  and ccimage ~= "" then
                -- texture = shareCache:addImage(ccimage)
                local ret,errMessage = xpcall(function ( ... )
                    texture = shareCache:addImage(ccimage)
                end,function ( ... )
                    cb(false , nil,sprite , false)
                    return
                end)
            end
            if tolua.type(texture) == "cc.Texture2D" and tolua.type(sprite) == "cc.Sprite"  then
                return callback(true, texture, sprite, false)
            end
        end
        callback(false,nil,sprite,false)
    end)
    return sprite
end

function utils.loadImage(url,cb)

    if not string.find(url,"http://") and not string.find(url,"https://") then
        if io.exists(url) then
            local texture = shareCache:addImage(url)
            sprite:setTexture(texture)
        end
        if type(cb) == "function" then
            cb(false,nil)
            return
        end
    end

    local key = crypto.md5(url)
    local save_path = __cachedir .. key
    if tolua.type(save_path) == "cc.Image" then
        cb(true , save_path , false)
        return
    end
    if type(save_path) == "string" and save_path ~= "" then
        local texture
        local ret,errMessage = xpcall(function ( ... )
            texture = shareCache:addImage(save_path)
        end,function ( ... )
            cb(false , save_path , false)
            return
        end)
        if tolua.type(texture) == "cc.Texture2D" then
            cb(true , save_path , false)
            return
        end
    end

    local req = network.createHTTPRequest(function(event)
        local ok = (event.name == "completed")
        local request = event.request
        local errCode = request:getErrorCode()
        local statusCode = 0
        if ok then
            statusCode = request:getResponseStatusCode()
        end
        if ok and statusCode == 200 then
            request:saveResponseData(save_path)
            return cb(true, save_path)
        elseif event.name == "progress" then
        else
            return cb(false, save_path, false) 
        end
    end,url,"GET")
    req:start()
end

function utils.loadData(url, cb)
    -- 强制刷新
    local key = crypto.md5(url)
    local req = network.createHTTPRequest(function(event)
        local ok = (event.name == "completed")
        local request = event.request
        local errCode = request:getErrorCode()
        local statusCode = 0
        if ok then
            statusCode = request:getResponseStatusCode()
        end
        if ok and statusCode == 200 then
            -- request:saveResponseData(save_path)
            return cb(true, checktable(json.decode(request:getResponseString())))
        elseif event.name == "progress" then
        else
            return cb(false) 
        end
    end,url,"GET")
    req:start()
end

function utils.loadRes(data)
    -- 强制刷新
    local req = network.createHTTPRequest(function(event)
        local ok = (event.name == "completed")
        local request = event.request
        local errCode = request:getErrorCode()
        local statusCode = 0
        if ok then
            statusCode = request:getResponseStatusCode()
        end
        if ok and statusCode == 200 then
            request:saveResponseData(data.path)
            print(string.format("load %s success! >>> statusCode:%d,errorCode:%d",data.url,statusCode,errCode))
            return data.cb(true)
        elseif event.name == "progress" then
            if data.progress then
                data.progress(event.dltotal)
            end
        else
            print(string.format("load %s fail! >>> statusCode:%d,errorCode:%d",data.url,statusCode,errCode))
            return data.cb(false) 
        end
    end,data.url,"GET")
    req:start()
end

function utils.toAppstoreGrade( itunesId )
    local url = string.format("itms-apps://itunes.apple.com/app/id%d", itunesId) 
    device.openURL(url)
end

function string.lenbyte(str)
    return #(string.gsub(str,'[\128-\255][\128-\255]',' '))
end

-- 截取utf8 字符串
-- str:         要截取的字符串
-- startChar:   开始字符下标,从1开始
-- numChars:    要截取的字符长度
function string.utf8sub(str, startChar, numChars)
    local startIndex = 1
    while startChar > 1 do
        local char = string.byte(str, startIndex)
        startIndex = startIndex + chsize(char)
        startChar = startChar - 1
    end

    local currentIndex = startIndex

    while numChars > 0 and currentIndex <= #str do
        local char = string.byte(str, currentIndex)
        currentIndex = currentIndex + chsize(char)
        numChars = numChars -1
    end
    return str:sub(startIndex, currentIndex - 1)
end

-- local str = "abcdef红绿蓝紫"
-- local _, count = string.gsub(str, "[^\128-\193]", "")
-- local tab = {}
-- for uchar in string.gfind(str, "[%z\1-\127\194-\244][\128-\191]*") do
--  tab[#tab+1] = uchar
-- end
-- for i=1,8 do
-- print(tab[i])
-- end

function string.lastindexof(haystack, needle)
    local i, j
    local k = 0
    repeat
        i = j
        j, k = string.find(haystack, needle, k + 1, true)
    until j == nil

    return i
end


--字符串分割函数
--传入字符串和分隔符，返回分割后的table
function string.split(str, delimiter)
    if str==nil or str=='' or delimiter==nil then
        return nil
    end
    
    local result = {}
    for match in (str..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match)
    end
    return result
end

function utils.callStaticMethod( cls, method, args, args_order, sig)
    if device.platform == "ios"  then
        return luaoc.callStaticMethod(cls, method, args)
    elseif device.platform == "android" then
        if cls == "MyGotye" then return end
        luaj = require("framework.luaj")
        local base_package = "com/qqsgame/texas_mobile/"
        if string.find(cls,"com.") then
            base_package = cls
        else
            cls = base_package..cls
        end
        if sig then
            if not string.find(sig,"Ljava") then
                sig = string.gsub(sig,"S","Ljava/lang/String;")
            end
        end
        if args_order then
            new_args = {}
            for _ ,k in ipairs(args_order) do
                table.insert(new_args,args[k])
            end
            args = new_args
        elseif args then
            args = table.values(args)
        end
        return luaj.callStaticMethod(cls, method, args, sig)
    else
        print("%s:%s not support this platform: %s",cls, method, device.platform)
    end
end

-- 获取app的版本
function device.getAppVersion()
    if device.platform == "ios" then
        local ok, r = utils.callStaticMethod("Helper","getAppVersion")
        return r
    elseif device.platform == "android" then
        local ok, r = utils.callStaticMethod("Helper","getAppVersion",{},{},"()S")
        return r
    end
end


function device.getDeviceID()
    local ok, r 
    if device.platform == "ios" then
        r = cc.UserDefault:getInstance():getStringForKey("GUEST_NAME")-- 字符串
        if not r or r == "" then
            ok, r = utils.callStaticMethod("Helper","getOpenUDID")
        end
    elseif device.platform == "android" then
        ok, r = utils.callStaticMethod("Helper","getUID",{},{},"()S")
    else
        device.deviceID = utils.getUserSetting("device_deviceID",false)
        if not device.deviceID  then
            device.deviceID = os.date("%Y-%M-%d-%X")..math.random(1,99999999)
        end
        utils.setUserSetting("device_deviceID",device.deviceID)
        return device.deviceID
    end
    return r
end
device.deviceID = device.getDeviceID()

--测试
-- device.deviceID = os.date("%Y-%M-%d-%X")..math.random(1,99999999)

function device.vibrate(t)
    if device.platform == "ios" then
        cc.Native:vibrate()
    elseif device.platform == "android" then
        utils.callStaticMethod("Helper","shock",{},{},"()V")
    end
end

function exitApp()
    if device.platform == "ios" then
        os.exit()
    elseif device.platform == "android" then
        utils.callStaticMethod("Helper","exitApp",nil,nil,"()V")
    end
end

return utils