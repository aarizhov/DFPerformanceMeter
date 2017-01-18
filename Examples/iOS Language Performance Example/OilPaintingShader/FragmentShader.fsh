
precision highp float;
//precision mediump vec2;

uniform sampler2D tex;
uniform float fIntensityLevels;
uniform int radius;
uniform vec2 src_size;// = vec2 (1.0 / 1000.0, 1.0 / 1000.0);
varying highp vec2 fragTexCoord;

int nIntensityCount[32];
vec3 nSum[32];


void main() {
    for (int i = 0; i < 32; i ++) {
        nIntensityCount[i] = 0;
    }
    for (int i = 0; i < 32; i ++) {
        nSum[i] = vec3(0.0,0.0,0.0);
    }
    int nY_O;
    int nX_O;
    vec3 c;
    int nCurIntensity = 0;
    for(  nY_O = -radius; nY_O <= radius; nY_O++ )
    {
        for(  nX_O = -radius; nX_O <= radius; nX_O++ )
        {
            c = texture2D(tex, fragTexCoord + vec2(nX_O,nY_O) * src_size).rgb;
            nCurIntensity = int( ( c.r + c.g + c.b ) / 3.0  * fIntensityLevels);
            nIntensityCount[nCurIntensity]++;
            nSum[nCurIntensity] += c;
        }
    }
    
    int nCurMax = 0;
    int nMaxIndex = 0;
    for( int nI = 0; nI < 32; nI++ )
    {
        if( nIntensityCount[nI] > nCurMax )
        {
            nCurMax = nIntensityCount[nI];
            nMaxIndex = nI;
        }
    }
    
    gl_FragColor = vec4(nSum[nMaxIndex] / float(nCurMax), 1.0);//texture2D(tex, fragTexCoord);//texture2D(tex, fragTexCoord);//vec4(nSum[nMaxIndex] / float(nCurMax), 1.0);
}
