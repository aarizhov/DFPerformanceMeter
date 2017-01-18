//
//  DFOilPaintingView.m
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

#import "DFOilPaintingView.h"

@implementation DFOilPaintingView

- (void)initGL{
    [super initGL];
    [self loadTextureWithName:@"texture0"];
    self.program = [self createShaderProgramWithVertexShader:@"VertexShader"
                                              fragmentShader:@"FragmentShader"];
    self.uniforms[DF_UNIFORM_TEXTURE0] = @(glGetUniformLocation(self.program, "tex"));
    self.uniforms[DF_UNIFORM_RADIUS] = @(glGetUniformLocation(self.program, "radius"));
    self.uniforms[DF_UNIFORM_INTENSITY_LEVELS] = @(glGetUniformLocation(self.program, "fIntensityLevels"));
    self.uniforms[DF_UNIFORM_IMAGE_SIZE] = @(glGetUniformLocation(self.program, "src_size"));
}

- (void)glRender{
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    
    glDisable(GL_DEPTH_TEST);
    glUseProgram(self.program);
    
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
    GLuint aPosition = glGetAttribLocation(self.program, aPositionCString);
    const char *aTexCoordCString = [@"texCoord" cStringUsingEncoding:NSUTF8StringEncoding];
    GLuint aTexCoord = glGetAttribLocation(self.program, aTexCoordCString);
    
    glVertexAttribPointer(aPosition, 2, GL_FLOAT, GL_FALSE, 0, square);
    glEnableVertexAttribArray(aPosition);
    glVertexAttribPointer(aTexCoord, 2, GL_FLOAT, GL_FALSE, 0, squareTexCoords);
    glEnableVertexAttribArray(aTexCoord);
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, _texId);
    
    glUniform1i((GLint)[self.uniforms[DF_UNIFORM_TEXTURE0] integerValue], 0);
    glUniform1i((GLint)[self.uniforms[DF_UNIFORM_RADIUS] integerValue], (int)_radius);
    glUniform1f((GLint)[self.uniforms[DF_UNIFORM_INTENSITY_LEVELS] integerValue], _fIntensityLevels);
    glUniform2f((GLint)[self.uniforms[DF_UNIFORM_IMAGE_SIZE] integerValue], _imageWidth, _imageHeight);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}


@end
