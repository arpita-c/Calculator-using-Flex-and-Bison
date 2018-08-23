Implemented Calculator using Flex and Bison

Grammer Rules:
----------------
Prog -> main(){Stmts}
Stmts -> ε | Stmt; Stmts
Stmt -> float Id| Id = E | print Id |{Stmts}
E -> Float | Id | E - E | E * E| (-Float)
Float -> digit+ . digit+
