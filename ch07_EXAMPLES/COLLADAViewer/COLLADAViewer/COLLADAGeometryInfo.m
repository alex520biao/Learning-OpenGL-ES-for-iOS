//
//  COLLADAGeometryInfo.m
//  COLLADAViewer
//

#import "COLLADAGeometryInfo.h"
#import "COLLADAParser.h"
#import "CVMesh.h"


/////////////////////////////////////////////////////////////////
//  
@interface SceneGeometryBuilderCombination : NSObject

@property (nonatomic, readwrite, assign) COLLADAIndexGroup
   indexGroup;
@property (nonatomic, readwrite, assign) GLushort 
   indexInMesh;

- (NSUInteger)hash;
- (BOOL)isEqual:(id)object;

@end


/////////////////////////////////////////////////////////////////
//  
@interface COLLADAGeometryInfo ()

@property (nonatomic, readwrite, retain) CVMesh
   *mesh;
@property (nonatomic, readwrite, strong) NSMutableSet 
   *existingCombinations;
@property (nonatomic, readwrite, assign) NSUInteger 
   nextAvalableIndex;
@property (retain, nonatomic, readwrite) NSMutableDictionary 
   *mutableSourcesByID;
@property (retain, nonatomic, readwrite) NSMutableDictionary 
   *mutableVertexInfoByID;

@end


/////////////////////////////////////////////////////////////////
//  
@implementation COLLADAGeometryInfo

@synthesize geometryID;
@synthesize mesh;
@synthesize existingCombinations;
@synthesize nextAvalableIndex;
@synthesize mutableSourcesByID;
@synthesize mutableVertexInfoByID;


/////////////////////////////////////////////////////////////////
//  
- (id)initWithID:(NSString *)aGeometryID;
{
   NSParameterAssert(nil != aGeometryID);
   
   if(nil != (self = [super init]))
   {
      self.geometryID = aGeometryID;
      self.mesh = [[[CVMesh alloc] init] autorelease];
      self.existingCombinations = [NSMutableSet set];      
      self.mutableSourcesByID = [NSMutableDictionary dictionary];
      self.mutableVertexInfoByID = [NSMutableDictionary dictionary];
   }
   
   return self;
}


