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
#import "Consts.h"

@interface StoryDetailViewController()
//@property (nonatomic ,strong) StoryDetail *detail;
@property (nonatomic ,strong) FunDetail *bigDetail;
@property (nonatomic, strong) UIWebView *webView;
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
    self.thisStoryTime = 0; //传入时间
    self.view.backgroundColor = [UIColor whiteColor];
//    self.navigationController.navigationBarHidden = YES;
    [self decideIfShoudGetDataFromNet];
    
    
}

- (void)decideIfShoudGetDataFromNet
{
    if ([self fetchWebString].detailId == NULL){
        [self loadDetailData];
//        [self loadWebView];
    }else{
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
        self.navigationItem.title = self.bigDetail.detailId;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"failed! %@",error);
    }];
}



#pragma mark - 加载WebView

-(void)loadWebView
{
    self.webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
//    webView.scrollView.contentInset = UIEdgeInsetsMake(44, 0, 0, 0);
    NSString *htmlString = [NSString stringWithFormat:@"<html><head><link rel=\"stylesheet\" type=\"text/css\" href=%@ /></head><body>%@</body></html>", [self fetchWebString].css, [self fetchWebString].body];
//    FunDetail *detail = [NSEntityDescription insertNewObjectForEntityForName:@"FunDetail" inManagedObjectContext:[StorageManager sharedInstance].managedObjectContext];
//    detail.body = self.passFun.detailId;
    
    
    [self.webView loadHTMLString:htmlString baseURL:nil];
    [self.view addSubview:self.webView];
    
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
//    SectionsViewController *vc = [[SectionsViewController alloc] init];
//    NSIndexPath *index = [vc.fetchedResultsController indexPathForObject:self.bigFun];
    //传入时间 -1*86300
    FunStory *sto = [self fetchDate];
    NSString *todayString = sto.storyDate;
    NSLog(@"today is %@",todayString);
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"YYYYMMdd"];
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
