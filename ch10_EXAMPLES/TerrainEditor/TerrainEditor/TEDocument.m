//
//  TEDocument.m
//  TerrainEditor
//

#import "TEDocument.h"
#import "TEEditWindowController.h"
#import "TETerrain+modelAdditions.h"
#import "TEHeightMap.h"
#import "TEModelManager.h"
#import "TEModel.h"
#import "UtilityTextureLoader.h"


@interface TEDocument ()

@property (strong, nonatomic, readwrite) TETerrain *terrain;

@end


@implementation TEDocument

@synthesize terrain;


//////////////////////////////////////////////////////////////////
//  
- (NSString *)windowNibName
{
   // Override returning the nib file name of the document
   // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
   return @"TEDocument";
}


//////////////////////////////////////////////////////////////////
//  
const UtilityVector3 TEDefaultTerrainLightDirection =
   {100.0f, 35.0f, 30.0f};
const GLfloat TEMetersPerUnit = (10.0f);
const GLfloat TEHeightScaleFactor = (35.0f);
   
//////////////////////////////////////////////////////////////////
//  
- (void)setupDefaultTerrain
{
   NSUndoManager *undoManager = [self undoManager];
   [[NSNotificationCenter defaultCenter]
      postNotificationName:NSUndoManagerCheckpointNotification
      object:undoManager];
   [undoManager disableUndoRegistration];

   NSAssert(nil == self.terrain, 
      @"Invalid attempt to re-init terrain");
   self.terrain = (TETerrain *)[NSEntityDescription
      insertNewObjectForEntityForName:@"Terrain"
      inManagedObjectContext:[self managedObjectContext]];
   
   NSString *heightMapPath = 
      [[NSBundle bundleForClass:[self class]]
      pathForResource:@"heightMap" ofType:@"tga"];
   NSAssert(nil != heightMapPath, 
      @"Unable to load height map");

   // Use default height map
   TEHeightMap *heightMap = [[[TEHeightMap alloc]
      initFromPath:heightMapPath] autorelease];

   [self.terrain 
      updateWithHeightMap:heightMap
      metersPerUnit:TEMetersPerUnit
      heightScaleFactor:TEHeightScaleFactor
      lightDirection:TEDefaultTerrainLightDirection
      inManagedObjectContext:[self managedObjectContext]];
   self.terrain.lightAndWeightsTextureInfo = [self.terrain
      defaultLightAndWeightsTextureInfo];
      
   // Configure reasonable default properties
   self.terrain.detailTextureScale0 = [NSNumber numberWithFloat:1.0f];
   self.terrain.detailTextureScale1 = [NSNumber numberWithFloat:1.0f];
   self.terrain.detailTextureScale2 = [NSNumber numberWithFloat:1.0f];
   self.terrain.detailTextureScale3 = [NSNumber numberWithFloat:1.0f];
   self.terrain.detailTextureInfo3 = [UtilityTextureLoader 
      textureWithCGImage:[[NSImage imageNamed:@"Sahara.jpg"]
         CGImageForProposedRect:NULL context:nil hints:nil] 
      options:nil 
      error:NULL];
   
   [[NSNotificationCenter defaultCenter]
      postNotificationName:NSUndoManagerCheckpointNotification
      object:undoManager];
   [undoManager enableUndoRegistration];
}


/* Create the user interface for this document, but don't show it yet. The default implementation of this method invokes [self windowNibName], creates a new window controller using the resulting nib name (if it is not nil), specifying this document as the nib file's owner, and then invokes [self addWindowController:theNewWindowController] to attach it. You can override this method to use a custom subclass of NSWindowController or to create more than one window controller right away. NSDocumentController invokes this method when creating or opening new documents.
*/
- (void)makeWindowControllers;
{  
   // First, make sure there is terrain available for the
   // window controller to access 
   NSFetchRequest *request = 
      [[[NSFetchRequest alloc] init] autorelease];
   NSEntityDescription *entity =
      [NSEntityDescription entityForName:@"Terrain"
      inManagedObjectContext:[self managedObjectContext]];
   [request setEntity:entity];
   NSError *error = nil;
   NSArray *terrainArray = [[self managedObjectContext] 
      executeFetchRequest:request error:&error];
   
   if (terrainArray != nil) 
   {
       NSUInteger count = [terrainArray count]; 
       
       if(0 == count)
       {  // Create and setup a new instance
          [self setupDefaultTerrain];
       }
       else if(1 == count)
       {  // Use the existing instance
          self.terrain = [terrainArray lastObject];
       }
       else
       {  // Too many existing instances
           // Deal with error.
       }
   }
   else 
   { 
      // Deal with error.
   }

   // Create and add the window controller
   TEEditWindowController *windowController = 
      [[[TEEditWindowController alloc] 
         initWithWindowNibName:[self windowNibName]] autorelease];
   [self addWindowController:windowController];
   [windowController setShouldCloseDocument:YES];
   
   // Make sure all models touch the terrain
   [self.terrain adjustModelsToTerrain];
}


//////////////////////////////////////////////////////////////////
//  
- (IBAction)loadModels:(id)sender;
{
   NSOpenPanel *oPanel = [NSOpenPanel openPanel];

   NSArray *fileTypes = [NSArray arrayWithObject:@"modelplist"];
   
   [oPanel setMessage:NSLocalizedString(
       @"Choose Models .modelplist files to import.", 
       @"Choose Models .modelplist files to import.")];
	[oPanel setCanChooseDirectories:NO];
	[oPanel setResolvesAliases:YES];
	[oPanel setCanChooseFiles:YES];
   [oPanel setAllowsMultipleSelection:NO];
   oPanel.allowedFileTypes = fileTypes;

	void (^openPanelHandler)(NSInteger) = ^( NSInteger result )
	{
      NSData *modelsData = nil;
      NSArray *urlsToOpen = [oPanel URLs];
      
      for (NSURL *aURL in urlsToOpen) 
      {
         modelsData = [NSData dataWithContentsOfURL:aURL];
      }
      
      self.terrain.modelsData = modelsData;
	};
	
   [oPanel beginSheetModalForWindow:[self windowForSheet] 
      completionHandler:openPanelHandler];
}

@end
