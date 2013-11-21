//
//  TEHeightMap.h
//  TerrainViewer
//

#import <Cocoa/Cocoa.h>
#import "UtilityVector.h"


@interface TEHeightMap : NSObject

@property (assign, nonatomic, readonly) NSInteger width;
@property (assign, nonatomic, readonly) NSInteger length;
@property (assign, nonatomic, readonly) BOOL isValid;


- (id)initFromPath:(NSString *)aPath;

- (GLfloat)heightAtXPos:(short int)x yPos:(short int)y;

@end
