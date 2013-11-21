//
//  TEMesh.m
//  TerrainEditor
//

#import "TEMesh.h"
#import "TEModelEffect.h"

@interface TEMesh ()

@property (strong, nonatomic, readwrite) NSMutableData
   *mutableVertexData;
@property (strong, nonatomic, readwrite) NSMutableData
   *mutableIndexData;
@property (strong, nonatomic, readwrite) NSArray
   *commands;

@end


@implementation TEMesh

@synthesize mutableVertexData;
@synthesize mutableIndexData;
@synthesize commands;


/////////////////////////////////////////////////////////////////
// Designated initializer
- (id)init
{
   if(nil != (self=[super init]))
   {
      mutableVertexData = [[NSMutableData alloc] init];
      mutableIndexData = [[NSMutableData alloc] init];
      commands = [NSArray array];
   }
   
   return self;
}


/////////////////////////////////////////////////////////////////
//
- (id)initWithPlistRepresentation:(NSDictionary *)aDictionary;
{
   if(nil != (self=[self init]))
   {
      [mutableVertexData appendData:[aDictionary
         objectForKey:@"vertexAttributeData"]];
      [mutableIndexData appendData:[aDictionary
         objectForKey:@"indexData"]];
      self.commands = [commands arrayByAddingObjectsFromArray:
         [aDictionary objectForKey:@"commands"]];
   }
   
   return self;
}


/////////////////////////////////////////////////////////////////
// 
- (id)appendVertexData:(NSData *)someVertexData
   indexData:(NSData *)someIndexData;
{
   if(nil != (self=[self init]))
   {
      [mutableVertexData appendData:someVertexData];
      [mutableIndexData appendData:someIndexData];
   }
   
   return self;
}


/////////////////////////////////////////////////////////////////
//
- (void)appendIndex:(GLushort)index;
{
   [self.mutableIndexData appendBytes:&index 
      length:sizeof(index)];
}


/////////////////////////////////////////////////////////////////
//
- (void)appendCommandDictionary:(NSDictionary *)aDictionary
{
  self.commands = 
     [self.commands arrayByAddingObject:aDictionary];
  //NSLog(@"%p %@", self, self.commands);
}


/////////////////////////////////////////////////////////////////
//
- (void)appendCommand:(GLenum)command 
   firstIndex:(size_t)firstIndex
   numberOfIndices:(size_t)numberOfIndices
   materialName:(NSString *)materialName;
{
   NSDictionary *renderingDictionary = 
      [NSDictionary dictionaryWithObjectsAndKeys:
         [NSNumber numberWithUnsignedInteger:firstIndex], 
            @"firstIndex",
         [NSNumber numberWithUnsignedInteger:numberOfIndices], 
            @"numberOfIndices",
         [NSNumber numberWithUnsignedInteger:command], 
            @"command",
         materialName,
            @"materialName",
         nil];
        
   [self appendCommandDictionary:renderingDictionary];
}


/////////////////////////////////////////////////////////////////
//
- (NSDictionary *)plistRepresentation
{
   return [NSDictionary dictionaryWithObjectsAndKeys:
      self.mutableVertexData, @"vertexAttributeData", 
      self.mutableIndexData, @"indexData", 
      self.commands, @"commands", 
      nil];
}


/////////////////////////////////////////////////////////////////
//
- (NSUInteger)numberOfVertices;
{
   return [self.vertexData length] / sizeof(TEMeshVertex);
}


/////////////////////////////////////////////////////////////////
//
- (NSString *)description
{
   NSMutableString *result = [NSMutableString string];
   const NSUInteger count = [self numberOfVertices];
   
   for(int i = 0; i < count; i++)
   {
      TEMeshVertex currentVertex = [self vertexAtIndex:i];
      
      [result appendFormat:
         @"p{%0.2f, %0.2f, %0.2f} n{%0.2f, %0.2f, %0.2f} t0{%0.2f %0.2f}\n", 
         currentVertex.position.v[0],
         currentVertex.position.v[1],
         currentVertex.position.v[2],
         currentVertex.normal.v[0],
         currentVertex.normal.v[1],
         currentVertex.normal.v[2],
         currentVertex.texCoords0.v[0],
         currentVertex.texCoords0.v[1]];
   }
   
   return result;
}


/////////////////////////////////////////////////////////////////
//
- (NSUInteger)numberOfIndices;
{
   return (NSUInteger)([self.indexData length] / 
      sizeof(GLushort));
}


/////////////////////////////////////////////////////////////////
//
- (NSData *)indexData
{
   return self.mutableIndexData;
}


