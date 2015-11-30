//
//  TencectOpenController.m
//  texas_mobile_rc2
//
//  Created by admin on 14/10/30.
//
//

#import "QQApi.h"

#include "cocos2d.h"
#include "CCLuaEngine.h"
#include "CCLuaBridge.h"



//#import "NSStringAdditions.h"

@implementation MyQQApi

static NSInteger s_callbackId;

- (void)viewDidLoad {

    NSString *appid;
#if APPID == 2001
         appid = @"1104889895";
        //    手Q AppId:1104889895   手Q Appkey:5qRY9Et0fv7m1psV
#else
         appid = @"1101746538";
#endif
    _permissions = [[NSMutableArray arrayWithObjects:
                     kOPEN_PERMISSION_GET_USER_INFO,
                     kOPEN_PERMISSION_GET_SIMPLE_USER_INFO,
                     kOPEN_PERMISSION_ADD_ALBUM,
                     kOPEN_PERMISSION_ADD_IDOL,
                     kOPEN_PERMISSION_ADD_ONE_BLOG,
                     kOPEN_PERMISSION_ADD_PIC_T,
                     kOPEN_PERMISSION_ADD_SHARE,
                     kOPEN_PERMISSION_ADD_TOPIC,
                     kOPEN_PERMISSION_CHECK_PAGE_FANS,
                     kOPEN_PERMISSION_DEL_IDOL,
                     kOPEN_PERMISSION_DEL_T,
                     kOPEN_PERMISSION_GET_FANSLIST,
                     kOPEN_PERMISSION_GET_IDOLLIST,
                     kOPEN_PERMISSION_GET_INFO,
                     kOPEN_PERMISSION_GET_OTHER_INFO,
                     kOPEN_PERMISSION_GET_REPOST_LIST,
                     kOPEN_PERMISSION_LIST_ALBUM,
                     kOPEN_PERMISSION_UPLOAD_PIC,
                     kOPEN_PERMISSION_GET_VIP_INFO,
                     kOPEN_PERMISSION_GET_VIP_RICH_INFO,
                     kOPEN_PERMISSION_GET_INTIMATE_FRIENDS_WEIBO,
                     kOPEN_PERMISSION_MATCH_NICK_TIPS_WEIBO,
                     nil] retain];
    
    _tencentOAuth = [[TencentOAuth alloc] initWithAppId:appid andDelegate:self];


}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [TencentOAuth HandleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
    
    return [TencentOAuth HandleOpenURL:url];
}


-(void) doQQLogin :(NSDictionary *)dict
{
    [_tencentOAuth authorize:_permissions inSafari:NO];
    
    s_callbackId = [[dict objectForKey:@"callback"] intValue];
}


+(MyQQApi*) getInstance
{
    if (s_Instance == nullptr) {
        s_Instance = [MyQQApi alloc];
        [s_Instance viewDidLoad];
    }
    
    return s_Instance;
}

- (void)tencentDidLogin
{
    // 登录成功
    if (_tencentOAuth.accessToken
       && 0 != [_tencentOAuth.accessToken length])
    {
        //NSString* text = _tencentOAuth.accessToken;
        BOOL b = [_tencentOAuth getUserInfo];
        
        if (b == NO) {
            
        }
    }
    else
    {
        //_labelAccessToken.text = @"登录不成功 没有获取accesstoken";
    }
}

/**
 * Called when the user dismissed the dialog without logging in.
 */
- (void)tencentDidNotLogin:(BOOL)cancelled
{
    if (cancelled){
        //_labelTitle.text = @"用户取消登录";
    }
    else {
        //_labelTitle.text = @"登录失败";
    }
    
}

-(void)tencentDidNotNetWork
{
    
   // _labelTitle.text=@"无网络连接，请设置网络";
}

-(void)tencentDidLogout
{

}

