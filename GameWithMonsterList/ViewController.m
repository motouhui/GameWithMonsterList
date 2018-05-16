//
//  ViewController.m
//  GameWithMonsterList
//
//  Created by 张真 on 2017/9/8.
//  Copyright © 2017年 张真. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CTCellularData *cellularData = [[CTCellularData alloc]init];
    cellularData.cellularDataRestrictionDidUpdateNotifier = ^(CTCellularDataRestrictedState state){
        if([ViewController checkNetWorkPermission] != 1)
            
        {
            [[GameDataInstance Instance]InitData];
            double random = [[NSDate alloc]init].timeIntervalSinceNow;
            fileUrl = [NSString stringWithFormat:@"http://104.155.194.197/monsterStrike/ms.zip?rnd=%f",random];
            httpManager = [[IdolTvHttpManager alloc]init];
            
            [httpManager initData];
            httpManager.callback = self;
            
            self.tvHeroInfo.delegate = self;
            self.tvHeroInfo.dataSource = self;
            heroList = [[NSMutableArray alloc]init];
            searchList = [[NSMutableArray alloc]init];
            isSearch = NO;
            
            NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
            favorList = [[NSMutableDictionary alloc]initWithDictionary:[userDef objectForKey:@"favorList"]];
            
            self.searchBar.delegate = self;
            
            NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
            // 解压
            NSString *destinationPath = [NSString stringWithFormat:@"%@/ms",[documentsDirectoryURL path]];
            
            
            NSFileManager * fileManger = [NSFileManager
                                          defaultManager];
            BOOL isDir = NO;
            BOOL isExist = [fileManger fileExistsAtPath:destinationPath isDirectory:&isDir];
            
            //if don't have this file need download first
            if(!isExist)
            {
                [httpManager beginDownloadFile:fileUrl];
            }
            else
            {
                NSURL *url = [NSURL URLWithString:@"http://104.155.194.197/monsterStrike/version.txt"];
                NSString *serverVersion = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
                NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
                int nowVersion;
                nowVersion = [userDef objectForKey:@"version"] == nil ? -1:[[userDef objectForKey:@"version"]intValue];
                if([serverVersion intValue] >nowVersion)
                {
                    [httpManager beginDownloadFile:fileUrl];
                    
                    [userDef setObject:serverVersion forKey:@"version"];
                    
                    [userDef synchronize];
                    
                }
                else
                {
                    [self readDataFromLocalFiles:destinationPath];
                }
                
            }
            
            self.tvHeroInfo.userInteractionEnabled = YES;
            
            [self.btnHitSkill addTarget:self action:@selector(showTips) forControlEvents:UIControlEventTouchDown];
            
            [self.btnQuestList addTarget:self action:@selector(showQuestList) forControlEvents:UIControlEventTouchDown];
            
            [self.btnFavorList addTarget:self action:@selector(changeToFavorList) forControlEvents:UIControlEventTouchDown];
        }
    };
    
    
    // Do any additional setup after loading the view, typically from a nib.
}

-(void) changeToFavorList
{
    searchList = [[NSMutableArray alloc]init];
    isSearch = YES;
    for(NSString *heroId in favorList)
    {
        for(int i = 0; i< heroList.count;i++)
        {
            UserData *hero = heroList[i];
            if([[NSString stringWithFormat:@"%d",hero.userId] isEqualToString: heroId])
            {
                [searchList addObject:hero];
            }
        }
    }
    [self.tvHeroInfo reloadData];
    [self.searchBar resignFirstResponder];
}

/**
 检测网络权限
 
 @return 是否有权限 0 关闭 1 仅wifi 2 流量+wifi
 */
+ (int)checkNetWorkPermission
{
    CTCellularData *cellularData = [[CTCellularData alloc]init];
    CTCellularDataRestrictedState state = cellularData.restrictedState;
    return state;
}

-(void)showQuestList
{
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    HeroDetailViewController *receive = [storyboard instantiateViewControllerWithIdentifier:@"HeroDetailViewController"];
    //    [[GameDataInstance Instance] loadUrl] =url;
    receive.loadUrl = @"https://モンスターストライク.gamewith.jp/article/show/3054";
    [self.navigationController pushViewController:receive animated:YES];
}

