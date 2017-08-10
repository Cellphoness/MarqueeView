//
//  ViewController.m
//  table-marquee-display
//
//  Created by kencai on 2017/8/10.
//  Copyright © 2017年 DragonPass. All rights reserved.
//

#import "ViewController.h"
#import "MarqueeView.h"

#define Screen_width    [[UIScreen mainScreen] bounds].size.width

@interface ImageTableViewCell : UITableViewCell

@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) MarqueeView *mView;
@end

@implementation ImageTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.imgView = [[UIImageView alloc] init];
        self.imgView.contentMode = UIViewContentModeScaleToFill;
        self.mView = [[MarqueeView alloc] init];
        [self.contentView addSubview:self.imgView];
        [self.contentView addSubview:self.mView];
    }
    return self;
}

-(void)layoutSubviews
{
    self.imgView.frame = self.contentView.bounds;
    self.mView.frame = CGRectMake(50, self.contentView.bounds.size.height - 150, [[UIScreen mainScreen] bounds].size.width - 100, 150);
}

@end



@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) UITableView    *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSArray <NSString *>*dataList = @[@"LosAngeles"
//                                      ,
//                          @"MarketStreet",
//                          @"Drops",
//                          @"Powell",
//                          @"Orange"
                                      ];
    
    self.dataArray = @[].mutableCopy;
    
    [dataList enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIImage *image = [UIImage imageNamed:obj];
        CGSize size = image.size;
        CGFloat tableCellHeight = Screen_width * size.height / size.width - 100;
        [self.dataArray addObject:@{@"height":@(tableCellHeight), @"image":image, @"topics":@[@"HHAHAHAHA", @"yeah!", @"hello world!", @"DragonPass", @"1234567890"]}];
        ;
    }];
    
    [self.view addSubview:self.tableView];
}

static NSString *reuseIdentifier = @"ReUseId";

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.dataArray[indexPath.row][@"height"] floatValue];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ImageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.imgView.image = self.dataArray[indexPath.row][@"image"];
    cell.mView.marqueeList = self.dataArray[indexPath.row][@"topics"];
    return cell;
}


-(UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[ImageTableViewCell class] forCellReuseIdentifier:reuseIdentifier];
    }
    return _tableView;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
