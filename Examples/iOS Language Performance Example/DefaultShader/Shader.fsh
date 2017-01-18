uniform sampler2D tex; //this is the texture
varying lowp vec2 fragTexCoord; //this is the texture coord
//out vec4 finalColor; //this is the output color of the pixel

void main() {
    gl_FragColor = texture2D(tex, fragTexCoord); //texture2D ?? vec4(1.0,1.0,1.0,1.0);//
}

/*
uniform sampler2D uTexture0;
uniform lowp vec4 CBDiffuseColor;
varying lowp vec2 TexCoordOut;

void main(void) {
    gl_FragColor = texture2D(uTexture0, TexCoordOut) * CBDiffuseColor;
}
*/
/*
varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}*/