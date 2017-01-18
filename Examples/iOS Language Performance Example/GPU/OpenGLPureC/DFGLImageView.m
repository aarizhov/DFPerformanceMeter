//
//  DFGLImageView.m
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

#import "DFGLImageView.h"

@interface DFGLImageView ()
{
    GLuint _vertexArray;
    GLuint _vertexBuffer;
    
    GLint framebufferWidth;
    GLint framebufferHeight;
    GLuint defaultFramebuffer, colorRenderbuffer;
}

- (void)deleteFramebuffer;

@property (nonatomic) EAGLContext *context;

@end

@implementation DFGLImageView

+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)initGL{
    _uniforms = [NSMutableArray new];
    for (int i = 0; i < DF_NUM_UNIFORMS; i ++) {
        _uniforms[i] = @(i);
    }
    [self _initGLContext];
    [self _createGLFramebuffer];
}

- (GLuint)loadTextureWithName:(NSString*)name{
    CGImageRef cgImage = [UIImage imageNamed:name].CGImage;
    GLuint width = (GLuint)CGImageGetWidth(cgImage);
    GLuint height = (GLuint)CGImageGetHeight(cgImage);
    _imageWidth = width;
    _imageHeight = height;
    CGDataProviderRef dataProvider = CGImageGetDataProvider(cgImage);
    CFDataRef data = CGDataProviderCopyData(dataProvider);
    const unsigned char  * bytes = CFDataGetBytePtr(data);
    glGenTextures(1, &_texId);
    glBindTexture(GL_TEXTURE_2D, _texId);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, bytes);
    CFRelease(data);
    return 0;
}

- (void)_initGLContext{
    CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
    eaglLayer.opaque = YES;
    //eaglLayer.contentsScale = 2.0;
    eaglLayer.drawableProperties = @{
                                     kEAGLDrawablePropertyRetainedBacking: [NSNumber numberWithBool:YES],
                                     kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8
                                     };
    _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:_context];
}

- (void)deleteGL
{
    if (_context) {
        [EAGLContext setCurrentContext:_context];
        
        if(_texId){
            glBindTexture(GL_TEXTURE_2D, _texId);
            glDeleteTextures(1, &_texId);
        }
        if(_program){
            glUseProgram(_program);
            glDeleteProgram(_program);
        }
        
        [self deleteFramebuffer];
    }
}

- (void)glRender{
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    
    glDisable(GL_DEPTH_TEST);
    glUseProgram(_program);
    
    static GLfloat square[] = {
        -1.0, -1.0,
        1.0, -1.0,
        -1.0, 1.0,
        1.0, 1.0};
    
    
    static GLfloat squareTexCoords[] = {
        0.0, 0.0,
        1.0, 0.0,
        0.0, 1.0,
        1.0, 1.0};
    
    const char *aPositionCString = [@"a_position" cStringUsingEncoding:NSUTF8StringEncoding];
    GLuint aPosition = glGetAttribLocation(_program, aPositionCString);
    const char *aTexCoordCString = [@"texCoord" cStringUsingEncoding:NSUTF8StringEncoding];
    GLuint aTexCoord = glGetAttribLocation(_program, aTexCoordCString);
    
    glVertexAttribPointer(aPosition, 2, GL_FLOAT, GL_FALSE, 0, square);
    glEnableVertexAttribArray(aPosition);
    glVertexAttribPointer(aTexCoord, 2, GL_FLOAT, GL_FALSE, 0, squareTexCoords);
    glEnableVertexAttribArray(aTexCoord);
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, _texId);
    
    glUniform1i((GLint)[_uniforms[DF_UNIFORM_TEXTURE0] integerValue], 0);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

- (void)render{
    if (!defaultFramebuffer)
        [self _createGLFramebuffer];
    glViewport(0, 0, framebufferWidth, framebufferHeight);
    
    [self glRender];
    
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}


- (void)dealloc
{
    [self deleteGL];
}

- (void)deleteFramebuffer
{
    if (_context) {
        [EAGLContext setCurrentContext:_context];
        
        if (defaultFramebuffer) {
            glDeleteFramebuffers(1, &defaultFramebuffer);
            defaultFramebuffer = 0;
        }
        
        if (colorRenderbuffer) {
            glDeleteRenderbuffers(1, &colorRenderbuffer);
            colorRenderbuffer = 0;
        }
    }
}

- (void)_createGLFramebuffer{
    [EAGLContext setCurrentContext:_context];
    
    glGenRenderbuffers(1, &colorRenderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer];
    
    glGenFramebuffers(1, &defaultFramebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRenderbuffer);
    
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &framebufferWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &framebufferHeight);
    
    
    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE){
        NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
    }
}

- (void)setFramebuffer
{
    if (_context) {
        [EAGLContext setCurrentContext:_context];
        
        if (!defaultFramebuffer)
            [self _createGLFramebuffer];
        
        glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer);
        
        glViewport(0, 0, framebufferWidth, framebufferHeight);
    }
}

