//#include "GotyeAPI.h"
//USING_NS_GOTYEAPI;///< 使用gotyeapi名空间，后续代码段不再提示。
//#import "MyGotye.h"
//
//#include "cocos2d.h"
//#include "CCLuaEngine.h"
//#include "CCLuaBridge.h"
//using namespace cocos2d;
//
//
//
//@implementation MyGotye
//
////std::vector<GotyeRoom>  roomlist;
//std::vector<GotyeMessage>  messageList;
//GotyeRoom room;
//
//
////语音监听类
//class yourClass: public GotyeDelegate
//{
//    public: string msgData;
//    public: bool autoPlay = true;
//    public: int sendCancel_ = 0;
//    public: int callback_ = -1;
//    // 监听房间列表回调
//    virtual void onGetRoomList(GotyeStatusCode code, unsigned pageIndex, const std::vector<GotyeRoom>& curPageRoomList, const std::vector<GotyeRoom>& allRoomList){
////                for (size_t i =0; i < allRoomList.size(); i ++) {
////        
////                    GotyeRoom r = allRoomList[i];
//////                    NSLog(@"%lld",r.id);
////                    NSLog(@"%s",r.name.c_str());
////                    
////                }
//
//    }
//
//         // 监听登录回调
//    virtual void onLogin(GotyeStatusCode code, const GotyeLoginUser& user){
//        NSLog(@"%d",callback_);
//        if(code == GotyeStatusCodeOK || code == GotyeStatusCodeOfflineLoginOK || code == GotyeStatusCodeReloginOK){
////            //you have signed in the server successfully, do something you are interested in.
//            [MyGotye threadRequest];
//        }
//        
//    }
//    // 监听登出回调
//    virtual void onLogout(GotyeStatusCode code){
//         NSLog(@"sendMessage result: %d", code);
//        if(code == GotyeStatusCodeNetworkDisConnected){
//             NSLog(@"sendMessage 网络错误！");
//        }
//    }
//    
//    // 监听消息发送回调
//    virtual void onSendMessage(GotyeStatusCode code, const GotyeMessage& message){
////        char buf[512] = {0};
////        message.getExtraData(buf);
////        NSLog(@"%s",buf);
////        NSLog(@"sendMessage result: %d", code);
////        apiist->playMessage(message); ///< 下载完成马上播放
//        if(callback_ > 0){
//            NSInteger sec = message.media.duration < 1000 ? 1: message.media.duration /1000;
//           
//            char buf[512] = {0};
//            message.getExtraData(buf);
//            
//            NSString *insertstr = [[NSString alloc] initWithFormat:@"\"sec\" : %ld,",(long)sec];
//        
//            NSMutableString *str =[ [NSMutableString alloc] initWithString:[NSString stringWithUTF8String:buf]];
//            [str insertString:insertstr atIndex:1];
//            
//            LuaBridge::pushLuaFunctionById(callback_);
//            LuaStack *stack = LuaBridge::getStack();
//            stack->pushString([str UTF8String] );
//            stack->executeFunction(1);
//        }
//        if(messageList.size() >= 50){
//            messageList.erase(messageList.begin());
//        }
//        messageList.push_back(message);
//    }
//    
//    // 监听消息接收回调
//    virtual void onReceiveMessage(const GotyeMessage& message, bool* downloadMediaIfNeed){
//        //        LOGD("receive a message: type(%d), from %s", message.type, message.sender.name.c_str());
//        if(callback_ > 0){
//        
//            NSInteger sec = message.media.duration < 1000 ? 1: message.media.duration /1000;
////            LuaValueDict item;
//            char buf[512] = {0};
//            message.getExtraData(buf);
//            NSString *insertstr = [[NSString alloc] initWithFormat:@"\"sec\" : %ld,",(long)sec];
//            
//            NSMutableString *str =[ [NSMutableString alloc] initWithString:[NSString stringWithUTF8String:buf]];
//            [str insertString:insertstr atIndex:1];
//            
//            LuaBridge::pushLuaFunctionById(callback_);
//            LuaStack *stack = LuaBridge::getStack();
//            stack->pushString([str UTF8String] );
//            stack->executeFunction(1);
//        }
//        *downloadMediaIfNeed = autoPlay;
//        if(messageList.size() >= 50){
//            messageList.erase(messageList.begin());
//        }
//        messageList.push_back(message);
//        
//        
//    }
//    
//    // 监听消息下载回调
//    virtual void onDownloadMediaInMessage(GotyeStatusCode code, const GotyeMessage& message){
//        //        LOGD("downloading completed. start playing...");
//        if(message.type == GotyeMessageTypeAudio){
//            apiist->playMessage(message); ///< 下载完成马上播放
//        }
//    }
//    
//    
//    // 监听录音停止回调
//    virtual void onStopTalk(GotyeStatusCode code, bool realtime, GotyeMessage& message, bool *cancelSending){
//        
//        if(code == GotyeStatusCodeVoiceTooShort)
//        {
//            LuaBridge::pushLuaFunctionById(callback_);
//            LuaStack *stack = LuaBridge::getStack();
//            stack->pushString("tooshort");
//            stack->executeFunction(1);
//        }
//        if(code != GotyeStatusCodeOK){
//            return;
//        }
//        *cancelSending = YES;
//        if(sendCancel_ == 1){
//            sendCancel_ = 0;
//            return;
//        }
//
////        NSLog(@"%s",msgData.c_str());
////        NSLog(@"%zu",strlen(msgData.c_str()));
//        message.putExtraData(msgData.c_str(),strlen(msgData.c_str()));
//        apiist->sendMessage (message);
//    }
//    
//    //    virtual void onEnterRoom(GotyeStatusCode code, GotyeRoom& room) Optional;
//    virtual void onEnterRoom(GotyeStatusCode code, GotyeRoom& room){
//        if(code == GotyeStatusCodeOK)
//        {
//           NSLog(@"onEnterRoom 成功");
//        }
//        else
//        {
//            NSString *errorStr;
//            
//            if(code == GotyeStatusCodeRoomIsFull)
//                errorStr = @"房间已满";
//            else if(code == GotyeStatusCodeRoomNotExist)
//                errorStr = @"房间不存在";
//            else if(code == GotyeStatusCodeAlreadyInRoom)
//                errorStr = @"重复进入房间请求";
//            else
//                errorStr = [NSString stringWithFormat:@"未知错误(%d)", code];
//            
//        }
//        
//    }
//};
//
//+ (void)gotypeLogout
//{
//    apiist->logout();
//}
//yourClass *plistener;
//
//+ (void)init:(NSDictionary *)dict
//{
//    plistener = new yourClass();
//    apiist-> addListener(*plistener);
//    plistener->callback_ = [[dict objectForKey:@"callback"] intValue];
//    NSLog(@"%d",plistener->callback_);
//    
//}
//
//+ (void)gotypeLogin :(NSDictionary *)dict
//{
//    messageList.clear();
//    apiist->login([[dict objectForKey:@"name"] UTF8String], nullptr);///<对应回调GotyeDelegate::onLogin
//}
//
//+ (void)startTalk :(NSDictionary *)dict
//{
//    plistener->msgData =[[dict objectForKey:@"msgData"] UTF8String];
////    NSLog(@"%s",plistener->msgData.c_str());
////    NSLog(@"%s",[[dict objectForKey:@"index"] UTF8String]);
////    NSLog(@"--------------------------------------------------");
//    if(room == NULL){
//        for (GotyeRoom r:apiist->getLocalRoomList ()) {
//            
//            if (r.name == [[dict objectForKey:@"index"] UTF8String]) {
//                NSLog(@"%s","找到房间");
//                room = r;
//                break;
//            }
//        }
////        room = roomlist.at([[dict objectForKey:@"index"] intValue ]);
//    }
//    if(room == NULL){
//        LuaBridge::pushLuaFunctionById(plistener->callback_);
//        LuaStack *stack = LuaBridge::getStack();
//        stack->pushString("tooshort");
//        stack->executeFunction(1);
//
//    }else{
//        apiist-> startTalk(room, GotyeWhineModeDefault, NO,60000);
//    }
//    ///<realtime如果为true，则开始实时语音，聊天室所有用户会收到onRealPlayStart的回调
//}
//
//+ (void)stopTalk:(NSDictionary *)dict
//{
//    plistener->sendCancel_ = [[dict objectForKey:@"sendCancel_"] intValue ];
//    apiist-> stopTalk();
//}
//
//+ (void)playMessage :(NSDictionary *)dict
//{
//    string mid = [[dict objectForKey:@"msgid"] UTF8String];
////    char buf[512] = {0};
//    GotyeMessage message;
//    NSString *str;
//    NSData *jsonData;
//    NSDictionary *requestData;
////     NSLog(@"%s",mid.c_str());
//    for (GotyeMessage msg:messageList) {
//        char buf[512] = {0};
//        msg.getExtraData(buf);
//        str = [NSString stringWithUTF8String:buf];
////        NSRange range = [str rangeOfString:@"}"];
////        str = [str substringToIndex:range.location];
//        jsonData = [str dataUsingEncoding:NSUTF8StringEncoding];
//        requestData = [NSJSONSerialization JSONObjectWithData:jsonData
//                                        options:0
//                                          error:nil];
////        NSLog(@"%s",buf);
//        if ( [requestData[@"msgid"] UTF8String] == mid) {
//            message = msg;
//            break;
//        }
//    }
//    if (message==NULL) {
//        return;
//    }
////    apiist->getMessageList(room);
//    if(message.media.status!=GotyeMediaStatusDownloading && ![[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithUTF8String:message.media.path.c_str()] ])
//    {
//        apiist->downloadMediaInMessage(message); /// <对应回调GotyeDelegate::onDownloadMediaInMessage
//                return;
//    }
//    [MyGotye stopPlay];
////    GotyeMessage message = messageList.at([[dict objectForKey:@"index"] intValue ]);
//    apiist->playMessage (message); /// <对应回调GotyeDelegate::onPlayStart，onPlaying和onPlayStop
//    
//}
//
//+ (void)stopPlay
//{
//    apiist-> stopPlay();
//}
//
//+ (void)enterRoom :(NSDictionary *)dict
//{
//    messageList.clear();
//    for (GotyeRoom r:apiist->getLocalRoomList()) {
//        
////        NSLog(@"%s",r.name.c_str());
//        if (r.name == [[dict objectForKey:@"index"] UTF8String]) {
//            room = r;
//            NSLog(@"找到房间了enterRoom");
//            break;
//        }
//    }
//    if(room == NULL){
//    }else{
////        if(apiist->isInRoom (room)){
////            [MyGotye outRoom];
////        }
//        apiist->enterRoom (room);/// <对应回调GotyeDelegate::onEnterRoom
//    }
//}
//
//+ (void)outRoom
//{
//    messageList.clear();
//    if (room == NULL){
//    }else{
//        apiist->leaveRoom(room);
//    }
//    
//}
//
//+ (void)sellTickets
//{
//    for (size_t i =0; i < 11; i ++) {
//        apiist->reqRoomList(i);
//    }
//
//}
//
//+ (void)threadRequest
//{
//     NSThread *thread = [[NSThread alloc]initWithTarget:self selector:@selector(sellTickets) object:nil];
//     [thread start];
//}
//
//+ (int)getTalkingPower
//{
//   return apiist->getTalkingPower();
//}
//
//+ (void)setAutoDownload :(NSDictionary *)dict
//{
//    BOOL b = [[dict objectForKey:@"play"] intValue];
//    plistener->autoPlay = b;
//}
//
//
//@end
