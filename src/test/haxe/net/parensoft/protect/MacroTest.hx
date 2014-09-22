package net.parensoft.protect;

import buddy.*;
using buddy.Should;

import haxe.macro.Expr;

class MacroTest extends BuddySuite {

  public function new() {

    describe("handle macroed returns, loops, etc", {
      it("should correctly handle macroed return", {
        var control = [];

        var run = function() {
          Protect.protect({
            SupportMacros.retVal("ret");
          },
          {
            control.push("clean");
          });
          return "whatever";
        };

        control.push(run());

        control.should.containExactly(["clean", "ret"]);
      });


      it("should handle macroed continue", {
        var control = [];

        for (idx in 0...1) {
          Protect.protect({
            control.push("enter");

            SupportMacros.cont(1);
          }, {
            control.push("clean");
          });

          control.push("should not happen");
        }

        control.should.containExactly(["enter", "clean"]);
      });


      it("should handle macroed break", {
        var control = [];

        do {
          Protect.protect({
            control.push("enter");

            SupportMacros.brk(1);
          }, {
            control.push("clean");
          });

          control.push("wrong");
        } while(false);

        control.should.containExactly(["enter", "clean"]);
      });

    });

  }


}

