//
//  LDIconPickerBtn.m
//  pukka-ios
//
//  Created by lidi on 2017/2/21.
//  Copyright © 2017年 Pukka Inc. All rights reserved.
//

#import "LDIconPickerButton.h"
#import "UIButton+WebCache.h"
@interface LDIconPickerButton ()<UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIScrollViewDelegate>
@property(nonatomic,strong)NSString *imageUrl;
@property(nonatomic,strong)NSString *placeholderImage;
@property(nonatomic,copy)IconBlock block;
@end
static NSString *icon_UD = @"LDUserIcon_UD";
static int backLayerTag = 7483;
static int imvTag = 7482;

@implementation LDIconPickerButton

+(instancetype)iconWithFrame:(CGRect)frame cornerRadius:(CGFloat)cornerRadius image:(NSString *)image placeholderImage:(NSString *)placeholderImage completion:(IconBlock)finishBlock{
    LDIconPickerButton *button = [LDIconPickerButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    [button.layer setMasksToBounds:YES];
    if (cornerRadius>frame.size.height) {
        [button.layer setCornerRadius:frame.size.height*0.5];
    } else {
        [button.layer setCornerRadius:cornerRadius];
    }
    [button addTarget:nil action:@selector(showActionSheet) forControlEvents:UIControlEventTouchUpInside];
    // 获取到图片后保存到本地，下次先加载本地头像，同时也会从网络加载以免头像更新
    NSData *localImageData = [[NSUserDefaults standardUserDefaults]objectForKey:icon_UD];
    if (localImageData) {
        [button setBackgroundImage:[UIImage imageWithData:localImageData] forState:0];
    }
    button.imageUrl = image;
    button.placeholderImage = placeholderImage;
    [button getInternetIcon];
    
    button.block = finishBlock;
    
    return button;
}
-(void)getInternetIcon{
    [self sd_setBackgroundImageWithURL:[NSURL URLWithString:self.imageUrl] forState:0 placeholderImage:[UIImage imageNamed:self.placeholderImage] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        NSData *dataImage = UIImagePNGRepresentation(image);
        [[NSUserDefaults standardUserDefaults] setObject:dataImage forKey:icon_UD];
    }];
}
// 设置边框
-(void)setBorderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor{
    [self.layer setBorderWidth:borderWidth];
    [self.layer setBorderColor:borderColor.CGColor];
}
// 弹出选择框
-(void)showActionSheet{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    //从相册选择
    [alert addAction:[UIAlertAction actionWithTitle:@"从相册选择照片" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //初始化UIImagePickerController
        UIImagePickerController *PickerImage = [[UIImagePickerController alloc]init];
        PickerImage.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        //允许编辑，即放大裁剪
        PickerImage.allowsEditing = YES;
        //自代理
        PickerImage.delegate = self;
        //页面跳转
        
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:PickerImage animated:YES completion:nil];
    }]];
    //拍照
    [alert addAction:[UIAlertAction actionWithTitle:@"照相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
        UIImagePickerController *PickerImage = [[UIImagePickerController alloc]init];
        PickerImage.sourceType = UIImagePickerControllerSourceTypeCamera;
        PickerImage.allowsEditing = YES;
        PickerImage.delegate = self;
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:PickerImage animated:YES completion:nil];
    }]];
    /**
     查看大图 未设置头像时不显示
    */
    NSData *localImageData = [[NSUserDefaults standardUserDefaults]objectForKey:icon_UD];
    WS(weakSelf)
    if (localImageData) {
        [alert addAction:[UIAlertAction actionWithTitle:@"查看大图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            // 添加背景，以scrollView为背景，缩放操作会简化
            UIScrollView *backlayer = [[UIScrollView alloc]initWithFrame:[UIScreen mainScreen].bounds];
            backlayer.delegate = self;
            backlayer.maximumZoomScale = 4.0;
            backlayer.minimumZoomScale = 0.5;
            backlayer.alwaysBounceHorizontal = YES; // 水平方向始终可以滑动
            UIWindow *keyWin = [UIApplication sharedApplication].keyWindow;
            [keyWin addSubview:backlayer];
            UIImageView *imv = [[UIImageView alloc]initWithFrame:CGRectMake(weakSelf.frame.origin.x, weakSelf.frame.origin.y, weakSelf.frame.size.width, weakSelf.frame.size.height)];   // 有导航栏的时候 y坐标+64
            imv.image = [UIImage imageWithData:localImageData];
            [backlayer addSubview:imv];
            // 设置tag，方便调用
            imv.tag = imvTag;
            backlayer.tag = backLayerTag;
            // 添加单双击手势
            UITapGestureRecognizer *singleTapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap)];
            [singleTapGR setNumberOfTapsRequired:1];
            [backlayer addGestureRecognizer:singleTapGR];
            UITapGestureRecognizer *doubleTapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
            [doubleTapGR setNumberOfTapsRequired:2];
            [backlayer addGestureRecognizer:doubleTapGR];
             // 只有检测到双击手势失败时，单击手势才有效
            [singleTapGR requireGestureRecognizerToFail:doubleTapGR];
            
            // 执行动画
            [UIView animateWithDuration:0.25 animations:^{
                backlayer.backgroundColor = [UIColor blackColor];
                imv.frame = CGRectMake(0, LD_SCREENHEIGHT*0.5-LD_SCREENWIDTH*0.5, LD_SCREENWIDTH, LD_SCREENWIDTH);
            } completion:^(BOOL finished) {
                [UIApplication sharedApplication].statusBarHidden = YES;
            }];
        }]];
    }
    //取消按钮，类型：UIAlertActionStyleCancel
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
   
}
// ******************  UIImageView的缩放处理 ******************************
-(void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale{
    if (scale < 1.0) {
        [scrollView setZoomScale:1.0 animated:YES];
    }
}
-(void)scrollViewDidZoom:(UIScrollView *)scrollView{
    UIView *imv = [scrollView viewWithTag:imvTag];
    imv.center = [self centerOfScrollViewContent:scrollView];
}
// 缩放时跳转imv的位置
- (CGPoint)centerOfScrollViewContent:(UIScrollView *)scrollView
{
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    CGPoint actualCenter = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                       scrollView.contentSize.height * 0.5 + offsetY);
    return actualCenter;
}
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    UIView *imv = [scrollView viewWithTag:imvTag];
    return imv;
}
#pragma mark 双击
-(void)doubleTap:(UITapGestureRecognizer *)recognizer{
    UIScrollView *scrollV = [[UIApplication sharedApplication].keyWindow viewWithTag:backLayerTag];
    CGPoint touchPoint = [recognizer locationInView:scrollV];
    if (scrollV.zoomScale <= 1.0) {
        
        CGFloat scaleX = touchPoint.x + scrollV.contentOffset.x;//需要放大的图片的X点
        CGFloat sacleY = touchPoint.y + scrollV.contentOffset.y;//需要放大的图片的Y点
        [scrollV zoomToRect:CGRectMake(scaleX, sacleY, 10, 10) animated:YES];
    } else {
        [scrollV setZoomScale:1.0 animated:YES]; //还原
    }
}
// ******************  UIImageView的缩放处理 ******************************

