//
//  UtilityMesh.m
//  
//

#import "UtilityMesh+viewAdditions.h"
#import "UtilityModelEffect.h"

@implementation UtilityMesh (viewAdditions)

/////////////////////////////////////////////////////////////////
// This method prepares the current OpenGL ES 2.0 context for
// drawing with the receiver's vertex attributes and indices.
- (void)prepareToDraw;
{
   if(0 != vertexArrayID_)
   {
      glBindVertexArrayOES(vertexArrayID_);
   }
   else if(0 < [self.vertexData length])
   {
      if(self.shouldUseVAOExtension)
      {
         glGenVertexArraysOES(1, &vertexArrayID_);
         NSAssert(0 != vertexArrayID_, @"Unable to create VAO");
         glBindVertexArrayOES(vertexArrayID_);
      }
      
      if(0 == vertexBufferID_)
      {  // Vertices haven't been sent to GPU yet
         // Create an element array buffer for mesh indices
         glGenBuffers(1, &vertexBufferID_);
         NSAssert(0 != vertexBufferID_, 
            @"Failed to generate vertex array buffer");
             
         glBindBuffer(GL_ARRAY_BUFFER, vertexBufferID_);
         glBufferData(GL_ARRAY_BUFFER, 
            [self.vertexData length], 
            [self.vertexData bytes], 
            GL_STATIC_DRAW);      
      }
      else
      {
         glBindBuffer(GL_ARRAY_BUFFER, vertexBufferID_);
      }

      // Set pointers
      glEnableVertexAttribArray(UtilityVertexAttribPosition); 
      glVertexAttribPointer(
         UtilityVertexAttribPosition,
         3, 
         GL_FLOAT,
         GL_FALSE, 
         sizeof(UtilityMeshVertex), 
         (GLbyte *)NULL + 
            offsetof(UtilityMeshVertex, position));
      
      glEnableVertexAttribArray(UtilityVertexAttribNormal); 
      glVertexAttribPointer(
         UtilityVertexAttribNormal,
         3, 
         GL_FLOAT,
         GL_FALSE, 
         sizeof(UtilityMeshVertex), 
         (GLbyte *)NULL + 
            offsetof(UtilityMeshVertex, normal));
      
      glEnableVertexAttribArray(UtilityVertexAttribTexCoord0); 
      glVertexAttribPointer(
         UtilityVertexAttribTexCoord0,
         2,
         GL_FLOAT, 
         GL_FALSE, 
         sizeof(UtilityMeshVertex), 
         (GLbyte *)NULL + 
            offsetof(UtilityMeshVertex, texCoords0));

      glEnableVertexAttribArray(UtilityVertexAttribTexCoord1); 
      glVertexAttribPointer(
         UtilityVertexAttribTexCoord1,
         2,
         GL_FLOAT, 
         GL_FALSE, 
         sizeof(UtilityMeshVertex), 
         (GLbyte *)NULL + 
            offsetof(UtilityMeshVertex, texCoords1));
   }

   if(0 != indexBufferID_)
   {
      glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBufferID_);
   }   
   else if(0 < [self.indexData length])
   {  // Indices haven't been sent to GPU yet
      // Create an element array buffer for mesh indices
      glGenBuffers(1, &indexBufferID_);
      NSAssert(0 != indexBufferID_, 
         @"Failed to generate element array buffer");
          
      glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 
         indexBufferID_);
      glBufferData(GL_ELEMENT_ARRAY_BUFFER, 
         [self.indexData length], 
         [self.indexData bytes], 
         GL_STATIC_DRAW);      
   }
}


