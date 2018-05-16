//
//  HeroTableViewCell.m
//  GameWithMonsterList
//
//  Created by 张真 on 2017/9/13.
//  Copyright © 2017年 张真. All rights reserved.
//

#import "HeroTableViewCell.h"

@implementation HeroTableViewCell


//实现类方法
 +(instancetype)HeroTableViewCell {
     
     return [[[NSBundle mainBundle] loadNibNamed:@"HeroTableViewCell" owner:nil options:nil] lastObject];
     
 }

/**
 初始化数据
 */
-(void)initData
{
    CGSize totalRect = self.contentView.frame.size;
    int swFavorHeight = self.contentView.frame.size.height  * 0.5;
    int swFavorWidth = swFavorHeight;
    self.swFavor = [[UISwitch alloc]initWithFrame:CGRectMake(totalRect.width - swFavorWidth-50, (totalRect.height - swFavorHeight)/2, swFavorWidth, swFavorHeight)];
    [self.contentView addSubview:self.swFavor];
    [self.swFavor addTarget:self action:@selector(clickFavor:) forControlEvents:UIControlEventValueChanged];
//    self.swFavor.userInteractionEnabled = YES;
//    self.userInteractionEnabled = YES;
    
    self.swFavor.tag =self.heroId;
}

-(void)clickBtn
{
    NSLog(@"fdaklfjdal");
}

/**
 点击了收藏
 */
-(void)clickFavor:(UISwitch*)sw
{
    if(self.delegate != nil)
    {
        [self.delegate clickFavorButto:self.heroId AndIsFavor:sw.on];
    }
}

/**
 更改收藏状态
 */
-(void)changeHeroFavorWithStatus:(BOOL)isFavor
{
    [self.swFavor setOn:isFavor];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ([touch.view isKindOfClass:[UISwitch class]])
    {
        return NO;
    }
    // 若为UITableViewCellContentView（即点击了tableViewCell），则不截获Touch事件
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        return NO;
    }
    return YES;
}

-(void)setDataWithXmlData:(UserData *)data
{
    self.txtHeroName.font = [UIFont fontWithName:@"Arial" size:18];
    self.txtHeroDetail.font = [UIFont fontWithName:@"Arial" size:10];
    self.txtHeroAbilityDetail.font = [UIFont fontWithName:@"Arial" size:10];
    
    NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
    self.heroData = data;
    self.txtHeroUpgradeType.text = data.upgradeType;
    self.txtHeroName.text = data.userName;
    self.txtHeroDetail.text = [NSString stringWithFormat:@"No.%d %@",data.userId,data.takeType];
    self.txtHeroAbilityDetail.text = data.abilityType;
    self.heroId = data.userId;
    self.txtHeroReview.text = data.reviewValue;
    
    
    if([[[GameDataInstance Instance] imageDict] objectForKey:[NSString stringWithFormat:@"%d",self.heroId]] != nil)
    {
        self.imgHeroAvatar.image = [[[GameDataInstance Instance] imageDict] objectForKey:[NSString stringWithFormat:@"%d",self.heroId]];
    }
    else
        {
             self.imgHeroAvatar.image = [UIImage imageNamed:@"DefaultImage"];
            NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(downloadAvatar) object:nil];
            [operationQueue addOperation:op];
        }
    if([data.hitType containsString:@"貫通"])
    {
        self.imgHeroHitType.image = [UIImage imageNamed:@"HitType02"];
    }
    else
    {
        self.imgHeroHitType.image = [UIImage imageNamed:@"HitType01"];
    }
}

- (void)downloadAvatar
{
    NSURL *imageUrl = [NSURL URLWithString:self.heroData.avatarAddress];
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageUrl]];
    self.imgHeroAvatar.image = image;
    
    [[[GameDataInstance Instance] imageDict] setObject:image forKey:[NSString stringWithFormat:@"%d",self.heroId]];
}



@end
