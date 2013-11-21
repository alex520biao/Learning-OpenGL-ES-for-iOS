//
//  UtilityJoint.h
//  
//

#import "UtilityMesh.h"

@interface UtilityJoint : NSObject

@property (weak, nonatomic, readonly) UtilityJoint * 
   parent;
@property (strong, nonatomic, readonly) NSArray * 
   children;
@property (assign, nonatomic, readonly) GLKVector3 
   displacement;  // Displacement from parent bone
@property (assign, nonatomic, readwrite) GLKMatrix4 
   matrix;        // local matrix

- (id)initWithDisplacement:(GLKVector3)aDisplacement
   parent:(UtilityJoint *)aParent;
   
- (GLKMatrix4)cumulativeTransforms;
- (GLKVector3)cumulativeDisplacement;

@end
