//
//  TEModelManager.m
//  TerrainEditor
//

#import "TEModelManager.h"
#import "TEMesh.h"
#import "TEModel.h"


@interface TEModelManager ()

@property (strong, nonatomic, readwrite) UtilityTextureInfo 
   *textureInfo;
@property (strong, nonatomic, readwrite) TEMesh 
   *consolidatedMesh;
@property (strong, nonatomic, readwrite) NSDictionary 
   *modelsDictionary;

- (NSDictionary *)modelsFromPlistRepresentation:
   (NSDictionary *)plist
   mesh:(TEMesh *)aMesh;

- (BOOL)readFromData:(NSData *)data 
   ofType:(NSString *)typeName 
   error:(NSError **)outError;

@end


@implementation TEModelManager

@synthesize textureInfo;
@synthesize consolidatedMesh;
@synthesize modelsDictionary;


/////////////////////////////////////////////////////////////////
// Designated initializer
- (id)init;
{
   if(nil != (self=[super init]))
   {
   }
   
   return self;
}


/////////////////////////////////////////////////////////////////
// This method returns a dictionary of TEModel instances
// keyed by name and initialized from plist.
- (NSDictionary *)modelsFromPlistRepresentation:
   (NSDictionary *)plist
   mesh:(TEMesh *)aMesh
{
   NSMutableDictionary *result = [NSMutableDictionary dictionary];
   
   for(NSDictionary *modelDictionary in plist.allValues)
   {
      TEModel *newModel = [[[TEModel alloc] 
         initWithPlistRepresentation:modelDictionary mesh:aMesh]
         autorelease];
         
      [result setObject:newModel forKey:newModel.name];
   }
   
   return result;
}


/////////////////////////////////////////////////////////////////
// This method initializes the texture, mesh, and models loaded
// from a plist archived in data.
- (BOOL)readFromData:(NSData *)data 
   ofType:(NSString *)typeName 
   error:(NSError **)outError
{
   NSDictionary *documentDictionary = 
      [NSKeyedUnarchiver unarchiveObjectWithData:data];
   
   self.textureInfo = 
      [[[UtilityTextureInfo alloc] 
      initWithPlistRepresentation:[documentDictionary 
      objectForKey:TEModelManagerTextureImageInfo]]
      autorelease];
      
   self.consolidatedMesh =  [[[TEMesh alloc] 
      initWithPlistRepresentation:[documentDictionary 
      objectForKey:TEModelManagerMesh]] autorelease];
           
   self.modelsDictionary = 
      [self modelsFromPlistRepresentation:[documentDictionary 
      objectForKey:TEModelManagerModels]
      mesh:self.consolidatedMesh]; 

   return YES;
}


/////////////////////////////////////////////////////////////////
// Returns the model with aName or nil if no such model is found.
- (TEModel *)modelNamed:(NSString *)aName;
{
   return [self.modelsDictionary objectForKey:aName];
}


/////////////////////////////////////////////////////////////////
// 
- (void)prepareToDraw;
{
   [self.consolidatedMesh prepareToDraw];
}


/////////////////////////////////////////////////////////////////
// 
- (void)prepareToPick;
{
   [self.consolidatedMesh prepareToPick];
}


/////////////////////////////////////////////////////////////////
//
- (NSDictionary *)allModelsPlistRepresentation;
{
   NSMutableDictionary *result = [NSMutableDictionary dictionary];
   
   for(TEModel *model in self.modelsDictionary.allValues)
   {
      NSString *uniqueName = model.name;
      int counter = 1;
      
      while(nil != [result objectForKey:uniqueName])
      {  // Model with name already exists in dictionary
         uniqueName = [model.name stringByAppendingFormat:@"%d",
               counter];

         counter++;
      }
      
      model.name = uniqueName;
      NSAssert(nil == [result objectForKey:model.name],
         @"Duplicate model names");

      [result setObject:model.plistRepresentation 
         forKey:model.name];
   }
   
   return result;
}


/////////////////////////////////////////////////////////////////
//
- (NSData *)modelsDataOfType:(NSString *)typeName 
   error:(NSError **)outError
{
   NSDictionary *textureInfoPlistForArchive = 
      self.textureInfo.plistRepresentation;
      
   if(nil == textureInfoPlistForArchive)
   {  // Can't write nil to dictionary so make sure texture
      // info plist is never nil
      textureInfoPlistForArchive = [NSDictionary dictionary];
   }
   
   NSAssert(nil != self.allModelsPlistRepresentation, 
      @"Invalid modles plist");
   NSAssert(nil != self.consolidatedMesh.plistRepresentation, 
      @"Invalid mesh plist");
      
   return [NSKeyedArchiver archivedDataWithRootObject:
      [NSDictionary dictionaryWithObjectsAndKeys:
         textureInfoPlistForArchive, @"textureImageInfo", 
         self.allModelsPlistRepresentation, @"models", 
         self.consolidatedMesh.plistRepresentation, @"mesh", 
         nil]];
}

@end

/////////////////////////////////////////////////////////////////
// Constants used to access model properties from a plist
// dictionary.
NSString *const TEModelManagerTextureImageInfo =
   @"textureImageInfo";
NSString *const TEModelManagerMesh =
   @"mesh";
NSString *const TEModelManagerModels =
   @"models";
