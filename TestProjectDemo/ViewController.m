//
//  ViewController.m
//  TestProjectDemo
//
//  Created by like on 2017/8/28.
//  Copyright © 2017年 like. All rights reserved.
//  https://jingyan.baidu.com/article/154b4631728dd328cb8f4170.html

#import "ViewController.h"
 #define NS_FORMAT_FUNCTION(F,A) __attribute__((format(__NSString__, F, A)))

@interface ViewController ()<UIPrintInteractionControllerDelegate>

@end

@implementation ViewController

//指向block的指针,觉得不好理解可以用typeof
void blockCleanUp(void(^*block)()){
    (*block)();
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIButton *printButton = [UIButton buttonWithType:UIButtonTypeSystem];
    printButton.frame =CGRectMake(100,100,100,70);
    [printButton setTitle:@"打印" forState:UIControlStateNormal];
    printButton.titleLabel.font = [UIFont systemFontOfSize:32];
    [printButton addTarget:self  action:@selector(printAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:printButton];
    
    void (^block)(void) __attribute__((cleanup(blockCleanUp))) = ^{
        NSLog(@"finish block");
    };
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//    打印

-(void)printAction:(id)sender
{
    UIPrintInteractionController *printC = [UIPrintInteractionController sharedPrintController];//显示出打印的用户界面。
    printC.delegate = self;
    UIImage *img = [UIImage imageNamed:@"db.png"];
    NSData *data = [NSData dataWithData:UIImagePNGRepresentation(img)];
        if (printC && [UIPrintInteractionController canPrintData:data]) {
        
        UIPrintInfo *printInfo = [UIPrintInfo printInfo];//准备打印信息以预设值初始化的对象。
        printInfo.outputType = UIPrintInfoOutputGeneral;//设置输出类型。
        printC.showsPageRange = YES;//显示的页面范围
        //        printInfo.jobName = @"willingseal";
        //        printC.printInfo = printInfo;
        //        NSLog(@"printinfo-%@",printC.printInfo);
        printC.printingItem = data;//single NSData, NSURL, UIImage, ALAsset
        
        //        NSLog(@"printingitem-%@",printC);

        //    等待完成
        void (^completionHandler)(UIPrintInteractionController *, BOOL, NSError *) =
        ^(UIPrintInteractionController *printController, BOOL completed, NSError *error) {
            if (!completed && error) {
                NSLog(@"可能无法完成，因为印刷错误: %@", error);
            }
        };
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:sender];//调用方法的时候，要注意参数的类型－下面presentFromBarButtonItem:的参数类型是 UIBarButtonItem..如果你是在系统的UIToolbar or UINavigationItem上放的一个打印button，就不需要转换了。
            [printC presentFromBarButtonItem:item animated:YES completionHandler:completionHandler];//在ipad上弹出打印那个页面
        }else {
            [printC presentAnimated:YES completionHandler:completionHandler];//在iPhone上弹出打印那个页面
        }
    }
}
@end
