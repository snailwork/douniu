
@interface MyGotye:NSObject

+ (void) gotypeLogout;
+ (void)gotypeLogin:(NSDictionary *)dict;
+ (void) startTalk:(NSDictionary *)dict ;
+ (void) stopTalk:(NSDictionary *)dict ;;
+ (void)playMessage:(NSDictionary *)dict;
+ (void)stopPlay:(NSDictionary *)dict;
+ (void)enterRoom:(NSDictionary *)dict;
+ (void)setAutoDownload :(NSDictionary *)dict;
+ (void)outRoom;
+ (void)init:(NSDictionary *)dict;
@end

