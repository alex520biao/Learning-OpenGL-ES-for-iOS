//
//  TETerrainTile.m
//  TerrainViewer
//

#import "TETerrainTile.h"
#import "TETerrain.h"
#import "TEModelPlacement.h"
#import <GLKit/GLKit.h>


@interface TETerrainTile ()

@property (strong, nonatomic, readwrite) TETerrain *terrain;
@property (strong, nonatomic, readwrite) NSMutableSet *
   modelPlacements;
@property (assign, nonatomic, readwrite) NSInteger originX;
@property (assign, nonatomic, readwrite) NSInteger originY;
@property (assign, nonatomic, readwrite) NSInteger tileWidth;
@property (assign, nonatomic, readwrite) NSInteger tileLength;
@property (assign, nonatomic, readwrite) GLuint indexBufferID;
@property (assign, nonatomic, readwrite) GLuint 
   simplifiedIndexBufferID;
@property (strong, nonatomic, readwrite) NSData *indexData;
@property (strong, nonatomic, readwrite) NSData *
   simplifiedIndexData;
@property (assign, nonatomic, readwrite) GLsizei numberOfIndices;
@property (assign, nonatomic, readwrite) GLsizei 
   numberOfSimplifiedIndices;

- (NSData *)generateIndicesForTileOriginX:(NSInteger)x 
   tileOriginY:(NSInteger)y 
   tileWidth:(NSInteger)aWidth
   tileLength:(NSInteger)aLength;
- (NSData *)generateSimplifiedIndicesForTileOriginX:(NSInteger)x 
   tileOriginY:(NSInteger)y 
   tileWidth:(NSInteger)aWidth
   tileLength:(NSInteger)aLength;

@end


@implementation TETerrainTile

@synthesize terrain = terrain_;
@synthesize modelPlacements = modelPlacements_;
@synthesize originX = originX_;
@synthesize originY = originY_;
@synthesize tileWidth = tileWidth_;
@synthesize tileLength = tileLength_;
@synthesize indexBufferID = indexBufferID_;
@synthesize simplifiedIndexBufferID = simplifiedIndexBufferID_;
@synthesize indexData = indexData_;
@synthesize simplifiedIndexData = simplifiedIndexData_;
@synthesize numberOfIndices = numberOfIndices_;
@synthesize numberOfSimplifiedIndices = numberOfSimplifiedIndices_;


/////////////////////////////////////////////////////////////////
// This initializer is invalid. Do not call it. 
- (id)init
{
   NSAssert(0, @"Invalid initializer");
   self = nil;

   return self;
}


/////////////////////////////////////////////////////////////////
// Unbinds and deletes ant element array buffers created by the 
// receiver.
- (void)dealloc
{
   glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
   
   if(0 != indexBufferID_)
   {
      glDeleteBuffers(1, &indexBufferID_);
      indexBufferID_ = 0;
   }
   
   if(0 != simplifiedIndexBufferID_)
   {
      glDeleteBuffers(1, &simplifiedIndexBufferID_);
      simplifiedIndexBufferID_ = 0;
   }
}


/////////////////////////////////////////////////////////////////
// Designated initializer: This method initializes the receiver 
// to store element index data for a tile comprising an area of 
// terrain bounded by position x,y with aWidth and aLength.
- (id)initWithTerrain:(TETerrain *)aTerrain
   tileOriginX:(NSInteger)x 
   tileOriginY:(NSInteger)y 
   tileWidth:(NSInteger)aWidth
   tileLength:(NSInteger)aLength
{
   if(nil != (self = [super init])) 
   {
      self.terrain = aTerrain;
      self.originX = x;
      self.originY = y;
      self.tileWidth = aWidth;
      self.tileLength = aLength;
      
      self.indexData = 
         [self generateIndicesForTileOriginX:x 
         tileOriginY:y 
         tileWidth:aWidth
         tileLength:aLength];
         
      self.numberOfIndices = (GLsizei)([self.indexData length] / 
         sizeof(GLushort));
      
      self.simplifiedIndexData = 
         [self generateSimplifiedIndicesForTileOriginX:x 
         tileOriginY:y 
         tileWidth:aWidth
         tileLength:aLength];
         
      self.numberOfSimplifiedIndices = 
         (GLsizei)([self.simplifiedIndexData length] / 
         sizeof(GLushort));
         
      self.modelPlacements = [NSMutableSet set];
   }

   return self;
}


