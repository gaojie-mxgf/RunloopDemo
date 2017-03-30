//
//  ViewController.m
//  RunTimeDemo
//
//  Created by 高洁 on 2017/3/27.
//  Copyright © 2017年 高洁. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UITableViewDelegate,UITableViewDataSource>



@property (strong, nonatomic) IBOutlet UITableView *talbeview;

@property (strong,nonnull) NSTimer *timer;
//定义一个block
typedef void(^RunloopBack)(void);

@property (nonatomic, strong)NSMutableArray *tasks;
//最大任务书
@property (nonatomic, assign) NSUInteger maxQueueLength;

// 卡顿的原因是因为runloop依次循环，渲染很多图片

//处理步骤
/*
 
 分布加载，让一次runloop循环就渲染一张图片
    1监听runloop循环
        CFRunLoopRef  __CFRunLoopObserver
 
    2将耗时操作放在一个数组中，不去执行
    3一次runloop循环，从数组中拿出一个任务
 
 */

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    //创建一个时钟
//    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeMethod) userInfo:nil repeats:YES];
//    NSTimer *timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(timeMethod) userInfo:nil repeats:YES];
//    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    _talbeview.delegate = self;
    _talbeview.dataSource = self;
    [self addRunloopObserver];
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.001 target:self selector:@selector(timeMethod) userInfo:nil repeats:YES];
    _tasks = [[NSMutableArray alloc] init];
    self.maxQueueLength = 15;
    
    
}

-(void)timerMethod{
    
}




-(void)timeMethod{
    static int num = 0;
    NSLog(@"%i/t   %@",num++,[NSThread currentThread]);
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 100;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell2"];
    }
    //去掉contentview 上面的子控件
    for (int i = 1; i < 4; i++) {
        [[cell.contentView viewWithTag:i] removeFromSuperview];
    }
     //添加图片，消耗性能
    [self addTask:^{
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 135)];
        imgView.image = [UIImage imageNamed:@"1.jpg"];
         [cell addSubview:imgView];
    }];
   [self addTask:^{
       UIImageView *imgView2 = [[UIImageView alloc] initWithFrame:CGRectMake(100, 0, 100, 135)];
       imgView2.image = [UIImage imageNamed:@"1.jpg"];
       [cell addSubview:imgView2];
   }];
    [self addTask:^{
        
        UIImageView *imgView3 = [[UIImageView alloc] initWithFrame:CGRectMake(200, 0, 100, 135)];
        imgView3.image = [UIImage imageNamed:@"1.jpg"];
        [cell addSubview:imgView3];
    }];
    
   

    return cell;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 150;
}

//提供一个添加任务的方法
-(void)addTask:(RunloopBack)task{
    //保存新的任务
    [self.tasks addObject:task];
   
    //干掉之前的任务
    if (self.tasks.count > self.maxQueueLength) {
        [self.tasks removeObjectAtIndex:0];
    }
    
}



#pragma mark - <Runloop>

//回调函数
static void CallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info){
    //拿到控制器对象
    ViewController *vc = (__bridge ViewController *)info;
    if(vc.tasks.count == 0)
    {
        return;
    }
    RunloopBack task = vc.tasks.firstObject;
    task();
    //干掉已经执行完毕的任务
    [vc.tasks removeObjectAtIndex:0];
   
    
}

-(void)addRunloopObserver{
    //获得当前runloop
    CFRunLoopRef runloop = CFRunLoopGetCurrent();
    //定义上下文
    CFRunLoopObserverContext context = {
        0,
        (__bridge void *)self,
        &CFRetain,
        &CFRelease,
        NULL
        
    };
    //创建观察者
    static CFRunLoopObserverRef defaultModelObserver;

    defaultModelObserver = CFRunLoopObserverCreate(NULL, kCFRunLoopBeforeWaiting, YES, 0,  &CallBack  ,&context );
    
    //给当前runloop添加观察者
    CFRunLoopAddObserver(runloop, defaultModelObserver, kCFRunLoopCommonModes);
    
    //释放资源
    CFRelease(defaultModelObserver);
    
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
