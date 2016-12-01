//
//  MainViewController.m
//  CentralPeripheralTool
//
//  Created by LiuMingchuan on 2016/11/29.
//  Copyright © 2016年 LiuMingchuan. All rights reserved.
//

#import "MainViewController.h"
#import "CentralViewController.h"
#import "PeripheralViewController.h"

@interface MainViewController ()<UITableViewDelegate,UITableViewDataSource> {
    NSArray *items;
    NSDictionary *controllers;
}

@property (weak, nonatomic) IBOutlet UITableView *mainTV;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:@"MainPage"];
    
    _mainTV.delegate = self;
    _mainTV.dataSource = self;
    
    items = @[@"Central",@"Peripheral"];
    controllers = @{items[0]:[[CentralViewController alloc]init],items[1]:[[PeripheralViewController alloc]init]};
    // Do any additional setup after loading the view from its nib.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [items count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifer = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifer];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifer];
    }
    cell.textLabel.text = [items objectAtIndex:indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIViewController *vc = [controllers objectForKey:[items objectAtIndex:indexPath.row]];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - others

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
