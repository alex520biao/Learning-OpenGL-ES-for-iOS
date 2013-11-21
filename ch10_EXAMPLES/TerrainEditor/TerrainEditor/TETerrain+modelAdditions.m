//
//  TETerrain+modelAdditions.m
//  TerrainEditor
//

#import "TETerrain+modelAdditions.h"
#import "TETerrainTile.h"
#import "TEHeightMap.h"
#import "TEModelPlacement.h"


/////////////////////////////////////////////////////////////////
// Heights in the range 0.0 to 1.0 are scaled to the range,
// 0.0 to TETerrainDeaultMaxHeightScaleFactor to create dramatic
// elevation changes in the rendered mesh.  The value of
// TETerrainDeaultMaxHeightScaleFactor is arbitrary: large values
// produce steeper more mountainous terrain.
static const GLfloat TETerrainDeaultMaxHeightScaleFactor = (35.0f);


/////////////////////////////////////////////////////////////////
// This function returns a pointer to a vector storing the X,Y,Z 
// coordinates the vertex corresponding to the x,z position in 
// terrain. 
static inline const UtilityVector3 *TETerrainPostitionPtrAt
(
 TETerrain *terrain,
 NSData *positionAttributes,
 NSInteger x,
 NSInteger z)
{
   NSCParameterAssert(nil != terrain);
   NSCParameterAssert(nil != positionAttributes);
   NSCParameterAssert(x >= 0 && x < [terrain.width integerValue]);
   NSCParameterAssert(z >= 0 && z < [terrain.length integerValue]);
   
   return 
      ((const UtilityVector3 *)[positionAttributes bytes]) +
      (z * [terrain.width integerValue] + x);
}


/////////////////////////////////////////////////////////////////
// This function returns a pointer through which a vector storing 
// the X,Y,Z coordinates the vertex corresponding to the x,z 
// position in terrain may be modified. 
static inline UtilityVector3 *TETerrainPostitionMutablePtrAt
(
 TETerrain *terrain,
 NSMutableData *positionAttributes,
 NSInteger x,
 NSInteger z)
{
   NSCParameterAssert(nil != terrain);
   NSCParameterAssert(nil != positionAttributes);
   NSCParameterAssert(x >= 0 && x < [terrain.width integerValue]);
   NSCParameterAssert(z >= 0 && z < [terrain.length integerValue]);
   
   return 
      ((UtilityVector3 *)[positionAttributes mutableBytes]) +
      (z * [terrain.width integerValue] + x);
}


/////////////////////////////////////////////////////////////////
// This function returns a pointer to a normal vector for
// the vertex corresponding to the x,z position in 
// terrain. 
static inline const UtilityVector3 *TETerrainNormalPtrAt
(
 TETerrain *terrain,
 NSData *normalData,
 NSInteger x,
 NSInteger z)
{
   NSCParameterAssert(nil != terrain);
   NSCParameterAssert(nil != normalData);
   NSCParameterAssert(x >= 0 && x < [terrain.width integerValue]);
   NSCParameterAssert(z >= 0 && z < [terrain.length integerValue]);
   
   return 
      ((const UtilityVector3 *)[normalData bytes]) +
      (z * [terrain.width integerValue] + x);
}


/////////////////////////////////////////////////////////////////
// This function returns a pointer through which a normal vector 
// for the vertex corresponding to the x,z position in terrain 
// may be modified. 
static inline UtilityVector3 *TETerrainNormalMutablePtrAt
(
 TETerrain *terrain,
 NSMutableData *normalData,
 NSInteger x,
 NSInteger z)
{
   NSCParameterAssert(nil != terrain);
   NSCParameterAssert(nil != normalData);
   NSCParameterAssert(x >= 0 && x < [terrain.width integerValue]);
   NSCParameterAssert(z >= 0 && z < [terrain.length integerValue]);
   
   return 
      ((UtilityVector3 *)[normalData mutableBytes]) +
      (z * [terrain.width integerValue] + x);
}


/////////////////////////////////////////////////////////////////
// This function returns a pointer through which light and 
// texture blending weights corresponding to the x,z 
// position in terrain may be modified. 
static inline unsigned char *TETerrainLightAndWeightsPtrAt
(
 TETerrain *terrain,
 NSMutableData *lightAndWeightsData,
 NSInteger x,
 NSInteger z)
{
   NSCParameterAssert(nil != terrain);
   NSCParameterAssert(nil != lightAndWeightsData);
   NSCParameterAssert(x >= 0 && x < [terrain.width integerValue]);
   NSCParameterAssert(z >= 0 && z < [terrain.length integerValue]);
   
   const NSInteger numBytesPerLightAndWeightsGroup = 4;
   
   return [lightAndWeightsData mutableBytes] +
   ((z * [terrain.width integerValue] + x) * 
    numBytesPerLightAndWeightsGroup);
}


