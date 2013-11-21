//
//  TEModel.m
//  TerrainEditor
//

#import "TEModel.h"
#import "TEMesh.h"


@interface TEModel ()

@property (strong, nonatomic, readwrite) TEMesh
   *mesh;
@property (strong, nonatomic, readwrite) NSNumber
   *numberOfVertices;
@property (assign, nonatomic, readwrite) NSUInteger
   indexOfFirstCommand;
@property (assign, nonatomic, readwrite) NSUInteger
   numberOfCommands;

- (NSNumber *)calculateNumberOfVertices;

@end


@implementation TEModel

@synthesize mesh;
@synthesize name;
@synthesize numberOfVertices;
@synthesize indexOfFirstCommand;
@synthesize numberOfCommands;


/////////////////////////////////////////////////////////////////
//
- (id)init
{
   [self release];
   self = nil;
   
   NSAssert(NO, @"Invalid initializer");
   return self;
}


/////////////////////////////////////////////////////////////////
//
- (id)initWithName:(NSString *)aName 
   mesh:(TEMesh *)aMesh
   indexOfFirstCommand:(NSUInteger)aFirstIndex
   numberOfCommands:(NSUInteger)count;
{
   NSParameterAssert(nil != aName);
   NSParameterAssert(nil != aMesh);
   NSParameterAssert(0 < count);
   
   if(nil != (self=[super init]))
   {
      self.mesh = aMesh;
      self.name = aName;
      self.numberOfVertices = [self calculateNumberOfVertices];
      self.indexOfFirstCommand = aFirstIndex;
      self.numberOfCommands = count;
   }
   
   return self;
}


/////////////////////////////////////////////////////////////////
//
- (id)initWithPlistRepresentation:(NSDictionary *)aDictionary
   mesh:(TEMesh *)aMesh;
{
   NSParameterAssert(nil != aMesh);
   
   NSString *aName = [aDictionary objectForKey:@"name"];
   NSNumber *aFirstIndex = 
      [aDictionary objectForKey:@"indexOfFirstCommand"];
   NSNumber *aNumberOfCommands = 
      [aDictionary objectForKey:@"numberOfCommands"];
   
   if(nil != aName && 
      nil != aFirstIndex && 
      nil != aNumberOfCommands &&
      0 < [aNumberOfCommands unsignedIntegerValue])
   {
      if(nil != (self = [self initWithName:aName
         mesh:aMesh
         indexOfFirstCommand:[aFirstIndex unsignedIntegerValue] 
         numberOfCommands:[aNumberOfCommands 
         unsignedIntegerValue]]))
      {
      }
   }
   else
   {
      [self release];
      self = nil;
   }
   
   return self;
}


/////////////////////////////////////////////////////////////////
//
- (NSDictionary *)plistRepresentation;
{
   return [NSDictionary dictionaryWithObjectsAndKeys:
      self.name, 
         @"name", 
      [NSNumber numberWithUnsignedInteger:
         self.indexOfFirstCommand], @"indexOfFirstCommand", 
      [NSNumber numberWithUnsignedInteger:
         self.numberOfCommands], @"numberOfCommands", 
      [self axisAlignedBoundingBox], 
         @"axisAlignedBoundingBox", 
      nil];
}


/////////////////////////////////////////////////////////////////
//
- (NSNumber *)calculateNumberOfVertices;
{
   NSUInteger numberOfVerticesUsed = 
      [self.mesh numberOfIndices];
   
   return [NSNumber numberWithUnsignedInteger:
      numberOfVerticesUsed];
}


/////////////////////////////////////////////////////////////////
//
- (void)draw
{
   NSRange commandsRange = {
      self.indexOfFirstCommand, self.numberOfCommands};
   
   [self.mesh drawCommandsInRange:commandsRange];
}


/////////////////////////////////////////////////////////////////
//
- (void)drawBoundingBox
{
   NSRange commandsRange = {
      self.indexOfFirstCommand, self.numberOfCommands};
   
   [self.mesh 
      drawBoundingBoxStringForCommandsInRange:commandsRange];
}


/////////////////////////////////////////////////////////////////
//
- (NSString *)axisAlignedBoundingBox;
{
   NSRange commandsRange = {
      self.indexOfFirstCommand, self.numberOfCommands};
   
   return [self.mesh 
      axisAlignedBoundingBoxStringForCommandsInRange:
         commandsRange];
}

@end
