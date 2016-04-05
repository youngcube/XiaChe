//
//  SettingsViewController.m
//  XiaChe
//
//  Created by eusoft on 3/29/16.
//  Copyright © 2016 cube. All rights reserved.
//

#import "SettingsViewController.h"
#import "SectionModel.h"
#import "Consts.h"

#import "FunStory.h"
#import "SearchForNewFun.h"
#import "SettingCell.h"
#import <AFNetworking/AFNetworking.h>
#import <Masonry.h>
typedef NS_ENUM(NSInteger, Sections){
    kSectionOne = 0,
    kSectionTwo,
    NUM_SECTIONS
};

typedef NS_ENUM(NSInteger, SectionOne){
    kDownList = 0,
    kProgressList,
    NUM_SectionOne_ROWS
};

typedef NS_ENUM(NSInteger, SectionTwo){
    kDownDetail = 0,
    kProgressDetail,
    NUM_SectionTwo_ROWS
};

@interface SettingsViewController()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic) BOOL ifIsLoopNewData;
@property (nonatomic, strong) NSDateFormatter *formatter;
@property (nonatomic) NSUInteger fetchCount;
@property (nonatomic, weak) ASProgressPopUpView *listProgress;
//@property (nonatomic, weak) UILabel *progressListLabel;
@property (nonatomic, weak) UIButton *downloadButton;
@property (nonatomic, weak) UIButton *cancelDownloadButton;

@end

@implementation SettingsViewController

- (instancetype)init
{
    self = [super init];
    if (self){
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(download)];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(stopDownload)];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupTableView];
}

- (void)stopDownload
{
    
    [[SearchForNewFun sharedInstance] removeObserver:self forKeyPath:@"loopTime"];
    [SearchForNewFun sharedInstance].loopTime = 0;
}

- (void)download
{
    [[SearchForNewFun sharedInstance] addObserver:self forKeyPath:@"loopTime" options:NSKeyValueObservingOptionNew context:nil];
    self.fetchCount = [[SearchForNewFun sharedInstance] calculateStartTimeToOldTime];
    [SearchForNewFun sharedInstance].loopTime = self.fetchCount;
    self.ifIsLoopNewData = NO;
    [[SearchForNewFun sharedInstance] accordingDateToLoopOldData];
}

