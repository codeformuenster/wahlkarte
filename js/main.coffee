---
---
templates = []
geoData = {}
votingData = {}
votingMap = {}
partyResults = ->
  templates = parseTemplates(["tooltip","detail"])
  daten = votingData["2014"]["districts"]
  data = geoData["districts"]
  daten.map (d) ->
    parties = ["spd","cdu","die_linke","gruene","piraten","fdp","oedp","uwg_ms"].map((partyName) -> makeParty(d,partyName))
    d.winner = _.max(parties, (d) -> d.votes; ).party
    d.partyPercentages = parties
    d.winning_percentage = d[d.winner] / d.waehler_insgesamt
    d.wahlbezirk_nr = parseInt(d.wahlbezirk_nr)
    d
  options = { width: 960, height: 600, zoomPercentage: 0.4 }
  votingMap = new VotingMap(data,daten,options)
  mapKeys = { featureClassKey: "winner", districtKey: "bezirk_nr", dataDistrictKey: "wahlbezirk_nr", opacityKey: "winning_percentage" }
  votingMap.setKeys(mapKeys)
  votingMap.tooltipHtml = (d) ->
    data = @dataForFeature(d)
    context = { bezirk: d.properties.bezirk_nam, partyName: partyName(data.winner), percentage: Math.ceil(data.winning_percentage*100) }
    templates.tooltip(context)
  votingMap.detailResults = (d) ->
    data = @dataForFeature(d)
    partyList = _.sortBy(data.partyPercentages, (party) -> party.percentage).reverse()
    context = { parties: partyList, districtName: d.properties.bezirk_nam }
    templates.detail(context)
  #votingMap.featureClass = (d) -> "spd"
#      votingMap.featureOpacity = (d) =>
#        data = @dataForFeature(d)
#        data.partyPercentages.spd / d.waehler_insgesamt
#      votingMap.opacityKey = (d) -> "spd_percentage"
  votingMap.render("map")

districtResults = ->
  templates = parseTemplates(["tooltip","detail"]) unless templates
  daten = votingData["2014"]["districts"]
  data = geoData["districts"]
  options = { width: 960, height: 600, zoomPercentage: 0.4 }
  votingMap = new VotingMap(data,daten,options)
  mapKeys = { featureClassKey: "winner", districtKey: "wahlbezirk", dataDistrictKey: "wahlbezirk_nr", opacityKey: "winning_percentage" }
  votingMap.setKeys(mapKeys)
  votingMap.tooltipHtml = (d) ->
    data = @dataForFeature(d)
    context = { bezirk: d.properties.bezirk_nam, partyName: partyName(data.winner), percentage: Math.ceil(data.winning_percentage*100) }
    templates.tooltip(context)
  votingMap.detailResults = (d) ->
    data = @dataForFeature(d)
    partyList = _.sortBy(data.partyPercentages, (party) -> party.percentage).reverse()
    context = { parties: partyList, districtName: d.properties.bezirk_nam }
    templates.detail(context)
  votingMap.render("map")

subDistrictData = ->
  voteData = new Votes2014(votingData["2014"]["erg"], [], votingData["2014"]["beznamen"])
  voteData.setResultsPerDistrict(votingData["2014"]["resultsPerDistrict"])
  voteData.formatForSubDistricts()
  votingData["2014"]["districts"] = voteData.data
  voteData.data

districtData = ->
  voteData = new Votes2014(votingData["2014"]["erg"], votingData["2014"]["raw"], votingData["2014"]["beznamen"])
  voteData.setResultsPerDistrict(votingData["2014"]["resultsPerDistrict"])
  voteData.formatForDistricts()
  votingData["2014"]["districts"] = voteData.data
  voteData.data

updateVoteMapForSubDistricts = ->
  mapKeys = { featureClassKey: "winner", districtKey: "bezirk_nr", dataDistrictKey: "wahlbezirk_nr", opacityKey: "winning_percentage" }
  geojson = geoData["subDistricts"]
  data = subDistrictData()
  updatVotingMapWithDistrictsAndData(geojson, data, mapKeys)

updateVoteMapForDistricts = ->
  mapKeys = { featureClassKey: "winner", districtKey: "wahlbezirk", dataDistrictKey: "wahlbezirk_nr", opacityKey: "winning_percentage" }
  geojson = geoData["districts"]
  data = districtData()
  updatVotingMapWithDistrictsAndData(geojson, data, mapKeys)

updatVotingMapWithDistrictsAndData = (districts, data, mapKeys) ->
  votingMap.setKeys(mapKeys)
  votingMap.update(districts, data)

init = ->
  d3.json "wahlbezirke.geojson", (err, data) ->
    geoData["districts"] = data
    d3.json "stimmbezirke.geojson", (err, data) ->
      geoData["subDistricts"] = data
      d3.csv "results.csv", (err, daten) ->
        votingData["2009"] = daten
        votingData["2014"] = {}
        jQuery.ajax({
          url: "http://pollfinder-codeformuenster.rhcloud.com/live-results",
          dataType: "script",
          success: (data, ts,jq) ->
            d3.json("wahlbezirke.json", (err, data) ->
              votingData["2014"]["raw"] = data
              votingData["2014"]["erg"] = erg
              votingData["2014"]["beznamen"] = beznamen
              votingData["2014"]["resultsPerDistrict"] = pnamen.length
              districtData()
              districtResults()
            )
          }
        )
$ ->
  templates = parseTemplates(["tooltip","detail"])
  init()
  $('#subDistricts').click (e) ->
    updateVoteMapForSubDistricts()
  $('#districts').click (e) ->
    updateVoteMapForDistricts()
