---
---
class @VotingMap extends Map
  constructor: (@geojson, @data, @options) ->
    {@electionOpacityConstant} = _.defaults(@options, electionOpacityConstant: 0.3)
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
      .on('mouseclick', @mouseclick)
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

  mouseover: (d) =>
    d3.select("#tooltip").style("left", (d3.event.pageX + 14) + "px")
    .html(@tooltipHtml(d))
    .style("opacity", 1)
    .style("top", (d3.event.pageY - 22) + "px")
