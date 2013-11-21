//
//  TEElevationTool.h
//  TerrainEditor
//

#import "TEAreaTool.h"

@interface TEElevationTool : TEAreaTool

@property (assign, nonatomic, readwrite) 
   SEL elevationChangeSelector;

- (IBAction)useRaiseElevationMode:(id)sender;
- (IBAction)useLowerElevationMode:(id)sender;
- (IBAction)useSmoothElevationMode:(id)sender;
   
@end