/////////////////////////////////////////////////////////////////
// This method prepares the current OpenGL ES 2.0 context for
// picking with the receiver's vertex attributes and indices.
- (void)prepareToPick;
{
   if(0 == vertexBufferID_ && 0 < [self.vertexData length])
   {  // Vertices haven't been sent to GPU yet
      // Create an element array buffer for mesh indices
      glGenBuffers(1, &vertexBufferID_);
      NSAssert(0 != vertexBufferID_, 
         @"Failed to generate vertex array buffer");
          
      glBindBuffer(GL_ARRAY_BUFFER, vertexBufferID_);
      glBufferData(GL_ARRAY_BUFFER, 
         [self.vertexData length], 
         [self.vertexData bytes], 
         GL_STATIC_DRAW);      
   }
   else
   {
      glBindBuffer(GL_ARRAY_BUFFER, vertexBufferID_);
   }

   // Set pointers
   glEnableVertexAttribArray(UtilityVertexAttribPosition); 
   glVertexAttribPointer(
      UtilityVertexAttribPosition,
      3, 
      GL_FLOAT,
      GL_FALSE, 
      sizeof(UtilityMeshVertex), 
      (GLbyte *)NULL + 
         offsetof(UtilityMeshVertex, position));
   
   glDisableVertexAttribArray(UtilityVertexAttribNormal); 
   glDisableVertexAttribArray(UtilityVertexAttribTexCoord0); 

   if(0 == indexBufferID_ && 0 < [self.indexData length])
   {  // Indices haven't been sent to GPU yet
      // Create an element array buffer for mesh indices
      glGenBuffers(1, &indexBufferID_);
      NSAssert(0 != indexBufferID_, 
         @"Failed to generate element array buffer");
          
      glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, vertexBufferID_);
      glBufferData(GL_ELEMENT_ARRAY_BUFFER, 
         [self.indexData length], 
         [self.indexData bytes], 
         GL_STATIC_DRAW);      
   }
   else
   {
      glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, vertexBufferID_);
   }
}


/////////////////////////////////////////////////////////////////
// After the receiver has been prepared for drawing or picking, 
// call this method to draw the portions of the mesh described
// by the specified range of the receiver's commands.
- (void)drawCommandsInRange:(NSRange)aRange;
{
   if(0 < aRange.length)
   {
      const NSUInteger lastCommandIndex = 
         (aRange.location + aRange.length) - 1;

      NSParameterAssert(aRange.location < [self.commands count]);
      NSParameterAssert(lastCommandIndex < [self.commands count]);

      for(NSUInteger i = aRange.location; 
         i <= lastCommandIndex; i++)
      {
         NSDictionary *currentCommand = 
            [self.commands objectAtIndex:i];
         const GLsizei  numberOfIndices = (GLsizei)[[currentCommand 
            objectForKey:@"numberOfIndices"] 
            unsignedIntegerValue];
         const GLsizei  firstIndex = (GLsizei)[[currentCommand 
            objectForKey:@"firstIndex"] unsignedIntegerValue];
         GLenum mode = (GLenum)[[currentCommand 
            objectForKey:@"command"] unsignedIntegerValue];
           
         glDrawElements(mode,
            (GLsizei)numberOfIndices,
            GL_UNSIGNED_SHORT,
            ((GLushort *)NULL + firstIndex));      
      }
   }
}


/////////////////////////////////////////////////////////////////
// After the receiver has been prepared for drawing, 
// call this method to draw lines defining a box containing
// all portions of the mesh described by the specified range of 
// the receiver's commands. This provides a quick visual way to 
// see the volume occupied by portions of the mesh.
- (void)drawBoundingBoxStringForCommandsInRange:
   (NSRange)aRange;
{
   if(0 < aRange.length)
   {
      const NSUInteger lastCommandIndex = 
         (aRange.location + aRange.length) - 1;

      NSParameterAssert(aRange.location < [self.commands count]);
      NSParameterAssert(lastCommandIndex < [self.commands count]);

      const GLushort *indices = (const GLushort *)
         [self.indexData bytes];
                
      for(NSUInteger i = aRange.location; 
         i <= lastCommandIndex; i++)
      {
         NSDictionary *currentCommand = 
            [self.commands objectAtIndex:i];
         size_t  numberOfIndices = (size_t)[[currentCommand 
            objectForKey:UtilityMeshCommandNumberOfIndices] 
            unsignedIntegerValue];
         size_t  firstIndex = (size_t)[[currentCommand 
            objectForKey:UtilityMeshCommandFirstIndex] 
               unsignedIntegerValue];
           
         glDrawElements(
            GL_LINE_STRIP,
            (GLsizei)numberOfIndices,
            GL_UNSIGNED_SHORT,
            indices + firstIndex);      
      }
   }
}

@end
