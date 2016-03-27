//
//  StoryDetailViewController.m
//  XIaCheDaily
//
//  Created by cube on 3/16/16.
//  Copyright © 2016 cube. All rights reserved.
//

#import "StoryDetailViewController.h"
#import "SectionsViewController.h"
#import "FunStory.h"
#import "FunDetail.h"
#import "SearchForNewFun.h"
#import <AFNetworking/AFNetworking.h>
#import <Masonry.h>
#import <MJRefresh.h>
#import "Consts.h"
#import <WebKit/WebKit.h>

@interface StoryDetailViewController()<UIWebViewDelegate,UIScrollViewDelegate>
{
    CGFloat webHeight;
}
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, copy) NSString *dateString;
@property (nonatomic) BOOL getNextFun;
@end

typedef NS_ENUM(NSInteger, Steps){
    kNext = 1,
    kBefore = -1
};

@implementation StoryDetailViewController

- (instancetype)init
{
    self = [super init];
    if (self){
//        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(afterFun)];
//        self.navigationItem.title = self.detail.detailId;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupToolbar];
    [self setupWebView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataDidSave) name:NSManagedObjectContextDidSaveNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupToolbar
{
    [self.navigationController setToolbarHidden:NO animated:YES];
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *fixWidth = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixWidth.width = 200;
    UIBarButtonItem *nextBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self action:@selector(switchToNewDetail:)];
    nextBtn.tag = 1001;
    
    UIBarButtonItem *beforeBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self action:@selector(switchToNewDetail:)];
    beforeBtn.tag = 1002;
    
    [self setToolbarItems:@[flex,nextBtn,fixWidth,beforeBtn] animated:YES];
}

- (void)setupWebView
{
//    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
//    scrollView.delegate = self;
//    
//    [self.view addSubview:scrollView];
//    self.scrollView = scrollView;
    
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.webView.delegate = self;
    self.webView.scrollView.delegate = self;
    self.webView.backgroundColor = RGBCOLOR(249, 249, 249);
    self.webView.scrollView.backgroundColor = RGBCOLOR(249, 249, 249);
    
//    UIView *newView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 100, 100)];
//    newView.backgroundColor = [UIColor redColor];
//    [self.webView.scrollView addSubview:newView];
    
    
    
//    self.webView.scrollView.backgroundColor = [UIColor redColor];
    [self.view addSubview:self.webView];
    
    [self decideIfShoudGetDataFromNet];
//    scrollView.contentSize = self.webView.bounds.size;
    
//    NSLog(@"加载前的scrollview contentSize %@",NSStringFromCGSize(self.webView.scrollView.contentSize));
}

- (void)decideIfShoudGetDataFromNet
{
    if ([self fetchWebString].detailId == NULL){
        [self loadDetailData];
    }else{
        [self loadWebView:[self fetchWebString]];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    
    webHeight = self.webView.scrollView.contentSize.height - self.view.bounds.size.height;
//    NSLog(@"加载完毕后的webHeight %f",webHeight);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    NSLog(@"contentOffset.y = %f",scrollView.contentOffset.y);
    if (scrollView.contentOffset.y >= webHeight + 50){
//        NSLog(@"下拉加载更多");
    }
    if (scrollView.contentOffset.y <= -(64+50)){
//        NSLog(@"上拉加载更多");
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
//    if (scrollView.contentOffset.y >= webHeight + 90){
//        NSLog(@"shang拉加载更多");
//        [UIView animateWithDuration:1.0 animations:^{
//            self.webView.scrollView.contentInset = UIEdgeInsetsMake(-self.webView.scrollView.contentSize.height-20+100, 0, 0, 0);
//        } completion:^(BOOL finished) {
//            [self.webView.scrollView setFrame:CGRectMake(0, self.webView.scrollView.contentSize.height, self.view.bounds.size.width, 0)];
//            
//        }];
//        
//        
//        
//    }
//    if (scrollView.contentOffset.y <= -(64+90)){
//        NSLog(@"xia拉加载更多");
//        [UIView animateWithDuration:1.0 animations:^{
//            self.webView.scrollView.contentInset = UIEdgeInsetsMake(-64, 0, 0, 0);
//        } completion:^(BOOL finished) {
//            [self.webView.scrollView setFrame:CGRectMake(0, self.webView.scrollView.contentSize.height, self.view.bounds.size.width, 0)];
//            
//        }];
//    }
}

#pragma mark - 将JSON装载到DetailItem中
-(void)loadDetailData
{
    NSString *url = [NSString stringWithFormat:@"%@%@",DetailNewsString,self.passFun.storyId];
//    NSLog(@"detail URL = %@",url);
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
//        NSLog(@"Progress ----------- %lld",downloadProgress.totalUnitCount);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        StoryDetail *detail = [StoryDetail yy_modelWithDictionary:responseObject];
        FunDetail *st = [NSEntityDescription insertNewObjectForEntityForName:@"FunDetail" inManagedObjectContext:[StorageManager sharedInstance].managedObjectContext];
        st.body = detail.body;
        st.css = [detail.css lastObject];
        st.detailId = detail.detailId;
        [[StorageManager sharedInstance].managedObjectContext save:nil];
        [self loadWebView:[self fetchWebString]];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        NSLog(@"failed! %@",error);
    }];
}