#pragma mark 单击
// 点击大图消失，恢复原样
-(void)singleTap{
    UIWindow *keyWin = [UIApplication sharedApplication].keyWindow;
     __block UIScrollView *backLayer = [keyWin viewWithTag:backLayerTag];
     UIImageView *imv = [backLayer viewWithTag:imvTag];
    // 如果图片放大了，先恢复初始大小，否则动画会乱掉
    if (backLayer.zoomScale > 1.0) {
        [backLayer setZoomScale:1.0];
    }
    
    WS(weakSelf)
    [UIView animateWithDuration:0.25 animations:^{
        backLayer.backgroundColor = [UIColor clearColor];
        imv.frame = CGRectMake(weakSelf.frame.origin.x, weakSelf.frame.origin.y, weakSelf.frame.size.width, weakSelf.frame.size.height);  // 有导航栏的时候 y坐标+64
    } completion:^(BOOL finished) {
        [backLayer removeFromSuperview];
        backLayer = nil;
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{

    UIImage *icon = [info objectForKey:@"UIImagePickerControllerEditedImage"];
//    UIImage *icon = [self scaleFromImage:EditedImage toSize:CGSizeMake(400, 400)];  // 缩小尺寸，视实际需求而定
//    [self setBackgroundImage:icon forState:0];
    if (self.block) {  // 回调icon
        self.block(icon);
    }
    NSData *dataImage = UIImagePNGRepresentation(icon);
    [[NSUserDefaults standardUserDefaults] setObject:dataImage forKey:icon_UD];
    [[UIApplication sharedApplication].keyWindow.rootViewController dismissViewControllerAnimated:YES completion:nil];
}


#pragma extension
// 改变图像的尺寸，方便上传服务器
- (UIImage *) scaleFromImage: (UIImage *) image toSize: (CGSize) size
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
@end
