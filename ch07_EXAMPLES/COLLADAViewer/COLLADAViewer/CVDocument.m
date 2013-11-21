//
//  CVDocument.m
//  COLLADAViewer
//

#import "CVDocument.h"
#import "CVView.h"
#import "COLLADAParser.h"
#import "CVMesh.h"
#import "COLLADARootNode.h"
#import "CVModel.h"
#import "UtilityTextureLoader.h"


@interface CVDocument ()

@property (retain, nonatomic, readwrite) UtilityTextureInfo 
   *textureInfo;
@property (retain, nonatomic, readwrite) CVMesh 
   *consolidatedMesh;
@property (retain, nonatomic, readwrite) NSArray 
   *allModels;
@property (assign, nonatomic, readonly) NSDictionary 
   *allModelsPlistRepresentation;

- (NSDictionary *)modelsFromPlistRepresentation:(NSArray *)plist;

@end


@implementation CVDocument

@synthesize view = view_;
@synthesize shouldShowNormals = shouldShowNormals_;
@synthesize shouldRotateModel = shouldRotateModel_;
@synthesize shouldShowNegativeZAxis = shouldShowNegativeZAxis_;
@synthesize selectedModels = selectedModels_;
@synthesize allModels = allModels_;
@synthesize consolidatedMesh = consolidatedMesh_;
@synthesize textureInfo = textureInfo_;

/////////////////////////////////////////////////////////////////
// Designated initializer
- (id)init
{
    self = [super init];
    if (self) 
    {
      self.allModels = [NSArray array];
      self.selectedModels = [NSIndexSet indexSet];
      self.consolidatedMesh = [[[CVMesh alloc] init] autorelease];     
    }
    return self;
}


/////////////////////////////////////////////////////////////////
//
- (NSString *)windowNibName
{
   return @"CVDocument";
}


/////////////////////////////////////////////////////////////////
//
- (void)windowControllerDidLoadNib:
   (NSWindowController *)aController
{
   [super windowControllerDidLoadNib:aController];
   
   self.view.dataSource = self;
   [self.view.window makeKeyAndOrderFront:nil];
   [self.view.window makeFirstResponder:self.view];
   [self.view startAnimating:self];
}


/////////////////////////////////////////////////////////////////
//
- (NSData *)dataOfType:(NSString *)typeName 
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
   //NSLog(@"%@", self.consolidatedMesh);
       
   return [NSKeyedArchiver archivedDataWithRootObject:
      [NSDictionary dictionaryWithObjectsAndKeys:
         textureInfoPlistForArchive, @"textureImageInfo", 
         self.allModelsPlistRepresentation, @"models", 
         self.consolidatedMesh.plistRepresentation, @"mesh", 
         nil]];
}


/////////////////////////////////////////////////////////////////
//
- (BOOL)readFromData:(NSData *)data 
   ofType:(NSString *)typeName 
   error:(NSError **)outError
{
   NSDictionary *documentDictionary = 
      [NSKeyedUnarchiver unarchiveObjectWithData:data];
      
   self.textureInfo = 
      [[[UtilityTextureInfo alloc] 
      initWithPlistRepresentation:[documentDictionary 
      objectForKey:@"textureImageInfo"]] autorelease];
      
   // Mesh must be set before models
   self.consolidatedMesh =  [[[CVMesh alloc] 
      initWithPlistRepresentation:[documentDictionary 
      objectForKey:@"mesh"]] autorelease];     
      
   self.allModels = 
      [[self modelsFromPlistRepresentation:[documentDictionary 
      objectForKey:@"models"]] allValues]; 

   return YES;
}


/////////////////////////////////////////////////////////////////
//
- (void)appendModelParsedFromCOLLADAFileAtPath:(NSString *)aPath
{
   COLLADAParser *coladaParser = 
      [[COLLADAParser alloc] init];
      
   [coladaParser parseCOLLADAFileAtPath:aPath];
   
   NSString *name = 
      [[aPath lastPathComponent] 
      stringByDeletingPathExtension];
   
   // Get next available command Index before appending meshes
   NSUInteger nextAvailableCommandIndex = 
      [self.consolidatedMesh.commands count];
   
   // Append root node's meshes to consolidatedMesh
   [coladaParser.rootNode 
      appendMeshesToMesh:self.consolidatedMesh
      cumulativeTransforms:UtilityMatrix4Identity];

   NSUInteger newCountCommandIndices = 
      [self.consolidatedMesh.commands count];

   self.allModels = [self.allModels arrayByAddingObject:
      [[[CVModel alloc]
         initWithName:name 
         mesh:self.consolidatedMesh
         indexOfFirstCommand:nextAvailableCommandIndex
         numberOfCommands:(newCountCommandIndices - 
            nextAvailableCommandIndex)]
      autorelease]];
   
   [self updateChangeCount:NSChangeReadOtherContents];
   
   // Use added model's texture if it has one
   if(nil != coladaParser.rootNode.textureInfo)
   {
     self.textureInfo = 
        coladaParser.rootNode.textureInfo;
   }
   
   [coladaParser release];
   coladaParser = nil;
}


