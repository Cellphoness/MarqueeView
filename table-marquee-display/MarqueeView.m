//
//  MarqueeView.m
//  table-marquee-display
//
//  Created by kencai on 2017/8/10.
//  Copyright © 2017年 DragonPass. All rights reserved.
//

#import "MarqueeView.h"
#import "YYWeakProxy.h"

@interface MarqueeViewBuddleCell : UITableViewCell

@property (nonatomic, strong) NSString *topic;
@property (nonatomic, strong) UIButton *topicContent;
@property (nonatomic, assign) BOOL animaitonOut;
@property (nonatomic, assign) BOOL animaitonIn;

@end

@implementation MarqueeViewBuddleCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        self.topicContent = [UIButton buttonWithType:UIButtonTypeCustom];
        self.topicContent.layer.cornerRadius = 10;
        self.topicContent.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
        [self.topicContent setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.topicContent setContentEdgeInsets:UIEdgeInsetsMake(3, 8, 3, 8)];
        self.topicContent.titleLabel.font = [UIFont systemFontOfSize:17];
        [self.contentView addSubview:self.topicContent];
    }
    return self;
}

-(void)layoutSubviews
{
    CGRect self_bounds = self.contentView.bounds;
    self_bounds.origin.y = 8;
    self_bounds.size.height = 24;
    [self.topicContent sizeToFit];
    self_bounds.size.width = self.topicContent.frame.size.width;
    self.topicContent.frame = self_bounds;
}

-(void)setTopic:(NSString *)topic
{
    _topic = topic;
    [self.topicContent setTitle:topic forState:UIControlStateNormal];
}

@end

@interface MarqueeView () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) CADisplayLink  *displayLink;
@property (nonatomic, strong) UITableView    *tableView;
@property (nonatomic, assign) NSInteger      count;
@end

@implementation MarqueeView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (instancetype)init
{
    self = [super init];
    if (self) {
        CGRect fr = CGRectZero;
        fr.size = CGSizeMake([[UIScreen mainScreen] bounds].size.width - 100, 150);
        self.frame = fr;
        [self addSubview:self.tableView];
        self.tableView.userInteractionEnabled = NO;
        self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 150)];
        self.displayLink = [CADisplayLink displayLinkWithTarget:[YYWeakProxy proxyWithTarget:self] selector:@selector(tick:)];
    }
    return self;
}

-(void)tick:(id)sender
{
    self.count ++;
    
    //x / 60 秒滚一次
    //x 越小 滑动越平滑
    //比例越小 越快
    if (self.count == 2) {
        CGPoint currentOffset = self.tableView.contentOffset;
        currentOffset.y += 1;
        [self.tableView setContentOffset:currentOffset animated:NO];//YES 就会一格一格的滑动
        self.count = 0;
    }
}

-(void)dealloc
{
    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint currentOffset = scrollView.contentOffset;
    
    //获取将消失的Cell
    if (currentOffset.y - 120 > 0) {
        NSInteger index = (currentOffset.y - 150) / 40;
        MarqueeViewBuddleCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        if (cell && !cell.animaitonOut) {
            cell.animaitonOut = YES;
            [self animationFadeCell:cell fadeInOut:NO];
            [cell setAnimaitonIn:NO];
            
        }
    }
    
    if (currentOffset.y - 40 > 0) {
        NSInteger index = (currentOffset.y - 40) / 40;
        MarqueeViewBuddleCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        if (cell && !cell.animaitonIn) {
            [cell setAnimaitonIn:YES];
            [self animationFadeCell:cell fadeInOut:YES];
            cell.animaitonOut = NO;
        }
    }
    
    //回到原点
    if (currentOffset.y >= (self.marqueeList.count + 4) * 40) {
        [self.tableView setContentOffset:CGPointZero animated:NO];
    }
    
    
}

-(void)setStartAnimation:(BOOL)startAnimation
{
    _startAnimation = startAnimation;
    if (startAnimation) {
        [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    } else {
        [self.displayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
}

-(void)setMarqueeList:(NSArray *)marqueeList
{
    _marqueeList = marqueeList;
    [self.tableView reloadData];
    if (!self.startAnimation) {
        self.startAnimation = YES;
    }
    [self.tableView setContentOffset:CGPointZero animated:NO];
}

static NSString *reuseIdentifier = @"ReUseId";

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.marqueeList.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MarqueeViewBuddleCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.topic = self.marqueeList[indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(MarqueeViewBuddleCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
//    [self animationFadeCell:cell fadeInOut:YES];
//    [cell setAnimaitonOut:NO];
    cell.alpha = 0;
}

-(void)animationFadeCell:(UITableViewCell *)cell fadeInOut:(BOOL)inOut
{
    cell.hidden = NO;
    cell.alpha = !inOut;
    [UIView beginAnimations:@"fadeIn" context:NULL];
    [UIView setAnimationDuration:1];
    cell.alpha = inOut;
    [UIView commitAnimations];
}

-(UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[MarqueeViewBuddleCell class] forCellReuseIdentifier:reuseIdentifier];
    }
    return _tableView;
}

@end
