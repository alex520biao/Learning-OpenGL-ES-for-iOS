//
//  TEModelPlacementTool.h
//  TerrainEditor
//

#import "TETool.h"

@class TEModelPlacement;
@class TEModel;


@interface TEModelPlacementTool : TETool

@property (assign, nonatomic, readonly) BOOL canPlaceSelectedModel;
@property (assign, nonatomic, readonly) BOOL canDeleteSelectedPlacement;
@property (strong, nonatomic, readonly) 
   TEModelPlacement *selectedPlacement;
@property (strong, nonatomic, readonly) 
   TEModel *selectedModel;
@property (strong, nonatomic, readwrite) 
   IBOutlet NSArrayController *modelsArrayController;
@property (strong, nonatomic, readwrite) 
   IBOutlet NSArrayController *modelPlacementArrayController;

- (IBAction)placeModel:(id)sender;
- (IBAction)deleteSelectedModelPlacements:(id)sender;
- (IBAction)noteModelSelectionChange:(id)sender;

@end
