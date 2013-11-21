//
//  TEModelManager.h
//  TerrainEditor
//

#import "UtilityTextureLoader.h"

@class TEEffect;
@class TEModel;


@interface TEModelManager : NSObject

@property (strong, nonatomic, readonly) UtilityTextureInfo 
   *textureInfo;
@property (strong, nonatomic, readonly) NSDictionary 
   *modelsDictionary;

- (id)init;

- (BOOL)readFromData:(NSData *)data 
   ofType:(NSString *)typeName 
   error:(NSError **)outError;

- (TEModel *)modelNamed:(NSString *)aName;
- (void)prepareToDraw;
- (void)prepareToPick;

@end

/////////////////////////////////////////////////////////////////
// Constants used to access model properties from a plist
// dictionary.
extern NSString *const TEModelManagerTextureImageInfo;
extern NSString *const TEModelManagerMesh;
extern NSString *const TEModelManagerModels;
