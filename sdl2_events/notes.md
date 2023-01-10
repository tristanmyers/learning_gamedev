How do I draw a texture on to the screen?
Initially I was trying to use a texture but have found out that a texture is GPU rendered and I am okay with just rendering a surface for this project.

Creating a window also creates a surface the size of the window.

I can load an image(bmp) with ``loadBMP``, this will create a surface.

Once we have the image, just blit that image surface on to the window surface.

How do I get user input?
