//
//  StoryDetailViewController.m
//  XIaCheDaily
//
//  Created by cube on 3/16/16.
//  Copyright © 2016 cube. All rights reserved.
//

#import "StoryDetailViewController.h"
#import <AFNetworking/AFNetworking.h>

@interface StoryDetailViewController()
@property (nonatomic ,strong) StoryDetail *detail;
@end

@implementation StoryDetailViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
//    self.navigationController.navigationBarHidden = YES;
    [self loadDetailData];
//    [self loadWebView];
}

#pragma mark - 将JSON装载到DetailItem中
-(void)loadDetailData
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:self.url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        self.detail = [StoryDetail yy_modelWithDictionary:responseObject];
        [self loadWebView];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"failed! %@",error);
    }];
}

#pragma mark - 加载WebView

-(void)loadWebView
{
    NSString *css = [self.detail.css lastObject];
    UIWebView *webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
//    webView.scrollView.contentInset = UIEdgeInsetsMake(44, 0, 0, 0);
    NSString *htmlString = [NSString stringWithFormat:@"<html><head><link rel=\"stylesheet\" type=\"text/css\" href=%@ /></head><body>%@</body></html>", css, self.detail.body];
    [webView loadHTMLString:htmlString baseURL:nil];
    [self.view addSubview:webView];
}



@end
