---
---
class @Map
  constructor: (@geojson, @options = {}) ->
    {@width, @height, @margin, @responsive, @autoCenter, @center, @scale, @translate} = _.defaults(@options, width: 600, height: 300, margin: 60, responsive: false, autoCenter: true, center: [3,50], scale: 1, translate: [0,0])
  createSvg: ->
    @svg = d3.select("##{@elementId}").append('svg')
    .attr('width', @width)
    .attr('height', @height)
    .append('g')
    .attr('transform', "translate(#{@margin}, 20)")

  drawMap: (geojson) ->
    paths = @svg.selectAll("path")
      .data(geojson.features)
    paths.enter()
      .append("path")
    paths.attr('d', @path())
      .attr('class', @featureClass)
    paths.exit()
      .remove()

  centerMap: ->
    b = @path().bounds(@geojson)
    @scale = .95 / Math.max((b[1][0] - b[0][0]) / @width, (b[1][1] - b[0][1]) / @height)
    @translate = [(@width - @scale * (b[1][0] + b[0][0])) / 2, (@height - @scale * (b[1][1] + b[0][1])) / 2]

  update: (@geojson) ->
    if @autoCenter
      @scale = 1
      @translate = [0,0]
      @centerMap()
    @drawMap(@geojson)

  render: (@elementId) ->
    @createSvg()
    @centerMap() if @autoCenter
    @drawMap(@geojson)

  projectionType: ->
    d3.geo.mercator()
  projection: ->
    if @autoCenter
      @projectionType()
        .scale(@scale)
        .translate(@translate)
    else
      @projectionType()
        .scale(@scale)
        .center(@center)

  path: ->
    d3.geo.path().projection(@projection())

  featureClass: (d) =>
    ""
