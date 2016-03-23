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
#import <AFNetworking/AFNetworking.h>
#import <Masonry.h>
#import <MJRefresh.h>
#import "Consts.h"

@interface StoryDetailViewController()<UIWebViewDelegate,UIScrollViewDelegate>
{
    CGFloat webHeight;
}
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, weak) UIScrollView *scrollView;
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
    
    [self setupScrollView];
    
    self.view.backgroundColor = [UIColor whiteColor];
//    [self decideIfShoudGetDataFromNet];
//    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 320, self.view.bounds.size.width, 40)];
//    toolBar.backgroundColor = [UIColor redColor];
//    [self.webView addSubview:toolBar];
}

- (void)setupScrollView
{
//    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
//    scrollView.delegate = self;
//    
//    [self.view addSubview:scrollView];
//    self.scrollView = scrollView;
    
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.webView.delegate = self;
    self.webView.scrollView.delegate = self;
    [self.view addSubview:self.webView];
    
    [self decideIfShoudGetDataFromNet];
//    scrollView.contentSize = self.webView.bounds.size;
    
    NSLog(@"加载前的scrollview contentSize %@",NSStringFromCGSize(self.webView.scrollView.contentSize));
}

- (void)decideIfShoudGetDataFromNet
{
    if ([self fetchWebString].detailId == NULL){
        [self loadDetailData];
    }else{
        [self loadWebView];
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
    if (scrollView.contentOffset.y >= webHeight + 50){
        NSLog(@"下拉加载更多");
        [self loadWebView];
    }
    if (scrollView.contentOffset.y <= -(64+50)){
        NSLog(@"shang拉加载更多");
        [self loadWebView];
    }
}

#pragma mark - 将JSON装载到DetailItem中
-(void)loadDetailData
{
    NSString *url = [NSString stringWithFormat:@"%@%@",DetailNewsString,self.passFun.storyId];
    NSLog(@"detail URL = %@",url);
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        StoryDetail *detail = [StoryDetail yy_modelWithDictionary:responseObject];
        FunDetail *st = [NSEntityDescription insertNewObjectForEntityForName:@"FunDetail" inManagedObjectContext:[StorageManager sharedInstance].managedObjectContext];
        st.body = detail.body;
        st.css = [detail.css lastObject];
        st.detailId = detail.detailId;
        [[StorageManager sharedInstance].managedObjectContext save:nil];
        [self loadWebView];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"failed! %@",error);
    }];
}

#pragma mark - 加载WebView
-(void)loadWebView
{
//    self.webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
//    [self.view addSubview:self.webView];
//    webView.scrollView.contentInset = UIEdgeInsetsMake(44, 0, 0, 0);
    NSString *htmlString = [NSString stringWithFormat:@"<html><head><link rel=\"stylesheet\" type=\"text/css\" href=%@ /></head><body>%@</body></html>", [self fetchWebString].css, [self fetchWebString].body];

    [self.webView loadHTMLString:htmlString baseURL:nil];

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

- (FunStory *)fetchDate
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"FunStory" inManagedObjectContext:[StorageManager sharedInstance].managedObjectContext];
    [fetchRequest setEntity:entity];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"storyId" ascending:YES];
    [fetchRequest setSortDescriptors:@[sort]];
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"storyId == %@",self.detailCleanId];
    NSLog(@"%@",self.detailCleanId);
    [fetchRequest setPredicate:pre];
    NSArray *array = [[StorageManager sharedInstance].managedObjectContext executeFetchRequest:fetchRequest error:nil];
    FunStory *funDate = [array firstObject];
    return funDate;
}

#pragma mark - 加载下一篇
- (NSString *)dateStringForInt:(Steps)step
{
    //传入时间 -1*86300
    FunStory *sto = [self fetchDate];
    NSString *todayString = sto.storyDate;
    NSLog(@"today is %@",todayString);
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyyMMdd"];
    NSDate *todayDate = [format dateFromString:todayString];
    NSDate *nextRange = [NSDate dateWithTimeInterval:+86400*step sinceDate:todayDate];
    
    NSString *newDateRangeString = [format stringFromDate:nextRange];
    NSLog(@"old String = %@",newDateRangeString);
    return newDateRangeString;
}

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



@end