/////////////////////////////////////////////////////////////////
// This method configures OpenGL ES state by binding element
// array buffers, and if necessary by passing element index data 
// to the GPU. Then the vertices corresponding to the receiver 
// are passed to the GPU via a call to glDrawElements(). The 
// receiver's entire mesh is drawn as a triangle strip.
- (void)draw;
{
   if(0 == indexBufferID_ && 0 < [self.indexData length])
   {  // Indices haven't been sent to GPU yet
      // Create an element array buffer for mesh indices
      glGenBuffers(1, &indexBufferID_);
      NSAssert(0 != self.indexBufferID, 
         @"Failed to generate element array buffer");
          
      glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBufferID_);
      glBufferData(GL_ELEMENT_ARRAY_BUFFER, 
         [self.indexData length], 
         [self.indexData bytes], 
         GL_STATIC_DRAW);      
         
      // No longer need local index storage
      self.indexData = nil;
   }
   else
   {
      glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBufferID_);
   }

   glDrawElements(GL_TRIANGLE_STRIP,
      self.numberOfIndices,
      GL_UNSIGNED_SHORT,
      ((GLushort *)NULL));
}


/////////////////////////////////////////////////////////////////
// This method configures OpenGL ES state by binding element
// array buffers, and if necessary by passing element index data 
// to the GPU. Then the vertices corresponding to the receiver 
// are passed to the GPU via a call to glDrawElements(). The 
// receiver's center and perimeter vertices are drawn as a 
// triangle fan.
- (void)drawSimplified;
{
   if(0 == simplifiedIndexBufferID_ && 
      0 < [self.simplifiedIndexData length])
   {  // Indices haven't been sent to GPU yet
      // Create an element array buffer for mesh indices
      glGenBuffers(1, &simplifiedIndexBufferID_);
      NSAssert(0 != self.simplifiedIndexBufferID, 
         @"Failed to generate element array buffer");
          
      glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 
         self.simplifiedIndexBufferID);
      glBufferData(GL_ELEMENT_ARRAY_BUFFER, 
         [self.simplifiedIndexData length], 
         [self.simplifiedIndexData bytes], 
         GL_STATIC_DRAW);      
         
      // No longer need local index storage
      self.simplifiedIndexData = nil;
   }
   else
   {
      glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 
         self.simplifiedIndexBufferID);
   }

   glDrawElements(GL_TRIANGLE_FAN,
      self.numberOfSimplifiedIndices,
      GL_UNSIGNED_SHORT,
      ((GLushort *)NULL));
}


/////////////////////////////////////////////////////////////////
// This method returns data containing vertex indices in the 
// order needed to draw the receiver's entire mesh as a single
// triangle strip. 
- (NSData *)generateIndicesForTileOriginX:(NSInteger)x 
   tileOriginY:(NSInteger)y 
   tileWidth:(NSInteger)aWidth
   tileLength:(NSInteger)aLength
{
   NSMutableData *indices = [NSMutableData data];

   const NSInteger constTerrainWidth = 
      self.terrain.width;
   NSAssert(0 < constTerrainWidth, @"Invalid terrain");
   
   NSInteger i = 0;
   NSInteger j = 0;
   
   // This sequence of indices produces triangle strips with
   // degenerate vertices so the entire tile  can be rendered
   // by a single call to glDrawElements().
   while(j < (aLength - 1))
   {
      for(i = 0; i < (aWidth - 1); i++)
      {
         // lower left
         GLushort currentIndex = i + (j + 0) * constTerrainWidth;            
         [indices appendBytes:&currentIndex 
            length:sizeof(currentIndex)]; 

         // upper left
         currentIndex = i + (j + 1) * constTerrainWidth; 
         [indices appendBytes:&currentIndex 
            length:sizeof(currentIndex)];
      }
      {           
         // lower left (i always equals aWidth - 1 here)
         GLushort currentIndex = i + (j + 0) * constTerrainWidth; 
         [indices appendBytes:&currentIndex 
            length:sizeof(currentIndex)];

         // upper left
         currentIndex = i + (j + 1) * constTerrainWidth; 
         [indices appendBytes:&currentIndex 
            length:sizeof(currentIndex)];
         [indices appendBytes:&currentIndex 
            length:sizeof(currentIndex)];
      }
      j++;
      
      if(j < (aLength - 1))
      {
         for(i = aWidth - 1; i > 0; i--)
         {
            // lower left
            GLushort currentIndex = i + (j + 0) * constTerrainWidth;            
            [indices appendBytes:&currentIndex 
               length:sizeof(currentIndex)]; 
               
            // upper left
            currentIndex = i + (j + 1) * constTerrainWidth;
            [indices appendBytes:&currentIndex 
               length:sizeof(currentIndex)]; 
         }            
         {           
            // lower left (i always equals 0 here)
            GLushort currentIndex = i + (j + 0) * constTerrainWidth; 
            [indices appendBytes:&currentIndex 
               length:sizeof(currentIndex)];
               
            // upper left
            currentIndex = i + (j + 1) * constTerrainWidth;
            [indices appendBytes:&currentIndex 
               length:sizeof(currentIndex)]; 
            [indices appendBytes:&currentIndex 
               length:sizeof(currentIndex)];
         }            
         j++;
      }
   }
   
   {           
      // lower left (j always equals length - 1 here)
      // i is either equal to width-1 or to 0
      GLushort currentIndex = i + (j + 0) * constTerrainWidth; 
      [indices appendBytes:&currentIndex 
         length:sizeof(currentIndex)];
   }
   
   return indices;
}


