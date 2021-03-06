# author: Ethosa
import
  node,
  ../thirdparty/opengl,
  ../core/enums,
  ../core/input


type
  SceneObj* {.final.} = object of NodeObj
  ScenePtr* = ptr SceneObj


proc Scene*(name: string, variable: var SceneObj): ScenePtr =
  ## Creates a new Scene pointer.
  ##
  ## Arguments:
  ## - `name` is a scene name.
  ## - `variable` is a SceneObj object.
  nodepattern(SceneObj)
  variable.pausemode = PAUSE

proc Scene*(variable: var SceneObj): ScenePtr {.inline.} =
  ## Creates a new Scene pointer with default scene name "Scene".
  ##
  ## Arguments:
  ## - `variable` is a SceneObj object.
  Scene("Scene", variable)


method drawScene*(scene: ScenePtr, w, h: GLfloat, paused: bool) {.base.} =
  ## Draws scene
  ## This used in the window.nim.
  for child in scene.getChildIter():
    if paused and child.getPauseMode() != PROCESS:
      continue
    if child.visible:
      if not child.is_ready:
        child.ready()
        child.is_ready = true
      child.process()
      child.draw(w, h)
  for child in scene.getChildIter():
    if paused and child.getPauseMode() != PROCESS:
      continue
    if child.visible:
      child.draw2stage(w, h)

method duplicate*(self: ScenePtr, obj: var SceneObj): ScenePtr {.base.} =
  ## Duplicates Scene object and create a new Scene pointer.
  obj = self[]
  obj.addr

method enter*(scene: ScenePtr) {.base.} =
  ## This called when scene was changed.
  for child in scene.getChildIter():
    child.enter()
    child.is_ready = false

method exit*(scene: ScenePtr) {.base.} =
  ## This called when scene was changed.
  for child in scene.getChildIter():
    child.enter()
    child.is_ready = false

method handleScene*(scene: ScenePtr, event: InputEvent, mouse_on: var NodePtr, paused: bool) {.base.} =
  ## Handles user input. This called on any input.
  var childs = scene.getChildIter()
  for i in countdown(childs.len()-1, 0):
    if paused and childs[i].getPauseMode() != PROCESS:
      continue
    if childs[i].visible:
      childs[i].handle(event, mouse_on)
      childs[i].input(event)

method reAnchorScene*(scene: ScenePtr, w, h: GLfloat, paused: bool) {.base.} =
  ## Recalculates node positions.
  scene.rect_size.x = w
  scene.rect_size.y = h
  for child in scene.getChildIter():
    if paused and child.getPauseMode() != PROCESS:
      continue
    child.calcPositionAnchor()
