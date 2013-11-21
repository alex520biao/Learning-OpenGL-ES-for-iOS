//
//  TETool.h
//  TerrainEditor
//

#import <Cocoa/Cocoa.h>


@interface TETool : NSObject

@property (strong, nonatomic, readwrite) IBOutlet NSView *supportView;
@property (assign, nonatomic, readwrite) IBOutlet id owner;

- (void)becomeActive;
- (void)resignActive;

- (void)mouseDown:(NSEvent *)theEvent;
- (void)mouseDragged:(NSEvent *)theEvent;
- (void)mouseUp:(NSEvent *)theEvent;

@end
