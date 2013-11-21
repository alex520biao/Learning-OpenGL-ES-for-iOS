//
//  UtilityMesh.m
//  
//

#import "UtilityMesh.h"

@interface UtilityMesh ()

@property (strong, nonatomic, readonly) 
   NSMutableData *mutableVertexData;
@property (strong, nonatomic, readonly) 
   NSMutableData *mutableIndexData;
@property (strong, nonatomic, readwrite) 
   NSArray *commands;
@property (assign, nonatomic, readwrite) 
   GLuint indexBufferID;
@property (assign, nonatomic, readwrite) 
   GLuint vertexBufferID;
@property (assign, nonatomic, readwrite) 
   GLuint vertexArrayID;

@end


@implementation UtilityMesh

@synthesize mutableVertexData = mutableVertexData_;
@synthesize mutableIndexData = mutableIndexData_;
@synthesize extraVertexData = extraVertexData_;
@synthesize commands = commands_;
@synthesize indexBufferID = indexBufferID_;
@synthesize vertexBufferID = vertexBufferID_;
@synthesize vertexArrayID = vertexArrayID_;
@synthesize shouldUseVAOExtension = shouldUseVAOExtension_;


/////////////////////////////////////////////////////////////////
// Designated initializer
- (id)init
{
   if(nil != (self=[super init]))
   {
      mutableVertexData_ = [[NSMutableData alloc] init];
      mutableIndexData_ = [[NSMutableData alloc] init];
      commands_ = [NSArray array];
      shouldUseVAOExtension_ = YES;
   }
   
   return self;
}


/////////////////////////////////////////////////////////////////
// Initialize the receiver with values for the keys, 
// "vertexAttributeData", "indexData", and "commands" 
// in aDictionary.
- (id)initWithPlistRepresentation:(NSDictionary *)aDictionary;
{
   if(nil != (self=[self init]))
   {
      [mutableVertexData_ appendData:[aDictionary
         objectForKey:@"vertexAttributeData"]];
      [mutableIndexData_ appendData:[aDictionary
         objectForKey:@"indexData"]];
      commands_ = [commands_ arrayByAddingObjectsFromArray:
         [aDictionary objectForKey:@"commands"]];
   }
   
   return self;
}


/////////////////////////////////////////////////////////////////
//  Deallocate OpenGL resources used by receiver.
- (void)dealloc
{
   glBindVertexArrayOES(0);
   glBindBuffer(GL_ARRAY_BUFFER, 0);
   glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
   
   if(0 != vertexArrayID_)
   {
      glDeleteVertexArraysOES(1, &vertexArrayID_);
      vertexArrayID_ = 0;
   }
   
   if(0 != vertexBufferID_)
   {
      glDeleteBuffers(1, &vertexBufferID_);
      vertexBufferID_ = 0;
   }

   if(0 != vertexExtraBufferID_)
   {
      glDeleteBuffers(1, &vertexExtraBufferID_);
      vertexExtraBufferID_ = 0;
   }

   if(0 != indexBufferID_)
   {
      glDeleteBuffers(1, &indexBufferID_);
      indexBufferID_ = 0;
   }
}


/////////////////////////////////////////////////////////////////
// Returns a dictionary storing "vertexAttributeData", 
// "indexData", and "commands" keys with associated values.
- (NSDictionary *)plistRepresentation
{
   return [NSDictionary dictionaryWithObjectsAndKeys:
      self.mutableVertexData, @"vertexAttributeData", 
      self.mutableIndexData, @"indexData", 
      self.commands, @"commands", 
      nil];
}


/////////////////////////////////////////////////////////////////
// Returns a mutable data object suitable for storing extra 
// attributes per vertex.  The specific extra attributes depend
// on the needs of applications.
- (NSMutableData *)extraVertexData
{
   if(nil == extraVertexData_)
   {
      extraVertexData_ = [NSMutableData data];
   }
   
   return extraVertexData_;
}


/////////////////////////////////////////////////////////////////
// Returns the calculated number of vertices stored by the 
// receiver.
- (NSUInteger)numberOfVertices;
{
   return [self.vertexData length] / sizeof(UtilityMeshVertex);
}


/////////////////////////////////////////////////////////////////
// Returns a string containing information about the vertices
// stored by the receiver.
- (NSString *)description
{
   NSMutableString *result = [NSMutableString string];
   const NSUInteger count = [self numberOfVertices];
   
   for(int i = 0; i < count; i++)
   {
      UtilityMeshVertex currentVertex = [self vertexAtIndex:i];
      
      [result appendFormat:
         @"p{%0.2f, %0.2f, %0.2f} n{%0.2f, %0.2f, %0.2f}}\n", 
         currentVertex.position.v[0],
         currentVertex.position.v[1],
         currentVertex.position.v[2],
         currentVertex.normal.v[0],
         currentVertex.normal.v[1],
         currentVertex.normal.v[2]];
      [result appendFormat:
         @" t0{%0.2f %0.2f}\n", 
         currentVertex.texCoords0.v[0],
         currentVertex.texCoords0.v[1]];
   }
   
   return result;
}


/////////////////////////////////////////////////////////////////
// Returns the calculated number of vertex indices stored by the
// receiver.
- (NSUInteger)numberOfIndices;
{
   return (NSUInteger)([self.indexData length] / 
      sizeof(GLushort));
}


