//
//  COLLADAGeometryParser.m
//  COLLADAViewer
//

#import "COLLADAGeometryParser.h"
#import "COLLADAParser.h"
#import "COLLADAGeometryInfo.h"
#import "CVMesh.h"


@interface COLLADAGeometryParser ()

@end


@implementation COLLADAGeometryParser

/////////////////////////////////////////////////////////////////
//  
+ (COLLADAGeometryInfo *)geometryFromElement:
   (NSXMLElement *)element;
{  // element is <geometry>
   COLLADAGeometryParser *geometryParser = 
      [[COLLADAGeometryParser alloc] init];
   
   COLLADAGeometryInfo *result = 
      [geometryParser extractGeometryFromGeometryElement:element];
   
   [geometryParser release];
   geometryParser = nil;
   
   return result;
}


/////////////////////////////////////////////////////////////////
//  Designated initializer
- (id)init;
{
   if(nil != (self = [super init]))
   {
   }
   
   return self;
}


/////////////////////////////////////////////////////////////////
//  
- (NSUInteger)extractStrideFromElement:(NSXMLElement *)element
{ // element is <source>
   NSUInteger result = 1;  // Default value
   
   NSArray *techniqueArrays = [element elementsForName:
      @"technique_common"];

   if(1 < [techniqueArrays count])
   {
      NSLog(@"More than one technique_common in source: %@",
         @"Extra data discarded.");
   }
   
   // element changed to <technique_common>
   element = [techniqueArrays lastObject];
   
   NSArray *accessorArrays = [element elementsForName:
      @"accessor"];

   if(1 < [accessorArrays count])
   {
      NSLog(@"More than one accessor in source: %@",
         @"Extra data discarded.");
   }
   
   // element changed to <accessor>
   element = [accessorArrays lastObject];
   
   NSXMLNode *strideNode = [element attributeForName:@"stride"];   
   NSString *strideString = [strideNode objectValue];
   
   if(nil == strideString)
   {
      NSLog(@"Unable to extract stride from source");
   }
   else
   {
      result = (NSUInteger)[strideString integerValue];
   }
   
   return result;
}


/////////////////////////////////////////////////////////////////
//  
- (NSData *)extractFloatArrayFromElement:(NSXMLElement *)element
{  // element is <source>
   NSArray *floatArrays = [element elementsForName:
      @"float_array"];

   if(1 < [floatArrays count])
   {
      NSLog(@"More than one float_array in source: %@",
         @"Extra data discarded.");
   }
   
   // element changed to <float_array>
   element = [floatArrays lastObject];
   
   //NSXMLNode *idNode = [element attributeForName:@"id"];   
   //NSString *arrayID = [idNode objectValue];
   NSArray *values = [[element stringValue] 
      componentsSeparatedByString:@" "];
   NSMutableData *floatData = [NSMutableData data];
      
   for(NSString *value in values)
   {
      float floatValue = [value floatValue];
      
      [floatData appendBytes:&floatValue 
         length:sizeof(floatValue)];
   }
   
   return floatData;
}


/////////////////////////////////////////////////////////////////
//  
- (COLLADASourceInfo *)extractSourceFromElement:
   (NSXMLElement *)source
{  // source is <source>
   COLLADASourceInfo *newSource = 
      [[[COLLADASourceInfo alloc] init] autorelease];

   // <source id=
   NSXMLNode *sourceIDNode = [source attributeForName:@"id"];   
   NSString *sourceIDString = [sourceIDNode objectValue];
   
   if(nil == sourceIDString)
   {
      NSLog(@"Unable to extract ID from <source>");
   }
   else
   {
      newSource.sourceID = sourceIDString;
   }

   // <float_array>
   NSData *floatData = [self extractFloatArrayFromElement:
      source];
   newSource.floatData = floatData;

   // <accessor stride=
   NSUInteger stride = [self extractStrideFromElement:
      source];
   NSAssert(0 < stride, @"Invalid souce stride");
   newSource.stride = stride;
   
   return newSource;
}


