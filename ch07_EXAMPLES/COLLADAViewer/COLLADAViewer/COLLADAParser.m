//
//  COLLADAParser.m
//  COLLADAViewer
//

#import "COLLADAParser.h"
#import "COLLADAGeometryParser.h"
#import "COLLADANode.h"
#include "UtilityMath.h"


/////////////////////////////////////////////////////////////////
//
static const float COLLADAParserMetersPerInch = 0.0254f;


@interface COLLADAParser ()

@property (retain, nonatomic) NSMutableDictionary *geometryByID;

@end


@implementation COLLADAParser

@synthesize geometryByID;
@synthesize rootNode;


/////////////////////////////////////////////////////////////////
// Designated initializer
- (id)init
{
   if(nil != (self = [super init]))
   {
      geometryByID = [NSMutableDictionary dictionary];
      rootNode = [[[COLLADARootNode alloc] init] autorelease];
   }
   
   return self;
}


#pragma mark - asset Element

/////////////////////////////////////////////////////////////////
// This method sets the rootNodes's axisCorrectionMatrix property
// based on element or a defualt value if neccessary. 
- (void)extractUpAxisFromAssetElement:(NSXMLElement *)element
{
   NSArray *upAxisElements = 
   [element elementsForName:@"up_axis"];
   NSString *elementValue = 
   [[upAxisElements lastObject] stringValue];
   
   if([@"X_UP" isEqualToString:elementValue])
   {  // Rotate 90 deg about Z
      rootNode.transforms = 
      UtilityMatrix4Rotate(
                           rootNode.transforms,
                           M_PI/2.0f,
                           0.0f,
                           0.0f,
                           1.0f);
   }
   else if([@"Y_UP" isEqualToString:elementValue])
   {  // Nothing required for this case
   }
   else 
   {  // Assume Z_UP: Rotate -90 deg about X
      rootNode.transforms = 
      UtilityMatrix4Rotate(
                           rootNode.transforms,
                           -M_PI/2.0f,
                           1.0f,
                           0.0f,
                           0.0f);
   }
}


/////////////////////////////////////////////////////////////////
// This method sets the rootNode's axisCorrectionMatrix property
// based on element or a defualt value if neccessary. 
- (void)extractUnitFromAssetElement:(NSXMLElement *)element
{
   NSArray *unitElements = 
   [element elementsForName:@"unit"];
   
   NSXMLElement *unit = [unitElements lastObject];
   NSXMLNode *meterNode = [unit attributeForName:@"meter"];
   NSString *metersPerUnit = [meterNode objectValue];
   
   if(nil != metersPerUnit && 0.0f < [metersPerUnit floatValue])
   {
      float metersPerUnitFactor = [metersPerUnit floatValue];
      
      rootNode.transforms = 
      UtilityMatrix4Scale(
                          rootNode.transforms,
                          metersPerUnitFactor,
                          metersPerUnitFactor,
                          metersPerUnitFactor);
   }
   else
   {
      rootNode.transforms = 
      UtilityMatrix4Scale(
                          rootNode.transforms,
                          COLLADAParserMetersPerInch,
                          COLLADAParserMetersPerInch,
                          COLLADAParserMetersPerInch);
   }
}


/////////////////////////////////////////////////////////////////
// Extracts the values of interest from the COLLADA asset 
// element and updates receiver's internal state accordingly.
- (void)parseAssetElements:(NSArray *)elements
{
   // We only care about at most one asset element
   NSXMLElement *element = [elements lastObject];
   
   if(nil != element)
   {
      [self extractUpAxisFromAssetElement:element];
      [self extractUnitFromAssetElement:element];
   }
   else
   {
      NSLog(@"No \"asset\" found: %@",
            @"Using defualt Z up and Inches converted to Meters.");
      
      // Set default values
      {  // Rotate -90 deg about X
         rootNode.transforms = 
         UtilityMatrix4MakeRotation(
                                    -M_PI/2.0f,
                                    1.0f,
                                    0.0f,
                                    0.0f);
         rootNode.transforms = 
         UtilityMatrix4Scale(
                             rootNode.transforms,
                             COLLADAParserMetersPerInch,
                             COLLADAParserMetersPerInch,
                             COLLADAParserMetersPerInch);
      }   
   }
}


