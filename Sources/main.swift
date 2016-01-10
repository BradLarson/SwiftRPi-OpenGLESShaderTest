import COpenGLES.gles2
import CVideoCore
import Foundation

struct renderingError: ErrorType {
    let errorString:String
}

var display:EGLDisplay = nil
var surface:EGLSurface = nil
var context:EGLContext = nil

var screen_width:UInt32 = 0
var screen_height:UInt32 = 0

var positionAttribute:GLuint = 0
var textureCoordinateAttribute:GLuint = 0

 var nativewindow = EGL_DISPMANX_WINDOW_T(element:0, width:0, height:0) // This needs to be retained at the top level or its deallocation will destroy the window system

func initializeOpenGLES() throws {
    display = eglGetDisplay(nil /* EGL_DEFAULT_DISPLAY */)
    //	guard (display != EGL_NO_DISPLAY) else {throw renderingError(errorString:"Could not obtain display")}
    
    //guard (eglInitialize(display, nil, nil) != EGL_FALSE) else {throw renderingError(errorString:"Could not initialize display")}
    eglInitialize(display, nil, nil)
    
    let attributes:[EGLint] = [
        EGL_RED_SIZE, 8,
        EGL_GREEN_SIZE, 8,
        EGL_BLUE_SIZE, 8,
        EGL_ALPHA_SIZE, 8,
        EGL_SURFACE_TYPE, EGL_WINDOW_BIT,
        EGL_NONE
    ]
    
    var config:EGLConfig = nil
    var num_config:EGLint = 0
    //	guard (eglChooseConfig(display, attributes, &config, 1, &num_config) != EGL_FALSE) else {throw renderingError(errorString:"Could not get a framebuffer configuration")}
    eglChooseConfig(display, attributes, &config, 1, &num_config)
    eglBindAPI(EGLenum(EGL_OPENGL_ES_API))
    
    //context = eglCreateContext(display, config, EGL_NO_CONTEXT, context_attributes)
    let context_attributes:[EGLint] = [
        EGL_CONTEXT_CLIENT_VERSION, 2,
        EGL_NONE
    ]
    context = eglCreateContext(display, config, nil /* EGL_NO_CONTEXT*/, context_attributes)
    //guard (context != EGL_NO_CONTEXT) else {throw renderingError(errorString:"Could not create a rendering context")}
    
    graphics_get_display_size(0 /* LCD */, &screen_width, &screen_height)
    let dispman_display = vc_dispmanx_display_open( 0 /* LCD */)
    let dispman_update = vc_dispmanx_update_start( 0 )
    var dst_rect = VC_RECT_T(x:0, y:0, width:Int32(screen_width), height:Int32(screen_height))
    var src_rect = VC_RECT_T(x:0, y:0, width:Int32(screen_width) << 16, height:Int32(screen_height) << 16)
    
    let dispman_element = vc_dispmanx_element_add(dispman_update, dispman_display, 0/*layer*/, &dst_rect, 0/*src*/, &src_rect, DISPMANX_PROTECTION_T(DISPMANX_PROTECTION_NONE), nil /*alpha*/, nil/*clamp*/, DISPMANX_TRANSFORM_T(0)/*transform*/)
	
    vc_dispmanx_update_submit_sync(dispman_update)
    
    nativewindow = EGL_DISPMANX_WINDOW_T(element:dispman_element, width:Int32(screen_width), height:Int32(screen_height))
    surface = eglCreateWindowSurface(display, config, &nativewindow, nil)
    //guard (surface != EGL_NO_SURFACE) else {throw renderingError(errorString:"Could not create a rendering surface")}
    
    eglMakeCurrent(display, surface, surface, context)
    
    glViewport(0, 0, GLsizei(screen_width), GLsizei(screen_height))
    glClearColor(0.15, 0.25, 0.35, 1.0)
    glClear(GLenum(GL_COLOR_BUFFER_BIT))
}

func drawQuad(shader:ShaderProgram) {
    glClear(GLenum(GL_COLOR_BUFFER_BIT))
    shader.use()
    
    let squareVertices:[GLfloat] = [
        -1.0, -1.0,
        1.0, -1.0,
        -1.0,  1.0,
        1.0,  1.0,
    ]
    
    let textureCoordinates:[GLfloat] = [
        0.0, 0.0,
        1.0, 0.0,
        0.0, 1.0,
        1.0, 1.0,
    ]
    
    glVertexAttribPointer(positionAttribute, 2, GLenum(GL_FLOAT), 0, 0, squareVertices)
    glVertexAttribPointer(textureCoordinateAttribute, 2, GLenum(GL_FLOAT), 0, 0, textureCoordinates)
    
    glDrawArrays(GLenum(GL_TRIANGLE_STRIP), 0, 4)
    eglSwapBuffers(display, surface)
}

var terminate:Int = 0

// Program execution start

do {
    bcm_host_init()
    try initializeOpenGLES()
    
    let shaderProgram = try ShaderProgram(vertexShaderFile:NSURL(fileURLWithPath:"SimpleVertexShader.vsh"), fragmentShaderFile:NSURL(fileURLWithPath:"SimpleFragmentShader.fsh"))
    shaderProgram.addAttribute("position")
    shaderProgram.addAttribute("inputTextureCoordinate")
    try shaderProgram.link()
    positionAttribute = GLuint(shaderProgram.attributeIndex("position")!)
    textureCoordinateAttribute = GLuint(shaderProgram.attributeIndex("inputTextureCoordinate")!)
    glEnableVertexAttribArray(positionAttribute)
    glEnableVertexAttribArray(textureCoordinateAttribute)
    
    while (terminate == 0) {
        drawQuad(shaderProgram)
    }
} catch {
    print("Terminated due to error: \(error)")
}
