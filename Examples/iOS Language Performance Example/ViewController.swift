//
//  ViewController.swift
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

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DFPerformanceMeterProtocol {
    
    var resultArray : [Int : DFPerformanceObj] = [:]
    var imagesArray : [String : UIImage] = [:]
    
    @IBOutlet var glViewSwift : DFOilPaintingViewS?
    @IBOutlet var glView : DFOilPaintingView?
    
    var image : UIImage?
    var imageCI : CIImage?
    
    @IBOutlet var resultImageView : UIImageView?
    
    @IBOutlet var resultTableView : UITableView?
    @IBOutlet var sliderRadius : UISlider?
    @IBOutlet var sliderIntensityLevels : UISlider?
    
    @IBOutlet var radiusLabel : UILabel?
    @IBOutlet var radiusIntensityLabel : UILabel?
    
    @IBOutlet var activitiIndicatorView : UIActivityIndicatorView?
    @IBOutlet var infoLabel : UILabel?
    
    @IBOutlet var segmentedControl : UISegmentedControl?
    
    @IBOutlet var startTestButton : UIButton?
    
    var performance : DFPerformanceMeter?
    var testing : Bool = false
    var activityStarted = false
    
    var zeFilter: OilPaintingCoreImage?
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    func sliderDidChange(slider : UISlider){
        if(slider == sliderRadius){
            radiusLabel?.text = String(format: "Radius: %d", Int(slider.value))
        }
        else {
            radiusIntensityLabel?.text = String(format: "Intensity: %d", Int(slider.value))
        }
    }
    
    @IBAction func segmentedDidChange(segmented : UISegmentedControl){
        let array = ["cpuC","cpuSwift","coreImageLanguage","openGLPureC","openGLSwift"]
        resultImageView?.image = imagesArray[array[segmented.selectedSegmentIndex]]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resizeViews()
        zeFilter =
            {
                let filtere = OilPaintingCoreImage()
                filtere.inputRadius = CGFloat((sliderRadius?.value)!)
                filtere.inputIntensityLevels = CGFloat((sliderIntensityLevels?.value)!)
                return filtere
        }()
        image = UIImage(named: "texture0")
        glViewSwift?.initGL()
        glView?.initGL()
        infoLabel?.text = String(format: "%dx%d", Int((image?.size.width)!), Int((image?.size.height)!))//
        imageCI = CIImage (image: image!)
        
        //use high priority DispatchQoS.userInteractive
        performance = DFPerformanceMeter(delegage: self)
        performance?.addFunction(selectorString:"cpuC")
        performance?.addFunction(selectorString:"cpuSwift")
        performance?.addFunction(selectorString:"coreImageLanguage")
        performance?.addFunction(selectorString:"openGLPureC", target: self) //target optional
        performance?.addFunction(selectorString:"openGLSwift")
    }
    
    func setInfoWithTime(title : String, time: Double){
        infoLabel?.text = String(format: "%@, time=%.2f, %dx%d", title, time, Int((image?.size.width)!), Int((image?.size.height)!))
    }
    
    @IBAction func startTest(){
        if(!testing){
            startActivity()
            testing = true
            performance?.callAll(dispatchQoS: DispatchQoS.userInteractive, sortBy : DFPerformanceSortBy.ascending)
        }
    }
    
    @IBAction func cpuC(){
        let result = OilPaintingC.filterOilWarpperC(image, radius: Int32((sliderRadius?.value)!), intensity: Int32((sliderIntensityLevels?.value)!))
        imagesArray["cpuC"] = result;
    }
    
    @IBAction func cpuSwift(){
        let result = OilPaintingSwift.filterOil(uiImage: image!, IntensityLevel: Int((sliderIntensityLevels?.value)!),
                                                radius: Int((sliderRadius?.value)!))
        imagesArray["cpuSwift"] = result;
    }
    
    @IBAction func coreImageLanguage(){
        DispatchQueue.main.sync {
            zeFilter?.inputRadius = CGFloat((sliderRadius?.value)!)
            zeFilter?.inputIntensityLevels = CGFloat((sliderIntensityLevels?.value)!)
            zeFilter?.inputImage =  imageCI
            
            let ciContext = CIContext(options: nil)
            let filteredImageData = (zeFilter?.outputImage!)! as CIImage
            let filteredImageRef = ciContext.createCGImage(filteredImageData, from: filteredImageData.extent)
            //filteredImageData.image = UIImage(CGImage: filteredImageRef);
            let ciImage = UIImage(cgImage: filteredImageRef!)//UIImage(ciImage: filteredImageData)
            imagesArray["coreImageLanguage"] = ciImage;
        }
    }

    @IBAction func openGLPureC(){
        DispatchQueue.main.sync {
            glView?.fIntensityLevels = Int32((sliderIntensityLevels?.value)!);
            glView?.radius = Int32((sliderRadius?.value)!);
            glView?.render()
            let image = glView?.drawableToCGImage()
            imagesArray["openGLPureC"] = image
        }
    }
    
    @IBAction func openGLSwift(){
        DispatchQueue.main.sync {
            glViewSwift?.fIntensityLevels = GLint((sliderIntensityLevels?.value)!);
            glViewSwift?.radius = GLint((sliderRadius?.value)!);
            glViewSwift?.render()
            imagesArray["openGLSwift"] = glViewSwift?.drawableToCGImage()
        }
    }
    
    // MARK:- PerformanceMeterProtocol delegate methods
    
    func functionCompleted(performanceMeter : DFPerformanceMeter,
                           selector: Selector,
                           elapsedTime: Double){
        
        print("\(selector) - " + String(format:"%.3lf sec", elapsedTime))
    }
    
    func allFunctionsCompleted(performanceMeter : DFPerformanceMeter, sortedResultArray : [Int : DFPerformanceObj]){
        resultArray = sortedResultArray
        for index in 0..<1 {
            let value = sortedResultArray[index]
            resultImageView?.image = imagesArray[(value?.selectorName)!]
        }
        stopActivity()
        resultTableView?.reloadData()
        testing = false
        print("Performance test completed")
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let value = resultArray[indexPath.row]
        setInfoWithTime(title: (value?.selectorName)!, time: (value?.elapsedTime)!)
    }
    
    // MARK:- UITableViewDataSource delegate methods
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return resultArray.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let identifier = "UITableViewCell";
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        if(!(cell != nil)) {
            cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: identifier)
        }
        let value = resultArray[indexPath.row]
        cell?.textLabel?.text = String(format:"%@ - %.3lf sec", (value?.selectorName)!, (value?.elapsedTime)!)
        //cell?.detailTextLabel?.text = value?.selectorName
        return cell!
    }
    
    func resizeViews(){
        sliderRadius?.addTarget(self, action: #selector(sliderDidChange), for: .valueChanged)
        sliderIntensityLevels?.addTarget(self, action: #selector(sliderDidChange), for: .valueChanged)
        
        let width = view.frame.width * 0.75
        let frame = CGRect(x: (view.frame.width - width) / 2, y: 55+10+18, width: width, height: width)
        resultImageView?.frame = frame
        
        activitiIndicatorView?.frame = CGRect(x: 0, y: 0, width: 37, height: 37)
        activitiIndicatorView?.center = (resultImageView?.center)!
        activitiIndicatorView?.isHidden = true
        infoLabel?.frame = CGRect(x: 0, y: 14 + 38, width: view.frame.width, height: 30)
        
        sliderRadius?.frame = CGRect(x: Int((view.frame.width - 224) / 2), y: Int(width) + 15 + 65 + 9, width: 224, height: 30)
        sliderIntensityLevels?.frame = CGRect(x: Int((view.frame.width - 224) / 2), y: Int(width) + 15 + 35 + 65 + 9, width: 224, height: 30)
        
        var frameRaius = radiusLabel?.frame
        var intensityLabel = radiusIntensityLabel?.frame
        frameRaius?.origin.x = ((sliderRadius?.frame.origin.x)!-((sliderRadius?.frame.size.width)!/2) - 15)
        frameRaius?.origin.y = (sliderRadius?.frame.origin.y)!
        intensityLabel?.origin.x = ((sliderIntensityLevels?.frame.origin.x)!-((sliderIntensityLevels?.frame.size.width)!/2) - 15)
        intensityLabel?.origin.y = (sliderIntensityLevels?.frame.origin.y)!
        radiusLabel?.frame = frameRaius!
        radiusIntensityLabel?.frame = intensityLabel!
        
        if(UIDevice.current.userInterfaceIdiom == .phone){
            segmentedControl?.frame = CGRect(x: 4, y: 5, width: view.frame.width-8, height: 35)
            
            //segmentedControl
            sliderRadius?.frame = CGRect(x: Int((view.frame.width - 200) / 2) + 50, y: Int(width) + 15 + 65 + 9 + 22, width: 200, height: 30)
            sliderIntensityLevels?.frame = CGRect(x: Int((view.frame.width - 200) / 2) + 50, y: Int(width) + 15 + 35 + 65 + 9 + 22, width: 200, height: 30)
            
            infoLabel?.frame = CGRect(x: 0, y: 14 + 23, width: view.frame.width, height: 30)
            
            var frameRaius = radiusLabel?.frame
            var intensityLabel = radiusIntensityLabel?.frame
            frameRaius?.origin.x += 68
            frameRaius?.origin.y += 22
            intensityLabel?.origin.x += 68
            intensityLabel?.origin.y += 22
            radiusLabel?.frame = frameRaius!
            radiusIntensityLabel?.frame = intensityLabel!
            
            resultTableView?.frame = CGRect(x: 0, y: view.frame.height - 150, width: view.frame.width, height: 150)
            resultTableView?.rowHeight = 30
            let frame = CGRect(x: (view.frame.width - width) / 2, y: 55+5+4, width: width, height: width)
            resultImageView?.frame = frame
            startTestButton?.frame = CGRect(x: (view.frame.width - width) / 2, y: 66 + width, width: width, height: 35)
        }
        
    }
    
    func startActivity() {
        if(activityStarted) {
            return
        }
        
        activityStarted = true
        activitiIndicatorView?.isHidden = false
        self.view.bringSubview(toFront: self.activitiIndicatorView!)
        activitiIndicatorView?.startAnimating()
    }
    func stopActivity() {
        activitiIndicatorView?.stopAnimating()
        activitiIndicatorView?.isHidden = true
        activityStarted = false
    }
}
