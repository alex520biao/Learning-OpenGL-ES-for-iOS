//
//  UtilityModel.m
// 
//

#import "UtilityModel.h"
#import "UtilityMesh.h"


@interface UtilityModel ()

@property (copy, nonatomic, readwrite) NSString
   *name;
@property (strong, nonatomic, readwrite) UtilityMesh
   *mesh;
@property (assign, nonatomic, readwrite) NSUInteger
   indexOfFirstCommand;
@property (assign, nonatomic, readwrite) NSUInteger
   numberOfCommands;
@property (assign, nonatomic, readwrite) 
   AGLKAxisAllignedBoundingBox axisAlignedBoundingBox;

@end


@implementation UtilityModel

@synthesize mesh = mesh_;
@synthesize name = name_;
@synthesize indexOfFirstCommand = indexOfFirstCommand_;
@synthesize numberOfCommands = numberOfCommands_;
@synthesize axisAlignedBoundingBox = axisAlignedBoundingBox_;
@synthesize doesRequireLighting = doesRequireLighting_;


/////////////////////////////////////////////////////////////////
// This function returns an axis aligned bounding box initialized
// with dimensions parsed from aString.
static AGLKAxisAllignedBoundingBox UtilityBoundingBoxFromString(
   NSString *aString);

   
/////////////////////////////////////////////////////////////////
// This method returns nil. 
- (id)init
{
   NSAssert(NO, @"Invalid initializer");
   return nil;
}


/////////////////////////////////////////////////////////////////
// Designated initializer. The aMesh argument is a mesh 
// containing all of the vertex attributes for all multiple
// models. The aFirstIndex argument specified the first mesh
// drawing command for the model being initialized. The 
// numberOfCommands argument specifies the number of mesh
// drawing commands for the model being specified. The 
// aBoundingBox argument defines an axis aligned bounding box
// that encloses the model being initialized.
// The receiver's diffuse material color is set to white.
- (id)initWithName:(NSString *)aName 
   mesh:(UtilityMesh *)aMesh
   indexOfFirstCommand:(NSUInteger)aFirstIndex
   numberOfCommands:(NSUInteger)count
   axisAlignedBoundingBox:(AGLKAxisAllignedBoundingBox)
      aBoundingBox
{
   if(nil != (self=[super init]))
   {
      mesh_ = aMesh;
      name_ = aName;
      indexOfFirstCommand_ = aFirstIndex;
      numberOfCommands_ = count;
      axisAlignedBoundingBox_ = aBoundingBox;
   }
   
   return self;
}


/////////////////////////////////////////////////////////////////
// This method calls the designated initializer using arguments
// obtained from aDictionary and aMesh. The receiver's
// material diffuse color is also set using values obtained from
// aDictionary.
- (id)initWithPlistRepresentation:(NSDictionary *)aDictionary
   mesh:(UtilityMesh *)aMesh
{
   NSString *aName = [aDictionary objectForKey:UtilityModelName];
   NSUInteger aFirstIndex = 
      [[aDictionary objectForKey:UtilityModelIndexOfFirstCommand] 
         unsignedIntegerValue];
   NSUInteger aNumberOfCommands = 
      [[aDictionary objectForKey:UtilityModelNumberOfCommands] 
         unsignedIntegerValue];
   NSString *anAxisAlignedBoundingBoxString = 
      [aDictionary objectForKey:UtilityModelAxisAlignedBoundingBox];
   AGLKAxisAllignedBoundingBox box =     
      UtilityBoundingBoxFromString(anAxisAlignedBoundingBoxString);
      
   return [self 
      initWithName:aName
      mesh:aMesh
      indexOfFirstCommand:aFirstIndex 
      numberOfCommands:aNumberOfCommands
      axisAlignedBoundingBox:box];         
}

@end


/////////////////////////////////////////////////////////////////
// This function returns an axis aligned bounding box initialized
// with dimensions parsed from aString.
static AGLKAxisAllignedBoundingBox 
   UtilityBoundingBoxFromString(NSString *aString)
{
   NSCParameterAssert(nil != aString);
   
   // Strip characters that don't contain needed information
   aString = [aString stringByReplacingOccurrencesOfString:@"{" 
      withString:@""];
   aString = [aString stringByReplacingOccurrencesOfString:@"}" 
      withString:@""];
      
   // Parse the coordinates into an array
   NSArray *coordsArray = [aString 
      componentsSeparatedByString:@","];
   
   // Verify that the right number of coordinates are present
   NSCAssert(6 == [coordsArray count], 
      @"invalid AGLKAxisAllignedBoundingBox");
      
   AGLKAxisAllignedBoundingBox result;
   result.min.x = [[coordsArray objectAtIndex:0] floatValue];
   result.min.y = [[coordsArray objectAtIndex:1] floatValue];
   result.min.z = [[coordsArray objectAtIndex:2] floatValue];
   result.max.x = [[coordsArray objectAtIndex:3] floatValue];
   result.max.y = [[coordsArray objectAtIndex:4] floatValue];
   result.max.z = [[coordsArray objectAtIndex:5] floatValue];
   
   return result;
}


/////////////////////////////////////////////////////////////////
// Constants used to access model properties from a plist
// dictionary.
NSString *const UtilityModelName = @"name";
NSString *const UtilityModelIndexOfFirstCommand =
   @"indexOfFirstCommand";
NSString *const UtilityModelNumberOfCommands =
   @"numberOfCommands";
NSString *const UtilityModelAxisAlignedBoundingBox =
   @"axisAlignedBoundingBox";
NSString *const UtilityModelDrawingCommand = 
   @"command";   
