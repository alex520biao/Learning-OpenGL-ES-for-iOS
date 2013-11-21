//
//  COLLADAGeometryInfo.h
//  COLLADAViewer
//

#import <Foundation/Foundation.h>
#include "UtilityVector.h"
#import "UtilityMatrix.h"

@class COLLADAParser;
@class CVMesh;


/////////////////////////////////////////////////////////////////
//  
typedef struct
{
   GLushort positionIndex;
   GLushort normalIndex;
   GLushort texCoord0Index;
   GLushort texCoord1Index;
}
COLLADAIndexGroup;


/////////////////////////////////////////////////////////////////
//  
typedef struct
{
   const UtilityVector3 *positionCoordsPtr;
   const UtilityVector3 *normalCoordsPtr;
   const UtilityVector2 *texCoord0Ptr;
   const UtilityVector2 *texCoord1Ptr;
}
COLLADAVertexAttributePointers;


/////////////////////////////////////////////////////////////////
//  
@interface COLLADATrianglesInfo : NSObject

@property (retain, nonatomic) NSString *materialID;
@property (retain, nonatomic) NSString *vertexSourceID;
@property (retain, nonatomic) NSString *normalSourceID;
@property (retain, nonatomic) NSString *texCoordSourceID;
@property (assign, nonatomic) NSInteger vertexOffset;
@property (assign, nonatomic) NSInteger normalOffset;
@property (assign, nonatomic) NSInteger texCoordOffset;
@property (retain, nonatomic) NSMutableData *indices;
@property (assign, nonatomic) NSInteger numberOfSources;

- (NSUInteger)numberOfIndexGroups;
- (COLLADAIndexGroup)indexGroupAtIndex:(NSUInteger)anIndex;

@end


/////////////////////////////////////////////////////////////////
//  
@interface COLLADAVertexInfo : NSObject

@property (retain, nonatomic) NSString *verticesID;
@property (retain, nonatomic) NSString *positionSourceID;
@property (retain, nonatomic) NSString *normalSourceID;
@property (retain, nonatomic) NSString *texCoordSourceID;
@property (retain, nonatomic) NSString *vertexSourceID;

@end


/////////////////////////////////////////////////////////////////
//  
@interface COLLADASourceInfo : NSObject

@property (retain, nonatomic) NSData *floatData;
@property (copy, nonatomic) NSString *sourceID;
@property (assign, nonatomic) NSUInteger stride;

@end

/////////////////////////////////////////////////////////////////
//  
@interface COLLADAGeometryInfo : NSObject

@property (copy, nonatomic)
   NSString *geometryID;
@property (nonatomic, readonly, retain)
   CVMesh *mesh;
@property (nonatomic, readonly, assign)
   NSUInteger nextAvalableIndex;
@property (retain, nonatomic, readonly)
   NSMutableDictionary *mutableSourcesByID;
@property (retain, nonatomic, readonly)
   NSMutableDictionary *mutableVertexInfoByID;



- (id)initWithID:(NSString *)aGeometryID;

- (void)appendTriangles:(COLLADATrianglesInfo *)triangles;
   
- (GLushort)appendIndexGroup:(COLLADAIndexGroup)anIndexGroup
   attributePointers:(COLLADAVertexAttributePointers)pointers;
   
@end
