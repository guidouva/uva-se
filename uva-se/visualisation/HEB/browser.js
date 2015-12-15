var Browser = function(heb, container) {
  emptyNode(container);
  this._heb = heb;

  this._browserfield = container.append("div")
    .attr({'class':'browser','id':'browser'});
  this._comparisonLeft = container.append('div')
    .attr({'class':'comparison','id':'comparisonLeft'});
  this._comparisonRight = container.append('div')
    .attr({'class':'comparison','id':'comparisonRight'});

  heb.pushNodeClickListener(this._HEBNodeClickListener.bind(this));
  heb.pushLinkClickListener(this._HEBLinkClickListener.bind(this));
};

Browser.prototype._HEBNodeClickListener = function(node) {
  this._showFileBrowsers(node.value, node.clones.map(function(c){return c.value;}));
  console.log('node',node);
};

Browser.prototype._HEBLinkClickListener = function(link) {
  this._showFileBrowsers(link[0].value, [link[link.length-1].value]);
  console.log('link',link);
};

Browser.prototype._showFileBrowsers = function(fileId, otherFileIds) {
  var pairs = [];

  var clonedata = this._heb.data().clonedata;
  var files = this._heb.data().files;
  var browserfield = this._browserfield;
  emptyNode(browserfield);

  for (var i = 0; i < clonedata.length; i++) {
    if (clonedata[i][0].file == fileId && otherFileIds.indexOf(clonedata[i][1].file) != -1) {
      pairs.push(clonedata[i]);
    }
  }
  
  var barHeight = 20;
  var divisionHeight = 5;
  
  browserHeight = pairs.length * (barHeight + divisionHeight); 
  browserfield.attr("height", browserHeight)

  var browserfieldUpdate = browserfield.selectAll("div").data(pairs);

  browserfieldUpdate.enter().append("div")
    .attr("x", 0)
    .attr("y", function(d, i) {return (i * barHeight + i * divisionHeight);})
    .attr("width", "100%")
    .attr("height", barHeight)
    .attr("class", "browserItem")
    .on("click", this._showPair.bind(this));
  
  browserfieldUpdate
    .html(function(d, i) {
      return i + " " + files[d[0].file] + " " + files[d[1].file];
    });
};

Browser.prototype._showPair = function(pair) {
  this._showClone(this._comparisonLeft, pair[0]);
  this._showClone(this._comparisonRight, pair[1]);
};

Browser.prototype._showClone = function(field, clone) {
  field.data([clone])
    .html(function(d) {
      var text = d.text;
      text = addLineNumbers(text, d.begin);
      text = this._heb.data().files[d.file] + "\n\n" + text

      text = text.replace(/\n/g, "<br>").replace(/\t/g, "&nbsp;&nbsp;&nbsp;&nbsp;");
      return text;
    }.bind(this));
};

function addLineNumbers(text, beginLineNumber) {
  var lines = text.split("\n");

  for (var i = 0; i < lines.length; i++) {
    lines[i] = (beginLineNumber + i) + ") " + lines[i];
  }

  return lines.join("\n");
}

//d3.json("smallsql.json", function(error, data) {
//  showPair([data.clonedata[0][0], data.clonedata[0][1]], data.files);
//  showPair([data.clonedata[1][0], data.clonedata[1][1]], data.files);
//
//  showFileBrowsers(data.clonedata[0][0].file, [data.clonedata[0][1].file], data.files, data.clonedata);
//});
