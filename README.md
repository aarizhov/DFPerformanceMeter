# DFPerformanceMeter
Tool for measurement performance of code. Supported iOS from 10.0 and Swift from 4.0

## Usage

All functions will be run on the background thread in synchronized mode

Example App: iOS Language Performance Example
https://github.com/aarizhov/DFPerformanceMeter/tree/master/Examples/iOS%20Language%20Performance%20Example

### Example

```swift
let performanceTest = DFPerformanceMeter(delegage: self)
// you can use custom target.
performanceTest.addFunction(selectorString:"performanceTestFunction2", target: self)
// if target not set, will use delegate target
performanceTest.addFunction(selectorString:"performanceTestFunction1")

// use high priority for Thread - DispatchQoS.userInteractive
// 
performanceTest.callAll(dispatchQoS: DispatchQoS.userInteractive, sortBy : DFPerformanceSortBy.ascending)
```

### Delegate Example

```swift
func functionCompleted(performanceMeter : DFPerformanceMeter,
							   selector : Selector,
                            elapsedTime : Double){
    print("\(selector) - " + String(format:"%.3lf sec", elapsedTime))
}

// sortedResultArray has sorted result
func allFunctionsCompleted(performanceMeter : DFPerformanceMeter, sortedResultArray : [Int : DFPerformanceObj]){
	for i in 0..<sortedResultArray.count{
		let value = sortedResultArray[i]
		print(value?.target)
		print(value?.selectorName)
		print(value?.elapsedTime)
	}
	print("Performance test completed")
}
```

## License

DFPerformanceMeter is released under the MIT license. See LICENSE for details.
