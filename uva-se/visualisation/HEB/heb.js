function HEB(data, container, diameter, radius, innerRadius) {
  this._data = data;
  this._container = container;
  this._diameter = diameter;
  this._radius = radius;
  this._innerRadius = innerRadius;

  this._back = null;
  this._svg = null; 
  this._filters = [null];
  this._recalculate();

  this._nodeClickListeners = [];
  this._linkClickListeners = [];
}

HEB.prototype.data = function(){ return this._data; };

HEB.prototype.pushNodeClickListener = function(f) {
  this._nodeClickListeners.push(f);
};

HEB.prototype.pushLinkClickListener = function(f) {
  this._linkClickListeners.push(f);
};

HEB.prototype.pushFilter = function(filter) {
  this._filters.push(filter);
  this._recalculate();
};

HEB.prototype.popFilter = function() {
  if(this._filters.length === 1) return;
  this._filters.pop();
  this._recalculate();
};

HEB.prototype._recalculate = function() {
  this._cluster = d3.layout.cluster()
    .size([360, this._innerRadius])
    .sort(null);

  this._nodes = this._cluster.nodes(
    fileHierarchy(this._data, this._filters[this._filters.length-1])
  );
  this._links = fileClones(this._nodes);
};

HEB.prototype._nodeclicked = function(node) {
  this.pushFilter(node.clones.map(function(c){return [node,c];}));
  this.redraw();
  this._nodeClickListeners.forEach(function(f){ f(node); });
};

HEB.prototype._linkclicked = function(link){
  this.pushFilter([link]);
  this.redraw();
  this._linkClickListeners.forEach(function(f){ f(link); });
};

HEB.prototype.redraw = function() {
  emptyNode(this._container);
  this._container.attr('class','heb');

  
 
  this._bundle = d3.layout.bundle();

  this._line = d3.svg.line.radial()
    .interpolate("bundle")
    .tension(.85)
    .radius(function(d) { return d.y; })
    .angle(function(d) { return d.x / 180 * Math.PI; });

  this._svg = this._container.append("svg")
    .attr({"width":this._diameter,'height':this._diameter})
  .append("g")
    .attr("transform", "translate(" + this._radius + "," + this._radius + ")");

  if(this._filters.length > 1) {
    this._back = this._container.append('div')
      .attr('class','heb_back')
    .append("button")
      .text("Back")
      .on("click", function(){
        this.popFilter();
        this.redraw();
      }.bind(this));
  }

  this._svg.selectAll(".link")
    .data(this._bundle(this._links.map(function(link){
      return {source:link[0], target:link[link.length-1]};
    })))
  .enter().append("path")
    .attr({"id":linkid,'class':'link','d':this._line.bind(this)})
    .style({"stroke":this._stroke.bind(this),'cursor':'pointer'})
    .on("mouseover", this._mouseoverlink.bind(this))
    .on("mouseout", this._mouseouted.bind(this))
    .on("click", this._linkclicked.bind(this));

  this._svg.selectAll(".node")
    .data(this._nodes.filter(function(n) { return !n.children; }))
  .enter().append("g")
    .attr({"id":nodeid,'class':'node'})
    .attr("transform", function(d) { return "rotate(" + (d.x - 90) + ")translate(" + d.y + ")"; })
  .append("text")
    .attr("dx", function(d) { return d.x < 180 ? 8 : -8; })
    .attr("dy", ".31em")
    .attr("text-anchor", function(d) { return d.x < 180 ? "start" : "end"; })
    .attr("transform", function(d) { return d.x < 180 ? null : "rotate(180)"; })
    .style("cursor", "pointer")
    .text(function(d) { return d.key; })
    .on("mouseover", this._mouseovernode.bind(this))
    .on("mouseout", this._mouseouted.bind(this))
    .on("click", this._nodeclicked.bind(this));
};

HEB.prototype._opacifylink = function(link, opacity) {
  link.forEach(function(n){
    this._svg.select('#'+nodeid(n)).style("opacity", opacity);
  }.bind(this));
  this._svg.select('#'+linkid(link)).style("stroke-opacity", opacity);
};

HEB.prototype._stroke = function(link) {
  var src = link[0].value,
      dest = link[link.length-1].value,
      red = Math.max(0, Math.round(255.0 * Math.min(1.0, this._data.duplicationdata[""+src][""+dest]))),
      green = Math.max(0, Math.round(255.0 - red));
  return "rgb("+([red,green,0].join(','))+")";
};

HEB.prototype._fadelink = function(link) { this._opacifylink(link,0.1); };
HEB.prototype._showlink = function(link) { this._opacifylink(link,1); };

HEB.prototype._fadeall = function() {
  this._links.forEach(this._fadelink.bind(this));
};

HEB.prototype._showall = function() {
  this._links.forEach(this._showlink.bind(this));
};

HEB.prototype._mouseovernode = function(node) {
  this._fadeall();
  node.clones.forEach(function(c){ this._showlink([node,c]); }.bind(this));
};

HEB.prototype._mouseoverlink = function(link) {
  this._fadeall();
  this._showlink(link);
};

HEB.prototype._mouseouted = HEB.prototype._showall;

function linkid(nodes) {
  var parts = [nodes[0].value, nodes[nodes.length-1].value]; parts.sort();
  return "l"+parts.join("_");
}

function nodeid(node) {
  return "n"+node.value;
}

function fileHierarchy(data, filter) {
  var map = {};

  function find(path) {
    var node = map[path], i;
    if (!node) {
      node = map[path] = {name: path, children: [], clones: [], value: data.files.indexOf(path)};
      if (path.length) {
        node.parent = find(path.substring(0, i = path.lastIndexOf('/')));
        node.parent.children.push(node);
        node.key = path.substring(i + 1);
      }
    }
    return node; 
  }

  function unique(element, index, self) { return self.indexOf(element) === index; }

  if(filter instanceof Array)
    var filterids = filter.map(linkid); 

  data.clonedata.forEach(function(pair){ 
    var id1 = pair[0]['file'],
        id2 = pair[1]['file'];

    if(filter instanceof Array && filterids.indexOf(linkid([{value:id1},{value:id2}])) === -1)
      return;

    var n1 = find(data.files[id1]),
        n2 = find(data.files[id2]);

    n1.clones = n1.clones.concat([n2]).filter(unique);
    n2.clones = n2.clones.concat([n1]).filter(unique);
  });

  while(map[""].children.length === 1) map[""] = map[""].children[0];
  map[""].parent = null;

  return map[""];
}

function fileClones(nodes) {
  var links = [];

  nodes.forEach(function(node){
    links = links.concat(node.clones.map(function(clone){
      return [node, clone];
    }));
  });

  var linkids = links.map(linkid);

  return links.filter(function(link,index){
    return linkids.indexOf(linkid(link)) === index;
  });
}

