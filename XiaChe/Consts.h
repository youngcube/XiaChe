//
//  Consts.h
//  XIaCheDaily
//
//  Created by cube on 3/15/16.
//  Copyright © 2016 cube. All rights reserved.
//

#define EACH_TIME_FETCH_NUM 10
#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#ifdef DEBUG
#define FUNLog( s, ... ) NSLog( @"<%p %@:(%d)> %@", self, [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
#define FUNLog( s, ... )
#endif
static NSString* const LatestNewsString = @"http://news-at.zhihu.com/api/4/news/latest";
static NSString* const BeforeNewsString = @"http://news.at.zhihu.com/api/4/news/before/";
static NSString* const DetailNewsString = @"http://news-at.zhihu.com/api/4/news/";
static NSString* const NOTIFICATION_LOAD_WEBVIEW = @"notification_load_webview";
static NSString* const NOTIFICATION_NO_MORE_NEW = @"notification_no_more_new";
static NSString* const NOTIFICATION_NO_MORE_OLD = @"notification_no_more_old";
static NSString* const NOTIFICATION_LOAD_MORE = @"notification_load_more";
static NSString* const FirstDayString = @"20130523";