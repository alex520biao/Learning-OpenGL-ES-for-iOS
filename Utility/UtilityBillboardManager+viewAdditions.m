//
//  UtilityBillboardManager+viewAdditions.m
//  
//

#import "UtilityBillboardManager+viewAdditions.h"
#import "UtilityBillboard.h"
#import <GLKit/GLKit.h>


/////////////////////////////////////////////////////////////////
// Vertex attributes used in render billboards
typedef struct
{
  GLKVector3 position;
  GLKVector3 normal;
  GLKVector2 textureCoords;
}
BillboardVertex;


@implementation UtilityBillboardManager (viewAdditions)

/////////////////////////////////////////////////////////////////
// Sort particles in reverse order for rendering from furthest
// to nearest.
- (void)drawWithEyePosition:(GLKVector3)eyePosition 
   lookDirection:(GLKVector3)lookDirection 
   upVector:(GLKVector3)upVector;
{
   // Make sure lookDirection is a unit vector
   lookDirection = GLKVector3Normalize(lookDirection);
   
   // Calculate displacements for billboard vertices based on
   // frustum. Billboards always face the viewer.
   GLKVector3 upUnitVector = GLKVector3Make(0.0f, 1.0f, 0.0f);
   GLKVector3 rightVector = GLKVector3CrossProduct(
      upUnitVector,
      lookDirection);
   
   if(self.shouldRenderSpherical)
   {  // Recalculate up vector so that particles will be 
      // parallel to frustum's near plane.
      upUnitVector = GLKVector3CrossProduct(
         lookDirection,
         rightVector);
   }
   
   const GLKVector3 normalVector = 
      GLKVector3Negate(lookDirection);
   //const GLKVector3 normalVector = lookDirection;
      
   // collect vertex data
   NSMutableData *billboardVertices = [NSMutableData data];
      
   // Update and store the vertices for all visible particles.
   for (UtilityBillboard *billboard in 
      [self.sortedBillboards reverseObjectEnumerator])
   {
      if(0 <= billboard.distanceSquared)
      {  // Due to sort order, remaining particles are behind the 
         // viewer so stop processing now.
         break;
      }
      else
      {  // billboard in front of viewer. Calculate vertex 
         // positions based on displacements
         const GLKVector2 size = billboard.size;
         const GLKVector3 position = billboard.position;
         
         GLKVector3 leftBottomPosition = 
            GLKVector3Add(GLKVector3MultiplyScalar(
            rightVector, size.x * -0.5f), position);
         GLKVector3 rightBottomPosition = 
            GLKVector3Add(GLKVector3MultiplyScalar(
            rightVector, size.x * 0.5f), position);
         GLKVector3 leftTopPosition = 
            GLKVector3Add(leftBottomPosition, 
               GLKVector3MultiplyScalar(upUnitVector, size.y));
         GLKVector3 rightTopPosition = 
            GLKVector3Add(rightBottomPosition, 
               GLKVector3MultiplyScalar(upUnitVector, size.y));
         
         // Store vertices for two triangles that compose one
         // billboard.    
         const GLKVector2 maxTextureCoords = 
            billboard.maxTextureCoords;
         const GLKVector2 minTextureCoords = 
            billboard.minTextureCoords;
            
         BillboardVertex vertices[6];
         vertices[2].position = leftBottomPosition;
         vertices[2].normal = normalVector;
         vertices[2].textureCoords.x = minTextureCoords.x;
         vertices[2].textureCoords.y = maxTextureCoords.y;
         vertices[1].position = rightBottomPosition;
         vertices[1].normal = normalVector;
         vertices[1].textureCoords = maxTextureCoords;
         vertices[0].position = leftTopPosition;
         vertices[0].normal = normalVector;
         vertices[0].textureCoords = minTextureCoords;
         vertices[5].position = leftTopPosition;
         vertices[5].normal = normalVector;
         vertices[5].textureCoords = minTextureCoords;
         vertices[4].position = rightBottomPosition;
         vertices[4].normal = normalVector;
         vertices[4].textureCoords = maxTextureCoords;
         vertices[3].position = rightTopPosition;
         vertices[3].normal = normalVector;
         vertices[3].textureCoords.x = maxTextureCoords.x;
         vertices[3].textureCoords.y = minTextureCoords.y;
         
         [billboardVertices appendBytes:vertices 
            length:sizeof(vertices)];
      }
   }   

   glBindVertexArrayOES(0);
   glBindBuffer(GL_ARRAY_BUFFER, 0);

   glEnableVertexAttribArray(GLKVertexAttribPosition); 
   glVertexAttribPointer(            
      GLKVertexAttribPosition,       
      3,                
      GL_FLOAT,            
      GL_FALSE,            
      sizeof(BillboardVertex),         
      (GLbyte *)[billboardVertices bytes] + 
      offsetof(BillboardVertex, position));       
   glEnableVertexAttribArray(GLKVertexAttribNormal); 
   glVertexAttribPointer(            
      GLKVertexAttribNormal,       
      3,                
      GL_FLOAT,            
      GL_FALSE,            
      sizeof(BillboardVertex),         
      (GLbyte *)[billboardVertices bytes] + 
      offsetof(BillboardVertex, normal));       
   glEnableVertexAttribArray(GLKVertexAttribTexCoord0); 
   glVertexAttribPointer(            
      GLKVertexAttribTexCoord0,       
      2,                
      GL_FLOAT,            
      GL_FALSE,            
      sizeof(BillboardVertex),         
      (GLbyte *)[billboardVertices bytes] + 
      offsetof(BillboardVertex, textureCoords));       

   glDepthMask(GL_FALSE);  // Disable depth buffer writes
   glDrawArrays(GL_TRIANGLES, 
      0, 
      [billboardVertices length] / sizeof(BillboardVertex));
   glDepthMask(GL_TRUE);   // Reenable depth buffer writes
}

@end
