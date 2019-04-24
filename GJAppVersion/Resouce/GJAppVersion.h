//
//  GJAppVersion.h
//  GJAppVersion
//
//  Created by gejiangs on 2019/4/4.
//  Copyright © 2019 gejiangs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GJVersionInfo : NSObject

@property (nonatomic, copy)     NSString *version;              //新版本号
@property (nonatomic, copy)     NSString *trackId;              //AppStore ID
@property (nonatomic, copy)     NSString *bundleId;             //App BundleID
@property (nonatomic, copy)     NSString *trackViewUrl;         //AppStore下载地址
@property (nonatomic, copy)     NSString *appDescription;       //新版本描述提示

@end

typedef void(^NewVersionBlock)(BOOL hasNew, GJVersionInfo * __nullable versionInfo);

@interface GJAppVersion : NSObject

@property (nonatomic, copy)     NSString *alertTitle;       //弹出框标题
@property (nonatomic, copy)     NSString *alertMsg;         //弹出框内容
@property (nonatomic, copy)     NSString *alertCancel;      //弹出框取消标题
@property (nonatomic, copy)     NSString *alertSure;        //弹出框确定更新标题

+(instancetype)manager;


/**
 检查新版本
 */
-(void)checkNewVesion;

/**
 检查新版本

 @param block 返回是否有新版本
 */
-(void)checkNewVesion:(nullable NewVersionBlock)block;

/**
 根据AppID检测是否有新版本

 @param appID AppID(AppStore上获取)
 */
-(void)checkNewVesionWithAPPID:(NSString *)appID;

/**
 根据AppID检测是否有新版本
 
 @param appID AppID(AppStore上获取)
 @param block 返回是否有新版本
 */
-(void)checkNewVesionWithAPPID:(NSString *)appID block:(nullable NewVersionBlock)block;

/**
 根据工程Bundle identifier检测是否有新版本

 @param bunldID 工程Bundle identifier
 */
-(void)checkNewVesionWithBunldID:(NSString *)bunldID;

/**
 根据工程Bundle identifier检测是否有新版本
 
 @param bunldID 工程Bundle identifier
 @param block 返回是否有新版本
 */
-(void)checkNewVesionWithBunldID:(NSString *)bunldID block:(nullable NewVersionBlock)block;

@end

NS_ASSUME_NONNULL_END
