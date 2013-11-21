//
//  UtilityModelManager.h
//  
//

#import <GLKit/GLKit.h>

@class UtilityModel;
@class UtilityMesh;


@interface UtilityModelManager : NSObject

@property (strong, nonatomic, readonly) GLKTextureInfo 
   *textureInfo;
@property (strong, nonatomic, readonly) UtilityMesh 
   *consolidatedMesh;

- (id)init;
- (id)initWithModelPath:(NSString *)aPath;

- (BOOL)readFromData:(NSData *)data 
   ofType:(NSString *)typeName 
   error:(NSError **)outError;

- (UtilityModel *)modelNamed:(NSString *)aName;
- (void)prepareToDraw;
- (void)prepareToPick;

@end

/////////////////////////////////////////////////////////////////
// Constants used to access model properties from a plist
// dictionary.
extern NSString *const UtilityModelManagerTextureImageInfo;
extern NSString *const UtilityModelManagerMesh;
extern NSString *const UtilityModelManagerModels;
