//
//  ViewController.m
//  GJAppVersion
//
//  Created by gejiangs on 2019/4/24.
//  Copyright © 2019 gejiangs. All rights reserved.
//

#import "ViewController.h"
#import "GJAppVersion.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self checkNewVersion];
}

-(void)checkNewVersion
{
    [[GJAppVersion manager] checkNewVesionWithBunldID:@"com.dacheng.OBDPlus" block:^(BOOL hasNew, GJVersionInfo * _Nonnull version) {
        NSLog(@"hasNew:%@", hasNew ? @"1" : @"0");
    }];
}


@end
