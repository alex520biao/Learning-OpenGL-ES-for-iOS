//
//  UtilityBillboard.m
//  
//

#import "UtilityBillboard.h"

@interface UtilityBillboard ()

@property (assign, nonatomic, readwrite) 
   GLKVector3 position;
@property (assign, nonatomic, readwrite) 
   GLfloat distanceSquared;

@end


@implementation UtilityBillboard

@synthesize position = position_;
@synthesize size = size_;
@synthesize minTextureCoords = minTextureCoords_;
@synthesize maxTextureCoords = maxTextureCoords_;
@synthesize distanceSquared = distanceSquared_;


/////////////////////////////////////////////////////////////////
// Designated initializer
- (id)initWithPosition:(GLKVector3)aPosition
   size:(GLKVector2)aSize
   minTextureCoords:(GLKVector2)minCoords
   maxTextureCoords:(GLKVector2)maxCoords;
{
   if(nil != (self = [super init]))
   {
      position_ = aPosition;
      size_ = aSize;
      minTextureCoords_ = minCoords;
      maxTextureCoords_ = maxCoords;
   }
   
   return self;
}


/////////////////////////////////////////////////////////////////
// override of inherited initializer
- (id)init
{
   NSAssert(0, @"Invalid initializer");
   
   return nil;
}


/////////////////////////////////////////////////////////////////
// Apply Newtonian physics and filters to modify the receiver's
// position and velocity.
- (void)updateWithEyePosition:(GLKVector3)eyePosition 
   lookDirection:(GLKVector3)lookDirection;
{
   const GLKVector3 vectorFromEye = GLKVector3Subtract(
      eyePosition, position_);
   distanceSquared_ = GLKVector3DotProduct(vectorFromEye, 
      lookDirection);
}


/////////////////////////////////////////////////////////////////
// Function used to compare particles when sorting.
NSComparisonResult UtilityCompareBillboardDistance(
  UtilityBillboard *a, 
  UtilityBillboard *b, 
  void *context)
{
   NSInteger result = NSOrderedSame;
   
   if (a->distanceSquared_ < b->distanceSquared_)
   {  // Distant particles are ordered after near ones
      result = NSOrderedDescending;
   }
   else if (a->distanceSquared_ > b->distanceSquared_)
   {  // Distant particles are ordered after near ones
      result = NSOrderedAscending;
   }
   
   return result;
}

@end
