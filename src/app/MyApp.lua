
require("config")
require("cocos.init")
require("framework.init")

require("app.tools.libext")
require("app.tools.deprecated")
require("app.tools.tips")

Loading = require("app.tools.Loading")
utils = require("app.tools.utils")
SocketTCP = require("framework.cc.net.SocketTCP")
scheduler = require("framework.scheduler")
NetManager = require("app.net.NetManager")
SendCMD = require("app.net.SendCMD")
ParseSocket = require("app.net.ParseSocket")
LoginManager = require("app.login.LoginManager")
Store = require("framework.cc.sdk.Store")

Chip = require("app.views.game.Chip")
Card = require("app.views.game.Card")
Card100 = require("app.views.game.Card100")

-- lType = {
-- 		1,    -- 默认如果第一次登录游戏
-- 	   	2,		--去登陆界面 
-- 	    3,	--登陆
-- 	    4,        -- 重连
-- 	    5,    -- 进入房间
-- 	    6,    -- 切换房间
-- 	    7,    -- 退出房间
-- 	    10,       -- 进新手帮助
-- 	}
CONFIG = {
	API_URL = "http://192.168.1.110:8080/bullfighting/api/mobile/api.php",
	-- API_URL = "http://bullfight.app200312266.twsapp.com/bullfighting/api/mobile/api.php"
	gp = 101,
	lType = 1,
	channel = 2000,
    niuType = {"牛一","牛二","牛三","牛四","牛五","牛六","牛七","牛八","牛九","牛牛","白皮牛","炸弹","五花牛","五小牛"},
    Ranking = {1,2},
    loadingTips ={
        "不要惧怕任何人，同样不要小视任何人",
        "该出手时就出手，切勿贪得无厌",
        "风水不好时，换个位置",
        "拿到4条的概率为1/4165",
        "位置、耐心与强牌是玩德州扑克的致胜关键",
        "尊重自己、尊重别人是长久胜利的口粮",
        "有时输钱是一种赢钱的策略，扮猪吃老虎有时很有效果",
        "翻牌指最初的3张公共牌",
        "打牌要打出气势，没有胆量就没有产量",
        "人生就像赌博，洗牌是上天，但是玩牌的是自己",
        "应该懂得什么时候去放弃",
        },
    UPDATA_URL = "http://www.baidu.com",
    -- UPDATA_URL = "http://app100642929-1.qzoneapp.com/poker/api/mobile/channel/channel.html",
    SHARE_URL = "http://app.qq.com/#id=detail&appid=1101746538",
    upDealer = {}
}
USER = {}
CMD = {
    HEART = 10006,
    SERVER_CLOSE = 10003,
    
    BIND_USER_AND_UPDATE_UICON = 1056,

    --socket登陆
    LOGIN                    = 1000,
    --推送房间里玩家信息
    ROOM_ALL_USER           =1002,
    --退出房间
    OUT_ROOM                 = 1004,
    --广播玩家进入（玩家信息）
    USER_IN_ROOM                 = 1005,
    --进入房间
    IN_ROOM                  = 1101,
    --游戏开始
    GAME_START                  = 1102,
    
  
    --抢庄
    QIANG_ZHUANG = 1103,
    WHO_GET_ZHUANG = 1104,
    --下注倍数
    BEI = 1105,
    --第二次发牌
    SECOND_CARD = 1106,
    --亮牌
    SHOW_CARD = 1107,
    --游戏结束
    GAME_CALCULATE = 1111,
    --游戏结算
    GAME_OVER = 1108,
    --重连的房间信息
    RE_LOGIN_ROOMINOF = 1109,
    --重连
    RE_LOGIN = 1110,
    
    --在线时长，和玩牌数的数据
    SERVER_PUSH_PLAYER_PLAYING_TIME           = 1036, 
    --任务完成推送
    PUSH_MISSION_COM_STATUS             = 1202,
    --任务状态数据推送
    MISSION_COM_STATUS             = 1201,


     --客户端请求赠送礼物 购买礼物
    CLIENT_REQUEST_PRESENT_GIFT               = 3001,
    --用户请求存钱
    BANK_SAVE_MONEY                           = 3011,
    --用户请求取钱
    BANK_TAKE_MONEY                           = 3012,
    --转账
    BANK_TURN_MONEY                           = 3013,
    --追踪用户
    BANK_TURN_MONEY                           = 3016,
    --修改银行密码
    CLIENT_REQUES_UPDATE_PASSWD               = 3024,

    --表情
    CLIENT_REQUEST_USE_FACE                     = 1032,
    --聊天
    CLIENT_REQUEST_CHAT_MESSAGE               = 2001,
    --聊天消息 广播消息
    CHAT_MSG                = 2002,

    --进百人场
    IN_ROOM100                    = 1001,
    --亮牌
    SHOW_CARDS                = 1041,
    --广播谁上庄
    UP_DEALER                = 1006,
    --广播谁下庄
    DOWN_DEALER                = 1007,

    --请求上庄
    REQ_UP_DEALER                = 1053,
    --请求下庄
    REQ_DOWN_DEALER                = 1054,

    --4个位置的下注额度
    CHIP_LIMIT      =   1055,
    --开始下注
    CHIP_BEGIN      =   1056,
    --下注
    CHIP_IN    = 1057,
    --通知庄丢股子dice
    DEALER_DICE    = 1058,
    --输赢历史
    GAME_HIS    = 1059,
    --抢庄列表
    DEALER_LIST    = 1060,
    --结算
    GAME100_CALCULATE    = 1061,
    --玩家请求丢股子
    PLAYER_DICE    = 1062,

}
ERR_INFO = {}
ERR_INFO["1000-2"] = "会话KEY校验失败"
ERR_INFO["1000-1"] = "登录失败, 未知错误"
ERR_INFO["1000-3"] = "你的账号在别处登录"
ERR_INFO["1000-4"] = "页面已过期，请重新登录"

