//
//  WebViewBridge.m
//
//  Created
//
//

#include "cocos2d.h"
#include "CCLuaEngine.h"
#include "CCLuaBridge.h"
using namespace cocos2d;
#import "platform/ios/CCEAGLView-ios.h"
#import "WebViewBridge.h"
static WebViewBridge *s_sharedInstance = nil;

@implementation WebViewBridge

NSString *callbackStr=@"";
static int callbackId = -1;

+ (WebViewBridge *)sharedInstance
{
	if (!s_sharedInstance) {
		s_sharedInstance = [[WebViewBridge alloc] init];
	}
	return s_sharedInstance;
}

+ (void)open:(NSDictionary *)dict
{
	callbackId = [[dict objectForKey:@"callback"] intValue];
	WebViewBridge *instance = [WebViewBridge sharedInstance];
//    instance.userInteractionEnabled = YES;

	if (!instance.mWebView) {	// reload
        CGRect bounds = [[UIScreen mainScreen] bounds];
//        CGSize size = [[UIScreen mainScreen] bounds].size;
//        CGRect bounds = CGRectMake(0, 0, size.height,size.width);
        instance.mWebView = [[UIWebView alloc] initWithFrame:bounds];
        [(UIScrollView *)[[instance.mWebView subviews] objectAtIndex:0] setBounces : NO];	//UIWebView默认允许当网页内容处于最顶端时，用户用手指往下拖动，然后露出空白的背景。这份代码能够禁止这种效果
		instance.mWebView.delegate			= instance;
		instance.mWebView.scalesPageToFit	= YES;
        instance.mWebView.autoresizesSubviews = YES; //自动调整大小
        instance.mWebView.detectsPhoneNumbers = NO;
        
        instance.mWebView.userInteractionEnabled = YES;

//		[instance addSubview:instance.mWebView];
        
        cocos2d::GLView *glview1 = cocos2d::Director::getInstance()->getOpenGLView();
        CCEAGLView *eaglview1 = (CCEAGLView*) glview1->getEAGLView();
//        [eaglview1 addSubview:instance];
        
        [eaglview1 addSubview:instance.mWebView];
        
        UIButton *btnClose = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnClose setImage:[UIImage imageNamed:@"res/back.png"] forState:UIControlStateNormal];
        [btnClose setFrame:CGRectMake(bounds.size.width-34, 4, 32, 32)];
        btnClose.showsTouchWhenHighlighted = YES;
        instance.mBtnClose = btnClose;
        [btnClose addTarget:instance action:@selector(onCloseButtonPress:) forControlEvents:UIControlEventTouchUpInside];	// 定义点击时的响应函数
        [instance.mWebView addSubview:btnClose];
	}
    
    
    NSURL* url = [NSURL URLWithString:[dict objectForKey:@"url"]];//创建URL
//    NSURL* url = [NSURL URLWithString:@"https://www.baidu.com/"];//创建URL

    NSURLRequest* request = [NSURLRequest requestWithURL:url];//创建NSURLRequest
    [instance.mWebView loadRequest:request];


//	instance.mWebView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.25, 0.25);
//	[UIView beginAnimations:nil context:nil];
//	[UIView setAnimationDelay:0.08];
//	[UIView setAnimationDuration:0.2];
//	[UIView setAnimationDelegate:instance];
//
//	instance.mWebView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
//	[UIView commitAnimations];
}

- (void)onCloseButtonPress:(id)sender
{
    [WebViewBridge close];
}

+ (void)close
{
	WebViewBridge *instance = [WebViewBridge sharedInstance];
    [MBProgressHUD hideAllHUDsForView:instance animated:YES];

	if (!instance.mWebView) {
		return;
	}
    if(callbackId <= 0){ return;}
    
    LuaBridge::pushLuaFunctionById(callbackId);
    
    LuaStack *stack = LuaBridge::getStack();
    stack->pushString([callbackStr UTF8String] );
    stack->executeFunction(1);
    LuaBridge::releaseLuaFunctionById (callbackId);
	[instance.mWebView removeFromSuperview];
	[instance.mWebView release];
	instance.mWebView = nil;
    [instance.mBtnClose removeFromSuperview];
    instance.mBtnClose = nil;
	[instance removeFromSuperview];
    callbackId = -1;
}



- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [MBProgressHUD showHUDAddedTo:[WebViewBridge sharedInstance] animated:true];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [MBProgressHUD hideAllHUDsForView:[WebViewBridge sharedInstance] animated:YES];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [MBProgressHUD hideAllHUDsForView:[WebViewBridge sharedInstance] animated:YES];
    if (error.code!=kCFURLErrorCancelled) {
//        [WebViewBridge close];
    }

}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString	*url	= [[request URL] absoluteString];
   	NSString	*prefix = @"webviewbridge://";

    if ([url hasPrefix:prefix]) {
        
        
        // 如果是自己定义的协议, 再截取协议中的方法和参数, 判断无误后在这里手动调用oc方法
        NSLog(@"URL: %@  %@ ", url, [url substringFromIndex:prefix.length]);
        NSString *act = [url substringFromIndex:prefix.length];
//        callbackStr = [url substringFromIndex:prefix.length];
        
        NSRange range=[act rangeOfString:@"?"];
        NSString *params =@"";
        if(range.length>0){
            params =[act substringFromIndex:range.location+1];
            act =[act substringToIndex:range.location];
        }
         NSLog(@"%s",[act UTF8String]);
        //解析要访问的方法
        if([act isEqual:@"load"]){
            callbackStr = @"load";
            [WebViewBridge close];
        }else if ([act isEqual:@"close"]){
            [WebViewBridge close];
        }else if ([act isEqual:@"quickstart"]){
            callbackStr = act;
            [WebViewBridge close];
        }else{
            callbackStr = act;
//            NSString *backStr = [url substringFromIndex:prefix.length];
            //解析参数
            // NSMutableDictionary *dictType= [[WebViewBridge sharedInstance] parseURLParams:params];

        }
        return NO;
    }
    
    return YES;
}

- (NSMutableDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val = [[kv objectAtIndex:1]
                         stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [params setObject:val forKey:[kv objectAtIndex:0]];
    }
    return params;
}

@end
