//
//  TEElevationTool.m
//  TerrainEditor
//

#import "TEElevationTool.h"
#import "TEView.h"
#import "TETerrain+modelAdditions.h"
#import "TETerrainEffect.h"


@implementation TEElevationTool

@synthesize elevationChangeSelector = elevationChangeSelector_;
@synthesize toolRadius;


/////////////////////////////////////////////////////////////////
//
- (void)smoothElevations
{
   TEView *view = self.owner;
   TETerrain *terrain = view.dataSource.terrain;

   NSAssert(nil != terrain,
      @"Missing terrain");
   
   UtilityVector2 position = view.terrainEffect.toolLocation;   
   GLfloat radius = [self.toolRadius floatValue];
   
   [terrain smoothTerrainAt:position radius:radius];
}


/////////////////////////////////////////////////////////////////
//
- (void)raiseElevations
{
   TEView *view = self.owner;
   TETerrain *terrain = view.dataSource.terrain;

   NSAssert(nil != terrain,
      @"Missing terrain");
   
   UtilityVector2 position = view.terrainEffect.toolLocation;   
   GLfloat radius = [self.toolRadius floatValue];
   
   [terrain updateTerrainWithHeightDelta:0.05f 
      at:position radius:radius];
}


/////////////////////////////////////////////////////////////////
//
- (void)lowerElevations
{
   TEView *view = self.owner;
   TETerrain *terrain = view.dataSource.terrain;

   NSAssert(nil != terrain,
      @"Missing terrain");
   
   UtilityVector2 position = view.terrainEffect.toolLocation;   
   GLfloat radius = [self.toolRadius floatValue];
   
   [terrain updateTerrainWithHeightDelta:-0.05f 
      at:position radius:radius];
}


/////////////////////////////////////////////////////////////////
//
- (SEL)elevationChangeSelector
{
   if(NULL == elevationChangeSelector_)
   {
      elevationChangeSelector_ = @selector(smoothElevations);
   }
   
   return elevationChangeSelector_;
}


/////////////////////////////////////////////////////////////////
//
- (void)mouseDown:(NSEvent *)theEvent
{
   TEView *view = self.owner;
   TETerrain *terrain = view.dataSource.terrain;

   NSAssert(nil != terrain,
      @"Missing terrain");
   
   [self performSelector:self.elevationChangeSelector];
   
   // Update lightsAndWeights texture with new lighting for
   // new elevations
   view.editingLightAndWeightsTextureInfo = 
      [terrain updatedLightInLightsAndWeightsTextureInfo];
}


/////////////////////////////////////////////////////////////////
//
- (IBAction)useRaiseElevationMode:(id)sender;
{
   self.elevationChangeSelector = @selector(raiseElevations);
}


/////////////////////////////////////////////////////////////////
//
- (IBAction)useLowerElevationMode:(id)sender;
{
   self.elevationChangeSelector = @selector(lowerElevations);
}


/////////////////////////////////////////////////////////////////
//
- (IBAction)useSmoothElevationMode:(id)sender;
{
   self.elevationChangeSelector = @selector(smoothElevations);
}

@end
