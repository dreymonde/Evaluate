import XCTest
import Evaluate

class EvaluateTests: XCTestCase {
    
    func test1() {
        let expression = 1.op(.addition, 5)
            .op(.subtraction, 7)
            .op(.multiplication, 9)
            .op(.addition, 2)
            .expression()
        XCTAssertEqual(expression.rightmostNode.string(), "1+5-7*9+2")
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
        XCTAssertEqual(expression.rightmostNode.string(), "7-9-18-33+15*21-8+1*2")
        let result = expression.evaluate()
        XCTAssertEqual(result, 256)
    }
    
    static var allTests = [
        ("test1", test1),
        ("test2", test2),
    ]
    
}