/////////////////////////////////////////////////////////////////
// This method returns data containing vertex indices in the 
// order needed to draw the receiver's mesh as a triangle fan
// centered in the receiver's mesh and including all of the 
// receiver's perimeter vertices.. 
- (NSData *)generateSimplifiedIndicesForTileOriginX:(NSInteger)x 
   tileOriginY:(NSInteger)y 
   tileWidth:(NSInteger)aWidth
   tileLength:(NSInteger)aLength
{
   NSMutableData *indices = [NSMutableData data];

   const NSInteger constTerrainWidth = 
      self.terrain.width;
   NSAssert(0 < constTerrainWidth, @"Invalid terrain");
   
   // First specify the center for a fan of triangles
   {
      GLushort currentIndex = (aWidth/2) + 
         ((aLength/2) * constTerrainWidth);            
      [indices appendBytes:&currentIndex 
         length:sizeof(currentIndex)];
   }
   
   // Next, specify all of the edge indices
   for(NSInteger j = 0; j < aLength; j++)
   {
      GLushort currentIndex = 0 + 
         (j * constTerrainWidth);            
      [indices appendBytes:&currentIndex 
         length:sizeof(currentIndex)]; 
   }
   
   for(NSInteger i = 1; i < aWidth; i++)
   {
      GLushort currentIndex = i + 
         ((aLength - 1) * constTerrainWidth);            
      [indices appendBytes:&currentIndex 
         length:sizeof(currentIndex)]; 
   }
   
   for(NSInteger j = aLength - 2; j >= 0; j--)
   {
      GLushort currentIndex = (aWidth - 1) + 
         (j * constTerrainWidth);            
      [indices appendBytes:&currentIndex 
         length:sizeof(currentIndex)]; 
   }
   
   for(NSInteger i = aWidth - 2; i >= 0; i--)
   {
      GLushort currentIndex = i + 
         (0 * constTerrainWidth);            
      [indices appendBytes:&currentIndex 
         length:sizeof(currentIndex)]; 
   }
   
   return indices;
}


/////////////////////////////////////////////////////////////////
// Add all model placements from somePlacements that are located
// within the receiver to the receiver's set of contained
// placements 
- (void)manageContainedModelPlacements:(NSSet *)somePlacements;
{
   for(TEModelPlacement *currentPlacement in somePlacements)
   {
      GLKVector3 position = 
      {
         currentPlacement.positionX,
         currentPlacement.positionY,
         currentPlacement.positionZ
      };
      
      if(position.x >= self.originX && 
         position.x < (self.originX + self.tileWidth) &&
         position.z >= self.originY && 
         position.z < (self.originY + self.tileLength))
      {
         [self.modelPlacements addObject:currentPlacement];
      }
   }
}


/////////////////////////////////////////////////////////////////
// Return the receiver's set of contained model placements
- (NSSet *)containedModelPlacements;
{
   return self.modelPlacements;
}

@end
