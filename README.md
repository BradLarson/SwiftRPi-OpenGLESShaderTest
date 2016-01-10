# SwiftRPi-OpenGLESShaderTest

This is a rudimentary Swift application that uses OpenGL ES to render a custom vertex and fragment shader to a screen-sized quad on a Raspberry Pi.

This requires the open source Swift compiler to be installed on the Raspberry Pi to build. I used the instructions by Andrew Madsen:

http://blog.andrewmadsen.com/post/136137396480/swift-on-raspberry-pi

and the precompiled packages from iAchieved.it:

http://dev.iachieved.it/iachievedit/open-source-swift-on-raspberry-pi-2/

to start from a clean Raspberry-Pi-compatible Ubuntu 14.04 and install the Swift toolchain on that.

After that, you'll need to install the `libraspberrypi` and `libraspberrypi-dev` packages to get the proper headers for OpenGL ES and the VideoCore libraries.

At the time I'm writing this, the Swift Package Manager isn't currently operational on Raspberry Pi, so I've created a simple build script to create the project and link in the appropriate modules. To run this, type

    ./compile.sh 

in the main project directory. This should compile the `shadertest` application, which you can run.

You can provide the shaders to use for the rendering at the command line, vertex shader first:

    ./shadertest SimpleVertexShader.vsh Mandelbrot.fsh

If you don't provide any shaders, the application looks for two shader files in the current directory, SimpleVertexShader.vsh and SimpleFragmentShader.fsh. If it finds those, it will load them and render a screen-size quad using them. You can edit these files how you want to produce arbitrary effects. To quit the application, hit Ctrl-C.

I'd like to also recognize SAKrisT's Swift OpenGL example:

https://github.com/sakrist/Swift_OpenGL_Example

, which pointed out something I was doing wrong in my shader loading.