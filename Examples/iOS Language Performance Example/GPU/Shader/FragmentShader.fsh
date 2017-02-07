//
//  FragmentShader.fsh
//  iOS Example
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

precision highp int;
precision highp float;
uniform highp sampler2D tex;
uniform highp float fIntensityLevels;
uniform highp int radius;
uniform highp vec2 src_size;
varying highp vec2 fragTexCoord;

#define INTENSITY_SIZE 32
#define INTENSITY_SIZE_1 31

void main() {
    highp int nIntensityCount[INTENSITY_SIZE];
    highp vec3 nSum[INTENSITY_SIZE];
    
    for (int i = 0; i < INTENSITY_SIZE; i ++) {
        nIntensityCount[i] = 0;
        nSum[i] = vec3(0.0,0.0,0.0);
    }
    int nY_O;
    int nX_O;
    highp vec3 c;
    
    vec2 gg = vec2(1.0, 1.0) / src_size;
    
    float rr = float(radius) / src_size.x;
    if(fragTexCoord.x - rr < 0.0 || fragTexCoord.x + rr > 1.0 || fragTexCoord.y - rr < 0.0 || fragTexCoord.y + rr > 1.0)
    {
        gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
        return;
    }
    
    int nCurIntensity = 0;
    for(  nY_O = -radius; nY_O <= radius; nY_O++ )
    {
        for(  nX_O = -radius; nX_O <= radius; nX_O++ )
        {
            c = texture2D(tex, fragTexCoord + vec2(nX_O, nY_O) * gg).rgb;
            nCurIntensity = int( (( c.r + c.g + c.b ) / 3.0)  * fIntensityLevels);
            if( nCurIntensity > INTENSITY_SIZE_1 ) {
                nCurIntensity = INTENSITY_SIZE_1;
            }
            nIntensityCount[nCurIntensity]++;
            nSum[nCurIntensity] += c;
        }
    }
    int nCurMax = 0;
    int nMaxIndex = 0;
    for( int nI = 0; nI < INTENSITY_SIZE; nI++ )
    {
        if( nIntensityCount[nI] > nCurMax )
        {
            nCurMax = nIntensityCount[nI];
            nMaxIndex = nI;
        }
    }
    gl_FragColor = vec4(nSum[nMaxIndex] / float(nCurMax), 1.0);
}
