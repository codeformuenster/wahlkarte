var wahlbezirke, bezirke, result, perBezirk;

function getWahlbezirkNr(name) {
  var bezirkArr = name.match(/^[0-9]{2}/)
  if(bezirkArr && bezirkArr.length > 0) {
    return bezirkArr[0];
  }else {
    var briefArr = name.match(/^[B][0-9]{3}/);
    if(briefArr && briefArr.length > 0) {
      var bezNr = name.split(" ")[0];
      bezirkArr = bezNr.match(/[0-9]{2}$/)
      if(bezirkArr && bezirkArr.length > 0) {
        return bezirkArr[0];
      }
    }
  }
}
function addToResult(resultForBezirk, resultForStimmbezirk) {
  for(var i=0;i<resultForBezirk.length;i++) {
    resultForBezirk[i] += parseInt(resultForStimmbezirk[i]);
  }
  return resultForBezirk;
}
function resultsForBezirk(wahlbezirk, resultBegin) {
  var daten = _.find(wahlbezirke, function(d) { return d.wahlbezirk_nr === wahlbezirk; } )
  resultForBezirk = result.slice(resultBegin, resultBegin+perBezirk);
  if(daten) {
    if(daten["result"].length == 0) {
      daten["result"] = resultForBezirk;
    }else {
      addToResult(daten["result"], resultForBezirk);
    }
  }
}
function formatResults(wahlResults) {
  var partyNames = ["cdu","spd","gruene","fdp","die_linke","uwg_ms","piraten","oedp","harryismus","afd"];
  var parties = [];
  for(var i=0;i<partyNames.length;i++) {
    var waehler = wahlResults[wahlResults.length-2];
    var votes = wahlResults[i];
    var percentage = votes * 100 / waehler;
    parties.push({party: partyNames[i], votes: votes, percentage: percentage });
  }
  return parties;
}
function appendDataToWahlbezirke() {
  wahlbezirke.map(function(bezirkResults) {
    var wahlResult = formatResults(bezirkResults["result"]);
    bezirkResults.winner = getWinner(wahlResult);
    bezirkResults.partyPercentages = wahlResult;
    var waehler = bezirkResults["result"][bezirkResults["result"].length-2];
    bezirkResults.winning_percentage = getWinningParty(wahlResult).votes / waehler;
  });
}
function parseLiveResults() {
  resultBegin = 0;
  jQuery.ajax({
    url: "http://pollfinder-codeformuenster.rhcloud.com/live-results", 
    dataType: "script",
    success: function(data, ts,jq) {
      bezirke = beznamen;
      result = erg;
      perBezirk = pnamen.length;
      d3.json("wahlbezirke.json", function(err, data) {
        wahlbezirke = data;
        for(var i=0;i<bezirke.length;i++) {
          var wahlbezirk = getWahlbezirkNr(bezirke[i]);
          resultsForBezirk(wahlbezirk,resultBegin);
          resultBegin = resultBegin+perBezirk;
        }
        appendDataToWahlbezirke(wahlbezirke);
        wahldaten = wahlbezirke;
        mapResults();
      });
    }
  });
}
