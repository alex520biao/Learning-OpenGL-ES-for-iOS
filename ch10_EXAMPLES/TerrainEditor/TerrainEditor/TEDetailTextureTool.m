//
//  TEDetailTextureTool.m
//  TerrainEditor
//

#import "TEDetailTextureTool.h"
#import "TEEditWindowController.h"
#import "TEView.h"
#import "TETerrainEffect.h"
#import "TETerrain.h"
#import "UtilityTextureLoader.h"


@implementation TEDetailTextureTool

@synthesize toolTextureImage;
@synthesize detailTexture0Weight;
@synthesize detailTexture1Weight;
@synthesize detailTexture2Weight;


/////////////////////////////////////////////////////////////////
//
- (void)awakeFromNib
{
    self.toolRadius = [NSNumber numberWithFloat:3.5f];
}


/////////////////////////////////////////////////////////////////
//  
- (void)setWeights:(UtilityVector3)values 
   at:(UtilityVector2)aPosition
   radius:(GLfloat)aRadius;
{
   TEView *view = self.owner;
   
   NSAssert(nil != view.editingLightAndWeightsTextureInfo,
      @"Uninitialized editingLightAndWeightsTextureInfo");

   UtilityVector2 scaledPosition =
   {
      aPosition.x / [view.dataSource.terrain.width floatValue],
      aPosition.y / [view.dataSource.terrain.length floatValue],
   };
   
   // Replace existing texture info with modified one
   [view.editingLightAndWeightsTextureInfo 
      updateWithModifiedRGBComponents:values
      at:scaledPosition
      radius:aRadius];
}


/////////////////////////////////////////////////////////////////
//
- (void)paintDetailTextures
{
   TEView *view = self.owner;
   
   UtilityVector2 position = view.terrainEffect.toolLocation;   
   UtilityVector3 weights =
   {
      [detailTexture0Weight floatValue],
      [detailTexture1Weight floatValue],
      [detailTexture2Weight floatValue],
   };
   //weights = UtilityVector3Normalize(weights);
   
   [self setWeights:weights 
      at:position
      radius:[self.toolRadius floatValue]];
}


/////////////////////////////////////////////////////////////////
//
- (void)mouseDragged:(NSEvent *)theEvent
{
   [self paintDetailTextures]; 
}

@end
