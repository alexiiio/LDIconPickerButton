# LDIconPickerButton
一个自定义的头像按钮，集成了更换头像和查看大图的功能。支持从相册和相机选择照片，对大图进行缩放等。
## Usage
```
#import "LDIconPickerButton.h"
```
```
  self.iconBtn = [LDIconPickerButton iconWithFrame:icon的frame cornerRadius:50 image:图片url 
    placeholderImage:占位图名称 completion:^(UIImage *icon) {
//  your code      icon为通过相册或相机选择的照片
  }];
  [self.view addSubview:self.iconBtn];
    // 设置边框属性
  [self.iconBtn setBorderWidth:2 borderColor:[UIColor lightGrayColor]];
    
```

## 效果
    
    
