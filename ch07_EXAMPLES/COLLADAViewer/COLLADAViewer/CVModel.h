//
//  CVModel.h
//  COLLADAViewer
//

#import <Foundation/Foundation.h>

@class CVMesh;

@interface CVModel : NSObject

@property (strong, nonatomic, readonly) CVMesh
   *mesh;
@property (copy, nonatomic, readwrite) NSString
   *name;
@property (copy, nonatomic, readonly) NSString
   *axisAlignedBoundingBox;
@property (strong, nonatomic, readonly) NSNumber
   *numberOfVertices;
@property (strong, nonatomic, readonly) NSDictionary
   *plistRepresentation;

- (id)initWithName:(NSString *)aName 
   mesh:(CVMesh *)aMesh
   indexOfFirstCommand:(NSUInteger)aFirstIndex
   numberOfCommands:(NSUInteger)count;
- (id)initWithPlistRepresentation:(NSDictionary *)aDictionary
   mesh:(CVMesh *)aMesh;

- (void)draw;
- (void)drawNormalsLength:(GLfloat)lineLength;

@end
