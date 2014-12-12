---
---
class @Map
  constructor: (@geojson, @options = {}) ->
    {@width, @height, @margin, @responsive, @autoCenter, @center, @scale, @translate, @zoomPercentage } = _.defaults(@options, width: 600, height: 300, margin: 60, responsive: false, autoCenter: true, center: [3,50], scale: 1, translate: [0,0], zoomPercentage: 0.7)
    @active = d3.select(null)
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
      .on("click", @mouseclick)
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

  mouseclick: (d) =>
    element = d3.event.currentTarget
    if @active.node() == element
      return @reset()
    @active.classed("active", false)
    @active = d3.select(element).classed("active", true)

    bounds = @path().bounds(d)
    dx = bounds[1][0] - bounds[0][0]
    dy = bounds[1][1] - bounds[0][1]
    x = (bounds[0][0] + bounds[1][0]) / 2
    y = (bounds[0][1] + bounds[1][1]) / 2
    scale = @zoomPercentage / Math.max(dx / @width, dy / @height)
    translate = [@width / 2 - scale * x, @height / 2 - scale * y]

    @svg.transition()
      .duration(750)
      .style("stroke-width", 1.5 / scale + "px")
      .attr("transform", "translate(" + translate + ")scale(" + scale + ")")
  reset: =>
    @active.classed("active", false)
    @active = d3.select(null)

    @svg.transition()
      .duration(750)
      .style("stroke-width", "1.5px")
      .attr("transform", "")
