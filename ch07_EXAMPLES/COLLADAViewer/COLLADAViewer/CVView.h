//
//  CVView.h
//  COLLADAViewer
//

#import <Cocoa/Cocoa.h>

@class UtilityOpenGLCamera;
@class UtilityTextureInfo;
@class CVMesh;


@protocol CVViewDataSourceProtocol <NSObject>

- (NSArray *)allModels;
- (NSIndexSet *)selectedModels;
- (CVMesh *)consolidatedMesh;
- (UtilityTextureInfo *)textureInfo;
- (BOOL)shouldShowNormals;
- (BOOL)shouldRotateModel;
- (BOOL)shouldShowNegativeZAxis;

@end


@interface CVView : NSOpenGLView

@property (nonatomic, readwrite, strong) IBOutlet id <CVViewDataSourceProtocol> 
   dataSource;
@property (nonatomic, assign, readonly) BOOL 
   isAnimating;
@property (nonatomic, retain, readonly) UtilityOpenGLCamera 
   *camera;
@property (assign, nonatomic, readwrite) GLfloat 
   normalLineLengthForDisplay;

- (IBAction)startAnimating:(id)sender;
- (IBAction)stopAnimating:(id)sender;

@end
