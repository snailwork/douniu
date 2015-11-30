//
//  TencectOpenController.m
//  texas_mobile_rc2
//
//  Created by admin on 14/10/30.
//
//

#import <UIKit/UIKit.h>

#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>

@interface MyQQApi : NSObject <TencentSessionDelegate , QQApiInterfaceDelegate> {
    
    TencentOAuth * _tencentOAuth;
    NSMutableArray * _permissions;
}

+(MyQQApi *) getInstance;

-(void) doQQLogin:(NSDictionary *)dict;


//- (void)onClickAddShare:(QQShareType)type;
//
//- (void)onClickAddShare:(QQShareType)type : (NSString*)image_path : (NSString*)des;

//+ (void)openStore;

@end

static MyQQApi * s_Instance = nullptr;
