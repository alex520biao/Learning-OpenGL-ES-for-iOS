//
//  UtilityBillboard.h
//  
//

#import <GLKit/GLKit.h>


@interface UtilityBillboard : NSObject

@property (assign, nonatomic, readonly) 
   GLKVector3 position;
@property (assign, nonatomic, readonly) 
   GLKVector2 minTextureCoords;
@property (assign, nonatomic, readonly) 
   GLKVector2 maxTextureCoords;
@property (assign, nonatomic, readonly) 
   GLKVector2 size;
@property (assign, nonatomic, readonly) 
   GLfloat distanceSquared;


- (id)initWithPosition:(GLKVector3)aPosition
   size:(GLKVector2)aSize
   minTextureCoords:(GLKVector2)minCoords
   maxTextureCoords:(GLKVector2)maxCoords;

- (void)updateWithEyePosition:(GLKVector3)eyePosition 
   lookDirection:(GLKVector3)lookDirection;

@end

// Function used to sort particles by distance
extern NSComparisonResult UtilityCompareBillboardDistance(
  UtilityBillboard *a, 
  UtilityBillboard *b, 
  void *context);