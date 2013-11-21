//
//  OpenGLES_Ch5_4ViewController.h
//  OpenGLES_Ch5_4
//

#import <GLKit/GLKit.h>

@class AGLKVertexAttribArrayBuffer;


/////////////////////////////////////////////////////////////////
// Constants identify user selected transformations
typedef enum
{
	SceneTranslate = 0,
	SceneRotate,
	SceneScale,
} SceneTransformationSelector;


/////////////////////////////////////////////////////////////////
// Constants identify user selected axis for transformation
typedef enum
{
	SceneXAxis = 0,
	SceneYAxis,
	SceneZAxis,
} SceneTransformationAxisSelector;


@interface OpenGLES_Ch5_4ViewController : GLKViewController
{
   SceneTransformationSelector      transform1Type;
   SceneTransformationAxisSelector  transform1Axis;
   float                            transform1Value;
   SceneTransformationSelector      transform2Type;
   SceneTransformationAxisSelector  transform2Axis;
   float                            transform2Value;
   SceneTransformationSelector      transform3Type;
   SceneTransformationAxisSelector  transform3Axis;
   float                            transform3Value;
}


@property (strong, nonatomic) GLKBaseEffect 
   *baseEffect;
@property (strong, nonatomic) AGLKVertexAttribArrayBuffer 
   *vertexPositionBuffer;
@property (strong, nonatomic) AGLKVertexAttribArrayBuffer 
   *vertexNormalBuffer;
@property (strong, nonatomic) IBOutlet UISlider 
   *transform1ValueSlider;
@property (strong, nonatomic) IBOutlet UISlider 
   *transform2ValueSlider;
@property (strong, nonatomic) IBOutlet UISlider 
   *transform3ValueSlider;

// Methods called from user interface objects configured
// in Interface Builder
- (IBAction)resetIdentity:(id)dummy;

- (IBAction)takeTransform1TypeFrom:
   (UISegmentedControl *)aControl;
   
- (IBAction)takeTransform2TypeFrom:
   (UISegmentedControl *)aControl;
   
- (IBAction)takeTransform3TypeFrom:
   (UISegmentedControl *)aControl;
   
- (IBAction)takeTransform1AxisFrom:
   (UISegmentedControl *)aControl;
   
- (IBAction)takeTransform2AxisFrom:
   (UISegmentedControl *)aControl;
   
- (IBAction)takeTransform3AxisFrom:
   (UISegmentedControl *)aControl;
   
- (IBAction)takeTransform1ValueFrom:
   (UISlider *)aControl;
   
- (IBAction)takeTransform2ValueFrom:
   (UISlider *)aControl;
   
- (IBAction)takeTransform3ValueFrom:
   (UISlider *)aControl;

@end

