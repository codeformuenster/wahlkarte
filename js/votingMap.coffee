---
---
class @VotingMap extends Map
  constructor: (@geojson, @data, @options) ->
    { @electionOpacityConstant } = _.defaults(@options, electionOpacityConstant: 0.3, zoomPercentage: 0.7)
    super(@geojson, @options)

  setKeys: (keys) ->
    {@featureClassKey, @districtKey, @dataDistrictKey, @opacityKey} = _.defaults(keys, featureClassKey: "winner", districtKey: "district", dataDistrictKey: "district", opacityKey: "opacity")

  drawMap: (geojson) ->
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
    super
    d3.select("#detail")
      .html(@detailResults(d))
      .style("display", "block")

  detailResults: (d) =>
    data = @dataForFeature(d)
