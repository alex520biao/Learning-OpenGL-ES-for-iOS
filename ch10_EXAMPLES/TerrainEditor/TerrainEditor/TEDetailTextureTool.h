//
//  TEDetailTextureTool.h
//  TerrainEditor
//

#import "TEAreaTool.h"


@interface TEDetailTextureTool : TEAreaTool

@property (strong, nonatomic, readonly) 
   NSImage *toolTextureImage;
@property (strong, nonatomic, readwrite) 
   NSNumber *detailTexture0Weight;
@property (strong, nonatomic, readwrite) 
   NSNumber *detailTexture1Weight;
@property (strong, nonatomic, readwrite) 
   NSNumber *detailTexture2Weight;

@end