- (void)setupTableView
{
    UITableView *table = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    [self.view addSubview:table];
    table.dataSource = self;
    table.delegate = self;
    self.tableView = table;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return NUM_SECTIONS ;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == kSectionOne){
        return NUM_SectionOne_ROWS;
    }else{
        return NUM_SectionTwo_ROWS;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == kProgressList){
        return 50;
    }else{
       return 50;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SettingCell *cell = [SettingCell createCellAtTableView:tableView];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(SettingCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger listP = [[SearchForNewFun sharedInstance] calculateStartTimeToOldTime];
    NSUInteger all = [[SearchForNewFun sharedInstance] calculateStartTimeToNow];
    double pro = (double)listP/all;
    if (indexPath.section == kSectionOne){
        switch (indexPath.row) { // 下载列表
            case kDownList:
                cell.contentImage.image = [UIImage imageNamed:@"download"];
                cell.titleLabel.text = @"缓存瞎扯列表";
                [cell.downloadBtn setTitle:@"下载" forState:UIControlStateNormal];
                
                [cell.downloadBtn addTarget:self action:@selector(download) forControlEvents:UIControlEventTouchUpInside];
                [cell.cancelBtn setTitle:@"停止" forState:UIControlStateNormal];
                [cell.downloadBtn addTarget:self action:@selector(stopDownload) forControlEvents:UIControlEventTouchUpInside];
                
                self.downloadButton = cell.downloadBtn;
                self.cancelDownloadButton = cell.cancelBtn;
                
                cell.progressView.hidden = YES;
                break;
            case kProgressList:
                [cell.progressView setProgress:(1 - pro) animated:YES];
                self.listProgress = cell.progressView;
                break;
            default:
                break;
        }
    }else if (indexPath.section == kSectionTwo){
        switch (indexPath.row) { // 下载详情
            case kDownDetail:
                cell.contentImage.image = [UIImage imageNamed:@"download"];
//                [cell.titleButton setTitle:@"缓存瞎扯页面" forState:UIControlStateNormal];
//                self.downloadButton = cell.titleButton;
                cell.progressView.hidden = YES;
                break;
            case kProgressDetail:
                break;
            default:
                break;
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    NSNumber *listP = (NSNumber *)[change objectForKey:NSKeyValueChangeNewKey];
    double this = [listP doubleValue];
    NSUInteger all = [[SearchForNewFun sharedInstance] calculateStartTimeToNow];
    double pro = this/all;
    self.listProgress.progress = 1 - pro;
    [self.listProgress showPopUpViewAnimated:YES];
    NSLog(@"%@",[NSString stringWithFormat:@"%f%%",1-pro]);
}

#pragma mark - 废弃的方法
//- (void)setupView
//{
//    UIImageView *downloadImage = [[UIImageView alloc] init];
//    downloadImage.image = [UIImage imageNamed:@"download"];
//    
//    [self.view addSubview:downloadImage];
//    
//    UILabel *downloadLabel = [[UILabel alloc] init];
//    downloadLabel.text = @"缓存列表";
//    [self.view addSubview:downloadLabel];
//    
//    UIButton *downloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [downloadButton setTitle:@"开始" forState:UIControlStateNormal];
//    [downloadButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [self.view addSubview:downloadButton];
//    
//    UIButton *cancelDownloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [cancelDownloadButton setTitle:@"停止" forState:UIControlStateNormal];
//    [cancelDownloadButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [self.view addSubview:cancelDownloadButton];
//    
//    
//    ASProgressPopUpView *listProgressView = [[ASProgressPopUpView alloc] init];
//    [self.view addSubview:listProgressView];
//    
//    [downloadImage mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.view).offset(40);
//        make.top.equalTo(self.mas_topLayoutGuide).offset(40);
////        make.width.height.equalTo(@40);
//    }];
//    
//    [downloadLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(downloadImage.mas_right).offset(10);
//        make.top.equalTo(downloadImage);
//    }];
//    
//    [downloadButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.equalTo(downloadButton.mas_left).offset(-20);
//        make.top.equalTo(downloadImage);
//    }];
//    
//    [cancelDownloadButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.equalTo(self.view).offset(-40);
//        make.top.equalTo(downloadImage);
//    }];
//    
//    [listProgressView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(downloadLabel.mas_bottom).offset(40);
//        make.left.equalTo(downloadImage);
//        make.right.equalTo(cancelDownloadButton);
//    }];
//    
//}
//
//
//- (void)decideIfShouldGetNewJson
//{
//    self.fetchCount = [[SearchForNewFun sharedInstance] calculateStartTimeToNow];
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    [manager GET:LatestNewsString parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
//        
//    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        SectionModel *model = [SectionModel yy_modelWithJSON:responseObject];
//        
//        if ([model.date isEqualToString:[[SearchForNewFun sharedInstance] fetchLastestDayFromStorage:NO]]){
//            
//        }else{
//            
//            NSDate *newDate = [self.formatter dateFromString:[[SearchForNewFun sharedInstance] fetchLastestDayFromStorage:NO]];
//            NSDate *today = [self.formatter dateFromString:model.date];
//            NSTimeInterval interval = [today timeIntervalSinceDate:newDate];
//            
//            //从后往前需要加的天数
//            NSUInteger days = (interval / 86400) - 1;
//            
//            NSLog(@"%lu",(unsigned long)days);
//            
//            if(newDate == NULL){ // 首次刷新，列表为空的情况
//                NSLog(@"这是第一次刷新");
//                [[SearchForNewFun sharedInstance] accordingDateToLoopNewDataWithData:NO];
//                self.ifIsLoopNewData = NO;
//                [SearchForNewFun sharedInstance].loopTime = self.fetchCount;
//            }else{
//                [[SearchForNewFun sharedInstance] accordingDateToLoopNewDataWithData:YES];
//                self.ifIsLoopNewData = YES;
//                [SearchForNewFun sharedInstance].loopTime = days;
//            }
//        }
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        NSLog(@"failed! %@",error);
//    }];
//}
//
//- (void)downList
//{
//    NSString *oldString;
//    if (self.ifIsLoopNewData == YES){
//        oldString = [[SearchForNewFun sharedInstance] fetchLastestDayFromStorage:NO];
//        NSDate *newDate = [self.formatter dateFromString:oldString];
//        NSDate *oldDateRange = [NSDate dateWithTimeInterval:+86400*2 sinceDate:newDate];
//        oldString = [self.formatter stringFromDate:oldDateRange];
//    }else{
//        oldString = [[SearchForNewFun sharedInstance] fetchLastestDayFromStorage:YES];
//    }
//    NSDate *oldDate = [self.formatter dateFromString:oldString];
//    NSString *oldDateRangeString = [self.formatter stringFromDate:oldDate];
//    [[SearchForNewFun sharedInstance] getJsonWithString:oldDateRangeString];
//    NSString *loadString = [NSString stringWithFormat:@"正在努力加载 %lu / %lu",(unsigned long)(self.fetchCount - [SearchForNewFun sharedInstance].loopTime),(unsigned long)self.fetchCount];
//    NSLog(@"%@",loadString);
//    [SearchForNewFun sharedInstance].loopTime--;
//}

@end
