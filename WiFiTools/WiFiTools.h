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

@interface WiFiTools : NSObject

+ (NSArray<CWNetwork *>*)scanResults;

+ (NSArray<CWNetworkProfile*>*)readNetworkProfiles;

+ (NSString*)currentNetworkSSID;

+ (int)rssi2quality:(int)rssi;

+ (void)callCommandline;
@end

NS_ASSUME_NONNULL_END
