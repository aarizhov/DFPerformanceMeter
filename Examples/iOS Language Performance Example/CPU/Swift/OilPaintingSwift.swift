//
//  OilPaintingSwift.swift
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

import UIKit

class OilPaintingSwift: NSObject {
    
    
    class func filterOil(uiImage : UIImage, IntensityLevel : Int, radius : Int) -> UIImage {
        
        let INTENSITY_SIZE = 32
        let INTENSITY_SIZE_1 = (INTENSITY_SIZE - 1)
        //let INTENSITY_SIZE_SHIFT = 5
        
        let nIntensityCount =  UnsafeMutablePointer<Int>.allocate(capacity: INTENSITY_SIZE)
        let nSumR =  UnsafeMutablePointer<Int>.allocate(capacity: INTENSITY_SIZE)
        let nSumG =  UnsafeMutablePointer<Int>.allocate(capacity: INTENSITY_SIZE)
        let nSumB =  UnsafeMutablePointer<Int>.allocate(capacity: INTENSITY_SIZE)
        
        var cgImage: CGImage = uiImage.cgImage!
        
        let width = cgImage.width
        let height = cgImage.height
        let bitsPerComponent = cgImage.bitsPerComponent
        let numberOfComponents = (Int)(cgImage.bytesPerRow / width)
        var bytesPerRow = cgImage.bytesPerRow
        let colorSpace = cgImage.colorSpace
        
        let data: CFData = cgImage.dataProvider!.data!
        let dataLength: size_t = CFDataGetLength(data)
        let bytes = UnsafeMutablePointer<UInt8>.allocate(capacity: dataLength)
        let outPutBytes = UnsafeMutablePointer<UInt8>.allocate(capacity: dataLength)
        memset(outPutBytes, 255, dataLength)
        CFDataGetBytes(data, CFRangeMake(0, dataLength), bytes)
        
        let sizeOf256Int = MemoryLayout<Int>.size*INTENSITY_SIZE
        let height_radius = height - radius
        let width_radius = width - radius
        
        bytesPerRow = Int(ceil( Double(bytesPerRow) / 4.0 ) * 4.0);
        
        var offsetY = radius * bytesPerRow
        
        for nY in radius..<height_radius {
            
            for nX in radius..<width_radius {
                
                memset(nIntensityCount, 0, sizeOf256Int)
                memset(nSumR, 0, sizeOf256Int)
                memset(nSumG, 0, sizeOf256Int)
                memset(nSumB, 0, sizeOf256Int)
                
                for nY_O in -radius...radius {
                    for nX_O in -radius...radius {
                        
                        let offset = (nX+nX_O) * numberOfComponents + ( nY + nY_O ) * bytesPerRow
                        let nR = Int(bytes[offset]);
                        let nG = Int(bytes[offset + 1]);
                        let nB = Int(bytes[offset + 2]);
                        
                        //var nCurIntensity =  ((( nR + nG + nB ) / 3) * IntensityLevel) >> INTENSITY_SIZE_SHIFT//>> INTENSITY_SIZE_SHIFT
                        //( ( Double( nR + nG + nB ) / 3.0 ) * Double(IntensityLevel) ) / 255.0;
                        let g = (Float(nR + nG + nB) / 3.0)
                        var nCurIntensity = Int((g * Float(IntensityLevel)) / 255.0);
                        if( nCurIntensity > INTENSITY_SIZE_1 ){
                            //https://softwarebydefault.com/2013/06/29/oil-painting-cartoon-filter/
                            nCurIntensity = INTENSITY_SIZE_1
                        }
                        let i = Int(nCurIntensity);
                        nIntensityCount[i] += 1;
                        
                        nSumR[i] += nR;
                        nSumG[i] += nG;
                        nSumB[i] += nB;
                    }
                }
                
                var nCurMax : Int = Int(0);
                var nMaxIndex : Int = Int(0);
                for nI in 0..<INTENSITY_SIZE
                {
                    if( nIntensityCount[nI] > nCurMax )
                    {
                        nCurMax = nIntensityCount[nI];
                        nMaxIndex = nI;
                    }
                }
                
                let offset = nX * numberOfComponents + offsetY
                
                outPutBytes[offset ] = UInt8(nSumR[nMaxIndex] / nCurMax);
                outPutBytes[offset + 1] = UInt8(nSumG[nMaxIndex] / nCurMax);
                outPutBytes[offset + 2] = UInt8(nSumB[nMaxIndex] / nCurMax);
            }
            offsetY += bytesPerRow
        }
        
        free(bytes)
        
        let targetContext: CGContext = CGContext(data: outPutBytes, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace!, bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue).rawValue)!
        cgImage = targetContext.makeImage()!
        let image: UIImage = UIImage(cgImage: cgImage)
        
        free(outPutBytes)
        free(nIntensityCount)
        free(nSumR)
        free(nSumG)
        free(nSumB)
        
        return image
    }

}
