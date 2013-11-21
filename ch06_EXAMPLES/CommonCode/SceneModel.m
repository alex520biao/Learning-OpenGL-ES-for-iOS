//
//  SceneModel.m
//  
//

#import "SceneModel.h"
#import "SceneMesh.h"
#import "AGLKVertexAttribArrayBuffer.h"


@interface SceneModel ()

@property (strong, nonatomic, readwrite) SceneMesh
   *mesh;
@property (assign, nonatomic, readwrite) 
   SceneAxisAllignedBoundingBox axisAlignedBoundingBox;
@property (nonatomic) GLsizei 
   numberOfVertices;
@property (copy, nonatomic, readwrite) NSString
   *name;

@end


@implementation SceneModel

@synthesize mesh;
@synthesize axisAlignedBoundingBox;
@synthesize numberOfVertices;
@synthesize name;


/////////////////////////////////////////////////////////////////
// Designated initializer
- (id)initWithName:(NSString *)aName
   mesh:(SceneMesh *)aMesh
   numberOfVertices:(GLsizei)aCount;
{
   if(nil != (self = [super init]))
   {
      self.name = aName;
      self.mesh = aMesh;
      self.numberOfVertices = aCount;
   }
   
   return self;
}


/////////////////////////////////////////////////////////////////
// Returns nil
- (id)init
{
   NSAssert(0, @"Invalid initializer");
   
   self = nil;
   
   return self;
}


/////////////////////////////////////////////////////////////////
// Prepare the model's mesh for drawing
- (void)prepareToDraw;
{
   [self.mesh prepareToDraw];
}


/////////////////////////////////////////////////////////////////
// Prepare the model's mesh for drawing, draws the model.
- (void)draw;
{
   [self.mesh prepareToDraw];
   [self.mesh drawUnidexedWithMode:GL_TRIANGLES
      startVertexIndex:0
      numberOfVertices:self.numberOfVertices];
}


/////////////////////////////////////////////////////////////////
// Call this method to recalculate the receiver's bounding box
// any time the vertex attributes for the receiver change.
- (void)updateAlignedBoundingBoxForVertices:(float *)verts
   count:(unsigned int)aCount;
{
   SceneAxisAllignedBoundingBox result = 
      {{0, 0, 0},{0, 0, 0}};
   const GLKVector3 *positions = (const GLKVector3 *)verts;
       
   if(0 < aCount)
   {
      result.min.x = result.max.x = positions[0].x;
      result.min.y = result.max.y = positions[0].y;
      result.min.z = result.max.z = positions[0].z;
   }
   for(int i = 1; i < aCount; i++)
   {
      result.min.x = MIN(result.min.x, positions[i].x);
      result.min.y = MIN(result.min.y, positions[i].y);
      result.min.z = MIN(result.min.z, positions[i].z);
      result.max.x = MAX(result.max.x, positions[i].x);
      result.max.y = MAX(result.max.y, positions[i].y);
      result.max.z = MAX(result.max.z, positions[i].z);
   }
   
   self.axisAlignedBoundingBox = result;
}

@end
