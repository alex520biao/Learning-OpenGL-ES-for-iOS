//
//  TEView.h
//  TerrainViewer
//

#import <Cocoa/Cocoa.h>
#import "Utilityvector.h"

@class UtilityOpenGLCamera;
@class UtilityTextureInfo;
@class TETerrain;
@class TETerrainEffect;

@class TETool;
@class TEModelManager;


@protocol TEViewDataSourceProtocol <NSObject>

- (TETerrain *)terrain;
- (TETool *)currentTool;
- (TEModelManager *)modelManager;
- (NSManagedObjectContext *)managedObjectContext;

- (NSUndoManager *)undoManager;

@end


@interface TEView : NSOpenGLView

@property (strong, nonatomic, readonly) 
   TETerrainEffect *terrainEffect;
@property (strong, nonatomic, readonly) 
   UtilityOpenGLCamera *camera;
@property (nonatomic, assign, readonly) 
   UtilityVector3 referencePosition;
@property (nonatomic, strong, readwrite) 
   UtilityTextureInfo *editingLightAndWeightsTextureInfo;
   
@property (strong, nonatomic, readwrite) 
   IBOutlet id <TEViewDataSourceProtocol> dataSource;
@property (strong, nonatomic, readwrite) 
   IBOutlet NSArrayController *modelPlacementArrayController;
@property (assign, nonatomic) BOOL shouldShowTexture;
@property (assign, nonatomic) BOOL shouldShowGrid;
   
- (IBAction)startAnimating:(id)sender;
- (IBAction)stopAnimating:(id)sender;
- (IBAction)takeShouldShowTextureFrom:(id)sender;
- (IBAction)takeShouldShowGridFrom:(id)sender;

@end
