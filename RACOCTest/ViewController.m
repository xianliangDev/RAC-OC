//
//  ViewController.m
//  RACOCTest
//
//  Created by xlCoder on 2018/5/22.
//  Copyright © 2018年 Xianliang_Mr. All rights reserved.
//

#import "ViewController.h"
#import <ReactiveObjC/RACSignal.h>
#import <ReactiveObjC/RACSubscriber.h>

#import <UITextField+RACSignalSupport.h>
#import <UIControl+RACSignalSupport.h>
#import <NSNotificationCenter+RACSupport.h>

#import <ReactiveObjC/RACEXTScope.h>

#import "SecViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /**一、常用类 初始化*/
    //创建信号源
    RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        NSLog(@"hello world");
        //发送信号
        [subscriber sendNext:@"this is RAC signal"];
        return nil;
    }];
    //订阅信号
    [signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@-----",x);
    }];
    
    /**二、一行代码搞定监听*/
    // 1. TargetAction转Block
    //实时监听输入的内容
    [[self.userNametf rac_textSignal] subscribeNext:^(NSString * _Nullable x) {
        NSLog(@"%@>>>>>>>>",x);
    }];
    //button 的点击事件
    [[self.loginBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
//        NSLog(@"button****%@",x);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"notificationObserver" object:@"hell"];
    }];
    //通知转block
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:@"notificationObserver" object:nil] subscribeNext:^(NSNotification * _Nullable x) {
//        NSLog(@"NSNotificationCenter=========%@",x);
        SecViewController *secVc = [[SecViewController alloc] init];
        [self presentViewController:secVc animated:YES completion:nil];
    }];
    
    /**三、注意事项 rac用 @weakify(self) 和 @strongify(self) 来定义弱引用与强引用*/
    @weakify(self);
    [[self.userNametf rac_textSignal] subscribeNext:^(NSString * _Nullable x) {
        NSLog(@"%@>>>>>>>>",x);
        @strongify(self);
        self.userNametf.text = @"strong ";
    }];
    
    
    // Do any additional setup after loading the view, typically from a nib.
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
