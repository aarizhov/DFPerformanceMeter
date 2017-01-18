//
//  DFGLImageViewS.swift
//  iOS Language Performance Example
//
//  Copyright (c) 2009-2017 Artem Ryzhov ( http://devforfun.net/ )
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import UIKit
import OpenGLES

let DF_UNIFORM_TEXTURE0 = 0
let DF_UNIFORM_MODELVIEWPROJECTION_MATRIX = 1
let DF_UNIFORM_NORMAL_MATRIX = 2
let DF_UNIFORM_RADIUS = 3
let DF_UNIFORM_INTENSITY_LEVELS = 4
let DF_UNIFORM_IMAGE_SIZE = 5
var uniforms = [GLint](repeating: 0, count: 6)

class DFGLImageViewS: UIView {
    
    
    var eaglLayer: CAEAGLLayer!
    var context: EAGLContext!
    var _vertexArray = GLuint()
    var _vertexBuffer = GLuint()
    var framebufferWidth = GLint()
    var framebufferHeight = GLint()
    var defaultFramebuffer = GLuint()
    var colorRenderbuffer = GLuint()
    
    var _imageWidth: Float = 0.0
    var _imageHeight: Float = 0.0
    var _texId = GLuint()
    
    var program = GLuint()
    
    override class var layerClass: AnyClass {
        get {
            return CAEAGLLayer.self
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func initGL() {
        for i in 0..<6 {
            uniforms[i] = GLint(0)
        }
        self._initGLContext()
        self._createGLFramebuffer()
    }
    
    func loadTexture(name: String) -> GLuint {
        let cgImage = UIImage(named: name)!.cgImage!
        let width = cgImage.width
        let height = cgImage.height
        self._imageWidth = Float(width)
        self._imageHeight = Float(height)
        let dataProvider = cgImage.dataProvider
        let data = dataProvider!.data
        let bytes: UnsafePointer<UInt8> = CFDataGetBytePtr(data)
        
        glGenTextures(1, &_texId)
        glBindTexture(GLenum(GL_TEXTURE_2D), _texId)
        glTexParameterf(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GLfloat(GL_CLAMP_TO_EDGE))
        glTexParameterf(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GLfloat(GL_CLAMP_TO_EDGE))
        glTexParameterf(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GLfloat(GL_NEAREST))
        glTexParameterf(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GLfloat(GL_NEAREST))
        glTexImage2D(GLenum(GL_TEXTURE_2D), 0, GL_RGBA, GLsizei(width), GLsizei(height), 0, GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE), bytes)
        //CFRelease(data)
        return _texId
    }
    
    func _initGLContext() {
        eaglLayer = layer as! CAEAGLLayer
        eaglLayer.isOpaque = true
        
        //there no need for swift version of OpenGL
        // eaglLayer.drawableProperties = [
        //     kEAGLDrawablePropertyRetainedBacking : Int(false),
        //     kEAGLDrawablePropertyColorFormat :     //                                        kEAGLColorFormatRGB565,
        //     kEAGLColorFormatRGBA8
        // ]
        
        let api: EAGLRenderingAPI = EAGLRenderingAPI.openGLES2
        context = EAGLContext(api: api)
        
        if (!(self.context != nil)) {
            print("Failed to initialize OpenGLES 2.0 context!")
            exit(1)
        }
        
        if (!EAGLContext.setCurrent(context)) {
            print("Failed to set current OpenGL context!")
            exit(1)
        }
        
    }
    
    func deleteGL() {
        if (context != nil) {
            EAGLContext.setCurrent(self.context)
            if (_texId != 0) {
                glBindTexture(GLenum(GL_TEXTURE_2D), _texId)
                glDeleteTextures(1, &_texId)
            }
            if (program != 0) {
                glUseProgram(program)
                glDeleteProgram(program)
            }
            self.deleteFramebuffer()
        }
    }
    
    func glRender() {
        
    }
    
    func render() {
        if (defaultFramebuffer == 0) {
            self._createGLFramebuffer()
        }
    
        glViewport(0, 0, framebufferWidth, framebufferHeight)
        self.glRender()
        context.presentRenderbuffer(Int(GL_RENDERBUFFER))
    }
    
    deinit {
        self.deleteGL()
    }
    
    func deleteFramebuffer() {
        if context != nil {
            EAGLContext.setCurrent(context)
            if (defaultFramebuffer != 0) {
                glDeleteFramebuffers(1, &defaultFramebuffer)
                defaultFramebuffer = 0
            }
            if (colorRenderbuffer != 0) {
                glDeleteRenderbuffers(1, &colorRenderbuffer)
                colorRenderbuffer = 0
            }
        }
    }
    
    func _createGLFramebuffer() {
        EAGLContext.setCurrent(context)
        
        glGenRenderbuffers(1, &colorRenderbuffer)
        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), colorRenderbuffer)
        context.renderbufferStorage(Int(GL_RENDERBUFFER), from: (self.layer as! CAEAGLLayer))
        