@implementation TETerrain (modelAdditions)


/////////////////////////////////////////////////////////////////
// This method updates the receiver to store vertices 
// corresponding to the heights in aHeightMap. The heights in
// aHeightMap are nominally in the range 0.0 to 1.0. This method
// scales each height in aHeightMap by 
// TETerrainDeaultMaxHeightScaleFactor.
- (void)updateWithHeightMap:(TEHeightMap *)aHeightMap
   metersPerUnit:(GLfloat)aNumber
   heightScaleFactor:(GLfloat)aFactor
   lightDirection:(UtilityVector3)aLightDirection
   inManagedObjectContext:(NSManagedObjectContext *)context;
{
   NSParameterAssert(nil != aHeightMap);
   NSParameterAssert(aHeightMap.isValid);
   NSParameterAssert(0.0f < aNumber);
   
   self.width = [NSNumber numberWithInteger:aHeightMap.width];
   self.length = [NSNumber numberWithInteger:aHeightMap.length];
   self.heightScaleFactor = [NSNumber numberWithFloat:MIN(MAX(1.0f, aFactor), 
      TETerrainDeaultMaxHeightScaleFactor)];
   self.metersPerUnit = [NSNumber numberWithFloat:aNumber];
      
   // Set reasonable default property values
   self.hasWater = [NSNumber numberWithBool:YES];
   self.lightDirectionX = [NSNumber numberWithFloat:aLightDirection.x];
   self.lightDirectionY = [NSNumber numberWithFloat:aLightDirection.y];
   self.lightDirectionZ = [NSNumber numberWithFloat:aLightDirection.z];
   
   // Initialize position attributes
   const NSInteger constLength = aHeightMap.length;
   const NSInteger constWidth = aHeightMap.width;
   const GLfloat constMetersPerUnit = [self.metersPerUnit floatValue];
   const GLfloat constHeightScaleFactor = [self.heightScaleFactor floatValue];
   NSMutableData *mutablePositionData = [NSMutableData data];
   for(NSInteger j = 0; j < constLength; j++)
   {
      for(NSInteger i = 0; i < constWidth; i++)
      {
         GLfloat height = [aHeightMap heightAtXPos:i yPos:j];
         
         const UtilityVector3 position = {
            constMetersPerUnit * i, 
            constMetersPerUnit * constHeightScaleFactor * height, 
            constMetersPerUnit * j
         };
         
         //NSLog(@"%f, %f, %f", position.x, position.y, position.z);
         [mutablePositionData appendBytes:&position 
                            length:sizeof(position)];
      }
   }
   
   self.positionAttributesData = mutablePositionData;
   
   // smooth position height
   for(NSInteger j = 1; j < (constLength - 1); j++)
   {
      for(NSInteger i = 1; i < (constWidth - 1); i++)
      {
         GLfloat height = [self smoothHeightNearXPos:i zPos:j];
         TETerrainPostitionMutablePtrAt(
            self, mutablePositionData, i, j)->y = height;
      }
   }      
}


/////////////////////////////////////////////////////////////////
// This method returns an array of TETerrainTile instances
// that collectively cover the entre terrain. Each Tile is a 
// small rectangualar section of terrain suitable for efficient 
// renderning by OpenGL ES.
- (NSArray *)tiles;
{
   NSMutableArray *tilesArray = [NSMutableArray array];
   const NSInteger constLength = [self.length integerValue];
   const NSInteger constWidth = [self.width integerValue];
   
   for(NSInteger j = 0; j < constLength; 
      j += (TETerrainTileDefaultLength - 1))
   {
      for(NSInteger i = 0; i < constWidth; 
         i += (TETerrainTileDefaultWidth - 1))
      {
         TETerrainTile *tile = [[[TETerrainTile alloc]
           initWithTerrain:self
           tileOriginX:i 
           tileOriginY:j 
           tileWidth:MIN(constWidth - i, 
              TETerrainTileDefaultWidth)
           tileLength:MIN(constLength - j, 
              TETerrainTileDefaultLength)]
         autorelease];

         [tilesArray addObject:tile];
      }
   }
   
   return tilesArray;
}


