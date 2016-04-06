//
//  WebViewController.m
//  XiaChe
//
//  Created by cube on 4/3/16.
//  Copyright © 2016 cube. All rights reserved.
//

#import "WebViewController.h"
#import <WebKit/WebKit.h>
#import "UIColor+Extension.h"
#import <Masonry.h>
#import <MBProgressHUD.h>
#import "ASProgressPopUpView.h"
@interface WebViewController ()<WKNavigationDelegate,UIScrollViewDelegate>
@property (nonatomic, weak) WKWebView *webView;
@property (nonatomic, weak) ASProgressPopUpView *progressView;
//@property (nonatomic, weak) MBProgressHUD *hud;
@end

@implementation WebViewController

- (instancetype)init
{
    if (self = [super init]){
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshWebView)];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self setupWebView];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController setToolbarHidden:YES animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)dealloc
{
    [self.webView setNavigationDelegate:nil];
    [self.webView.scrollView setDelegate:nil];
    [self.webView stopLoading];
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
}

- (void)refreshWebView
{
    [self.webView reload];
    [self setupProgress];
}

- (void)setupProgress
{
    ASProgressPopUpView *progress = [[ASProgressPopUpView alloc] init];
    progress.popUpViewAnimatedColors = @[[UIColor redColor], [UIColor orangeColor], [UIColor greenColor]];
    progress.popUpViewCornerRadius = 14.0;
    [self.view addSubview:progress];
    self.progressView = progress;
    [progress mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuide);
        make.width.equalTo(self.view);
        make.height.equalTo(@3);
    }];
}

- (void)setupWebView
{
    
    //    self.automaticallyAdjustsScrollViewInsets = NO;
    CGRect webFrame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    
    WKWebView *webView = [[WKWebView alloc] initWithFrame:webFrame configuration:config];
    webView.navigationDelegate = self;
    webView.scrollView.delegate = self;
    webView.backgroundColor = RGBCOLOR(249, 249, 249);
    webView.scrollView.backgroundColor = RGBCOLOR(249, 249, 249);
    [self.view addSubview:webView];
    self.webView = webView;
    
    // KVO 进度
    [webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:NULL];
    
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self setupProgress];
}

- (void)setUrl:(NSURL *)url
{
    _url = url;
    [self setupWebView];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}

#pragma mark - webview delegate
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    
    if (![webView.URL.absoluteString isEqualToString:@"about:blank"]){
        self.progressView.progress = webView.estimatedProgress;
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        [UIView animateWithDuration:0.5 animations:^{
            [self.progressView removeFromSuperview];
        }];
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    
    [self.progressView setProgress:self.webView.estimatedProgress animated:YES];
}




@end
