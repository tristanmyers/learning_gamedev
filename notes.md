- How do I detect when a rect is off screen?
There is a ``HasIntersection()`` proc but this seems to not have been added to the nim-lang/sdl2 lib. If this was the case I could just make a reactangle covering the entire screen than check if 
``rect1.HasIntersection(windowRect)``

So instead I'm checking if the ``rect x coord + rect width`` is greater than the rectangle covering the whole window.  

When trying to draw onto the screen, pixels are placed on the back buffer. This means that the things in the back buffer are not on the screen, I need to call ``present()`` to update the screen with whatever is in the back buffer.

- How do I draw a texture on to the screen?
Initially I was trying to use a texture but have found out that a texture is GPU rendered and I am okay with just rendering a surface for this project.

Creating a window also creates a surface the size of the window.

I can load an image(bmp) with ``loadBMP``, this will create a surface.

Once we have the image, just blit that image surface on to the window surface.

- How do I get user input?
- Frames?
