//
//  WChat.m
//  Texas
//
//  Created
//
//

#import "WXApiObject.h"
#import "WXApi.h"
#import "Wchat.h"

@implementation Wchat : NSObject

+ (void) login :(NSDictionary *)dict
{

    [[[UIApplication sharedApplication] delegate] sendAuthRequest:dict];
}


+ (void) pay :(NSDictionary *)dict
{
    
    [[[UIApplication sharedApplication] delegate] pay:dict];
}


+ (int) installWchat
{
    if([WXApi isWXAppInstalled] == NO){
        return 0;
    }
    return 1;
}


@end
