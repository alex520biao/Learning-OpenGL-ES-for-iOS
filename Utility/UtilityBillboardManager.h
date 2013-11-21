//
//  UtilityBillboardManager.h
//
//

#import <GLKit/GLKit.h>

@class UtilityBillboard;


@interface UtilityBillboardManager : NSObject

@property (strong, nonatomic, readonly) 
   NSArray *sortedBillboards;
@property (assign, nonatomic, readwrite) 
   BOOL shouldRenderSpherical;

- (void)updateWithEyePosition:(GLKVector3)eyePosition 
   lookDirection:(GLKVector3)lookDirection;

- (void)addBillboard:(UtilityBillboard *)aBillboard;

- (void)addBillboardAtPosition:(GLKVector3)aPosition
   size:(GLKVector2)aSize
   minTextureCoords:(GLKVector2)minCoords
   maxTextureCoords:(GLKVector2)maxCoords;


@end
