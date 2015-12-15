function emptyNode(node) {
  while(node[0][0].hasChildNodes()) node[0][0].removeChild(node[0][0].lastChild);
}

function throttleEvent(type, name, obj) {
  obj = obj || window;
  var running = false;
  var func = function() {
    if (running) { return; }
    running = true;
    requestAnimationFrame(function() {
      obj.dispatchEvent(new CustomEvent(name));
      running = false;
    });
  };
  obj.addEventListener(type, func);
}
