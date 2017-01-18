
precision highp float;
precision highp int;
//precision highp vec2;
//precision highp vec4;

attribute highp vec4 a_position;
attribute highp vec2 texCoord;
//uniform mat4 normalMatrix;

varying highp vec2 fragTexCoord;

void main() {
    fragTexCoord = texCoord;
    gl_Position = a_position * vec4(1.0, -1.0, 1.0, 1.0);
} 
