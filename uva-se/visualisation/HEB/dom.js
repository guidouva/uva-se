function emptyNode(node) {
  while(node[0][0].hasChildNodes()) node[0][0].removeChild(node[0][0].lastChild);
}

