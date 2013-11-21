//
//  UtilityMesh+skinning.m
//
//

#import "UtilityMesh+viewAdditions.h"
#import "UtilityMesh+skinning.h"
#import "UtilityArmatureBaseEffect.h"


@implementation UtilityMesh (Skinning)

/////////////////////////////////////////////////////////////////
// Set the influence that each joint has on the specified 
// mesh vertex.
- (void)setJointInfluence:
     (UtilityMeshJointInfluence)aJointInfluence
   atIndex:(GLsizei)vertexIndex;
{
   NSMutableData *jointControlsData = self.extraVertexData;
   
   // Make sure there is enough storage for joint influence
   // attributes
   if([jointControlsData length] < (self.numberOfIndices *
      sizeof(UtilityMeshJointInfluence)))
   {
      // Initialize all of the joint controls
      const UtilityMeshJointInfluence defaultInfluence = 
         {{0, 0, 0, 0},{1, 0, 0, 0}};
         
      for(int i = 0; i < self.numberOfIndices; i++)
      {
         [jointControlsData appendBytes:&defaultInfluence 
            length:sizeof(UtilityMeshJointInfluence)];
      }
   }
   
   NSParameterAssert(vertexIndex < self.numberOfIndices);
   UtilityMeshJointInfluence *jointControlsPtr = 
      (UtilityMeshJointInfluence *)[jointControlsData 
         mutableBytes];
      
   jointControlsPtr[vertexIndex] = aJointInfluence;
   
   // If the mesh joint influences are cached in a GPU controlled
   // buffer, then the GPU controlled buffer's contents need to 
   // be updated. The easiest way to force the buffer contents
   // update is to delete the current buffer. It will be 
   // recreated if necessary in -prepareToDrawWithJointInfluence.
   if(0 != vertexExtraBufferID_)
   {  
      glBindBuffer(GL_ARRAY_BUFFER, 0);
      glDeleteBuffers(1, &vertexExtraBufferID_);
      vertexExtraBufferID_ = 0;
   }
}
   

/////////////////////////////////////////////////////////////////
// This method prepares the current OpenGL ES 2.0 context for
// drawing the receiver's mesh vertices with amature joint
// weighting.
- (void)prepareToDrawWithJointInfluence;
{
   [self prepareToDraw];

   // If there is no "Vertex Array Object" VAO ID stored in
   // vertexArrayID_ after -prepareToDraw then it is necessary
   // to bind vertexExtraBufferID_ and set pointers to vertex
   // attributes within the bound buffer. Similarly, if
   // vertexExtraBufferID_ has not yet been initialized, it's
   // necessary to generate, bind, and fill the buffer with 
   // vertex data and then set pointers to vertex attributes 
   // within the bound buffer.
   // In contrast, if both vertexArrayID_ and 
   // vertexExtraBufferID_ are already configured, there is
   // no more setup needed here.
   if(0 == vertexArrayID_ || 0 == vertexExtraBufferID_)
   {
      if(0 == vertexExtraBufferID_)
      {  // Vertices haven't been sent to GPU yet
         // Create an element array buffer for mesh indices
         glGenBuffers(1, &vertexExtraBufferID_);
         NSAssert(0 != vertexExtraBufferID_, 
            @"Failed to generate vertex array buffer");
             
         glBindBuffer(GL_ARRAY_BUFFER, vertexExtraBufferID_);
         glBufferData(GL_ARRAY_BUFFER, 
            [self.extraVertexData length], 
            [self.extraVertexData bytes], 
            GL_STATIC_DRAW);      
      }
      else
      {
         glBindBuffer(GL_ARRAY_BUFFER, vertexExtraBufferID_);
      }

      glEnableVertexAttribArray(
         UtilityArmatureVertexAttribJointMatrixIndices);       
      glVertexAttribPointer(  
         UtilityArmatureVertexAttribJointMatrixIndices,
         4,                   // number of coordinates 
         GL_FLOAT,            // data is floating point
         GL_FALSE,            // no fixed point scaling
         sizeof(UtilityMeshJointInfluence),// bytes per vert
         (GLubyte *)NULL +
            offsetof(UtilityMeshJointInfluence, jointIndices)); 
        
      glEnableVertexAttribArray(
         UtilityArmatureVertexAttribJointNormalizedWeights); 
      glVertexAttribPointer(  
         UtilityArmatureVertexAttribJointNormalizedWeights, 
         4,                   // number of coordinates 
         GL_FLOAT,            // data is floating point
         GL_FALSE,            // no fixed point scaling
         sizeof(UtilityMeshJointInfluence),// bytes per vert
         (GLubyte *)NULL + 
            offsetof(UtilityMeshJointInfluence, jointWeights)); 
   }
   
#ifdef DEBUG
   {  // Report any errors 
      GLenum error = glGetError();
      if(GL_NO_ERROR != error)
      {
         NSLog(@"GL Error: 0x%x", error);
      }
   }
#endif
}

@end
