//
//  HTTPSession.h
//  XiaChe
//
//  Created by eusoft on 3/24/16.
//  Copyright © 2016 cube. All rights reserved.
//

#import <AFNetworking.h>
#import "Singleton.h"

@interface HTTPSession : AFHTTPSessionManager
SingletonH(HTTPSession)
//+ (instancetype)sharedInstance;
@end
