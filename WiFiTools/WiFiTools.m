//
//  WiFiTools.m
//  WiFiTools
//
//  Created by Qianlishun on 2022/3/31.
//

#import "WiFiTools.h"

@interface WiFiTools()
@end

@implementation WiFiTools

+ (NSString *)currentNetworkSSID{
    CWInterface* wifi = [[CWWiFiClient sharedWiFiClient] interface];
    return wifi.ssid;
}

+ (NSArray<CWNetwork *> *)scanResults{
    
//    NSString *pingHost = @"www.baidu.com";
//    SCNetworkConnectionFlags flags = 0;

//    if (pingHost && [pingHost length] > 0) {
//        flags = 0;
//        BOOL found = NO;
//        //判断当前网络连接
//        SCNetworkReachabilityRef reachabilityRef = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, [pingHost UTF8String]);
//        if (reachabilityRef) {
//            found = SCNetworkReachabilityGetFlags(reachabilityRef, &flags)
//            &&  (flags & kSCNetworkFlagsReachable)
//            && !(flags & kSCNetworkFlagsConnectionRequired);
//            CFRelease(reachabilityRef);
//            reachabilityRef = NULL;
//        }
//
//        if (found) {

            NSLog(@"Connection established");

            NSLog(@"\n\n----- CWInterface \n\n");
            CWInterface* wifi = [[CWWiFiClient sharedWiFiClient] interface];
            
            if(!wifi)
                return nil;
            
            NSLog(@"interfaceNames : %@",[CWWiFiClient interfaceNames]);
            
            NSLog(@"interfaceName: %@", wifi.interfaceName); //BSD if name: en1
            NSLog(@"powerOn: %d", wifi.powerOn);
            NSLog(@"ssid: %@", wifi.ssid);
            NSLog(@"bssid: %@", wifi.bssid);
            NSLog(@"rssiValue: %ld", wifi.rssiValue);
            NSLog(@"noiseMeasurement: %ld", wifi.noiseMeasurement);
            NSLog(@"transmitRate: %f", wifi.transmitRate);
            NSLog(@"countryCode: %@", wifi.countryCode);
            NSLog(@"interfaceMode: %ld", wifi.interfaceMode);
            NSLog(@"transmitPower: %ld", wifi.transmitPower);
            NSLog(@"hardwareAddress: %@", wifi.hardwareAddress);
            NSLog(@"serviceActive: %d", wifi.serviceActive);
            NSLog(@"security: %ld", wifi.security);
            NSLog(@"\n\n----- CWChannel \n");
            CWChannel *channel = wifi.wlanChannel;
            NSLog(@"channel: %@",channel);
            NSLog(@"channelNumber: %ld",channel.channelNumber);
            NSLog(@"channelWidth: %ld",channel.channelWidth);
            NSLog(@"channelBand: %ld ",channel.channelBand);

                NSLog(@"\n\n----- CWConfiguration \n");
            CWConfiguration *config = wifi.configuration;
            NSLog(@"config: %@",config);
            NSLog(@"requireAdministratorForAssociation: %d",config.requireAdministratorForAssociation);
            NSLog(@"requireAdministratorForPower: %d",config.requireAdministratorForPower);
            NSLog(@"requireAdministratorForIBSSMode: %d",config.requireAdministratorForIBSSMode);
            NSLog(@"rememberJoinedNetworks: %d ",config.rememberJoinedNetworks);

            NSLog(@"\n\n----- CWNetworkProfile \n");
            
            NSLog(@"cachedScanResults: %@ \n", wifi.cachedScanResults);

            
            return [wifi.cachedScanResults allObjects];
//        }
        
//    }
//    return nil;
}

+ (NSArray<CWNetworkProfile *> *)readNetworkProfiles{
    CWInterface* wifi = [[CWWiFiClient sharedWiFiClient] interface];
    if(wifi){
        return [wifi.configuration.networkProfiles array];
    }
    return nil;
}

+ (void)callCommandline{
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport"];
    [task setArguments:[NSArray arrayWithObjects:@"-s",nil]];
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput:pipe];
    [task setStandardError:pipe];
    NSFileHandle *handle = [pipe fileHandleForReading];
    [task launch];
    [task waitUntilExit];

    NSData *data = [handle readDataToEndOfFile];
    NSLog(@"airport %@",[[NSString alloc] initWithData:data encoding:kCFStringEncodingUTF8]);
    
//    NSTask *certTask = [[NSTask alloc] init];
//        [certTask setLaunchPath:@"/usr/bin/security"];
//        [certTask setArguments:[NSArray arrayWithObjects:@"find-identity", @"-v", @"-p", @"codesigning", nil]];
//        NSPipe *pipe = [NSPipe pipe];
//        [certTask setStandardOutput:pipe];
//        [certTask setStandardError:pipe];
//        NSFileHandle *handle = [pipe fileHandleForReading];
//        [certTask launch];
//
//       NSData  *data = [handle readDataToEndOfFile];
//        NSLog(@"airport %@",[[NSString alloc] initWithData:data encoding:kCFStringEncodingUTF8]);

}


+ (int)rssi2quality:(int)rssi{
    if(rssi < 0){
        rssi = MAX(rssi, -100);
        rssi = MIN(rssi, -50);
        
        return 2 * (rssi + 100);
    }
    return 0;
}
@end