- (BOOL)presentFramebuffer
{
    BOOL success = FALSE;
    
    if (_context) {
        [EAGLContext setCurrentContext:_context];
        
        glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
        
        success = [_context presentRenderbuffer:GL_RENDERBUFFER];
    }
    
    return success;
}

- (void)layoutSubviews
{
    [self deleteFramebuffer];
}

- (UIImage*) getImageFromLayer
{
    UIGraphicsBeginImageContext(CGSizeMake(self.layer.bounds.size.width,
                                           self.layer.bounds.size.height));
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return img;
}

-(UIImage *)drawableToCGImage
{
    GLint backingWidth2, backingHeight2;
    
    // Get the size of the backing CAEAGLLayer
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth2);
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight2);
    
    GLint x = 0, y = 0, width2 = backingWidth2, height2 = backingHeight2;
    NSInteger dataLength = width2 * height2 * 4;
    GLubyte *data = (GLubyte*)malloc(dataLength * sizeof(GLubyte));
    
    // Read pixel data from the framebuffer
    glPixelStorei(GL_PACK_ALIGNMENT, 4);
    glReadPixels(x, y, width2, height2, GL_RGBA, GL_UNSIGNED_BYTE, data);
    
    CGDataProviderRef ref = CGDataProviderCreateWithData(NULL, data, dataLength, NULL);
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGImageRef iref = CGImageCreate(width2, height2, 8, 32, width2 * 4, colorspace, kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast,
                                    ref, NULL, true, kCGRenderingIntentDefault);
    
    // OpenGL ES measures data in PIXELS
    // Create a graphics context with the target size measured in POINTS
    NSInteger widthInPoints, heightInPoints;
    
    CGFloat scale = self.contentScaleFactor;
    widthInPoints = width2 / scale;
    heightInPoints = height2 / scale;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(widthInPoints, heightInPoints), NO, scale);

    CGContextRef cgcontext = UIGraphicsGetCurrentContext();
    
    CGContextSetBlendMode(cgcontext, kCGBlendModeCopy);
    CGContextDrawImage(cgcontext, CGRectMake(0.0, 0.0, widthInPoints, heightInPoints), iref);
    
    // Retrieve the UIImage from the current context
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    // Clean up
    free(data);
    CFRelease(ref);
    CFRelease(colorspace);
    CGImageRelease(iref);
    
    return image;
}

#pragma mark -  OpenGL ES 2 shader compilation

- (GLint)createShaderProgramWithVertexShader:(NSString*)fileNameVertexShader
                              fragmentShader:(NSString*)fileNameFragmentShader
{
    NSString *vertexShaderSource = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:fileNameVertexShader ofType:@"vsh"] encoding:NSUTF8StringEncoding error:nil];
    const char *vertexShaderSourceCString = [vertexShaderSource cStringUsingEncoding:NSUTF8StringEncoding];
    
    // Create and compile vertex shader
    GLuint vertexShader = glCreateShader(GL_VERTEX_SHADER);
    glShaderSource(vertexShader, 1, &vertexShaderSourceCString, NULL);
    glCompileShader(vertexShader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(vertexShader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(vertexShader, logLength, &logLength, log);
        NSLog(@"Shader 1 compile log:\n%s", log);
        free(log);
    }
#endif
    
    // Read fragment shader source
    NSString *fragmentShaderSource = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:fileNameFragmentShader ofType:@"fsh"] encoding:NSUTF8StringEncoding error:nil];
    const char *fragmentShaderSourceCString = [fragmentShaderSource cStringUsingEncoding:NSUTF8StringEncoding];
    // Create and compile fragment shader
    GLuint fragmentShader = glCreateShader(GL_FRAGMENT_SHADER);
    glShaderSource(fragmentShader, 1, &fragmentShaderSourceCString, NULL);
    glCompileShader(fragmentShader);
#if defined(DEBUG)
    {
        GLint logLength;
        glGetShaderiv(fragmentShader, GL_INFO_LOG_LENGTH, &logLength);
        if (logLength > 0) {
            GLchar *log = (GLchar *)malloc(logLength);
            glGetShaderInfoLog(fragmentShader, logLength, &logLength, log);
            NSLog(@"Shader 2 compile log:\n%s", log);
            free(log);
        }
    }
#endif
    // Create and link program
    GLuint program = glCreateProgram();
    glAttachShader(program, vertexShader);
    glAttachShader(program, fragmentShader);
    glLinkProgram(program);
    {
        GLint logLength;
        glGetProgramiv(program, GL_INFO_LOG_LENGTH, &logLength);
        if (logLength > 0) {
            GLchar *log = (GLchar *)malloc(logLength);
            glGetProgramInfoLog(program, logLength, &logLength, log);
            NSLog(@"Program link log:\n%s", log);
            free(log);
        }
    }
    // Release vertex and fragment shaders.
    if (vertexShader) {
        glDetachShader(program, vertexShader);
        glDeleteShader(vertexShader);
    }
    if (fragmentShader) {
        glDetachShader(program, fragmentShader);
        glDeleteShader(fragmentShader);
    }
    return program;
}

@end
