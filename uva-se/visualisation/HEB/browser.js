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
      if (pair[0].text != pair[1].text && pairs[j][0].text == pair[0].text && pairs[j][1].text == pair[1].text) {
        pairs.splice(i, 1);
        i--;
        break;
      }
    }
  }

  var pairSize = function(p) {
    return Math.max(p[0].end - p[0].begin, p[1].end - p[1].begin);
  };

  var pairString = function(p) {
    return files[p[0].file] + "&nbsp;&nbsp;&nbsp;&nbsp;" + files[p[1].file];
  };

  pairs.sort(function(e1,e2) {
    if(pairSize(e2) !== pairSize(e1)) return pairSize(e2) - pairSize(e1);
    return pairString(e1) < pairString(e2);
  });

  var browserfieldUpdate = browserfield.selectAll("div").data(pairs);

  browserfieldUpdate.enter().append("div")
    .attr("class", "browserItem biInactive")
    .on("click", Browser._showPair(this));
  
  browserfieldUpdate
    .html(function(p) { return "[" + pairSize(p) + "]&nbsp;&nbsp;&nbsp;&nbsp;" + pairString(p); });
};

Browser._showPair = function(browser){ return function(pair) {
  d3.selectAll('.browserItem').attr('class','browserItem biInactive');
  d3.select(this).attr('class','browserItem biActive');
  browser._showClone(browser._comparisonLeft, pair[0]);
  browser._showClone(browser._comparisonRight, pair[1]);
}; };

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

function pairType(pair) {
  if (removeIndentation(removeComments(pair[0].text)) == removeIndentation(removeComments(pair[1].text))) {
    return 1;
  }

  return 2;
}

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

    if (line == "\n" || line == "\r\n" || line == "\r" || line == "") {
      lines.splice(i, 1);
      i--;
      continue
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
        blockComment: false,
        lineComment: false,
    };
    for (var i = 0, l = str.length; i < l; i++) {
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
            if (str[i+1] === '\n' || str[i+1] === '\r') {
                mode.lineComment = false;
            }
            str[i] = '';
            continue;
        }
 
        mode.doubleQuote = str[i] === '"';
        mode.singleQuote = str[i] === "'";
 
        if (str[i] === '/') {
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
        }
    }
    return str.join('').slice(2, -2);
}