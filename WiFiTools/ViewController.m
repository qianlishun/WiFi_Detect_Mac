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

@interface ViewController()<NSTableViewDelegate,NSTableViewDataSource,WiFiToolsDelegate>
@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSButton *refreshButton;

@property(nonatomic, strong) WiFiTools *wifiTools;
@property(nonatomic, strong) NSArray<QNetWork*> *networks;

@property(nonatomic, strong) NSMutableDictionary *sortAscendings;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.wifiTools = [WiFiTools new];
    [self.wifiTools setDelegate:self];
}

- (void)viewWillAppear{
    [super viewWillAppear];
    self.view.window.restorable = NO;
    [self.view.window setContentSize:NSMakeSize(800, 480)];
    
}

- (void)viewDidAppear{
    [super viewDidAppear];
 
    [self onRefresh:nil];
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (IBAction)onRefresh:(id)sender {
    [_wifiTools scanNetwork];
}

- (void)wifiToolsDidDiscoverNetworks:(NSArray<QNetWork *> *)results{
    self.networks = results;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

#pragma mark - Table
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return self.networks.count;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row{
    return 50;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    QNetWork *model = self.networks[row];
    
    if([tableColumn.identifier isEqualToString:@"SSIDColumn"]){
        NSTableCellView *cell = [tableView makeViewWithIdentifier:@"SSIDCell" owner:self];
        cell.textField.stringValue = model.ssid;
        if([_wifiTools.currentNetwork.ssid isEqualToString:model.ssid]){
            cell.textField.textColor = [NSColor colorWithSRGBRed:0.2 green:0.9 blue:0.2 alpha:1.0];
        }else{
            cell.textField.textColor = [NSColor colorWithWhite:0.9 alpha:1.0];
        }
        return cell;
    }else if([tableColumn.identifier isEqualToString:@"RSSIColumn"]){
        NSTableCellView *cell = [tableView makeViewWithIdentifier:@"RSSICell" owner:self];
        
        NSString *imageName = @"NSStatusNone";
        if(model.qualityLevel == 3){
            imageName = @"NSStatusAvailable";
        }else if(model.qualityLevel == 2){
            imageName = @"NSStatusPartiallyAvailable";
        }else if(model.qualityLevel == 1){
            imageName = @"NSStatusUnavailable";
        }
        
        cell.textField.stringValue = model.qualityDescribe;
        NSImage *image = [NSImage imageNamed:imageName];
        cell.imageView.image = image;
        
        return cell;
    }else if([tableColumn.identifier isEqualToString:@"ChannelColumn"]){
        NSTableCellView *cell = [tableView makeViewWithIdentifier:@"ChannelCell" owner:self];

        cell.textField.stringValue = model.channelDescribe;
        
        return cell;
    }else if([tableColumn.identifier isEqualToString:@"SecurityColumn"]){
        NSTableCellView *cell = [tableView makeViewWithIdentifier:@"SecurityCell" owner:self];

        cell.textField.stringValue = model.securityDescribe;
        
        return cell;
    }
    
    return nil;
}

- (void)tableView:(NSTableView *)tableView didClickTableColumn:(NSTableColumn *)tableColumn{
    NSLog(@"%s %@",__func__,tableColumn.identifier);
    
    NSString *key = @"";
    
    NSSortDescriptor *sortDescripttor;
    if([tableColumn.identifier isEqualToString:@"SSIDColumn"]){
        key = @"ssid";
    }else if([tableColumn.identifier isEqualToString:@"RSSIColumn"]){
        key = @"rssiValue";
    }else if([tableColumn.identifier isEqualToString:@"ChannelColumn"]){
        key = @"channel";
    }else if([tableColumn.identifier isEqualToString:@"SecurityColumn"]){
        key = @"securityDescribe";
    }
    
    BOOL ascending = ![[self.sortAscendings objectForKey:key] boolValue];
    sortDescripttor = [NSSortDescriptor sortDescriptorWithKey:key ascending:ascending];

    if(sortDescripttor){
        self.networks = [self.networks sortedArrayUsingDescriptors:@[sortDescripttor]];
        [self.tableView reloadData];
    }
    
    [self.sortAscendings setObject:[NSNumber numberWithBool:ascending] forKey:key];
}

- (NSMutableDictionary *)sortAscendings{
    if(!_sortAscendings){
        _sortAscendings = [NSMutableDictionary dictionaryWithDictionary: @{
            @"ssid": @YES,
            @"rssiValue": @YES,
            @"channel" : @YES,
            @"securityDescribe": @YES
        }];
        
    }
    return _sortAscendings;
}
@end
