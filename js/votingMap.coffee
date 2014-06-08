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
