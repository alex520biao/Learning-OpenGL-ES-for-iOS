//
//  UtilityModel+skinning.m
//
//

#import "UtilityModel+skinning.h"
#import "UtilityMesh+Skinning.h"
#import "UtilityJoint.h"


@implementation UtilityModel (skinning)


/////////////////////////////////////////////////////////////////
// Set the index of the matrix to use for one armature joint
// per vertex animation
- (void)assignJoint:(NSUInteger)anIndex;
{
   const NSUInteger lastCommandIndex = 
      self.indexOfFirstCommand + self.numberOfCommands;

   for(NSUInteger i = self.indexOfFirstCommand; 
      i < lastCommandIndex; i++)
   {  // for each command that draws part of model
      NSDictionary *currentCommand = 
         [self.mesh.commands objectAtIndex:i];
      const GLsizei numberOfIndices = (GLsizei)[[currentCommand 
         objectForKey:UtilityMeshCommandNumberOfIndices]
         unsignedIntegerValue];
      const GLsizei firstIndex = (GLsizei)[[currentCommand 
         objectForKey:UtilityMeshCommandFirstIndex] 
         unsignedIntegerValue];
      
      GLsizei lastIndex = firstIndex + numberOfIndices;
      
      for(GLsizei j = firstIndex; j < lastIndex; j++)
      {  // For each mesh index used by command
         // Joint indices start at 1
         UtilityMeshJointInfluence influences = 
            {{anIndex + 1, 0, 0, 0}, {1, 0, 0, 0}};
            
         [self.mesh setJointInfluence:influences atIndex:j];
      }
   }
}


/////////////////////////////////////////////////////////////////
//  
static GLfloat UtilityVector3DistanceSquared(
   GLKVector3 positionA,
   GLKVector3 positionB)
{
   const GLKVector3 vectorFromAtoB = GLKVector3Subtract(
      positionB, positionA);
      
   return GLKVector3DotProduct(vectorFromAtoB, 
      vectorFromAtoB);
}


/////////////////////////////////////////////////////////////////
//  
- (UtilityMeshJointInfluence)closestJointsToPosition:
   (GLKVector3)position
   joints:(NSArray *)joints;
{
   struct jointInfo {
      float jointIndex;
      float distanceSquared;  
   };
   
   struct jointInfo joint0 = {0, HUGE_VALF}; 
   struct jointInfo joint1 = {0, HUGE_VALF}; 
   struct jointInfo joint2 = {0, HUGE_VALF}; 
   struct jointInfo joint3 = {0, HUGE_VALF};
      
   // For each joint
   const NSUInteger count = [joints count];      
   for(NSUInteger i = 0; i < count; i++)
   {
      UtilityJoint *joint = [joints objectAtIndex:i];
      
      float distanceSquared = UtilityVector3DistanceSquared(
         position, joint.cumulativeDisplacement);
      
      // Joint matrix indices are 1 based because matrix[0] is
      // reserved to be identity (mvpMatrix in Shader)
      struct jointInfo currentJoint = {i + 1, distanceSquared}; 
      
      // Sort currentJoint into four closest joints
      struct jointInfo closerJoint = 
         (currentJoint.distanceSquared < joint0.distanceSquared)
         ? currentJoint : joint0;
      struct jointInfo furtherJoint = 
         (currentJoint.distanceSquared > joint0.distanceSquared)
         ? currentJoint : joint0;
      joint0 = closerJoint;
        
      closerJoint = 
         (furtherJoint.distanceSquared < joint1.distanceSquared)
         ? furtherJoint : joint1;
      furtherJoint = 
         (furtherJoint.distanceSquared > joint1.distanceSquared)
         ? furtherJoint : joint1;
      joint1 = closerJoint;
        
      closerJoint = 
         (furtherJoint.distanceSquared < joint2.distanceSquared)
         ? furtherJoint : joint2;
      furtherJoint = 
         (furtherJoint.distanceSquared > joint2.distanceSquared)
         ? furtherJoint : joint2;
      joint2 = closerJoint;
        
      closerJoint = 
         (furtherJoint.distanceSquared < joint3.distanceSquared)
         ? furtherJoint : joint3;
      joint3 = closerJoint;
   }
      
   // Collect result;
   GLKVector4 jointIndices = {
      joint0.jointIndex,
      joint1.jointIndex,
      joint2.jointIndex,
      joint3.jointIndex};
      
   GLKVector4 jointWeights = {
      1.0f / MAX(joint0.distanceSquared, 0.001),
      1.0f / MAX(joint1.distanceSquared, 0.001),
      1.0f / MAX(joint2.distanceSquared, 0.001),
      1.0f / MAX(joint3.distanceSquared, 0.001)};
      
   // Normalizing scales the weights proportionally
   if(jointWeights.x == HUGE_VALF) jointWeights.x = 0;
   if(jointWeights.y == HUGE_VALF) jointWeights.y = 0;
   if(jointWeights.z == HUGE_VALF) jointWeights.z = 0;
   if(jointWeights.w == HUGE_VALF) jointWeights.w = 0;
   jointWeights = GLKVector4Normalize(jointWeights);
   
   UtilityMeshJointInfluence result = 
      {jointIndices, jointWeights};
   
   /***** Uncomment to see skinning weight assignments
   NSLog(@"Y:%0.2f {%d, %d, %d, %d}{%f, %f, %f, %f}", 
      position.y,
      (int)result.jointIndices.x,
      (int)result.jointIndices.y,
      (int)result.jointIndices.z,
      (int)result.jointIndices.w,
      result.jointWeights.x,
      result.jointWeights.y,
      result.jointWeights.z,
      result.jointWeights.w);
   *****/
      
   return result;
}


