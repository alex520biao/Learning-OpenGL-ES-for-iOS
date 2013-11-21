//
//  UtilityBillboardParticleManager.m
//
//

#import "UtilityBillboardParticleManager.h"
#import "UtilityBillboardParticleEffect.h"
#import "UtilityBillboardParticle.h"
#import "UtilityCamera.h"


/////////////////////////////////////////////////////////////////
// Vertex attributes used in UtilityBillboardParticleShader
typedef struct
{
  GLKVector3 position;
  GLKVector2 textureCoords;
  GLfloat opacity;
}
BillboardVertex;


@interface UtilityBillboardParticleManager ()

@property (strong, nonatomic, readwrite) 
   NSMutableArray *mutableSortedParticles;

@end


@implementation UtilityBillboardParticleManager

@synthesize mutableSortedParticles = mutableSortedParticles_;
@synthesize shouldRenderSpherical = shouldRenderSpherical_;


/////////////////////////////////////////////////////////////////
// Designated initializer
- (id)init
{
   if(nil != (self = [super init]))
   {
      mutableSortedParticles_ = [NSMutableArray array];
      shouldRenderSpherical_ = YES;
   }
   
   return self;
}


/////////////////////////////////////////////////////////////////
//  
- (void)updateWithElapsedTime:(NSTimeInterval)someSeconds
   frustum:(const AGLKFrustum *)frustumPtr;
{
   for(UtilityBillboardParticle *currentBillboard in 
      self.sortedParticles)
   {
      [currentBillboard updateWithElapsedTime:someSeconds
         frustum:frustumPtr];
   }

   // Sort from furthest to nearest with dead particles and
   // particles behind the viewer ordered before all others.
   // Note: dead particles are available for reuse.
   [self.mutableSortedParticles 
      sortUsingFunction:AGLKCompareBillboardParticleDistance
      context:NULL];
}


/////////////////////////////////////////////////////////////////
// Accessor
- (NSArray *)sortedParticles
{
   return self.mutableSortedParticles;
}


/////////////////////////////////////////////////////////////////
// The maximum number of particles allow in the simulation at 
// one time.
static const NSInteger UtilityMaximumNumberOfParticles =
   (4000);
   
/////////////////////////////////////////////////////////////////
// Adds aParticle to the end of the particles array. If a
// dead bilboard is available, then one dead billboard is also
// removed so the total number of particles does not increase.
- (void)addParticle:(UtilityBillboardParticle *)aParticle;
{
   const NSInteger count = self.sortedParticles.count;
   
   if(0 < count && 
      ![[self.mutableSortedParticles objectAtIndex:0] isAlive])
   {
      [self.mutableSortedParticles removeObjectAtIndex:0];
      [self.mutableSortedParticles addObject:aParticle];
   }
   else if(UtilityMaximumNumberOfParticles> 
      self.mutableSortedParticles.count)
   {
      [self.mutableSortedParticles addObject:aParticle];
   }
   else
   {
      NSLog(@"Attempt to add too many particles");
   }
}


/////////////////////////////////////////////////////////////////
//  
- (void)addParticleAtPosition:(GLKVector3)aPosition
   velocity:(GLKVector3)aVelocity
   force:(GLKVector3)aForce
   initialSize:(GLKVector2)anInitialSize
   finalSize:(GLKVector2)aFinalSize
   lifeSpanSeconds:(NSTimeInterval)aSpan
   fadeDurationSeconds:(NSTimeInterval)aDuration
   minTextureCoords:(GLKVector2)minCoords
   maxTextureCoords:(GLKVector2)maxCoords;
{
   UtilityBillboardParticle *newBillboard = 
      [[UtilityBillboardParticle alloc]
         initWithPosition:aPosition
         velocity:aVelocity
         force:aForce
         initialSize:anInitialSize
         finalSize:aFinalSize
         lifeSpanSeconds:aSpan
         fadeDurationSeconds:aDuration
         minTextureCoords:minCoords
         maxTextureCoords:maxCoords];
   
   [self addParticle:newBillboard];
}

@end
