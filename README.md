# Evaluate

Converts a string to an expression and evaluates it.

## Usage

### Shortest way

```swift
let inputString = "one + 14 minus 2 times five"
let expression = try Expression(from: inputString)
let result = expression.evaluate() // 5
```

### Long one

```swift
let input = UnparsedExpression("eleven minus 10 times fifty five / 4 + 4")
let fullParser = ExpressionTokenParser.numbers.chained(with: .basicArithmetic)
let tokens = input.parse(parser: fullParser, processor: .collapsingNumbers)
let expression = try Expression(tokens: tokens)
let result = expression.evaluate() // -122.5
```

Supported operations:

- Addition
- Subtraction
- Multiplication
- Division