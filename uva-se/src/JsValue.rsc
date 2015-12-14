module JsValue

import List;
import Set;
import String;

public data JsValue =
	JsString(str a)
  | JsNum(num b)
  | JsArray(list[JsValue] c)
  | JsMap(map[JsValue,JsValue] d);
  
public str toJSON(value v) = toJsCode(toJsValue(v));
 
public JsValue toJsValue(JsValue x) = x;
public JsValue toJsValue(str s) = JsString(s);
public JsValue toJsValue(num i) = JsNum(i);
public JsValue toJsValue(list[value] l) = JsArray([ toJsValue(i) | i <- l ]);
public JsValue toJsValue(set[value] s) = toJsValue(toList(s));
public JsValue toJsValue(map[value,value] m) = JsMap(( toJsValue("<k>") : toJsValue(m[k]) | k <- m ));
public JsValue toJsValue(tuple[value,value] t) = JsArray([ toJsValue(t[i]) | i <- [0..2] ]);
public JsValue toJsValue(tuple[value,value,value] t) = JsArray([ toJsValue(t[i]) | i <- [0..3] ]);
  
public str toJsCode(JsString(a)) = "\"<escape(a, (
	"\n" : "\\n",
	"\t" : "\\t",
	"\\" : "\\\\",
	"\"" : "\\\""
))>\"";

public str toJsCode(JsNum(b))
	= "<b>";

public str toJsCode(JsArray(c))
	= "[" + intercalate(",", [ toJsCode(e) | e <- c ]) + "]";

public str toJsCode(JsMap(d))
	= "{" + intercalate(",", [ toJsCode(e) + ":" + toJsCode(d[e]) | e <- d ]) + "}";