#pragma mark - library_images Element

/////////////////////////////////////////////////////////////////
//  
- (void)extractPathFromLibraryImagesElement:
(NSXMLElement *)element
{
   NSArray *imageElements = 
   [element elementsForName:@"image"];
   NSXMLElement *imageElement = [imageElements lastObject];
   
   NSArray *pathElements = 
   [imageElement elementsForName:@"init_from"];   
   NSXMLElement *pathElement = [pathElements lastObject];
   NSString *path = [pathElement stringValue];
   
   if(nil == path)
   {
      NSLog(@"Failed extracting texture image path.");
   }
   
   rootNode.textureImagePath = path;
}


/////////////////////////////////////////////////////////////////
// Extracts the values of interest from the COLLADA 
// library_images element and updates receiver's internal state 
// accordingly.
- (void)parseLibraryImagesElements:(NSArray *)elements
{
   // We only care about at most one asset element
   NSXMLElement *element = [elements lastObject];
   
   if(nil != element)
   {
      [self extractPathFromLibraryImagesElement:element];
      
      if(1 < [elements count])
      {
         NSLog(@"More than one image found: Using <%@>",
               rootNode.textureImagePath);
      }
   }
   else
   {
      NSLog(@"No \"library_images\" found: %@",
            @"No texture image has been identified.");
   }
}


#pragma mark - library_geometries

/////////////////////////////////////////////////////////////////
//  
- (void)parseGeometryElement:(NSXMLElement *)element
{  // element is <geometry>
   NSString *geometryID = [[element attributeForName:@"id"]
                           objectValue];
   
   if(nil != geometryID)
   {
      COLLADAGeometryInfo *geometry = 
         [COLLADAGeometryParser geometryFromElement:element];
      
      // Remember the geometry for futire look-up when assembling
      // nodes etc.
      [self.geometryByID 
       setObject:geometry 
       forKey:[@"#" stringByAppendingString:geometryID]];
   }
   else
   {
      NSLog(@"Geometry found without ID and can't be used.");
   }
}


/////////////////////////////////////////////////////////////////
// Extracts the values of interest from the COLLADA 
// library_geometries element and updates receiver's internal 
// state accordingly.
- (void)parseLibraryGeometriesElements:(NSArray *)elements
{  // Assume only ONE <library_geometries>
   NSArray *geometries = 
   [[elements lastObject] elementsForName:@"geometry"];
   
   if(0 < [geometries count])
   {
      for(NSXMLElement *element in geometries)
      { // Each element is a "geometry"
         [self parseGeometryElement:element];
      }
   }
   else
   {
      NSLog(@"No \"library_geometries\" found: %@",
            @"No geometry (meshes) loaded.");
   }
}


#pragma mark - library_visual_scenes