/////////////////////////////////////////////////////////////////
// 
- (UtilityTextureInfo *)lightTexture;
{
   NSMutableData *mutableLightAndWeightsData = [NSMutableData data];
   NSData *normalData = [self normalData];
   
   NSAssert(nil != normalData, @"Missing normal data");
   
   const UtilityVector3 lightDirection = {
      [self.lightDirectionX floatValue],
      [self.lightDirectionY floatValue],
      [self.lightDirectionZ floatValue]
   };
   
   NSAssert(0 < UtilityVector3LengthSquared(lightDirection),
      @"Light direction not set");
   
   const UtilityVector3 normalizedLightDirection =
      UtilityVector3Normalize(lightDirection);
   const GLfloat diffuseIntensity = 0.7f;
   const GLfloat maximumIntensity = (diffuseIntensity * 255.0f);
   const NSInteger constLength = [self.length integerValue];
   const NSInteger constWidth = [self.width integerValue];
   for(NSInteger j = constLength-1; j >= 0; j--)
   {
      for(NSInteger i = 0; i < constWidth; i++)
      {
         unsigned char lightAndWeightsBytes[4] = 
         {
            0, 0, 0, 0
         };
         UtilityVector3 normal = *TETerrainNormalPtrAt(
            self,
            normalData,
            i,
            j);
         
         lightAndWeightsBytes[3] = 
            maximumIntensity * MAX(0.0f,
            UtilityVector3DotProduct(normal, normalizedLightDirection));
         //NSLog(@"normal:{%f, %f, %f} light:{%f, %f, %f}, bytes:%d",
         //   normal.x, normal.y, normal.z,
         //   normalizedLightDirection.x, normalizedLightDirection.y, normalizedLightDirection.z,
         //   lightAndWeightsBytes[3]);
         [mutableLightAndWeightsData 
            appendBytes:lightAndWeightsBytes 
            length:sizeof(lightAndWeightsBytes)];
      }
   }

   // Create image from data buffer
   CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName( kCGColorSpaceGenericRGBLinear);
   CGContextRef cgContext = CGBitmapContextCreate( 
      [mutableLightAndWeightsData mutableBytes], 
      constWidth, 
      constLength, 
      8, 
      4 * constWidth, 
      colorSpace, 
      kCGImageAlphaPremultipliedLast);
   CGColorSpaceRelease(colorSpace);
   
   CGImageRef imageRef = CGBitmapContextCreateImage(
      cgContext);
   CGContextRelease(cgContext);
   
   UtilityTextureInfo *textureInfo = 
      [UtilityTextureLoader 
         textureWithCGImage:imageRef
         options:nil 
         error:NULL];
   
   /***** Write lights and weights to a file for visual debugging
   [[lightAndWeightsData description] writeToFile:[@"~/lights.txt" stringByExpandingTildeInPath]
      atomically:YES
       encoding:NSUTF8StringEncoding 
       error:NULL];
   [[[[[NSBitmapImageRep alloc] initWithCGImage:imageRef] autorelease] TIFFRepresentation]
      writeToFile:[@"~/lights.tiff" stringByExpandingTildeInPath] 
      atomically:YES];
   *****/

   CGImageRelease(imageRef);
      
   return textureInfo;
}


/////////////////////////////////////////////////////////////////
//  This method returns a texture initialized with deafult
// light and texture blending weights for the receiver. Lights
// are based on the average normal vector for each vertex in the 
// terrain. Blending weighst are initialized to zeros.
- (UtilityTextureInfo *)defaultLightAndWeightsTextureInfo;
{
   NSMutableData *mutableLightAndWeightsData = [NSMutableData data];
   NSData *normalData = [self normalData];
   
   NSAssert(nil != normalData, @"Missing normal data");
   
   const UtilityVector3 lightDirection = {
      [self.lightDirectionX floatValue],
      [self.lightDirectionY floatValue],
      [self.lightDirectionZ floatValue]
   };
   
   NSAssert(0 < UtilityVector3LengthSquared(lightDirection),
      @"Light direction not set");
   
   const UtilityVector3 normalizedLightDirection =
      UtilityVector3Normalize(lightDirection);
   const GLfloat diffuseIntensity = 0.7f;
   const GLfloat maximumIntensity = (diffuseIntensity * 255.0f);
   const NSInteger constLength = [self.length integerValue];
   const NSInteger constWidth = [self.width integerValue];
   for(NSInteger j = constLength-1; j >= 0; j--)
   {
      for(NSInteger i = 0; i < constWidth; i++)
      {
         unsigned char lightAndWeightsBytes[4] = 
         {
            0, 0, 0, 0
         };
         UtilityVector3 normal = *TETerrainNormalPtrAt(
            self,
            normalData,
            i,
            j);
         
         lightAndWeightsBytes[3] = 
            maximumIntensity * MAX(0.0f,
            UtilityVector3DotProduct(normal, normalizedLightDirection));
         //NSLog(@"normal:{%f, %f, %f} light:{%f, %f, %f}, bytes:%d",
         //   normal.x, normal.y, normal.z,
         //   normalizedLightDirection.x, normalizedLightDirection.y, normalizedLightDirection.z,
         //   lightAndWeightsBytes[3]);
         [mutableLightAndWeightsData 
            appendBytes:lightAndWeightsBytes 
            length:sizeof(lightAndWeightsBytes)];
      }
   }

   // Create image from data buffer
   CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName( kCGColorSpaceGenericRGBLinear);
   CGContextRef cgContext = CGBitmapContextCreate( 
      [mutableLightAndWeightsData mutableBytes], 
      constWidth, 
      constLength, 
      8, 
      4 * constWidth, 
      colorSpace, 
      kCGImageAlphaPremultipliedLast);
   CGColorSpaceRelease(colorSpace);
   
   CGImageRef imageRef = CGBitmapContextCreateImage(
      cgContext);
   CGContextRelease(cgContext);
   
   UtilityTextureInfo *textureInfo = 
      [UtilityTextureLoader 
         textureWithCGImage:imageRef
         options:nil 
         error:NULL];
   
   /***** Write lights and weights to a file for visual debugging
   [[lightAndWeightsData description] writeToFile:[@"~/lights.txt" stringByExpandingTildeInPath]
      atomically:YES
       encoding:NSUTF8StringEncoding 
       error:NULL];
   [[[[[NSBitmapImageRep alloc] initWithCGImage:imageRef] autorelease] TIFFRepresentation]
      writeToFile:[@"~/lights.tiff" stringByExpandingTildeInPath] 
      atomically:YES];
   *****/

   CGImageRelease(imageRef);
      
   return textureInfo;
}


