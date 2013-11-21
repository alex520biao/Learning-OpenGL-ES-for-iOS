//
//  UtilityBillboardManager.m
//
//

#import "UtilityBillboardManager.h"
#import "UtilityBillboard.h"


@interface UtilityBillboardManager ()

@property (strong, nonatomic, readwrite) 
   NSMutableArray *mutableSortedBillboards;

@end


@implementation UtilityBillboardManager

@synthesize mutableSortedBillboards = mutableSortedBillboards_;
@synthesize shouldRenderSpherical = shouldRenderSpherical_;


/////////////////////////////////////////////////////////////////
// Designated initializer
- (id)init
{
   if(nil != (self = [super init]))
   {
      mutableSortedBillboards_ = [NSMutableArray array];
      shouldRenderSpherical_ = YES;
   }
   
   return self;
}


/////////////////////////////////////////////////////////////////
//  
- (void)updateWithEyePosition:(GLKVector3)eyePosition 
   lookDirection:(GLKVector3)lookDirection;
{  
   // Make sure lookDirection is a unit vector
   lookDirection = GLKVector3Normalize(lookDirection);
   
   for(UtilityBillboard *currentBillboard in 
      self.sortedBillboards)
   {
      [currentBillboard updateWithEyePosition:eyePosition 
         lookDirection:lookDirection];
   }

   // Sort from furthest to nearest with dead particles and
   // particles behind the viewer ordered before all others.
   // Note: dead particles are available for reuse.
   [self.mutableSortedBillboards 
      sortUsingFunction:UtilityCompareBillboardDistance
      context:NULL];
}


/////////////////////////////////////////////////////////////////
// Accessor
- (NSArray *)sortedBillboards
{
   return self.mutableSortedBillboards;
}


/////////////////////////////////////////////////////////////////
// The maximum number of particles allow in the simulation at 
// one time.
static const NSInteger UtilityMaximumNumberOfBillboards =
   (4000);
   
/////////////////////////////////////////////////////////////////
// Adds aBillboard to the end of the billboards array.
- (void)addBillboard:(UtilityBillboard *)aBillboard;
{
   const NSInteger count = self.mutableSortedBillboards.count;
   
   if(UtilityMaximumNumberOfBillboards > count)
   {
      [self.mutableSortedBillboards addObject:aBillboard];
   }
   else
   {
      NSLog(@"Attempt to add too many billboards");
   }
}


/////////////////////////////////////////////////////////////////
//  
- (void)addBillboardAtPosition:(GLKVector3)aPosition
   size:(GLKVector2)aSize
   minTextureCoords:(GLKVector2)minCoords
   maxTextureCoords:(GLKVector2)maxCoords;
{
   UtilityBillboard *newBillboard = 
      [[UtilityBillboard alloc]
         initWithPosition:aPosition
         size:aSize
         minTextureCoords:minCoords
         maxTextureCoords:maxCoords];
   
   [self addBillboard:newBillboard];
}

@end
