 ParseXml= class("ParseXml")
--房间信息
function ParseXml.parseRoomInfo(roomdata)
	CONFIG.roominfo = {}
	CONFIG.room100info = {}
	local item 
	for k,v in pairs(roomdata) do
		if v["@attributes"].type == "K1" then
			for i,v1 in ipairs(v.item) do
				item = v1["@attributes"]
				-- dump(item)
				table.insert(CONFIG.roominfo,{blind =  checkint(item.blind),min = checkint(item.min),typeId = checkint(item.rid),name = item.name})
			end
		elseif v["@attributes"].type == "B1" then
			if #v.item > 1 then
				for i,v1 in ipairs(v.item) do
					item = v1["@attributes"]
					table.insert(CONFIG.room100info,{beginRid =  checkint(item["begin"]),endRid =  checkint(item["end"])})
				end
			else
				item = v.item["@attributes"]
				table.insert(CONFIG.room100info,{beginRid =  checkint(item["begin"]),endRid =  checkint(item["end"]),min = checkint(item["max"])})
			end
		end
	end
	-- dump(CONFIG.roominfo)
	-- dump(CONFIG.room100info)
end

	


--任务
function ParseXml.parseCommon(commom)
	-- dump(commom.content,"",5)
	local data = {}
	for i,v in ipairs(commom.content.fastmsg.item) do
		data[i] = v["@attributes"].msg
	end
	CONFIG.fastMsg = data
	data = {}
	local site,pcate,pframe,_type
	for i,v in ipairs(commom.content.task.item) do
		site = checkint(v["@attributes"].site)
		if site < 2 then
			_type = checkint(v["@attributes"].type)
			pcate = checkint(v["@attributes"].pcate)		--排序 
			pframe = checkint(v["@attributes"].pframe)
			key = pcate..pframe
			-- if _type == 1 then
				data[key] ={
					pcate = pcate,
					pframe = pframe,
					key = key,
					_type = _type --type=1日常任务，2是支线任务
				}
				data[key].award = checkint(v["@attributes"].award)  	--奖历多少钱
				data[key].dec = v["@attributes"].des
				data[key].name = v["@attributes"].name
				data[key].url = v["@attributes"].url
				data[key].needNum = checkint(v["@attributes"].value) --需要多少次完成任务
				data[key].subtype = checkint(v["@attributes"].subtype)
			-- else
			-- 	data1[key] ={
			-- 		pcate = pcate,
			-- 		key = key,
			-- 		pframe = pframe,
			-- 		_type = _type --type=1日常任务，2是支线任务
			-- 	}
			-- 	data1[key].award = checkint(v["@attributes"].award)  	--奖历多少钱
			-- 	data1[key].dec = v["@attributes"].des
			-- 	data1[key].name = v["@attributes"].name
			-- 	data1[key].url = v["@attributes"].url
			-- 	data1[key].needNum = checkint(v["@attributes"].value) --需要多少次完成任务
			-- 	data1[key].subtype = checkint(v["@attributes"].subtype)
			-- end
			-- <option value="1">完成局数</option>
			-- <option value="2">胜利局数</option>
			-- <option value="3">HOT场玩牌</option>
			-- <option value="4">购买任何道具</option>
			-- <option value="5">充值</option>
			-- <option value="6">ALL IN次数</option>
			-- <option value="7">分享次数</option>
			-- <option value="8">邀请次数</option>
			-- <option value="9">赢取大盲注倍数</option>
			-- <option value="10">牌型胜利</option>
			-- <option value="11">玩牌计时</option>
			-- <option value="12">HOT玩牌计时</option>
			-- <option value="13">每日登录</option>
			-- <option value="14">成为VIP</option>
			-- <option value="15">幸运777</option>

		end		
	end
	CONFIG.task = data
	-- 从小到大
	table.sort(CONFIG.task,function(a,b)
        return a.key < v.key
    end)

    -- CONFIG.SignInBase = {}
    -- for i,v in ipairs(commom.content.re_couple.item) do
    -- 	table.insert(CONFIG.SignInBase,v["@attributes"])
    -- end
   	-- dump(commom.content.vipmobile.item,"",5)
    data = {}
    CONFIG.vipAdd = {}
    CONFIG.storeItems = {}
    for i,v in ipairs(commom.content.vipmobile.item) do
		data = v["@attributes"]
		data.content = json.decode(data.content)
		if checkint(data.id) >= 3 and checkint(data.id) <= 7 then
			CONFIG.vipAdd[#CONFIG.vipAdd + 1]  = data.content["13"]
		end
		table.insert( CONFIG.storeItems,data)
    end
    -- CONFIG.level = {}
    -- dump(commom.content.required,"",5)
    -- for i,v in ipairs(commom.content.required.item) do
    -- 	table.insert(CONFIG.level,v["@attributes"])
    -- end
    --配制
  	-- local config = commom.content.sysnum.item
  	-- dump(config,"",5)
 --  	CONFIG.SignInCycle = config[2]["@attributes"].count
	-- CONFIG.slot.isopen = config[17]["@attributes"].count == "1" and true or false
	-- CONFIG.slot.wingame =  checkint(config[18]["@attributes"].count)
	-- CONFIG.activity =  config[20]["@attributes"].count == "1" and true or false
	-- CONFIG.storeVipCard =  config[21]["@attributes"].count == "1" and true or false
	-- CONFIG.rankingAdderss =  config[22]["@attributes"].count == "1" and true or false
	-- CONFIG.turntable =  config[23]["@attributes"].count == "1" and true or false
	-- CONFIG.turntableVip =  config[24]["@attributes"].count == "1" and true or false
	-- CONFIG.WCHAT_PAY =  config[26]["@attributes"].count == "1" and true or false
	-- CONFIG.openActivity =  config[27]["@attributes"].count == "1" and true or false
	-- CONFIG.getUserInfo =  config[28]["@attributes"].count == "1" and true or false
	CONFIG.activity = {}
	dump(commom.content.mobileac.item,"",5)
	if #commom.content.mobileac.item > 1 then
		for k,v in pairs(commom.content.mobileac.item) do
	 		local data = v["@attributes"]
	 		if checkint(data.isopen) == 1 then
	 			table.insert(CONFIG.activity,data)
	 		end
 		end
 	else
 		local data = commom.content.mobileac.item["@attributes"]
 		if checkint(data.isopen) == 1 then
 			table.insert(CONFIG.activity,data)
 		end
 	end
end

function ParseXml.parseProp(prop)
	local data = {}
	local pcate
	local pframe
	-- dump(prop.content.props,"",5)
	CONFIG.gift = {}
	for k , v in pairs(prop.content.props) do
		local info = v["@attributes"]
		pcate = checkint(info.pcate)
		for k , v in pairs(v["item"]) do
			local info = v["@attributes"]
			pframe =  checkint(info.pframe)
				local key = pcate.."_"..pframe
				data[key] = {}
				data[key].pcate = pcate
				data[key].pframe = pframe
				data[key].des = info.description
				data[key].price = checkint(info.mobile_price)
				data[key].name = info.name
				data[key].day =   checkint(info.validity)
			if info.mtype == "1" then
				table.insert(CONFIG.gift , data[key])	
			end
		end
	end	
	CONFIG.prop = data
end


return ParseXml