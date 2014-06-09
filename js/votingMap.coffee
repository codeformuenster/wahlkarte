---
---
class @VotingMap extends Map
  constructor: (@geojson, @data, @options) ->
    {@electionOpacityConstant, @zoomPercentage} = _.defaults(@options, electionOpacityConstant: 0.3, zoomPercentage: 0.7)
    @active = d3.select(null)
    super(@geojson, @options)

  setKeys: (keys) ->
    {@featureClassKey, @districtKey, @dataDistrictKey, @opacityKey} = _.defaults(keys, featureClassKey: "winner", districtKey: "district", dataDistrictKey: "district", opacityKey: "opacity")

  drawMap: (geojson, data) ->
    paths = @svg.selectAll("path")
      .data(geojson.features)
    paths.enter()
      .append("path")
    paths.attr('d', @path())
      .attr('class', @featureClass)
      .attr('opacity', @featureOpacity)
      .on('mouseover', @mouseover)
      .on('mouseout', @mouseout)
      .on('mousemove', @mousemove)
      .on('click', @mouseclick)
    paths.exit()
      .remove()

  update: (@geojson, @data) ->
    @centerMap() if @autoCenter
    @drawMap(@geojson)

  render: (@elementId) ->
    @createSvg()
    @centerMap() if @autoCenter
    @drawMap(@geojson)

  featureClass: (d) =>
    data = @dataForFeature(d)
    data[@featureClassKey]

  featureOpacity: (d) =>
    data = @dataForFeature(d)
    data[@opacityKey] + @electionOpacityConstant

  dataForFeature: (d) =>
    district = d.properties[@districtKey]
    dataDistrict = @dataDistrictKey
    _.find(@data, (d) -> d[dataDistrict] == district)

  tooltipHtml: (d) =>
    data = @dataForFeature(d)
    d.properties[@districtKey]

  mousemove: (d) =>
    d3.select("#tooltip").style("left", (d3.event.pageX + 14) + "px")
    .style("top", (d3.event.pageY - 22) + "px")

  mouseover: (d) =>
    element = d3.event.currentTarget
    d3.select("#tooltip")
    .html(@tooltipHtml(d))
    .style("opacity", 1)
    d3.select(element).classed("active",true)

  mouseout: (d) ->
    element = d3.event.currentTarget
    d3.select("#tooltip").style("opacity",0)
    d3.select(element).classed("active",false)

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
