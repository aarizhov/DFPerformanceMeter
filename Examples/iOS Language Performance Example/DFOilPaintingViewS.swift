//
//  DFOilPaintingViewS.swift
//  DFPerformanceMeter Examples
//
//  Created by Artem Ryzhov on 11/12/16.
//
//

import UIKit
import OpenGLES

class DFOilPaintingViewS: DFGLImageViewS {
    
    var radius = GLint()
    var fIntensityLevels = GLfloat()
    
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
        //glViewport(0, 0, GLsizei(self.frame.size.width), GLsizei(self.frame.size.height))
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
        glUniform1f(uniforms[DF_UNIFORM_INTENSITY_LEVELS], fIntensityLevels)
        glUniform2f(uniforms[DF_UNIFORM_IMAGE_SIZE], 1.0 / _imageWidth, 1.0 / _imageHeight)
        glDrawArrays(GLenum(GL_TRIANGLE_STRIP), 0, 4)
    }
    
}
