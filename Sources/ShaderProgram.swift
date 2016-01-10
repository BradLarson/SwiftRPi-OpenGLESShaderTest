#if os(Linux)
    import COpenGLES.gles2
#else
    import OpenGL.GL3
#endif

import Foundation


struct ShaderCompileError:ErrorType {
    let compileLog:String
}

enum ShaderType {
    case VertexShader
    case FragmentShader
}

func compileShader(shaderString:String, type:ShaderType) throws -> GLuint {
    let shaderHandle:GLuint
    switch type {
        case .VertexShader: shaderHandle = glCreateShader(GLenum(GL_VERTEX_SHADER))
        case .FragmentShader: shaderHandle = glCreateShader(GLenum(GL_FRAGMENT_SHADER))
    }
    
    let shaderCString = UnsafeMutablePointer<UInt8>.alloc(shaderString.characters.count+1)
    for (index, characterValue) in shaderString.utf8.enumerate() {
        shaderCString[index] = characterValue
    }
    shaderCString[shaderString.characters.count] = 0 // Have to add a null termination
    
    var shaderCStringPointer = UnsafePointer<GLchar>(shaderCString)
    
    glShaderSource(shaderHandle, 1, &shaderCStringPointer, nil)
    glCompileShader(shaderHandle)
    
    shaderCString.dealloc(shaderString.characters.count)
    
    var compileStatus:GLint = 1
    glGetShaderiv(shaderHandle, GLenum(GL_COMPILE_STATUS), &compileStatus)
    if (compileStatus != 1) {
        var logLength:GLint = 0
        glGetShaderiv(shaderHandle, GLenum(GL_INFO_LOG_LENGTH), &logLength)
        if (logLength > 0) {
            var compileLog = [CChar](count:Int(logLength), repeatedValue:0)
            
            glGetShaderInfoLog(shaderHandle, logLength, &logLength, &compileLog)
            print("Compile log: \(String.fromCString(compileLog))")
            // let compileLogString = String(bytes:compileLog.map{UInt8($0)}, encoding:NSASCIIStringEncoding)
            
            switch type {
            case .VertexShader: throw ShaderCompileError(compileLog:"Vertex shader compile error:")
            case .FragmentShader: throw ShaderCompileError(compileLog:"Fragment shader compile error:")
            }
        }
    }
    
    return shaderHandle
}

class ShaderProgram {
    let program:GLuint
    var vertexShader:GLuint! // At some point, the Swift compiler will be able to deal with the early throw and we can convert these to lets
    var fragmentShader:GLuint!
    var initialized:Bool = false
    private var attributes = [String]()
    
    // MARK: -
    // MARK: Initialization and teardown
    
    init(vertexShader:String, fragmentShader:String) throws {
        program = glCreateProgram()
        
        self.vertexShader = try compileShader(vertexShader, type:.VertexShader)
        self.fragmentShader = try compileShader(fragmentShader, type:.FragmentShader)
        
        glAttachShader(program, self.vertexShader)
        glAttachShader(program, self.fragmentShader)
    }
    
    convenience init(vertexShaderFile:NSURL, fragmentShaderFile:NSURL) throws {
        // Note: this is a hack until Foundation's String initializers are fully functional
        //        let vertexShaderString = String(contentsOfURL:vertexShaderFile, encoding:NSASCIIStringEncoding)
        //        let fragmentShaderString = String(contentsOfURL:fragmentShaderFile, encoding:NSASCIIStringEncoding)
        guard (NSFileManager.defaultManager().fileExistsAtPath(vertexShaderFile.path!)) else { throw ShaderCompileError(compileLog:"Vertex shader file missing")}
        guard (NSFileManager.defaultManager().fileExistsAtPath(fragmentShaderFile.path!)) else { throw ShaderCompileError(compileLog:"Fragment shader file missing")}
        let vertexShaderString = try NSString(contentsOfFile:vertexShaderFile.path!, encoding:NSASCIIStringEncoding)
        let fragmentShaderString = try NSString(contentsOfFile:fragmentShaderFile.path!, encoding:NSASCIIStringEncoding)
        
        try self.init(vertexShader:String(vertexShaderString), fragmentShader:String(fragmentShaderString))
    }
    
    deinit {
        if (vertexShader != nil) {
            glDeleteShader(vertexShader)
        }
        if (fragmentShader != nil) {
            glDeleteShader(fragmentShader)
        }
        glDeleteProgram(program)
    }
    
    // MARK: -
    // MARK: Attributes and uniforms
    
    func addAttribute(attribute:String) {
        if (!attributes.contains(attribute)) {
            attributes.append(attribute)
            glBindAttribLocation(program, (GLuint)(attributes.count - 1), UnsafePointer<GLchar>(Array<UInt8>(attribute.utf8)))
        }
    }
    
    func attributeIndex(attribute:String) -> GLint? {
        return attributes.indexOf(attribute).flatMap{GLint($0)}
    }
    
    func uniformIndex(uniform:String) -> GLint {
        return glGetUniformLocation(program, UnsafePointer<GLchar>(Array<UInt8>(uniform.utf8)))
    }
    
    // MARK: -
    // MARK: Usage
    
    func link() throws {
        glLinkProgram(program)
        
        var linkStatus:GLint = 0
        glGetProgramiv(program, GLenum(GL_LINK_STATUS), &linkStatus)
        if (linkStatus == 0) {
            var logLength:GLint = 0
            glGetProgramiv(program, GLenum(GL_INFO_LOG_LENGTH), &logLength)
            if (logLength > 0) {
                var compileLog = [CChar](count:Int(logLength), repeatedValue:0)
                
                glGetProgramInfoLog(program, logLength, &logLength, &compileLog)
                print("Link log: \(String.fromCString(compileLog))")
            }
            
            
            throw ShaderCompileError(compileLog:"Link error")
        }
        initialized = true
    }
    
    func use() {
        glUseProgram(program)
    }
}
