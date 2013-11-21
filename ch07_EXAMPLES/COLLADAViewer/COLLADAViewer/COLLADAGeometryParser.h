//
//  COLLADAGeometryParser.h
//  COLLADAViewer
//

#import <Foundation/Foundation.h>

@class COLLADAParser;
@class COLLADAGeometryInfo;


@interface COLLADAGeometryParser : NSObject

+ (COLLADAGeometryInfo *)geometryFromElement:
   (NSXMLElement *)element;

- (COLLADAGeometryInfo *)extractGeometryFromGeometryElement:
   (NSXMLElement *)element;

@end