        glGenFramebuffers(1, &defaultFramebuffer)
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), defaultFramebuffer)
        glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_RENDERBUFFER), colorRenderbuffer)
        
        glGetRenderbufferParameteriv(GLenum(GL_RENDERBUFFER), GLenum(GL_RENDERBUFFER_WIDTH), &framebufferWidth)
        glGetRenderbufferParameteriv(GLenum(GL_RENDERBUFFER), GLenum(GL_RENDERBUFFER_HEIGHT), &framebufferHeight)
        
        
        if (glCheckFramebufferStatus(GLenum(GL_FRAMEBUFFER)) != GLenum(GL_FRAMEBUFFER_COMPLETE)) {
            print("Failed to make complete framebuffer object \(glCheckFramebufferStatus(GLenum(GL_FRAMEBUFFER)))")
        }
    }
    
    func setFramebuffer() {
        if context != nil {
            EAGLContext.setCurrent(context)
            if (defaultFramebuffer != 0) {
                self._createGLFramebuffer()
            }
            glBindFramebuffer(GLenum(GL_FRAMEBUFFER), defaultFramebuffer)
            glViewport(0, 0, framebufferWidth, framebufferHeight)
        }
    }
    
    func presentFramebuffer() -> Bool {
        var success = false
        if context != nil {
            EAGLContext.setCurrent(context)
            glBindRenderbuffer(GLenum(GL_RENDERBUFFER), colorRenderbuffer)
            success = context.presentRenderbuffer(Int(GL_RENDERBUFFER))
        }
        return success
    }
    
    override func layoutSubviews() {
        self.deleteFramebuffer()
    }
    
    func drawableToCGImage() -> UIImage {
        let backingWidth2 = framebufferWidth
        let backingHeight2 = framebufferHeight
        let x = 0
        let y = 0
        let width2 = backingWidth2
        let height2 = backingHeight2
        let dataLength = width2 * height2 * 4
        
        let data = malloc(Int(dataLength))
        glPixelStorei(GLenum(GL_PACK_ALIGNMENT), 4)
        glReadPixels(GLint(x), GLint(y), width2, height2, GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE), data)
        
        let ref = CGDataProvider(dataInfo: nil, data: data!, size: Int(dataLength), releaseData: {_,_,_ in
            
        })
        
        let colorspace = CGColorSpaceCreateDeviceRGB()
        let gg = CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue
        
        let iref = CGImage(width: Int(width2), height: Int(height2), bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: size_t(width2 * 4), space: colorspace, bitmapInfo: CGBitmapInfo(rawValue: gg), provider: ref!, decode: nil, shouldInterpolate: true, intent: CGColorRenderingIntent.defaultIntent)
        var widthInPoints: Int
        var heightInPoints: Int
        let scale: CGFloat = self.contentScaleFactor
        widthInPoints = Int(width2) * Int(scale)
        heightInPoints = Int(height2) * Int(scale)
        UIGraphicsBeginImageContextWithOptions(CGSize(width: CGFloat(widthInPoints), height: CGFloat(heightInPoints)), false, scale)
        let cgcontext = UIGraphicsGetCurrentContext()!
        cgcontext.setBlendMode(CGBlendMode.copy)
        cgcontext.draw(iref!, in:  CGRect(x: CGFloat(0.0), y: CGFloat(0.0), width: CGFloat(widthInPoints), height: CGFloat(heightInPoints)))
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        free(data)
        return image
    }
    
    func createShaderProgram(withVertexShader fileNameVertexShader: String, fragmentShader fileNameFragmentShader: String) -> GLint {
        
        var source: UnsafePointer<Int8>
        do {
            source = try NSString(contentsOfFile: Bundle.main.path(forResource: fileNameVertexShader, ofType: "vsh")!, encoding: String.Encoding.utf8.rawValue).utf8String!
        } catch {
            print("Failed to load vertex shader")
            return 0
        }
        var castSource: UnsafePointer<GLchar>? = UnsafePointer<GLchar>(source)
        
        let vertexShader = glCreateShader(GLenum(GL_VERTEX_SHADER))
        glShaderSource(vertexShader, 1, &castSource, nil)
        glCompileShader(vertexShader)
        
        do {
            source = try NSString(contentsOfFile: Bundle.main.path(forResource: fileNameFragmentShader, ofType: "fsh")!, encoding: String.Encoding.utf8.rawValue).utf8String!
        } catch {
            print("Failed to load vertex shader")
            return 0
        }
        
        castSource = UnsafePointer<GLchar>(source)
        
        // Create and compile fragment shader
        let fragmentShader = glCreateShader(GLenum(GL_FRAGMENT_SHADER))
        glShaderSource(fragmentShader, 1, &castSource, nil)
        glCompileShader(fragmentShader)
        
        
        // Create and link program
        let program = glCreateProgram()
        glAttachShader(program, vertexShader)
        glAttachShader(program, fragmentShader)
        glLinkProgram(program)
        do {
            var logLength: GLint = 0
            glGetProgramiv(program, GLenum(GL_INFO_LOG_LENGTH), &logLength)
            if logLength > 0 {
                let log = UnsafeMutablePointer<GLchar>.allocate(capacity: Int(logLength))
                //malloc(Int(logLength))
                glGetProgramInfoLog(program, logLength, &logLength, log)
                print("Program link log:\n\(log)")
                free(log)
            }
        }
        // Release vertex and fragment shaders.
        if (vertexShader != 0) {
            glDetachShader(program, vertexShader)
            glDeleteShader(vertexShader)
        }
        if (fragmentShader != 0) {
            glDetachShader(program, fragmentShader)
            glDeleteShader(fragmentShader)
        }
        return GLint(program)
    }
    
}