local MyApp = class("MyApp", cc.mvc.AppBase)

function MyApp:ctor()
    MyApp.super.ctor(self)
end

function MyApp:run()
    cc.FileUtils:getInstance():addSearchPath("res/")

    CONFIG.appversion = device.getAppVersion()
    CONFIG.seat={}
    CONFIG.seat[1] = 1
    CONFIG.seat[3] = 2
    CONFIG.seat[5] = 3
    CONFIG.seat[7] = 4
    CONFIG.seat[9] = 5

    CONFIG.cardVal ={}
    CONFIG.cardVal["1"] = 1
    CONFIG.cardVal["2"] = 2
    CONFIG.cardVal["3"] = 3
    CONFIG.cardVal["4"] = 4
    CONFIG.cardVal["5"] = 5
    CONFIG.cardVal["6"] = 6
    CONFIG.cardVal["7"] = 7
    CONFIG.cardVal["8"] = 8
    CONFIG.cardVal["9"] = 9
    CONFIG.cardVal.T = 10
    CONFIG.cardVal.J = 10
    CONFIG.cardVal.Q = 10
    CONFIG.cardVal.K = 10
    CONFIG.cardVal.A = 1
    -- CONFIG.channel = Launcher.channel
    self:enterScene("MainScene")
end


-- 1000，用户登陆。
-- INT32  MID 
-- STRING 密码
-- 返回
-- INT32 错误代码
-- {
--         static const std::int32_t   REGISTER_SUCCESS = 0;           //登陆成功
--         static const std::int32_t   REGISTER_FAILED = 1;        //登陆失败, 未知错误.
--         static const std::int32_t   REGISTER_KEY_ERROR = 2;         //会话KEY校验失败
--         static const std::int32_t   REGISTER_RELOGIN = 3;           //重复登陆, 只会发给前一个连接.
-- }

-- 1001， 进入房间
-- INT32 服务器ID
-- INT32 房间ID
-- 返回
-- INT32 错误代码
-- INT32 座位ID
-- STRING 服务器端版本号
--  
-- 1004 ，离开房间
-- 返回
-- 无返回值

-- 1026， 游戏结束

-- 1027， 玩家准备就绪 
-- 返回，广播
-- INT32 MID

-- 1038， 请求抢庄
-- INT32 , 0，不抢。1，抢庄
-- 返回，广播
-- INT32 座位ID 
-- INT32 , 0，不抢。1，抢庄

-- 1041， 亮牌
-- 返回 （广播）
-- INT32 座位ID
-- STRING 牌，固定读三张
-- INT32 牌型


-- 1042 ，服务器通知选择倍数

-- 1043， 玩家选择压注倍数
-- INT32 倍数
-- 返回 (广播)
-- INT32 座位号
-- INT32 倍数

-- 1044 游戏开始
-- INT32, 进入本局的玩家数
-- INT32 座位ID （循环）

-- 1045， 发牌
-- STRING 牌（读三张） （旁观玩家收到的牌是 "-"）

-- 1046, 结算

-- 1047, 推送游戏状态信息
-- INT32 游戏状态
-- INT32 游戏子状态
-- INT32 庄家座位
-- INT32 玩家个数
-- //循环
-- INT32 座位ID
-- INT32 MID

-- INT32 是否准备就绪
-- INT32倍数
-- INT32 是否抢庄 //-1， 未表决。0，不抢。1，抢庄
return MyApp
