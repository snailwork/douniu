//
//  Helper.m
//  Texas
//
//  Created
//
//
#import <AdSupport/ASIdentifierManager.h>
#import "Helper.h"
#import "SvUDIDTools.h"
#import <AudioToolbox/AudioSession.h>
#import "QQApi.h"
#import "Reachability.h"
#import <AVFoundation/AVFoundation.h>

#import "cocos2d.h"
#include "CCLuaEngine.h"
#include "CCLuaBridge.h"
using namespace cocos2d;

static id s_sharedInstance = nil;
@implementation Helper

+ (Helper *)sharedInstance
{
	if (!s_sharedInstance) {
		s_sharedInstance = [Helper alloc];
	}

	return s_sharedInstance;
}

+ (void)purgeSharedInstance
{
	[s_sharedInstance release];
}

+ (NSDictionary *)getAppInfo
{
	return [[NSBundle mainBundle] infoDictionary];
}

+ (NSString *)getAppID
{
	return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
}

+ (NSString *)getAppVersion
{
    NSLog(@"%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]);
	return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

+ (NSString *)getAppVersionCode
{
	return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}

+ (NSNumber *)currentTimeMillis
{
	NSNumber *currentTimeMillis = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970] * 1000];

	NSLog(@"currentTimeMillis = %@", currentTimeMillis);
	return currentTimeMillis;
}

+ (NSString *)NSHomeDirectory
{
	return NSHomeDirectory();
}

+ (NSString *)NSDocumentDirectory
{
	NSArray		*paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString	*documentsDirectory = [paths objectAtIndex:0];

	return documentsDirectory;
}

+ (BOOL)checkAppInstalled:(NSString *)urlSchemes
{
	if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:urlSchemes]]) {
		NSLog(@"%@ installed", urlSchemes);
		return YES;
	} else {
		return NO;
	}
}

//复制到剪切板
+ (void)copyToPasteboard:(NSDictionary *)dict
{
	NSString		*str		= [dict objectForKey:@"mString"];
	UIPasteboard	*pasteboard = [UIPasteboard generalPasteboard];

	[pasteboard setString:str];
	NSLog(@"Pasteboard value: %@", str);
}

+ (NSString *)getSystemVersion
{
    return [UIDevice currentDevice].systemVersion;
}

+ (NSString *)getOpenUDID
{
    return [SvUDIDTools UDID];
}

+ (int)registerForRemoteNotification
{
	NSLog(@"Registering for push notifications...");
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:
	(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
    return (int)[[UIApplication sharedApplication] enabledRemoteNotificationTypes];
}

+ (void) openURL:(NSDictionary *)dict
{
    NSString* url = [dict objectForKey:@"url"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

+ (BOOL) isPlaying
{
    UInt32 otherAudioIsPlaying;                                   // 1
    UInt32 propertySize = sizeof (otherAudioIsPlaying);
    
    AudioSessionGetProperty (                                     // 2
                             kAudioSessionProperty_OtherAudioIsPlaying,
                             &propertySize,
                             &otherAudioIsPlaying
                             );
    
//    if (otherAudioIsPlaying) {                                    // 3
//        NSLog(@"is playing")
//    } else {
//        NSLog(@"is not playing");
//    }
    return otherAudioIsPlaying > 0;
}

+ (void) QQLogin :(NSDictionary *)dict
{
    [[MyQQApi getInstance] doQQLogin : dict];
}

+ (int) checkWifi
{
    int result = 0;
    Reachability *r = [Reachability reachabilityWithHostName:@"www.baidu.com"];
//    switch ([r currentReachabilityStatus]) {
//            
//        caseNotReachable:// 没有网络连接
//            
//            result=0;
//            
//            break;
//            
//        caseReachableViaWWAN:// 使用3G网络
//            
//            result= 3;
//            
//            break;
//            
//        caseReachableViaWiFi:// 使用WiFi网络
//            
//            result=1;
//
//            break;
//            
//    }
    return [r currentReachabilityStatus];
}

+ (void) recordPermission :(NSDictionary *)dict
{
    int callback = [[dict objectForKey:@"callback"] intValue];
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
//        if(granted){
//            NSLog(@"允许使用麦克风");
//            
//        }else{
//            NSLog(@"不允许使用麦克风");
//            
//        }
        LuaBridge::pushLuaFunctionById(callback);
        LuaStack *stack = LuaBridge::getStack();
        stack->pushBoolean(granted);
        stack->executeFunction(1);
        LuaBridge::releaseLuaFunctionById (callback);
        
    }];
}


//+ (NSString *)getPhoto:(NSDictionary*) dict
//{
//    XJPhoto::getSingletonPtr()->getPhoto([[dict objectForKey:@"callback"] intValue]);
//}

@end
