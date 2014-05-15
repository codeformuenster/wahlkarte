var wahldaten;
var width = 960,
height = 500;

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
    parties = ["spd","cdu","die_linke","grune","piraten","fdp","dp","uwg_ms"].map(function(partyName) { return makeParty(d,partyName) });
    d.winner = _.max(parties, function(d) { return d.votes; }).party;
    d.winning_percentage = d[d.winner] / d.g_ltige_stimmen;
    return d;
  });
}
function wahlDataForBezirk(d) {
  wahlbezirk = d.properties.wahlbezirk;
  daten = _.find(wahldaten, function(d) { return d.column_1 === wahlbezirk; } )
  return daten;
}
function wahlData(d) {
  daten = wahlDataForBezirk(d);
  return daten.winner;
}
function percentageOpacity(d) {
  daten = wahlDataForBezirk(d);
  return daten.winning_percentage+0.3;
}
function tooltipHtml(d) {
  daten = wahlDataForBezirk(d);
  return "<p>"+d.properties.bezirkname+"</p><p>"+daten.winner.toUpperCase()+": "+Math.ceil(daten.winning_percentage*100)+"%</p>";
}
function tooltip(d) {
  d3.select("#tooltip").style("left", (d3.event.pageX + 14) + "px")
  .html(tooltipHtml(d))
  .style("opacity", 1)
  .style("top", (d3.event.pageY - 22) + "px");
}
d3.csv("results.csv", function(err, daten) {
  wahldaten = daten;
  nest();
  d3.json("wahlbezirke.geojson", function(err, data) {

    var svg = d3.select("body").append("svg")
    .attr("width", width)
    .attr("height", height);

    svg.selectAll("path")
    .data(data.features)
    .enter()
    .append("path")
    .attr("d",path)
    .attr("class", winner)
    .attr("opacity", percentageOpacity)
    .on("mouseover", tooltip);

  });
});