/////////////////////////////////////////////////////////////////
//  
- (UtilityTextureInfo *)updatedLightInLightsAndWeightsTextureInfo;
{
   UtilityTextureInfo *originalLightAndWeightsTextureInfo = 
      self.lightAndWeightsTextureInfo;
   NSMutableData *mutableLightAndWeightsData = 
      originalLightAndWeightsTextureInfo.mutableImageData;
   NSData *normalData = [self normalData];
   
   NSAssert(nil != normalData, @"Missing normal data");
   
   const UtilityVector3 lightDirection = {
      [self.lightDirectionX floatValue],
      [self.lightDirectionY floatValue],
      [self.lightDirectionZ floatValue]
   };
   
   NSAssert(0 < UtilityVector3LengthSquared(lightDirection),
      @"Light direction not set");
   
   const UtilityVector3 normalizedLightDirection =
      UtilityVector3Normalize(lightDirection);
   const GLfloat diffuseIntensity = 0.7f;
   const GLfloat maximumIntensity = (diffuseIntensity * 255.0f);
   const NSInteger constLength = [self.length integerValue];
   const NSInteger constWidth = [self.width integerValue];
   for(NSInteger j = constLength-1; j >= 0; j--)
   {
      for(NSInteger i = 0; i < constWidth; i++)
      {
         unsigned char lightAndWeightsBytes[4];
         
         UtilityVector3 normal = *TETerrainNormalPtrAt(
            self,
            normalData,
            i,
            j);
         
         lightAndWeightsBytes[3] = 
            maximumIntensity * MAX(0.0f,
            UtilityVector3DotProduct(normal, normalizedLightDirection));
         //NSLog(@"normal:{%f, %f, %f} light:{%f, %f, %f}, bytes:%d",
         //   normal.x, normal.y, normal.z,
         //   normalizedLightDirection.x, normalizedLightDirection.y, normalizedLightDirection.z,
         //   lightAndWeightsBytes[3]);
         [mutableLightAndWeightsData 
            appendBytes:lightAndWeightsBytes 
            length:sizeof(lightAndWeightsBytes)];
      }
   }
   
   return originalLightAndWeightsTextureInfo;
}


/////////////////////////////////////////////////////////////////
//  
- (void)adjustModelsToTerrain;
{
   NSSet *localModelPlacements = self.modelPlacements;
      
   for(TEModelPlacement *currentPlacement in localModelPlacements)
   {
      GLfloat terrainHeight = [self
         calculatedHeightAtXPos:[currentPlacement.positionX floatValue]
         zPos:[currentPlacement.positionZ floatValue]];
      currentPlacement.positionY = [NSNumber numberWithFloat:terrainHeight];
   }
}


#pragma mark -  Render Support

/////////////////////////////////////////////////////////////////
// This method configures OpenGL ES state by binding buffers, and
// if necessary by passing vertex attribute data to the GPU.
- (void)prepareToDraw;
{
   // Configure attributes
   if(0 == [self.glVertexAttributeBufferID intValue])
   {
      GLuint  glName;
      
      glGenBuffers(1,                // STEP 1
                   &glName);
      glBindBuffer(GL_ARRAY_BUFFER,  // STEP 2
                   glName); 
      glBufferData(                  // STEP 3
                   GL_ARRAY_BUFFER,  // Initialize buffer contents
                   [self.positionAttributesData length], 
                   [self.positionAttributesData bytes],  
                   GL_STATIC_DRAW);            // Hint: cache in GPU memory
      self.glVertexAttributeBufferID = 
         [NSNumber numberWithInt:glName];
   }
   else
   {
      glBindBuffer(GL_ARRAY_BUFFER,  
                   [self.glVertexAttributeBufferID intValue]); 
   }
   glEnableVertexAttribArray(TETerrainPositionAttrib); 
}


