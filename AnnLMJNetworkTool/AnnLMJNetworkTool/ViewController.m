//
//  ViewController.m
//  AnnLMJNetworkTool
//
//  Created by iSolar on 2017/8/8.
//  Copyright © 2017年 nothing. All rights reserved.
//

#import "ViewController.h"
#import "ProjectModle.h"
#import "HomeViewCell.h"
#import "AnnLiuNetworking.h"
#import "AnnLSVPHUD.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UIButton *urlBtn;
@property (strong, nonatomic) UILabel *contentL;
@property (nonatomic, strong) NSMutableArray *projectListArr;
@property (strong, nonatomic) UITableView *table;
@property (strong, nonatomic) UIButton *uploadBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    _table = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, kScreenHeight - 64) style:UITableViewStylePlain];
    _table.backgroundColor = [UIColor colorWithHexString:@"d7d7d7"];
    _table.delegate = self;
    _table.dataSource = self;
    _table.allowsSelection = NO;
    _table.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_table registerNib:[UINib nibWithNibName:@"HomeViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"cell"];
    [self.view addSubview:_table];
    _table.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 140)];
    
    _urlBtn = [[UIButton alloc] initWithFrame:CGRectMake(50, 30, (kScreenWidth - 150 ) / 2, 35)];
    _urlBtn.layer.cornerRadius = 10;
    [_urlBtn setTitle:@"urlTest" forState: UIControlStateNormal];
    [_urlBtn setTitleColor:[UIColor colorWithHexString:@"1475f9"] forState:UIControlStateNormal];
    _urlBtn.backgroundColor = [UIColor colorWithHexString:@"0df988"];
    [_urlBtn addTarget:self action:@selector(testAction) forControlEvents:UIControlEventTouchUpInside];
    [_table.tableHeaderView addSubview:_urlBtn];
    
    _uploadBtn = [[UIButton alloc] initWithFrame:CGRectMake(100 + (kScreenWidth - 150 ) / 2, 30, (kScreenWidth - 150 ) / 2, 35)];
    _uploadBtn.layer.cornerRadius = 10;
    [_uploadBtn setTitle:@"uploadTest" forState: UIControlStateNormal];
    [_uploadBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _uploadBtn.backgroundColor = [UIColor redColor];
    [_uploadBtn addTarget:self action:@selector(clearAllAction) forControlEvents:UIControlEventTouchUpInside];
    [_table.tableHeaderView addSubview:_uploadBtn];
    
    _contentL = [[UILabel alloc] initWithFrame:CGRectMake(50, 90, kScreenWidth - 100, 20)];
    [_table.tableHeaderView addSubview:_contentL];
    _contentL.textAlignment = NSTextAlignmentCenter;
    _contentL.textColor = [UIColor whiteColor];
    
    
}


- (void)testAction {
    
    [AnnLiuNetworking getWithUrl:@"4/news/before/20131119" params:nil Cache:NO refreshCache:YES success:^(id responseObj) {
        
        self.projectListArr = [ProjectModle mj_objectArrayWithKeyValuesArray:responseObj[@"stories"]];
        
        self.contentL.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.projectListArr.count];
        
        [_table reloadData];
        
        [AnnLSVPHUD showSuccessWithStatus:@"加载成功"];
        
    } fail:^(NSError *error) {
        
    }];
    
}

- (void)clearAllAction {
    
    [self.projectListArr removeAllObjects];
    self.contentL.text = @"0";
    [self.table reloadData];
    [AnnLSVPHUD showSuccessWithStatus:@"清除数据成功"];
    
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.projectListArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIndentifier1 = @"cell";
    HomeViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier1];
    if (cell == nil) {
        cell = [[HomeViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier1];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    [cell setModel:self.projectListArr[indexPath.row]];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

@end

