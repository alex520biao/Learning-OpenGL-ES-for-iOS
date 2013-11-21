//
//  COLLADANode.h
//  COLLADAViewer
//

#import <Foundation/Foundation.h>
#import "COLLADAGeometryInfo.h"
#import "UtilityMatrix.h"


@interface COLLADANode : NSObject

@property (copy, nonatomic) NSString *name;
@property (retain, nonatomic, readonly) CVMesh *mesh;
@property (assign, nonatomic) UtilityMatrix4 transforms;
@property (nonatomic, readonly, retain) NSSet 
   *subnodes;
@property (nonatomic, readwrite, assign) COLLADANode 
   *parent;

- (void)draw;
- (void)drawNormals;

- (void)addSubnode:(COLLADANode *)aNode;
- (void)appendMesh:(CVMesh *)aMesh;
- (void)appendMeshesToMesh:(CVMesh *)aMesh
   cumulativeTransforms:(UtilityMatrix4)cumulativeTransforms;

@end