#pragma mark - 加载WebView
-(void)loadWebView:(FunDetail *)funDetail
{
//    self.webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
//    [self.view addSubview:self.webView];
//    webView.scrollView.contentInset = UIEdgeInsetsMake(44, 0, 0, 0);
    NSString *htmlString = [NSString stringWithFormat:@"<html><head><link rel=\"stylesheet\" type=\"text/css\" href=%@ /></head><body>%@</body></html>", funDetail.css, funDetail.body];
    [self.webView loadHTMLString:htmlString baseURL:nil];
    self.title = funDetail.storyId.title;
//    NSLog(@"%@",funDetail.storyId.title);
    NSString *newString = [self dateStringForInt:kNext];
    NSString *before = [self dateStringForInt:kBefore];
    NSLog(@"next = %@ , before = %@", newString , before);
}

- (FunDetail *)fetchWebString
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"FunDetail" inManagedObjectContext:[StorageManager sharedInstance].managedObjectContext];
    [fetchRequest setEntity:entity];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"detailId" ascending:YES];
    [fetchRequest setSortDescriptors:@[sort]];
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"detailId == %@",self.passFun.storyId];
    
    [fetchRequest setPredicate:pre];
    NSArray *array = [[StorageManager sharedInstance].managedObjectContext executeFetchRequest:fetchRequest error:nil];
    FunDetail *detail = [array firstObject];
    return detail;
}

#pragma mark - 获取当前storyId所处的FunStory Model
- (FunStory *)fetchDate
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"FunStory" inManagedObjectContext:[StorageManager sharedInstance].managedObjectContext];
    [fetchRequest setEntity:entity];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"storyId" ascending:YES];
    [fetchRequest setSortDescriptors:@[sort]];
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"storyId == %@",self.passFun.storyId];
//    NSLog(@"%@",self.detailCleanId);
    [fetchRequest setPredicate:pre];
    NSArray *array = [[StorageManager sharedInstance].managedObjectContext executeFetchRequest:fetchRequest error:nil];
    FunStory *funDate = [array firstObject];
    return funDate;
}

#pragma mark - 计算当前时间的前一天和后一天
- (NSString *)dateStringForInt:(Steps)step
{
    //传入时间 -1*86300
    FunStory *sto = [self fetchDate];
    NSString *todayString = sto.storyDate;
//    NSLog(@"today is %@",todayString);
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyyMMdd"];
    NSDate *todayDate = [format dateFromString:todayString];
    NSDate *nextRange = [NSDate dateWithTimeInterval:+86400*step sinceDate:todayDate];
    
    NSString *newDateRangeString = [format stringFromDate:nextRange];
//    NSLog(@"old String = %@",newDateRangeString);
    return newDateRangeString;
}

#pragma mark - 直接从CoreData读取最新的文章
- (NSString *)fetchLastestDayFromStorage
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"FunStory" inManagedObjectContext:[StorageManager sharedInstance].managedObjectContext];
    [fetchRequest setEntity:entity];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"storyDate" ascending:NO]; // YES返回最老的
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    NSArray *late = [[StorageManager sharedInstance].managedObjectContext executeFetchRequest:fetchRequest error:nil];
    FunStory *fun = [late firstObject];
    return fun.storyDate;
}

- (void)switchToNewDetail:(UIBarButtonItem *)sender
{
    if (sender.tag == 1001){
        self.dateString = [self dateStringForInt:kNext];
    }else if(sender.tag == 1002){
        self.dateString = [self dateStringForInt:kBefore];
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"FunStory" inManagedObjectContext:[StorageManager sharedInstance].managedObjectContext];
    [fetchRequest setEntity:entity];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"storyId" ascending:YES];
    [fetchRequest setSortDescriptors:@[sort]];
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"storyDate == %@",self.dateString];
    NSLog(@"今天的日期是！ %@",self.dateString);
    [fetchRequest setPredicate:pre];
    NSArray *array = [[StorageManager sharedInstance].managedObjectContext executeFetchRequest:fetchRequest error:nil];
    FunStory *funDate = [array firstObject];
    
    if (funDate == NULL){
        self.getNextFun = YES;
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyyMMdd"];
        NSDate *oldDate = [formatter dateFromString:self.dateString];
        NSDate *oldDateRange = [NSDate dateWithTimeInterval:+86400 sinceDate:oldDate];
        
        NSString *oldDateRangeString = [formatter stringFromDate:oldDateRange];
        
        
        [[SearchForNewFun sharedInstance] getJsonWithString:oldDateRangeString];
        
    }else{
        self.passFun = funDate;
    }
    
    [self decideIfShoudGetDataFromNet];
}

- (void)dataDidSave
{
    
    if (self.getNextFun == NO) {
        return;
    }else{
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"FunStory" inManagedObjectContext:[StorageManager sharedInstance].managedObjectContext];
        [fetchRequest setEntity:entity];
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"storyId" ascending:YES];
        [fetchRequest setSortDescriptors:@[sort]];
        NSPredicate *pre = [NSPredicate predicateWithFormat:@"storyDate == %@",self.dateString];
        NSLog(@"今天的日期是！ %@",self.dateString);
        [fetchRequest setPredicate:pre];
        NSArray *array = [[StorageManager sharedInstance].managedObjectContext executeFetchRequest:fetchRequest error:nil];
        FunStory *funDate = [array firstObject];
        self.passFun = funDate;
        [self decideIfShoudGetDataFromNet];
        self.getNextFun = NO;
    }
}

@end
