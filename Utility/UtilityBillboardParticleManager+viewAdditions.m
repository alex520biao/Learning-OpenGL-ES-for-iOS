//
//  UtilityBillboardParticleManager+viewAdditions.m
//  
//

#import "UtilityBillboardParticleManager+viewAdditions.h"
#import "UtilityBillboardParticle.h"
#import "UtilityBillboardParticleEffect.h"
#import "UtilityCamera.h"
#import <GLKit/GLKit.h>


/////////////////////////////////////////////////////////////////
// Vertex attributes used in UtilityBillboardParticleShader
typedef struct
{
  GLKVector3 position;
  GLKVector2 textureCoords;
  GLfloat opacity;
}
BillboardVertex;


@implementation UtilityBillboardParticleManager (viewAdditions)

/////////////////////////////////////////////////////////////////
// Sort particles in reverse order for rendering from furthest
// to nearest.
- (void)drawWithCamera:(UtilityCamera *)aCamera;
{
   // Calculate displacements for billboard vertices based on
   // frustum. Particles always face the viewer.
   GLKVector3 upUnitVector = GLKVector3Make(0.0f, 1.0f, 0.0f);
   GLKVector3 rightVector = GLKVector3CrossProduct(
      upUnitVector,
      aCamera.frustumForCulling->zUnitVector);
   
   if(self.shouldRenderSpherical)
   {  // Recalculate up vector so that particles will be 
      // parallel to frustum's near plane.
      upUnitVector = GLKVector3CrossProduct(
         aCamera.frustumForCulling->zUnitVector,
         rightVector);
   }
   
   // collect vertex data
   NSMutableData *billboardVertices = [NSMutableData data];
      
   // Update and store the vertices for all visible particles.
   for (UtilityBillboardParticle *billboard in 
      [self.sortedParticles reverseObjectEnumerator])
   {
      if(!billboard.isAlive || 0 <= billboard.distanceSquared)
      {  // Due to sort order, remaining particles are dead or 
         // behind the viewer so stop processing now.
         break;
      }
      else
      {  // billboard is alive and in front of viewer. Calculate
         // vertex positions based on displacements
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
         const GLfloat opacity = billboard.opacity;
            
         BillboardVertex vertices[6];
         vertices[0].position = leftBottomPosition;
         vertices[0].textureCoords.x = minTextureCoords.x;
         vertices[0].textureCoords.y = maxTextureCoords.y;
         vertices[0].opacity = opacity;
         vertices[1].position = rightBottomPosition;
         vertices[1].textureCoords = maxTextureCoords;
         vertices[1].opacity = opacity;
         vertices[2].position = leftTopPosition;
         vertices[2].textureCoords = minTextureCoords;
         vertices[2].opacity = opacity;
         vertices[3].position = leftTopPosition;
         vertices[3].textureCoords = minTextureCoords;
         vertices[3].opacity = opacity;
         vertices[4].position = rightBottomPosition;
         vertices[4].textureCoords = maxTextureCoords;
         vertices[4].opacity = opacity;
         vertices[5].position = rightTopPosition;
         vertices[5].textureCoords.x = maxTextureCoords.x;
         vertices[5].textureCoords.y = minTextureCoords.y;
         vertices[5].opacity = opacity;
         
         [billboardVertices appendBytes:vertices 
            length:sizeof(vertices)];
      }
   }   

   glBindVertexArrayOES(0);
   glBindBuffer(GL_ARRAY_BUFFER, 0);

   glEnableVertexAttribArray(UtilityVertexAttribPosition); 
   glVertexAttribPointer(            
      UtilityVertexAttribPosition,       
      3,                
      GL_FLOAT,            
      GL_FALSE,            
      sizeof(BillboardVertex),         
      (GLbyte *)[billboardVertices bytes] + 
      offsetof(BillboardVertex, position));       
   glEnableVertexAttribArray(UtilityVertexAttribTexCoord0); 
   glVertexAttribPointer(            
      UtilityVertexAttribTexCoord0,       
      2,                
      GL_FLOAT,            
      GL_FALSE,            
      sizeof(BillboardVertex),         
      (GLbyte *)[billboardVertices bytes] + 
      offsetof(BillboardVertex, textureCoords));       
   glEnableVertexAttribArray(UtilityVertexAttribOpacity);
   glVertexAttribPointer(            
      UtilityVertexAttribOpacity,       
      1,                
      GL_FLOAT,            
      GL_FALSE,            
      sizeof(BillboardVertex),         
      (GLbyte *)[billboardVertices bytes] + 
         offsetof(BillboardVertex, opacity));  

   glDepthMask(GL_FALSE);  // Disable depth buffer writes
   glDrawArrays(GL_TRIANGLES, 
      0, 
      [billboardVertices length] / sizeof(BillboardVertex));
   glDepthMask(GL_TRUE);   // Reenable depth buffer writes
}

@end
