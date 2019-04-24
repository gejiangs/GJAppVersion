//
//  GJAppVersion.m
//  GJAppVersion
//
//  Created by gejiangs on 2019/4/4.
//  Copyright © 2019 gejiangs. All rights reserved.
//

#import "GJAppVersion.h"
//#import <StoreKit/StoreKit.h>

typedef NS_ENUM(NSInteger) {
    GJRequestTypeAppID,
    GJRequestTypeBundleID
}GJRequestType;

@implementation GJVersionInfo

-(id)initWithDict:(NSDictionary *)dict
{
    if (self = [super init]) {
        self.version = dict[@"version"];
        self.trackId = dict[@"trackId"];
        self.bundleId = dict[@"bundleId"];
        self.trackViewUrl = dict[@"trackViewUrl"];
        self.appDescription = dict[@"appDescription"];
    }
    return self;
}

@end

@interface GJAppVersion ()

@end

@implementation GJAppVersion

+(instancetype)manager
{
    static id obj;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [[self alloc] init];
    });
    return obj;
}

-(id)init
{
    if (self = [super init]) {
        self.alertTitle     = @"检测版本";
        self.alertMsg       = @"检测到新版本，是否更新？";
        self.alertCancel    = @"暂不更新";
        self.alertSure      = @"更新";
    }
    return self;
}

/**
 检查新版本
 */
-(void)checkNewVesion
{
    [self checkNewVesion:nil];
}

/**
 检查新版本
 */
-(void)checkNewVesion:(NewVersionBlock)block
{
    [self checkNewVesionWithBunldID:[self currentBundleID] block:block];
}

/**
 根据AppID检测是否有新版本
 
 @param appID AppID(AppStore上获取)
 */
-(void)checkNewVesionWithAPPID:(NSString *)appID
{
    [self checkNewVesionWithAPPID:appID block:nil];
}

/**
 根据AppID检测是否有新版本
 
 @param appID AppID(AppStore上获取)
 @param block 返回是否有新版本
 */
-(void)checkNewVesionWithAPPID:(NSString *)appID block:(NewVersionBlock)block
{
    [self requestWithType:GJRequestTypeAppID value:appID block:^(BOOL hasNew, GJVersionInfo *version) {
        if (block) {
            block(hasNew, version);
        }else{
            [self showNewVersionAlertWithVersion:version];
        }
    }];
}

/**
 根据工程Bundle identifier检测是否有新版本
 
 @param bunldID 工程Bundle identifier
 */
-(void)checkNewVesionWithBunldID:(NSString *)bunldID
{
    [self checkNewVesionWithBunldID:bunldID block:nil];
}

/**
 根据工程Bundle identifier检测是否有新版本
 
 @param bunldID 工程Bundle identifier
 @param block 返回是否有新版本
 */
-(void)checkNewVesionWithBunldID:(NSString *)bunldID block:(NewVersionBlock)block
{
    [self requestWithType:GJRequestTypeBundleID value:bunldID block:^(BOOL hasNew, GJVersionInfo *version) {
        if (block) {
            block(hasNew, version);
        }else{
            [self showNewVersionAlertWithVersion:version];
        }
    }];
}


-(NSString *)currentVersion
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

-(NSString *)currentBundleID
{
    return [[NSBundle mainBundle] bundleIdentifier];
}

-(UIWindow *)window{
    
    UIWindow *window = nil;
    id<UIApplicationDelegate> delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate respondsToSelector:@selector(window)]) {
        window = [delegate performSelector:@selector(window)];
    } else {
        window = [[UIApplication sharedApplication] keyWindow];
    }
    return window;
}

-(void)showNewVersionAlertWithVersion:(GJVersionInfo *)info
{
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:self.alertCancel style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *handler = [UIAlertAction actionWithTitle:self.alertSure style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self openInAppStoreForAppURL:info.trackViewUrl];
    }];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:self.alertTitle message:self.alertMsg preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:cancel];
    [alert addAction:handler];
    
    [[self window].rootViewController presentViewController:alert animated:YES completion:nil];
}

//#pragma mark OpenUrl Store
//- (void)openInStoreProductViewControllerForAppId:(NSString *)appId{
//
//    SKStoreProductViewController *storeProductVC = [[SKStoreProductViewController alloc] init];
//    NSDictionary *dict = [NSDictionary dictionaryWithObject:appId forKey:SKStoreProductParameterITunesItemIdentifier];
//    storeProductVC.delegate = self;
//    [storeProductVC loadProductWithParameters:dict completionBlock:^(BOOL result, NSError *error) {
//        if (result) {
//            [[self window].rootViewController presentViewController:storeProductVC animated:YES completion:nil];
//        }
//    }];
//
//}
//- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController
//{
//    [viewController dismissViewControllerAnimated:YES completion:nil];
//}

-(void)openInAppStoreForAppURL:(NSString *)appURL
{
    if (@available(iOS 10, *)) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appURL] options:@{} completionHandler:nil];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appURL]];
    }
}

#pragma mark - NSURLRequest
-(void)requestWithType:(GJRequestType)type value:(NSString *)value block:(NewVersionBlock)block
{
    NSString *urlString = @"http://itunes.apple.com/lookup?";
    if (type == GJRequestTypeAppID) {
        urlString = [urlString stringByAppendingString:@"id="];
    }else if (type == GJRequestTypeBundleID){
        urlString = [urlString stringByAppendingString:@"bundleId="];
    }
    urlString = [urlString stringByAppendingString:value];
    NSURL *url = [NSURL URLWithString:urlString];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSURLRequest * request = [NSURLRequest requestWithURL:url];
        NSURLSessionDataTask * dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (!error) {
                    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                    [self matchNewVersionInfo:dict block:block];
                }else{
                    if (block) {
                        block(NO, nil);
                    }
                }
            });
            
        }];
        [dataTask resume];
    });
}

-(void)matchNewVersionInfo:(NSDictionary *)dict block:(NewVersionBlock)block
{
    NSInteger resultCount = [[dict objectForKey:@"resultCount"] integerValue];
    if (resultCount == 1) {
        NSArray *results = [NSArray arrayWithArray:[dict objectForKey:@"results"]];
        if ([results isKindOfClass:[NSArray class]]) {
            NSDictionary *versionDict = [results firstObject];
            GJVersionInfo *version = [[GJVersionInfo alloc] initWithDict:versionDict];
            
            BOOL new = [[self currentVersion] compare:version.version options:NSNumericSearch] == NSOrderedAscending;
            if (block) {
                block(new, version);
            }
        }else{
            if (block) {
                block(NO, nil);
            }
        }
    }else{
        if (block) {
            block(NO, nil);
        }
    }
}

@end
