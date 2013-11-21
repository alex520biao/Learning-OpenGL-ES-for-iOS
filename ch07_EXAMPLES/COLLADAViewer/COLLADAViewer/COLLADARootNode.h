//
//  COLLADARootNode.h
//  COLLADAViewer
//

#import "COLLADANode.h"

@class UtilityTextureInfo;


@interface COLLADARootNode : COLLADANode

@property (nonatomic, readwrite, copy) NSString 
   *path;
@property (nonatomic, readwrite, copy) NSString 
   *textureImagePath;
@property (retain, nonatomic, readonly) CVMesh 
   *consolidatedMesh;
@property (nonatomic, readonly, retain) UtilityTextureInfo 
   *textureInfo;
@property (nonatomic, readonly, assign) NSUInteger 
   numberOfElements;

- (void)drawConsolidatedMesh;
- (void)drawNormalsConsolidatedMesh;

@end
