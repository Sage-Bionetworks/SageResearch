#  Release Notes 

## Version 3.0 - 3.3

The initial migration was split into three minor releases. See migration notes specific to each release for details.

## Version 3.4

This version changes the `RSDTaskResult.stepHistory` to include an instance 
of the step result for *each* display of that step so that there can be duplicates of the same step identifier in the
results.

In order to track the current path of a task that can navigate back, a new field has been added to the protocol:

```
/// The `BranchNodeResult` is the result created for a given level of navigation of a node tree.
public protocol BranchNodeResult : CollectionResult {

    /// The running history of the nodes that were traversed as a part of running an assessment.
    /// This will only include a subset (section) that is the path defined at this level of the
    /// overall assessment hierarchy.
    var stepHistory: [RSDResult] { get set }
    
    /// The path traversed by this branch. The `nodePath` is specific to the navigation implemented
    /// on iOS and is different from the `path` implementation in the Kotlin-native framework.
    var nodePath: [String] { get set }
}
```

The existing method extensions on `RSDTaskResult` handle adding and removing from the `nodePath` as a part
of the implementation of the `appendStepHistory()` and `removeStepHistory()` methods. The 
`RSDOrderedStepNavigator` protocol has been updated to use the `nodePath` (where implemented) in 
calculating backward navigation and progress.

Navigators that inherit from `RSDOrderedStepNavigator` should work correctly as-is. It is recommended that you
run unit tests on any custom navigators as well as familiarizing yourself with the `appendStepHistory` and 
`removeStepHistory` methods.

## Version 3.5

No migration should be required. 

This version introduces `SectionResultObject` and changes the protocol for
`RSDTaskResult` to *not* include the schema, revision, and task run UUID. In actual usage, the top-level task 
conforms to `RSDTaskRunResult` with a read/write `taskRunUUID` that is comparable to the Kotlin native 
implementation of an `AssessmentResultObject`.  This change allows for only including the task run UUID at the
top level of the task result JSON file.

## Version 3.6

Refactored `RSDResourceTransformer` to load the resource URL indirectly by using the `RSDResourceLoader`.

In most cases, no migration should be required. If you do *not* use `RSDDesignSystem` or `RSDAppDelegate`
and you *do* use `RSDResourceTransformer` then you will need to add the following line of code to your 
launch set up:

```
resourceLoader = ResourceLoader()
```

This will set up the resource loader to look in the appropriate bundles for resources that load from a URL.

## Version 3.7

Refactored `Localization` to *not* initially load the main and Research bundles. This separates out the platform 
context. 

If you do *not* use `RSDAppDelegate` then you will need to add the following line of code to your launch set up:

```
LocalizationBundle.registerDefaultBundlesIfNeeded()
```

## Version 3.8

Deprecated `RSDCollectionResult`. Use `CollectionResult` directly, instead.

## Version 3.9

Assorted minor fixes to better support using the newer protocols and objects from other frameworks.

## Version 3.10

Added `ResearchAudioRecorder` framework for recording audio and full scale decibel level.

## Version 3.11

No migration should be required.

The focus of this version is to move the code related to resources, file management, and bundles so that the 
Research framework can be built for other platforms that do not use some version of Apple OS.

* Moved `FileManager` references to use a protocol so that this framework could be used for platforms that do 
not support `FileManager`.

* Move platform context into the ResearchUI framework.

## Version 3.12

No migration should be required.

Added `AbstractTaskObject` that requires implementing the method `copy(with identifier: String)` and
does *not* implement it as a public final method.

## Version 3.13

No migration should be required.

Added `AbstractUIStepObject`.

## Version 3.14

Reorganized the SageResearch frameworks to allow using either the `Research.xcodeproj` structure *or* 
SwiftPM. Because SwiftPM does not allow for mixing Obj-c and Swift code in the same module, the Obj-c code
files were moved into a different framework. Therefore, if your application or dependent frameworks access 
these classes directly, then you will need to import the frameworks for these. Otherwise, no migration is required.

## Version 3.15

Added `UIActionType.navigation(.abandonAssessment)` and `RSDResultProcessor`. No migration required.

## Version 3.16

Fix code signing.

## Version 3.17

Do not embed frameworks. This means that if you are using the `Research.xcodeproj` to build dynamic 
frameworks rather than using the swift package, that you will *also* need to embed `Formatters.framework` 
and `ExceptionHandler.framework` in applications that reference this dylib.

## Version 3.18

Inherit `RSDResult` from `JsonModel.ResultData` and use the result serializer included in that module. This is
intended to allow for encoding results that do not conform to the `Codable` protocol. In most cases, no migration
will be needed, though the `import JsonModel` statement may need to be included in some code files.

## Version 4.0

See "MigrationNotes_v4.0.md". 

## Version 4.1

See "MigrationNotes_v4.1.md". 

## Version 4.4

Moved base implementation for `BranchNodeResult` and `AssessmentResult` into JsonModel.

## Version 4.6

Update Swift Package min target and all app min target OS to iOS 14 and macOS 11.

## Version 4.7

Deprecated unused code and added support for `JsonModel 1.6.0..<3.0.0`

## Version 4.9

Deprecated classes and structs used to support Bridge Exporter v1 and v2.
