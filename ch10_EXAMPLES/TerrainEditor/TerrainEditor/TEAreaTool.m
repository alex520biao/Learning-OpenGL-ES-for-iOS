//
//  TEAreaTool.m
//  TerrainEditor
//

#import "TEAreaTool.h"
#import "TEView.h"
#import "TETerrain.h"
#import "TETerrainEffect.h"

@implementation TEAreaTool

@synthesize toolRadius;


/////////////////////////////////////////////////////////////////
//  
- (void)setToolRadius:(NSNumber *)aNumber
{
   [aNumber retain];
   [toolRadius release];
   toolRadius = aNumber;
   
   TEView *view = self.owner;
   
   view.terrainEffect.toolTextureRadius = 
      [self.toolRadius floatValue];
   [view.terrainEffect updateTool];
   [view display];
}


/////////////////////////////////////////////////////////////////
//  
- (void)update
{
   TEView *view = self.owner;
   
   view.terrainEffect.toolTextureRadius = 
      [self.toolRadius floatValue];
}


@end
