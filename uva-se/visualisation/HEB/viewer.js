function Viewer(container) {
  emptyNode(container);
  this._container = container;

  this._filepickercontainer = container.append('div');
  this._hebcontainer = container.append('div');
  this._browsercontainer = container.append('div');
  this._heb = this._browser = null;

  this._filepicker = this._filepickercontainer.append('input')
    .attr('type','file')
    .on('change', this._readfile.bind(this));
}

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
  var diameter = 960,
      radius = diameter / 2,
      innerRadius = radius - 120,
      heb = new HEB(data, this._hebcontainer, diameter, radius, innerRadius),
      browser = new Browser(heb, this._browsercontainer);
  heb.redraw();
};
