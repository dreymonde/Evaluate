# Evaluate

Converts a string to an expression and evaluate it.

## Usage

```swift
let inputString = "one + 14 minus 2 times five"
let expression = try Expression(from: inputString)
let result = expression.evaluate() // 5
```

Supported operations:

- Addition
- Subtraction
- Multiplication