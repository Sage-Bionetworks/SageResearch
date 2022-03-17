#   Migration Steps -> v5.0

- Moved all question steps included in this repository to [AssessmentModel](https://github.com/Sage-Bionetworks/AssessmentModelKMM.git).
- Moved all the results in [JsonModel](https://github.com/Sage-Bionetworks/JsonModel-Swift.git) to [AssessmentModel](https://github.com/Sage-Bionetworks/AssessmentModelKMM.git).
- Moved `BranchNodeResult` and `AssessmentResult` from this repository to [AssessmentModel](https://github.com/Sage-Bionetworks/AssessmentModelKMM.git).

The rsd-migration-tool can be used to search/replace *most* of the required code migration. For details
on how to use this tool, see MigrationNotes_v4.0.md

## Moved from [JsonModel](https://github.com/Sage-Bionetworks/JsonModel-Swift.git)

Add `import AssessmentModel` to files that reference `ResultData` and implementations that were previously defined in JsonModel.

## Find and replace text

Add `import AssessmentModel` and replace text:

```
    Keyword(library: .assessmentModel, find: "RSDCollectionResultObject", replace: "CollectionResultObject"),
    Keyword(library: .assessmentModel, find: "RSDResultObject", replace: "ResultObject"),
    Keyword(library: .assessmentModel, find: "TextInputValidator", replace: "TextEntryValidator"),
    Keyword(library: .assessmentModel, find: "RSDSize", replace: "ImageSize"),
    Keyword(library: .assessmentModel, find: "RSDCopyWithIdentifier", replace: "CopyWithIdentifier"),
    Keyword(library: .assessmentModel, find: "RSDFetchableImageThemeElementObject", replace: "FetchableImage"),
    Keyword(library: .assessmentModel, find: "RSDAnimatedImageThemeElementObject", replace: "AnimatedImage"),
```

Note: `CollectionResultObject` and `ResultObject` do not implement `RSDNavigationResult`.

## `Research.RSDStep` inherits from `AssessmentModel.Node`

If you inherit your steps from a step defined within SageResearch, the additional methods will be
handled for you. If not, there will be some additional methods and properties that you may need
to define. You may wish to consider using the protocol `RSDNodeStep` to implement missing requirements.

## `Research.RSDTask` inherits from `AssessmentModel.BranchNode`

If you inherit your tasks from a task defined within SageResearch, the additional methods will be 
handled for you. If not, there will be some additional methods and properties that you may need
to define. You may wish to consider using the protocol `RSDNode` and/or `RSDSageResearchTask` to 
implement missing requirements.

## `Research.RSDTaskResult` inherits from `AssessmentModel.BranchNodeResult`

Note: `RSDTaskResultObject` is included as a top-level result to maintain the serialization "type"
key that has been used on iOS of "task", while changing the top-level result "type" key to "assessment"
to match the existing Kotlin implementation.
