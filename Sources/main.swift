import COpenGLES.gles2
import Foundation

var positionAttribute:GLuint = 0
var textureCoordinateAttribute:GLuint = 0

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
    presentRenderBuffer()
 }

var terminate:Int = 0

// Program execution start

do {
    try initializeRenderWindow(width:640, height:480)
    
    let shaderProgram:ShaderProgram
    let fileNames = Array<String>(Process.arguments.dropFirst())
    if (fileNames.count > 1) {
        print(fileNames)
        shaderProgram = try ShaderProgram(vertexShaderFile:NSURL(fileURLWithPath:fileNames[0]), fragmentShaderFile:NSURL(fileURLWithPath:fileNames[1]))
    } else {
        shaderProgram = try ShaderProgram(vertexShaderFile:NSURL(fileURLWithPath:"SimpleVertexShader.vsh"), fragmentShaderFile:NSURL(fileURLWithPath:"SimpleFragmentShader.fsh"))
    }
    
    // This assumes a couple of defined attributes for vertices and texture coordinates
    shaderProgram.addAttribute("position")
    shaderProgram.addAttribute("inputTextureCoordinate")
    try shaderProgram.link()
    positionAttribute = GLuint(shaderProgram.attributeIndex("position")!)
    textureCoordinateAttribute = GLuint(shaderProgram.attributeIndex("inputTextureCoordinate")!)
    glEnableVertexAttribArray(positionAttribute)
    glEnableVertexAttribArray(textureCoordinateAttribute)
    
    while (terminate == 0) {
        let startTime = NSDate()
        
        drawQuad(shaderProgram)
        
        print("Render time: \(-startTime.timeIntervalSinceNow)")
    }
} catch {
    print("Terminated due to error: \(error)")
}
