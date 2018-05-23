//
//  SecViewController.m
//  RACOCTest
//
//  Created by xlCoder on 2018/5/23.
//  Copyright © 2018年 Xianliang_Mr. All rights reserved.
//

#import "SecViewController.h"

#import <ReactiveObjC/RACSubscriber.h>
#import <ReactiveObjC/RACSignal.h>
#import <ReactiveObjC/RACDisposable.h>

#import <ReactiveObjC.h>
#import <RACReturnSignal.h>
#import "MuticaseConnectionViewController.h"

@interface SecViewController ()

@property (nonatomic, strong)id<RACSubscriber> subscriber;

@end

@implementation SecViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(40, 150, 100, 60);
    btn.backgroundColor = [UIColor redColor];
    [btn setTitle:@"标题" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    //创建信号
  RACSignal *signal =  [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
      NSLog(@"secondcontroller");
      [subscriber sendNext:@"你好"];
      //这个地方是强引用 消息订阅不会主动取消 ，需要手动取消
      _subscriber = subscriber;
      //取消消息的订阅 ：消息发送完毕或者是发送失败
      return [RACDisposable disposableWithBlock:^{
          //清空消息订阅
          NSLog(@"到这里了");
      }];
    }];
    
    RACDisposable *disposable = [signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"---------%@",x);
    }];
    //消息取消订阅
    [disposable dispose];//手动取消消息订阅
    
    
    [self test1];
    
    
    //映射测试
    [self maptest1];
    [self maptest2];
    [self flatMap];
    
    //过滤
    [self takeUtil];
    
    //组合
    [self then];
    // Do any additional setup after loading the view.
}

- (void)btnClick {
    MuticaseConnectionViewController *aa = [[MuticaseConnectionViewController alloc] init];
    [self presentViewController:aa animated:YES completion:nil];
}

- (void)test1 {
    //bind 测试
    // 1、创建信号
    RACSubject *subject = [RACSubject subject];
    // 2、绑定信号
    RACSignal *bindSignal = [subject bind:^RACSignalBindBlock _Nonnull{
        return ^RACSignal *(id value,BOOL *stop){
            value= @3;
            NSLog(@"接收到的信号源内容--%@",value);
            //返回信号，不能为nil,如果非要返回空---则empty或 alloc init。
            return [RACReturnSignal return:value];//包装成信号
        };
    }];
    
    // 3、 订阅绑定信号
    [bindSignal subscribeNext:^(id  _Nullable x) {
        NSLog(@"接收到绑定信号处理 ---%@",x);
    }];
    
    // 4、发送信号
//    [subject sendNext:@"123"];
}

/***---------------------映射测试-------------------------***/
- (void)maptest1{
    RACSubject *subject = [RACSubject subject];
    RACSignal *bindSignal = [subject map:^id _Nullable(id  _Nullable value) {
        return [NSString stringWithFormat:@"ws:%@",value];
    }];
    [bindSignal subscribeNext:^(id  _Nullable x) {
        NSLog(@"......%@",x);
    }];
    [subject sendNext:@"this test"];
}

//信号中的信号
- (void)maptest2 {
    RACSubject *subjetofsignal = [RACSubject subject];
    RACSubject *subject = [RACSubject subject];
    [[subjetofsignal flattenMap:^__kindof RACSignal * _Nullable(id  _Nullable value) {
        return value;
    }] subscribeNext:^(id  _Nullable x) {
        NSLog(@"-----%@",x);
    }];
    [subjetofsignal sendNext:subject];
    [subject sendNext:@"123"];
}

- (void)flatMap {
    // 创建信号
    RACSubject *subject = [RACSubject subject];
    // 绑定信号
    RACSignal *bindSignal = [subject flattenMap:^RACSignal *(id value) {
        // block：只要源信号发送内容就会调用
        // value: 就是源信号发送的内容
        // 返回信号用来包装成修改内容的值
        return [RACReturnSignal return:value];
        
    }];
    
    // flattenMap中返回的是什么信号，订阅的就是什么信号(那么，x的值等于value的值，如果我们操纵value的值那么x也会随之而变)
    // 订阅信号
    [bindSignal subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    
    // 发送数据
    [subject sendNext:@"123"];
    
}

/**-----------------过滤--------------------------*/
- (void)takeUtil{
    RACSubject *subject1 = [RACSubject subject];
    RACSubject *subject2 = [RACSubject subject];
    [[subject1 takeUntil:subject2] subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@*****",x);
    }];
    [subject1 sendNext:@"1"];
    [subject1 sendNext:@"2"];
    [subject2 sendNext:@"3"];
    [subject2 sendNext:@"4"];
}

/**---------组合-------*/
// then --- 使用需求：有两部分数据：想让上部分先进行网络请求但是过滤掉数据，然后进行下部分的，拿到下部分数据
- (void)then {
    // 创建信号A
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        // 发送请求
        NSLog(@"----发送上部分请求---afn");
        
        [subscriber sendNext:@"上部分数据"];
        [subscriber sendCompleted]; // 必须要调用sendCompleted方法！
        return nil;
    }];
    
    // 创建信号B，
    RACSignal *signalsB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        // 发送请求
        NSLog(@"--发送下部分请求--afn");
        [subscriber sendNext:@"下部分数据"];
        return nil;
    }];
    // 创建组合信号
    // then;忽略掉第一个信号的所有值
    RACSignal *thenSignal = [signalA then:^RACSignal *{
        // 返回的信号就是要组合的信号
        return signalsB;
    }];
    
    // 订阅信号
    [thenSignal subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    
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
