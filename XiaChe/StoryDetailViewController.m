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
#import "WebViewController.h"
#import "DetailToolBar.h"
#import "UIView+Toast.h"

static CGFloat toolBarHeight = 44;

@interface StoryDetailViewController()<WKNavigationDelegate,UIScrollViewDelegate>
{
    CGFloat _currentOffset;
}
@property (nonatomic, weak) WKWebView *webView;
@property (nonatomic, weak) UIImageView *topImage;
@property (nonatomic, weak) UIView *headerView;
@property (nonatomic, weak) UILabel *headerTitleLabel;
@property (nonatomic, weak) UILabel *headerSourceLabel;
@property (nonatomic, weak) DeformationButton *nextBtn;
@property (nonatomic, weak) DeformationButton *beforeBtn;
@property (nonatomic, weak) UILabel *dateLabel;
@property (nonatomic, copy) NSString *thisDate;
@property (nonatomic, copy) NSString *cssString;
@end

@implementation StoryDetailViewController

- (instancetype)init
{
    self = [super init];
    if (self){
        NSURL *cssUrl = [[NSBundle mainBundle] URLForResource:@"funstyle" withExtension:@"css"];
        self.cssString = [NSString stringWithContentsOfURL:cssUrl encoding:NSUTF8StringEncoding error:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupToolBar];
    [self setupWebView];
    [self decideIfShoudGetDataFromNet];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadWebNoti:) name:NOTIFICATION_LOAD_WEBVIEW object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noMoreNew) name:NOTIFICATION_NO_MORE_NEW object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadMore) name:NOTIFICATION_LOAD_MORE object:nil];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)noMoreNew
{
    [self.webView makeToast:[NSString stringWithFormat:@"没有更新的%@啦 (ㆆᴗㆆ) ",self.predicateCache]
                   duration:1.0
                   position:CSToastPositionBottom];
}

- (void)loadMore
{
    [self.webView makeToast:[NSString stringWithFormat:@"正在努力加载之前的%@ (,,・ω・,,) ",self.predicateCache]
                   duration:1.0
                   position:CSToastPositionBottom];
}

- (void)loadWebNoti:(NSNotification *)notification
{
    self.passFun = [notification object];
    [self decideIfShoudGetDataFromNet];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (BOOL)hidesBottomBarWhenPushed
{
    return YES;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    FunDetail *detail = [self fetchWebString];
    detail.contentOffset = [NSNumber numberWithFloat:_currentOffset];
    [self.webView setNavigationDelegate:nil];
    [self.webView.scrollView setDelegate:nil];
    [self.webView stopLoading];
}

- (void)setupWebView
{
    CGRect webFrame = CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.height - 20 - toolBarHeight);
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    WKWebView *webView = [[WKWebView alloc] initWithFrame:webFrame configuration:config];
    webView.navigationDelegate = self;
    webView.scrollView.delegate = self;
    [self.view addSubview:webView];
    self.webView = webView;
    
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
    headerTitleLabel.textColor = [UIColor blackColor];
    headerTitleLabel.textAlignment = NSTextAlignmentLeft;
    [headerView addSubview:headerTitleLabel];
    self.headerTitleLabel = headerTitleLabel;
    
    UILabel *headerSourceLabel = [[UILabel alloc] init];
    headerSourceLabel.font = [UIFont systemFontOfSize:9];
    headerSourceLabel.textColor = [UIColor blackColor];
    headerSourceLabel.textAlignment = NSTextAlignmentRight;
    [headerView addSubview:headerSourceLabel];
    self.headerSourceLabel = headerSourceLabel;
    headerSourceLabel.hidden = YES;
    
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
    self.nextBtn.enabled = YES;
    self.nextBtn.isLoading = NO;
    self.beforeBtn.enabled = YES;
    self.beforeBtn.isLoading = NO;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    // TODO 不设置animated 就不会滚动 stackoverflow
    CGPoint current = CGPointMake(0, [[self fetchWebString].contentOffset floatValue]);
    [self.webView.scrollView setContentOffset:current animated:NO];
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    if (![webView.URL.absoluteString isEqualToString:@"about:blank"]){
        WebViewController *web = [[WebViewController alloc] init];
        web.url = webView.URL;
        [self.navigationController pushViewController:web animated:YES];
        [webView stopLoading];
    }
}

