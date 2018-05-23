//
//  MuticaseConnectionViewController.m
//  RACOCTest
//
//  Created by xlCoder on 2018/5/23.
//  Copyright © 2018年 Xianliang_Mr. All rights reserved.
//

#import "MuticaseConnectionViewController.h"
#import <ReactiveObjC.h>

@interface MuticaseConnectionViewController ()

@end

@implementation MuticaseConnectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(40, 150, 100, 60);
    btn.backgroundColor = [UIColor redColor];
    [btn setTitle:@"标题aa" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    [self test1];
    [self test2];
    // Do any additional setup after loading the view.
}

- (void)test1 {
    NSDictionary *dict = @{@"key1":@"name",@"key2":@"age"};
    [dict.rac_sequence.signal subscribeNext:^(id  _Nullable x) {
//        NSLog(@"******%@",x);
//        NSString *key = x[0];
//        NSString *value = x[1];
        RACTupleUnpack(NSString *key,NSString *value) = x;
        
//        RACTuplePack() = x;
        NSLog(@"%@-------&&&****---%@",key,value);
    } error:^(NSError *error) {
        NSLog(@"===error===");
    } completed:^{
        NSLog(@"ok---完毕");
    }];
}

- (void)test2 {
    RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@"RACMulticastConnection"];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"清空信息");
        }];
    }];
    //2. 创建连接类
    RACMulticastConnection *connection = [signal publish];
    [connection.signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"订阅消息者1");
    }];
    [connection.signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"订阅消息者2");
    }];
    [connection.signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"订阅消息者3");
    }];
    [connection connect];
}
- (void)btnClick {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
