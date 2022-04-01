//
//  WiFiTools.m
//  WiFiTools
//
//  Created by Qianlishun on 2022/3/31.
//

#import "WiFiTools.h"

@interface WiFiTools()
@property(nonatomic, strong) QNetWork *theCurrentNetwork;
@end

@implementation WiFiTools

- (QNetWork *)currentNetwork{
    return self.theCurrentNetwork;
}

- (void)scanResults:(void (^)(NSArray<QNetWork *>* results))block{

    NSLog(@"Connection established");

    NSLog(@"\n\n----- CWInterface \n\n");
    CWInterface* wifi = [[CWWiFiClient sharedWiFiClient] interface];
    
    if(!wifi)
        return;
    
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
    
    NSMutableArray *array = [NSMutableArray array];
    
    NSMutableSet *cachedResults = [NSMutableSet setWithSet: wifi.cachedScanResults];
        
    for (CWNetwork *net in cachedResults ) {
        QNetWork *qnet = [QNetWork initWith:net];
 
        if([wifi.ssid isEqualToString:net.ssid] ){ //}&& [wifi.wlanChannel isEqualToChannel:net.wlanChannel]){
            self.theCurrentNetwork = qnet;
        }
        
        [array addObject:qnet];
    }
    if(self.theCurrentNetwork){
        [array removeObject:self.theCurrentNetwork];
        [array insertObject:self.theCurrentNetwork atIndex:0];
    }

    block(array);
}

- (NSArray<CWNetworkProfile *> *)readNetworkProfiles{
    CWInterface* wifi = [[CWWiFiClient sharedWiFiClient] interface];
    if(wifi){
        return [wifi.configuration.networkProfiles array];
    }
    return nil;
}

+ (void)callAirport:(void (^)(NSString * _Nonnull))block{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND,0), ^{
        NSString* result = [WiFiTools callCommandline:@"/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -s"];
        block(result);
    });
}

+ (NSString*)callCommandline:(NSString*)cmd{
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath: @"/bin/bash"];
    NSArray *arguments = [NSArray arrayWithObjects: @"-c", cmd, nil];
    [task setArguments: arguments];
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput:pipe];
    [task setStandardError:pipe];
    
    NSFileHandle *handle = [pipe fileHandleForReading];
    [handle waitForDataInBackgroundAndNotify];
    [task launch];
    [task waitUntilExit];

    NSData *data = [handle readDataToEndOfFile];
    NSString *outputString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

//    NSLog(@"cmd output %@",outputString);
    return outputString;
}

+ (int)rssi2quality:(NSInteger)rssi{
    if(rssi < 0){
        rssi = MAX(rssi, -100);
        rssi = MIN(rssi, -50);
        
        return 2 * ((int)rssi + 100);
    }
    return 0;
}

+ (int)qualityLevelWith:(int)quality{
    if(quality >= 80){
        return 3;
    }else if(quality >= 50){
        return 2;
    }else if(quality >= 20){
        return 1;
    }
    return 0;
}
@end

@implementation QNetWork

+ (instancetype)initWith:(CWNetwork*)cw{
    
    QNetWork *network = [QNetWork new];
    network.ssid = cw.ssid;
    network.bssid = cw.bssid;
    network.rssiValue = cw.rssiValue;
    int quality = [WiFiTools rssi2quality:cw.rssiValue];
    network.qualityDescribe = [NSString stringWithFormat:@"%d(%ld)",quality,network.rssiValue];
    network.qualityLevel = [WiFiTools qualityLevelWith:quality];
    
    CWChannel *wlanChannel = [cw wlanChannel];
    network.channel = wlanChannel.channelNumber;
    NSString *channelDescribe = [NSString stringWithFormat:@"%@",wlanChannel];
    channelDescribe = [channelDescribe componentsSeparatedByString:@">"].lastObject;
    channelDescribe = [channelDescribe stringByReplacingOccurrencesOfString:@"channelNumber=" withString:@""];
    channelDescribe = [channelDescribe stringByReplacingOccurrencesOfString:@"channelWidth=" withString:@""];
    channelDescribe = [channelDescribe stringByReplacingOccurrencesOfString:@" " withString:@""] ;
    NSCharacterSet *character = [NSCharacterSet characterSetWithCharactersInString:@"[]{}"];
    NSArray *array = [channelDescribe componentsSeparatedByCharactersInSet:character];
    channelDescribe = [array componentsJoinedByString:@""];
    network.channelDescribe = channelDescribe;
    
    return network;
}

@end