/////////////////////////////////////////////////////////////////
// Ths method submits vertex data to OpenGL for each tile in 
// tiles. The pointer to the start of vertex data for each tile
// is set prior to rendering so that the vertex data for each
// tile is within accessible range of a single glDrawElements()
// call per tile.
- (void)drawTiles:(NSArray *)tiles;
{   
   for(TETerrainTile *tile in tiles)
   {  // Set the pointer to the first vertex position in the tile
      glVertexAttribPointer(        
                            TETerrainPositionAttrib,               
                            3, 
                            GL_FLOAT,
                            GL_FALSE, 
                            sizeof(UtilityVector3),
                            ((UtilityVector3 *)NULL) + 
                            (tile.originY * [self.width integerValue]) +
                            tile.originX);
      
      [tile draw];
   }
}


/////////////////////////////////////////////////////////////////
// This method is just like -drawTiles: except that the tile
// vertex data is rendered as lines instead of textured 
// triangles.
- (void)drawTileLines:(NSArray *)tiles;
{
   for(TETerrainTile *tile in tiles)
   {
      // Set the pointer to the first vertex position in the tile
      glEnableVertexAttribArray(TETerrainPositionAttrib); 
      glVertexAttribPointer(        
         TETerrainPositionAttrib,               
         3, 
         GL_FLOAT,
         GL_FALSE, 
         sizeof(UtilityVector3),
         ((UtilityVector3 *)NULL) + 
            (tile.originY * [self.width integerValue]) +
            tile.originX);

      // Draw outlines
      [tile drawLines];
   }
}


/////////////////////////////////////////////////////////////////
// Draws normal lines to help visually debig normal vectors
// generated for the terrain.
- (void)drawNormalsWithData:(NSData *)normalData;
{
   glBindBuffer(GL_ARRAY_BUFFER, 0); 
   
   UtilityVector3 lineBuffer[2];
   const NSInteger constLength = [self.length integerValue];
   const NSInteger constWidth = [self.width integerValue];
   const GLfloat constMetersPerUnit = [self.metersPerUnit floatValue];
   
   for(NSInteger j = 0; j < constLength; j++)
   {
      for(NSInteger i = 0; i < constWidth; i++)
      {
         const UtilityVector3 position = {
            constMetersPerUnit * i, 
            [self heightAtXPos:i zPos:j], 
            constMetersPerUnit * j
         };
         const UtilityVector3 normal =
            *TETerrainNormalPtrAt(self, normalData, i, j);
         
         lineBuffer[0] = position;
         lineBuffer[1] = UtilityVector3Add(position, normal);
         
         glEnableVertexAttribArray(TETerrainPositionAttrib); 
         glVertexAttribPointer(        
            TETerrainPositionAttrib,               
            3, 
            GL_FLOAT,
            GL_FALSE, 
            sizeof(UtilityVector3),
            lineBuffer);
         glDrawArrays(GL_LINES, 0, 2);
      }
   }
}


/////////////////////////////////////////////////////////////////
// Return the height of the terrain at position x,z. 
- (GLfloat)calculatedHeightAtXPos:(GLfloat)x zPos:(GLfloat)z
{
   GLfloat       result = 0.0f;
   
   // First, find out which triangle contains the point 
   UtilityVector3 a= {ceilf(x), 0.0f, ceilf(z)};
   UtilityVector3 b = {ceilf(x), 0.0f, floorf(z)};
   UtilityVector3 c = {floorf(x), 0.0f, ceilf(z)};
   UtilityVector3 d = {floorf(x), 0.0f, floorf(z)};
   UtilityVector3 p = {x, 0.0f, z};
   
   if(UtilityPointIsInTriangle(p, a, b, c))
   {
      float heightA = [self heightAtXPos:a.x zPos:a.z];
      float heightB = [self heightAtXPos:b.x zPos:b.z];
      float heightC = [self heightAtXPos:c.x zPos:c.z];
      
      float fractionX = p.x - floorf(p.x);
      float fractionZ = p.z - floorf(p.z);
      
      // Average of height alon A<->B and <A<->C>
      result = 0.5 * 
         ((fractionX * heightB) + 
         ((1.0f - fractionX) * heightA) + 
         (fractionZ * heightC) + 
         ((1.0f - fractionZ) * heightA)); 
   }
   else
   {
      float heightD = [self heightAtXPos:d.x zPos:d.z];
      float heightB = [self heightAtXPos:b.x zPos:b.z];
      float heightC = [self heightAtXPos:c.x zPos:c.z];
      
      float fractionX = p.x - floorf(p.x);
      float fractionZ = p.z - floorf(p.z);
      
      // Average of height alon D<->B and <D<->C>
      result = 0.5 * 
         ((fractionX * heightB) + 
         ((1.0f - fractionX) * heightD) + 
         (fractionZ * heightC) + 
         ((1.0f - fractionZ) * heightD)); 
   }
      
   return result;
}


