/* The Labal notation is very minimalistic. Each command is a single, non numerical character (excluding +/-).
 * Each command can optionally be followed by a single numerical value, which makes sense only in the context of the command. For example,
 * "<120" would mean animate left 120 units.
 *
 * ~ delay
 *
 * w width
 * h height
 *
 * x move to x
 * y move to y
 *
 * < move left
 * > move right
 * ^ move up
 * v move down
 *
 * f alpha fade
 *
 * s uniform scale
 *
 * r roll
 * p pitch
 * a yaw
 *
 * d duration for current pipe
 *
 * D staggaered duration based on sibling/child index
 *
 * L loop (absolute) this segment (value is number of times to loop, -1 means loop infinitely)
 *
 * l loop (relative) this segment (value is number of times to loop, -1 means loop infinitely)
 *
 * e easing (we allow e# for shorthand or full easeInOutQuad)
 *
 * | pipe animations (chain)
 *
 * ! invert an action (instead of move left, its move to current position from the right)
 *
 * [] concurrent Laba animations ( example: [>d2][!fd1] )
 *
 */

use "ponytest"

use "ui"
use "easings"
use "linal"
use "utility"
use "stringext"

class LabaActionGroup
  let actions:Array[LabaAction]
  let duration:F32 = 1.0
  
  new create() =>
    actions = Array[LabaAction](32)
    
  fun ref push(action:LabaAction) =>
    actions.push(action)
    
  fun values():ArrayValues[LabaAction, this->Array[LabaAction]]^ =>
    actions.values()
    
  fun ref commit(target:LabaTarget) =>
    for action in actions.values() do
      action.update(target, 1.0)
    end
    
  fun ref update(target:LabaTarget, animationValue:F32):Bool =>
    for action in actions.values() do
      action.update(target, animationValue / duration)
    end
    target.syncToNode()
    (animationValue >= duration)
    
  fun ref toString(string:String ref) =>
    for action in actions.values() do
      action.toString(string)
    end
    string.push('|')
    
    
class LabaTarget
"""
  Stores and then simulates changes to target animatable properties over time
"""
  let target:YogaNode
  var _x:F32 = 0
  var _y:F32 = 0
  
  var x_sync:Bool = false
  var y_sync:Bool = false

  new create(target':YogaNode) =>
    target = target'
  
  fun ref getX():F32 => _x
  fun ref setX(x:F32) => _x = x; x_sync = true
  
  fun ref getY():F32 => _y
  fun ref setY(y:F32) => _y = y; y_sync = true
  
  fun ref syncFromNode() =>
    _x = target.getLeft()
    _y = target.getTop()
  
  fun ref syncToNode() =>
    if x_sync then target.left(_x); x_sync = false end
    if y_sync then target.top(_y); y_sync = false end



class Laba
"""
  Parses a Laba animation string into groups of Laba actions and effectuates the
  actual animation process (an outside entity calls animate with timing deltas)
"""
  
  let groups:Array[LabaActionGroup]
  let target:LabaTarget
  let animationString:String val
  
  var lazyInit:Bool = true
  var animationValue:F32 = 0.0
  
  
  new create(node:YogaNode, animationString':String val) =>
    animationString = animationString'
    target = LabaTarget(node)
    groups = Array[LabaActionGroup](32)
  
  fun ref print() =>
    var string:String ref = String(2048)
    string.push('[')
    for group in groups.values() do
      group.toString(string)
    end
    try string.pop()? end
    string.push(']')
    Log.println("%s", string)
  
  fun ref parse() =>
    // parse the laba string into a series of LabaActions which can be used to
    // make the animation happen. Note that we cannot do this in create(), because
    // the node as not yet been laid out. So we do it on the first call to animate.
    let parser = StringParser(animationString)
    var inverted:Bool = false
    var action:(LabaAction|None) = None
    var group = LabaActionGroup
    
    target.syncFromNode()
    
    groups.push(group)
    
    while true do
      try
        let c = parser.u8()?
        match c
        | '!' => inverted = true
        | '<' => action = LabaActionMoveX(c, target, parser, -1, inverted)
        | '>' => action = LabaActionMoveX(c, target, parser, 1, inverted)
        | '^' => action = LabaActionMoveY(c, target, parser, -1, inverted)
        | 'v' => action = LabaActionMoveY(c, target, parser, 1, inverted)
      
        | '|' =>
          group.commit(target)
          group = LabaActionGroup
          groups.push(group)
        end
      
        if action as LabaAction then
          group.push(action)
          inverted = false
        end
        action = None

      else
        break
      end
    end
    
    //print()
  
  fun ref animate(delta:F32 val):Bool =>
    
    if lazyInit then
      parse()
      lazyInit = false
    end
    
    animationValue = (animationValue + delta)
    
    try
      let group = groups(0)?
      
      if group.update(target, animationValue) then
        animationValue = animationValue - group.duration
        groups.delete(0)?
      end
      
    else
      Log.println("animate failed with %s", animationValue)
      return true
    end
    
    (groups.size() == 0)    
  


	
  
	