/////////////////////////////////////////////////////////////////
//
- (IBAction)importCOLLADA:(id)sender
{
   NSOpenPanel *oPanel = [NSOpenPanel openPanel];

   NSArray *fileTypes = [NSArray arrayWithObject:@"dae"];
   
   [oPanel setMessage:NSLocalizedString(
       @"Choose COLLADA .dae files to import.", 
       @"Choose COLLADA .dae files to import.")];
	[oPanel setCanChooseDirectories:NO];
	[oPanel setResolvesAliases:YES];
	[oPanel setCanChooseFiles:YES];
   [oPanel setAllowsMultipleSelection:YES];
   oPanel.allowedFileTypes = fileTypes;

	void (^openPanelHandler)(NSInteger) = ^( NSInteger result )
	{
      NSArray *urlsToOpen = [oPanel URLs];
      const NSUInteger startNumModels = [self.allModels count];   
      
      for (NSURL *aUrl in urlsToOpen)
      {
         [self appendModelParsedFromCOLLADAFileAtPath:[aUrl path]];
      }
      
      // Select all newly added models
      const NSUInteger numModels = [self.allModels count];   
      NSRange selectionRange = 
         {startNumModels, numModels - startNumModels};
      self.selectedModels = 
         [NSIndexSet indexSetWithIndexesInRange:selectionRange];
	};
	
   [oPanel beginSheetModalForWindow:[self windowForSheet] 
      completionHandler:openPanelHandler];
}


/////////////////////////////////////////////////////////////////
//
+ (NSSet *)keyPathsForValuesAffectingNumberOfVertexPositions
{
   return [NSSet setWithObject:@"consolidatedMesh.vertexData"];
}


/////////////////////////////////////////////////////////////////
//
- (NSInteger)numberOfVertexPositions
{
   return (self.consolidatedMesh.vertexData.length /
      sizeof(CVMeshVertex) );
}


/////////////////////////////////////////////////////////////////
//
- (IBAction)removeDuplicateVertices:(id)sender;
{
   // Not yet implemented
}


/////////////////////////////////////////////////////////////////
//
- (NSDictionary *)textureImageInfoForRootNode:
   (COLLADARootNode *)rootNode
{
   id imageData = [NSNull null];
   NSNumber *width = [NSNumber numberWithUnsignedInteger:0];
   NSNumber *height = [NSNumber numberWithUnsignedInteger:0];
   
   if(nil != rootNode)
   {
      width = [NSNumber numberWithUnsignedInteger:
         rootNode.textureInfo.width];
      height = [NSNumber numberWithUnsignedInteger:
         rootNode.textureInfo.height];
         
      if(nil != rootNode.textureInfo.imageData)
      {
         imageData = rootNode.textureInfo.imageData;
      }
   }
   
   return [NSDictionary dictionaryWithObjectsAndKeys:
      @"imageData", imageData, 
      @"imageWidth", width,
      @"imageHeight", height,
      nil];
}


/////////////////////////////////////////////////////////////////
//
- (NSDictionary *)allModelsPlistRepresentation;
{
   NSMutableDictionary *result = [NSMutableDictionary dictionary];
   
   for(CVModel *model in self.allModels)
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
- (NSDictionary *)modelsFromPlistRepresentation:
  (NSDictionary *)plist
{
   NSMutableDictionary *result = [NSMutableDictionary dictionary];
   
   for(NSDictionary *modelDictionary in plist.allValues)
   {
      CVModel *newModel = [[[CVModel alloc] 
         initWithPlistRepresentation:modelDictionary
         mesh:self.consolidatedMesh] autorelease];
      
      if(nil !=  newModel && nil != newModel.name)
      {
         [result setObject:newModel forKey:newModel.name];
      }
      else
      {
         NSLog(@"Unable to load model: %@", modelDictionary);
      }
   }
   
   return result;
}

@end
