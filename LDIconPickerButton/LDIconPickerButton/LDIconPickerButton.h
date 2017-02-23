//
//  LDIconPickerBtn.h
//  pukka-ios
//
//  Created by lidi on 2017/2/21.
//  Copyright © 2017年 Pukka Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#define WS(weakSelf) __weak __typeof(&*self)weakSelf = self;
#define LD_SCREENWIDTH [[UIScreen mainScreen]bounds].size.width      //屏宽
#define LD_SCREENHEIGHT [[UIScreen mainScreen]bounds].size.height   //  屏高
typedef void(^IconBlock)(UIImage *icon);
@interface LDIconPickerButton : UIButton
/**
 *
 *  初始化方法
 *  @param frame 指定坐标、大小。也可以使用自动布局，但需先指定size。
 *  @param cornerRadius 圆角弧度
 *  @param image 图片的URL
 *  @param placeholderImage 占位图名称（非url）
 *  @param finishBlock 回调block，选择图片之后，把图片传出去。然后在block里做图片上传服务器、更换头像等操作
 */
+(instancetype)iconWithFrame:(CGRect)frame cornerRadius:(CGFloat)cornerRadius image:(NSString *)image placeholderImage:(NSString *)placeholderImage completion:(IconBlock)finishBlock;
-(void)setBorderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor;
@end