-(void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation
{
    NSString *todayString = [[NSUserDefaults standardUserDefaults] objectForKey:@"todayString"];
    
    if ([self.passFun.storyDate isEqualToString:todayString]){
        [self.nextBtn setEnabled:NO];
    }else{
        [self.nextBtn setEnabled:YES];
    }
    [self.beforeBtn setEnabled:YES];
    [self updateToolbar];
    
}

#pragma mark - ScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (![self.headerView isHidden]){
        _currentOffset = scrollView.contentOffset.y;
        FUNLog(@"offsetY = %f",_currentOffset);
        if (_currentOffset>=self.headerView.frame.size.height - 40){
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        }else{
            if (!self.passFun.imageData){ // 如果没有图片 状态栏是黑色
                [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
            }else{ // 如果有图片 状态栏是白色
                [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
            }
        }
        if (-_currentOffset <= 80 && -_currentOffset >= 0) {
            self.headerView.frame = CGRectMake(0, -40 - _currentOffset / 2, self.view.frame.size.width, 260 - _currentOffset / 2);
            //        [_imaSourceLab setTop:240-offSetY/2];
            //        [_titleLab setBottom:_imaSourceLab.bottom-20];
            if (-_currentOffset > 40 && !_webView.scrollView.isDragging){
//                            [self switchToNext];
            }
        }else if (-_currentOffset > 80) {
            _webView.scrollView.contentOffset = CGPointMake(0, -80);
        }else if (_currentOffset <= 300 ){
            self.headerView.frame = CGRectMake(0, -40 - _currentOffset, self.view.frame.size.width, 260);
        }
        if (_currentOffset + self.view.frame.size.height > scrollView.contentSize.height + 160 && !_webView.scrollView.isDragging) {
            //        [self.viewmodel getNextStoryContent];
//            [self switchToBefore];
        }
    }
}

#pragma mark 禁止缩放
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return nil;
}

#pragma mark - toolbar
- (void)setupToolBar
{
    DetailToolBar *tool = [DetailToolBar createToolBar];
    [tool.backBtn addTarget:self action:@selector(popToLastVc) forControlEvents:UIControlEventTouchUpInside];
    [tool.beforeBtn addTarget:self action:@selector(switchToBefore) forControlEvents:UIControlEventTouchUpInside];
    [tool.nextBtn addTarget:self action:@selector(switchToNext) forControlEvents:UIControlEventTouchUpInside];
    
    self.dateLabel = tool.dateLabel;
    self.beforeBtn = tool.beforeBtn;
    self.nextBtn = tool.nextBtn;
    
    [self.view addSubview:tool];
    
    [tool mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.height.mas_equalTo(toolBarHeight);
    }];
}

- (void)updateToolbar
{
    if ([SearchForNewFun sharedInstance].loopTime == 0){
        self.nextBtn.enabled = YES;
        self.nextBtn.isLoading = NO;
        self.beforeBtn.enabled = YES;
        self.beforeBtn.isLoading = NO;
    }else{
        if ([SearchForNewFun sharedInstance].isDownloadOld){
            self.nextBtn.enabled = YES;
            self.nextBtn.isLoading = NO;
            self.beforeBtn.enabled = YES;
            self.beforeBtn.isLoading = NO;
        }else{
//            self.nextBtn.enabled = YES;
//            self.nextBtn.isLoading = NO;
//            
//            self.beforeBtn.enabled = NO;
//            self.beforeBtn.isLoading = YES;
        }
    }
    self.dateLabel.text = self.thisDate;
}

- (void)switchToNext
{
    FunDetail *detail = [self fetchWebString];
    detail.contentOffset = [NSNumber numberWithFloat:_currentOffset];
    self.nextBtn.isLoading = YES;
    self.nextBtn.enabled = NO;
    self.topImage.image = nil;
    [self.delegate nextStoryDetailFetchWithPassFun:self.passFun];
    [self updateToolbar];
}

