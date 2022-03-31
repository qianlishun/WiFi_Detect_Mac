//
//  ViewController.m
//  WiFiTools
//
//  Created by Qianlishun on 2022/3/31.
//
//#define showPrint(FORMAT, ...) [self appendText2View:[NSString stringWithFormat:FORMAT, ##__VA_ARGS__]]

//#define MyNSLog(FORMAT, ...) fprintf(stderr,"[%s]:[line %d行] %s\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);

#import "ViewController.h"
#import "WiFiTools.h"

@interface ViewController()<NSTableViewDelegate,NSTableViewDataSource>
@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSButton *refreshButton;
@property(nonatomic, strong) NSArray<CWNetwork*> *networks;
@property(nonatomic, strong) NSString *currentConnSSID;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
}

- (void)viewWillAppear{
    [super viewWillAppear];
    self.view.window.restorable = NO;
    [self.view.window setContentSize:NSMakeSize(640, 480)];
    
}

- (void)viewDidAppear{
    [super viewDidAppear];
 
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (IBAction)onRefresh:(id)sender {
//    [WiFiTools callCommandline];
    self.networks = [WiFiTools scanResults];
    self.currentConnSSID = [WiFiTools currentNetworkSSID];
    
    CWNetwork *currentNet = nil;
    for (CWNetwork *net in self.networks ) {
        if([self.currentConnSSID isEqualToString:net.ssid]){
            currentNet = net;
            break;
        }
    }
    if(currentNet){
        NSMutableArray *array = [NSMutableArray arrayWithArray:self.networks];
        [array removeObject:currentNet];
        [array insertObject:currentNet atIndex:0];
        self.networks = array.copy;
    }
    
    [self.tableView reloadData];

}

#pragma mark - Table
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return self.networks.count;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row{
    return 50;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    CWNetwork *model = self.networks[row];
    
    if([tableColumn.identifier isEqualToString:@"SSIDColumn"]){
        NSTableCellView *cell = [tableView makeViewWithIdentifier:@"SSIDCell" owner:self];
        cell.textField.stringValue = model.ssid;
        if([self.currentConnSSID isEqualToString:model.ssid]){
            cell.textField.textColor = [NSColor colorWithSRGBRed:0.2 green:0.9 blue:0.2 alpha:1.0];
        }else{
            cell.textField.textColor = [NSColor colorWithWhite:0.9 alpha:1.0];
        }
        return cell;
    }else if([tableColumn.identifier isEqualToString:@"RSSIColumn"]){
        NSTableCellView *cell = [tableView makeViewWithIdentifier:@"RSSICell" owner:self];
        NSInteger rssi = model.rssiValue;
        
        int quality = [WiFiTools rssi2quality:(int)rssi];
        NSString *imageName = @"NSStatusNone";
        if(quality >= 80){
            imageName = @"NSStatusAvailable";
        }else if(quality >= 50){
            imageName = @"NSStatusPartiallyAvailable";
        }else if(quality >= 20){
            imageName = @"NSStatusUnavailable";
        }
        
        cell.textField.stringValue = [NSString stringWithFormat:@"%d%%(%ld)",quality,rssi];
        NSImage *image = [NSImage imageNamed:imageName];
        cell.imageView.image = image;
        
        return cell;
    }else if([tableColumn.identifier isEqualToString:@"OtherColumn"]){
        NSTableCellView *cell = [tableView makeViewWithIdentifier:@"OtherCell" owner:self];

        NSString *modelStr = [NSString stringWithFormat:@"%@", model];
        
        NSRange range1 = [modelStr rangeOfString:@"security="];
        NSRange range2 = [modelStr rangeOfString:@"rssi="];
        NSString *security = [modelStr substringWithRange:NSMakeRange(range1.location+range1.length, range2.location-range1.location-range1.length)];
        
        range1 = [modelStr rangeOfString:@"channelNumber="];
        range2 = [modelStr rangeOfString:@"channelWidth="];
        NSString *channelNumber = [modelStr substringWithRange:NSMakeRange(range1.location+range1.length, range2.location-range1.location-range1.length)];

        range1 = [modelStr rangeOfString:@"channelWidth="];
        range2 = [modelStr rangeOfString:@"], ibss="];
        NSString *channelWidth = [modelStr substringWithRange:NSMakeRange(range1.location+range1.length, range2.location-range1.location-range1.length)];

        cell.textField.stringValue = [NSString stringWithFormat:@"%@ %@ %@",security,channelNumber,channelWidth];
        
        return cell;
    }
    
    return nil;
}


@end
