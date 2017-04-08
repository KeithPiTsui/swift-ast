/*
   Copyright 2016 Ryuichi Saito, LLC and the Yanagiba project contributors

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/

import XCTest

@testable import AST

class ParserSuperclassExpressionTests: XCTestCase {
  func testSuperclassMethodExpression() {
    parseExpressionAndTest("super.foo", "super.foo", testClosure: { expr in
      guard let superExpr = expr as? SuperclassExpression,
        case .method(let name) = superExpr.kind,
        name == "foo" else {
        XCTFail("Failed in getting a superclass expression")
        return
      }
    })
  }

  func testSuperclassSubscriptExpression() {
    parseExpressionAndTest("super[0]", "super[0]", testClosure: { expr in
      guard let superExpr = expr as? SuperclassExpression,
        case .subscript(let exprs) = superExpr.kind,
        exprs.count == 1,
        let literalExpr = exprs[0] as? LiteralExpression,
        case .integer(let i, _) = literalExpr.kind,
        i == 0 else {
        XCTFail("Failed in getting a superclass expression")
        return
      }
    })
  }

  func testSuperclassSubscriptExprWithExprList() {
    parseExpressionAndTest("super[0, 1, 5]", "super[0, 1, 5]", testClosure: { expr in
      guard let superExpr = expr as? SuperclassExpression,
        case .subscript(let exprs) = superExpr.kind,
        exprs.count == 3 else {
        XCTFail("Failed in getting a superclass expression")
        return
      }

      XCTAssertTrue(exprs[0] is LiteralExpression)
      XCTAssertTrue(exprs[1] is LiteralExpression)
      XCTAssertTrue(exprs[2] is LiteralExpression)
    })
  }

  func testSuperclassSubscriptExprWithVariables() {
    parseExpressionAndTest("super [ foo,   0, bar,1, 5 ] ", "super[foo, 0, bar, 1, 5]", testClosure: { expr in
      guard let superExpr = expr as? SuperclassExpression,
        case .subscript(let exprs) = superExpr.kind,
        exprs.count == 5 else {
        XCTFail("Failed in getting a superclass expression")
        return
      }

      XCTAssertTrue(exprs[0] is IdentifierExpression)
      XCTAssertTrue(exprs[1] is LiteralExpression)
      XCTAssertTrue(exprs[2] is IdentifierExpression)
      XCTAssertTrue(exprs[3] is LiteralExpression)
      XCTAssertTrue(exprs[4] is LiteralExpression)
    })
  }

  func testSuperclassInitializerExpression() {
    parseExpressionAndTest("super.init", "super.init", testClosure: { expr in
      guard let superExpr = expr as? SuperclassExpression,
        case .initializer = superExpr.kind else {
        XCTFail("Failed in getting a superclass expression")
        return
      }
    })
  }

  static var allTests = [
    ("testSuperclassMethodExpression", testSuperclassMethodExpression),
    ("testSuperclassSubscriptExpression", testSuperclassSubscriptExpression),
    ("testSuperclassSubscriptExprWithExprList", testSuperclassSubscriptExprWithExprList),
    ("testSuperclassSubscriptExprWithVariables", testSuperclassSubscriptExprWithVariables),
    ("testSuperclassInitializerExpression", testSuperclassInitializerExpression),
  ]
}
