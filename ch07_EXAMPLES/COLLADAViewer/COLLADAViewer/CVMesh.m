//
//  CVMesh.m
//  COLLADAViewer
//

#import "CVMesh.h"


@interface CVMesh ()

@property (strong, nonatomic, readwrite) NSMutableData
   *mutableVertexData;
@property (retain, nonatomic, readwrite) NSMutableData
   *mutableIndexData;
@property (retain, nonatomic, readwrite) NSArray
   *commands;

@end


@implementation CVMesh

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
      commands = [commands arrayByAddingObjectsFromArray:
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
   return [self.vertexData length] / sizeof(CVMeshVertex);
}


/////////////////////////////////////////////////////////////////
//
- (NSString *)description
{
   NSMutableString *result = [NSMutableString string];
   const NSUInteger count = [self numberOfVertices];
   
   for(int i = 0; i < count; i++)
   {
      CVMeshVertex currentVertex = [self vertexAtIndex:i];
      
      [result appendFormat:
         @"p{%0.2f, %0.2f, %0.2f} n{%0.2f, %0.2f, %0.2f} t0{%0.2f %0.2f} t1{%0.2f %0.2f}\n", 
         currentVertex.position.v[0],
         currentVertex.position.v[1],
         currentVertex.position.v[2],
         currentVertex.normal.v[0],
         currentVertex.normal.v[1],
         currentVertex.normal.v[2],
         currentVertex.texCoords0.v[0],
         currentVertex.texCoords0.v[1],
         currentVertex.texCoords1.v[0],
         currentVertex.texCoords1.v[1]];
   }
   
   return result;
}


/////////////////////////////////////////////////////////////////
//
+ (NSSet *)keyPathsForValuesAffectingNumberOfOfIndices
{
   return [NSSet setWithObject:@"indexData"];
}


/////////////////////////////////////////////////////////////////
//
- (NSUInteger)numberOfIndices;
{
   return (NSUInteger)([self.indexData length] / sizeof(GLushort));
}


/////////////////////////////////////////////////////////////////
//
+ (NSSet *)keyPathsForValuesAffectingIndexdata
{
   return [NSSet setWithObject:@"mutableIndexData"];
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
+ (NSSet *)keyPathsForValuesAffectingVertexdata
{
   return [NSSet setWithObject:@"mutableVertexData"];
}


/////////////////////////////////////////////////////////////////
//
- (NSData *)vertexData
{
   return self.mutableVertexData;
}


/////////////////////////////////////////////////////////////////
//
- (CVMeshVertex)vertexAtIndex:(NSUInteger)anIndex;
{
   const NSUInteger count = [self numberOfVertices];

   NSParameterAssert(anIndex < count);
      
   const CVMeshVertex *bytes = 
      (const CVMeshVertex *)[self.vertexData bytes];
   
   return bytes[anIndex];
}


/////////////////////////////////////////////////////////////////
//
- (void)setVertex:(CVMeshVertex)aVertex 
   atIndex:(NSUInteger)anIndex;
{
   const NSUInteger count = [self numberOfVertices];

   NSParameterAssert(anIndex < count);
      
   CVMeshVertex *mutableBytes = 
      (CVMeshVertex *)[self.mutableVertexData mutableBytes];
   mutableBytes[anIndex] = aVertex;
}


/////////////////////////////////////////////////////////////////
//
- (void)appendVertex:(CVMeshVertex)aVertex;
{
   [mutableVertexData appendBytes:&aVertex 
      length:sizeof(aVertex)];
}


/////////////////////////////////////////////////////////////////
//
- (id)copyWithTransform:(UtilityMatrix4)transforms;
{
   CVMesh *result = [[CVMesh alloc] init];
   
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
      CVMeshVertex vertex = [self vertexAtIndex:i];
      
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
- (void)appendMesh:(CVMesh *)aMesh;
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
         [NSMutableDictionary dictionaryWithDictionary:commandDictionary];
      NSUInteger newCommandFirstIndex = 
         [[commandDictionary objectForKey:@"firstIndex"]
            unsignedIntegerValue] + startNumberOfIndices;
      
      [newCommandDictionary setObject:[NSNumber numberWithUnsignedInteger:newCommandFirstIndex] forKey:@"firstIndex"]; 
        
      [self appendCommandDictionary:newCommandDictionary];
   }
}


