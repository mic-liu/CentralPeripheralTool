//
//  CentralViewController.m
//  CentralPeripheralTool
//
//  Created by LiuMingchuan on 2016/11/29.
//  Copyright © 2016年 LiuMingchuan. All rights reserved.
//

#import "CentralViewController.h"
#import "SinglePeripheralViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface CentralViewController ()<UITableViewDelegate,UITableViewDataSource,CBCentralManagerDelegate,CBPeripheralDelegate>{
    NSMutableArray *peripherals;
    
}

@property (strong, nonatomic) IBOutlet UITableView *peripheralsTV;
@property (strong, nonatomic) IBOutlet UITextView *logTxtV;
@property (strong, nonatomic)  CBCentralManager *centralManager;

@end

@implementation CentralViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:@"Central"];
    
    _peripheralsTV.delegate = self;
    _peripheralsTV.dataSource = self;
    
    peripherals = [NSMutableArray array];
    
    //调整因版本问题出现的导航遮挡视图
    if ([[UIDevice currentDevice]systemVersion].doubleValue>7.0) {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
        [self.navigationController.navigationBar setTranslucent:NO];
    }
    
    _centralManager = [[CBCentralManager alloc]initWithDelegate:self queue:nil options:@{CBCentralManagerOptionRestoreIdentifierKey:@"Ryoma"}];
    _centralManager.delegate = self;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"ClearLog" style:UIBarButtonItemStylePlain target:self action:@selector(clearLog)];
    
}

#pragma mark - 清空记录
- (void)clearLog {
    _logTxtV.text = @"";
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [peripherals count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifer = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifer];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifer];
    }
    cell.textLabel.text = ((CBPeripheral *)[peripherals objectAtIndex:indexPath.row]).name;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CBPeripheral *peripheral = [peripherals objectAtIndex:indexPath.row];
    switch (peripheral.state) {
        case CBPeripheralStateConnected:
        {
            [self showLogMsg:[NSString stringWithFormat:@"%@已经连接",peripheral.name]];
            SinglePeripheralViewController *singlePeripheralVC = [[SinglePeripheralViewController alloc]initWithPeripheral:peripheral];
            [self.navigationController pushViewController:singlePeripheralVC animated:YES];
            break;
        }
        case CBPeripheralStateDisconnected:
        {
            [_centralManager connectPeripheral:peripheral options:nil];
            [self showLogMsg:[NSString stringWithFormat:@"%@正在连接。。。。。。",peripheral.name]];
            break;
        }
        default:
            break;
    }
}

#pragma mark - 是否连接了周边设备
-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    [self showLogMsg:[NSString stringWithFormat:@"%@连接成功",peripheral.name]];
    SinglePeripheralViewController *singlePeripheralVC = [[SinglePeripheralViewController alloc]initWithPeripheral:peripheral];
    [self.navigationController pushViewController:singlePeripheralVC animated:YES];
}

#pragma mark - 是否断开了周边设备
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    [self showLogMsg:[NSString stringWithFormat:@"%@断开连接",peripheral.name]];
    [peripherals removeObject:peripheral];
    [_peripheralsTV reloadData];
}

#pragma mark - 连接周边设备失败
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    [self showLogMsg:[NSString stringWithFormat:@"%@连接失败",peripheral.name]];
    [peripherals removeObject:peripheral];
    [_peripheralsTV reloadData];
}

#pragma mark - 中心设备状态监测
-(void)centralManagerDidUpdateState:(CBCentralManager *)central {
    switch (central.state) {
        case CBManagerStatePoweredOn:
            [_centralManager scanForPeripheralsWithServices:nil options:nil];
            break;
            
        case CBManagerStatePoweredOff:
            [self showLogMsg:@"蓝牙未打开"];
            break;
            
        default:
            [self showLogMsg:@"设备不支持BLE"];
            break;
    }
}

#pragma mark - 检测到周边设备
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    if (![peripherals containsObject:peripheral]) {
        [peripherals addObject:peripheral];
        [self showLogMsg:[NSString stringWithFormat:@"检索到周边%@",[peripheral name]]];
        [_peripheralsTV reloadData];
    }
}

#pragma mark - 状态保存和恢复
-(void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary<NSString *,id> *)dict {
    //central提供信息，dict包含了应用程序关闭是系统保存的central的信息，用dic去恢复central
    //app状态的保存或者恢复，这是第一个被调用的方法当APP进入后台去完成一些蓝牙有关的工作设置，使用这个方法同步app状态通过蓝牙系统
}

#pragma mark - Log信息显示
- (void)showLogMsg:(NSString *)logMsg {
    if ([@"" isEqualToString:_logTxtV.text]) {
        _logTxtV.text = [NSString stringWithFormat:@">>%@",logMsg];
    } else {
        _logTxtV.text = [NSString stringWithFormat:@"%@\n>>%@",_logTxtV.text,logMsg];
    }
    [_logTxtV scrollRangeToVisible:NSMakeRange(_logTxtV.text.length, 1)];
    _logTxtV.layoutManager.allowsNonContiguousLayout = NO;
}

#pragma mark - other
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
