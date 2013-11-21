//
//  COLLADANode.m
//  COLLADAViewer
//

#import "COLLADANode.h"
#import "CVMesh.h"

@interface COLLADANode ()

@property (nonatomic, readwrite, retain) NSMutableSet 
   *mutableSubnodes;
@property (retain, nonatomic, readwrite) CVMesh *mesh;

@end


@implementation COLLADANode

@synthesize mutableSubnodes;
@synthesize transforms;
@synthesize parent;
@synthesize name;
@synthesize mesh;


/////////////////////////////////////////////////////////////////
//
- (id)init;
{
   if(nil != (self=[super init]))
   {
      self.mutableSubnodes = [NSMutableSet set];
      self.transforms = UtilityMatrix4Identity;
   }
   
   return self;
}


/////////////////////////////////////////////////////////////////
//
- (NSSet *)subnodes;
{
   return self.mutableSubnodes;
}


/////////////////////////////////////////////////////////////////
//
- (void)addSubnode:(COLLADANode *)aNode;
{
   [self.mutableSubnodes addObject:aNode];
   aNode.parent = self;
}


/////////////////////////////////////////////////////////////////
//
- (void)appendMesh:(CVMesh *)aMesh;
{
   if(nil == self.mesh)
   {
      self.mesh = aMesh;
   }
   else
   {
      [self.mesh appendMesh:aMesh];
   }
}


/////////////////////////////////////////////////////////////////
//
- (void)appendMeshesToMesh:(CVMesh *)aMesh
   cumulativeTransforms:(UtilityMatrix4)cumulativeTransforms;
{
   cumulativeTransforms = 
      UtilityMatrix4Multiply(cumulativeTransforms,
      self.transforms);
      
   if(nil != self.mesh)
   {
      CVMesh *newMesh = 
         [[self.mesh copyWithTransform:cumulativeTransforms]
         autorelease];
         
      [aMesh appendMesh:newMesh];
   }
    
   for(COLLADANode *currentNode in self.subnodes)
   {
      [currentNode appendMeshesToMesh:aMesh
         cumulativeTransforms:cumulativeTransforms];
   }
}

/////////////////////////////////////////////////////////////////
//
- (void)draw;
{
   glMatrixMode(GL_MODELVIEW);
   glPushMatrix();
      glMultMatrixf(self.transforms.m);
      [self.mesh prepareToDraw];
      [self.mesh drawAllCommands];
      [self.subnodes makeObjectsPerformSelector:@selector(draw)];
   glPopMatrix();
}


/////////////////////////////////////////////////////////////////
//
- (void)drawNormals
{
   glMatrixMode(GL_MODELVIEW);
   glPushMatrix();
      glMultMatrixf(self.transforms.m);
      [self.mesh drawNormalsAllCommandsLength:0.1f];
      [self.subnodes makeObjectsPerformSelector:@selector(drawNormals)];
   glPopMatrix();
}

@end
