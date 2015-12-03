//
//  Helper.h
//  Texas
//
//  Created by 
//
//



@interface Helper: NSObject 
+ (Helper *)sharedInstance;
+ (void)purgeSharedInstance;
// + (void) registerScriptHandler:(NSDictionary *)dict;
// + (void) unregisterScriptHandler;


+ (int)registerForRemoteNotification;


+ (NSString *) getIDFA;
+ (NSString *)getOpenUDID;
+ (void) openURL:(NSDictionary *)dict;
+ (NSString *)getSystemVersion;
+ (void) QQLogin:(NSDictionary *)dict ;
+ (int) checkWifi;
+ (void) recordPermission :(NSDictionary *)dict;

@end

