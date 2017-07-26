import XCTest
import Evaluate

extension Expression.Token {
    
    func equals(_ number: Int) -> Bool {
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
        XCTAssertEqual(expression.rightmostNode.string(), "1+5-7×9+2")
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
        XCTAssertEqual(expression.rightmostNode.string(), "7-9-18-33+15×21-8+1×2")
        let result = expression.evaluate()
        XCTAssertEqual(result, 256)
    }
    
    func testProcess() {
        let parser = NumberFormatter.expressionTokenParser.chained(with: BasicArithmetic.parser)
        let tokens = UnparsedExpression("7-9 times 10 + 187").parse(with: parser)
        print(tokens)
    }
    
    func testNumbersParser() {
        let parser = NumberFormatter.expressionTokenParser
        let tokens = UnparsedExpression("7 19 five seven one hundred seventy two").parse(with: parser)
        let awaited = [7, 19, 5, 7, 1, 70, 2].map(Expression.Token.number)
        XCTAssertEqual(tokens.expression_debug(), awaited.expression_debug())
    }
    
    func testTokensToExpression() throws {
        let string = "7-9*10 plus 15 minus 7 times 2"
        let parser = NumberFormatter.expressionTokenParser.chained(with: BasicArithmetic.parser)
        let tokens = UnparsedExpression(string).parse(with: parser)
        let expression = try Expression(tokens: tokens)
        XCTAssertEqual("7-9×10+15-7×2", expression.rightmostNode.string())
    }
    
    func testTokensToExpressionInvalidEvenTokens() {
        let string = "seven plus one two minus ten"
        XCTAssertThrowsError(try Expression(from: string)) { (error) in
            switch error {
            case Expression.Error.evenNumberOfTokens:
                break
            default:
                XCTFail()
            }
        }
    }
    
    func testTokensToExpressionInvalidNotOperation() {
        XCTAssertThrowsError(try Expression(from: "seven plus one two minus ten times")) { (error) in
            switch error {
            case Expression.Error.notOperation:
                break
            default:
                XCTFail()
            }
        }
    }
    
    func testUsage() throws {
        let inputString = "one + 14 minus 2 times five"
        let expression = try Expression(from: inputString)
        let result = expression.evaluate() // 5
        XCTAssertEqual(result, 5)
    }
    
    static var allTests = [
        ("test1", test1),
        ("test2", test2),
    ]
    
}
