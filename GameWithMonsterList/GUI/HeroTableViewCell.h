//
//  HeroTableViewCell.h
//  GameWithMonsterList
//
//  Created by 张真 on 2017/9/13.
//  Copyright © 2017年 张真. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GDataXMLNode.h>
#import "GameDataInstance.h"
#import "HeroTableViewCellDelegate.h"


@interface HeroTableViewCell : UITableViewCell
{
}

@property(nonatomic,assign) id<HeroTableViewCellDelegate> delegate;

@property (nonatomic) int heroId;


/**
 初始化数据
 */
-(void)initData;

+(instancetype)HeroTableViewCell;
@property (weak, nonatomic) IBOutlet UIImageView *imgHeroAvatar;
@property (weak, nonatomic) IBOutlet UILabel *txtHeroUpgradeType;
@property (weak, nonatomic) IBOutlet UILabel *txtHeroDetail;
@property (weak, nonatomic) IBOutlet UILabel *txtHeroName;
@property (weak, nonatomic) IBOutlet UILabel *txtHeroAbilityDetail;
@property (weak, nonatomic) IBOutlet UIImageView *imgHeroHitType;
@property (weak, nonatomic) IBOutlet UILabel *txtHeroReview;

@property (nonatomic,strong) UISwitch *swFavor;

@property (nonatomic) UserData *heroData;

-(void)setDataWithXmlData:(UserData *)data;


/**
 更改收藏状态
 */
-(void)changeHeroFavorWithStatus:(BOOL)isFavor;

@end
