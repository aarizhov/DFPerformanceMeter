//
//  DFPerformanceMeter.swift
//  DFPerformanceMeter
//
//  Copyright (c) 2009-2016 Artem Ryzhov ( http://devforfun.net/ )
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

import Foundation

public enum DFPerformanceSortBy {
    
    case `default`
    
    case none
    
    case ascending
    
    case descending
}

public struct DFPerformanceObj {
    var target: NSObject
    var selectorName: String
    var elapsedTime: Double
}

public class DFPerformanceMeter {
    
    private var functionsArray : [Int : DFPerformanceObj] = [:]
    private var sortedResultArray : [Int : DFPerformanceObj] = [:]
    
    weak var delegate: DFPerformanceMeterProtocol?
    
    init(delegage : DFPerformanceMeterProtocol) {
        self.delegate = delegage
    }
    
    func addFunction(selectorString : String, target : NSObject = NSNull()){
        var localTarget = target
        if(target is NSNull){
            localTarget = delegate as! NSObject
        }
        functionsArray[functionsArray.count] = DFPerformanceObj(target: localTarget, selectorName: selectorString, elapsedTime: 0)
    }
    
    func callAll(dispatchQoS : DispatchQoS, sortBy : DFPerformanceSortBy = DFPerformanceSortBy.default){
        if(functionsArray.count == 0) {
            delegate?.allFunctionsCompleted(performanceMeter: self, sortedResultArray: sortedResultArray)
            return
        }
        
        let syncQueue = DispatchQueue(label: "Performance Meter Queue",qos: dispatchQoS)
        syncQueue.async{
            let count = self.functionsArray.count
            for index in 0..<count {
                self.functionsArray[index]?.elapsedTime = self._callFunction(selectorName: (self.functionsArray[index]?.selectorName)!,
                                                                                target: (self.functionsArray[index]?.target)!)
            }
            
            self.sortedResultArray = [:]
            
            switch(sortBy)
            {
            case DFPerformanceSortBy.ascending:
                for (_,v) in (self.functionsArray.sorted {$0.value.elapsedTime < $1.value.elapsedTime}) {
                    self.sortedResultArray[self.sortedResultArray.count] = v
                }
                break
                
            case DFPerformanceSortBy.descending:
                for (_,v) in (self.functionsArray.sorted {$0.value.elapsedTime > $1.value.elapsedTime}) {
                    self.sortedResultArray[self.sortedResultArray.count] = v
                }
                break
                
            case DFPerformanceSortBy.none:
                self.sortedResultArray = self.functionsArray
                break
                
            default:
                self.sortedResultArray = self.functionsArray
                break
            }
            
            DispatchQueue.main.sync {
                self.delegate?.allFunctionsCompleted(performanceMeter: self, sortedResultArray: self.sortedResultArray)
            }
        }
    }
    
    private func _callFunction(selectorName : String, target : NSObject) -> Double {
        let selector = NSSelectorFromString(selectorName)
        if(!target.responds(to: selector)){
            return 0
        }
        let start = Date()
        target.perform(selector)
        let time = Date().timeIntervalSince(start)
        DispatchQueue.main.sync {
            self.delegate?.functionCompleted(performanceMeter: self, selector: selector, elapsedTime: time)
        }
        return time
    }
}

public protocol DFPerformanceMeterProtocol : NSObjectProtocol {
    func functionCompleted(performanceMeter : DFPerformanceMeter, selector: Selector, elapsedTime: Double)
    func allFunctionsCompleted(performanceMeter : DFPerformanceMeter, sortedResultArray : [Int : DFPerformanceObj])
}