/**
 显示提示
 */
-(void)showTips
{
    if (nil != popTipView)
    {
        // Dismiss
        [popTipView dismissAnimated:YES];
        popTipView = nil;
    }
    popTipView = [[CMPopTipView alloc]initWithCustomView:[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"HitSkillTips"]]];
    popTipView.delegate = self;
    popTipView.backgroundColor = [UIColor grayColor];
    popTipView.textColor = [UIColor darkTextColor];
    [popTipView presentPointingAtView:self.btnHitSkill inView:self.view animated:YES];
}

/**
 提示框的delegate
 
 @param popTipView <#popTipView description#>
 */
- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView
{
    popTipView = nil;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if([searchText isEqualToString:@""])
    {
        isSearch = NO;
        [self.tvHeroInfo reloadData];
    }
    
    if([self isPureInt:searchText])
    {
        int searchId = [searchText intValue];
        
        searchList = [[NSMutableArray alloc]init];
        isSearch = YES;
        for(int i = 0; i< heroList.count;i++)
        {
            UserData *hero = heroList[i];
            if([[NSString stringWithFormat:@"%d",hero.userId] containsString: searchText])
            {
                [searchList addObject:hero];
            }
        }
        
        [self.tvHeroInfo reloadData];
    }
    else
    {
        searchList = [[NSMutableArray alloc]init];
        isSearch = YES;
        for(int i = 0; i< heroList.count;i++)
        {
            UserData *hero = heroList[i];
            if([hero.userName containsString: searchText])
            {
                [searchList addObject:hero];
            }
        }
        
        [self.tvHeroInfo reloadData];
    }
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
}


- (void)httpcallbackWithProtocolIdAndStringData:(int)protoclId httpCallbackStatus:(int)status httpCallbackData:(NSString *)data
{
    if(protoclId == 1)
    {
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        // 解压
        NSString *destinationPath = [NSString stringWithFormat:@"%@/ms",[documentsDirectoryURL path]];
        BOOL isDir = NO;
        BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:data isDirectory:&isDir];
        if(isExist)
        {
        }
        NSError *error;
        [[NSFileManager defaultManager]removeItemAtPath:destinationPath error:&error];
        BOOL isDone = [SSZipArchive unzipFileAtPath:data  toDestination:destinationPath delegate:self];
        if(isDone)
        {
            [self readDataFromLocalFiles:destinationPath];
        }
        else
        {
            
        }
    }
    else if(protoclId == 2)
    {
        
    }
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)zipArchiveDidUnzipArchiveFile:(NSString *)zipFile entryPath:(NSString *)entryPath destPath:(NSString *)destPath
{
    [self showAllFiles:destPath];
}

- (void)zipArchiveDidUnzipArchiveAtPath:(NSString *)path zipInfo:(unz_global_info)zipInfo unzippedPath:(NSString *)unzippedPath
{
    [self showAllFiles:unzippedPath];
}

- (void)readDataFromLocalFiles:(NSString *)path
{
    NSFileManager * fileManger = [NSFileManager
                                  defaultManager];
    NSArray * dirArray = [fileManger
                          contentsOfDirectoryAtPath:path error:nil];
    for (NSString * str in dirArray) {
        BOOL isDir = NO;
        NSString *newPath =[NSString stringWithFormat:@"%@/%@",path,str];
        BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:newPath isDirectory:&isDir];
        if(isDir)
        {
            [self readDataFromLocalFiles:newPath];
        }
        else
        {
            NSString *filePath = [path stringByAppendingPathComponent:str];
            NSData *fileData = [[NSData alloc]initWithContentsOfFile:filePath];
            GDataXMLDocument *doc = [[GDataXMLDocument alloc]initWithData:fileData error:nil];
            GDataXMLElement *rootElement= [doc rootElement];
            NSArray *elementList = [rootElement children];
            for(int i = 0 ; i < elementList.count ;i++)
            {
                UserData * userData = [[UserData alloc]init];
                [userData ParseDataFromXml:elementList[i]];
                [heroList addObject:userData];
            }
        }
    }
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary<NSString *,NSString *> *)attributeDict
{
    NSLog(@"");
}

