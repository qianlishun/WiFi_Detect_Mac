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

@property(nonatomic, strong) WiFiTools *wifiTools;
@property(nonatomic, strong) NSArray<QNetWork*> *networks;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.wifiTools = [WiFiTools new];
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
    [WiFiTools callAirport:^(NSString * _Nonnull result) {
        NSLog(@"result");
    }];
    
    return;
    __weak __typeof(self)weakSelf = self;
    [_wifiTools scanResults:^(NSArray<QNetWork *> * _Nonnull results) {
        weakSelf.networks = results;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
    
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
    }
    
    return nil;
}


@end
