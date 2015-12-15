function Viewer(container) {
  emptyNode(container);
  this._container = container;

  this._hebcontainer = container.append('div');
  this._browsercontainer = container.append('div');
  this._heb = this._browser = null;

  postProcessCloneData(CLONEDATA);
  this._reinit(CLONEDATA);
}

function postProcessCloneData(clonedata) {
  removeCommonPrefix(clonedata.files);
}

function removeCommonPrefix(files) {
  var cpl = commonPrefixLength(files);
  for(var i = 0; cpl > 0 && i < files.length; ++i) {
    files[i] = files[i].substr(cpl);
  }
}

function commonPrefixLength(strs) {
  if(strs.length === 0) return 0;

  var prefix = strs[0];
  for(var i = 1; i < strs.length; ++i) {
    var len = 0;
    while(len < Math.min(prefix.length, strs[i].length)
          && prefix[len] === strs[i][len]) ++len;
    prefix = prefix.substr(0, len);
  }

  return prefix.length;
};

Viewer.prototype._readfile = function() {
  var file = this._filepicker[0][0].files[0];
  if(!file instanceof File) return;

  var reader = new FileReader();
  reader.onload = this._readfileComplete.bind(this);
  reader.readAsText(file);
};

Viewer.prototype._readfileComplete = function(evt) {
  try {
    var json = JSON.parse(evt.target.result);
  } catch(e) {
    alert(e);
  }

  this._reinit(json);
};

Viewer.prototype._reinit = function(data) {
  var diameter = 900,
      radius = diameter / 2,
      innerRadius = radius - 200,
      heb = new HEB(data, this._hebcontainer, diameter, radius, innerRadius),
      browser = new Browser(heb, this._browsercontainer);
  heb.redraw();
  window.setTimeout(
    function(){window.scrollTop = 0;},
    20
  );
};
