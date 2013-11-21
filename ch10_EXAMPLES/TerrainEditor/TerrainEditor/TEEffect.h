//
//  TEEffect.h
//  
//

#import <Cocoa/Cocoa.h>

@interface TEEffect : NSObject

@property (assign, nonatomic, readonly) GLuint program;

- (void)prepareOpenGL;
- (void)updateUniformValues;
- (void)prepareToDraw;

// Required overrides
- (void)bindAttribLocations;
- (void)configureUniformLocations;

- (BOOL)loadShadersWithName:(NSString *)aShaderName;

@end