/////////////////////////////////////////////////////////////////
// Return the height of the terrain at position x,z. 
- (GLfloat)heightAtXPos:(NSInteger)x zPos:(NSInteger)z
{
   GLfloat       result = 0.0f;
   const NSInteger constLength = [self.length integerValue];
   const NSInteger constWidth = [self.width integerValue];
   
   if(nil != self.positionAttributesData && x < constWidth && 
      z < constLength && 0 <= x && 0 <= z)
   {
      result = TETerrainPostitionPtrAt(
         self, self.positionAttributesData, x, z)->y;
   }
   
   return result;
}


/////////////////////////////////////////////////////////////////
// Return the highest height of the terrain near position x,z. 
- (GLfloat)maxHeightNearXPosMeters:(NSInteger)x 
   zPosMeters:(NSInteger)z;
{
   NSParameterAssert(0 <= x && x < self.widthMeters);
   NSParameterAssert(0 <= z && z < self.lengthMeters);

   const GLfloat constMetersPerUnit = [self.metersPerUnit floatValue];
   NSAssert(0 < constMetersPerUnit, @"Invalid diminesion");
   
   x /= constMetersPerUnit;
   z /= constMetersPerUnit;
   
   GLfloat       maxNearbyHeight = [self heightAtXPos:x zPos:z];
   maxNearbyHeight = MAX(maxNearbyHeight, 
                         [self heightAtXPos:x+1 zPos:z]);
   maxNearbyHeight = MAX(maxNearbyHeight, 
                         [self heightAtXPos:x-1 zPos:z]);
   maxNearbyHeight = MAX(maxNearbyHeight, 
                         [self heightAtXPos:x zPos:z+1]);
   maxNearbyHeight = MAX(maxNearbyHeight, 
                         [self heightAtXPos:x zPos:z-1]);
   maxNearbyHeight = MAX(maxNearbyHeight, 
                         [self heightAtXPos:x+1 zPos:z+1]);
   maxNearbyHeight = MAX(maxNearbyHeight, 
                         [self heightAtXPos:x-1 zPos:z+1]);
   maxNearbyHeight = MAX(maxNearbyHeight, 
                         [self heightAtXPos:x+1 zPos:z-1]);
   maxNearbyHeight = MAX(maxNearbyHeight, 
                         [self heightAtXPos:x-1 zPos:z-1]);
   
   return maxNearbyHeight;
}


/////////////////////////////////////////////////////////////////
// Returns a weighted average of the up to 9 mesh vertices 
// centered at x,z  
- (GLfloat)smoothHeightNearXPos:(NSInteger)x 
   zPos:(NSInteger)z;
{
   const NSInteger constLength = [self.length integerValue];
   const NSInteger constWidth = [self.width integerValue];
   NSParameterAssert(0 <= x && x < constWidth);
   NSParameterAssert(0 <= z && z < constLength);

   GLfloat       height = [self heightAtXPos:x zPos:z];

   if(0 < x && x < (constWidth - 1) && 
      0 < z && z < (constLength - 1))
   {
      height *= 0.5f; 
      height += 1.0/16.0 * [self heightAtXPos:x+1 zPos:z];
      height += 1.0/16.0 * [self heightAtXPos:x-1 zPos:z];
      height += 1.0/16.0 * [self heightAtXPos:x zPos:z+1];
      height += 1.0/16.0 * [self heightAtXPos:x zPos:z-1];
      height += 1.0/16.0 * [self heightAtXPos:x+1 zPos:z+1];
      height += 1.0/16.0 * [self heightAtXPos:x-1 zPos:z+1];
      height += 1.0/16.0 * [self heightAtXPos:x+1 zPos:z-1];
      height += 1.0/16.0 * [self heightAtXPos:x-1 zPos:z-1];
   }
   
   return height;
}


/////////////////////////////////////////////////////////////////
//
- (void)didChangeValueForKey:(NSString *)key
{
   if([@"positionAttributesData" isEqualToString:key])
   {
      GLuint  glName = [self.glVertexAttributeBufferID intValue];
      if(0 != glName)
      {
         // Force rebuffering of vertex data
         glBindBuffer(GL_ARRAY_BUFFER,  // STEP 2
                      glName); 
         glBufferData(                  // STEP 3
                      GL_ARRAY_BUFFER,  // Initialize buffer contents
                      [self.positionAttributesData length], 
                      [self.positionAttributesData bytes],  
                      GL_STATIC_DRAW);            // Hint: cache in GPU memory
      }
   }
   
   [super didChangeValueForKey:key];
}


