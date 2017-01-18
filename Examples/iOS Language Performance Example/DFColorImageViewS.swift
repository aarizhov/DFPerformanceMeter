//
//  DFColorImageView.swift
//  DFPerformanceMeter Examples
//
//  Created by Artem Ryzhov on 11/12/16.
//
//

import UIKit
import OpenGLES

class DFColorImageViewS: DFGLImageViewS {
    var radius = GLint()
    var fIntensityLevels = GLfloat()
    
    override func initGL() {
        super.initGL()
        self.program = GLuint(self.createShaderProgram(withVertexShader: "VertexColorShader", fragmentShader: "FragmentColorShader"))
    }
    
    override func glRender() {
        //glViewport(0, 0, GLsizei(self.frame.size.width), GLsizei(self.frame.size.height))
        glDisable(GLenum(GL_DEPTH_TEST))
        glUseProgram(self.program)
        let square: [GLfloat] = [-1.0, -1.0, 1.0, -1.0, -1.0, 1.0, 1.0, 1.0]
        let aPositionCString = "a_position".cString(using: String.Encoding.utf8)
        let aPosition = glGetAttribLocation(self.program, aPositionCString)
        glVertexAttribPointer(GLuint(aPosition), 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 0, square)
        glEnableVertexAttribArray(GLuint(aPosition))
        glDrawArrays(GLenum(GL_TRIANGLE_STRIP), 0, 4)
    }
}