- (void) getUserInfoResponse:(APIResponse *)response {
    if (response.retCode == URLREQUEST_SUCCEED) {
        // 获取信息成功
        NSError* pError;

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"登录成功" message:[NSString stringWithFormat:@"good job"]
                              
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        
        //Data转换为JSON
//        NSString* str = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        //SnsAdapter::ObjectQQLoginComplete([str UTF8String] , [_tencentOAuth.openId UTF8String]);
        
        cocos2d::LuaValueDict dict;
        dict["nickname"] = cocos2d::LuaValue::stringValue([[response.jsonResponse objectForKey:@"nickname"] UTF8String]);
        dict["figureurl_qq_2"] = cocos2d::LuaValue::stringValue([[response.jsonResponse objectForKey:@"figureurl_qq_2"] UTF8String]);
        dict["openId"] = cocos2d::LuaValue::stringValue([_tencentOAuth.openId UTF8String]);
        cocos2d::LuaBridge::pushLuaFunctionById (s_callbackId);
        cocos2d::LuaStack *stack = cocos2d::LuaBridge::getStack ();
//        stack->pushString([str UTF8String]);
//        stack->pushString([_tencentOAuth.openId UTF8String]);
        
        stack->pushLuaValueDict(dict);
        stack->executeFunction (1);
        
        cocos2d::LuaBridge::releaseLuaFunctionById (s_callbackId);
        
    }
    else
    {
        // 获取信息失败
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"登录失败" message:[NSString stringWithFormat:@"请检查网络"]
                              
                                                       delegate:self cancelButtonTitle:@"我知道啦" otherButtonTitles: nil];
        [alert show];
        [alert release];
        
        
    }
}

- (void)onClickLogout
{
    //_labelTitle.text = @"退出登录";
    [_tencentOAuth logout:self];
}

- (void)tencentFailedUpdate:(UpdateFailType)reason
{
    if (reason == kUpdateFailNetwork)
    {
        //_labelTitle.text=@"增量授权失败，无网络连接，请设置网络";
    }
}

- (void)tencentDidUpdate:(TencentOAuth *)tencentOAuth
{
}
//
//- (void)onClickAddShare:(QQShareType)type
//{
//    //分享跳转URL
//    NSString *url = @"http://www.qqsgame.com";
//    //分享图预览图URL地址
//    //NSString *previewImageUrl = @"http://cdn2.image.apk.gfan.com/asdf/PImages/2014/10/14/ldpi_816420_2d804fba1-cb97-4ccb-9e50-157fc8a2eb44.png";
//    
//    NSString *previewImageUrl = @"http://b.hiphotos.baidu.com/image/pic/item/b8389b504fc2d562c4e5a7a1e41190ef77c66c88.jpg";
//    QQApiNewsObject *newsObj = [QQApiNewsObject
//                                objectWithURL:[NSURL URLWithString:url ? : @""]
//                                title: @"牵手德州扑克"
//                                description:@"最专业的德州扑克，超级大场，海量金币，高手齐聚，赶快来PK吧！"
//                                previewImageURL:[NSURL URLWithString:previewImageUrl]];
//    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:newsObj];
//    //将内容分享到qq
//    QQApiSendResultCode sent;
//    if (type == kShareMsgToQQ) {
//        
//        sent = [QQApiInterface sendReq:req];
//        
//    }
//    else if (type == kShareMsgToQQQZone){
//        
//        sent = [QQApiInterface SendReqToQZone:req];
//
//    }
//        
//    if (sent == false) {
//        
//        // 分享失败
//    }
//}
//
//
//- (void)onClickAddShare:(QQShareType)type : (NSString*)image_path : (NSString*)des
//{
//    //分享跳转URL
//    NSString *url = @"http://a.app.qq.com/o/simple.jsp?pkgname=com.qqsgame.texas_mobile";
//    //分享图预览图URL地址
//    NSString *previewImageUrl = image_path;
//    QQApiNewsObject *newsObj = [QQApiNewsObject
//                                objectWithURL:[NSURL URLWithString:url ? : @""]
//                                title: @"牵手德州扑克"
//                                description:des
//                                previewImageURL:[NSURL URLWithString:previewImageUrl]];
//    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:newsObj];
//    //将内容分享到qq
//    QQApiSendResultCode sent;
//    if (type == kShareMsgToQQ) {
//        
//        sent = [QQApiInterface sendReq:req];
//        
//    }
//    else if (type == kShareMsgToQQQZone){
//        
//        sent = [QQApiInterface SendReqToQZone:req];
//        
//    }
//    
//    if (sent == EQQAPISENDSUCESS) {
//        
//        // 分享失败
//    }
//}

+ (void)onResp:(QQBaseResp *)resp
{
    NSLog(@"%@",resp.result);
    switch (resp.type)
    {
        case ESENDMESSAGETOQQRESPTYPE:
        {
            //SendMessageToQQResp* sendResp = (SendMessageToQQResp*)resp;
            //UIAlertView* alert = [[UIAlertView alloc] initWithTitle:sendResp.result message:sendResp.errorDescription delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            //[alert show];
            break;
        }
        default:
        {
            break;
        }
    }
}

//+ (void)openStore   // 跳转到AppStore
//{
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://a.app.qq.com/o/simple.jsp?pkgname=com.qqsgame.texas_mobile"]];
//}

- (void)dealloc {
    [_permissions release];
    [_tencentOAuth release];

    [super dealloc];
}
@end




