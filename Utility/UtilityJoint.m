//
//  UtilityJoint.m
//  
//

#import "UtilityJoint.h"

@interface UtilityJoint ()

@property (weak, nonatomic, readwrite) UtilityJoint * 
   parent;
@property (strong, nonatomic, readwrite) NSArray * 
   children;
@property (assign, nonatomic, readwrite) GLKVector3 
   displacement;

@end


@implementation UtilityJoint

@synthesize parent;
@synthesize children;
@synthesize displacement;
@synthesize matrix;


/////////////////////////////////////////////////////////////////
// Designated initializer
- (id)initWithDisplacement:(GLKVector3)aDisplacement
   parent:(UtilityJoint *)aParent;
{
   if(nil != (self = [super init]))
   {
      self.displacement = aDisplacement;
      self.parent = aParent;
      self.children = [NSMutableArray array];
      self.matrix = GLKMatrix4Identity;
   }
   
   return self;
}


/////////////////////////////////////////////////////////////////
// Returns the cumulative matrix that includes parent transforms
- (GLKMatrix4)cumulativeTransforms;
{
   GLKMatrix4 result = GLKMatrix4Identity;
   
   if(nil != parent)
   {
      result = [parent cumulativeTransforms];
   }
   
   GLKVector3 d = self.cumulativeDisplacement;
   
   // Use the classic recipe for transform about a point:
   // translate to the location of the joint, rotate, and 
   // translate back.
   result = GLKMatrix4Translate(result, d.x, d.y, d.z);
   result = GLKMatrix4Multiply(result, self.matrix);
   result = GLKMatrix4Translate(result, -d.x, -d.y, -d.z);
      
   return result;
}


/////////////////////////////////////////////////////////////////
// Returns the cumulative untransformed displacement including 
// parent's cumulative displacement
- (GLKVector3)cumulativeDisplacement;
{
   GLKVector3 result = self.displacement;
   
   if(nil != self.parent)
   {
      result = GLKVector3Add(result, 
         [self.parent cumulativeDisplacement]);
   }
   
   return result;
}

@end