/////////////////////////////////////////////////////////////////
//  
- (COLLADAVertexInfo *)extractVertexInfoFromElement:
   (NSXMLElement *)vertexInfo
{  // source is <source>
   COLLADAVertexInfo *newVertexInfo = 
      [[[COLLADAVertexInfo alloc] init] autorelease];

   // <vertices id=
   NSXMLNode *verticesIDNode = 
      [vertexInfo attributeForName:@"id"];   
   NSString *verticesIDString = [verticesIDNode objectValue];
   
   if(nil == verticesIDString)
   {
      NSLog(@"Unable to extract ID from <vertices>");
   }
   else
   {
      newVertexInfo.verticesID = verticesIDString;
   }

   // <input>
   NSArray *inputs = [vertexInfo elementsForName:@"input"];
   for(NSXMLElement *input in inputs)
   {
      NSXMLNode *semanticNode = 
         [input attributeForName:@"semantic"];   
      NSString *semanticString = [semanticNode objectValue];
      NSXMLNode *sourceIDNode = 
         [input attributeForName:@"source"];   
      NSString *sourceIDString = [sourceIDNode objectValue];
      NSAssert(nil != sourceIDString && nil != semanticString,
          @"<vertices> missing essential attribtes.");
      
      if([@"POSITION" isEqualToString:semanticString])
      {
         newVertexInfo.positionSourceID = sourceIDString;
      }
      else if([@"NORMAL" isEqualToString:semanticString])
      {
         newVertexInfo.normalSourceID = sourceIDString;
      }
      else if([@"TEXCOORD" isEqualToString:semanticString])
      {
         newVertexInfo.texCoordSourceID = sourceIDString;
      }
      else if([@"VERTEX" isEqualToString:semanticString])
      {
         newVertexInfo.vertexSourceID = sourceIDString;
      }
      else
      {
         NSLog(@"Unrecognized <input semantic=>: %@",
            semanticString);
      }
   }
   
   return newVertexInfo;
}


/////////////////////////////////////////////////////////////////
//  
- (COLLADATrianglesInfo *)extractTrianglesInfoFromElement:
   (NSXMLElement *)triangle;
{  // source is <triangles>
   COLLADATrianglesInfo *newTriangleInfo = 
      [[[COLLADATrianglesInfo alloc] init] autorelease];

   NSXMLNode *materialIDNode = 
      [triangle attributeForName:@"material"];   
   NSString *materialIDString = [materialIDNode objectValue];
   newTriangleInfo.materialID = materialIDString;
   
   // <input>
   NSArray *inputs = [triangle elementsForName:@"input"];
   newTriangleInfo.numberOfSources = [inputs count];
   for(NSXMLElement *input in inputs)
   {
      NSXMLNode *semanticNode = 
         [input attributeForName:@"semantic"];   
      NSString *semanticString = [semanticNode objectValue];
      NSXMLNode *sourceIDNode = 
         [input attributeForName:@"source"];   
      NSString *sourceIDString = [sourceIDNode objectValue];
      NSAssert(nil != sourceIDString && nil != semanticString,
          @"<triangles> missing essential attribtes.");
      NSXMLNode *offsetNode = 
         [input attributeForName:@"offset"];   
      NSString *offsetString = [offsetNode objectValue];
      
      if([@"NORMAL" isEqualToString:semanticString])
      {
         newTriangleInfo.normalSourceID = sourceIDString;
         newTriangleInfo.normalOffset = 
            [offsetString integerValue];
      }
      else if([@"TEXCOORD" isEqualToString:semanticString])
      {
         newTriangleInfo.texCoordSourceID = sourceIDString;
         newTriangleInfo.texCoordOffset = 
            [offsetString integerValue];
      }
      else if([@"VERTEX" isEqualToString:semanticString])
      {
         newTriangleInfo.vertexSourceID = sourceIDString;
         newTriangleInfo.vertexOffset = 
            [offsetString integerValue];
      }
      else
      {
         NSLog(@"Unrecognized <input semantic=>: %@",
            semanticString);
      }
   }
   
   // <p>
   newTriangleInfo.indices = [NSMutableData data];
   NSArray *indices = [triangle elementsForName:@"p"];
   for(NSXMLElement *p in indices)
   {
      NSArray *values = [[p stringValue] 
         componentsSeparatedByString:@" "];

      for(NSString *value in values)
      {
         GLushort indexValue = (GLushort)[value intValue];
         
         [newTriangleInfo.indices appendBytes:&indexValue 
            length:sizeof(indexValue)];
      }
   }
   
   return newTriangleInfo;
}