/////////////////////////////////////////////////////////////////
// Returns the receiver's index data. Indices are type GLushort.
- (NSData *)indexData
{
   return self.mutableIndexData;
}


/////////////////////////////////////////////////////////////////
// Returns the receiver's vertex data. Vertices are type 
// UtilityMeshVertex.
- (NSData *)vertexData
{
   return self.mutableVertexData;
}


/////////////////////////////////////////////////////////////////
// Return's the receiver's vertex at the specified index.
- (UtilityMeshVertex)vertexAtIndex:(NSUInteger)anIndex;
{
   NSParameterAssert(anIndex < [self numberOfVertices]);
      
   const UtilityMeshVertex *bytes = 
      (const UtilityMeshVertex *)[self.vertexData bytes];
   
   return bytes[anIndex];
}


/////////////////////////////////////////////////////////////////
// Return's the receiver's index at the specified index.
- (GLushort)indexAtIndex:(NSUInteger)anIndex;
{
   NSParameterAssert(anIndex < [self numberOfIndices]);
      
   const GLushort *bytes = 
      (const GLushort *)[self.indexData bytes];
   
   return bytes[anIndex];
}


/////////////////////////////////////////////////////////////////
// This method returns a string encoding the minimum and maximum
// extents of an axis aligned bounding box enclosing all of the
// receiver's vertices described by the receiver's commands in 
// the specified range.
- (NSString *)axisAlignedBoundingBoxStringForCommandsInRange:
   (NSRange)aRange;
{
   GLfloat minCornerVertexPosition[3] = {0.0f, 0.0f, 0.0f};
   GLfloat maxCornerVertexPosition[3] = {0.0f, 0.0f, 0.0f};
      
   if(0 < aRange.length)
   {
      const NSUInteger lastCommandIndex = 
         (aRange.location + aRange.length) - 1;

      NSParameterAssert(aRange.location < [self.commands count]);
      NSParameterAssert(lastCommandIndex < [self.commands count]);

      UtilityMeshVertex *vertexAttributes = (UtilityMeshVertex *)
         [self.vertexData bytes];
      BOOL hasFoundFirstVertex = NO;
               
      for(NSUInteger i = aRange.location; 
         i <= lastCommandIndex; i++)
      {
         NSDictionary *currentCommand = 
            [self.commands objectAtIndex:i];
         size_t  numberOfIndices = (size_t)[[currentCommand 
            objectForKey:@"numberOfIndices"] 
            unsignedIntegerValue];
         size_t  firstIndex = (size_t)[[currentCommand 
            objectForKey:@"firstIndex"] unsignedIntegerValue];
         GLushort *indices = (GLushort *)
            [self.indexData bytes];
         
         if(0 < numberOfIndices && !hasFoundFirstVertex)
         {
            hasFoundFirstVertex = YES;
            GLushort  index = indices[0 + firstIndex];
            UtilityMeshVertex currentVertex = vertexAttributes[index];
            
            minCornerVertexPosition[0] = currentVertex.position.x;
            minCornerVertexPosition[1] = currentVertex.position.y;
            minCornerVertexPosition[2] = currentVertex.position.z;
            maxCornerVertexPosition[0] = currentVertex.position.x;
            maxCornerVertexPosition[1] = currentVertex.position.y;
            maxCornerVertexPosition[2] = currentVertex.position.z;
         }
         for(int j = 1; j < numberOfIndices; j++)
         {
            GLushort  index = indices[j + firstIndex];
            UtilityMeshVertex currentVertex = vertexAttributes[index];
            
            minCornerVertexPosition[0] = 
               MIN(currentVertex.position.x, 
               minCornerVertexPosition[0]);
            minCornerVertexPosition[1] = 
               MIN(currentVertex.position.y, 
               minCornerVertexPosition[1]);
            minCornerVertexPosition[2] = 
               MIN(currentVertex.position.z, 
               minCornerVertexPosition[2]);
            maxCornerVertexPosition[0] = 
               MAX(currentVertex.position.x, 
               maxCornerVertexPosition[0]);
            maxCornerVertexPosition[1] = 
               MAX(currentVertex.position.y, 
               maxCornerVertexPosition[1]);
            maxCornerVertexPosition[2] = 
               MAX(currentVertex.position.z, 
               maxCornerVertexPosition[2]);
         }
      }
   }
   
   return [NSString stringWithFormat:
      @"{%0.2f, %0.2f, %0.2f},{%0.2f, %0.2f, %0.2f}",
      minCornerVertexPosition[0],
      minCornerVertexPosition[1],
      minCornerVertexPosition[2],
      maxCornerVertexPosition[0],
      maxCornerVertexPosition[1],
      maxCornerVertexPosition[2]];
}


/////////////////////////////////////////////////////////////////
// This method returns a string encoding the minimum and maximum
// extents of an axis aligned bounding box enclosing all of the
// receiver's vertices.
- (NSString *)axisAlignedBoundingBoxString;
{
   NSRange allCommandsRange = {0, [self.commands count]};
   
   return [self axisAlignedBoundingBoxStringForCommandsInRange:
      allCommandsRange];
}

@end


/////////////////////////////////////////////////////////////////
// Constants used to access properties from a drawing
// command dictionary.
NSString *const UtilityMeshCommandNumberOfIndices = 
   @"numberOfIndices";
NSString *const UtilityMeshCommandFirstIndex = 
   @"firstIndex";