/////////////////////////////////////////////////////////////////
//
- (void)updateTerrainWithHeightDelta:
   (float)delta 
   at:(UtilityVector2)aPosition
   radius:(GLfloat)aRadius;
{
   const GLfloat constHeightScaleFactor = 
      [self.heightScaleFactor floatValue] * 
      [self.metersPerUnit floatValue];
   NSMutableData *mutablePositionData = 
      [[self.positionAttributesData mutableCopy] autorelease];
   const GLint x = aPosition.x;
   const GLint y = aPosition.y;
   const GLfloat radiusSquared = (aRadius * aRadius);
   
   // Change vertex elevaltions in radius cenered on aPosition
   for(int j = MAX(0, y - aRadius); j < MIN([self.length floatValue], y + aRadius); 
      j++)
   {
      for(int i = MAX(0, x - aRadius); 
         i < MIN([self.width floatValue], x + aRadius); i++)
      {
         float distanceSquared = (x - i) * (x - i) + 
            (y - j) * (y - j);
            
         // Alpha is used to fade delta at radius edges   
         float alpha = MAX(0.0f, (1.0f - (distanceSquared / 
            radiusSquared)));

         if(0.0f < alpha)
         {
            float height = TETerrainPostitionPtrAt(
               self, mutablePositionData, i, j)->y;
            float newHeight = height +                    
                  (alpha * constHeightScaleFactor * delta);
            TETerrainPostitionMutablePtrAt(
               self, mutablePositionData, i, j)->y = newHeight;
         }
      }
   }

   self.positionAttributesData = mutablePositionData;   
}


/////////////////////////////////////////////////////////////////
//
- (void)smoothTerrainAt:(UtilityVector2)aPosition
   radius:(GLfloat)aRadius;
{
   NSMutableData *mutablePositionData = 
      [[self.positionAttributesData mutableCopy] autorelease];
   const GLint x = aPosition.x;
   const GLint y = aPosition.y;
   const GLfloat radiusSquared = (aRadius * aRadius);
   
   // Change vertex elevaltions in radius cenered on aPosition
   for(int j = MAX(0, y - aRadius); j < MIN([self.length floatValue], y + aRadius); 
      j++)
   {
      for(int i = MAX(0, x - aRadius); 
         i < MIN([self.width floatValue], x + aRadius); i++)
      {
         float distanceSquared = (x - i) * (x - i) + 
            (y - j) * (y - j);
            
         // Alpha is used to fade delta at radius edges   
         float alpha = MAX(0.0f, (1.0f - (distanceSquared / 
            radiusSquared)));

         GLfloat height = TETerrainPostitionPtrAt(
            self, mutablePositionData, i, j)->y;
         GLfloat smoothHeight = [self smoothHeightNearXPos:i zPos:j];
         TETerrainPostitionMutablePtrAt(
            self, mutablePositionData, i, j)->y = 
            (smoothHeight * alpha) + (height * (1.0 - alpha));
      }
   }

   self.positionAttributesData = mutablePositionData;
}


/////////////////////////////////////////////////////////////////
// Returns YES if and only if a valid height value is available
// for teh terrain at position x,z.
- (BOOL)isHeightValidAtXPos:(NSInteger)x zPos:(NSInteger)z
{
   const NSInteger constLength = [self.length integerValue];
   const NSInteger constWidth = [self.width integerValue];
   NSParameterAssert(0 <= x && x < constWidth);
   NSParameterAssert(0 <= z && z < constLength);

   return (x < constWidth && z < constLength && 0 <= x && 0 <= z);
}


/////////////////////////////////////////////////////////////////
// Returns the average of the up to 9 mesh vertices 
// centered at x,z  
- (GLfloat)regionalHeightAtXPos:(NSInteger)x zPos:(NSInteger)z
{  // Returns the average of the up to 9 mesh poNSIntegers 
   // centered at x,z
   const NSInteger constLength = [self.length integerValue];
   const NSInteger constWidth = [self.width integerValue];
   NSParameterAssert(0 <= x && x < constWidth);
   NSParameterAssert(0 <= z && z < constLength);

   NSInteger  zIndex;
	NSInteger xIndex;
   GLfloat count = 0.0f;
   GLfloat heightSum = 0.0;
   GLfloat heightAverage = 0.0;
   
   for(zIndex = z-1; zIndex <= z+1; zIndex++)
   {
      for(xIndex = x-1; xIndex <= x+1; xIndex++) 
      {
         if([self isHeightValidAtXPos:xIndex zPos:zIndex])
         {
            heightSum += [self heightAtXPos:xIndex zPos:zIndex];
            count += 1.0f;
         }
      }
   }
   if(0.0f < count)
   {
      heightAverage = heightSum / count;
   }
   
   return heightAverage;
}


