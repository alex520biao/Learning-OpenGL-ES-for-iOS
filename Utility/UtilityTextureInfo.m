//
//  UtilityTextureInfo.m
//  
//

#import "UtilityTextureInfo.h"

@interface UtilityTextureInfo ()

@property (strong, nonatomic) NSDictionary *plist;

@end

                              
/////////////////////////////////////////////////////////////////
// This class exists solely to support unarchiving of 
// UtilityTextureInfo instances archived by external 
// applications.
@implementation UtilityTextureInfo

@synthesize plist = plist_;
@synthesize userInfo = userInfo_;


/////////////////////////////////////////////////////////////////
//  
- (void)discardPlist;
{
   self.plist = nil;
}


#pragma mark - NSCoding

/////////////////////////////////////////////////////////////////
// This class exists to support unarchiving only. Instances 
// should never be encoded.
- (void)encodeWithCoder:(NSCoder *)aCoder;
{
   NSAssert(0, @"Invalid method");
}


/////////////////////////////////////////////////////////////////
// Returns a dictionary caontaining a plist storing unarchives 
// attribues.
- (id)initWithCoder:(NSCoder *)aDecoder;
{
   self.plist = [aDecoder decodeObjectForKey:@"plist"];
   
   return self;
}

@end