/////////////////////////////////////////////////////////////////
//
- (void)prepareToDraw;
{
   CVMeshVertex *vertexAttributes = (CVMeshVertex *)
      [self.vertexData bytes];
            
   // Set pointers
   glEnableClientState(GL_VERTEX_ARRAY);                 
   glVertexPointer(3, 
      GL_FLOAT, 
      sizeof(CVMeshVertex), 
      (GLbyte *)vertexAttributes + 
         offsetof(CVMeshVertex, position));
   
   glEnableClientState(GL_NORMAL_ARRAY); 
   glNormalPointer(GL_FLOAT, 
      sizeof(CVMeshVertex), 
      (GLbyte *)vertexAttributes + 
         offsetof(CVMeshVertex, normal));
   
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
   glTexCoordPointer(2,
      GL_FLOAT, 
      sizeof(CVMeshVertex), 
      (GLbyte *)vertexAttributes + 
         offsetof(CVMeshVertex, texCoords0));
}


/////////////////////////////////////////////////////////////////
//
- (NSUInteger)numberOfVerticesForCommandsInRange:(NSRange)aRange;
{
   NSInteger result = 0;
   
   if(0 < aRange.length)
   {
      const NSUInteger lastCommandIndex = 
         (aRange.location + aRange.length) - 1;
      const NSUInteger numberOfCommands = 
         [self.commands count];

      NSParameterAssert(aRange.location < numberOfCommands);
      NSParameterAssert(lastCommandIndex < numberOfCommands);
                
      for(NSUInteger i = aRange.location; 
         i <= lastCommandIndex; i++)
      {
         NSDictionary *currentCommand = 
            [self.commands objectAtIndex:i];
         result += [[currentCommand 
            objectForKey:@"numberOfIndices"] unsignedIntegerValue];
      }
   }
   
   return result;
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

      GLfloat   diffuseColorComponents[4];
      diffuseColorComponents[0] = 1.0f;
      diffuseColorComponents[1] = 1.0f;
      diffuseColorComponents[2] = 1.0f;
      diffuseColorComponents[3] = 1.0f;  // Opaque      
      glMaterialfv(GL_FRONT, GL_AMBIENT_AND_DIFFUSE, 
         diffuseColorComponents);
      
      GLfloat   specularColorComponents[4];
      specularColorComponents[0] = 0.0f;
      specularColorComponents[1] = 0.0f;
      specularColorComponents[2] = 0.0f;
      specularColorComponents[3] = 1.0f;  // Opaque      
      glMaterialfv(GL_FRONT, GL_SPECULAR, 
         specularColorComponents);

      glEnable(GL_TEXTURE_2D);
                
      for(NSUInteger i = aRange.location; 
         i <= lastCommandIndex; i++)
      {
         NSDictionary *currentCommand = 
            [self.commands objectAtIndex:i];
         size_t  numberOfIndices = (size_t)[[currentCommand 
            objectForKey:@"numberOfIndices"] unsignedIntegerValue];
         size_t  firstIndex = (size_t)[[currentCommand 
            objectForKey:@"firstIndex"] unsignedIntegerValue];
         GLenum mode = (GLenum)[[currentCommand 
            objectForKey:@"command"] unsignedIntegerValue];
         GLushort *indices = (GLushort *)
            [self.indexData bytes];
           
         glEnableClientState(GL_VERTEX_ARRAY);                 
         glEnableClientState(GL_NORMAL_ARRAY); 
         glEnableClientState(GL_TEXTURE_COORD_ARRAY);
         glEnable(GL_LIGHTING);
         glDrawElements(mode,
                        (GLsizei)numberOfIndices,
                        GL_UNSIGNED_SHORT,
                        indices + firstIndex);      
      }
   }
}


/////////////////////////////////////////////////////////////////
//
- (void)drawAllCommands;
{
   NSRange allCommandsRange = {0, [self.commands count]};
   
   [self drawCommandsInRange:allCommandsRange];
}


