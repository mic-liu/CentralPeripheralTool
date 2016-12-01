//
//  SingleCharacteristicViewController.m
//  CentralPeripheralTool
//
//  Created by LiuMingchuan on 2016/11/30.
//  Copyright © 2016年 LiuMingchuan. All rights reserved.
//

#import "SingleCharacteristicViewController.h"

@interface SingleCharacteristicViewController ()<CBPeripheralDelegate>

@property (strong, nonatomic) CBPeripheral *singlePeripheral;
@property (strong, nonatomic) CBCharacteristic *singleCharacteristic;
@property (weak, nonatomic) IBOutlet UITextView *logTxtV;

@end

@implementation SingleCharacteristicViewController

-(instancetype)initWithPeripheral:(CBPeripheral *)peripheral characteristic:(CBCharacteristic *)characteristic {
    self = [super init];
    _singlePeripheral = peripheral;
    _singleCharacteristic = characteristic;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:_singleCharacteristic.UUID.UUIDString];
    
    _singlePeripheral.delegate = self;
    [_singlePeripheral setNotifyValue:YES forCharacteristic:_singleCharacteristic];
    // Do any additional setup after loading the view from its nib.
}

-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (characteristic.value) {
        NSString *value = [[NSString alloc]initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        [self showLogMsg:value];
    } else {
        [self showLogMsg:@"没有特征值"];
    }
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