/////////////////////////////////////////////////////////////////
// Only 3 sides polygons are supported so polylist is synonomous
// with triangles (hopefully!)
- (COLLADATrianglesInfo *)extractPolylistInfoFromElement:
   (NSXMLElement *)polylist;
{  // polylist is <polylist>
   COLLADATrianglesInfo *newTriangleInfo = 
      [[[COLLADATrianglesInfo alloc] init] autorelease];

   NSXMLNode *materialIDNode = 
      [polylist attributeForName:@"material"];   
   NSString *materialIDString = [materialIDNode objectValue];
   newTriangleInfo.materialID = materialIDString;
   newTriangleInfo.vertexOffset = 0;
   newTriangleInfo.normalOffset = 0;
   newTriangleInfo.texCoordOffset = 0;
   
   // <input>
   NSArray *inputs = [polylist elementsForName:@"input"];
   for(NSXMLElement *input in inputs)
   {
      NSXMLNode *semanticNode = 
         [input attributeForName:@"semantic"];   
      NSString *semanticString = [semanticNode objectValue];
      NSXMLNode *sourceIDNode = 
         [input attributeForName:@"source"];   
      NSString *sourceIDString = [sourceIDNode objectValue];
      NSAssert(nil != sourceIDString && nil != semanticString,
          @"<polylist> missing essential attribtes.");
      NSXMLNode *offsetNode = 
         [input attributeForName:@"offset"];   
      NSString *offsetString = [offsetNode objectValue];
      
      if([@"NORMAL" isEqualToString:semanticString])
      {
         newTriangleInfo.normalSourceID = sourceIDString;
         newTriangleInfo.normalOffset = 
            [offsetString integerValue];
      }
      else if([@"TEXCOORD" isEqualToString:semanticString])
      {
         newTriangleInfo.texCoordSourceID = sourceIDString;
         newTriangleInfo.texCoordOffset = 
            [offsetString integerValue];
      }
      else if([@"VERTEX" isEqualToString:semanticString])
      {
         newTriangleInfo.vertexSourceID = sourceIDString;
         newTriangleInfo.vertexOffset = 
            [offsetString integerValue];
      }
      else
      {
         NSLog(@"Unrecognized <input semantic=>: %@",
            semanticString);
      }
   }
   
   // <p>
   newTriangleInfo.indices = [NSMutableData data];
   NSArray *indices = [polylist elementsForName:@"p"];
   for(NSXMLElement *p in indices)
   {
      NSArray *values = [[p stringValue] 
         componentsSeparatedByString:@" "];

      for(NSString *value in values)
      {
         GLushort indexValue = (GLushort)[value intValue];
         
         [newTriangleInfo.indices appendBytes:&indexValue 
            length:sizeof(indexValue)];
      }
   }
   
   return newTriangleInfo;
}


/////////////////////////////////////////////////////////////////
//  
- (COLLADAGeometryInfo *)extractGeometryFromGeometryElement:
   (NSXMLElement *)element;
{  // element is <geometry>
   NSString *geometryID = [[element attributeForName:@"id"]
      objectValue];
   
   if(nil == geometryID)
   {
      NSLog(@"Geometry found without ID and can't be used.");
      return nil;
   }

   COLLADAGeometryInfo *result = [[[COLLADAGeometryInfo alloc]
      initWithID:geometryID] autorelease];

   COLLADATrianglesInfo *meshTrianglesInfo = nil;
   NSArray *meshes = [element elementsForName:@"mesh"];
   
   for(NSXMLElement *mesh in meshes)
   { // mesh is <mesh>
      NSArray *sources = [mesh elementsForName:@"source"];
      NSArray *vertices = [mesh elementsForName:@"vertices"];
      NSArray *triangles = [mesh elementsForName:@"triangles"];
      NSArray *polylists = [mesh elementsForName:@"polylist"];
      NSArray *lines = [mesh elementsForName:@"lines"];
      
      // Parse each <source>
      for(NSXMLElement *source in sources)
      {  // source is <source>
         COLLADASourceInfo *newSource = 
            [self extractSourceFromElement:source];
         NSAssert(nil != newSource && nil != newSource.sourceID,
            @"Invalid <source>");
               
         [result.mutableSourcesByID setObject:newSource 
            forKey:[@"#" stringByAppendingString:
               newSource.sourceID]];
      }
      
      // Parse each <vertices> info element
      for(NSXMLElement *vertexInfo in vertices)
      {  // vertexInfo is <vertices>
         COLLADAVertexInfo *newVertexInfo = 
            [self extractVertexInfoFromElement:vertexInfo];
         NSAssert(nil != newVertexInfo && 
            nil != newVertexInfo.verticesID,
            @"Invalid <source>");
         
         [result.mutableVertexInfoByID setObject:newVertexInfo 
            forKey:[@"#" stringByAppendingString:
               newVertexInfo.verticesID]];
      }
      
      if(nil != triangles && 0 < [triangles count])
      {
         // Parse each <triangles> element
         for(NSXMLElement *triangle in triangles)
         { // triangle is <triangles>
            meshTrianglesInfo = 
               [self extractTrianglesInfoFromElement:triangle];
            NSAssert(nil != meshTrianglesInfo,
               @"Invalid <triangles>");
            
            [result appendTriangles:meshTrianglesInfo];
         }
      }      
      else if(nil != polylists && 0 < [polylists count])
      {
         // Parse each <polylist> element
         for(NSXMLElement *polylist in polylists)
         { // polylist is <polylist>
            meshTrianglesInfo = 
               [self extractTrianglesInfoFromElement:polylist];
            NSAssert(nil != meshTrianglesInfo,
               @"Invalid <triangles>");
            
            [result appendTriangles:meshTrianglesInfo];
         }
      }
      else if(nil != lines && 0 < [lines count])
      { // Lines currently ignored
      }
      else
      {
         NSLog(@"Mesh has niether <triangles> nor <polylist>");
      }
      
   }
   
   return result;
}

@end
