use "ponytest"
use "collections"

use "easings"
use "linal"
use "ui"

actor Main is TestList
	new create(env: Env) => PonyTest(env, this)
	new make() => None

	fun tag tests(test: PonyTest) =>
		test(_TestLaba1)
    test(_TestLaba2)


primitive LabaTestShared
  fun advanceLabaAnimationOnNode(node:YogaNode ref) =>
    node.layout()
    while node.isAnimating() do
      node.animate(0.1)
      node.layout()
    end
    

class iso _TestLaba1 is UnitTest
	fun name(): String => "Test 1: basic ui functionality"

	fun apply(h: TestHelper) =>
    h.long_test(30_000_000_000)
    let result = """<div layout="width: 100; height: 100; top: 0; left: 0;" style="width: 100px; height: 100px; " ></div>"""
    let node = YogaNode.>size(100,100).>view( Clear )
    LabaTestShared.advanceLabaAnimationOnNode(node)
    h.complete(node.string() == result)
	

class iso _TestLaba2 is UnitTest
  fun name(): String => "Test 2: movement"

  fun apply(h: TestHelper) =>
    h.long_test(30_000_000_000)
    
    let tests:Array[(String,String)] = [
      ("<100", """<div layout="width: 100; height: 100; top: 0; left: -100;" style="width: 100px; height: 100px; left: -100px; " ></div>""")
      (">100", """<div layout="width: 100; height: 100; top: 0; left: 100;" style="width: 100px; height: 100px; left: 100px; " ></div>""")
      ("^100", """<div layout="width: 100; height: 100; top: -100; left: 0;" style="width: 100px; height: 100px; top: -100px; " ></div>""")
      ("v100", """<div layout="width: 100; height: 100; top: 100; left: 0;" style="width: 100px; height: 100px; top: 100px; " ></div>""")
      ("<100^100", """<div layout="width: 100; height: 100; top: -100; left: -100;" style="width: 100px; height: 100px; left: -100px; top: -100px; " ></div>""")
      ("<100|>100|^50|v50", """<div layout="width: 100; height: 100; top: 0; left: 0;" style="width: 100px; height: 100px; left: 0px; top: 0px; " ></div>""")
    ]
    
    for (labaString, compare) in tests.values() do
      let node = YogaNode.>laba(labaString).>size(100,100)
      LabaTestShared.advanceLabaAnimationOnNode(node)
      if node.string() != compare then
        node.print()
        h.complete(false)
        return
      end
    end
    
    h.complete(true)
    
    