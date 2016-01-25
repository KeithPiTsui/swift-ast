/*
   Copyright 2016 Ryuichi Saito, LLC

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

import source
import ast

extension Parser {
    /*
    - [_] expression → try-operator/opt/ prefix-expression binary-expressions/opt/
    */
    func parseExpression() throws -> Expression {
        let result = parseExpression(currentToken, tokens: reversedTokens.map { $0.0 })

        guard let expression = result.expression else {
            throw ParserError.InternalError // TODO: better error handling
        }

        for _ in 0..<result.advancedBy {
            shiftToken()
        }

        return expression
    }

    func parseExpression(head: Token?, tokens: [Token]) -> (expression: Expression?, advancedBy: Int) {
        let parsePrimaryExpressionResult = parsePrimaryExpression(head, tokens: tokens)
        if let primaryExpression = parsePrimaryExpressionResult.primaryExpression {
            return (primaryExpression, parsePrimaryExpressionResult.advancedBy)
        }

        return (nil, 0)
    }
}