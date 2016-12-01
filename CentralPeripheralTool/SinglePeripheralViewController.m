//
//  SinglePeripheralViewController.m
//  CentralPeripheralTool
//
//  Created by LiuMingchuan on 2016/11/29.
//  Copyright © 2016年 LiuMingchuan. All rights reserved.
//

#import "SinglePeripheralViewController.h"
#import "SingleCharacteristicViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface SinglePeripheralViewController ()<UITableViewDelegate,UITableViewDataSource,CBPeripheralDelegate> {
    NSMutableArray *services;
}
@property (strong, nonatomic) IBOutlet UITableView *singlePeripheralTV;
@property (strong, nonatomic) IBOutlet UITextView *logTxtV;
@property (strong, nonatomic) CBPeripheral *singlePeripheral;

@end

@implementation SinglePeripheralViewController

-(instancetype)initWithPeripheral:(CBPeripheral *)peripheral {
    self = [super init];
    _singlePeripheral = peripheral;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:_singlePeripheral.name];
    
    services = [NSMutableArray array];
    
    _singlePeripheral.delegate = self;
    [_singlePeripheral discoverServices:nil];
    
    _singlePeripheralTV.delegate = self;
    _singlePeripheralTV.dataSource = self;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    CBService *service = (CBService *)[services objectAtIndex:section];
    [self showLogMsg:[NSString stringWithFormat:@"%ld",[service.characteristics count]]];
    return [service.characteristics count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [services count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return ((CBService *)[services objectAtIndex:section]).UUID.UUIDString;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *identifer = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifer];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifer];
    }
    CBService *service = (CBService *)[services objectAtIndex:indexPath.section];
    CBCharacteristic *characteristic = (CBCharacteristic *)[service.characteristics objectAtIndex:indexPath.row];
    cell.textLabel.text = characteristic.UUID.UUIDString;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CBService *service = (CBService *)[services objectAtIndex:indexPath.section];
    CBCharacteristic *characteristic = (CBCharacteristic *)[service.characteristics objectAtIndex:indexPath.row];
    SingleCharacteristicViewController *singleCharacteristicVC = [[SingleCharacteristicViewController alloc]initWithPeripheral:_singlePeripheral characteristic:characteristic];
    [self.navigationController pushViewController:singleCharacteristicVC animated:YES];
}

#pragma mark - 搜索周边设备
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    for (CBService *service in peripheral.services) {
        if ([services count]==0) {
            [services addObject:service];
            [peripheral discoverCharacteristics:nil forService:service];
        } else {
            if (![self containsService:service]) {
                [services addObject:service];
                [peripheral discoverCharacteristics:nil forService:service];
            }
        }
    }
}

#pragma mark - 是否已经保存服务
- (Boolean)containsService:(CBService *)service {
    for (CBService *single in services) {
        if ([single.UUID.UUIDString isEqualToString:service.UUID.UUIDString]) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - 有新的特征，更新列表
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    [_singlePeripheralTV reloadData];
}

-(void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
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
