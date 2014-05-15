var wahldaten;
var width = 960,
height = 500;

var partyNames = ["spd","cdu","die_linke","grune","piraten","fdp","dp","uwg_ms"]

var projection = d3.geo.mercator()
.scale(70000)
.center([7.627530,51.966588 ])
.translate([width / 2, height / 2]);

var path = d3.geo.path().projection(projection);

function makeParty(d,partyName) {
  return  { party: partyName, votes: parseInt(d[partyName]) };
}

function nest() {
  wahldaten.map(function(d) { 
    parties = partyNames.map(function(partyName) { return makeParty(d,partyName) });
    d.winner = _.max(parties, function(d) { return d.votes; }).party;
    d.winning_percentage = d[d.winner] / d.g_ltige_stimmen;
    return d;
  });
}

function wahlData(d) {
  wahlbezirk = d.properties.wahlbezirk;
  daten = _.find(wahldaten, function(d) { return d.column_1 === wahlbezirk; } )
  return daten.winner;
}

function anteil(partyName) {
  return function (d) {
    wahlbezirk = d.properties.wahlbezirk;
    daten = _.find(wahldaten, function(d) { return d.column_1 === wahlbezirk; } )
    return daten[partyName]/d3.sum(partyNames.map(function(name) { return daten[name]; }))
  }
}

d3.csv("results.csv", function(err, daten) {
  wahldaten = daten;
  nest();

  var svg = d3.select("body").append("svg")
       .attr("width", width)
       .attr("height", height);

  partyNames.forEach(function(partyName) {
    d3.json("wahlbezirke.geojson", function(err, data) {
      svg.selectAll("path."+partyName)
      .data(data.features)
      .enter()
      .append("path")
      .attr("d",path)
      .attr("class", partyName)
      .attr("opacity", anteil(partyName));
    });
  });
});
