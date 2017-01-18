attribute vec3 vert;
attribute vec2 texCoord;
varying mediump vec2 fragTexCoord;
//uniform mat4 normalMatrix;

void main() {
    // Pass the tex coord straight through to the fragment shader
    fragTexCoord = texCoord;
    
    gl_Position = vec4(vert, 1.0);
}
/*
attribute vec4 vPos;
attribute vec2 vTex0;
uniform highp mat4 uWVP;
varying mediump vec2 TexCoordOut;

void main(void) { 
    gl_Position = uWVP * vPos;
    TexCoordOut = vTex0;
}*/

//
//  Shader.vsh
//  openGLtest
//
//  Created by ARTEM RIZHOV on 27.06.15.
//  Copyright (c) 2015 ARTEM RIZHOV. All rights reserved.
//
/*
attribute vec4 position;
attribute vec3 normal;

varying lowp vec4 colorVarying;

uniform mat4 modelViewProjectionMatrix;
uniform mat3 normalMatrix;

void main()
{
    vec3 eyeNormal = normalize(normalMatrix * normal);
    vec3 lightPosition = vec3(0.0, 0.0, 1.0);
    vec4 diffuseColor = vec4(0.4, 0.4, 1.0, 1.0);
    
    float nDotVP = max(0.0, dot(eyeNormal, normalize(lightPosition)));
    
    colorVarying = diffuseColor * nDotVP;
    
    gl_Position = modelViewProjectionMatrix * position;
}*/