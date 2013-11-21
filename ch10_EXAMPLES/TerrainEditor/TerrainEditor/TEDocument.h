//
//  TEDocument.h
//  TerrainEditor
//

#import <Cocoa/Cocoa.h>
#import "UtilityVector.h"


@interface TEDocument : NSPersistentDocument

- (IBAction)loadModels:(id)sender;

@end


//////////////////////////////////////////////////////////////////
//  
extern const UtilityVector3 TEDefaultTerrainLightDirection;
