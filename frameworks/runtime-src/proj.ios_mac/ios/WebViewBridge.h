//
//  WebViewBridge.h
//
//


#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"
@interface WebViewBridge:UIView <UIWebViewDelegate,UIAlertViewDelegate> {
    UIWebView *mWebView;
    UIButton* *m_BtnClose;
}

@property(nonatomic,retain) UIWebView *mWebView;
@property(nonatomic,retain) UIButton *mBtnClose;

+ (WebViewBridge *) sharedInstance;

+ (void) open:(NSDictionary *) dict;
+ (void) close;

- (NSMutableDictionary*)parseURLParams:(NSString *)query;
@end
