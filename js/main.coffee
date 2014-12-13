---
---
templates = []
geoData = {}
votingData = {}
votingMap = {}
subDistrictResults = ->
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
  data = geoData["subDistricts"]
  options = { width: 960, height: 600, zoomPercentage: 0.4 }
  votingMap = new VotingMap(data,daten,options)
  #mapKeys = { featureClassKey: "winner", districtKey: "wahlbezirk", dataDistrictKey: "wahlbezirk_nr", opacityKey: "winning_percentage" }
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
  votingMap.render("map")

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
              voteData = new Votes2014(erg, [], beznamen)
              voteData.setResultsPerDistrict(pnamen.length)
              #voteData.formatForDistricts()
              voteData.formatForSubDistricts()
              votingData["2014"]["districts"] = voteData.data
              districtResults()
            )
          }
        )
$ ->
  templates = parseTemplates(["tooltip","detail"])
  init()
