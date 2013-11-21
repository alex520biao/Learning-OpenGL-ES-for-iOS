//
//  UtilityTextureInfo.h
//  
//

#import <GLKit/GLKit.h>

@interface UtilityTextureInfo : NSObject 
   <NSCoding>

@property (strong, nonatomic, readonly) NSDictionary *plist;
@property (strong, nonatomic, readwrite) id userInfo;

- (void)discardPlist;

@end