/////////////////////////////////////////////////////////////////
//
- (GLushort)indexAtIndex:(NSUInteger)anIndex;
{
   const NSUInteger count = [self numberOfIndices];

   NSParameterAssert(anIndex < count);
      
   const GLushort *bytes = 
      (const GLushort *)[self.indexData bytes];
   
   return bytes[anIndex];
}


/////////////////////////////////////////////////////////////////
//
- (NSData *)vertexData
{
   return self.mutableVertexData;
}


/////////////////////////////////////////////////////////////////
//
- (TEMeshVertex)vertexAtIndex:(NSUInteger)anIndex;
{
   const NSUInteger count = [self numberOfVertices];

   NSParameterAssert(anIndex < count);
      
   const TEMeshVertex *bytes = 
      (const TEMeshVertex *)[self.vertexData bytes];
   
   return bytes[anIndex];
}


/////////////////////////////////////////////////////////////////
//
- (void)setVertex:(TEMeshVertex)aVertex 
   atIndex:(NSUInteger)anIndex;
{
   const NSUInteger count = [self numberOfVertices];

   NSParameterAssert(anIndex < count);
      
   TEMeshVertex *mutableBytes = 
      (TEMeshVertex *)[self.mutableVertexData mutableBytes];
   mutableBytes[anIndex] = aVertex;
}


/////////////////////////////////////////////////////////////////
//
- (void)appendVertex:(TEMeshVertex)aVertex;
{
   [mutableVertexData appendBytes:&aVertex 
      length:sizeof(aVertex)];
}


/////////////////////////////////////////////////////////////////
//
- (id)copyWithTransform:(UtilityMatrix4)transforms;
{
   TEMesh *result = [[TEMesh alloc] init];
   
   BOOL isInvertible;
   UtilityMatrix3 normalMatrix = UtilityMatrix4GetMatrix3(
      UtilityMatrix4Transpose(UtilityMatrix4Invert(
         transforms, &isInvertible)));
   
   if(!isInvertible)
   {
      normalMatrix = UtilityMatrix4GetMatrix3(
         UtilityMatrix4Transpose(transforms));
   }

   const NSUInteger count = self.numberOfIndices;
   
   // Transform all the positions and normals while copying
   // vertex attributes into result.
   // Renormalizes normals.
   for(NSUInteger i = 0; i < count; i++)
   {
      TEMeshVertex vertex = [self vertexAtIndex:i];
      
      vertex.position = 
         UtilityMatrix4MultiplyVector3WithTranslation(
            transforms, vertex.position);
      vertex.normal = UtilityVector3Normalize(
         UtilityMatrix3MultiplyVector3(normalMatrix, 
         vertex.normal));
         
      [result appendVertex:vertex];
   }
   
   // Copy indices and commands which remain identical but 
   // can't be shared.
   [result.mutableIndexData appendData:self.indexData];
   result.commands = [[self.commands copy] autorelease];
   
   return result;
}


/////////////////////////////////////////////////////////////////
//
- (void)appendMesh:(TEMesh *)aMesh;
{
   NSParameterAssert(nil != aMesh);
   const NSUInteger  startNumberOfIndices = self.numberOfIndices;
   
   // Append vertex attribute data for the aMesh
   [self.mutableVertexData appendData:aMesh.vertexData];
   
   // Offset all of aMesh's indices while appending them
   const NSUInteger numberOfIndicesToAdd = aMesh.numberOfIndices;
   for(NSUInteger i = 0; i < numberOfIndicesToAdd; i++)
   {
      NSUInteger offsetIndex = 
         startNumberOfIndices + [aMesh indexAtIndex:i];
      NSAssert(65536 > offsetIndex, @"index overflow");
      
      [self appendIndex:offsetIndex];
   }

   // Append aMesh's commands
   for(NSDictionary *commandDictionary in aMesh.commands)
   {
      NSMutableDictionary *newCommandDictionary = 
         [NSMutableDictionary dictionaryWithDictionary:
         commandDictionary];
      NSUInteger newCommandFirstIndex = 
         [[commandDictionary objectForKey:@"firstIndex"]
            unsignedIntegerValue] + startNumberOfIndices;
      
      [newCommandDictionary setObject:[NSNumber 
         numberWithUnsignedInteger:newCommandFirstIndex] 
         forKey:@"firstIndex"]; 
        
      [self appendCommandDictionary:newCommandDictionary];
   }
}


