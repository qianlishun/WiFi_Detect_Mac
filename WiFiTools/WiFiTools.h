//
//  WiFiTools.h
//  WiFiTools
//
//  Created by Qianlishun on 2022/3/31.
//

#import <Cocoa/Cocoa.h>
#import <CoreWLAN/CoreWLAN.h>
#import <SystemConfiguration/SystemConfiguration.h>

NS_ASSUME_NONNULL_BEGIN

@interface QNetWork : NSObject
@property(nonatomic, copy)      NSString*    ssid;
@property(nonatomic, copy)      NSString*    bssid;
@property(nonatomic, assign)    NSInteger    rssiValue;
@property(nonatomic, assign)    NSInteger    qualityLevel;
@property(nonatomic, copy)      NSString*    qualityDescribe;

@property(nonatomic, copy)      NSString*    securityDescribe;
@property(nonatomic, assign)    NSInteger    channel;
@property(nonatomic, copy)      NSString*    channelDescribe;

+ (instancetype)initWith:(CWNetwork*)cw;
@end


@protocol WiFiToolsDelegate <NSObject>
- (void)wifiToolsDidDiscoverNetworks:(NSArray<QNetWork *>*)results;
@end

@interface WiFiTools : NSObject

- (void)setDelegate:(id<WiFiToolsDelegate>)delegate;

- (void)scanNetwork;

- (QNetWork*)currentNetwork;

- (NSArray<CWNetworkProfile*>*)readNetworkProfiles;

@end

NS_ASSUME_NONNULL_END
