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
#import <MBProgressHUD.h>
#import "UIImageView+WebCache.h"
#import "UIColor+Extension.h"
#import <WebKit/WebKit.h>
#import "DetailToolbar.h"
#import "WebViewController.h"

@interface StoryDetailViewController()<WKNavigationDelegate,UIScrollViewDelegate>
{
    CGFloat webHeight;
//    CGFloat _startScroll;
}
@property (nonatomic, weak) WKWebView *webView;
@property (nonatomic, weak) DetailToolbar *toolBar;
@property (nonatomic, weak) UIImageView *topImage;
@property (nonatomic, weak) UIView *headerView;
@property (nonatomic, weak) UILabel *headerTitleLabel;
@property (nonatomic, weak) UILabel *headerSourceLabel;
@property (nonatomic, copy) NSString *dateString;
@property (nonatomic) BOOL getNextFun;
@property (nonatomic) double webViewProgress;
@property (nonatomic, weak) MBProgressHUD *hud;
@property (nonatomic, weak) UIProgressView *progressView;
@property (nonatomic, weak) UIBarButtonItem *nextBtnItem;
@property (nonatomic, weak) UIBarButtonItem *beforeBtnItem;
@property (nonatomic, copy) NSString *thisDate;
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
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupToolbar];
    [self setupWebView];
    [self decideIfShoudGetDataFromNet];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(detailDidSave) name:NSManagedObjectContextDidSaveNotification object:nil];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.navigationController setToolbarHidden:NO animated:YES];
}

- (BOOL)hidesBottomBarWhenPushed
{
    return YES;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.webView setNavigationDelegate:nil];
    [self.webView.scrollView setDelegate:nil];
    [self.webView stopLoading];
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
}

- (void)setupWebView
{
    CGRect webFrame = CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.height);
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    WKWebView *webView = [[WKWebView alloc] initWithFrame:webFrame configuration:config];
    webView.navigationDelegate = self;
    webView.scrollView.delegate = self;
    webView.backgroundColor = RGBCOLOR(249, 249, 249);
    webView.scrollView.backgroundColor = RGBCOLOR(249, 249, 249);
    webView.scrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:webView];
    self.webView = webView;
    
    // KVO 进度
    [webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:NULL];
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, -40, self.view.frame.size.width, 260)];
    headerView.clipsToBounds = YES;
    [self.view addSubview:headerView];
    self.headerView = headerView;
    
    UIImageView *topImage = [[UIImageView alloc] init];
    topImage.frame = CGRectMake(0, 0, self.view.bounds.size.width, 300);
    topImage.contentMode = UIViewContentModeScaleAspectFill;;
    topImage.backgroundColor = [UIColor clearColor];
    [headerView addSubview:topImage];
    self.topImage = topImage;
    
    UILabel *headerTitleLabel = [[UILabel alloc] init];
    headerTitleLabel.numberOfLines = 0;
    headerTitleLabel.font = [UIFont boldSystemFontOfSize:20];
    headerTitleLabel.textColor = [UIColor whiteColor];
    headerTitleLabel.textAlignment = NSTextAlignmentLeft;
    [headerView addSubview:headerTitleLabel];
    self.headerTitleLabel = headerTitleLabel;
    
    UILabel *headerSourceLabel = [[UILabel alloc] init];
    headerSourceLabel.font = [UIFont systemFontOfSize:9];
    headerSourceLabel.textColor = [UIColor cellSeparateLine];
    headerSourceLabel.textAlignment = NSTextAlignmentRight;
    [headerView addSubview:headerSourceLabel];
    self.headerSourceLabel = headerSourceLabel;
    
    [headerTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headerView.mas_left).offset(20);
        make.right.equalTo(self.headerView.mas_right).offset(-20);
        make.bottom.equalTo(self.headerView.mas_bottom).offset(-32);
    }];
    
    [headerSourceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.headerView.mas_right).offset(-20);
        make.bottom.equalTo(self.headerView.mas_bottom).offset(-10);
    }];
}

#pragma mark - webview delegate
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    NSLog(@"progress = %f",webView.estimatedProgress);
    self.hud.progress = webView.estimatedProgress;
    [self.hud hide:YES];
    
    NSString *todayString = [[NSUserDefaults standardUserDefaults] objectForKey:@"todayString"];
    NSLog(@"story date = %@ %@",self.passFun.storyDate,todayString);
    if ([self.passFun.storyDate isEqualToString:todayString]){
        [self.nextBtnItem setEnabled:NO];
    }else{
        [self.nextBtnItem setEnabled:YES];
    }
    [self.beforeBtnItem setEnabled:YES];
    [self setupToolbar];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSLog(@"navigation = %@",webView.URL);
    if (![webView.URL.absoluteString isEqualToString:@"about:blank"]){
        WebViewController *web = [[WebViewController alloc] init];
        web.url = webView.URL;
        [self.navigationController pushViewController:web animated:YES];
        [webView stopLoading];
    }
}



#pragma mark - ScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (![self.headerView isHidden]){
//        _startScroll = scrollView.contentOffset.y;
        CGFloat offSetY = scrollView.contentOffset.y;
        if (offSetY>=self.headerView.frame.size.height - 40){
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        }else{
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        }
        if (-offSetY <= 80 && -offSetY >= 0) {
            self.headerView.frame = CGRectMake(0, -40 - offSetY / 2, self.view.frame.size.width, 260 - offSetY / 2);
            //        [_imaSourceLab setTop:240-offSetY/2];
            //        [_titleLab setBottom:_imaSourceLab.bottom-20];
            if (-offSetY > 40 && !_webView.scrollView.isDragging){
                //            [self.viewmodel getPreviousStoryContent];
            }
        }else if (-offSetY > 80) {
            _webView.scrollView.contentOffset = CGPointMake(0, -80);
        }else if (offSetY <= 300 ){
            self.headerView.frame = CGRectMake(0, -40 - offSetY, self.view.frame.size.width, 260);
        }
        if (offSetY + self.view.frame.size.height > scrollView.contentSize.height + 160 && !_webView.scrollView.isDragging) {
            //        [self.viewmodel getNextStoryContent];
        }
        
    }
}

