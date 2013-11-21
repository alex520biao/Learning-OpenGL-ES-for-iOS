//
//  UtilityModelManager.m
//  
//

#import "UtilityModelManager.h"
#import "UtilityModel+viewAdditions.h"
#import "UtilityMesh+viewAdditions.h"
#import "UtilityTextureInfo+viewAdditions.h"


@interface UtilityModelManager ()

@property (strong, nonatomic, readwrite) GLKTextureInfo 
   *textureInfo;
@property (strong, nonatomic, readwrite) UtilityMesh 
   *consolidatedMesh;
@property (strong, nonatomic, readwrite) NSDictionary 
   *modelsDictionary;

- (NSDictionary *)modelsFromPlistRepresentation:
   (NSDictionary *)plist
   mesh:(UtilityMesh *)aMesh;

- (BOOL)readFromData:(NSData *)data 
   ofType:(NSString *)typeName 
   error:(NSError **)outError;

@end


@implementation UtilityModelManager

@synthesize textureInfo = textureInfo_;
@synthesize consolidatedMesh = consolidatedMesh_;
@synthesize modelsDictionary = modelsDictionary_;


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
// 
- (id)initWithModelPath:(NSString *)aPath;
{
   if(nil != (self=[self init]))
   {
      NSError *modelLoadingError = nil;
      
      NSData *data = [NSData dataWithContentsOfFile:aPath 
         options:0 
         error:&modelLoadingError];
         
      if(nil != data)
      {
         [self readFromData:data
            ofType:[aPath pathExtension]
            error:&modelLoadingError];
      }
   }
   
   return self;
}


/////////////////////////////////////////////////////////////////
// This method returns a dictionary of UtilityModel instances
// keyed by name and initialized from plist.
- (NSDictionary *)modelsFromPlistRepresentation:
   (NSDictionary *)plist
   mesh:(UtilityMesh *)aMesh
{
   NSMutableDictionary *result = [NSMutableDictionary dictionary];
   
   for(NSDictionary *modelDictionary in plist.allValues)
   {
      UtilityModel *newModel = [[UtilityModel alloc] 
         initWithPlistRepresentation:modelDictionary mesh:aMesh];
         
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
   
   self.textureInfo = [GLKTextureInfo 
      textureInfoFromUtilityPlistRepresentation:
         [documentDictionary objectForKey:
         UtilityModelManagerTextureImageInfo]];
      
   self.consolidatedMesh = [[UtilityMesh alloc] 
      initWithPlistRepresentation:[documentDictionary 
      objectForKey:UtilityModelManagerMesh]];
           
   self.modelsDictionary = 
      [self modelsFromPlistRepresentation:[documentDictionary 
      objectForKey:UtilityModelManagerModels]
      mesh:self.consolidatedMesh]; 

   return YES;
}


/////////////////////////////////////////////////////////////////
// Returns the model with aName or nil if no such model is found.
- (UtilityModel *)modelNamed:(NSString *)aName;
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

@end

/////////////////////////////////////////////////////////////////
// Constants used to access model properties from a plist
// dictionary.
NSString *const UtilityModelManagerTextureImageInfo =
   @"textureImageInfo";
NSString *const UtilityModelManagerMesh =
   @"mesh";
NSString *const UtilityModelManagerModels =
   @"models";
