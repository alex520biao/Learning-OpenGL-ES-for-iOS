//
//  TEEditWindowController.m
//  TerrainEditor
//

#import "TEEditWindowController.h"
#import "TEView.h"
#import "TETerrain+modelAdditions.h"
#import "TEModelManager.h"
#import "TEDocument.h"
#import "TETool.h"


@interface TEEditWindowController ()

@property (strong, nonatomic, readwrite) NSArray *allModels;

@end


@implementation TEEditWindowController

@dynamic terrain;
@dynamic managedObjectContext;
@synthesize allModels;
@synthesize terrainView;
@synthesize modelManager;
@synthesize supportViewArea;
@synthesize currentTool;
@synthesize defaultTool;


//////////////////////////////////////////////////////////////////
//  
- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if(self) 
    {
        // Initialization code here.
    }
    
    return self;
}


//////////////////////////////////////////////////////////////////
//  
- (void)windowDidLoad
{
   [super windowDidLoad];
   
   [self setCurrentTool:self.defaultTool];
}


//////////////////////////////////////////////////////////////////
//  
- (void)windowWillClose:(NSNotification *)notification
{
   [self.terrainView stopAnimating:nil];
}


//////////////////////////////////////////////////////////////////
//  
- (NSManagedObjectContext *)managedObjectContext
{
   return [[self document] managedObjectContext];
}


//////////////////////////////////////////////////////////////////
//  
- (TETerrain *)terrain;
{
   return [[self document] terrain];
}


//////////////////////////////////////////////////////////////////
//  
+ (NSSet *)keyPathsForValuesAffectingAllModels
{
   return [NSSet setWithObjects:
      @"modelManager",
      nil]; 
}


//////////////////////////////////////////////////////////////////
//  
+ (NSSet *)keyPathsForValuesAffectingModelManager
{
   return [NSSet setWithObjects:
      @"terrain.modelsData",
      nil]; 
}


//////////////////////////////////////////////////////////////////
//  
- (TEModelManager *)modelManager
{
   if(modelManager == nil &&
      nil != self.terrain.modelsData)
   {
      modelManager = [[TEModelManager alloc] init];
      [modelManager readFromData:self.terrain.modelsData 
         ofType:nil 
         error:NULL];
      self.allModels = [modelManager.modelsDictionary allValues];
   }
      
   return modelManager;
}


//////////////////////////////////////////////////////////////////
//  
+ (NSSet *)keyPathsForValuesAffectingDetailTexture0Image
{
   return [NSSet setWithObject:@"terrain.detailTextureInfo0"]; 
}


//////////////////////////////////////////////////////////////////
//  
- (NSImage *)detailTexture0Image;
{
   return [self.terrain.detailTextureInfo0 image];
}


//////////////////////////////////////////////////////////////////
//  
- (void)setDetailTexture0Image:(NSImage *)anImage;
{
   UtilityTextureInfo *textureInfo = [UtilityTextureLoader
      textureWithCGImage:[anImage
         CGImageForProposedRect:NULL context:nil hints:nil]                                                        
      options:nil 
      error:NULL];
   self.terrain.detailTextureInfo0 = textureInfo;
}


//////////////////////////////////////////////////////////////////
//  
+ (NSSet *)keyPathsForValuesAffectingDetailTexture1Image
{
   return [NSSet setWithObject:@"terrain.detailTextureInfo1"]; 
}


//////////////////////////////////////////////////////////////////
//  
- (NSImage *)detailTexture1Image;
{
   return [self.terrain.detailTextureInfo1 image];
}


//////////////////////////////////////////////////////////////////
//  
- (void)setDetailTexture1Image:(NSImage *)anImage;
{
   UtilityTextureInfo *textureInfo = [UtilityTextureLoader
      textureWithCGImage:[anImage
         CGImageForProposedRect:NULL context:nil hints:nil]                                                        
      options:nil 
      error:NULL];
   self.terrain.detailTextureInfo1 = textureInfo;
}


//////////////////////////////////////////////////////////////////
//  
+ (NSSet *)keyPathsForValuesAffectingDetailTexture2Image
{
   return [NSSet setWithObject:@"terrain.detailTextureInfo2"]; 
}


//////////////////////////////////////////////////////////////////
//  
- (NSImage *)detailTexture2Image;
{
   return [self.terrain.detailTextureInfo2 image];
}


//////////////////////////////////////////////////////////////////
//  
- (void)setDetailTexture2Image:(NSImage *)anImage;
{
   UtilityTextureInfo *textureInfo = [UtilityTextureLoader
      textureWithCGImage:[anImage
         CGImageForProposedRect:NULL context:nil hints:nil]                                                        
      options:nil 
      error:NULL];
   self.terrain.detailTextureInfo2 = textureInfo;
}


//////////////////////////////////////////////////////////////////
//  
+ (NSSet *)keyPathsForValuesAffectingDetailTexture3Image
{
   return [NSSet setWithObject:@"terrain.detailTextureInfo3"]; 
}


//////////////////////////////////////////////////////////////////
//  
- (NSImage *)detailTexture3Image;
{
   return [self.terrain.detailTextureInfo3 image];
}


//////////////////////////////////////////////////////////////////
//  
- (void)setDetailTexture3Image:(NSImage *)anImage;
{
   UtilityTextureInfo *textureInfo = [UtilityTextureLoader
      textureWithCGImage:[anImage
         CGImageForProposedRect:NULL context:nil hints:nil]                                                        
      options:nil 
      error:NULL];
   self.terrain.detailTextureInfo3 = textureInfo;
}


//////////////////////////////////////////////////////////////////
//  
- (void)setCurrentTool:(id)anObject
{
   [self.currentTool resignActive];
   [self.currentTool.supportView removeFromSuperview];
   
   [anObject retain];
   [currentTool release];
   currentTool = anObject;
   
   [self.supportViewArea 
      addSubview:self.currentTool.supportView];
   [self.currentTool.supportView 
      setFrame:[self.supportViewArea bounds]];
   [self.currentTool becomeActive];
}


//////////////////////////////////////////////////////////////////
//  
- (IBAction)takeSelectedToolFrom:(id)sender;
{
   TETool *selectedTool = nil;
   
   if([sender respondsToSelector:@selector(representedObject)])
   {
      selectedTool = [sender representedObject];
   }
   else if([sender respondsToSelector:@selector(selectedCell)])
   {
      selectedTool = [[sender selectedCell] representedObject];
   }
   
   if(self.currentTool != selectedTool)
   {
      self.currentTool = selectedTool;
   }
}

@end
