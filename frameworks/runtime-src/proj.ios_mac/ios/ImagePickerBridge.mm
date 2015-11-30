//
//  ImagePickerBridge.mm

//  Created 
//
//
#include "cocos2d.h"
#include "CCLuaEngine.h"
#include "CCLuaBridge.h"
#import "platform/ios/CCEAGLView-ios.h"

using namespace cocos2d;

#import <UIKit/UIKit.h>


@interface ImagePickerBridge : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate>
@end

@implementation ImagePickerBridge


static NSInteger s_callbackId = -1;



+ (void)showPicker:(NSDictionary*) dict
{
    s_callbackId = [[dict objectForKey:@"callback"] intValue];
    ImagePickerBridge* instance = [[ImagePickerBridge alloc] initWithNibName:nil bundle:nil];
    cocos2d::GLView *glview1 = cocos2d::Director::getInstance()->getOpenGLView();
    CCEAGLView *eaglview1 = (CCEAGLView*) glview1->getEAGLView();
    [eaglview1 addSubview:instance.view];
    

    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:instance
                                                    cancelButtonTitle:@"取消"
                                                    destructiveButtonTitle:nil
//                                                    otherButtonTitles: @"从相册中选取",@"拍照",nil];
                                                    otherButtonTitles: @"从相册中选取",nil];
    
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showInView: instance.view];
    [actionSheet release];
    
}


- (void)showNormalPicker:(UIImagePickerControllerSourceType) sourceType {
    
    if (![UIImagePickerController isSourceTypeAvailable: sourceType] ){

        LuaBridge::releaseLuaFunctionById (s_callbackId);
        s_callbackId = -1;
        if (sourceType == UIImagePickerControllerSourceTypeCamera) {
            [[[UIAlertView alloc] initWithTitle:@"选取失败"
                                        message: @"摄像头当前不可用"
                                       delegate:self
                              cancelButtonTitle:@"关闭"
                              otherButtonTitles:nil] show];
        }else if(sourceType == UIImagePickerControllerSourceTypePhotoLibrary){
            [[[UIAlertView alloc] initWithTitle:@"选取失败"
                                        message:@"您是否限制了相册的读取?"
                                       delegate:self
                              cancelButtonTitle:@"关闭"
                              otherButtonTitles:nil] show];
        }
        
        return;
    }
    
     UIImagePickerController *ctr  = [[UIImagePickerController alloc] init];
     ctr.sourceType = sourceType;
     ctr.delegate = self;
     ctr.allowsEditing = YES;

//    ctr.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
//    ctr.cameraViewTransform     = CGAffineTransformMakeRotation(-M_PI / 2);
//    ctr.cameraViewTransform = CGAffineTransformMakeScale(0.5, 0.5);

     ctr.modalPresentationStyle=UIModalPresentationOverCurrentContext;

//    [self presentViewController:ctr animated:YES completion:nil];
     [self.view.window.rootViewController presentViewController:ctr animated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self _didFinishPicking:picker];
}


//上传和返回texture
//返回保存的路径
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo{
    NSString* filename = [NSString stringWithFormat:@"%d.jpg",(int)[[NSDate date] timeIntervalSince1970]] ;
    
    NSString* filePath = [self saveImageToCaches:image name:filename];
    LuaBridge::pushLuaFunctionById (s_callbackId);
    LuaStack *stack = LuaBridge::getStack ();
    stack->pushString([filePath UTF8String]);
    stack->executeFunction (1);
    LuaBridge::releaseLuaFunctionById (s_callbackId);
    
    s_callbackId = -1;
    
    [self _didFinishPicking:picker];
}



- (NSString *)saveImageToCaches:(UIImage*)image name:(NSString*)name
{
    NSData *imageData = UIImageJPEGRepresentation(image,0.3);
    // NSData *imageData = UIImageJPEGRepresentation(image,0.7);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
    NSString *filePath = [documentsPath stringByAppendingPathComponent:name]; //Add the file name
    [imageData writeToFile:filePath atomically:YES]; //Write the file
    
    return filePath;
}



- (void) _didFinishPicking:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    if(!s_callbackId){
        return;
    }
    
//    LuaValueDict item;
//    item["success"] = LuaValue::booleanValue(false);
//    LuaBridge::pushLuaFunctionById (s_callbackId);
//    LuaStack *stack = LuaBridge::getStack ();
//    stack->pushLuaValueDict (item);
//    stack->executeFunction (1);
    LuaBridge::releaseLuaFunctionById (s_callbackId);
    s_callbackId = -1;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIImagePickerControllerSourceType sourceType ;
    switch (buttonIndex)
    {
        case 0:
//            sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            break;
//        case 1:
//            sourceType = UIImagePickerControllerSourceTypeCamera;
//            break;
//        case 2:
//            break;
        default:
            return;
    }
    

    [self showNormalPicker:sourceType];
}

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//    
//    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight );
//    
//}
//
//-(NSUInteger)supportedInterfaceOrientations{
//    return UIInterfaceOrientationMaskLandscape;
//}
//
//- (BOOL)shouldAutorotate
//{
//    return YES;
//}

@end