- (void)appendTriangles:(COLLADATrianglesInfo *)triangles;
{
   // Get the vertex positions source and by default get the 
   // other attributes from the same source
   COLLADAVertexInfo *positionVertexInfo = 
      [self.mutableVertexInfoByID objectForKey:
      triangles.vertexSourceID];
   COLLADAVertexInfo *normalVertexInfo = positionVertexInfo;
   COLLADAVertexInfo *texCoordVertexInfo = positionVertexInfo;
   COLLADASourceInfo *positionSource = nil;
   COLLADASourceInfo *normalSource = nil;
   COLLADASourceInfo *texCoordSource = nil;
   
   if(nil == triangles.vertexSourceID ||
      nil == positionVertexInfo)
   {
      NSLog(@"No vertex position available.");
      return;
   }

   positionSource = [self.mutableSourcesByID
      objectForKey:positionVertexInfo.positionSourceID];
   
   if(nil != triangles.normalSourceID)
   {  // Override source for normals
      normalVertexInfo = [self.mutableVertexInfoByID 
         objectForKey:triangles.normalSourceID];
      if(nil != normalVertexInfo)
      {  // There was a <vertices> for this attribute
         normalSource = [self.mutableSourcesByID
            objectForKey:normalVertexInfo.normalSourceID];
      }
      else
      {  // There was no <vertices> so try accessing source 
         // directly
         normalSource = [self.mutableSourcesByID
            objectForKey:triangles.normalSourceID];
      }
   }
   else
   {
      normalSource = [self.mutableSourcesByID
         objectForKey:normalVertexInfo.normalSourceID];
   }
   
   if(nil != triangles.texCoordSourceID)
   {  // Override source for texCoords
      texCoordVertexInfo = [self.mutableVertexInfoByID 
         objectForKey:triangles.texCoordSourceID];
      if(nil != texCoordVertexInfo)
      {  // There was a <vertices> for this attribute
         texCoordSource = [self.mutableSourcesByID
            objectForKey:texCoordVertexInfo.texCoordSourceID];
      }
      else
      {  // There was no <vertices> so try accessing source 
         // directly
         texCoordSource = [self.mutableSourcesByID
            objectForKey:triangles.texCoordSourceID];
      }
   }
   else
   {
      texCoordSource = [self.mutableSourcesByID
         objectForKey:texCoordVertexInfo.texCoordSourceID];
   }
      
   if(nil == positionSource)
   {  //Last ditch: look for position in VERTEX element
      positionSource = [self.mutableSourcesByID
         objectForKey:positionVertexInfo.vertexSourceID];
   } 
   
   if(nil == positionSource)
   {
      NSLog(@"No source for vertex positions.");
      return;
   }
   
     // Save firstIndex for future command  
   const NSUInteger firstIndex = self.nextAvalableIndex;

   //Initialize the pointers to vertex attribute data
   COLLADAVertexAttributePointers pointers;
   pointers.positionCoordsPtr = 
      (UtilityVector3 *)[positionSource.floatData bytes];
   pointers.normalCoordsPtr = 
      (UtilityVector3 *)[normalSource.floatData bytes];
   pointers.texCoord0Ptr = 
      (UtilityVector2 *)[texCoordSource.floatData bytes];
   pointers.texCoord1Ptr = NULL;

   const NSUInteger numberOfIndexGroups = [triangles
      numberOfIndexGroups];
      
   for(NSUInteger i = 0; i < numberOfIndexGroups; i++)
   {  // for each index group
      COLLADAIndexGroup indexGroup = 
         [triangles indexGroupAtIndex:i];
   
      // Append corresponding vertex attributes
      GLushort currentIndex = [self appendIndexGroup:indexGroup
         attributePointers:pointers];
      [self.mesh appendIndex:currentIndex];
   }
   
   // Add command to draw the triangles just added 
   [self.mesh appendCommand:GL_TRIANGLES 
      firstIndex:firstIndex
      numberOfIndices:(self.nextAvalableIndex - 
         firstIndex)
      materialName:triangles.materialID];
}

   
- (GLushort)appendIndexGroup:(COLLADAIndexGroup)anIndexGroup
   attributePointers:(COLLADAVertexAttributePointers)pointers;
{
   NSParameterAssert(NULL != pointers.positionCoordsPtr);
   
   GLushort currentIndex = self.nextAvalableIndex;
   
   /***** I've never seen an existing combination found, so why
   bother checking?
   SceneGeometryBuilderCombination *candidateCombination =
      [[[SceneGeometryBuilderCombination alloc] init] autorelease];
   candidateCombination.indexGroup = anIndexGroup;
   
   SceneGeometryBuilderCombination *existingCombination =
      [self.existingCombinations member:candidateCombination];
      
   if(existingCombination)
   {  // The requested combination of attributes exists
      // return the exiting index within mesh
      currentIndex = existingCombination.indexInMesh;
   }
   else
   {  // Add new attributes combination to mesh
      candidateCombination.indexInMesh = currentIndex;
      
      // Make note that the new combination exists
      [self.existingCombinations addObject:candidateCombination];
   }
   *****/
   
   if(self.nextAvalableIndex >= 0xFFFF)
   {
      NSLog(@"Attempt to overflow 16 bit index range: %@",
         @"vertex data discarded");
   }
   else
   {
      self.nextAvalableIndex += 1;
      
      // Initialize the new vertex attributes from separate
      // arrays using separate indices
      CVMeshVertex newVertex;
      newVertex.position.x = NAN;
      newVertex.position.y = NAN;
      newVertex.position.z = NAN;
      newVertex.normal.x = NAN;
      newVertex.normal.y = NAN;
      newVertex.normal.z = NAN;
      newVertex.texCoords0.x = 0;
      newVertex.texCoords0.y = 0;
      newVertex.texCoords1.x = 0;
      newVertex.texCoords1.y = 0;
      
      {  // Store position
         UtilityVector3 position = 
            pointers.positionCoordsPtr[anIndexGroup.positionIndex];
               
         newVertex.position = position;
      }
      
      if(NULL != pointers.normalCoordsPtr)
      {
         // Store normal vector (renormalize just in case)
         UtilityVector3 normal = 
            pointers.normalCoordsPtr[anIndexGroup.normalIndex];
            
         newVertex.normal = UtilityVector3Normalize(normal);
      }
      if(NULL != pointers.texCoord0Ptr)
      {
         newVertex.texCoords0 = 
            pointers.texCoord0Ptr[anIndexGroup.texCoord0Index];
      }
      if(NULL != pointers.texCoord1Ptr)
      {
         newVertex.texCoords1 = 
            pointers.texCoord1Ptr[anIndexGroup.texCoord1Index];
      }
      
      // Add the new combination of vertex attributes to the mesh
      [self.mesh appendVertex:newVertex];
   }
   
   return currentIndex;
}

