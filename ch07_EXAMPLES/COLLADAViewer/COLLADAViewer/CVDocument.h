//
//  CVDocument.h
//  COLLADAViewer
//

#import <Cocoa/Cocoa.h>
#import "CVView.h"

@class CVMesh;
@class UtilityTextureInfo;


@interface CVDocument : NSDocument  <CVViewDataSourceProtocol>

@property (retain, nonatomic, readwrite) IBOutlet CVView 
   *view;
@property (nonatomic, assign, readwrite) BOOL 
   shouldShowNormals;
@property (nonatomic, assign, readwrite) BOOL 
   shouldRotateModel;
@property (nonatomic, assign, readwrite) BOOL 
   shouldShowNegativeZAxis;
@property (retain, nonatomic, readonly) NSArray 
   *allModels;
@property (retain, nonatomic, readwrite) NSIndexSet 
   *selectedModels;
@property (assign, nonatomic, readonly) NSInteger 
   numberOfVertexPositions;


- (IBAction)importCOLLADA:(id)sender;
- (IBAction)removeDuplicateVertices:(id)sender;

@end
