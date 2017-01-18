//
//  DFOilPaintingViewS.swift
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

class DFOilPaintingViewS: DFGLImageViewS {
    
    var radius = GLint()
    var fIntensityLevels = GLint()
    
    override func initGL() {
        super.initGL()
        _texId = self.loadTexture(name: "texture0")
        self.program = GLuint(self.createShaderProgram(withVertexShader: "VertexShader", fragmentShader: "FragmentShader"))
        uniforms[DF_UNIFORM_IMAGE_SIZE] = (glGetUniformLocation(self.program, "src_size"))
        uniforms[DF_UNIFORM_TEXTURE0] = (glGetUniformLocation(self.program, "tex"))
        uniforms[DF_UNIFORM_RADIUS] = (glGetUniformLocation(self.program, "radius"))
        uniforms[DF_UNIFORM_INTENSITY_LEVELS] = (glGetUniformLocation(self.program, "fIntensityLevels"))
    }
    
    override func glRender() {
        glViewport(0, 0, GLsizei(self.frame.size.width), GLsizei(self.frame.size.height))
        glDisable(GLenum(GL_DEPTH_TEST))
        glUseProgram(self.program)
        let square: [GLfloat] = [-1.0, -1.0, 1.0, -1.0, -1.0, 1.0, 1.0, 1.0]
        let squareTexCoords: [GLfloat] = [0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 1.0, 1.0]
        let aPositionCString = "a_position".cString(using: String.Encoding.utf8)
        let aPosition = glGetAttribLocation(self.program, aPositionCString)
        let aTexCoordCString = "texCoord".cString(using: String.Encoding.utf8)
        let aTexCoord = glGetAttribLocation(self.program, aTexCoordCString)
        glVertexAttribPointer(GLuint(aPosition), 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 0, square)
        glEnableVertexAttribArray(GLuint(aPosition))
        glVertexAttribPointer(GLuint(aTexCoord), 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 0, squareTexCoords)
        glEnableVertexAttribArray(GLuint(aTexCoord))
        glActiveTexture(GLenum(GL_TEXTURE0))
        glBindTexture(GLenum(GL_TEXTURE_2D), _texId)
        glUniform1i(uniforms[DF_UNIFORM_TEXTURE0], 0)
        glUniform1i(uniforms[DF_UNIFORM_RADIUS], radius)
        glUniform1f(uniforms[DF_UNIFORM_INTENSITY_LEVELS], GLfloat(fIntensityLevels))
        glUniform2f(uniforms[DF_UNIFORM_IMAGE_SIZE], _imageWidth, _imageHeight)
        glDrawArrays(GLenum(GL_TRIANGLE_STRIP), 0, 4)
    }
    
}
