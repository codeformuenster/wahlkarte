var wahldaten;
var width = 960,
height = 650;

partyNames = { "spd": "SPD", "cdu": "CDU", "die_linke": "Die Linke", "gruene": "Grüne", "piraten": "Piraten", "fdp": "FDP", "oedp": "ÖDP", "uwg_ms": "UWG Ms" }
function partyName(accronym) {
  return partyNames[accronym];
}
function makeParty(d,partyName) {
  return  { 
    party: partyName, 
    votes: parseInt(d[partyName]) || 0,
    percentage: (parseInt(d[partyName]) * 100 / parseInt(d.waehler_insgesamt) ) || 0
  };
}
function getWinner(parties) {
  return _.max(parties, function(d) { return d.votes; }).party;
}
function addData() {
  wahldaten.map(function(d) { 
    parties = ["spd","cdu","die_linke","gruene","piraten","fdp","oedp","uwg_ms"].map(function(partyName) { return makeParty(d,partyName) });
    d.winner = getWinner(parties);
    d.partyPercentages = parties;
    d.winning_percentage = (d[d.winner] / d.waehler_insgesamt);
    return d;
  });
}
function wahlDataForBezirk(d) {
  wahlbezirk = d.properties.wahlbezirk;
  daten = _.find(wahldaten, function(d) { return d.wahlbezirk_nr === wahlbezirk; } )
  return daten;
}
function winner(d) {
  daten = wahlDataForBezirk(d);
  return daten.winner;
}
function percentageOpacity(d) {
  daten = wahlDataForBezirk(d);
  return daten.winning_percentage+0.3;
}
function partyPercentagesHtml(parties) {
  partyList = _.sortBy(parties, function(party) { return party.percentage}).reverse();//.forEach(function(d) {
  context = { parties: partyList };
  html = templates["detail"](context);
  return html;
}
function addDetailData(d) {
  daten = wahlDataForBezirk(d);
  html = "<h2>"+d.properties.bezirkname+"</h2>"
  html += partyPercentagesHtml(daten.partyPercentages);

  d3.select("#detail")
  .style("display", "block")
  .html(html);
}
function tooltipHtml(d) {
  daten = wahlDataForBezirk(d);
  context = { bezirk: d.properties.bezirkname, partyName: partyName(daten.winner), percentage: Math.ceil(daten.winning_percentage*100) };
  html    = templates["tooltip"](context);
  return html;
}
function tooltip(d) {
  d3.select("#tooltip")
  .html(tooltipHtml(d))
  .style("opacity", 1);
}
function tooltipPosition(d) {
  d3.select("#tooltip").style("left", (d3.event.pageX + 14) + "px")
  .style("top", (d3.event.pageY - 22) + "px");

}
function highlight(d) {
  tooltip(d);
  d3.select(this).classed("active",true);
}
function unhighlight(d) {
  d3.select("#tooltip").style("opacity",0);
  d3.select(this).classed("active",false);
}
d3.csv("results.csv", function(err, daten) {
  if(window.outerWidth < width) {
    width = window.outerWidth;
  }
  projection = d3.geo.mercator()
  .scale(98000)
  .center([7.62536, 51.9620774])
  .translate([width / 2, height / 2]);
  var path = d3.geo.path().projection(projection);
  wahldaten = daten;
  templates = parseTemplates(["tooltip","detail"]);
  addData();
  d3.json("wahlbezirke.geojson", function(err, data) {

    var svg = d3.select("#map").append("svg")
    .attr("width", width)
    .attr("height", height)
    .call(d3.behavior.zoom()
    .on("zoom", redraw))
    .append("g");

    function redraw() {
      svg.attr("transform", "translate(" + d3.event.translate + ")scale(" + d3.event.scale + ")");
    }

    svg.selectAll("path")
    .data(data.features)
    .enter()
    .append("path")
    .attr("d",path)
    .attr("class", winner)
    .attr("opacity", percentageOpacity)
    .on("mouseover", highlight)
    .on("mouseout", unhighlight)
    .on("mousemove", tooltipPosition)
    .on("click",addDetailData);
  });
});
