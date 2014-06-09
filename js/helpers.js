function parseTemplates(ids) {
  var templates = {}
  ids.forEach(function(id) {
    var source   = d3.select("#"+id+"-template").html();
    var template =  _.template(source);
    templates[id] = template;
  });
  return templates;
}
