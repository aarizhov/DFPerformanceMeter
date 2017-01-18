
//precision mediump float;

attribute vec4 a_position;
attribute vec2 texCoord;
uniform mat4 normalMatrix;

varying highp vec2 fragTexCoord;


void main() {
    fragTexCoord = texCoord;
    gl_Position = a_position * vec4(1.0, -1.0, 1.0, 1.0);
} 