
//precision mediump float;

attribute vec4 a_position;

void main() {
    gl_Position = a_position;// * vec4(1.0, -1.0, 1.0, 1.0);
} 
