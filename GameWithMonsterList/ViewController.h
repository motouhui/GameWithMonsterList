//
//  ViewController.h
//  GameWithMonsterList
//
//  Created by 张真 on 2017/9/8.
//  Copyright © 2017年 张真. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AFNetworking/AFNetworking.h>
#import <Ono.h>
#import "IdolTvHttpManager.h"
#import <SSZipArchive/SSZipArchive.h>
#import <GDataXMLNode.h>
#import "UserData.h"
#import "HeroTableViewCell.h"
#import "HeroDetailViewController.h"
#import "GameDataInstance.h"
#import <CMPopTipView.h>
#import <CoreTelephony/CTCellularData.h>


@interface ViewController : UIViewController<IdolTvHttpCallbackDelegate,SSZipArchiveDelegate,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,CMPopTipViewDelegate,HeroTableViewCellDelegate>
{
    IdolTvHttpManager *httpManager;
    
    NSMutableArray *heroList;
    
    BOOL isSearch;
    
    NSMutableArray *searchList;
    
    //tips视图
    CMPopTipView *popTipView;
    
    NSString *fileUrl;
    
    //收藏列表
    NSMutableDictionary *favorList;
}

@property (weak, nonatomic) IBOutlet UITableView *tvHeroInfo;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIButton *btnHitSkill;
@property (weak, nonatomic) IBOutlet UIButton *btnQuestList;
@property (weak, nonatomic) IBOutlet UIButton *btnFavorList;

@end