/////////////////////////////////////////////////////////////////
//
- (void)prepareToDraw;
{
   TEMeshVertex *vertexAttributes = (TEMeshVertex *)
      [self.vertexData bytes];
            
   glBindBuffer(GL_ARRAY_BUFFER, 0);

   // Set pointers
   glEnableVertexAttribArray(TEModelPositionAttrib); 
   glVertexAttribPointer(
      TEModelPositionAttrib,
      3, 
      GL_FLOAT,
      GL_FALSE, 
      sizeof(TEMeshVertex), 
      (GLbyte *)vertexAttributes + 
         offsetof(TEMeshVertex, position));
   
   glEnableVertexAttribArray(TEModelNormalAttrib); 
   glVertexAttribPointer(
      TEModelNormalAttrib,
      3, 
      GL_FLOAT,
      GL_FALSE, 
      sizeof(TEMeshVertex), 
      (GLbyte *)vertexAttributes + 
         offsetof(TEMeshVertex, normal));
   
   glEnableVertexAttribArray(TEModelTexCoords0Attrib); 
   glVertexAttribPointer(
      TEModelTexCoords0Attrib,
      2,
      GL_FLOAT, 
      GL_FALSE, 
      sizeof(TEMeshVertex), 
      (GLbyte *)vertexAttributes + 
         offsetof(TEMeshVertex, texCoords0));

   glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
}


/////////////////////////////////////////////////////////////////
//
- (void)prepareToPick;
{
   TEMeshVertex *vertexAttributes = (TEMeshVertex *)
      [self.vertexData bytes];
            
   glBindBuffer(GL_ARRAY_BUFFER, 0);

   // Set pointers
   glEnableVertexAttribArray(TEModelPositionAttrib); 
   glVertexAttribPointer(
      TEModelPositionAttrib,
      3, 
      GL_FLOAT,
      GL_FALSE, 
      sizeof(TEMeshVertex), 
      (GLbyte *)vertexAttributes + 
         offsetof(TEMeshVertex, position));
   
   glDisableVertexAttribArray(TEModelNormalAttrib); 
   glEnableVertexAttribArray(TEModelTexCoords0Attrib); 
   glVertexAttribPointer(
      TEModelTexCoords0Attrib,
      2,
      GL_FLOAT, 
      GL_FALSE, 
      sizeof(TEMeshVertex), 
      (GLbyte *)vertexAttributes + 
         offsetof(TEMeshVertex, texCoords0));

   glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
}


/////////////////////////////////////////////////////////////////
//
- (void)drawCommandsInRange:(NSRange)aRange;
{
   if(0 < aRange.length)
   {
      const NSUInteger lastCommandIndex = 
         (aRange.location + aRange.length) - 1;
      const NSUInteger numberOfCommands = 
         [self.commands count];

      NSParameterAssert(aRange.location < numberOfCommands);
      NSParameterAssert(lastCommandIndex < numberOfCommands);

      const GLushort *indices = (const GLushort *)
         [self.indexData bytes];
                
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
         GLenum mode = (GLenum)[[currentCommand 
            objectForKey:@"command"] unsignedIntegerValue];
           
         glDrawElements(
            mode,
            (GLsizei)numberOfIndices,
            GL_UNSIGNED_SHORT,
            indices + firstIndex);      
      }
   }
}


/////////////////////////////////////////////////////////////////
//
- (void)drawBoundingBoxStringForCommandsInRange:
   (NSRange)aRange;
{
   if(0 < aRange.length)
   {
      const NSUInteger lastCommandIndex = 
         (aRange.location + aRange.length) - 1;
      const NSUInteger numberOfCommands = 
         [self.commands count];

      NSParameterAssert(aRange.location < numberOfCommands);
      NSParameterAssert(lastCommandIndex < numberOfCommands);

      const GLushort *indices = (const GLushort *)
         [self.indexData bytes];
                
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
           
         glDrawElements(
            GL_LINE_STRIP,
            (GLsizei)numberOfIndices,
            GL_UNSIGNED_SHORT,
            indices + firstIndex);      
      }
   }
}


/////////////////////////////////////////////////////////////////
//
- (NSString *)axisAlignedBoundingBoxStringForCommandsInRange:
   (NSRange)aRange;
{
   GLfloat minCornerVertexPosition[3] = {0.0f, 0.0f, 0.0f};
   GLfloat maxCornerVertexPosition[3] = {0.0f, 0.0f, 0.0f};
      
   if(0 < aRange.length)
   {
      const NSUInteger lastCommandIndex = 
         (aRange.location + aRange.length) - 1;
      const NSUInteger numberOfCommands = 
         [self.commands count];

      NSParameterAssert(aRange.location < numberOfCommands);
      NSParameterAssert(lastCommandIndex < numberOfCommands);

      TEMeshVertex *vertexAttributes = (TEMeshVertex *)
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
            TEMeshVertex currentVertex = vertexAttributes[index];
            
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
            TEMeshVertex currentVertex = vertexAttributes[index];
            
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
//
- (NSString *)axisAlignedBoundingBoxString;
{
   NSRange allCommandsRange = {0, [self.commands count]};
   
   return [self axisAlignedBoundingBoxStringForCommandsInRange:
      allCommandsRange];
}

@end
