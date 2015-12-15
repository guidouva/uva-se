var Browser = function(heb, container) {
  emptyNode(container);
  this._heb = heb;

  this._browserfield = container.append("div")
    .attr({'class':'browser','id':'browser'});
  this._comparisonLeft = container.append('div')
    .attr({'class':'comparison','id':'comparisonLeft'});
  this._comparisonRight = container.append('div')
    .attr({'class':'comparison','id':'comparisonRight'});

  [this._comparisonLeft,this._comparisonRight].forEach(
    function(comp) {
      throttleEvent('scroll', 'optimizedScroll', comp[0][0]);
      comp[0][0].addEventListener(
        'optimizedScroll',
        function(evt){
          var trgt = evt.target === this._comparisonLeft[0][0] ?
            this._comparisonRight[0][0]
            : this._comparisonLeft[0][0];

          trgt.scrollTop = evt.target.scrollTop;
          trgt.scrollLeft = evt.target.scrollLeft;
        }.bind(this)
      );
    }.bind(this)
  );
  

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
  
  for (var i = 0; i < pairs.length; i++) {
    var pair = [pairs[i][1], pairs[i][0]];

    for (var j = 0; j < pairs.length; j++) {
      if (pairs[j][0].text == pair[0].text && pairs[j][1].text == pair[1].text) {
        pairs.splice(i, 1);
        i--;
        break;
      }
    }
  }

  var browserfieldUpdate = browserfield.selectAll("div").data(pairs);

  browserfieldUpdate.enter().append("div")
    .attr("class", "browserItem")
    .on("click", this._showPair.bind(this));
  
  browserfieldUpdate
    .html(function(d, i) {
      var type = 2;

      if (removeIndentation(removeComments(d[0].text)) == removeIndentation(removeComments(d[1].text))) {
        type = 1;
      }

      return i + " type: " + type + " " + files[d[0].file] + " " + files[d[1].file];
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


function removeIndentation(str) {
  var lines = str.split("\n");

  for (var i = 0; i < lines.length; i++) {
    var line = lines[i];
    
    for (var j = 0; j < line.length; j++) {
      if (line[j] == ' ') {
        line = line.replace(" ", "");
        j--;
      }
      else if (line[j] == '\t') {
        line = line.replace("\t", "");
        j--; 
      }
    }

    lines[i] = line;
  }

  return lines.join("\n");
}

/* 
    This function is loosely based on the one found here:
    http://www.weanswer.it/blog/optimize-css-javascript-remove-comments-php/
*/
function removeComments(str) {
    str = ('__' + str + '__').split('');
    var mode = {
        singleQuote: false,
        doubleQuote: false,
        regex: false,
        blockComment: false,
        lineComment: false,
        condComp: false 
    };
    for (var i = 0, l = str.length; i < l; i++) {
 
        if (mode.regex) {
            if (str[i] === '/' && str[i-1] !== '\\') {
                mode.regex = false;
            }
            continue;
        }
 
        if (mode.singleQuote) {
            if (str[i] === "'" && str[i-1] !== '\\') {
                mode.singleQuote = false;
            }
            continue;
        }
 
        if (mode.doubleQuote) {
            if (str[i] === '"' && str[i-1] !== '\\') {
                mode.doubleQuote = false;
            }
            continue;
        }
 
        if (mode.blockComment) {
            if (str[i] === '*' && str[i+1] === '/') {
                str[i+1] = '';
                mode.blockComment = false;
            }
            str[i] = '';
            continue;
        }
 
        if (mode.lineComment) {
            if (str[i] == '\\' && (str[i+1] === 'n' || str[i+1] === 'r')) {
                mode.lineComment = false;
            }
            str[i] = '';
            continue;
        }
 
        if (mode.condComp) {
            if (str[i-2] === '@' && str[i-1] === '*' && str[i] === '/') {
                mode.condComp = false;
            }
            continue;
        }
 
        mode.doubleQuote = str[i] === '"';
        mode.singleQuote = str[i] === "'";
 
        if (str[i] === '/') {
 
            if (str[i+1] === '*' && str[i+2] === '@') {
                mode.condComp = true;
                continue;
            }
            if (str[i+1] === '*') {
                str[i] = '';
                mode.blockComment = true;
                continue;
            }
            if (str[i+1] === '/') {
                str[i] = '';
                mode.lineComment = true;
                continue;
            }
            mode.regex = true;
 
        }
 
    }
    return str.join('').slice(2, -2);
}