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
@interface WebViewController ()<WKNavigationDelegate,UIScrollViewDelegate>
@property (nonatomic, weak) WKWebView *webView;
@property (nonatomic, weak) UIProgressView *progressView;
@property (nonatomic, weak) MBProgressHUD *hud;
@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self setupWebView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)dealloc
{
    [self.webView setNavigationDelegate:nil];
    [self.webView.scrollView setDelegate:nil];
    [self.webView stopLoading];
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
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
    self.hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication].windows lastObject] animated:YES];
    self.hud.mode = MBProgressHUDModeAnnularDeterminate;
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
    self.hud.progress = webView.estimatedProgress;
    [self.hud hide:YES];
    if (![webView.URL.absoluteString isEqualToString:@"about:blank"]){
        self.progressView.progress = webView.estimatedProgress;
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    self.hud.progress = self.webView.estimatedProgress;
}




@end
