//
//  IdolTvTypeConvertUtil.m
//  IdolTv
//
//  Created by 张 真 on 16/5/10.
//  Copyright © 2016年 张 真. All rights reserved.
//

#import "IdolTvTypeConvertUtil.h"


@implementation IdolTvTypeConvertUtil


/**
 *  @author LionelZhang
 *
 *  @brief 把字典转成json字符串
 *
 *  @param dict 字典
 *
 *  @return json字符串
 */
+ (NSString*) SConvertNSDictionaryToNSString:(NSDictionary*)dict
{
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:nil];
    return [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    
}

/**
 base64解码
 
 @param sorStr 源字符串
 @return 结果字符串
 */
+ (NSString*) SDecodeBase64String:(NSString*)sorStr
{
    NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:sorStr options:0];
    
    NSString *decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
    
    return decodedString;
}

/**
 base64编码

 @param sorStr 源字符串
 @return 编码后字符串
 */
+ (NSString*) SEncodeBase64String:(NSString*)sorStr
{
    NSData *nsdata = [sorStr
                      dataUsingEncoding:NSUTF8StringEncoding];
    
    // Get NSString from NSData object in Base64
    return [nsdata base64EncodedStringWithOptions:0];
}

/**
 把字符串转换成字典
 
 @param sorStr 源字符串
 @return 字典
 */
+ (NSMutableDictionary*) SConvertNSStringToNSMutableDictionary:(NSString*)sorStr
{
    NSMutableDictionary *string2dic = [NSJSONSerialization JSONObjectWithData: [sorStr dataUsingEncoding:NSUTF8StringEncoding]
                                                                      options: NSJSONReadingMutableContainers
                                                                        error: nil];
    return string2dic;
}


/**
 nsdata转成16进制字符串
 
 @param data 源数据
 @return 返回字符串
 */
+(NSString*)dataToHexString:(NSData*)data {
    if (data == nil) {
        return @"";
    }
    Byte *dateByte = (Byte *)[data bytes];
    
    NSString *hexStr=@"";
    for(int i=0;i<[data length];i++) {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",dateByte[i]&0xff]; ///16进制数
        if([newHexStr length]==1)
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        else
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
    }
    return hexStr;
}

/**
 根据位置的列表获取json数据
 
 @param locList 位置数据
 @return json字符串
 */
+ (NSString *)locationListToJsonData:(NSArray *)locList
{
    NSMutableArray *jsonData = [[NSMutableArray alloc]init];
    for (GMSAutocompletePrediction *location in locList)
    {
        //添加数据
        NSMutableDictionary *detailData = [[NSMutableDictionary alloc]init];
        [detailData setValue:location.attributedSecondaryText.string forKey:@"address"];
        [detailData setValue:location.attributedPrimaryText.string forKey:@"title"];
        [detailData setValue:location.placeID forKey:@"location"];
        
        //添加到列表
        [jsonData addObject:detailData];
    }
    
    NSData *jsonNsData = [NSJSONSerialization dataWithJSONObject:jsonData options:kNilOptions error:nil];
    
    NSString *jsonStr = [[NSString alloc] initWithData:jsonNsData encoding:NSUTF8StringEncoding];
    
    return jsonStr;
    
}

/**
 16进制转10进制数据
 
 @param hexStr 16进制的数据字符串
 @return 10进制数值
 */
+ (int)HexToDecimal:(NSString *)hexStr
{
    int temp = 1;
    hexStr = [hexStr uppercaseString];
    int finalResule = 0;
    int len = (int)(hexStr.length - 1);
    for(int i = len  ;i >= 0;i--)
    {
        unichar value = [hexStr characterAtIndex:i];
        int nowValue;
        if(value >= 'A' && value <= 'z')
        {
            nowValue = value - 'A';
        }
        else
        {
            nowValue = value - '0';
        }
        
        finalResule += nowValue * temp;
        temp *=16;
    }
    return finalResule;
}

/**
 缩放图片到一定大小
 
 @param image 图片
 @param size 目标大小
 @return 目标图片
 */
+ (UIImage *)scaleUIImage:(UIImage *)image scaleToSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);  //size 为CGSize类型，即你所需要的图片尺寸
    
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return scaledImage;   //返回的就是已经改变的图片
}

/**
 aes256解码

 @param sorStr 源串
 @return <#return value description#>
 */
+ (NSDictionary*)decodeAes256:(NSString*)sorStr
{
    NSString *key = @"9577d7e4a1f5bd494692b511047808ad";
    NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
    
    NSData *allData = [[NSData alloc] initWithBase64EncodedString:sorStr options:0];
    NSData *ivData = [allData subdataWithRange:NSMakeRange(0, 16)];
    NSData *strData = [allData subdataWithRange:NSMakeRange(16, allData.length - 16)];
    sorStr = [strData base64EncodedStringWithOptions:0] ;
    
    CocoaSecurityResult *result = [CocoaSecurity aesDecryptWithBase64:sorStr key:keyData iv:ivData];
    NSData *resultNsData = [result.utf8String dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:resultNsData options:NSJSONReadingMutableLeaves error:nil];
    
    
    return jsonData;
}

/**
 判断当前是否为int
 
 @param string 源字符串
 @return <#return value description#>
 */
+ (BOOL)isPureInt:(NSString *)string
{
    
    NSScanner* scan = [NSScanner scannerWithString:string];
    
    int val;
    
    return [scan scanInt:&val] && [scan isAtEnd];
    
}

@end
