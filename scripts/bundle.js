var fs = require('fs');

var source = "var jsonpath = (function() { var require=true,module=false; var exports = {};  ";

source += fs.readFileSync(__dirname+'/../lib/parser.js', 'utf8');
source += " exec: function exec(input, curPos) { parser.yy.myStack = new Array(); parser.yy.curpos = curPos; return parser.parse(input); } exports.exec = exec; return exports; }());";

console.log(source);