/////////////////////////////////////////////////////////////////
// Calculate smooth normal vectors by averaging the normal 
// vectors of four planes adjacent to each vertex.  Normal 
// vectors must be recalculated every time the vertex positions
// or the height scale factor change.
- (NSData *)normalData
{
   NSData *positionData = self.positionAttributesData;
   NSMutableData *normalData = [NSMutableData dataWithLength:
      [positionData length]];
   //NSLog(@"normalData length:%lu", 
   //   [self.positionAttributesData length]);
   NSInteger currentRow;
   NSInteger currentColumn;
   const NSInteger constLength = [self.length integerValue];
   const NSInteger constWidth = [self.width integerValue];
   
   // Calculate normals for vertices NSIntegerernal to the mesh
   for(currentRow = 1; currentRow < (constLength - 1); 
       currentRow++)
   {
      for(currentColumn = 1; currentColumn < (constWidth - 1); 
          currentColumn++)
      {
         UtilityVector3 position = *TETerrainPostitionPtrAt(
            self, positionData, currentColumn, currentRow);
         
         UtilityVector3 vectorA = (UtilityVector3Subtract(*TETerrainPostitionPtrAt(
            self, positionData, currentColumn, currentRow+1), position));
         UtilityVector3 vectorB = (UtilityVector3Subtract(*TETerrainPostitionPtrAt(
            self, positionData, currentColumn+1, currentRow), position));
         UtilityVector3 vectorC = (UtilityVector3Subtract(*TETerrainPostitionPtrAt(
            self, positionData, currentColumn, currentRow-1), position));
         UtilityVector3 vectorD = (UtilityVector3Subtract(*TETerrainPostitionPtrAt(
            self, positionData, currentColumn-1, currentRow), position));
         
         // Calculate normal vectors for four planes
         UtilityVector3   normalBA = UtilityVector3CrossProduct(vectorA, vectorB);
         UtilityVector3   normalCB = UtilityVector3CrossProduct(vectorB, vectorC);
         UtilityVector3   normalDC = UtilityVector3CrossProduct(vectorC, vectorD);
         UtilityVector3   normalAD = UtilityVector3CrossProduct(vectorD, vectorA);
         
         // Store the average the face normal vectors of the 
         // four triangles that share the current vertex
         *TETerrainNormalMutablePtrAt(
            self, normalData, currentColumn, currentRow) =
         UtilityVector3Normalize(UtilityVector3Scale(UtilityVector3Add(
            UtilityVector3Add(UtilityVector3Add(
               normalBA, 
               normalCB), 
               normalDC), 
               normalAD), 
               0.25));
      }
   } 
   
   // Calculate normals along X max and X min edges
   for(currentRow = 0; currentRow < constLength; 
       currentRow++)
   {
      *TETerrainNormalMutablePtrAt(self, normalData, 0, currentRow) =
         *TETerrainNormalPtrAt(self, normalData, 1, currentRow);
      *TETerrainNormalMutablePtrAt(self, normalData, constWidth-1, currentRow) =
         *TETerrainNormalPtrAt(self, normalData, constWidth-2, currentRow);
   }
   
   // Calculate normals along Z max and Z min edges
   for(currentColumn = 0; currentColumn < constWidth; 
       currentColumn++)
   {
      *TETerrainNormalMutablePtrAt(self, normalData, currentColumn, 0) =
         *TETerrainNormalPtrAt(self, normalData, currentColumn, 1);
      *TETerrainNormalMutablePtrAt(self, normalData, currentColumn, constLength-1) =
         *TETerrainNormalPtrAt(self, normalData, currentColumn, constLength-2);
   }
   
   return normalData;
}


#pragma mark -  Property Support

/////////////////////////////////////////////////////////////////
// Returns the width of the terrain in meters based on the 
// receiver's metersPerUnit property.
- (GLfloat)widthMeters;
{
   return [self.width floatValue] * 
   [self.metersPerUnit floatValue];
}


/////////////////////////////////////////////////////////////////
// Returns the maxmum height of the terrain in meters based on 
// the receiver's metersPerUnit property.
- (GLfloat)heightMeters;
{
   return [self.heightScaleFactor floatValue] * 
   [self.metersPerUnit floatValue];
}


/////////////////////////////////////////////////////////////////
// Returns the length of the terrain in meters based on the 
// receiver's metersPerUnit property.
- (GLfloat)lengthMeters;
{
   return [self.length floatValue] * 
   [self.metersPerUnit floatValue];
}

@end
