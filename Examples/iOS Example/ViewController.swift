//
//  ViewController.swift
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

import UIKit

class ViewController: UIViewController, UITableViewDataSource, DFPerformanceMeterProtocol {
    
    var resultArray : [Int : DFPerformanceObj] = [:]
    @IBOutlet var resultTableView : UITableView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let performance = DFPerformanceMeter(delegage: self)
        performance.addFunction(selectorString:"performanceTestFunction1")
        performance.addFunction(selectorString:"performanceTestFunction2")
        performance.addFunction(selectorString:"performanceTestFunction3")
        performance.addFunction(selectorString:"performanceTestFunction4", target: self) //target optional
        performance.addFunction(selectorString:"performanceTestFunction5")
        //use high priority DispatchQoS.userInteractive
        performance.callAll(dispatchQoS: DispatchQoS.userInteractive, sortBy : DFPerformanceSortBy.ascending)
    }
    
// MARK:- Test performance functions
    
    func performanceTestFunction1() {
        sleep(2)
    }
    
    func performanceTestFunction2() {
        sleep(1)
    }
    
    func performanceTestFunction3() {
        let nsArray = NSMutableArray()
        for _ in 0...100000 {
            nsArray.add("12345")
        }
    }
    
    func performanceTestFunction4() {
        var swiftArray = [String]()
        for _ in 0...100000 {
            swiftArray.append("12345")
        }
    }
    
    func performanceTestFunction5() {
        sleep(2)
    }
    
// MARK:- PerformanceMeterProtocol delegate methods
    
    func functionCompleted(performanceMeter : DFPerformanceMeter,
                           selector: Selector,
                           elapsedTime: Double){
        
        print("\(selector) - " + String(format:"%.3lf sec", elapsedTime))
        
    }
    
    func allFunctionsCompleted(performanceMeter : DFPerformanceMeter, sortedResultArray : [Int : DFPerformanceObj]){
        resultArray = sortedResultArray
        resultTableView?.reloadData()
        
        print("Performance test completed")
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
        cell?.textLabel?.text = String(format:"elapsedTime - %.3lf sec", (value?.elapsedTime)!)
        cell?.detailTextLabel?.text = value?.selectorName
        return cell!
    }
}

