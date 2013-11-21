Chapter 5 Examples

Use the obj2openglFlippedZ.pl script to generate .h files from .obj files when using the default OpenGL ES coordinate system. i.e. no use of glFrustumf() or glOrthof().

The obj2openglFlippedZ.pl script inverts the Z coordinate of all vertices and normal vectors.

Use the obj2opengl.pl script to generate .h files from .obj files when using glFrustumf() or glOrthof().

Example: >obj2opengl.pl -nomove sphere.obj 

