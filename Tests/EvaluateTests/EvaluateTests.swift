import XCTest
import Evaluate

extension Expression.Token {
    
    func equals(_ number: Double) -> Bool {
        if case .number(let num) = self, num == number {
            return true
        }
        return false
    }
    
}

extension Sequence where Iterator.Element == Expression.Token {
    
    func expression_debug() -> String {
        var str = ""
        for token in self {
            switch token {
            case .number(let num):
                str.append(String(num))
            case .operation(let op):
                str.append(String.init(describing: op))
            }
        }
        return str
    }

    
}

class EvaluateTests: XCTestCase {
    
    func test1() {
        let expression = 1.op(.addition, 5)
            .op(.subtraction, 7)
            .op(.multiplication, 9)
            .op(.addition, 2)
            .expression()
        XCTAssertEqual(expression.rightmostNode.fullString(), "1+5-7×9+2")
        let result = expression.evaluate()
        XCTAssertEqual(result, -55)
    }
    
    func test2() {
        let expression = 7.op(.subtraction, 9)
            .op(.subtraction, 18)
            .op(.subtraction, 33)
            .op(.addition, 15)
            .op(.multiplication, 21)
            .op(.subtraction, 8)
            .op(.addition, 1)
            .op(.multiplication, 2)
            .expression()
        XCTAssertEqual(expression.rightmostNode.fullString(), "7-9-18-33+15×21-8+1×2")
        let result = expression.evaluate()
        XCTAssertEqual(result, 256)
    }
    
    func testParse() {
        let parser = ExpressionTokenParser.numbers.chained(with: .basicArithmetic)
        let tokens = UnparsedExpression("7-9 times 10 + 187").parse(parser: parser, processor: .noProcessing)
        XCTAssertEqual(tokens.expression_debug(), "7.0-9.0×10.0+187.0")
    }
    
    func testNumbersParserCollapse() {
        let parser = ExpressionTokenParser.numbers
        let tokens = UnparsedExpression("seventy-two").parse(parser: parser, processor: .collapsingNumbers)
        let awaited = [72].map(Expression.Token.number)
        XCTAssertEqual(tokens.expression_debug(), awaited.expression_debug())
    }
    
    func testTokensToExpression() throws {
        let string = "7-9*10 plus 15 minus 7 times 2"
        let parser = ExpressionTokenParser.numbers.chained(with: .basicArithmetic)
        let tokens = UnparsedExpression(string).parse(parser: parser, processor: .noProcessing)
        let expression = try Expression(tokens: tokens)
        XCTAssertEqual("7-9×10+15-7×2", expression.rightmostNode.fullString())
    }
    
    func testTokensToExpressionInvalidEvenTokens() {
        let string = "seven plus one two minus ten"
        XCTAssertThrowsError(try Expression(from: string, processor: .noProcessing)) { (error) in
            switch error {
            case Expression.Error.evenNumberOfTokens:
                break
            default:
                XCTFail()
            }
        }
    }
    
    func testTokensToExpressionInvalidNotOperation() {
        XCTAssertThrowsError(try Expression(from: "seven plus one two minus ten times", processor: .noProcessing)) { (error) in
            switch error {
            case Expression.Error.notOperation:
                break
            default:
                XCTFail()
            }
        }
    }
    
    func testTokensToExpressionInvalidNotNumber() {
        XCTAssertThrowsError(try Expression(from: "seven plus plus")) { (error) in
            switch error {
            case Expression.Error.notANumber:
                break
            default:
                XCTFail()
            }
        }
    }
    
    func testTokensToExpressionInvalidFirstNotNumber() {
        XCTAssertThrowsError(try Expression(from: "* seven minues")) { (error) in
            switch error {
            case Expression.Error.firstTokenIsNotANumber:
                break
            default:
                XCTFail()
            }
        }
    }
    
    func testTokensToExpressionInvalidNoOperations() {
        XCTAssertThrowsError(try Expression(from: "seven")) { (error) in
            switch error {
            case Expression.Error.noOperations:
                break
            default:
                XCTFail()
            }
        }
    }
    
    func testTokensToExpressionInvalidNoTokens() {
        XCTAssertThrowsError(try Expression(from: "")) { (error) in
            switch error {
            case Expression.Error.noTokens:
                break
            default:
                XCTFail()
            }
        }
    }
    
    func testEndToEnd1() throws {
        let expression = try Expression(from: "five minus seven + 17 * two times nine")
        print(expression.rightmostNode.string())
        let result = expression.evaluate()
        XCTAssertEqual(result, 304)
    }
    
    func testEndToEnd2() throws {
        let expression = try Expression(from: "nineteen - 19 + 4 * 18 - seven adding five times twelve plus 11 times 10")
        let result = expression.evaluate()
        XCTAssertEqual(result, 235)
    }
    
    func testEndToEnd3() throws {
        let expression = try Expression(from: "one+19*23-12+34*12-5*2 divided by 2*3-1 plus eighty six")
        let result = expression.evaluate()
        XCTAssertEqual(result, 904)
    }
    
    func testUsage() throws {
        let inputString = "One + 14 minus 2 times five"
        let expression = try Expression(from: inputString)
        let result = expression.evaluate() // 5
        XCTAssertEqual(result, 5)
    }
    
    func testUsageLong() throws {
        let input = UnparsedExpression("eleven minus 10 times fifty five / 4 + 4")
        let fullParser = ExpressionTokenParser.numbers.chained(with: .basicArithmetic)
        let tokens = input.parse(parser: fullParser, processor: .collapsingNumbers)
        let expression = try Expression(tokens: tokens)
        let result = expression.evaluate()
        XCTAssertEqual(result, -122.5)
    }
    
    static var allTests = [
        ("test1", test1),
        ("test2", test2),
    ]
    
}
