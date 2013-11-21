//
//  COLLADAParser.h
//  COLLADAViewer
//

#import <Foundation/Foundation.h>
#import "COLLADARootNode.h"
#import "UtilityMatrix.h"


@interface COLLADAParser : NSObject <NSXMLParserDelegate>

@property (retain, nonatomic, readonly) COLLADARootNode 
   *rootNode;

- (void)parseCOLLADAFileAtPath:(NSString *)filePath;
 
@end