@end


/////////////////////////////////////////////////////////////////
//  
@implementation SceneGeometryBuilderCombination

@synthesize indexGroup;
@synthesize indexInMesh;

/////////////////////////////////////////////////////////////////
//
- (NSUInteger)hash;
{
   NSUInteger result = indexGroup.normalIndex;
   
   result = result | (indexGroup.positionIndex << 16);
   
   return result;
}


/////////////////////////////////////////////////////////////////
//
- (BOOL)isEqual:(id)object;
{
   BOOL result = (self == object);
   
   if(result && [object respondsToSelector:@selector(indexGroup)])
   {
      COLLADAIndexGroup otherIndexGroup = [object indexGroup];
      
      result = 
         (otherIndexGroup.positionIndex == indexGroup.positionIndex) &&
         (otherIndexGroup.normalIndex == indexGroup.normalIndex) &&
         (otherIndexGroup.texCoord0Index == indexGroup.texCoord0Index) &&
         (otherIndexGroup.texCoord1Index == indexGroup.texCoord1Index);
   }
   
   return result;
}

@end


/////////////////////////////////////////////////////////////////
//  
@implementation COLLADATrianglesInfo

@synthesize materialID;
@synthesize vertexSourceID;
@synthesize normalSourceID;
@synthesize texCoordSourceID;
@synthesize vertexOffset;
@synthesize normalOffset;
@synthesize texCoordOffset;
@synthesize indices;
@synthesize numberOfSources;

- (NSUInteger)numberOfIndexGroups;
{
   NSAssert(0 < numberOfSources, @"No sources for index groups");
   return [indices length] / (numberOfSources * sizeof(GLushort));
}


- (COLLADAIndexGroup)indexGroupAtIndex:(NSUInteger)anIndex;
{
   NSAssert(anIndex < [self numberOfIndexGroups], 
      @"Index out of range");
   GLushort *indexPtr = (GLushort *)[indices bytes];
   indexPtr += (anIndex * numberOfSources);
   
   COLLADAIndexGroup result;
   result.positionIndex = indexPtr[vertexOffset];
   result.normalIndex = indexPtr[normalOffset];
   result.texCoord0Index = indexPtr[texCoordOffset];
   result.texCoord1Index = 0;
   
   return result;
}

@end


/////////////////////////////////////////////////////////////////
//  
@implementation COLLADAVertexInfo

@synthesize verticesID;
@synthesize positionSourceID;
@synthesize normalSourceID;
@synthesize texCoordSourceID;
@synthesize vertexSourceID;

@end


/////////////////////////////////////////////////////////////////
//  
@implementation COLLADASourceInfo

@synthesize floatData;
@synthesize sourceID;
@synthesize stride;

@end
