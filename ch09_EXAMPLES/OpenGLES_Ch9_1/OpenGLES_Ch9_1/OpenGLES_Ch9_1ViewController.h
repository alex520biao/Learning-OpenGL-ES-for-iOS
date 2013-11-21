//
//  OpenGLES_Ch9_1ViewController.h
//  OpenGLES_Ch9_1
//

#import <GLKit/GLKit.h>

@interface OpenGLES_Ch9_1ViewController : GLKViewController
   <UIAccelerometerDelegate>

@property (strong, nonatomic) IBOutlet UILabel *fpsField;

- (IBAction)takeShouldCullFrom:(UISwitch *)sender;

@end