#pragma mark 禁止缩放
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return nil;
}

#pragma mark - UI
- (void)setupToolbar
{
    [self.navigationController setToolbarHidden:NO animated:YES];
    
    UIBarButtonItem *pop = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(popToLastVc)];
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *fixWidth = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *nextBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"upArrow"] style:UIBarButtonItemStylePlain target:self action:@selector(switchToNewDetail:)];
    nextBtn.tag = 1001;
    self.nextBtnItem = nextBtn;
    
    
    UIBarButtonItem *dateItem = [[UIBarButtonItem alloc] initWithTitle:self.thisDate style:UIBarButtonItemStylePlain target:self action:nil];
    dateItem.enabled = NO;
    
    
    UIBarButtonItem *beforeBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"downArrow"] style:UIBarButtonItemStylePlain target:self action:@selector(switchToNewDetail:)];
    beforeBtn.tag = 1002;
    self.beforeBtnItem = beforeBtn;
    
    NSString *todayString = [[NSUserDefaults standardUserDefaults] objectForKey:@"todayString"];
    
    if ([self.passFun.storyDate isEqualToString:todayString]){
        [self.nextBtnItem setEnabled:NO];
    }else{
        [self.nextBtnItem setEnabled:YES];
    }

    [self setToolbarItems:@[pop,flex,beforeBtn,flex,dateItem,flex,nextBtn,flex,fixWidth] animated:YES];
}

- (NSString *)thisDate
{
    NSDateFormatter *normalFormat = [[NSDateFormatter alloc] init];
    [normalFormat setDateFormat:@"yyyyMMdd"];
    
    NSDateFormatter *simpleFormat = [[NSDateFormatter alloc] init];
    [simpleFormat setDateFormat:@"M 月 d 日"];
    
    NSDate *thisDate = [normalFormat dateFromString:self.passFun.storyDate];
    return [simpleFormat stringFromDate:thisDate];
}

- (void)popToLastVc
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    [self.progressView setProgress:self.webView.estimatedProgress animated:YES];
}


#pragma mark - 网络逻辑
- (void)decideIfShoudGetDataFromNet
{
    if ([self fetchWebString].detailId == NULL){
        [self loadDetailData];
    }else{
        [self loadWebView:[self fetchWebString]];
    }
}

#pragma mark 将JSON装载到DetailItem中
- (void)loadDetailData
{
    NSString *url = [NSString stringWithFormat:@"%@%@",DetailNewsString,self.passFun.storyId];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        StoryDetail *detail = [StoryDetail yy_modelWithDictionary:responseObject];
        FunDetail *st = [NSEntityDescription insertNewObjectForEntityForName:@"FunDetail" inManagedObjectContext:[StorageManager sharedInstance].managedObjectContext];
        st.body = detail.body;
        st.css = [detail.css lastObject];
        st.detailId = detail.detailId;
        st.image = detail.image;
        st.image_source = detail.image_source;
        [[StorageManager sharedInstance].managedObjectContext save:nil];

        [self loadWebView:[self fetchWebString]];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {

    }];
}

#pragma mark - 加载WebView
-(void)loadWebView:(FunDetail *)funDetail
{
    [self.passFun setUnread:[NSNumber numberWithBool:NO]];
    [[StorageManager sharedInstance].managedObjectContext save:nil];
    
    NSString *htmlString = [NSString stringWithFormat:@"<html><head><link rel=\"stylesheet\" type=\"text/css\" href=%@ /><meta name=\"viewport\" content=\"initial-scale=1.0\" /></head><body>%@</body></html>", funDetail.css, funDetail.body];
    [self.webView loadHTMLString:htmlString baseURL:nil];
    self.navigationItem.title = funDetail.storyId.title;
    [self.topImage sd_setImageWithURL:[NSURL URLWithString:funDetail.image]];
    
    self.headerTitleLabel.text = self.passFun.title;
    self.headerSourceLabel.text = funDetail.image_source;
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
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyyMMdd"];
    NSDate *todayDate = [format dateFromString:todayString];
    NSDate *nextRange = [NSDate dateWithTimeInterval:+86400*step sinceDate:todayDate];
    NSString *newDateRangeString = [format stringFromDate:nextRange];
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

- (void)switchToNewDetail:(UIButton *)sender
{
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.mode = MBProgressHUDModeAnnularDeterminate;
    
    if (sender.tag == 1001){
        self.dateString = [self dateStringForInt:kNext];
        [self.nextBtnItem setEnabled:NO];
    }else if(sender.tag == 1002){
        self.dateString = [self dateStringForInt:kBefore];
        [self.beforeBtnItem setEnabled:NO];
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"FunStory" inManagedObjectContext:[StorageManager sharedInstance].managedObjectContext];
    [fetchRequest setEntity:entity];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"storyId" ascending:YES];
    [fetchRequest setSortDescriptors:@[sort]];
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"storyDate == %@",self.dateString];
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
        [self decideIfShoudGetDataFromNet];
    }
}

- (void)detailDidSave
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
