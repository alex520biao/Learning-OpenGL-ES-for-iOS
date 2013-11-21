//
//  UtilityTextureLoader.h
//  
//

#include "UtilityVector.h"
#import <OpenGL/gl.h>

#pragma mark -UtilityTextureInfo

@interface UtilityTextureInfo : NSObject <NSCoding, NSCopying>

@property (nonatomic, readonly, assign) GLuint name;
@property (nonatomic, readonly, assign) GLenum target;
@property (nonatomic, readonly, assign) size_t width;
@property (nonatomic, readonly, assign) size_t height;
@property (nonatomic, readonly, strong) NSData *imageData;
@property (nonatomic, readonly, strong) NSMutableData *mutableImageData;
@property (nonatomic, readonly, strong) NSDictionary
   *plistRepresentation;

- (id)initWithPlistRepresentation:(NSDictionary *)aDictionary;

- (void)discardLocalImageData;

- (NSImage *)image;

- (void)updateWithModifiedRGBComponents:
   (UtilityVector3)values 
   at:(UtilityVector2)aPosition
   radius:(GLfloat)aRadius;
   
@end


#pragma mark -UtilityTextureLoader

@interface UtilityTextureLoader : NSObject

+ (UtilityTextureInfo *)textureWithCGImage:(CGImageRef)cgImage                                                         options:(NSDictionary *)options 
   error:(NSError **)outError; 
   
@end
