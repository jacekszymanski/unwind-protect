package net.parensoft.protect;

import haxe.macro.Expr;
using haxe.macro.ExprTools;

@:autoBuild(net.parensoft.protect.ProtectSyntax.SyntaxBuilder.build())
interface ProtectSyntax {}

#if macro
class SyntaxBuilder {

  public static function build() {
    return haxe.macro.Context.getBuildFields().map(transformField);
  }

  static function transformField(field: Field) {
    switch (field.kind) {
      case FFun(fun): 
        transform(fun.expr);
      case FVar(_, e):
        transform(e);
      case FProp(_, _, _, e):
        transform(e);
      default: {}
    }

    return field;

  }

  static function transform(ex: Expr) 
    switch (ex) {
      case macro @protect { protected: $prot, cleanup: $clean }:
        transform(prot); transform(clean);
        ex.expr = (macro net.parensoft.protect.Protect.protect($prot, $clean)).expr;
      case { expr: EBlock(el) }: {
        ex.iter(transform);
        ex.expr = transformBlock(el).expr;
      }
      default:
        ex.iter(transform);
    }


  static function transformBlock(el: Array<Expr>) {
    var hasExits = false;

    var idx = 0;

    while(idx < el.length) {
      var ex = el[idx];
      switch (ex) {
        case macro @scope $x, macro @SCOPE $x, macro @closes $x, macro @CLOSES $x:
          hasExits = true;
        case macro @scope($v) $x, macro @SCOPE($v) $x,
             macro @closes($v) $x, macro @CLOSES($v) $x:
          hasExits = true;
        case macro @protect $prot:
        if (idx + 1 < el.length) switch(el[idx + 1]) {
          case macro @clean $clean:
            el[idx].expr = (macro {}).expr;
            el[idx + 1].expr = (macro net.parensoft.protect.Protect.protect($prot, $clean)).expr;
            idx++;
          default: {}
        }
        default: {}
      }
      idx++;
    }

    if (hasExits) return macro net.parensoft.protect.Scope.withExits($b{el});
    else return macro $b{el};
  }
}
#end
