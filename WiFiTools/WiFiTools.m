//
//  WiFiTools.m
//  WiFiTools
//
//  Created by Qianlishun on 2022/3/31.
//

#import "WiFiTools.h"

@interface QNetWork()
@property(nonatomic, strong) CWChannel *wlanChannel;
@end

@interface WiFiTools()
@property(nonatomic, weak) id<WiFiToolsDelegate> theDelegate;
@property(nonatomic, strong) QNetWork *theCurrentNetwork;
@end

@implementation WiFiTools

- (void)setDelegate:(id)delegate{
    _theDelegate = delegate;
}

- (QNetWork *)currentNetwork{
    return self.theCurrentNetwork;
}

- (void)scanNetwork{

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
        
        if([wifi.ssid isEqualToString:net.ssid]){// && [wifi.wlanChannel isEqualToChannel:net.wlanChannel]){
            self.theCurrentNetwork = qnet;
        }
        
        [array addObject:qnet];
    }
    if(self.theCurrentNetwork){
        [array removeObject:self.theCurrentNetwork];
        [array insertObject:self.theCurrentNetwork atIndex:0];
    }

    if(_theDelegate && [_theDelegate respondsToSelector:@selector(wifiToolsDidDiscoverNetworks:)]){
        [_theDelegate wifiToolsDidDiscoverNetworks:array];
    }
        
    __weak typeof(_theDelegate) weakDelegate = _theDelegate;
    [self callAirport:^(NSString * _Nonnull result) {

        NSDictionary *securityDict = [WiFiTools analysisAirportPrint:result];
        
        for (QNetWork *qnet in array) {
            if(qnet.ssid.length >0 && [securityDict.allKeys containsObject:qnet.ssid]){
                qnet.securityDescribe = [securityDict objectForKey:qnet.ssid];
            }
        }
        
        if(weakDelegate && [weakDelegate respondsToSelector:@selector(wifiToolsDidDiscoverNetworks:)]){
            [weakDelegate wifiToolsDidDiscoverNetworks:array];
        }
        
    }];
}

- (NSArray<CWNetworkProfile *> *)readNetworkProfiles{
    CWInterface* wifi = [[CWWiFiClient sharedWiFiClient] interface];
    if(wifi){
        return [wifi.configuration.networkProfiles array];
    }
    return nil;
}

+ (NSDictionary*)analysisAirportPrint:(NSString*)result{
    NSMutableDictionary *securityDict = [NSMutableDictionary dictionary];
    
    if([result containsString:@"SECURITY (auth/unicast/group)"]){
        result = [result componentsSeparatedByString:@"SECURITY (auth/unicast/group)\n"].lastObject;
        result = [result stringByReplacingOccurrencesOfString:@"\n" withString:@"|n|"];

        // 把连续的空格替换成 "|t|"
        NSError *error = nil;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\s{2,}" options:NSRegularExpressionCaseInsensitive error:&error];
        NSArray *arr = [regex matchesInString:result options:NSMatchingReportCompletion range:NSMakeRange(0, result.length)];
        arr = [[arr reverseObjectEnumerator] allObjects];
        for (NSTextCheckingResult *str in arr) {
            result = [result stringByReplacingCharactersInRange:[str range] withString:@"|t|"];
        }
        // 按行分割
        NSArray *netItems = [result componentsSeparatedByString:@"|n|"];

        for (int i = 0; i < netItems.count; i++) {
            NSString *itemStr = netItems[i];
            NSArray *item = [itemStr componentsSeparatedByString:@"|t|"];
            NSString *ssid = @"";
            if([itemStr hasPrefix:@"|t|"] &&
               [item.firstObject isEqualToString:@""]){
                ssid = item[1];
            }else{
                ssid = item.firstObject;
            }
            NSString *security = @"";
            if([itemStr hasSuffix:@"|t|"] &&
               [item.lastObject isEqualToString:@""]){
                security = item[item.count-2];
            }else{
                security = item.lastObject;
            }
            if(ssid && security){
                security = [security stringByReplacingOccurrencesOfString:@"-- " withString:@""];
                [securityDict setObject:security forKey:ssid];
            }
        }
    }
    return securityDict.copy;
}

- (void)callAirport:(void (^)(NSString * _Nonnull))callback{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND,0), ^{
        [self callCommandline:@"/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -s" callback:^(NSString * _Nonnull result) {
            callback(result);
        }];
    });
}

- (void)callCommandline:(NSString*)cmd callback:(void (^)(NSString * _Nonnull))callback{
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath: @"/bin/bash"];
    NSArray *arguments = [NSArray arrayWithObjects: @"-c", cmd, nil];
    [task setArguments: arguments];
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput:pipe];
    [task setStandardError:pipe];
    
    NSFileHandle *handle = [pipe fileHandleForReading];
    [handle waitForDataInBackgroundAndNotify];
    
    NSMutableString *mString = [NSMutableString string];
    
    __block id obs1 = [[NSNotificationCenter defaultCenter] addObserverForName:NSFileHandleDataAvailableNotification object:handle queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        NSData *data = [handle availableData];
        if(data.length > 0){
            NSString *outputString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            [mString appendString:outputString];
            NSLog(@"## %@",outputString);
            [handle waitForDataInBackgroundAndNotify];
        }else{
            callback(mString.copy);
            [[NSNotificationCenter defaultCenter]  removeObserver:obs1];
        }
    }];
    

    [task launch];
    [task waitUntilExit];
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
    network.qualityDescribe = [NSString stringWithFormat:@"%d%%(%ld)",quality,network.rssiValue];
    network.qualityLevel = [WiFiTools qualityLevelWith:quality];
    
    CWChannel *wlanChannel = [cw wlanChannel];
    network.wlanChannel = wlanChannel;
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
    
    network.securityDescribe = @"";
    
    return network;
}

- (void)setSsid:(NSString *)ssid{
    if(!ssid)
        ssid = @"";
    _ssid = ssid;
}

- (void)setBssid:(NSString *)bssid{
    if(!bssid)
        bssid = @"";
    _bssid = bssid;
}

- (void)setChannelDescribe:(NSString *)channelDescribe{
    if(!channelDescribe)
        channelDescribe = @"";
    _channelDescribe = channelDescribe;
}

- (void)setQualityDescribe:(NSString *)qualityDescribe{
    if(!qualityDescribe)
        qualityDescribe = @"";
    _qualityDescribe = qualityDescribe;
}

- (void)setSecurityDescribe:(NSString *)securityDescribe{
    if(!securityDescribe)
        securityDescribe = @"";
    _securityDescribe = securityDescribe;
}
@end
