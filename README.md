# Scope guard expressions, autoclose variables and protected (try/finally) blocks in Haxe

This library introduces scope exit expressions, similar to what is [found](http://dlang.org/statement.html#ScopeGuardStatement)
in the D language, and autoclose variables, similar to C#'s ```using``` or Java's ```try```-with-resources, but with
a different syntax. The guarded scope is a plain block in which (but not in the scope guard expressions) control statements
(ie. ```return```, ```break``` and ```continue```) may be used; it's also allowed to throw exceptions, both from the guarded block
and from the scope guard expressions themselves.

A _primitive_ ```try```/```finally```-like syntax is available as well.

The library is based on expression macros, and these may be used explicitly. A build macro based syntax is also provided.

**This library is feature complete, no further development (apart from bugfixes) is planned.**

## Usage:

## Expression macros:

### Scope exits:

```
#!haxe
import net.parensoft.protect.Scope;


Scope.withExits({
    expr1;
    expr2;
    @scope(true) expr3;
    @scope expr4;
    expr5;
    });
```

The only parameter to ```Scope.withExits()``` must be a block expression.

Expressions annotated with ```@scope``` will not be executed right away, but queued for execution
upon leaving the scope instead. The ```@scope``` meta accepts the following arguments:

* ```true``` for expressions to be executed when the block exits normally, which includes ```return```,
  ```break``` and ```continue```
* ```false``` for expressions to be executed when the block exits with an exception
* ```null``` for expressions to be executed everytime the block exits

```@scope``` without arguments is equal to ```@scope(null)```.

The eligible expressions will be executed in reverse lexical order.

Scope exit expressions may not contain ```return```, ```break``` or ```continue``` statements.
If any throws an exception, the subsequent
ones **will not** be executed.

If uppercase ```@SCOPE``` is used instead of ```@scope```, exceptions from thus annotated expression
will be silently dropped.

```Scope.withExits()``` is implemented with ```Protect.protect()```, so all relevant limitations apply.

Any scope exit expression must be so declared directly inside a block, that is not in an ```if``` or whatever
else.

The value of the ```Scope.withExits()``` expression is the value of the last expression in the transformed
block, or, if the block ends with ```@scope``` expression, unspecified.

### Autoclose variables:

Autoclose variable is a special case of scope exit expression. If a variable(s) declaration is marked with
```closes```, when the scope is exited the object it references will have it's ```close()``` method
called. If several variables are declared in one ```var``` expression, declarations will be split and each
one will have its autoclose code generated. That is:
```
#!haxe
@closes var var1 = expr1,
            var2 = expr2;
```
is equal to:
```
#!haxe
var var1 = expr1;
@scope var1.close();
var var2 = expr2;
@scope var2.close();
```

It is possible to specify the name of the function to be called instead of the default ```close()```, that is
if a variable is annotated with ```@closes("aMethod")```, its ```aMethod()``` function will be called.

If ```@CLOSES``` is used instead of ```@closes```, any exceptions thrown by the call will be silently dropped.

### Primitive protected/cleanup expressions:

```
#!haxe
import net.parensoft.protect.Protect;


Protect.protect(
  PROT,
  CLEAN);
```

```CLEAN``` will **always** be executed when ```PROT``` exits. This includes normal completion or
an abrupt exit with an exception, or a ```return```, ```break``` or ```continue``` statement.


Any abrupt exit from the ```CLEAN``` expression will shadow the previous abrupt exit from the ```PROT```
expression, if any.

The value of the ```Protect.protect(PROT, CLEAN)``` expression is the value of the ```PROT``` expression
**if it completes**; otherwise it's unspecified (and unreachable as well).

## Build macros:

To use the build macros the class _must_ implement the ```net.parensoft.protect.ProtectSyntax```
interface or be annotated with ```@:build(net.parensoft.protect.ProtectSyntax.SyntaxBuilder.build())```

### Scope exit, autoclose variables:

No difference from the expression macro, the block doesn't need any metadata, if any annotated 
variables/expressions are found inside, the macro will work. That is, the code below will work
as expected:

```
class Example implements ProtectSyntax {


    {
        @closes var var1 = initExpr1();
        expr1;
        expr2;
        @scope(true) expr3;
        @scope expr4;
        expr5;
    }
```


### Basic unwind/protect:

```
#!haxe

@protect {
  protected: PROT,
  cleanup: CLEAN
}

```
As above, ```CLEAN``` is executed always whenever ```PROT``` exits.

Alternatively, **only** directly in a block, this somewhat hacky syntax is also available:
```
#!haxe
if(somecond) {
  expr0;
  @protect {
    expr1;
    expr2;
  }
  @clean {
    expr3;
    expr4;
  }
  expr5;
}
```

## Changes:

09/27/14: 0.4.0 Protected expressions (thus also blocks with scope exits) now have proper values

09/25/14: 0.3.1 Disallow return in scope exits, add new protect syntax

09/25/14: 0.3.0 Scope exits and autoclose variables

09/22/14: 0.2.0 Expand macros inside the protected block

09/08/14: 0.1.0 First version, support return, break, continue
inside the protected block.


### License: MIT

(C) Parensoft.NET 2014
