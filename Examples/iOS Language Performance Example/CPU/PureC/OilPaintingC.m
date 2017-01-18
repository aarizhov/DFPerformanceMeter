//
//  OilPaintingC.m
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

#import "OilPaintingC.h"

typedef unsigned char BYTE;

#define INTENSITY_SIZE 32
#define INTENSITY_SIZE_1 (INTENSITY_SIZE - 1)
#define INTENSITY_SIZE_SHIFT 5

@implementation OilPaintingC

+ (UIImage*)filterOilWarpperC:(UIImage*)sourceImage
                       radius:(int)radius
                    intensity:(int)intensity
{
    CGImageRef cgImage = sourceImage.CGImage;
    size_t width = CGImageGetWidth(cgImage);
    size_t height = CGImageGetHeight(cgImage);
    size_t bitsPerComponent = CGImageGetBitsPerComponent(cgImage);
    size_t bytesPerRow = CGImageGetBytesPerRow(cgImage);
    CGDataProviderRef dataProvider = CGImageGetDataProvider(cgImage);
    CFDataRef data = CGDataProviderCopyData(dataProvider);
    size_t dataLength = CFDataGetLength(data);
    const BYTE * bytes = CFDataGetBytePtr(data);
    BYTE * outPutBytes = malloc(dataLength);
    bytesPerRow = ceil( bytesPerRow / 4.0 ) * 4.0;
    filterOilC(bytes, radius, intensity, (int)width, (int)height, outPutBytes);

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef targetContext = CGBitmapContextCreate(outPutBytes, width, height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast);
    cgImage = CGBitmapContextCreateImage(targetContext);
    
    CFRelease(data);
    CGContextRelease(targetContext);
    CGColorSpaceRelease(colorSpace);
    free(outPutBytes);
    UIImage* image = [UIImage imageWithCGImage:cgImage];
    CFRelease(cgImage);
    return image;
}

void filterOilC(const BYTE* pbyDataIn_i,
                const int nRadius_i,
                const int fIntensityLevels_i,
                const int nWidth_i,
                const int nHeight_i,
                BYTE* pbyDataOut_o )
{
    int nIntensityCount[INTENSITY_SIZE];
    int nSumR[INTENSITY_SIZE];
    int nSumG[INTENSITY_SIZE];
    int nSumB[INTENSITY_SIZE];
    
    memset( pbyDataOut_o, 255, nWidth_i * nHeight_i * 4 );
    
    int nBytesInARow = ceil( nWidth_i * 4 / 4.0 ) * 4.0;
    
    int h1 = nHeight_i - nRadius_i;
    int w1 = nWidth_i - nRadius_i;
    int offsetY = nRadius_i * nBytesInARow;
    for( int nY = nRadius_i; nY < h1; nY++)
    {
        for( int nX = nRadius_i; nX < w1; nX++)
        {
            memset( nIntensityCount, 0, sizeof(nIntensityCount) );
            memset( nSumR, 0, sizeof(nSumR) );
            memset( nSumG, 0, sizeof(nSumG) );
            memset( nSumB, 0, sizeof(nSumB) );
            
            for( int nY_O = -nRadius_i; nY_O <= nRadius_i; nY_O++ )
            {
                for( int nX_O = -nRadius_i; nX_O <= nRadius_i; nX_O++ )
                {
                    int offset = ((nX+nX_O)<<2)  + ( nY + nY_O ) * nBytesInARow;
                    int nR = pbyDataIn_i[offset];
                    int nG = pbyDataIn_i[offset + 1];
                    int nB = pbyDataIn_i[offset + 2];
                    int nCurIntensity = (int)((((nR + nG + nB)) / 3.0) * fIntensityLevels_i) / 255.0;
                    if( nCurIntensity > INTENSITY_SIZE_1 ) {
                        nCurIntensity = INTENSITY_SIZE_1;
                    }
                    int i = nCurIntensity;
                    nIntensityCount[i]++;
                    nSumR[i] += nR;
                    nSumG[i] += nG;
                    nSumB[i] += nB;
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
            
            int offset = (nX << 2) + offsetY;
            pbyDataOut_o[offset ] = nSumR[nMaxIndex] / nCurMax;
            pbyDataOut_o[offset + 1] = nSumG[nMaxIndex] / nCurMax;
            pbyDataOut_o[offset + 2] = nSumB[nMaxIndex] / nCurMax;
        }
        
        offsetY += nBytesInARow;
    }
}


@end