/////////////////////////////////////////////////////////////////
//  
- (UtilityMeshJointInfluence)jointBelowPosition:
   (GLKVector3)position
   joints:(NSArray *)joints;
{
   struct jointInfo {
      float jointIndex;
      float distanceSquared;  
   };
   
   struct jointInfo joint0 = {0, 1}; 
   struct jointInfo joint1 = {0, 0}; 
   struct jointInfo joint2 = {0, 0}; 
   struct jointInfo joint3 = {0, 0};
      
   // For each joint
   const NSUInteger count = [joints count];      
   for(NSUInteger i = 0; i < count; i++)
   {
      UtilityJoint *joint = [joints objectAtIndex:i];
      
      GLKVector3 jointDisplacement = 
         joint.cumulativeDisplacement;
      if(jointDisplacement.y <= position.y)
      {
        joint0.jointIndex = i + 1;
      }
   }
      
   // Collect result;
   GLKVector4 jointIndices = {
      joint0.jointIndex,
      joint1.jointIndex,
      joint2.jointIndex,
      joint3.jointIndex};
      
   GLKVector4 jointWeights = {
      joint0.distanceSquared,
      joint1.distanceSquared,
      joint2.distanceSquared,
      joint3.distanceSquared};
      
   // Normalizing scales the weights proportionally
   jointWeights = GLKVector4Normalize(jointWeights);
   
   UtilityMeshJointInfluence result = 
      {jointIndices, jointWeights};
   
   /***** Uncomment to see skinning weight assignments *
   NSLog(@"Y:%0.2f {%d, %d, %d, %d}{%f, %f, %f, %f}", 
      position.y,
      (int)result.jointIndices.x,
      (int)result.jointIndices.y,
      (int)result.jointIndices.z,
      (int)result.jointIndices.w,
      result.jointWeights.x,
      result.jointWeights.y,
      result.jointWeights.z,
      result.jointWeights.w);
   *****/
      
   return result;
}


/////////////////////////////////////////////////////////////////
// Set the index of the matrix to use for blended armature 
// animation
- (void)automaticallySkinSmoothWithJoints:(NSArray *)joints;
{
   const NSUInteger lastCommandIndex = 
      self.indexOfFirstCommand + self.numberOfCommands;

   for(NSUInteger i = self.indexOfFirstCommand; 
      i < lastCommandIndex; i++)
   {  // for each command that draws part of model
      NSDictionary *currentCommand = 
         [self.mesh.commands objectAtIndex:i];
      const GLsizei numberOfIndices = (GLsizei)[[currentCommand 
         objectForKey:UtilityMeshCommandNumberOfIndices]
         unsignedIntegerValue];
      const GLsizei firstIndex = (GLsizei)[[currentCommand 
         objectForKey:UtilityMeshCommandFirstIndex] 
         unsignedIntegerValue];
      
      GLsizei lastIndex = firstIndex + numberOfIndices;
      
      for(GLsizei j = firstIndex; j < lastIndex; j++)
      {  // For each mesh index used by command
         UtilityMeshVertex currentVertex = 
            [self.mesh vertexAtIndex:j]; 
         
         UtilityMeshJointInfluence influences = 
            [self closestJointsToPosition:currentVertex.position
            joints:joints];
            
         [self.mesh setJointInfluence:influences atIndex:j];
      }
   }
}


/////////////////////////////////////////////////////////////////
// Set the index of the matrix to use for one armature joint
// per vertex animation
- (void)automaticallySkinRigidWithJoints:(NSArray *)joints;
{
   const NSUInteger lastCommandIndex = 
      self.indexOfFirstCommand + self.numberOfCommands;

   for(NSUInteger i = self.indexOfFirstCommand; 
      i < lastCommandIndex; i++)
   {  // for each command that draws part of model
      NSDictionary *currentCommand = 
         [self.mesh.commands objectAtIndex:i];
      const GLsizei numberOfIndices = (GLsizei)[[currentCommand 
         objectForKey:UtilityMeshCommandNumberOfIndices]
         unsignedIntegerValue];
      const GLsizei firstIndex = (GLsizei)[[currentCommand 
         objectForKey:UtilityMeshCommandFirstIndex] 
         unsignedIntegerValue];
      
      GLsizei lastIndex = firstIndex + numberOfIndices;
      
      for(GLsizei j = firstIndex; j < lastIndex; j++)
      {  // For each mesh index used by command
         UtilityMeshVertex currentVertex = 
            [self.mesh vertexAtIndex:j]; 
         
         UtilityMeshJointInfluence influences = 
            [self jointBelowPosition:currentVertex.position
            joints:joints];
            
         [self.mesh setJointInfluence:influences atIndex:j];
      }
   }
}

@end