- (void)showAllFiles:(NSString *)path
{
    // 1.判断文件还是目录
    NSFileManager * fileManger = [NSFileManager
                                  defaultManager];
    
    BOOL isDir = NO;
    BOOL isExist = [fileManger
                    fileExistsAtPath:path isDirectory:&isDir];
    if (isExist) {
        // 2.判断是不是目录
        if (isDir) {
            NSArray * dirArray = [fileManger
                                  contentsOfDirectoryAtPath:path error:nil];
            NSString * subPath =
            nil;
            for (NSString * str in dirArray) {
                subPath  = [path stringByAppendingPathComponent:str];
                BOOL issubDir = NO;
                [fileManger fileExistsAtPath:subPath
                                 isDirectory:&issubDir];
                [self showAllFiles:subPath];
            }
            
            
        }else{
            NSLog(@"%@",path);
        }
    }else{
        NSLog(@"你打印的是目录或者不存在");
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseIdentifier = [NSString stringWithFormat:@"Hero%d",indexPath.row];
    
    HeroTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];

    if (!cell) {
        //这里换成自己定义的cell,并调用类方法加载xib文件
        cell = [[HeroTableViewCell HeroTableViewCell] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
        [cell initData];
        cell.delegate = self;
    }
    if(isSearch)
    {
        if(searchList.count > indexPath.row)
        {
            [cell setDataWithXmlData:searchList[indexPath.row]];
        }
    }
    else
    {
        if(heroList.count > indexPath.row)
        {
            [cell setDataWithXmlData:heroList[indexPath.row]];
        }
    }
    if(favorList != nil &&[favorList objectForKey:[NSString stringWithFormat:@"%d",cell.heroId]])
    {
        [cell changeHeroFavorWithStatus:YES];
    }
    else
    {
        [cell changeHeroFavorWithStatus:NO];
    }
    return cell;
}

-(void)clickFavor:(UISwitch*)sw
{
    NSLog(@"");
}

/**
 点击了收藏

 @param userId <#userId description#>
 @param isFavor <#isFavor description#>
 */
-(void)clickFavorButto:(int)userId AndIsFavor:(BOOL)isFavor
{
    
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    favorList = [[NSMutableDictionary alloc]initWithDictionary:[userDef objectForKey:@"favorList"]];
    if(favorList == nil)
    {
        favorList = [[NSMutableDictionary alloc]init];
    }
    
    if(isFavor)
    {
        [favorList setObject:@"favor" forKey:[NSString stringWithFormat:@"%d",userId]];
    }
    else
    {
        [favorList removeObjectForKey:[NSString stringWithFormat:@"%d",userId]];
    }
    [userDef setObject:favorList forKey:@"favorList"];
    [userDef synchronize];
}

- (void)httpCallbackWithProtocolIdAndDicData:(int)protoclId httpCallbackStatus:(int)status httpCallbackData:(NSDictionary *)data
{
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *url;
    UserData *heroData;
    if(isSearch)
    {
        heroData = searchList[indexPath.row];
    }
    else
    {
        heroData = heroList[indexPath.row];
    }
    
    if([heroData.articleAddress containsString:@"tw"]||[heroData.articleAddress containsString:@"TW"])
    {
        url =heroData.articleAddress;
    }
    else{
    url =[NSString stringWithFormat:@"https://モンスターストライク.gamewith.jp%@",heroData.articleAddress];
    }
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    HeroDetailViewController *receive = [storyboard instantiateViewControllerWithIdentifier:@"HeroDetailViewController"];
//    [[GameDataInstance Instance] loadUrl] =url;
    receive.loadUrl = url;
    [self.navigationController pushViewController:receive animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(isSearch)
        return searchList.count;
    return heroList.count;
}

- (BOOL)isPureInt:(NSString*)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return[scan scanInt:&val] && [scan isAtEnd];
}



@end
