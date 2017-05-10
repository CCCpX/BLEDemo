//
//  ViewController.m
//  KPBLEDemo
//
//  Created by CPX on 08/05/2017.
//  Copyright © 2017 KaoPuJinFu. All rights reserved.
//

#import "ViewController.h"
#import "KPHandheldManager.h"
#import "KPHandheldDevice.h"

@interface ViewController ()<KPHandheldManagerDelegate, KPHandheldDeviceDelegate, UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (nonatomic, strong) KPHandheldManager *handheldManager;
@property (nonatomic, strong) KPHandheldDevice *handheldDevice;
@property (nonatomic, strong) NSMutableArray<KPHandheldDevice *> *foundDevices;
@end

static NSString * const cellReuseIdentifier = @"cellReuseIdentifier";

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.handheldManager = [[KPHandheldManager alloc] initWithDelegate:self];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.foundDevices = [NSMutableArray array];
    self.textView.text = @"";
}

- (IBAction)searchPeripheralAction:(UIBarButtonItem *)sender {
    NSError *error;
    [self.handheldManager startScan_error:&error];
    if (error) {
        KPLog(@"error while search:%@",error.description);
        [self writeToLog:error.description];
        return;
    }
}
- (IBAction)sendDataAction:(UIBarButtonItem *)sender {
    NSString *dataString = @"S04;00000000;067;E04;";
    NSData *data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    [self.handheldDevice sendSerialData:data];
}

- (IBAction)disconnectPeripheralAction:(UIBarButtonItem *)sender {
    NSError *error;
    [self.handheldManager disconnectFromAllHandheld:&error];
    if (error) {
        KPLog(@"error while disconnect:%@",error.description);
        [self writeToLog:error.description];
        return;
    }
}

#pragma mark - KPHandheldManagerDelegate
- (void)handheldManagerDidUpdateState:(KPHandheldManager *)hhManager {
    [self writeToLog:[NSString stringWithFormat:@"%s",__PRETTY_FUNCTION__]];
}
- (void)handheldManager:(KPHandheldManager *)hhManager didDiscoverHandheld:(KPHandheldDevice *)handheld error:(NSError*)error{
//    [self writeToLog:[NSString stringWithFormat:@"%s",__PRETTY_FUNCTION__]];
    [self.foundDevices addObject:handheld];
    [self.tableView reloadData];
}
- (void)handheldManager:(KPHandheldManager *)hhManager didConnectHandheld:(KPHandheldDevice *)handheld error:(NSError *)error {
    self.handheldDevice = handheld;
    [self writeToLog:[NSString stringWithFormat:@"%s",__PRETTY_FUNCTION__]];
}
- (void)handheldManager:(KPHandheldManager *)hhManager didDisconnectHandheld:(KPHandheldDevice *)handheld error:(NSError *)error {
    [self writeToLog:[NSString stringWithFormat:@"%s",__PRETTY_FUNCTION__]];
}

#pragma mark - KPHandheldDeviceDelegate
- (void)handheld:(KPHandheldDevice *)device receiveSerialData:(NSData *)data {
    KPLog(@"接收到数据:%@",data);
}

- (void)writeToLog:(NSString *)log {
    self.textView.text = [NSString stringWithFormat:@"%@\r\n%@",self.textView.text,log];
    if(self.textView.text.length > 0 ) {
        NSRange bottom = NSMakeRange(self.textView.text.length -1, 1);
        [self.textView scrollRangeToVisible:bottom];
    }
}

#pragma mark - UITableViewDelegate&DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.foundDevices.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier forIndexPath:indexPath];
    KPHandheldDevice *device = self.foundDevices[indexPath.row];
    cell.textLabel.text = device.name;
    cell.detailTextLabel.text = device.identifier.UUIDString;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    KPHandheldDevice *selectedDevice = self.foundDevices[indexPath.row];
    NSError *error = nil;
    [self.handheldManager connectToHandheld:selectedDevice error:&error];
    if (error) {
        KPLog(@"error while search:%@",error.description);
        [self writeToLog:error.description];
        return;
    }
}

@end
