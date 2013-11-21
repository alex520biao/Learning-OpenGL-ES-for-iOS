//
//  TEModelPlacementTool.m
//  TerrainEditor
//

#import "TEModelPlacementTool.h"
#import "TEModelPlacement.h"
#import "TEView.h"
#import "TETerrainEffect.h"
#import "TEModel.h"
#import "TETerrain+modelAdditions.h"


@interface TEModelPlacementTool ()

@property (assign, nonatomic, readwrite) NSUInteger changeCount;

@end


@implementation TEModelPlacementTool

@dynamic canPlaceSelectedModel;
@dynamic canDeleteSelectedPlacement;
@dynamic selectedPlacement;
@dynamic selectedModel;
@synthesize modelsArrayController;
@synthesize modelPlacementArrayController;
@synthesize changeCount;


//////////////////////////////////////////////////////////////////
//  
+ (NSSet *)keyPathsForValuesAffectingCanPlaceSelectedModel
{
   return [NSSet setWithObjects:
      @"modelsArrayController.selectionIndex",
      @"modelsArrayController.content",
      @"changeCount",
      nil]; 
}


//////////////////////////////////////////////////////////////////
//  
- (BOOL)canPlaceSelectedModel
{
   return (nil != self.selectedModel);
}


//////////////////////////////////////////////////////////////////
//  
+ (NSSet *)keyPathsForValuesAffectingCanDeleteSelectedPlacement
{
   return [NSSet setWithObjects:
      @"modelPlacementArrayController.selectionIndex",
      @"modelPlacementArrayController.content",
      @"changeCount",
      nil]; 
}


//////////////////////////////////////////////////////////////////
//  
- (BOOL)canDeleteSelectedPlacement
{
   return (nil != self.selectedPlacement);
}


//////////////////////////////////////////////////////////////////
//  
+ (NSSet *)keyPathsForValuesAffectingSelectedPlacement
{
   return [NSSet setWithObjects:
      @"modelPlacementArrayController.selectionIndex",
      @"modelPlacementArrayController.content",
      nil]; 
}


/////////////////////////////////////////////////////////////////
//  
- (TEModelPlacement *)selectedPlacement;
{
   TEModelPlacement *result = nil;
   
   NSUInteger index = 
      self.modelPlacementArrayController.selectionIndex;
   
   if(NSNotFound != index)
   {
      result = 
         [self.modelPlacementArrayController.arrangedObjects
         objectAtIndex:index];
   }
   
   return result;
}


//////////////////////////////////////////////////////////////////
//  
+ (NSSet *)keyPathsForValuesAffectingSelectedModel
{
   return [NSSet setWithObjects:
      @"modelsArrayController.selectionIndex",
      @"modelsArrayController.content",
      nil]; 
}


/////////////////////////////////////////////////////////////////
//  
- (TEModel *)selectedModel;
{
   TEModel *result = nil;
   
   NSUInteger index = 
      self.modelsArrayController.selectionIndex;
   
   if(NSNotFound != index)
   {
      result = 
         [self.modelsArrayController.arrangedObjects
         objectAtIndex:index];
   }
   
   return result;
}


/////////////////////////////////////////////////////////////////
//  
- (void)update
{
   TEView *view = self.owner;
   
   view.terrainEffect.toolTextureRadius = 1.5f;
}


/////////////////////////////////////////////////////////////////
//  
- (void)mouseDown:(NSEvent *)theEvent;
{
   self.changeCount++;
}


/////////////////////////////////////////////////////////////////
//  
- (IBAction)placeModel:(id)sender;
{
   NSAssert(nil != self.selectedModel,
      @"No selected model to place");
      
   UtilityVector2 toolLocation = 
      ((TEView *)self.owner).terrainEffect.toolLocation;
   GLfloat height = [[[(TEView *)self.owner dataSource] terrain]
      calculatedHeightAtXPos:toolLocation.x zPos:toolLocation.y];
      
   TEModelPlacement *newPlacement = 
      (TEModelPlacement *)[NSEntityDescription
      insertNewObjectForEntityForName:@"ModelPlacement"
      inManagedObjectContext:
         [(id <TEViewDataSourceProtocol>)[self.owner dataSource] 
         managedObjectContext]];
         
   newPlacement.modelName = self.selectedModel.name;
   newPlacement.terrain = 
      [[(TEView *)self.owner dataSource] terrain];
   newPlacement.positionX = 
      [NSNumber numberWithFloat:toolLocation.x];
   newPlacement.positionY = 
      [NSNumber numberWithFloat:height];
   newPlacement.positionZ = 
      [NSNumber numberWithFloat:toolLocation.y];
   newPlacement.angle = 
      [NSNumber numberWithFloat:0.0f];
      
   [self.modelPlacementArrayController setSelectedObjects:
      [NSArray arrayWithObject:newPlacement]];
      
   self.changeCount++;
}


/////////////////////////////////////////////////////////////////
//  
- (IBAction)deleteSelectedModelPlacements:(id)sender;
{
   NSAssert(nil != self.selectedPlacement,
      @"No selected placement to delete");
      
   [[(id <TEViewDataSourceProtocol>)[self.owner dataSource] 
      managedObjectContext] 
      deleteObject:self.selectedPlacement];
      
   self.changeCount++;
}


/////////////////////////////////////////////////////////////////
//  
- (IBAction)noteModelSelectionChange:(id)sender;
{
   self.changeCount++;
}

@end
