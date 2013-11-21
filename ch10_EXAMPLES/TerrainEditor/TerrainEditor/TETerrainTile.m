//
//  TETerrainTile.m
//  TerrainViewer
//

#import "TETerrainTile.h"
#import "TETerrain+modelAdditions.h"


@interface TETerrainTile ()

@property (strong, nonatomic, readwrite) TETerrain *terrain;
@property (assign, nonatomic, readwrite) NSInteger originX;
@property (assign, nonatomic, readwrite) NSInteger originY;
@property (assign, nonatomic, readwrite) NSInteger tileWidth;
@property (assign, nonatomic, readwrite) NSInteger tileLength;
@property (assign, nonatomic, readwrite) GLuint indexBufferID;
@property (strong, nonatomic, readwrite) NSData *indexData;
@property (assign, nonatomic, readwrite) GLsizei numberOfIndices;

@end


@implementation TETerrainTile

@synthesize terrain;
@synthesize originX;
@synthesize originY;
@synthesize tileWidth;
@synthesize tileLength;
@synthesize indexBufferID;
@synthesize indexData;
@synthesize numberOfIndices;


/////////////////////////////////////////////////////////////////
// This initializer is invalid. Do not call it. 
- (id)init
{
   NSAssert(0, @"Invalid initializer");
   [self release];
   self = nil;

   return self;
}


/////////////////////////////////////////////////////////////////
// Unbinds and deletes ant element array buffers created by the 
// receiver.
- (void)dealloc
{
   glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
   glDeleteBuffers(1, &indexBufferID);
   indexBufferID = 0;
   
   [super dealloc];
}


/////////////////////////////////////////////////////////////////
// Designated initailizer: This method initializes the receiver 
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
      
      NSMutableData *indices = [NSMutableData data];

      const NSInteger constTerrainWidth = 
         [terrain.width integerValue];
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

      self.indexData = indices;
      self.numberOfIndices = (GLsizei)([self.indexData length] / 
         sizeof(GLushort));
   }

   return self;
}


/////////////////////////////////////////////////////////////////
// This method configures OpenGL ES state by binding element
// array buffers, and if necessary by passing element index data 
// to the GPU. Thenm the vertices corresponding to the receiver 
// are passed to the GPU via a call to glDrawElements().
- (void)draw;
{
   if(0 == indexBufferID && 0 < [self.indexData length])
   {  // Indices haven't been sent to GPU yet
      // Create an element array buffer for mesh indices
      glGenBuffers(1, &indexBufferID);
      NSAssert(0 != self.indexBufferID, 
         @"Failed to generate element array buffer");
          
      glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, self.indexBufferID);
      glBufferData(GL_ELEMENT_ARRAY_BUFFER, 
         [self.indexData length], 
         [self.indexData bytes], 
         GL_STATIC_DRAW);      
         
      // No longer need local index storage
      self.indexData = nil;
   }
   else
   {
      glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, self.indexBufferID);
   }

   glDrawElements(GL_TRIANGLE_STRIP,
      self.numberOfIndices,
      GL_UNSIGNED_SHORT,
      ((GLushort *)NULL));
}


/////////////////////////////////////////////////////////////////
// This method is teh same as -draw except that vertex data is 
// rendered as lines instead of triangles.
- (void)drawLines;
{
   if(0 == indexBufferID && 0 < [self.indexData length])
   {  // Indices haven't been sent to GPU yet
      // Create an element array buffer for mesh indices
      glGenBuffers(1, &indexBufferID);
      NSAssert(0 != self.indexBufferID, 
         @"Failed to generate element array buffer");
          
      glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, self.indexBufferID);
      glBufferData(GL_ELEMENT_ARRAY_BUFFER, 
         [self.indexData length], 
         [self.indexData bytes], 
         GL_STATIC_DRAW);
      
      self.numberOfIndices = (GLsizei)([self.indexData length] / 
         sizeof(GLushort));
         
      // No longer need local index storage
      self.indexData = nil;
   }
   else
   {
      glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, self.indexBufferID);
   }

   glPolygonOffset(3.0f, 1.0f);
   glLineWidth(1.0f);
   glDrawElements(GL_LINE_STRIP,
      self.numberOfIndices,
      GL_UNSIGNED_SHORT,
      ((GLushort *)NULL));      
   glPolygonOffset(0.0f, 1.0f);
}

@end
