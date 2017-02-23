//
//  ViewController.m
//  LDIconPickerView
//
//  Created by lidi on 2017/2/23.
//  Copyright © 2017年 Li. All rights reserved.
//

#import "ViewController.h"
#import "LDIconPickerButton.h"
@interface ViewController ()
@property(nonatomic,strong)LDIconPickerButton *iconBtn;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.6 alpha:1];
    // Do any additional setup after loading the view.
    WS(weakSelf)
    self.iconBtn = [LDIconPickerButton iconWithFrame:CGRectMake(LD_SCREENWIDTH/2-50, 100, 100, 100) cornerRadius:50 image:@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1487588100446&di=415d5761ebba4da6e80a2557793bbf12&imgtype=0&src=http%3A%2F%2Fpic35.nipic.com%2F20131122%2F8821914_131225771000_2.jpg" placeholderImage:@"userIcon" completion:^(UIImage *icon) {
        [weakSelf.iconBtn setBackgroundImage:icon forState:0];
    }];
    [self.view addSubview:self.iconBtn];
    [self.iconBtn setBorderWidth:2 borderColor:[UIColor lightGrayColor]];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
