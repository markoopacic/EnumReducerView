# Counter

The Counter app consists of a single screen, which shows the following components:
- the current number
- "-" and "+" buttons to decrement and increment the current number, respectively
- an "Info" button which pulls up a sheet that informs the user whether the current number is even or odd
- a "Settings" button which opens up the settings sheet, in which the user can select the tint color

## `@WithSwitchCaseView` usage
Since both Info and Settings views are shown in a sheet on the Counter screen, the Counter.Sheet reducer can simply be a TCA enum Reducer.
This means we can apply the `@WithSwitchCaseView` macro directly to the Sheet reducer in `Counter.swift`:
```swift
extension Counter {
    @WithSwitchCaseView
    @Reducer
    enum Sheet {
        case info(Info)
        case settings(Settings)
    }
}
```