/////////////////////////////////////////////////////////////////
//  
- (UtilityMatrix4)cumulativeTransformsForNodeElement:
   (NSXMLElement *)element
{
   // Collect transforms IN ORDER and apply to newNode
   // matrix
   UtilityMatrix4 cumulativeTransforms = 
      UtilityMatrix4Identity;
   
   for(NSXMLElement *subElement in [element children])
   {
      if([subElement.name isEqualToString:@"translate"])
      {
         NSString *arguments = [subElement stringValue];
         NSArray *separateArgumnts = 
         [arguments componentsSeparatedByString:@" "];
         if(3 != [separateArgumnts count])
         {
            NSLog(@"Incorrect number of <translate> values.");
         }
         else
         {
            float x = [[separateArgumnts objectAtIndex:0]
                       floatValue];
            float y = [[separateArgumnts objectAtIndex:1]
                       floatValue];
            float z = [[separateArgumnts objectAtIndex:2]
                       floatValue];
            
            cumulativeTransforms = 
            UtilityMatrix4Translate(cumulativeTransforms, 
                                    x, 
                                    y, 
                                    z);
         }
      }
      else if([subElement.name isEqualToString:@"rotate"])
      {
         NSString *arguments = [subElement stringValue];
         NSArray *separateArgumnts = 
         [arguments componentsSeparatedByString:@" "];
         if(4 != [separateArgumnts count])
         {
            NSLog(@"Incorrect number of <rotate> values.");
         }
         else
         {
            float x = [[separateArgumnts objectAtIndex:0]
                       floatValue];
            float y = [[separateArgumnts objectAtIndex:1]
                       floatValue];
            float z = [[separateArgumnts objectAtIndex:2]
                       floatValue];
            float angleDeg = [[separateArgumnts objectAtIndex:3]
                              floatValue];
            
            cumulativeTransforms = 
            UtilityMatrix4Rotate(
                                 cumulativeTransforms,
                                 angleDeg * UtilityDegreesToRadians, 
                                 x, 
                                 y, 
                                 z);
         }
      }
      else if([subElement.name isEqualToString:@"scale"])
      {
         NSString *arguments = [subElement stringValue];
         NSArray *separateArgumnts = 
         [arguments componentsSeparatedByString:@" "];
         if(3 != [separateArgumnts count])
         {
            NSLog(@"Incorrect number of <scale> values.");
         }
         else
         {
            float x = [[separateArgumnts objectAtIndex:0]
                       floatValue];
            float y = [[separateArgumnts objectAtIndex:1]
                       floatValue];
            float z = [[separateArgumnts objectAtIndex:2]
                       floatValue];
            
            cumulativeTransforms = 
            UtilityMatrix4Scale(
                                cumulativeTransforms, 
                                x, 
                                y, 
                                z);
         }
      }
      else if([subElement.name isEqualToString:@"matrix"])
      {
         NSString *arguments = [subElement stringValue];
         NSArray *separateArgumnts = 
         [arguments componentsSeparatedByString:@" "];
         if(16 != [separateArgumnts count])
         {
            NSLog(@"Incorrect number of <matrix> values.");
         }
         else
         {
            float  matrixFloats[16];
            for(int i = 0; i < 16; i++)
            {
               matrixFloats[i] = [[separateArgumnts objectAtIndex:i]
                       floatValue];
            }
            UtilityMatrix4 matrix = 
               UtilityMatrix4MakeWithArray(matrixFloats);
               
            cumulativeTransforms = 
               UtilityMatrix4Multiply(
                  cumulativeTransforms, 
                  matrix);
         }
      }
   }
   
   return cumulativeTransforms;
}


/////////////////////////////////////////////////////////////////
//  
- (void)parseNodeElement:(NSXMLElement *)element
   parentNode:(COLLADANode *)parent;
{ // element is <node>
   COLLADANode *newNode = [[[COLLADANode alloc]
      init] autorelease];
   
   NSXMLNode *nodeNameNode = [element attributeForName:@"name"];
   NSString *nodeName = [nodeNameNode objectValue];
   
   if(nil == nodeName)
   {
      NSXMLNode *nodeIDNode = [element attributeForName:@"id"];
      nodeName = [nodeIDNode objectValue];
   
      if(nil == nodeName)
      {
         NSLog(@"<node> has no name or id");
      }
      else
      {
         nodeName = @"<ANONYMOUS>";
      }
   }
   newNode.name = nodeName;

   NSArray *instanceGeometries = 
      [element elementsForName:@"instance_geometry"];
   
   for(NSXMLElement *instanceGeometry in instanceGeometries)
   {  
      NSXMLNode *urlNode = 
         [instanceGeometry attributeForName:@"url"];
      NSString *urlID = [urlNode objectValue];
      
      COLLADAGeometryInfo *geometry = 
         [self.geometryByID objectForKey:urlID];
      
      if(nil == geometry)
      {
         NSLog(@"Failed to locate <instance_geometry>: %@",
               urlID);
      }
      else
      {
         [newNode appendMesh:geometry.mesh];
      }
   }

   // Recursively add subnodes to newNode
   NSArray *subNodes = 
     [element elementsForName:@"node"];
   if(nil != subNodes && 
      0 < [subNodes count])
   {  
      for(NSXMLElement *subNode in subNodes)
      {
         [self parseNodeElement:subNode
           parentNode:newNode];
      }
   }
   
   newNode.transforms = [self
      cumulativeTransformsForNodeElement:element];
   
   // Add newNode to its own parent
   [parent addSubnode:newNode];
}