/////////////////////////////////////////////////////////////////
//
- (void)drawNormalsCommandsInRange:(NSRange)aRange
   length:(GLfloat)lineLength;
{
   if(0 < aRange.length)
   {
      const NSUInteger lastCommandIndex = 
         (aRange.location + aRange.length) - 1;
      const NSUInteger numberOfCommands = 
         [self.commands count];

      NSParameterAssert(aRange.location < numberOfCommands);
      NSParameterAssert(lastCommandIndex < numberOfCommands);

      CVMeshVertex *vertexAttributes = (CVMeshVertex *)
         [self.vertexData bytes];
               
      glDisable(GL_LIGHTING);
      glDisable(GL_TEXTURE_2D);
      glColor4f(1.0f, 1.0f, 0.0f, 1.0f);
      
      glDisableClientState(GL_VERTEX_ARRAY);                 
      glDisableClientState(GL_NORMAL_ARRAY); 
      glDisableClientState(GL_TEXTURE_COORD_ARRAY);
      
      for(NSUInteger i = aRange.location; 
         i <= lastCommandIndex; i++)
      {
         NSDictionary *currentCommand = 
            [self.commands objectAtIndex:i];
         size_t  numberOfIndices = (size_t)[[currentCommand 
            objectForKey:@"numberOfIndices"] unsignedIntegerValue];
         size_t  firstIndex = (size_t)[[currentCommand 
            objectForKey:@"firstIndex"] unsignedIntegerValue];
         GLushort *indices = (GLushort *)
            [self.indexData bytes];
        
         for(int j = 0; j < numberOfIndices; j++)
         {
            GLushort  index = indices[j + firstIndex];
            CVMeshVertex currentVertex = vertexAttributes[index];
            GLfloat   vertexBuffer[6];
            
            vertexBuffer[0] = currentVertex.position.x;
            vertexBuffer[1] = currentVertex.position.y;
            vertexBuffer[2] = currentVertex.position.z;
            vertexBuffer[3] = vertexBuffer[0] + 
               (lineLength * currentVertex.normal.x);
            vertexBuffer[4] = vertexBuffer[1] + 
               (lineLength * currentVertex.normal.y);
            vertexBuffer[5] = vertexBuffer[2] + 
               (lineLength * currentVertex.normal.z);
            
            glEnableClientState(GL_VERTEX_ARRAY);                 
            glVertexPointer(3, 
               GL_FLOAT, 
               3 * sizeof(GLfloat), 
               vertexBuffer);
            glDrawArrays(GL_LINES, 0, 2);
         }
      }
   }
}


/////////////////////////////////////////////////////////////////
//
- (void)drawNormalsAllCommandsLength:(GLfloat)lineLength
{
   NSRange allCommandsRange = {0, [self.commands count]};
   
   [self drawNormalsCommandsInRange:allCommandsRange
      length:lineLength];
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

      CVMeshVertex *vertexAttributes = (CVMeshVertex *)
         [self.vertexData bytes];
      BOOL hasFoundFirstVertex = NO;
               
      for(NSUInteger i = aRange.location; 
         i <= lastCommandIndex; i++)
      {
         NSDictionary *currentCommand = 
            [self.commands objectAtIndex:i];
         size_t  numberOfIndices = (size_t)[[currentCommand 
            objectForKey:@"numberOfIndices"] unsignedIntegerValue];
         size_t  firstIndex = (size_t)[[currentCommand 
            objectForKey:@"firstIndex"] unsignedIntegerValue];
         GLushort *indices = (GLushort *)
            [self.indexData bytes];
         
         if(0 < numberOfIndices && !hasFoundFirstVertex)
         {
            hasFoundFirstVertex = YES;
            GLushort  index = indices[0 + firstIndex];
            CVMeshVertex currentVertex = vertexAttributes[index];
            
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
            CVMeshVertex currentVertex = vertexAttributes[index];
            
            minCornerVertexPosition[0] = MIN(currentVertex.position.x, minCornerVertexPosition[0]);
            minCornerVertexPosition[1] = MIN(currentVertex.position.y, minCornerVertexPosition[1]);
            minCornerVertexPosition[2] = MIN(currentVertex.position.z, minCornerVertexPosition[2]);
            maxCornerVertexPosition[0] = MAX(currentVertex.position.x, maxCornerVertexPosition[0]);
            maxCornerVertexPosition[1] = MAX(currentVertex.position.y, maxCornerVertexPosition[1]);
            maxCornerVertexPosition[2] = MAX(currentVertex.position.z, maxCornerVertexPosition[2]);
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