- (void)switchToBefore
{
    FunDetail *detail = [self fetchWebString];
    detail.contentOffset = [NSNumber numberWithFloat:_currentOffset];
    self.beforeBtn.isLoading = YES;
    self.beforeBtn.enabled = NO;
    self.topImage.image = nil;
    [self.delegate beforeStoryDetailFetchWithPassFun:self.passFun];
    [self updateToolbar];
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

#pragma mark - 网络逻辑
- (void)decideIfShoudGetDataFromNet
{
    if ([self fetchWebString].detailId == NULL){
            [self loadDetailData];
    }else{
        [self loadWebView:[self fetchWebString]];
    }
}

//TODO 404页面
- (void)setupNoView
{
    NSString *htmlString = [NSString stringWithFormat:@"<html><head><link rel=\"stylesheet\" type=\"text/css\" href= /><meta name=\"viewport\" content=\"initial-scale=1.0\" /></head><body>抱歉，今天没有瞎扯！</body></html>"];
    [self.webView loadHTMLString:htmlString baseURL:nil];
    
    self.topImage.image = nil;
    self.headerTitleLabel.text = @"";
    self.headerSourceLabel.text = @"";
}

#pragma mark 将JSON装载到DetailItem中
- (void)loadDetailData
{
    if (self.passFun.storyId == NULL){
        [self setupNoView];
        return;
    }
    
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
//        [[StorageManager sharedInstance].managedObjectContext save:nil];
        
        if ([self fetchWebString].body == NULL ){
            
            [self setupNoView];
        }else{
            [self loadWebView:[self fetchWebString]];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {

    }];
}

#pragma mark - 加载WebView
-(void)loadWebView:(FunDetail *)funDetail
{
    if([funDetail.body isEqualToString:@""]){
        [self setupNoView];
    }else{
        // 5 .23
        if ([self.passFun.storyDate isEqualToString:FirstDayString] && [self.predicateCache isEqualToString:@"瞎扯"]){
            self.headerTitleLabel.hidden = YES;
            self.headerSourceLabel.hidden = YES;
        }else{
            self.headerTitleLabel.hidden = NO;
            self.headerSourceLabel.hidden = NO;
        }
        [self.passFun setUnread:[NSNumber numberWithBool:NO]];
//        [[StorageManager sharedInstance].managedObjectContext save:nil];
//        NSString *htmlString = [NSString stringWithFormat:@"<html><head><link rel=\"stylesheet\" type=\"text/css\" href=%@ /><meta name=\"viewport\" content=\"initial-scale=1.0\" /></head><body>%@</body></html>", funDetail.css, funDetail.body];
        
        NSString *htmlString = [NSString stringWithFormat:@"<html><head><link rel=\"stylesheet\"/><style type = \"text/css\" >%@</style><meta name=\"viewport\" content=\"initial-scale=1.0\" /></head><body>%@</body></html>", self.cssString,funDetail.body];
        [self.webView loadHTMLString:htmlString baseURL:nil];
        self.navigationItem.title = funDetail.storyId.title;
        
        // 设置顶部图片
        if (self.passFun.imageData){
            self.topImage.image = [UIImage imageWithData:funDetail.imageData];
            self.headerTitleLabel.textColor = [UIColor whiteColor];
            self.headerSourceLabel.textColor = [UIColor cellHeaderColor];
            self.headerSourceLabel.hidden = NO;
//            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        }else{
            [self.topImage sd_setImageWithURL:[NSURL URLWithString:funDetail.image]
                             placeholderImage:nil
                                    completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                        [self.passFun setImageData:UIImagePNGRepresentation(image)];
                                        self.headerTitleLabel.textColor = [UIColor whiteColor];
                                        self.headerSourceLabel.textColor = [UIColor cellHeaderColor];
                                        self.headerSourceLabel.hidden = NO;
                                    }];
        }
        self.headerTitleLabel.text = self.passFun.title;
        self.headerSourceLabel.text = funDetail.image_source;
        
        
        
    }
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

@end
