
cc.GLNode = cc.Node.extend
  draw: (ctx) ->
      this._super(ctx)

cc.GLNode.create = ->

  node = new cc.GLNode()
  node.init()
  return node

cc.GLNode.extend = cc.Class.extend

ShaderNode = cc.GLNode.extend(
  ctor: (vertexShader, framentShader) ->
    @_super()
    @init()
    if cc.sys.capabilities.opengl
      @width = 256
      @height = 256
      @anchorX = 0.5
      @anchorY = 0.5
      @shader = cc.GLProgram.create(vertexShader, framentShader)
      @shader.retain()
      @shader.addAttribute "aVertex", cc.VERTEX_ATTRIB_POSITION
      @shader.link()
      @shader.updateUniforms()
      program = @shader.getProgram()
      @uniformCenter = gl.getUniformLocation(program, "center")
      @uniformResolution = gl.getUniformLocation(program, "resolution")
      @initBuffers()
      @scheduleUpdate()
      @_time = 0
    return

  draw: ->

    winSize = cc.director.getWinSize()

    @shader.use()
    @shader.setUniformsForBuiltins()

    #
    # Uniforms
    #
    @shader.setUniformLocationF32 @uniformCenter, 100, 100
    @shader.setUniformLocationF32 @uniformResolution, 256, 256
    cc.glEnableVertexAttribs cc.VERTEX_ATTRIB_FLAG_POSITION

    # Draw fullscreen Square
    gl.bindBuffer gl.ARRAY_BUFFER, @squareVertexPositionBuffer
    gl.vertexAttribPointer cc.VERTEX_ATTRIB_POSITION, 2, gl.FLOAT, false, 0, 0
    gl.drawArrays gl.TRIANGLE_STRIP, 0, 4
    gl.bindBuffer gl.ARRAY_BUFFER, null
    return

  update: (dt) ->
    @_time += dt
    return

  initBuffers: ->

    #
    # Square
    #
    squareVertexPositionBuffer = @squareVertexPositionBuffer = gl.createBuffer()
    gl.bindBuffer gl.ARRAY_BUFFER, squareVertexPositionBuffer
    vertices = [
      256
      256
      0
      256
      256
      0
      0
      0
    ]
    gl.bufferData gl.ARRAY_BUFFER, new Float32Array(vertices), gl.STATIC_DRAW
    gl.bindBuffer gl.ARRAY_BUFFER, null
    return
)
