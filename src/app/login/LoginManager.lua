local LoginManager = class("LoginManager")


function LoginManager:ctor()
   
end

function LoginManager.callback (data)
		local svflag = data.svflag
		if data.err  then
    				--网络错误处理
		elseif data.svflag == 1 then
			data = data.data
			USER.sessionKey = data.sesskey
			USER.sitemid = data.sitemid
			--------------------
			CONFIG.server = {}
			CONFIG.port = {}
			local server = data.server
			server = string.split(server, ",")
			local tmp = {}
			for i,v in ipairs(server) do
				tmp = string.split(v, ":")
				CONFIG.server[#CONFIG.server+1] = tmp[1]
				CONFIG.port[#CONFIG.port+1] = tmp[2]
			end
			CONFIG.activityImgUrl = data.mobileUrl
			CONFIG.activityUrl = data.baseUrl
			
			------------------
			CONFIG.ver = data.ver
			CONFIG.dataUrl = data.dataUrl

			--缓存到本地
			local login = utils.getUserSetting("LOGIN",{})
			login.sitemid=data.sitemid
			login.login_type = CONFIG.LOGIN_TYPE
			login.nick_name = USER.name
			login.dataUrl = data.dataUrl
			login.ver = data.ver
			utils.setUserSetting("LOGIN",login)
			
			--完成后加载用户信息
			LoginManager.getUserInfo()
			LoginManager.dayFirst()
			
			--拿活动的xml活动配制，房间
			LoginManager.parserRoomCfg()
			LoginManager.parserCommon()
			-- LoginManager.parserAwardCfg()
			-- if device.platform == "ios" then
			-- 	utils.callStaticMethod("Helper","recordPermission",{callback = function ( data)
			--         CONFIG.recordPermission = data
			--     end},{"callback"},"(I)V")
			-- end
			

		elseif data.svflag == 1004 then
			--服务器更新中
			showDialogTip("",data.data.msg,{"确定"},function ( flag )
				SceneManager.switch("LoginScene")
			end)
			return
		else
			--登陆失败
		end
		app:dispatchEvent({name = "http.login" , data = svflag})
	end

function LoginManager.login(data)
	local login = LoginManager.getLogin(data)
	CONFIG.LOGIN_TYPE = data.login_type
	login:login(data,function (login_data )
		LoginManager.callback(login_data)
	end)
	
end

function LoginManager.dayFirst()
	utils.http(CONFIG.API_URL,
    		{
	    		method="Amember.dayFirst",
	    		sesskey=USER.sessionKey,

    		},function ( data )
    			if data.svflag == 1 then
    				USER.hongbao = checkint(data.data[1])
    				if checkint(data.data[2][1]) > 0 then
    					makeNews({id = data.data[2][1]..os.time() , time = os.time() , status = 1, type = 1, tab = 2, title = "退还系统红包", msg = string.format("很遗憾，你发出的红包有人未能在规定时间内领取，我们将退还给你(退还个数%d)",checkint(data.data[2][1]))})
    				end
    				if checkint(data.data[2][2]) > 0 then
    					makeNews({id = os.time() , time = os.time() , status = 1, type = 1, tab = 2, title = "退还红包", msg = string.format("很遗憾，你发出的红包有人未能在规定时间内领取，我们将退还给你(退还筹码%s)",utils.numAbbrZh(checkint(data.data[2][2])))})
					end
    			end

    	end,"POST")
end

function LoginManager.getLogin(data)
	local login
   	if data.login_type == 0 then--游客
   		login = require("app.login.GuestLogin").new()
   	elseif data.login_type == 1 then--牵手
   		login = require("app.login.QsLogin").new()
   	elseif data.login_type == 2 then--qq
   		login = require("app.login.QQLogin").new()
   	elseif data.login_type == 3 then--微信
   		login = require("app.login.WChatLogin").new()
   	end
	
	return login
end

function LoginManager.getUserInfo()
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
    				utils.__merge(USER,data.aGame)

    				CONFIG.canaward = data.canaward
    				CONFIG.isaddf = data.isaddf
    				CONFIG.isdayfrist = data.isdayfrist
    				CONFIG.ismobile = data.ismobile
    				CONFIG.lotcount = data.lotcount
    				CONFIG.nowtime = data.nowtime
    				CONFIG.tcost = data.tcost

    				CONFIG.news = utils.getUserSetting(USER.mid.."CONFIG.news" , {})
					LoginManager.loadNews()

    				--连接socket服务器
    				NetManager.connectToServer()
    				-- utils.callStaticMethod("MyGotye","gotypeLogin",{name=USER.mid..""},{"name"},"(S)V")
    			else

    			end

    	end,"POST")
end

function LoginManager.parserRoomCfg()
	local filename =  device.writablePath.."room.data"
	CONFIG.ver = nil
	if CONFIG.ver == utils.getUserSetting("room_version" , 0) then
		CONFIG.roominfo = utils.readeFile(filename)
		dump(CONFIG.roominfo)
	else
		utils.loadData(CONFIG.dataUrl.."room.data", function ( isok  , roomdata )
			if isok then
				ParseXml.parseRoomInfo(roomdata.content.room)
				-- dump(CONFIG.roominfo)
				utils.saveFile(filename,CONFIG.roominfo)
				utils.setUserSetting("room_version" , CONFIG.ver)
			end

		end)
	end
end


function LoginManager.parserPropsCfg()
	local filename = device.writablePath.."props.data"
    if CONFIG.ver == utils.getUserSetting("props_version" , 0) then
		CONFIG.PROP = utils.readeFile(filename)
		ParseXml.parseProp(CONFIG.PROP)
		return 
	end
	
    utils.loadData(CONFIG.dataUrl.."props"..CONFIG.appversion..".data", function ( isok , data )
		if isok then
			utils.saveFile(filename,data)
			utils.setUserSetting("props_version" , CONFIG.ver)
			ParseXml.parseProp(data)
		end
	end , filename)

end

function LoginManager.parserCommon()
	local filename = device.writablePath.."common.data"
    if CONFIG.ver == utils.getUserSetting("common_version" , 0) then
		-- CONFIG.COMMON = utils.readeFile(filename)
		-- ParseXml.parseCommon(CONFIG.COMMON) --解析
		ParseXml.parseCommon(utils.readeFile(filename)) --解析
		return 
	end
    utils.loadData(CONFIG.dataUrl.."common"..CONFIG.appversion..".data", function ( isok , data )
		if isok then
			utils.saveFile(filename,data)
			ParseXml.parseCommon(data) --解析
			utils.setUserSetting("common_version" , CONFIG.ver)
		end

	end , filename)
end

function LoginManager.loadNews(_type)
	_type = _type or 0
	utils.http(CONFIG.API_URL,
    	{
	    	method = "Anotice.getMessage",	    
	    	sesskey = USER.sessionKey,
	    	isnew = 1,
	    	type = _type,
    	},function ( data )

			if data.svflag ~= 1 then
				return
			end		
			local flag = true,pot,msg,title,str
			local arr = {}
			for k , v in pairs(data.data.arr) do
				str = v
				flag = true
				arr = string.split(str,"#")
				LoginManager.makeNews({	id = arr[1].._type , 
						time = arr[3] , 
						status = 1 , 
						type = arr[2] , 
						tab = 2 , 
                        title = arr[4] ,
						msg = arr[5]})
			end	
    		local i = 1
			while i <= #CONFIG.news do

				local des_time = os.time() - CONFIG.news[i].time
				if des_time > 24 * 60 * 60 then
					table.remove(CONFIG.news, i)
				else
					i = i + 1
				end
			end
			utils.setUserSetting(USER.mid.."NEWS" , CONFIG.news)
    	end,"POST")

end


function LoginManager.makeNews(data)
	local des_time = os.time() - data.time
	if des_time > 30 * 24 * 60 * 60 then
		return
	end	
	for i,v in ipairs(CONFIG.news) do
		if v.id == data.id then
			return
		end
	end
	table.insert( CONFIG.news ,1, {	id = data.id , 
							time = data.time, 
							status = data.status or 1 , 
							type = data.type or 1 , 
							tab = data.tab or 2 , 
							title = data.title , 
							msg = data.msg } )
end

return LoginManager