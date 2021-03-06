//
//  DFGLImageView.h
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

#import <UIKit/UIKit.h>

#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

enum
{
    DF_UNIFORM_TEXTURE0=0,
    DF_UNIFORM_MODELVIEWPROJECTION_MATRIX,
    DF_UNIFORM_NORMAL_MATRIX,
    DF_UNIFORM_RADIUS,
    DF_UNIFORM_INTENSITY_LEVELS,
    DF_UNIFORM_IMAGE_SIZE,
    DF_NUM_UNIFORMS
};


@interface DFGLImageView : UIView
{
    float _imageWidth;
    float _imageHeight;
    GLuint _texId;
}

- (UIImage*)drawableToCGImage;
- (UIImage*)getImageFromLayer;
- (void)render;
- (void)initGL;
- (GLint)createShaderProgramWithVertexShader:(NSString*)fileNameVertexShader
                              fragmentShader:(NSString*)fileNameFragmentShader;
- (GLuint)loadTextureWithName:(NSString*)name;

@property (nonatomic) GLuint program;
@property NSMutableArray* uniforms;

@end
