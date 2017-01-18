//
//  OilPaintingCoreImage.swift
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
import CoreImage

class OilPaintingCoreImage: CIFilter {
    var inputImage: CIImage?
    var inputBlurImage: CIImage?
    var inputRadius: CGFloat = 5
    var inputIntensityLevels: CGFloat = 5
    static var INTENSITY_SIZE = "32"
    static var INTENSITY_SIZE_1 = "31"
    
    override var attributes: [String : Any]
    {
        return [
            kCIAttributeFilterDisplayName: "Image" as AnyObject,
            
            "inputImage": [kCIAttributeIdentity: 0,
                           kCIAttributeClass: "CIImage",
                           kCIAttributeDisplayName: "Image",
                           kCIAttributeType: kCIAttributeTypeImage],
            
            "inputRadius": [kCIAttributeIdentity: 0,
                            kCIAttributeClass: "NSNumber",
                            kCIAttributeDefault: 5,
                            kCIAttributeDisplayName: "Radius",
                            kCIAttributeMin: 0,
                            kCIAttributeSliderMin: 0,
                            kCIAttributeSliderMax: 20,
                            kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputIntensityLevels": [kCIAttributeIdentity: 0,
                                     kCIAttributeClass: "NSNumber",
                                     kCIAttributeDefault: 5,
                                     kCIAttributeDisplayName: "Intensity Levels",
                                     kCIAttributeMin: 0,
                                     kCIAttributeSliderMin: 0,
                                     kCIAttributeSliderMax: 32,
                                     kCIAttributeType: kCIAttributeTypeScalar]
        ]
    }
    
    override var outputImage: CIImage!
    {
        guard let
            inputImage = inputImage else
        {
            return nil
        }
        
        let extent = inputImage.extent
        
        let bb = effectPaintingOil?.apply(
            withExtent: inputImage.extent,
            roiCallback:
            {
                (index, rect) in
                return rect
            },
            arguments: [inputImage, inputRadius, inputIntensityLevels])
        
        return bb!.cropping(to: extent)
    }
    
    let effectPaintingOil = CIKernel(string:
        "kernel vec4 lumaVariableBlur(sampler image, float radius1, float fIntensityLevels) " +
            "{ " +
            "   int nIntensityCount["+INTENSITY_SIZE+"];" +
            "   vec3 nSum["+INTENSITY_SIZE+"];" +
            "   int i;" +
            "   for (i = 0; i < "+INTENSITY_SIZE+"; i ++) {" +
            "       nIntensityCount[i] = 0;" +
            "       nSum[i] = vec3(0.0,0.0,0.0);" +
            "   }" +
            "vec2 size = samplerSize(image);" +
            "vec2 scale = vec2(1.0, 1.0) / size;" +
            "vec2 d = destCoord(); " +
            "int radius = int(radius1);" +
            "if(int(d.x) - radius < 0 || int(d.x) + radius >= int(size.x) || int(d.y) - radius < 0 || int(d.y) + radius >= int(size.y)){" +
            "return vec4(0.0, 0.0, 0.0, 0.0);" +
            "}" +
            "int nY_O;" +
            "int nX_O;" +
            "vec3 c;" +
            "int nCurIntensity = 0;" +
            "for( nY_O = -radius; nY_O <= radius; nY_O++ ){" +
            "for(  nX_O = -radius; nX_O <= radius; nX_O++ ){" +
            "c = sample(image, samplerCoord(image) + (vec2(nX_O,nY_O) * scale)).rgb;" +
            "nCurIntensity = int( (( c.r + c.g + c.b ) / 3.0 ) * fIntensityLevels);" +
            "if( nCurIntensity > "+INTENSITY_SIZE_1+" ) {" +
            "nCurIntensity = "+INTENSITY_SIZE_1+";" +
            "}" +
            "nIntensityCount[nCurIntensity]++;" +
            "nSum[nCurIntensity] += c;" +
            "}" +
            "}" +
            "int nCurMax = 0;" +
            "int nMaxIndex = 0;" +
            "for( int nI = 0; nI < "+INTENSITY_SIZE+"; nI++ ){" +
            "if( nIntensityCount[nI] > nCurMax ){" +
            "nCurMax = nIntensityCount[nI];" +
            "nMaxIndex = nI;" +
            "}" +
            "}" +
            "return vec4(nSum[nMaxIndex] / float(nCurMax), 1.0);" +
        "} "
    )// samplerTransform(image,d + vec2(nX_O,nY_O) )
}

class FilterVendor: NSObject, CIFilterConstructor
{
    func filter(withName name: String) -> CIFilter?
    {
        switch name
        {
        case "OilPainting":
            return OilPaintingCoreImage()
            
        default:
            return nil
        }
    }
}
