 //
//  TEModel.h
//  TerrainEditor
//

#import <Foundation/Foundation.h>

@class TEMesh;


@interface TEModel : NSObject

@property (strong, nonatomic, readonly) TEMesh
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
   mesh:(TEMesh *)aMesh
   indexOfFirstCommand:(NSUInteger)aFirstIndex
   numberOfCommands:(NSUInteger)count;
- (id)initWithPlistRepresentation:(NSDictionary *)aDictionary
   mesh:(TEMesh *)aMesh;

- (void)draw;
- (void)drawBoundingBox;

@end