/////////////////////////////////////////////////////////////////
// Extracts the values of interest from the COLLADA 
// library_visual_scenes element and updates receiver's internal 
// state accordingly.
- (void)parseLibraryVisualScenesElements:(NSArray *)elements;
{  // Assume only ONE <library_visual_scenes>
   NSArray *visualScenes = 
      [[elements lastObject] elementsForName:@"visual_scene"];
   
   for(NSXMLElement *visualScene in visualScenes)
   {
      NSArray *nodes = [visualScene elementsForName:@"node"];
      
      for(NSXMLElement *node in nodes)
      {
         [self parseNodeElement:node 
            parentNode:self.rootNode];
      }
   }
}

#pragma mark - Document Level

/////////////////////////////////////////////////////////////////
// Extracts each top level elemement of interest.
- (void)parseXMLDocument:(NSXMLDocument *)xmlDoc
{
   NSXMLElement *rootElement = [xmlDoc rootElement]; 
   
   NSArray *assetElements = 
   [rootElement elementsForName:@"asset"];
   [self parseAssetElements:assetElements];
   
   NSArray *libraryImages = 
   [rootElement elementsForName:@"library_images"];
   [self parseLibraryImagesElements:libraryImages];
   
   NSArray *libraryGeometries = 
   [rootElement elementsForName:@"library_geometries"];
   [self parseLibraryGeometriesElements:libraryGeometries];
   
   NSArray *libraryVisualScenes = 
   [rootElement elementsForName:@"library_visual_scenes"];
   [self parseLibraryVisualScenesElements:
      libraryVisualScenes];
   
   //NSArray *libraryAnimations = 
   //   [rootElement elementsForName:@"library_animations"];
   //NSArray *libraryLights = 
   //   [rootElement elementsForName:@"library_lights"];
   //NSArray *libraryMaterials = 
   //   [rootElement elementsForName:@"library_materials"];
   //NSArray *libraryEffects = 
   //   [rootElement elementsForName:@"library_effects"];
   //NSArray *libraryControllers = 
   //   [rootElement elementsForName:@"library_controllers"];
   //NSArray *scene = 
   //   [rootElement elementsForName:@"scene"];
   
   //NSLog(@"%@", libraryAnimations);
   //NSLog(@"%@", libraryLights);
   //NSLog(@"%@", libraryImages);
   //NSLog(@"%@", libraryMaterials);
   //NSLog(@"%@", libraryEffects);
   //NSLog(@"%@", libraryGeometries);
   //NSLog(@"%@", libraryControllers);
   //NSLog(@"%@", libraryVisualScenes);
   //NSLog(@"%@", scene);
}


/////////////////////////////////////////////////////////////////
//
- (void)parseCOLLADAFileAtPath:(NSString *)filePath 
{
   NSURL *furl = [NSURL fileURLWithPath:filePath];
   
   if (!furl) 
   {
      NSLog(@"Can't create an URL from file %@.", filePath);
      return;
   }
   
   NSError *error = nil;
   NSXMLDocument *xmlDoc = 
   [[[NSXMLDocument alloc] 
     initWithContentsOfURL:furl
     options:(NSXMLNodePreserveWhitespace|NSXMLNodePreserveCDATA)
     error:&error] autorelease];
   
   if (nil == xmlDoc) 
   {
      xmlDoc = 
      [[NSXMLDocument alloc] 
       initWithContentsOfURL:furl
       options:NSXMLDocumentTidyXML
       error:&error];
   }
   
   if (nil != error) 
   {
      NSLog(@"Unrecoverable parsing error: %@", error);
   }
   else
   {
      [self parseXMLDocument:xmlDoc];
      rootNode.path = [filePath stringByDeletingLastPathComponent];
   }
}

@end
