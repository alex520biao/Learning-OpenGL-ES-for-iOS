//
//  TEEditWindowController.h
//  TerrainEditor
//

#import <Cocoa/Cocoa.h>
#import "TEView.h"

@class TETool;
@class TEModelPlacement;
@class TEModelManager;


@interface TEEditWindowController : NSWindowController 
   <TEViewDataSourceProtocol>

@property (strong, nonatomic, readwrite) TETool *currentTool;
@property (strong, nonatomic, readonly) TEModelManager *modelManager;
@property (strong, nonatomic, readonly) TETerrain *terrain;

@property (strong, nonatomic, readwrite) NSImage *detailTexture0Image;
@property (strong, nonatomic, readwrite) NSImage *detailTexture1Image;
@property (strong, nonatomic, readwrite) NSImage *detailTexture2Image;
@property (strong, nonatomic, readwrite) NSImage *detailTexture3Image;
@property (strong, nonatomic, readonly) NSArray *allModels;
@property (strong, nonatomic, readonly) 
   NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic, readwrite) IBOutlet TEView *terrainView;
@property (strong, nonatomic, readwrite) IBOutlet NSView *supportViewArea;
@property (strong, nonatomic, readwrite) IBOutlet TETool *defaultTool;

- (IBAction)takeSelectedToolFrom:(id)sender;

@end
