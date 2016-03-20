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

@interface StoryDetailViewController()
//@property (nonatomic ,strong) StoryDetail *detail;
@property (nonatomic ,strong) FunDetail *bigDetail;

@end

@implementation StoryDetailViewController

- (instancetype)init
{
    self = [super init];
    if (self){
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(nextFun)];
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
    [self loadDetailData];
    [self loadWebView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadWebView) name:NSManagedObjectContextDidSaveNotification object:nil];
    
}

#pragma mark - 将JSON装载到DetailItem中
-(void)loadDetailData
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:self.url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        StoryDetail *detail = [StoryDetail yy_modelWithDictionary:responseObject];
        
        FunDetail *st = [NSEntityDescription insertNewObjectForEntityForName:@"FunDetail" inManagedObjectContext:[StorageManager sharedInstance].managedObjectContext];
        st.body = detail.body;
        st.css = [detail.css lastObject];
        st.detailId = detail.detailId;
        
        
        
        [[StorageManager sharedInstance].managedObjectContext save:nil];
        
        self.navigationItem.title = self.bigDetail.detailId;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"failed! %@",error);
    }];
}

#pragma mark - 加载WebView

-(void)loadWebView
{
    UIWebView *webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
//    webView.scrollView.contentInset = UIEdgeInsetsMake(44, 0, 0, 0);
    NSString *htmlString = [NSString stringWithFormat:@"<html><head><link rel=\"stylesheet\" type=\"text/css\" href=%@ /></head><body>%@</body></html>", [self fetchWebString].css, [self fetchWebString].body];
    [webView loadHTMLString:htmlString baseURL:nil];
    [self.view addSubview:webView];
}

- (FunDetail *)fetchWebString
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"FunDetail" inManagedObjectContext:[StorageManager sharedInstance].managedObjectContext];
    [fetchRequest setEntity:entity];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"detailId" ascending:YES];
    [fetchRequest setSortDescriptors:@[sort]];
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"detailId == %@",self.detailCleanId];
    NSLog(@"%@",self.detailCleanId);
    [fetchRequest setPredicate:pre];
    NSArray *array = [[StorageManager sharedInstance].managedObjectContext executeFetchRequest:fetchRequest error:nil];
    FunDetail *detail = [array firstObject];
    
    return detail;
}

#pragma mark - 加载下一篇
- (void)nextFun
{
//    SectionsViewController *vc = [[SectionsViewController alloc] init];
//    NSIndexPath *index = [vc.fetchedResultsController indexPathForObject:self.bigFun];
    //传入时间 -1*86300
    
    
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
    //    NSLog(@"%@",fun.storyDate);
//    self.thisStoryTime++;
    return fun.storyDate;
}

@end
