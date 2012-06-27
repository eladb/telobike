var telobike = (function(global, undefined){
  var DEBUG         = false,
      pkgdefs       = {},
      pkgmap        = {},
      global        = {},
      lib           = undefined,
      nativeRequire = typeof require != 'undefined' && require,
      ties, locals;
  lib = (function(exports){
  exports.path = (function(exports){ 
    // Copyright Joyent, Inc. and other Node contributors.
// Minimized fork of NodeJS' path module, based on its an early version.
exports.join = function () {
  return exports.normalize(Array.prototype.join.call(arguments, "/"));
};
exports.normalizeArray = function (parts, keepBlanks) {
  var directories = [], prev;
  for (var i = 0, l = parts.length - 1; i <= l; i++) {
    var directory = parts[i];
    // if it's blank, but it's not the first thing, and not the last thing, skip it.
    if (directory === "" && i !== 0 && i !== l && !keepBlanks) continue;
    // if it's a dot, and there was some previous dir already, then skip it.
    if (directory === "." && prev !== undefined) continue;
    if (
      directory === ".."
      && directories.length
      && prev !== ".."
      && prev !== "."
      && prev !== undefined
      && (prev !== "" || keepBlanks)
    ) {
      directories.pop();
      prev = directories.slice(-1)[0]
    } else {
      if (prev === ".") directories.pop();
      directories.push(directory);
      prev = directory;
    }
  }
  return directories;
};
exports.normalize = function (path, keepBlanks) {
  return exports.normalizeArray(path.split("/"), keepBlanks).join("/");
};
exports.dirname = function (path) {
  return path && path.substr(0, path.lastIndexOf("/")) || ".";
};
    return exports;
  })({});
    global.process = exports.process = (function(exports){
    /**
 * This is module's purpose is to partly emulate NodeJS' process object on web browsers. It's not an alternative 
 * and/or implementation of the "process" object.
 */
function Buffer(size){
  if (!(this instanceof Buffer)) return new Buffer(size);
  this.content = '';
};
Buffer.prototype.isBuffer = function isBuffer(){
  return true;
};
Buffer.prototype.write = function write(string){
  this.content += string;
};
global.Buffer = exports.Buffer = Buffer;
function Stream(writable, readable){
  if (!(this instanceof Stream)) return new Stream(writable, readable);
  Buffer.call(this);
  this.emulation = true;
  this.readable = readable;
  this.writable = writable;
  this.type = 'file';
};
Stream.prototype = Buffer(0,0);
exports.Stream = Stream;
function notImplemented(){
  throw new Error('Not Implemented.');
}
exports.binding = (function(){
  
  var table = {
    'buffer':{ 'Buffer':Buffer, 'SlowBuffer':Buffer }
  };
  return function binding(bname){
    if(!table.hasOwnProperty(bname)){
      throw new Error('No such module.');
    }
    return table[bname];
  };
})();
exports.argv = ['onejs'];
exports.env = {};
exports.nextTick = function nextTick(fn){
  return setTimeout(fn, 0);
};
exports.stderr = Stream(true, false);
exports.stdin = Stream(false, true);
exports.stdout = Stream(true, false);
exports.version = '1.6.0';
exports.versions = {};
/**
 * void definitions
 */
exports.pid = 
exports.uptime = 0;
exports.arch = 
exports.execPath = 
exports.installPrefix = 
exports.platform =
exports.title = '';
exports.chdir = 
exports.cwd = 
exports.exit = 
exports.getgid = 
exports.setgid =
exports.getuid =
exports.setuid =
exports.memoryUsage =
exports.on = 
exports.umask = notImplemented;
    return exports;
  })({});
  return exports;
})({});
  function findPkg(uri){
    return pkgmap[uri];
  }
  function findModule(workingModule, uri){
    var module = undefined,
        moduleId = lib.path.join(lib.path.dirname(workingModule.id), uri).replace(/\.js$/, ''),
        moduleIndexId = lib.path.join(moduleId, 'index'),
        pkg = workingModule.pkg;
    var i = pkg.modules.length,
        id;
    while(i-->0){
      id = pkg.modules[i].id;
      if(id==moduleId || id == moduleIndexId){
        module = pkg.modules[i];
        break;
      }
    }
    return module;
  }
  function genRequire(callingModule){
    return function require(uri){
      var module,
          pkg;
      if(/^\./.test(uri)){
        module = findModule(callingModule, uri);
      } else if ( ties && ties.hasOwnProperty( uri ) ) {
        return ties[ uri ];
      } else {
        pkg = findPkg(uri);
        if(!pkg && nativeRequire){
          try {
            pkg = nativeRequire(uri);
          } catch (nativeRequireError) {}
          if(pkg) return pkg;
        }
        if(!pkg){
          throw new Error('Cannot find module "'+uri+'" @[module: '+callingModule.id+' package: '+callingModule.pkg.name+']');
        }
        module = pkg.index;
      }
      if(!module){
        throw new Error('Cannot find module "'+uri+'" @[module: '+callingModule.id+' package: '+callingModule.pkg.name+']');
      }
      module.parent = callingModule;
      return module.call();
    };
  }
  function module(parentId, wrapper){
    var parent = pkgdefs[parentId],
        mod = wrapper(parent),
        cached = false;
    mod.exports = {};
    mod.require = genRequire(mod);
    mod.call = function(){
            if(cached) {
        return mod.exports;
      }
      cached = true;
      global.require = mod.require;
      mod.wrapper(mod, mod.exports, global, global.Buffer,global.process, global.require);
      return mod.exports;
    };
    if(parent.mainModuleId == mod.id){
      parent.index = mod;
      parent.parents.length == 0 && ( locals.main = mod.call );
    }
    parent.modules.push(mod);
  }
  function pkg(/* [ parentId ...], wrapper */){
    var wrapper = arguments[ arguments.length - 1 ],
        parents = Array.prototype.slice.call(arguments, 0, arguments.length - 1),
        ctx = wrapper(parents);
    if(pkgdefs.hasOwnProperty(ctx.id)){
      throw new Error('Package#'+ctx.id+' "' + ctx.name + '" has duplication of itself.');
    }
    pkgdefs[ctx.id] = ctx;
    pkgmap[ctx.name] = ctx;
    arguments.length == 1 && ( pkgmap['main'] = ctx );
  }
  function mainRequire(uri){
    return pkgmap.main.index.require(uri);
  }
  function stderr(){
    return lib.process.stderr.content;
  }
  function stdin(){
    return lib.process.stdin.content;
  }
  function stdout(){
    return lib.process.stdout.content;
  }
  return (locals = {
    'lib'        : lib,
    'findPkg'    : findPkg,
    'findModule' : findModule,
    'name'       : 'telobike',
    'module'     : module,
    'pkg'        : pkg,
    'packages'   : pkgmap,
    'stderr'     : stderr,
    'stdin'      : stdin,
    'stdout'     : stdout,
    'require'    : mainRequire
});
})(this);
telobike.pkg(function(parents){
  return {
    'id':1,
    'name':'telobike',
    'main':undefined,
    'mainModuleId':'app',
    'modules':[],
    'parents':parents
  };
});
telobike.module(1, function(/* parent */){
  return {
    'id': 'lib/data',
    'pkg': arguments[0],
    'wrapper': function(module, exports, global, Buffer,process, require, undefined){
      module.exports = [{"available_bike":"6","available_spaces":"14","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.1438,"location":"32.1438,34.7926","longitude":34.7926,"name":"חוף הצוק הצפוני מלון מנדרין","sid":"101","address":"חוף הצוק הצפוני מלון מנדרין","name_en":"North Cliff Beach","address_en":"חוף הצוק הצפוני מלון מנדרין"},{"available_bike":"5","available_spaces":"15","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.1403,"location":"32.1403,34.791","longitude":34.791,"name":"חוף הצוק הדרומי סאמט שמעון","sid":"102","address":"חוף הצוק הדרומי סאמט שמעון","name_en":"South Cliff Beach","address_en":"חוף הצוק הדרומי סאמט שמעון"},{"available_bike":"9","available_spaces":"11","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.1298,"location":"32.1298,34.7923","longitude":34.7923,"name":"אזורי חן  גרינברג 26","sid":"104","address":"אזורי חן  גרינברג 26","name_en":"Azorei Chen – 26 Greenberg St.","address_en":"Azorei Chen – 26 Greenberg St."},{"available_bike":"6","available_spaces":"15","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.1247,"location":"32.1247,34.8018","longitude":34.8018,"name":"מרכז שוסטר אחימאיר 18","sid":"105","address":"מרכז שוסטר אחימאיר 18","name_en":"18 Aba Ahimeir St.- Shuster Center ","address_en":"18 Aba Ahimeir St.- Shuster Center "},{"available_bike":"6","available_spaces":"14","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.1204,"location":"32.1204,34.7924","longitude":34.7924,"name":"רודנסקי מרכז מסחרי","sid":"106","address":"רודנסקי 3 - מרכז מסחרי","name_en":"Rudensky-Ramat Aviv 3","address_en":"רודנסקי 3 - מרכז מסחרי"},{"available_bike":"1","available_spaces":"19","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.1214,"location":"32.1214,34.7832","longitude":34.7832,"name":"חוף תל ברוך","sid":"107","address":"ארצי יצחק 34 -חוף תל ברוך -צמוד לתחנת שאיבה בגינה צפונית לכניסה ראשית","name_en":"Tel Baruch beach","address_en":"ארצי יצחק 34 -חוף תל ברוך -צמוד לתחנת שאיבה בגינה צפונית לכניסה ראשית"},{"available_bike":"4","available_spaces":"16","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.1141,"location":"32.1141,34.7916","longitude":34.7916,"name":"פרלוק 4","sid":"108","address":"פרלוק 4","name_en":"4 Perluk St.","address_en":"4 Perluk St."},{"available_bike":"1","available_spaces":"19","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.1177,"location":"32.1177,34.798","longitude":34.798,"name":"טאגור מרכז מסחרי","sid":"109","address":"טאגור מרכז מסחרי","name_en":"Tagore St. – commercial center","address_en":"Tagore St. – commercial center"},{"available_bike":"5","available_spaces":"15","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.1103,"location":"32.1103,34.7905","longitude":34.7905,"name":"שיכון למד האוזנר 5","sid":"110","address":"שיכון למד האוזנר 5","name_en":"Shikun Lamed – 5 Hausner St.","address_en":"Shikun Lamed – 5 Hausner St."},{"available_bike":"3","available_spaces":"17","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.1129,"location":"32.1129,34.7968","longitude":34.7968,"name":"איינשטיין 41","sid":"111","address":"איינשטיין 41 קניון רמת אביב","name_en":"41 Einstein St.","address_en":"איינשטיין 41 קניון רמת אביב"},{"available_bike":"8","available_spaces":"16","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.1133,"location":"32.1133,34.8008","longitude":34.8008,"name":"אוניברסיטה איינשטיין 78","sid":"112","address":"איינשטיין 78","name_en":"78 Einstein St.","address_en":"איינשטיין 78"},{"available_bike":"17","available_spaces":"3","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.1077,"location":"32.1077,34.7981","longitude":34.7981,"name":"ברודצקי פינת שד אבנר","sid":"113","address":"ברודצקי פינת שד אבנר","name_en":"Brodetzky St./ Mayer Ebner","address_en":"Brodetzky St./ Mayer Ebner"},{"available_bike":"4","available_spaces":"16","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.1048,"location":"32.1048,34.7891","longitude":34.7891,"name":"לוי אשכול 26","sid":"114","address":" לוי אשכול 26 פינת אפטר -   במדרכה ד. מזרחית בין העצים","name_en":"26 Levi Eshkol St. - Sde Dov Airport","address_en":" לוי אשכול 26 פינת אפטר -   במדרכה ד. מזרחית בין העצים"},{"available_bike":"1","available_spaces":"17","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.1022,"location":"32.1022,34.7854","longitude":34.7854,"name":"שי עגנון 59","sid":"116","address":"שי עגנון 59 פינת ישראל גלילי -בגינה מזרחית לכניסה לשכונה","name_en":"59 Agnon St./ Israel Galili St.","address_en":"שי עגנון 59 פינת ישראל גלילי -בגינה מזרחית לכניסה לשכונה"},{"available_bike":"8","available_spaces":"12","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.1017,"location":"32.1017,34.7929","longitude":34.7929,"name":"דרך נמיר - סמינר הקיבוצים","sid":"117","address":" סמינר הקיבוצים - דרך נמיר מימין  לרחוב ויטלה בחורשה ","name_en":"Derekh Namir - Seminar Ha-Kibutsim","address_en":" סמינר הקיבוצים - דרך נמיר מימין  לרחוב ויטלה בחורשה "},{"available_bike":"5","available_spaces":"15","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.1259,"location":"32.1259,34.7985","longitude":34.7985,"name":"שלמה בן יוסף 24","sid":"118","address":"שלמה בן יוסף 24","name_en":"24  Shlomo Ben-Yosef St.","address_en":"24  Shlomo Ben-Yosef St."},{"available_bike":"6","available_spaces":"14","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.1156,"location":"32.1156,34.7886","longitude":34.7886,"name":"הגוש הגדול אמיר גלבע 17","sid":"120","address":"אמיר גלבוע 17","name_en":"17 Amir Gilboa st.","address_en":"אמיר גלבוע 17"},{"available_bike":"9","available_spaces":"10","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.1207,"location":"32.1207,34.7993","longitude":34.7993,"name":"רב אשי 11 מרכז מסחרי","sid":"121","address":"רב אשי בגינה מול בית 11","name_en":"11 Rav Ashi st.","address_en":"רב אשי בגינה מול בית 11"},{"available_bike":"0","available_spaces":"20","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.1107,"location":"32.1107,34.8036","longitude":34.8036,"name":"אוניברסיטה שער 4","sid":"122","address":"אוניברסיטה שער 4","name_en":"University - Gate 4","address_en":"אוניברסיטה שער 4"},{"available_bike":"2","available_spaces":"18","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.1263,"location":"32.1263,34.8278","longitude":34.8278,"name":"המשתלה ברוד מקס 12","sid":"201","address":"המשתלה ברוד מקס 12","name_en":"The Plant Nursery – 12 Max Brod St.","address_en":"The Plant Nursery – 12 Max Brod St."},{"available_bike":"9","available_spaces":"11","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.1223,"location":"32.1223,34.8179","longitude":34.8179,"name":"אהרון בקר 15","sid":"202","address":"אהרון בקר 15","name_en":"15 Beker Aharon St.","address_en":"15 Beker Aharon St."},{"available_bike":"2","available_spaces":"18","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.1202,"location":"32.1202,34.8214","longitude":34.8214,"name":"לאה 16 פינת אלתרמן","sid":"203","address":"לאה 16 פינת אלתרמן","name_en":"16 Lea St./ Alterman St.","address_en":"16 Lea St./ Alterman St."},{"available_bike":"4","available_spaces":"16","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.1218,"location":"32.1218,34.8258","longitude":34.8258,"name":"צהל פינת עיר שמש בכיכר","sid":"204","address":"צהל פינת עיר שמש בכיכר","name_en":"Tsahal St./ Ir Shemesh St.","address_en":"Tsahal St./ Ir Shemesh St."},{"available_bike":"1","available_spaces":"19","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.1214,"location":"32.1214,34.8349","longitude":34.8349,"name":"צה\"ל מול בית 76","sid":"205","address":"צה\"ל מול בית 76","name_en":"Opp. 76 Tsahal St.","address_en":"צה\"ל מול בית 76"},{"available_bike":"0","available_spaces":"20","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.118,"location":"32.118,34.8395","longitude":34.8395,"name":"נווה שרת הצנחנים 2","sid":"206","address":"נווה שרת הצנחנים 2","name_en":"Neve Sharett – 2 HaTzanchanim St.","address_en":"Neve Sharett – 2 HaTzanchanim St."},{"available_bike":"13","available_spaces":"7","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.1142,"location":"32.1142,34.8189","longitude":34.8189,"name":"קהילת קיוב 3 - המכללה להנדסאים","sid":"207","address":"מכללת תל אביב להנדסאים -קהילת קייב מול בית מס 6 במדרכה","name_en":"3 Kehillat Kiov St. – College of Practical Engineering","address_en":"מכללת תל אביב להנדסאים -קהילת קייב מול בית מס 6 במדרכה"},{"available_bike":"3","available_spaces":"17","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.1137,"location":"32.1137,34.8252","longitude":34.8252,"name":"מול פנחס רוזן 62","sid":"208","address":"מול פנחס רוזן 62","name_en":"Opp. 62 Pinchas Rosen St.","address_en":"Opp. 62 Pinchas Rosen St."},{"available_bike":"8","available_spaces":"12","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.1144,"location":"32.1144,34.8414","longitude":34.8414,"name":"עתידים -דבורה הנביאה","sid":"209","address":"עתידים -דבורה הנביאה","name_en":"Raoul Valenberg St./ Dvorah HaNeva St.- Atidim","address_en":"Raoul Valenberg St./ Dvorah HaNeva St.- Atidim"},{"available_bike":"9","available_spaces":"11","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.1099,"location":"32.1099,34.8189","longitude":34.8189,"name":"הדר יוסף - מרכז מסחרי","sid":"210","address":" הדר יוסף 7 מרכז מסחרי- בגינה מימין לשביל ,נדרש משטח","name_en":"Hadar Yosef – commercial center","address_en":" הדר יוסף 7 מרכז מסחרי- בגינה מימין לשביל ,נדרש משטח"},{"available_bike":"7","available_spaces":"13","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.1091,"location":"32.1091,34.8394","longitude":34.8394,"name":"אסותא הברזל 23","sid":"211","address":"אסותא הברזל 23","name_en":"Assuta – 23 HaBarzel St.","address_en":"Assuta – 23 HaBarzel St."},{"available_bike":"4","available_spaces":"14","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.1101,"location":"32.1101,34.8324","longitude":34.8324,"name":"הרוגי המלכות 6","sid":"212","address":"הרוגי המלכות 6","name_en":"6 Harugey Malkhot St.","address_en":"6 Harugey Malkhot St."},{"available_bike":"1","available_spaces":"19","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.1069,"location":"32.1069,34.8211","longitude":34.8211,"name":"שלום אש מרכז מסחרי","sid":"213","address":"שלום אש מול בית 14 ","name_en":"","address_en":"שלום אש מול בית 14 "},{"available_bike":"2","available_spaces":"18","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.1176,"location":"32.1176,34.8132","longitude":34.8132,"name":"תל ברוך ביהס אלחריזי","sid":"214","address":"תל ברוך ביהס אלחריזי","name_en":"Tel Baruch – Alharizi School","address_en":"Tel Baruch – Alharizi School"},{"available_bike":"9","available_spaces":"11","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.1042,"location":"32.1042,34.8094","longitude":34.8094,"name":"רוקח מרכז הירידים","sid":"215","address":"רוקח מרכז הירידים","name_en":"Trade Fairs Center","address_en":"Trade Fairs Center"},{"available_bike":"5","available_spaces":"15","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.1032,"location":"32.1032,34.8051","longitude":34.8051,"name":"תחנת רכבת אונברסיטה","sid":"216","address":" תחנת רכבת אונברסיטה - במדרכה  צמוד לקיר בצד הדרומי של*","name_en":"University Railway Station","address_en":" תחנת רכבת אונברסיטה - במדרכה  צמוד לקיר בצד הדרומי של*"},{"available_bike":"6","available_spaces":"8","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.1173,"location":"32.1173,34.8247","longitude":34.8247,"name":"גבעת הפרחים","sid":"217","address":"מרסל ינקו 7-גבעת הפרחים","name_en":"7 Marcel Yanko St.","address_en":"מרסל ינקו 7-גבעת הפרחים"},{"available_bike":"6","available_spaces":"14","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.1067,"location":"32.1067,34.8326","longitude":34.8326,"name":"ראול ולנברג פינת הברזל","sid":"218","address":"ראול ולנברג פינת הברזל","name_en":"Raoul Wallenberg St./ HaBarzel St.","address_en":"Raoul Wallenberg St./ HaBarzel St."},{"available_bike":"3","available_spaces":"17","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.1136,"location":"32.1136,34.8326","longitude":34.8326,"name":"שיכון דן משמר הירדן 79","sid":"219","address":"שיכון דן משמר הירדן 79","name_en":"Shikun Dan – 79 Mishmar HaYarden St.","address_en":"Shikun Dan – 79 Mishmar HaYarden St."},{"available_bike":"6","available_spaces":"11","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.1122,"location":"32.1122,34.8151","longitude":34.8151,"name":"קדש ברנע מול בית 9","sid":"220","address":"קדש ברנע מול בית 9","name_en":"Opp. 9 Kadesh Barnea St.","address_en":"קדש ברנע מול בית 9"},{"available_bike":"4","available_spaces":"16","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.101,"location":"32.101,34.7753","longitude":34.7753,"name":"נמל תל אביב כיכר שלוותה","sid":"301","address":"נמל תל אביב כיכר שלוותה","name_en":"Namel Tel Aviv - Shalvata","address_en":"נמל תל אביב כיכר שלוותה"},{"available_bike":"5","available_spaces":"12","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0971,"location":"32.0971,34.776","longitude":34.776,"name":"דיזנגוף 342","sid":"302","address":"דיזנגוף 342 במדרכה","name_en":"342 Meir Dizengoff St.","address_en":"דיזנגוף 342 במדרכה"},{"available_bike":"6","available_spaces":"11","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.096,"location":"32.096,34.7772","longitude":34.7772,"name":"אוסישקין 48","sid":"303","address":"אושיסקין 46-48 בכביש","name_en":"48 Ussishkin St.","address_en":"אושיסקין 46-48 בכביש"},{"available_bike":"5","available_spaces":"15","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.099,"location":"32.099,34.7813","longitude":34.7813,"name":"שדרות רוקח-חניון רידינג","sid":"304","address":"רוקח-חניון בית ההלוויות העירוני -כניסה לחניון צד ימין בדשא","name_en":"Rokach Yisrael - Reeding Parking Lot","address_en":"רוקח-חניון בית ההלוויות העירוני -כניסה לחניון צד ימין בדשא"},{"available_bike":"8","available_spaces":"12","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0988,"location":"32.0988,34.789","longitude":34.789,"name":"שדרות רוקח - ספורטק","sid":"305","address":"ספורטק בגינה 100 מטר מז לתחנת אוטובוס","name_en":"Rokach Yisrael - Sportek","address_en":"ספורטק בגינה 100 מטר מז לתחנת אוטובוס"},{"available_bike":"4","available_spaces":"16","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0908,"location":"32.0908,34.7966","longitude":34.7966,"name":"אלוני ניסים 8","sid":"306","address":"אלוני ניסים 8 בגינה סמוך למרכז המסחרי","name_en":"8 Nisim Aloni St.","address_en":"אלוני ניסים 8 בגינה סמוך למרכז המסחרי"},{"available_bike":"0","available_spaces":"20","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0962,"location":"32.0962,34.7907","longitude":34.7907,"name":"בני דן 56- גני יהושוע","sid":"307","address":"בני דן 56 בגינה","name_en":"56 Bnei Dan St.","address_en":"בני דן 56 בגינה"},{"available_bike":"10","available_spaces":"10","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0979,"location":"32.0979,34.797","longitude":34.797,"name":"קוסובסקי 34 -גני יהושוע","sid":"308","address":"קוסובסקי 34 -32 ממול בפארק יהושוע","name_en":"34 Kosowski St.","address_en":"קוסובסקי 34 -32 ממול בפארק יהושוע"},{"available_bike":"9","available_spaces":"11","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0942,"location":"32.0942,34.793","longitude":34.793,"name":"יהודה מכבי 81","sid":"309","address":"יהודה מכבי 79-81 במדרכה","name_en":"81 Yehuda Hamakabi St.","address_en":"יהודה מכבי 79-81 במדרכה"},{"available_bike":"4","available_spaces":"16","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0936,"location":"32.0936,34.7872","longitude":34.7872,"name":"ברנדיס 20","sid":"310","address":"ברנדיס 20 בכביש מפרץ חניה","name_en":"20 Brandeis St.","address_en":"ברנדיס 20 בכביש מפרץ חניה"},{"available_bike":"12","available_spaces":"4","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0937,"location":"32.0937,34.7835","longitude":34.7835,"name":"אבן גבירול 182","sid":"311","address":"אבן גבירול 180-182 במדרכה","name_en":"182 Ibn Gvirol St.","address_en":"אבן גבירול 180-182 במדרכה"},{"available_bike":"8","available_spaces":"12","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0949,"location":"32.0949,34.7726","longitude":34.7726,"name":"נמל תל אביב   12","sid":"312","address":"נמל תל אביב 12 במדרכה חוף מציצים","name_en":"12 Namel Tel Aviv - Metzitzim Beach","address_en":"נמל תל אביב 12 במדרכה חוף מציצים"},{"available_bike":"1","available_spaces":"19","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0926,"location":"32.0926,34.7765","longitude":34.7765,"name":"דיזנגוף 280","sid":"313","address":"דיזנגוף 280 במדרכה","name_en":"280 Meir Dizengoff St.","address_en":"דיזנגוף 280 במדרכה"},{"available_bike":"7","available_spaces":"13","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0918,"location":"32.0918,34.7827","longitude":34.7827,"name":"נורדאו 101בשדרה","sid":"314","address":"נורדאו 99-101 פינת אבן גבירול בשדרה ","name_en":"101 Nordau St.","address_en":"נורדאו 99-101 פינת אבן גבירול בשדרה "},{"available_bike":"9","available_spaces":"8","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0914,"location":"32.0914,34.7867","longitude":34.7867,"name":"דה האז 30","sid":"315","address":"דה האז 30 במדרכה","name_en":"30 De Haas St.","address_en":"דה האז 30 במדרכה"},{"available_bike":"8","available_spaces":"11","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0903,"location":"32.0903,34.7904","longitude":34.7904,"name":"ויצמן 60 - בית החייל","sid":"316","address":"ויצמן 60 במדרכה","name_en":"60 Weizman St. - Beit Ha-Khyal","address_en":"ויצמן 60 במדרכה"},{"available_bike":"7","available_spaces":"13","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0913,"location":"32.0913,34.7943","longitude":34.7943,"name":"פנקס  69","sid":"317","address":"פנקס  69 במדרכה פינת נמיר","name_en":"69 Pinkas St.","address_en":"פנקס  69 במדרכה פינת נמיר"},{"available_bike":"5","available_spaces":"15","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0892,"location":"32.0892,34.7737","longitude":34.7737,"name":"בן יהודה 192","sid":"318","address":"בן יהודה 192 במדרכה פינת זבוטינסקי","name_en":"192 Ben Yehuda St.","address_en":"בן יהודה 192 במדרכה פינת זבוטינסקי"},{"available_bike":"6","available_spaces":"14","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0871,"location":"32.0871,34.7822","longitude":34.7822,"name":"אבן גבירול 124","sid":"319","address":"אבן גבירול 124 במדרכה","name_en":"124 Ibn Gvirol St.","address_en":"אבן גבירול 124 במדרכה"},{"available_bike":"10","available_spaces":"10","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0901,"location":"32.0901,34.7791","longitude":34.7791,"name":"השלה 1  -מתחם בזל","sid":"320","address":"השלה 1 במדרכה","name_en":"1 HaShlah St. - Basel Area","address_en":"השלה 1 במדרכה"},{"available_bike":"5","available_spaces":"15","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0867,"location":"32.0867,34.7884","longitude":34.7884,"name":"ה באייר 2- כיכר המדינה","sid":"321","address":"מול ה באייר 2 פינת זבוטינסקי בכיכר סמוך לשפת הכביש","name_en":"2 Heh be-iyar St. - Ha-Medina Square","address_en":"מול ה באייר 2 פינת זבוטינסקי בכיכר סמוך לשפת הכביש"},{"available_bike":"2","available_spaces":"18","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0865,"location":"32.0865,34.7926","longitude":34.7926,"name":"שדרות הציונות 1 ","sid":"322","address":"שדרות הציונות 1 ","name_en":" 1 Tsiyonut Av","address_en":"שדרות הציונות 1 "},{"available_bike":"12","available_spaces":"8","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0847,"location":"32.0847,34.7867","longitude":34.7867,"name":"תשח 2","sid":"323","address":"תשח 2 במדרכה","name_en":"2 Tashah St.","address_en":"תשח 2 במדרכה"},{"available_bike":"2","available_spaces":"15","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0843,"location":"32.0843,34.7816","longitude":34.7816,"name":"אבן גבירול 106 -בית הדואר","sid":"324","address":"אבן גבירול 106 - בית הדואר במדרכה","name_en":"106 Ibn Gvirol St. - Post Office","address_en":"אבן גבירול 106 - בית הדואר במדרכה"},{"available_bike":"0","available_spaces":"20","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0836,"location":"32.0836,34.7917","longitude":34.7917,"name":"הלסינקי 3","sid":"325","address":"הלסינקי 3 במפרץ חניה","name_en":"3 Helsinki St.","address_en":"הלסינקי 3 במפרץ חניה"},{"available_bike":"18","available_spaces":"11","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0836,"location":"32.0836,34.7968","longitude":34.7968,"name":"תחנת רכבת סבידור","sid":"326","address":"תחנת רכבת סבידור - מערבית לשער יציאה (קרוסלה) במדרכה","name_en":"Savidor Train Station Center","address_en":"תחנת רכבת סבידור - מערבית לשער יציאה (קרוסלה) במדרכה"},{"available_bike":"7","available_spaces":"12","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.095,"location":"32.095,34.7971","longitude":34.7971,"name":"בבלי פעמוני 2","sid":"328","address":"שכונת בבלי - פעמוני 2 בכביש מפרץ חניה","name_en":"2 Paamony St. - Bavli","address_en":"שכונת בבלי - פעמוני 2 בכביש מפרץ חניה"},{"available_bike":"6","available_spaces":"14","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0866,"location":"32.0866,34.7694","longitude":34.7694,"name":"מלון קרלטון בטיילת","sid":"329","address":"טיילת צמוד למרפסת צפונית מלון קרלטון ","name_en":"Carlton Hotel - Tayelet","address_en":"טיילת צמוד למרפסת צפונית מלון קרלטון "},{"available_bike":"2","available_spaces":"18","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.083,"location":"32.083,34.777","longitude":34.777,"name":"שדרות בן גוריון 68","sid":"330","address":"שדרות בן גוריון 68 במרכז הגינה בחול צמוד לשביל אופניים","name_en":"68 Ben Gurion Av.","address_en":"שדרות בן גוריון 68 במרכז הגינה בחול צמוד לשביל אופניים"},{"available_bike":"13","available_spaces":"15","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.081,"location":"32.081,34.7811","longitude":34.7811,"name":"כיכר רבין","sid":"331","address":"כיכר רבין  מול אבן גבירול 76 -תחנה עירייה","name_en":"Rabin Square","address_en":"כיכר רבין  מול אבן גבירול 76 -תחנה עירייה"},{"available_bike":"2","available_spaces":"18","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.08,"location":"32.08,34.7854","longitude":34.7854,"name":"דוד המלך 30","sid":"332","address":"דוד המלך 30 מול הרבנות בשדרה","name_en":"30 David Hamellech St.","address_en":"דוד המלך 30 מול הרבנות בשדרה"},{"available_bike":"2","available_spaces":"18","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0811,"location":"32.0811,34.7888","longitude":34.7888,"name":"ויצמן 15-איכילוב","sid":"333","address":"ויצמן 15 איכילוב במדרכה מול בית החולים","name_en":"15 weizman st. Ichilov Hospital","address_en":"ויצמן 15 איכילוב במדרכה מול בית החולים"},{"available_bike":"2","available_spaces":"18","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0815,"location":"32.0815,34.7706","longitude":34.7706,"name":"בן יהודה 86","sid":"334","address":"בן יהודה 86   במדרכה ","name_en":"86 Ben Yehuda St.","address_en":"בן יהודה 86   במדרכה "},{"available_bike":"6","available_spaces":"14","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0814,"location":"32.0814,34.7737","longitude":34.7737,"name":"דיזנגוף 126","sid":"335","address":"דיזנגוף 126 פינת גורדון במדרכה צמוד לכביש ","name_en":"126 Meir Dizengoff St.","address_en":"דיזנגוף 126 פינת גורדון במדרכה צמוד לכביש "},{"available_bike":"1","available_spaces":"19","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0841,"location":"32.0841,34.775","longitude":34.775,"name":"בן גוריון 55 -בשדרה","sid":"336","address":"בן גוריון 55 פינת דיזנגוף במרכז השדרה  צמוד לשביל אופניים","name_en":"55 Ben Gurion Av.","address_en":"בן גוריון 55 פינת דיזנגוף במרכז השדרה  צמוד לשביל אופניים"},{"available_bike":"4","available_spaces":"14","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0863,"location":"32.0863,34.7774","longitude":34.7774,"name":"ארלוזורוב 62","sid":"337","address":"ארלוזורוב 62 במדרכה","name_en":"62 Arlozorov St.","address_en":"ארלוזורוב 62 במדרכה"},{"available_bike":"17","available_spaces":"3","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0774,"location":"32.0774,34.7664","longitude":34.7664,"name":"הרברט סמואל 90","sid":"341","address":"הרברט סמואל 90 (ממול )בטילת צמוד לחומה ","name_en":"90 Herbert Samuel St.","address_en":"הרברט סמואל 90 (ממול )בטילת צמוד לחומה "},{"available_bike":"1","available_spaces":"19","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0759,"location":"32.0759,34.7851","longitude":34.7851,"name":"שאול המלך 21 קאמרי","sid":"342","address":"שאול המלך 21 קאמרי -במדרכה מימין למדרגות כניסה מערבית","name_en":"21 Sauol Hamelekh- Hakameri","address_en":"שאול המלך 21 קאמרי -במדרכה מימין למדרגות כניסה מערבית"},{"available_bike":"21","available_spaces":"2","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0782,"location":"32.0782,34.7745","longitude":34.7745,"name":"ככר דיזינגוף ","sid":"343","address":"ריינס 2 - כיכר דיזנגוף במדרכה","name_en":"2 Reiness St. - Dizengoff Square","address_en":"ריינס 2 - כיכר דיזנגוף במדרכה"},{"available_bike":"11","available_spaces":"9","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0779,"location":"32.0779,34.7783","longitude":34.7783,"name":"נצח ישראל 4 פינת מסריק","sid":"344","address":"נצח ישראל 4 פינת מסריק - תחנה בחניה בכביש ","name_en":"4 Netsakh Yisrael St./ Masaryk","address_en":"נצח ישראל 4 פינת מסריק - תחנה בחניה בכביש "},{"available_bike":"11","available_spaces":"9","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0772,"location":"32.0772,34.7884","longitude":34.7884,"name":"ויצמן 1 -  בית המשפט","sid":"345","address":"ויצמן 1 בית המשפט","name_en":"1 Weizman St. - Court Justice Hall","address_en":"ויצמן 1 בית המשפט"},{"available_bike":"3","available_spaces":"17","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.075,"location":"32.075,34.7818","longitude":34.7818,"name":"אבן גבירול 28","sid":"346","address":"אבן גבירול 28 לונדון מיניסטור מאחורי ספסל ארוך דרום לכניסה","name_en":"28 Ibn Gabirol St.","address_en":"אבן גבירול 28 לונדון מיניסטור מאחורי ספסל ארוך דרום לכניסה"},{"available_bike":"9","available_spaces":"10","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.076,"location":"32.076,34.7718","longitude":34.7718,"name":"בוגרשוב 45 פינת פינסקר","sid":"347","address":"בוגרשוב 46-45 פינת פינסקר במדרכה ","name_en":"Bograshov 45/ Pinsker st.","address_en":"בוגרשוב 46-45 פינת פינסקר במדרכה "},{"available_bike":"12","available_spaces":"8","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.074,"location":"32.074,34.7756","longitude":34.7756,"name":"שדרות בן ציון  1","sid":"348","address":"שדרות בן ציון  1 במדרכה בין העצים","name_en":"1 Shderot Ben Tsiyon St.","address_en":"שדרות בן ציון  1 במדרכה בין העצים"},{"available_bike":"3","available_spaces":"17","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.073,"location":"32.073,34.7682","longitude":34.7682,"name":"בן יהודה 1","sid":"354","address":"בן יהודה 1 במדרכה כיכר מוגרבי","name_en":"1 Ben Yehuda St.","address_en":"בן יהודה 1 במדרכה כיכר מוגרבי"},{"available_bike":"6","available_spaces":"14","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.071,"location":"32.071,34.7641","longitude":34.7641,"name":"הרברט סמואל 32","sid":"355","address":"הרברט סמואל 32 בטיילת חוף הבננה ביץ","name_en":"32 Herbert Samuel St.","address_en":"הרברט סמואל 32 בטיילת חוף הבננה ביץ"},{"available_bike":"13","available_spaces":"7","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0718,"location":"32.0718,34.779","longitude":34.779,"name":"רוטשילד 140","sid":"357","address":"רוטשילד 140 בשדרה פינת מרמורק  (כיכר הבימה) ","name_en":"140 Rothshild Av. - Habima","address_en":"רוטשילד 140 בשדרה פינת מרמורק  (כיכר הבימה) "},{"available_bike":"5","available_spaces":"14","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0707,"location":"32.0707,34.7826","longitude":34.7826,"name":"שפרינצק 1 - סינימטק","sid":"358","address":"סינימטק מול שפרינצק 1 במדרכה","name_en":"1 Shprintsak St. - Cinematek","address_en":"סינימטק מול שפרינצק 1 במדרכה"},{"available_bike":"1","available_spaces":"19","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0732,"location":"32.0732,34.7857","longitude":34.7857,"name":"קפלן פינת ארניה","sid":"359","address":"קפלן פינת ארניה קריה מול שער רבין","name_en":"Kaplan St./ Aaranha St.","address_en":"קפלן פינת ארניה קריה מול שער רבין"},{"available_bike":"9","available_spaces":"11","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0701,"location":"32.0701,34.7901","longitude":34.7901,"name":"שד יהודית 11 פינת הנציב","sid":"360","address":"שדרות יהודית מול 16 בגינה","name_en":"11 Sderot Yehudit /Ha-Nanatsiv St.","address_en":"שדרות יהודית מול 16 בגינה"},{"available_bike":"2","available_spaces":"18","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0695,"location":"32.0695,34.7707","longitude":34.7707,"name":"אלנבי 53 שוק הכרמל","sid":"361","address":"אלנבי 53 שוק הכרמל, כיכר מגן דוד","name_en":"53 Allenby St. - Carmel Market","address_en":"אלנבי 53 שוק הכרמל, כיכר מגן דוד"},{"available_bike":"14","available_spaces":"6","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0685,"location":"32.0685,34.7783","longitude":34.7783,"name":"רוטשילד 108","sid":"362","address":"רוטשילד 108 בשדרה פינת נחמני","name_en":"108 Rothshild Av. ","address_en":"רוטשילד 108 בשדרה פינת נחמני"},{"available_bike":"6","available_spaces":"14","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0657,"location":"32.0657,34.7831","longitude":34.7831,"name":"בית רובינשטיין-צ. מעריב","sid":"363","address":"בית רובינשטיין במדרכה סמוך לשפת הכביש ","name_en":"Begin/ Lincoln -Biet Rubinshtein","address_en":"בית רובינשטיין במדרכה סמוך לשפת הכביש "},{"available_bike":"3","available_spaces":"17","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0696,"location":"32.0696,34.7725","longitude":34.7725,"name":"גינת שינקין-י נפחא מול 1","sid":"364","address":"שינקין  יצחק נפחא מול בית 1","name_en":"Sheinkin  garden","address_en":"שינקין  יצחק נפחא מול בית 1"},{"available_bike":"7","available_spaces":"13","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0654,"location":"32.0654,34.7858","longitude":34.7858,"name":"יצחק שדה 17 - ביטוח לאומי","sid":"365","address":"מול יצחק שדה 17 ביטוח לאומי (המסגר) במדרכה","name_en":"17 Yitskhak Sadeh St. ","address_en":"מול יצחק שדה 17 ביטוח לאומי (המסגר) במדרכה"},{"available_bike":"6","available_spaces":"14","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0665,"location":"32.0665,34.7662","longitude":34.7662,"name":"כרמלית פינת הכרמל","sid":"366","address":"כרמלית פינת הכרמל בגינה","name_en":"Carmelit/ Ha-Carmel Market","address_en":"כרמלית פינת הכרמל בגינה"},{"available_bike":"13","available_spaces":"7","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0635,"location":"32.0635,34.7617","longitude":34.7617,"name":"קויפמן 2 -  תחנת הדלק","sid":"367","address":"מול קויפמן 2 במדרכה צמוד לתחנת הדלק ","name_en":"Opp. 2 Koifman St. - Gas Station","address_en":"מול קויפמן 2 במדרכה צמוד לתחנת הדלק "},{"available_bike":"1","available_spaces":"19","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0669,"location":"32.0669,34.7716","longitude":34.7716,"name":"אלנבי 90 פינת מאזה","sid":"368","address":"אלנבי 88-90 פינת גרוזנברג במדרכה בין העצים  ","name_en":"90 Allenby St./ Maze St.","address_en":"אלנבי 88-90 פינת גרוזנברג במדרכה בין העצים  "},{"available_bike":"14","available_spaces":"6","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0631,"location":"32.0631,34.7709","longitude":34.7709,"name":"רוטשילד 11 פינת הרצל","sid":"369","address":"רוטשילד 11 פינת הרצל בשדרה בין העצים ","name_en":"11 Rothshild Av./ Herzl St.","address_en":"רוטשילד 11 פינת הרצל בשדרה בין העצים "},{"available_bike":"4","available_spaces":"16","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0653,"location":"32.0653,34.7766","longitude":34.7766,"name":"רוטשילד 65","sid":"370","address":"רוטשילד 65 בשדרה פינת נחמני","name_en":"65 Rothschild Av./ Nachmami St.","address_en":"רוטשילד 65 בשדרה פינת נחמני"},{"available_bike":"6","available_spaces":"14","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0629,"location":"32.0629,34.7799","longitude":34.7799,"name":"בגין 48 פינת הרכבת","sid":"371","address":"בגין 46-48 פינת הרכבת ברחבה מצידי השביל","name_en":"48 Menachem Begin Rd./ HaRakevet St.","address_en":"בגין 46-48 פינת הרכבת ברחבה מצידי השביל"},{"available_bike":"16","available_spaces":"2","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0618,"location":"32.0618,34.7844","longitude":34.7844,"name":"יד חרוצים 17 - המסגר","sid":"372","address":"יד חרוצים 17 פינת המסגר במדרכה","name_en":"17 Yad Kharutsim St./Ha-Masger","address_en":"יד חרוצים 17 פינת המסגר במדרכה"},{"available_bike":"11","available_spaces":"9","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0618,"location":"32.0618,34.7731","longitude":34.7731,"name":"יהודה הלוי 43 פינת אלנבי","sid":"375","address":"יהודה הלוי 43 פינת אלנבי במדרכה ","name_en":"43 Yehuda HaLevi St./ Allenby St.","address_en":"יהודה הלוי 43 פינת אלנבי במדרכה "},{"available_bike":"10","available_spaces":"10","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0594,"location":"32.0594,34.7614","longitude":34.7614,"name":"מתחם התחנה","sid":"377","address":"מתחם התחנה -בכניסה לרחבה של המוזיאון בצד הצפוני","name_en":"Hatachana","address_en":"מתחם התחנה -בכניסה לרחבה של המוזיאון בצד הצפוני"},{"available_bike":"13","available_spaces":"5","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0621,"location":"32.0621,34.7646","longitude":34.7646,"name":"שבזי 19 -נווה צדק","sid":"379","address":"שבזי 19 נווה צדק","name_en":"Shabazi 19 Neve Tsedek","address_en":"שבזי 19 נווה צדק"},{"available_bike":"7","available_spaces":"13","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0724,"location":"32.0724,34.7739","longitude":34.7739,"name":"גן מאיר - רחוב קינג גורג","sid":"380","address":"גן מאיר - רחוב קינג גורג","name_en":"King George St.- Meir Garden","address_en":"גן מאיר - רחוב קינג גורג"},{"available_bike":"4","available_spaces":"16","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0795,"location":"32.0795,34.7797","longitude":34.7797,"name":"פרישמן 77","sid":"381","address":"פרישמן 77-שדרות חן","name_en":"77 Frishman St.","address_en":"פרישמן 77-שדרות חן"},{"available_bike":"8","available_spaces":"12","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0563,"location":"32.0563,34.7812","longitude":34.7812,"name":"יסוד המעלה 64 - ת. מרכזית","sid":"401","address":"יסוד המעלה 64 במדרכה -התחנה המרכזית חדשה ","name_en":"64 Yesud ha-Maala  St. - Central Bus Station","address_en":"יסוד המעלה 64 במדרכה -התחנה המרכזית חדשה "},{"available_bike":"4","available_spaces":"16","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0588,"location":"32.0588,34.7751","longitude":34.7751,"name":"לוינסקי 83א","sid":"402","address":"לוינסקי 83א פינת צלנוב","name_en":"83 Elhanan Eib Levinski St.","address_en":"לוינסקי 83א פינת צלנוב"},{"available_bike":"5","available_spaces":"15","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0556,"location":"32.0556,34.756","longitude":34.756,"name":"רציף העליה השניה - כיכר השעון","sid":"403","address":"אריאנה -רציף העליה השניה צפונית לקישלה","name_en":" The Clock Tower","address_en":"אריאנה -רציף העליה השניה צפונית לקישלה"},{"available_bike":"4","available_spaces":"16","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0518,"location":"32.0518,34.7643","longitude":34.7643,"name":"שארית ישראל מול 37","sid":"404","address":"שארית ישראל מול 37","name_en":"Opp. 37 Sheerit Yisrael St. Bloomfield Stadium","address_en":"Opp. 37 Sheerit Yisrael St. Bloomfield Stadium"},{"available_bike":"7","available_spaces":"13","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0546,"location":"32.0546,34.7521","longitude":34.7521,"name":"כיכר קדומים -יפו העתיקה","sid":"405","address":"- כיכר קדומים - ברחבה","name_en":"Kedumim Square – Old jaffa","address_en":"- כיכר קדומים - ברחבה"},{"available_bike":"6","available_spaces":"13","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0481,"location":"32.0481,34.7692","longitude":34.7692,"name":"הרצל 155 - גני הטבע","sid":"406","address":"הרצל 155 גני הטבע תא ,לאורך הקיר מימין לשער","name_en":"155 Herzl St. - Botanical Garden","address_en":"הרצל 155 גני הטבע תא ,לאורך הקיר מימין לשער"},{"available_bike":"4","available_spaces":"16","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0475,"location":"32.0475,34.7595","longitude":34.7595,"name":"מכללת תא עזה מול 34","sid":"407","address":"עזה 34-מכללת תל אביב  ","name_en":"Opp. 34 Azza St. – Tlv College","address_en":"עזה 34-מכללת תל אביב  "},{"available_bike":"9","available_spaces":"11","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0411,"location":"32.0411,34.7656","longitude":34.7656,"name":"גרינבוים 37 - נווה עופר","sid":"408","address":"גרינבוים 37 - נווה עופר","name_en":"37  Greenbaum St.","address_en":"37  Greenbaum St."},{"available_bike":"14","available_spaces":"6","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0536,"location":"32.0536,34.7501","longitude":34.7501,"name":"נמל יפו מבנה המגדלור","sid":"409","address":"נמל יפו קיר מבנה מגדלור","name_en":"Nemal Yaffo - Ha-migdalor (jaffa Port)","address_en":"נמל יפו קיר מבנה מגדלור"},{"available_bike":"5","available_spaces":"14","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0476,"location":"32.0476,34.7525","longitude":34.7525,"name":"יפת 66 -  גן השניים","sid":"410","address":"יפת 66 -  גן השניים","name_en":"66 Yefet St.","address_en":"66 Yefet St."},{"available_bike":"4","available_spaces":"16","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0534,"location":"32.0534,34.7553","longitude":34.7553,"name":"שוק פשפשים- רבי אחא","sid":"411","address":"שוק פשפשים- רבי אחא","name_en":"Flea market – Rabbi Aha St.","address_en":"Flea market – Rabbi Aha St."},{"available_bike":"6","available_spaces":"14","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0427,"location":"32.0427,34.7804","longitude":34.7804,"name":"ישראל גורי 34","sid":"412","address":"ישראל גורי 34","name_en":"34 Guri Yisrael St.","address_en":"34 Guri Yisrael St."},{"available_bike":"6","available_spaces":"13","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0372,"location":"32.0372,34.7516","longitude":34.7516,"name":"שד הבעל שם טוב נוה אילן","sid":"414","address":"שד הבעל שם טוב נוה אילן","name_en":"HaBesht Ave. – Neve Golan","address_en":"HaBesht Ave. – Neve Golan"},{"available_bike":"5","available_spaces":"15","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0419,"location":"32.0419,34.7736","longitude":34.7736,"name":"שדרות בן צבי 91","sid":"415","address":"שדרות בן צבי 91","name_en":"91 Ben-Zvi Av.","address_en":"91 Ben-Zvi Av."},{"available_bike":"17","available_spaces":"3","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.056,"location":"32.056,34.7698","longitude":34.7698,"name":"פלורנטין שד וושינגטון ","sid":"416","address":"פלורנטין -גינת וושינגטון","name_en":"Washington Av./ Florentin St.","address_en":"פלורנטין -גינת וושינגטון"},{"available_bike":"6","available_spaces":"14","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0424,"location":"32.0424,34.757","longitude":34.757,"name":"שד ירושלים פ. נחל הבשור","sid":"417","address":"שדרות ירושלים פינת נחל הבשור","name_en":"Yerushalayim Av. Nahal Habsor","address_en":"שדרות ירושלים פינת נחל הבשור"},{"available_bike":"4","available_spaces":"16","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0489,"location":"32.0489,34.781","longitude":34.781,"name":"ישראל מסלנט מול 13","sid":"418","address":"ישראל מסלנט מול 13","name_en":"opp.13 Israel Misalant St.","address_en":"opp.13 Israel Misalant St."},{"available_bike":"1","available_spaces":"19","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0508,"location":"32.0508,34.7596","longitude":34.7596,"name":"שד ירושלים פינת בן צבי 1","sid":"420","address":"שד ירושלים פינת בן צבי 1 במדרכה צמוד לשפת הכביש  ","name_en":"Jerusalem Av./ 1 Ben Zvi Av.","address_en":"שד ירושלים פינת בן צבי 1 במדרכה צמוד לשפת הכביש  "},{"available_bike":"3","available_spaces":"17","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0421,"location":"32.0421,34.7473","longitude":34.7473,"name":"מנדס פרנס - גינת טולוז","sid":"422","address":"מנדס פרנס 2 קדם (גינת טולוז)","name_en":"Mendes Parnas St. – Toulouse Gardens","address_en":"מנדס פרנס 2 קדם (גינת טולוז)"},{"available_bike":"3","available_spaces":"16","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0464,"location":"32.0464,34.749","longitude":34.749,"name":"קדם 49","sid":"423","address":"קדם מול 49 - קיר דרומי חסן עראפה, רחבת ירידה לפארק מדרון  ","name_en":"49 Kedem St.","address_en":"קדם מול 49 - קיר דרומי חסן עראפה, רחבת ירידה לפארק מדרון  "},{"available_bike":"7","available_spaces":"13","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0319,"location":"32.0319,34.7473","longitude":34.7473,"name":"אייזיק חריף מול 36","sid":"424","address":"אייזיק חריף מול 36","name_en":"Opp. 36 Isaac Harif St.","address_en":"Opp. 36 Isaac Harif St."},{"available_bike":"0","available_spaces":"20","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.034,"location":"32.034,34.7531","longitude":34.7531,"name":"המחרוזת 9","sid":"425","address":"המחרוזת 9","name_en":"9 Machrozet St.","address_en":"9 Machrozet St."},{"available_bike":"13","available_spaces":"7","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0665,"location":"32.0665,34.7959","longitude":34.7959,"name":"שדרות ההשכלה 11","sid":"501","address":"שדרות ההשכלה 11","name_en":"Hahaskalla Av. / Krminitzki St.","address_en":"שדרות ההשכלה 11"},{"available_bike":"8","available_spaces":"12","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0695,"location":"32.0695,34.7939","longitude":34.7939,"name":"יגאל אלון 96","sid":"503","address":"יגאל אלון 96 במדרכה סמוך לשפת הכביש  הסרת עמודי חסימה","name_en":"96 Yigal Allon St.","address_en":"יגאל אלון 96 במדרכה סמוך לשפת הכביש  הסרת עמודי חסימה"},{"available_bike":"8","available_spaces":"12","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.058,"location":"32.058,34.8001","longitude":34.8001,"name":"משה דיין פינת לה גרדיה","sid":"504","address":"משה דיין פינת לה גרדיה","name_en":"Moshe Dayan St./ La Guardia St.","address_en":"Moshe Dayan St./ La Guardia St."},{"available_bike":"4","available_spaces":"16","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.062,"location":"32.062,34.7903","longitude":34.7903,"name":"היכל נוקיה השלושה 9","sid":"507","address":"היכל נוקיה השלושה 9","name_en":"9 ha-shlosha St.- Nokia Arena","address_en":"היכל נוקיה השלושה 9"},{"available_bike":"5","available_spaces":"15","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0646,"location":"32.0646,34.7986","longitude":34.7986,"name":"משה דיין פינת יצחק שדה","sid":"508","address":"משה דיין פינת יצחק שדה","name_en":"Moshe Dayan St./ Yitzhak Sadeh St.","address_en":"Moshe Dayan St./ Yitzhak Sadeh St."},{"available_bike":"0","available_spaces":"20","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0565,"location":"32.0565,34.8065","longitude":34.8065,"name":"הטייסים 40","sid":"509","address":"הטייסים 40","name_en":"40 HaTayassim Rd.","address_en":"40 HaTayassim Rd."},{"available_bike":"2","available_spaces":"18","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0504,"location":"32.0504,34.7981","longitude":34.7981,"name":"קרייתי מול 28","sid":"510","address":"קרייתי מול 28","name_en":"Opp. 28 Kiryati St.","address_en":"Opp. 28 Kiryati St."},{"available_bike":"5","available_spaces":"13","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0543,"location":"32.0543,34.7865","longitude":34.7865,"name":"ההגנה 31 - תחנת רכבת ההגנה","sid":"511","address":"ההגנה 31 - תחנת רכבת ההגנה","name_en":"2 Derech HaHaganah St. – HaHaganah Railway station","address_en":"2 Derech HaHaganah St. – HaHaganah Railway station"},{"available_bike":"4","available_spaces":"15","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0569,"location":"32.0569,34.7918","longitude":34.7918,"name":"יגאל אלון 33 פינת שדרות החי\"ל ","sid":"512","address":"יגאל אלון 33 פינת שדרות החי\"ל ","name_en":"33 Yigal Allon St./ Hahayil","address_en":"יגאל אלון 33 פינת שדרות החי\"ל "},{"available_bike":"1","available_spaces":"19","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0529,"location":"32.0529,34.7996","longitude":34.7996,"name":"משה דיין 45","sid":"513","address":"משה דיין 45","name_en":"45 Moshe Dayan St.","address_en":"45 Moshe Dayan St."},{"available_bike":"5","available_spaces":"12","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0532,"location":"32.0532,34.8103","longitude":34.8103,"name":"מעפילי אגוז 59","sid":"514","address":"מעפילי אגוז 59","name_en":"59 Maapilei Egoz St.","address_en":"59 Maapilei Egoz St."},{"available_bike":"6","available_spaces":"14","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.05,"location":"32.05,34.7889","longitude":34.7889,"name":"סמטת כביר 18","sid":"515","address":"סמטת כביר 18","name_en":"18 Kabir Lane","address_en":"18 Kabir Lane"},{"available_bike":"4","available_spaces":"16","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0497,"location":"32.0497,34.8121","longitude":34.8121,"name":"מחל 79","sid":"516","address":"מחל 79","name_en":"79 Mahal St.","address_en":"79 Mahal St."},{"available_bike":"6","available_spaces":"14","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.045,"location":"32.045,34.8098","longitude":34.8098,"name":"דרך בר לב 186","sid":"517","address":"דרך בר לב 186","name_en":"186 Bar-Lev Rd.","address_en":"186 Bar-Lev Rd."},{"available_bike":"0","available_spaces":"20","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0469,"location":"32.0469,34.8","longitude":34.8,"name":"דרך בר לב 111","sid":"518","address":"דרך בר לב 111","name_en":"111 Bar-Lev Rd.","address_en":"111 Bar-Lev Rd."},{"available_bike":"9","available_spaces":"11","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0744,"location":"32.0744,34.8","longitude":34.8,"name":"ילקוט  הרועים 2 - נחלת יצחק","sid":"519","address":" ילקוט  הרועים 2 נחלת יצחק במדרכה צמוד לגינה מרכז קהילתי  ","name_en":"2 Yalkut HaRoim St. / Nachlat Yitzhak","address_en":" ילקוט  הרועים 2 נחלת יצחק במדרכה צמוד לגינה מרכז קהילתי  "},{"available_bike":"5","available_spaces":"15","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0435,"location":"32.0435,34.8047","longitude":34.8047,"name":"פארק דרום בכניסה","sid":"520","address":"פארק דרום בכניסה","name_en":"Park Darom – Entrance (Biranit St.)","address_en":"Park Darom – Entrance (Biranit St.)"},{"available_bike":"2","available_spaces":"24","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0548,"location":"32.0548,34.7848","longitude":34.7848,"name":"תחנת רכבת ההגנה","sid":"522","address":"תחנת רכבת ההגנה","name_en":"Hahgana Railway Station","address_en":"Hahgana Railway Station"},{"available_bike":"5","available_spaces":"13","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0481,"location":"32.0481,34.7936","longitude":34.7936,"name":"אצל 93","sid":"523","address":"אצל 93","name_en":"93 Etsel St.","address_en":"93 Etsel St."},{"available_bike":"8","available_spaces":"16","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0731,"location":"32.0731,34.792","longitude":34.792,"name":"עזריאלי-בירידה לאיילון דרום","sid":"525","address":"עזריאלי-בירידה לאיילון דרום","name_en":"Opp. Azrieli Center - Ayalon South","address_en":"עזריאלי-בירידה לאיילון דרום"},{"available_bike":"3","available_spaces":"17","city":"tlv","last_update":"2012-06-25 12:32:42.489","latitude":32.0593,"location":"32.0593,34.7897","longitude":34.7897,"name":"לה גווארדיה 24","sid":"526","address":"לה גווארדיה 24","name_en":"24 La Guardia","address_en":"לה גווארדיה 24"}]
    }
  };
});
telobike.module(1, function(/* parent */){
  return {
    'id': 'app',
    'pkg': arguments[0],
    'wrapper': function(module, exports, global, Buffer,process, require, undefined){
      var UI = require('uijs');
var constant = UI.util.constant;
var derive = UI.util.derive;
var animate = UI.animation;
var defaults = UI.util.defaults;
var override = UI.util.override;
var $x = require('xui');
var data = require('./lib/data');
var loadimage = UI.util.loadimage;
var app = UI.app({
  layout: UI.layouts.dock({ stretch: constant(true) }),
});
function placeholder(options) {
  var obj = UI.view(defaults(options, {
    // alpha: constant(0.5),
    fillStyle: constant('rgba(100, 100, 100, 0.1)'),
    strokeStyle: constant('black'),
    textFillStyle: constant('909090'),
    font: constant('italic 12pt Helvetica')
  }));
  return obj;
}
var navbar = placeholder({
  height: constant(44),
  dockStyle: constant('top'),
  width: app.width,
  text: constant('navbar'),
});
var tabbar = placeholder({
  height: constant(50),
  dockStyle: constant('bottom'),
  width: app.width,
  text: constant('tabbar'),
});
app.add(navbar);
app.add(tabbar);
var content = UI.view({
  alpha: constant(1.0),
  dockStyle: constant('fill'),
  fillStyle: constant('#404040'),
  layout: UI.layouts.none(),
});
app.add(content);
var list = UI.view({
  alpha: constant(1.0),
  dockStyle: constant('fill'),
  fillStyle: constant('white'),
  layout: UI.layouts.stack({
    spacing: constant(1),
    stretch: constant(true),
  }),
});
content.add(list);
list.x = constant(0);
list.y = constant(0);
list.width = content.width;
list.height = function() {
  return content.height();
};
//   return content.height() + -1*list.y();
// };
// list.y = UI.animation(0, -2000, { duration: constant(10000) });
list.on('touchstart', function() {
  alert('hey');
});
function listitem(options) {
  var def = {
    passthrough: constant(true),
    strokeStyle: null,
    shadowColor: constant('red'),
    shadowBlur: constant(0),
    width: app.width,
    height: constant(62),
    radius: constant(0),
    layout: UI.layouts.dock({
      padding: constant(10),
      spacing: constant(10),
    }),
    highlighted: {
      fillStyle: constant('#aaaaaa'),
    },
    children: [
      UI.image({
        width: function() { return 46; },
        height: function() { return 46; },
        dockStyle: constant('right'),
        image: loadimage(options.icon),
      }),
      UI.view({
        dockStyle: constant('top'),
        font: constant('bold 16pt arial,sans-serif'),
        height: constant(24),
        textAlign: constant('right'),
        text: options.title,
      }),
      UI.view({
        dockStyle: constant('bottom'),
        font: constant('12pt arial,sans-serif'),
        textAlign: constant('right'),
        text: options.subtitle,
        height: constant(20),
        textFillStyle: constant('gray'),
      }),
    ],
    text: null,
  };
  var obj = UI.button(defaults(options, def));
  var base_ondraw = obj.ondraw;
  obj.ondraw = function(ctx) {
    var self = this;
    base_ondraw.call(self, ctx);
    ctx.beginPath();
    ctx.moveTo(0, self.height());
    ctx.lineTo(self.width(), self.height());
    ctx.closePath();
    ctx.strokeStyle = '#eeeeee';
    ctx.stroke();
  };
  return obj;
}
UI.listitem = listitem;
current_location = false;
function load_stations(stations) {
  stations = stations
    .map(function(s) {
      s.online = !!s.last_update;
      s.active = !s.online || s.available_bike > 0 || s.available_spaces > 0;
      s.status = determine_status(s);
      s.subtitle =  ' אופניים ' + s.available_bike + ' חניות ' + s.available_spaces;
      // s.last_update_label = prettyDate(s.last_update_time);
      // if (current_location) {
      //   var d = calculate_distance([ s.latitude, s.longitude ], current_location);
      //   var dl = d < 1.0 ? (d * 1000).toFixed(1) + 'm' : d.toFixed(1) + 'km';
      //   s.distance = d;
      //   s.distance_label = dl;
      // }
      return s;
    });
  for (var i = 0; i < 20; ++i) {
    var station = stations[i];
    list.add(UI.listitem({
      title: constant(station.name),
      subtitle: constant(station.subtitle),
      icon: constant('dist/assets/img/list_' + station.status + '.png'),
    }));
  }    
}
x$(null).xhr('http://telobike.citylifeapps.com/stations', {
  async: true,
  callback: function(x) {
    load_stations(JSON.parse(this.responseText));
  },
});
load_stations(data);
var MARGINAL = 3;
function determine_status(station) {
  if (!station.online) return 'unknown';
  if (!station.active) return 'inactive';
  if (station.available_bike === 0) return 'empty';
  if (station.available_spaces === 0) return 'full';
  if (station.available_bike <= MARGINAL) return 'hempty';
  if (station.available_spaces <= MARGINAL) return 'hfull';
  return 'okay';
}
module.exports = app;
    }
  };
});
telobike.pkg(1, function(parents){
  return {
    'id':2,
    'name':'uijs',
    'main':undefined,
    'mainModuleId':'lib/index',
    'modules':[],
    'parents':parents
  };
});
telobike.module(2, function(/* parent */){
  return {
    'id': 'lib/animation',
    'pkg': arguments[0],
    'wrapper': function(module, exports, global, Buffer,process, require, undefined){
      // -- animation
var constant = require('./util').constant;
var curves = exports.curves = {};
curves.linear = function() {
  return function(x) {
    return x;
  };
};
curves.easeInEaseOut = function() {
  return function(x) {
    return (1 - Math.sin(Math.PI / 2 + x * Math.PI)) / 2;
  };
};
module.exports = function(from, to, options) {
  options = options || {};
  options.duration = options.duration || constant(250);
  options.callback = options.callback || function() { };
  options.curve = options.curve || curves.easeInEaseOut();
  options.name = options.name || from.toString() + '_to_' + to.toString();
  var startTime = Date.now();
  var endTime = Date.now() + options.duration();
  var callbackCalled = false;
  // console.time(options.name);
  return function () {
    var elapsedTime = Date.now() - startTime;
    var ratio = elapsedTime / options.duration();
    if (ratio < 1.0) {
      curr = from + (to - from) * options.curve(ratio);
    }
    else {
      // console.timeEnd(options.name);
      curr = to;
      if (options.callback && !callbackCalled) {
        options.callback.call(this);
        callbackCalled = true;
      }
    }
    return curr;
  };
};
    }
  };
});
telobike.module(2, function(/* parent */){
  return {
    'id': 'lib/app',
    'pkg': arguments[0],
    'wrapper': function(module, exports, global, Buffer,process, require, undefined){
      var view = require('./view');
var defaults = require('./util').defaults;
var constant = require('./util').constant;
module.exports = function(options) {
  return view(defaults(options, {
    dockStyle: constant('fill'),
  }));
}
    }
  };
});
telobike.module(2, function(/* parent */){
  return {
    'id': 'lib/button',
    'pkg': arguments[0],
    'wrapper': function(module, exports, global, Buffer,process, require, undefined){
      var view = require('./view');
var layouts = require('./layouts');
var image = require('./image');
var constant = require('./util').constant;
var derive = require('./util').derive;
var valueof = require('./util').valueof;
var defaults = require('./util').defaults;
module.exports = function(options) {
  options = defaults(options, {
    radius: constant(10),
    layouts: layouts.dock(),
    font: constant('xx-large Helvetica'),
    text: constant('button'),
    width: constant(400),
    height: constant(80),
    fillStyle: constant('white'),
    strokeStyle: constant('black'),
    lineWidth: constant(3),
    textFillStyle: constant('black'),
    shadowColor: constant('rgba(0,0,0,0.5)'),
    shadowBlur: constant(15),
  });
  // highlighted state
  options.highlighted = defaults(options.highlighted, {
    fillStyle: constant('#666666'),
  });
  var self = view(options);
  self.on('touchstart', function(c) { self.override = derive(self.highlighted); });
  self.on('touchend',   function(c) { self.override = null; });
  self.on('mousedown',  function(c) { self.emit('touchstart', c); });
  self.on('mouseup',    function(c) { self.emit('touchend', c); });
  self.on('touchend', function(c) {
    if (c.x < 0 || c.x > self.width()) return;
    if (c.y < 0 || c.y > self.height()) return;
    return self.queue('click', c);
  });
  return self;
  }
    }
  };
});
telobike.module(2, function(/* parent */){
  return {
    'id': 'lib/canvasize',
    'pkg': arguments[0],
    'wrapper': function(module, exports, global, Buffer,process, require, undefined){
      var view = require('./view');
var constant = require('./util').constant;
var layouts = require('./layouts');
var INTERACTION_EVENTS = [
  'touchstart',
  'touchmove',
  'touchend',
  'mousedown',
  'mousemove',
  'mouseup',
];
module.exports = function(options) {
  options = options || {};
  window.requestAnimationFrame || (
    window.requestAnimationFrame = 
    window.webkitRequestAnimationFrame || 
    window.mozRequestAnimationFrame    || 
    window.oRequestAnimationFrame      || 
    window.msRequestAnimationFrame     || 
    function(cb) { setTimeout(cb, 1000/60); }
  );
  window.devicePixelRatio || (window.devicePixelRatio = 1);
  console.log('devicePixelRatio is', window.devicePixelRatio);
  var canvas = null;
  if (options.element) {
    canvas = options.element;
    canvas.width = canvas.width || parseInt(canvas.style.width) * window.devicePixelRatio;
    canvas.height = canvas.height || parseInt(canvas.style.height) * window.devicePixelRatio;
  }
  else {
    if (document.body.hasChildNodes()) {
      while (document.body.childNodes.length) {
        document.body.removeChild(document.body.firstChild);
      }
    }
    document.body.style.background = 'white';
    document.body.style.padding = '0px';
    document.body.style.margin = '0px';
    canvas = document.createElement('canvas');
    canvas.style.background = 'green';
    document.body.appendChild(canvas);
    window.onresize = function() {
      // http://joubert.posterous.com/crisp-html-5-canvas-text-on-mobile-phones-and
      canvas.width = window.innerWidth * window.devicePixelRatio;
      canvas.height = window.innerHeight * window.devicePixelRatio;
      canvas.style.width = window.innerWidth;
      canvas.style.height = window.innerHeight;
      var c = canvas.getContext('2d');
      c.scale(window.devicePixelRatio, window.devicePixelRatio);
    };
    document.body.onorientationchange = window.onresize;
    setTimeout(function() { 
      window.scrollTo(0, 0);
      window.onresize();
    }, 0);
    window.onresize();
  }
  var ctx = canvas.getContext('2d');
  options = options || {};
  options.id = options.id || constant('canvas');
  options.x = options.x || constant(0);
  options.y = options.y || constant(0);
  options.width = options.width || function() { return canvas.width / window.devicePixelRatio; };
  options.height = options.height || function() { return canvas.height / window.devicePixelRatio; };
  options.layout = options.layout || layouts.dock({ stretch: true });
  var main = view(options);
  // get the coordinates for a mouse or touch event
  // http://www.nogginbox.co.uk/blog/canvas-and-multi-touch
  function getCoords(e) {
    if (e.touches && e.touches.length > 0) {
      e = e.touches[0];
      return { x: e.pageX - canvas.offsetLeft, y: e.pageY - canvas.offsetTop };
    }
    else if (e.offsetX) {
      // works in chrome / safari (except on ipad/iphone)
      return { x: e.offsetX, y: e.offsetY };
    }
    else if (e.layerX) {
      // works in Firefox
      return { x: e.layerX, y: e.layerY };
    }
    else if (e.pageX) {
      // works in safari on ipad/iphone
      return { x: e.pageX - canvas.offsetLeft, y: e.pageY - canvas.offsetTop };
    }
  }
  // add mouse/touch interaction events
  INTERACTION_EVENTS.forEach(function(name) {
    canvas['on' + name] = function(e) {
      e.preventDefault();
      var coords = (name !== 'touchend') ? getCoords(e) : getCoords(e.changedTouches[0]);
      // coords.x *= window.devicePixelRatio;
      // coords.y *= window.devicePixelRatio;
      if (coords) main.log('on' + name, coords.x + ',' + coords.y);
      else main.log('error - no coords for ' + name);
      
      main.interact(name, coords, e);
    };
  });
  function redraw() {
    //TODO: since the canvas fills the screen we don't really need this?
    if (main.alpha && main.alpha() < 1.0) {
      ctx.clearRect(0, 0, canvas.width, canvas.height);
    }
    main.draw(ctx);
    window.requestAnimationFrame(redraw);
  }
  redraw();
  main.INTERACTION_EVENTS = INTERACTION_EVENTS;
  return main;
};
    }
  };
});
telobike.module(2, function(/* parent */){
  return {
    'id': 'lib/image',
    'pkg': arguments[0],
    'wrapper': function(module, exports, global, Buffer,process, require, undefined){
      var view = require('./view');
var defaults = require('./util').defaults;
var constant = require('./util').constant;
module.exports = function(options) {
  var obj = view(defaults(options, {
    stretch: constant(true),
  }));
  var base = {
    width: self.width,
    height: self.height,
  };
  // console.log('!!!');
  // obj.width = function() {
  //   var self = this;
  //   if (self.image && !self.stretch()) {
  //     return self.image.width;
  //   }
  //   else return base.width.call(self);
  // };
  // obj.height = function() {
  //   var self = this;
  //   if (self.image & !self.stretch()) {
  //     return self.image.height;
  //   }
  //   else return base.height.call(self);
  // };
  return obj;
};
    }
  };
});
telobike.module(2, function(/* parent */){
  return {
    'id': 'lib/index',
    'pkg': arguments[0],
    'wrapper': function(module, exports, global, Buffer,process, require, undefined){
      exports.canvasize = require('./canvasize');
exports.animation = require('./animation');
exports.util = require('./util');
exports.image = require('./image');
exports.label = require('./label');
exports.layouts = require('./layouts');
exports.rectangle = require('./rectangle');
exports.view = require('./view');
exports.button = require('./button');
exports.app = require('./app');
exports.terminal = require('./terminal');
exports.rterm = require('./rterm');
    }
  };
});
telobike.module(2, function(/* parent */){
  return {
    'id': 'lib/label',
    'pkg': arguments[0],
    'wrapper': function(module, exports, global, Buffer,process, require, undefined){
      var view = require('./view');
module.exports = function(options) {
  return view(options);
};
    }
  };
});
telobike.module(2, function(/* parent */){
  return {
    'id': 'lib/layouts',
    'pkg': arguments[0],
    'wrapper': function(module, exports, global, Buffer,process, require, undefined){
      var constant = require('./util').constant;
var max = require('./util').max;
var defaults = require('./util').defaults;
exports.stack = function(options) {
  options = options || {};
  options.padding = options.padding || constant(0);
  options.spacing = options.spacing || constant(0);
  options.stretch = options.stretch || constant(false);
  return function() {
    var parent = this;
    parent.on('after-add-child', function(child) {
      child.x = options.padding;
      if (options.stretch()) {
        child.width = function() {
          return parent.width() - options.padding() * 2 - child.shadowOffsetX();
        };
      }
      var prev = child.prev();
      if (!prev) {
        child.y = options.padding;
      }
      else {
        child.y = function() { 
          return prev.y() + prev.height() + options.spacing() + child.shadowOffsetY();
        };
      }
      // center
      child.x = function() {
        return parent.width() / 2 - this.width() / 2;
      };
    });
  };
};
exports.dock = function(options) {
  options = options || {};
  options.spacing = options.spacing || constant(0);
  options.padding = options.padding || constant(0);
  return function() {
    var parent = this;
    parent.dock = function(child, type) {
      var parent = this;
      var base = { 
        x: child.x, 
        y: child.y,
        width: child.width,
        height: child.height,
      };
      var adjust = 
      {
        left:   { width: false, height: true,  x: true,  y: false },
        right:  { width: false, height: true,  x: true,  y: false },
        top:    { width: true,  height: false, x: false, y: true  },
        bottom: { width: true,  height: false, x: false, y: true  },
        fill:   { width: true,  height: true,  x: false, y: false },
      }[type];
      if (adjust.x) {
        child.x = function() {
          var region = parent.unoccupied(child);
          return region.x + (type === 'right' ? region.width - child.width() - child.shadowOffsetX() : 0)
        };
      }
      if (adjust.y) {
        child.y = function() { 
          var region = parent.unoccupied(child);
          return region.y + (type === 'bottom' ? region.height - child.height() - child.shadowOffsetY() : 0);
        };
      }
      if (adjust.width) {
        child.x = function() {
          if (!child.dockOptions.center()) return base.x.call(child);
          var region = parent.unoccupied(child);
          return region.x + region.width / 2 - (child.width() + child.shadowOffsetX()) / 2; 
        };
        child.width = function() { 
          if (!child.dockOptions.stretch()) return base.width.call(child);
          var region = parent.unoccupied(child);
          return region.width - child.shadowOffsetX();
        };
      }
      if (adjust.height) {
        child.y = function() {
          if (!child.dockOptions.center()) return base.y.call(child);
          var region = parent.unoccupied(child);
          return region.y + region.height / 2 - (child.height() + child.shadowOffsetY()) / 2;
        };
        child.height = function() { 
          if (!child.dockOptions.stretch()) return base.height.call(child);
          var region = parent.unoccupied(child);
          return region.height - child.shadowOffsetY();
        };
      }
    };
    // returns the unoccupied region after distributing
    // frames for all children (up to `upto` child, if specified).
    parent.unoccupied = function(upto) {
      // start with the entire parent region
      var curr = {
        x: options.padding(),
        y: options.padding(),
        width: parent.width() - options.padding() * 2,
        height: parent.height() - options.padding() * 2,
      };
      for (var id in parent._children) {
        
        // break until we reach `upto`
        if (upto && upto._id == id) {
          break;
        }
        var child = parent._children[id];
        if (!child.visible()) continue;
        
        var dockStyle = (child.dockStyle && child.dockStyle()) || 'top';
        switch (dockStyle) {
          case 'top':
            curr.y += child.height() + options.spacing() + child.shadowOffsetY();
            curr.height -= child.height() + child.shadowOffsetY() + options.spacing();
            break;
          case 'bottom':
            curr.height -= child.height() + child.shadowOffsetY() + options.spacing();
            break;
          case 'left':
            curr.x += child.width() + options.spacing() + child.shadowOffsetX();
            curr.width -= child.width() + child.shadowOffsetX() + options.spacing();
            break;
          case 'right':
            curr.width -= child.width() + child.shadowOffsetX() + options.spacing();
            break;
          case 'fill':
            curr.width -= child.width() + child.shadowOffsetX();
            curr.height -= child.height() + child.shadowOffsetY();
            break;
        }
        if (curr.width < 0) curr.width = 0;
        if (curr.height < 0) curr.height = 0;
        if (curr.width === 0 || curr.height === 0) break;
      }
      return curr;
    };
    this.on('before-add-child', function(child) {
      var dockStyle = (child.dockStyle && child.dockStyle()) || 'top';
      child.dockOptions = defaults(child.dockOptions, {
        center: constant(true),
        stretch: constant(true),
      });
      parent.dock(child, dockStyle);
    });
  };
};
exports.none = function() {
  return function() { };
};
    }
  };
});
telobike.module(2, function(/* parent */){
  return {
    'id': 'lib/rectangle',
    'pkg': arguments[0],
    'wrapper': function(module, exports, global, Buffer,process, require, undefined){
      var view = require('./view');
module.exports = function(options) {
  return view(options);
}
    }
  };
});
telobike.module(2, function(/* parent */){
  return {
    'id': 'lib/rterm',
    'pkg': arguments[0],
    'wrapper': function(module, exports, global, Buffer,process, require, undefined){
      var view = require('./view');
var constant = require('./util').constant;
var defaults = require('./util').defaults;
module.exports = function(socket, options) {
  if (!socket) throw new Error('`socket` is required');
  var obj = view(defaults(options, {
    id: constant('#terminal'),
    visible: constant(false),
  }));
  obj.writeLine = function() {
    var args = [];
    
    for (var i = 0; i < arguments.length; ++i) {
      args.push(arguments[i]);
    }
    var line = {
      time: Date.now(),
      data: args.join(' '),
    };
    socket.emit('log', line);
    return line;
  };
  return obj;
};
    }
  };
});
telobike.module(2, function(/* parent */){
  return {
    'id': 'lib/terminal',
    'pkg': arguments[0],
    'wrapper': function(module, exports, global, Buffer,process, require, undefined){
      var view = require('./view');
var constant = require('./util').constant;
var max = require('./util').max;
module.exports = function(options) {
  options = options || {};
  options.bufferSize = options.bufferSize || constant(100);
  options.id = options.id || constant('#terminal'); // for `view.log(...)`
  options.lineHeight = options.lineHeight || constant(12);
  var self = view(options);
  self.fillStyle = constant('black');
  var lines = [];
  self.writeLine = function(s) {
    var line = {
      data: s,
      time: Date.now()
    };
    lines.push(line);
    var bufferSize = self.bufferSize && self.bufferSize();
    if (bufferSize) {
      while (lines.length > bufferSize) {
        lines.shift();
      }
    }
    return line;
  };
  var _ondraw = self.ondraw;
  self.ondraw = function(ctx) {
    _ondraw.call(self, ctx);
    ctx.save();
    var lineHeight = self.lineHeight();
    ctx.font = lineHeight + 'px Courier';
    ctx.textAlign = 'left';
    // calculate how many lines can fit into the terminal
    var maxLines = self.height() / lineHeight;
    var first = max(0, Math.round(lines.length - maxLines) + 1);
    var y = 0;
    for (var i = first; i < lines.length; ++i) {
      var line = lines[i].data;
      var now = '[' + new Date(lines[i].time).toISOString().replace(/.*T/, '') + '] ';
      ctx.fillStyle = 'gray';
      ctx.fillText(now, 0, y);
      ctx.fillStyle = 'white';
      ctx.fillText(line, ctx.measureText(now).width, y);
      y += lineHeight;
    }
    ctx.restore();
  };
  return self;
}
    }
  };
});
telobike.module(2, function(/* parent */){
  return {
    'id': 'lib/util',
    'pkg': arguments[0],
    'wrapper': function(module, exports, global, Buffer,process, require, undefined){
      exports.constant = function(x) { return function() { return x; }; };
exports.centerx = function(target, delta) { return function() { return target.width() / 2 - this.width() / 2 + (delta || 0); }; };
exports.centery = function(target, delta) { return function() { return target.height() / 2 - this.height() / 2 + (delta || 0); }; };
exports.top = function(target, delta) { return function() { return (delta || 0); }; };
exports.left = function(target, delta) { return function() { return (delta || 0); }; };
exports.right = function(target, delta) { return function() { return target.width() + (delta || 0); }; };
exports.bottom = function(target, delta) { return function() { return target.height() + (delta || 0); }; };
exports.min = function(a, b) { return a < b ? a : b; };
exports.max = function(a, b) { return a > b ? a : b; };
// returns a function that creates a new object linked to `this` (`Object.create(this)`).
// any property specified in `options` (if specified) is assigned to the child object.
exports.derive = function(options) {
  return function() {
    var obj = Object.create(this);
    obj.base = this;
    if (options) {
      for (var k in options) {
        obj[k] = options[k];
      }
    }
    return obj;
  };  
};
// returns the value of `obj.property` if it is defined (could be `null` too)
// if not, returns `def` (or false). useful for example in tri-state attributes where `null` 
// is used to disregard it in the drawing process (e.g. `fillStyle`).
exports.valueof = function(obj, property, def) {
  if (!obj) throw new Error('`obj` is required');
  if (!def) def = false;
  if (!(property in obj)) return def;
  else return obj[property];
};
exports.defaults = function(target, source) {
  var valueof = exports.valueof;
  target = target || {};
  for (var k in source) {
    target[k] = valueof(target, k, source[k]);
  }
  return target;
};
exports.loadimage = function(src) {
  if (typeof src === 'function') src = src();
  
  var img = new Image();
  img.src = src;
  img.onload = function() { };
  return function() {
    return img;
  }
};
    }
  };
});
telobike.module(2, function(/* parent */){
  return {
    'id': 'lib/view',
    'pkg': arguments[0],
    'wrapper': function(module, exports, global, Buffer,process, require, undefined){
      var layouts = require('./layouts');
var constant = require('./util').constant;
var valueof = require('./util').valueof;
module.exports = function(options) {
  var view       = options       || {};
  view.x         = view.x        || function() { return 0; };
  view.y         = view.y        || function() { return 0; };
  view.width     = view.width    || function() { return 100; };
  view.height    = view.height   || function() { return 50; };
  view.rotation  = view.rotation || function() { return 0; };
  view.visible   = view.visible  || function() { return true; };
  view.clip      = view.clip     || function() { return true; };
  view.layout    = view.layout   || layouts.stack();
  view.alpha     = view.alpha    || null;
  view.override  = view.override || null;
  view.id        = view.id       || function() { return this._id; };
  view.terminal  = view.terminal || function() { return this.query('#terminal'); };
  
  view.shadowOffsetX = valueof(view, 'shadowOffsetX') || function() { return 0; };
  view.shadowOffsetY = valueof(view, 'shadowOffsetY') || function() { return 0; };
  view.shadowBlur    = valueof(view, 'shadowBlur') || function() { return 0; };
  view.shadowColor   = valueof(view, 'shadowColor') || function() { return 'black'; };
  view.font              = valueof(view, 'font')           || function() { return '16pt Helvetica'; };
  view.textShadowBlur    = valueof(view, 'textShadowBlur') || function() { return 0; };
  view.textShadowColor   = valueof(view, 'textShadowColor') || function() { return 'black' };
  view.textShadowOffsetX = valueof(view, 'textShadowOffsetX') || function() { return 0; };
  view.textShadowOffsetY = valueof(view, 'textShadowOffsetY') || function() { return 0; };
  // rect
  view.radius    = view.radius || constant(0);
  // image
  view.imagesrc  = view.imagesrc || null;
  view.image     = view.image    || null;
  
  // text
  view.text              = view.text || null;
  view.textBaseline      = view.textBaseline || constant('top');
  view.textAlign         = view.textAlign || constant('center');
  view.textVerticalAlign = view.textVerticalAlign || constant('middle');
  view._id       = '<unattached>';
  view._is_view  = true;
  view._children = {};
  view._nextid   = 0;
  if (!('textFillStyle' in view) && !('textStrokeStyle' in view)) {
    view.textFillStyle = constant('black');
  }
  if (view.imagesrc) {
    var img = new Image();
    img.src = view.imagesrc();
    img.onload = function() { view.image = this; }
  }
  // -- log
  // logs to the terminal associated with this view
  view.log = function() {
    var self = this;
    var term = self.terminal();
    if (!term) return;
    var args = [];
    var id = (self.id && self.id()) || self._id;
    args.push('[' + id + ']');
    for (var i = 0; i < arguments.length; ++i) {
      args.push(arguments[i]);
    }
    term.writeLine(args.join(' '));
  };
  // -- event emitter
  var _subscriptions = {};
  view.emit = function(event) {
    var self = this;
    var handlers = _subscriptions[event];
    var handled;
    if (handlers) {
      var args = [];
      for (var i = 1; i < arguments.length; ++i) {
        args.push(arguments[i]);
      }
      handlers.forEach(function(fn) {
        var ret = fn.apply(self, args);
        if (typeof ret === 'undefined' || ret === true) handled = true;
        if (ret === false) handled = false;
      });
    }
    return handled;
  };
  // emits the event (with arguments) after 100ms
  // should be used to allow ui to update when emitting
  // events from event handlers.
  view.queue = function(event) {
    var self = this;
    var args = arguments;
    console.log('emitting later', event);
    setTimeout(function() {
      self.emit.apply(self, args);
    }, 50);
  };
  view.on = function(event, handler) {
    var self = this;
    if (!_subscriptions) return;
    var handlers = _subscriptions[event];
    if (!handlers) handlers = _subscriptions[event] = [];
    handlers.push(handler);
  };  
  // call layout initialization function on the child
  if (view.layout) {
    view.layout();
  }
  // -- children/parents
  // returns the root of the view hierarchy
  view.root = function() {
    var self = this;
    if (!self.parent) return self;
    return self.parent.root();
  };
  // adds a child to the end of the children's stack.
  view.add = function(child) {
    var self = this;
    if (Array.isArray(child)) {
      return child.forEach(function(c) {
        self.add(c);
      });
    }
    if (!child._is_view) throw new Error('can only add views as children to a view');
    var previd = self._nextid;
    child._id = self._nextid++;
    child.parent = self;
    child.bringToTop = function() {
      self.remove(child);
      self.add(child);
    };
    child.remove = function() {
      self.remove(child);
    };
    child.prev = function() {
      var prev = null;
      
      for (var id in self._children) {
        if (id == child._id) {
          return self._children[prev];
        }
        prev = id;
      }
      return null;
    };
    var allow = true;
    var ret = self.emit('before-add-child', child);
    if (typeof ret === 'undefined') allow = true;
    else allow = !!ret;
    if (allow) {
      self._children[child._id] = child;
      self.emit('after-add-child', child);
    }
  };
  // removes a child
  view.remove = function(child) {
    var self = this;
    delete self._children[child._id];
    child.parent = null;
    return child;
  };
  // removes all children
  view.empty = function() {
    var self = this;
    for (var k in self._children) {
      self.remove(self._children[k]);
    }
  };
  // retrieve a child by it's `id()` property. children without
  // this property cannot be retrieved using this function.
  view.get = function(id) {
    var self = this;
    for (var k in self._children) {
      var child = self._children[k];
      if (child.id && child.id() === id) {
        return child;
      }
    }
    return null;
  };
  // retrieve a child from the entire view tree by id.
  view.query = function(id) {
    var self = this;
    var child = self.get(id);
    if (!child) {
      for (var k in self._children) {
        var found = self._children[k].query(id);
        if (found) {
          child = found;
          break;
        }
      }
    }
    return child;
  };
  // -- drawing
  // default draw for view is basically to draw a rectangle
  view.ondraw = function(ctx) {
    var self = this;
    var radius = (self.radius && self.radius()) || 0;
    ctx.beginPath();
    ctx.moveTo(radius, 0);
    ctx.lineTo(self.width() - radius, 0);
    if (radius) ctx.quadraticCurveTo(self.width(), 0, self.width(), radius);
    ctx.lineTo(self.width(), self.height() - radius);
    if (radius) ctx.quadraticCurveTo(self.width(), self.height(), self.width() - radius, self.height());
    ctx.lineTo(radius, self.height());
    if (radius) ctx.quadraticCurveTo(0, self.height(), 0, self.height() - radius);
    ctx.lineTo(0, radius);
    if (radius) ctx.quadraticCurveTo(0, 0, radius, 0);
    ctx.closePath();
    
    self.drawFill(ctx);
    self.drawImage(ctx);
    self.drawBorder(ctx);
    self.drawText(ctx);
  };
  view.drawFill = function(ctx) {
    var self = this;
    if (!self.fillStyle) return;
    ctx.fill();
  };
  view.drawBorder = function(ctx) {
    var self = this;
    if (!self.strokeStyle) return;
    // we don't want shadow on the border
    ctx.save();
    ctx.shadowOffsetY = 0;
    ctx.shadowOffsetX = 0;
    ctx.shadowBlur = 0;
    ctx.stroke();
    ctx.restore();
  };
  view.drawImage = function(ctx) {
    var self = this;
    if (self.image) {
      var img = self.image();
      if (!img) return;
      ctx.drawImage(img, 0, 0, self.width(), self.height());
    }
  }
  view.drawText = function(ctx) {
    var self = this;
    if (!self.text || !self.text() || self.text().length === 0) return;
    if (!self.textFillStyle && !self.textStrokeStyle) return;
    var text = self.text();
    var width = self.width();
    var height = self.height();
    var top = 0;
    var left = 0;
    // http://stackoverflow.com/questions/1134586/how-can-you-find-the-height-of-text-on-an-html-canvas
    var textHeight = ctx.measureText('ee').width;
    switch (ctx.textAlign) {
      case 'start':
      case 'left': left = 0; break;
      case 'end':
      case 'right': left = width; break;
      case 'center': left = width / 2; break;
    }
    switch (self.textVerticalAlign()) {
      case 'top': top = 0; break;
      case 'middle': top = height / 2 - textHeight / 2; break;
      case 'bottom': top = height - textHeight; break;
    }
    ctx.save();
    if (self.textShadowBlur) ctx.shadowBlur = self.textShadowBlur();
    if (self.textShadowColor) ctx.shadowColor = self.textShadowColor();
    if (self.textShadowOffsetX) ctx.shadowOffsetX = self.textShadowOffsetX();
    if (self.textShadowOffsetY) ctx.shadowOffsetY = self.textShadowOffsetY();
    if (self.textFillStyle) {
      var s = self.textFillStyle();
      if (s && s !== '') {
        ctx.fillStyle = self.textFillStyle();
        ctx.fillText(text, left, top, width);
      }
    }
    if (self.textStrokeStyle) {
      var s = self.textStrokeStyle();
      if (s && s !== '') {
        ctx.strokeStyle = s;
        ctx.strokeText(text, left, top, width);
      }
    }
    ctx.restore();
  };
  view._self = function() {
    var override = this.override && this.override();
    if (override) return override;
    else return this;
  };
  view.draw = function(ctx) {
    var self = this._self();
    ctx.save();
    if (self.rotation && self.rotation()) {
      var centerX = self.x() + self.width() / 2;
      var centerY = self.y() + self.height() / 2;
      ctx.translate(centerX, centerY);
      ctx.rotate(self.rotation());
      ctx.translate(-centerX, -centerY);
    }
    if (self.visible()) {
      // stuff that applies to all children
      ctx.translate(self.x(), self.y());
      if (self.alpha) ctx.globalAlpha = self.alpha();
      ctx.save();
      // stuff that applies only to this child
      if (self.fillStyle) ctx.fillStyle = self.fillStyle();
      if (self.shadowBlur) ctx.shadowBlur = self.shadowBlur();
      if (self.shadowColor) ctx.shadowColor = self.shadowColor();
      if (self.shadowOffsetX) ctx.shadowOffsetX = self.shadowOffsetX();
      if (self.shadowOffsetY) ctx.shadowOffsetY = self.shadowOffsetY();
      if (self.lineCap) ctx.lineCap = self.lineCap();
      if (self.lineJoin) ctx.lineJoin = self.lineJoin();
      if (self.lineWidth) ctx.lineWidth = self.lineWidth();
      if (self.strokeStyle) ctx.strokeStyle = self.strokeStyle();
      if (self.font) ctx.font = self.font();
      if (self.textAlign) ctx.textAlign = self.textAlign();
      if (self.textBaseline) ctx.textBaseline = self.textBaseline();
      if (self.ondraw) {
        if (self.width() > 0 && self.height() > 0) {
          self.ondraw(ctx);
        }
      }
      ctx.restore();
      if (self.clip()) {
        ctx.beginPath();
        ctx.moveTo(0, 0);
        ctx.lineTo(self.width(), 0);
        ctx.lineTo(self.width(), self.height());
        ctx.lineTo(0, self.height());
        ctx.closePath();
        ctx.clip();
      }
      Object.keys(self._children).forEach(function(key) {
        var child = self._children[key];
        child.draw.call(child, ctx);
      });
      ctx.restore();
    }
  };
  // returns the first child
  view.first = function() {
    var self = this;
    var keys = self._children && Object.keys(self._children);
    if (!keys || keys.length === 0) return null;
    return self._children[keys[0]];
  };
  // if `children` is defined in construction, add them and
  // replace with a property so we can treat children as an array
  if (view.children) {
    view.add(view.children);
    delete view.children;
  }
  // -- interactivity
  // returns {x,y} in child coordinates
  view.hittest = function(child, pt) {
    var self = this;
    if (pt.x >= child.x() &&
        pt.y >= child.y() &&
        pt.x <= child.x() + child.width() &&
        pt.y <= child.y() + child.height()) {
      
      // convert to child coords
      var child_x = pt.x - child.x();
      var child_y = pt.y - child.y();
      return { x: child_x, y: child_y };
    }
    return null;
  };
  var current_handler = null;
  view._propagate = function(event, pt, e) {
    var self = this;
    var handler = null;
    for (var id in self._children) {
      var child = self._children[id];
      var child_pt = self.hittest(child, pt);
      if (child_pt) {
        var child_handler = child.interact(event, child_pt, e);
        if (child_handler) handler = child_handler;
      }
    }
    if (!handler) {
      if (self.emit(event, pt, e)) {
        handler = self;
      }
    }
    if (handler) self.log(event, 'handled by', handler.id());
    return handler;
  }
  // called with a mouse/touch event and relative coords
  // and propogates to child views. if child view did not handle
  // the event, the event is emitted to the parent (dfs).
  view.interact = function(event, pt, e) {
    var self = this;
    if (event === 'touchstart' || event === 'mousedown') {
      current_handler = null;
      var handler = self._propagate(event, pt, e);
      if (handler) current_handler = handler;
      return current_handler;
    }
    // check if we already have an ongoing touch
    if (current_handler) {
      // convert pt to current handler coordinates.
      var current_handler_screen = current_handler.screen();
      var this_screen = self.screen();
      var delta = {
        x: current_handler_screen.x - this_screen.x,
        y: current_handler_screen.y - this_screen.y,
      };
      pt = {
        x: pt.x - delta.x,
        y: pt.y - delta.y,
      };
      var handled = current_handler.emit(event, pt, e);
      if (event === 'touchend' || event === 'mouseup') current_handler = null;
      return handled ? self : null;
    }
    return null;
  };
  // returns the screen coordinates of this view
  view.screen = function() {
    var self = this;
    var pscreen = self.parent ? self.parent.screen() : { x: 0, y: 0 };
    return {
      x: pscreen.x + self.x(),
      y: pscreen.y + self.y()
    };
  };
  return view;
};
    }
  };
});
telobike.module(2, function(/* parent */){
  return {
    'id': 'lib/index',
    'pkg': arguments[0],
    'wrapper': function(module, exports, global, Buffer,process, require, undefined){
      exports.canvasize = require('./canvasize');
exports.animation = require('./animation');
exports.util = require('./util');
exports.image = require('./image');
exports.label = require('./label');
exports.layouts = require('./layouts');
exports.rectangle = require('./rectangle');
exports.view = require('./view');
exports.button = require('./button');
exports.app = require('./app');
exports.terminal = require('./terminal');
exports.rterm = require('./rterm');
    }
  };
});
telobike.pkg(1, function(parents){
  return {
    'id':3,
    'name':'xui',
    'main':undefined,
    'mainModuleId':'lib/xui',
    'modules':[],
    'parents':parents
  };
});
telobike.module(3, function(/* parent */){
  return {
    'id': 'lib/xui-2.3.2',
    'pkg': arguments[0],
    'wrapper': function(module, exports, global, Buffer,process, require, undefined){
      module.exports = function() {
(function () {
/**
	Basics
	======
    
    xui is available as the global `x$` function. It accepts a CSS selector string or DOM element, or an array of a mix of these, as parameters,
    and returns the xui object. For example:
    
        var header = x$('#header'); // returns the element with id attribute equal to "header".
        
    For more information on CSS selectors, see the [W3C specification](http://www.w3.org/TR/CSS2/selector.html). Please note that there are
    different levels of CSS selector support (Levels 1, 2 and 3) and different browsers support each to different degrees. Be warned!
    
	The functions described in the docs are available on the xui object and often manipulate or retrieve information about the elements in the
	xui collection.
*/
var undefined,
    xui,
    window     = this,
    string     = new String('string'), // prevents Goog compiler from removing primative and subsidising out allowing us to compress further
    document   = window.document,      // obvious really
    simpleExpr = /^#?([\w-]+)$/,   // for situations of dire need. Symbian and the such        
    idExpr     = /^#/,
    tagExpr    = /<([\w:]+)/, // so you can create elements on the fly a la x$('<img href="/foo" /><strong>yay</strong>')
    slice      = function (e) { return [].slice.call(e, 0); };
    try { var a = slice(document.documentElement.childNodes)[0].nodeType; }
    catch(e){ slice = function (e) { var ret=[]; for (var i=0; e[i]; i++) ret.push(e[i]); return ret; }; }
window.x$ = window.xui = xui = function(q, context) {
    return new xui.fn.find(q, context);
};
// patch in forEach to help get the size down a little and avoid over the top currying on event.js and dom.js (shortcuts)
if (! [].forEach) {
    Array.prototype.forEach = function(fn) {
        var len = this.length || 0,
            i = 0,
            that = arguments[1]; // wait, what's that!? awwww rem. here I thought I knew ya!
                                 // @rem - that that is a hat tip to your thats :)
        if (typeof fn == 'function') {
            for (; i < len; i++) {
                fn.call(that, this[i], i, this);
            }
        }
    };
}
/*
 * Array Remove - By John Resig (MIT Licensed) 
 */
function removex(array, from, to) {
    var rest = array.slice((to || from) + 1 || array.length);
    array.length = from < 0 ? array.length + from: from;
    return array.push.apply(array, rest);
}
// converts all CSS style names to DOM style names, i.e. margin-left to marginLeft
function domstyle(name) {
  return name.replace(/\-[a-z]/g,function(m) { return m[1].toUpperCase(); });
}
// converts all DOM style names to CSS style names, i.e. marginLeft to margin-left
function cssstyle(name) {
  return name.replace(/[A-Z]/g, function(m) { return '-'+m.toLowerCase(); })
}
xui.fn = xui.prototype = {
/**
	extend
	------
	Extends XUI's prototype with the members of another object.
	### syntax ###
		xui.extend( object );
	### arguments ###
	- object `Object` contains the members that will be added to XUI's prototype.
 
	### example ###
	Given:
		var sugar = {
		    first: function() { return this[0]; },
		    last:  function() { return this[this.length - 1]; }
		}
	We can extend xui's prototype with members of `sugar` by using `extend`:
		xui.extend(sugar);
	Now we can use `first` and `last` in all instances of xui:
		var f = x$('.button').first();
		var l = x$('.notice').last();
*/
    extend: function(o) {
        for (var i in o) {
            xui.fn[i] = o[i];
        }
    },
/**
	find
	----
	Find the elements that match a query string. `x$` is an alias for `find`.
	### syntax ###
		x$( window ).find( selector, context );
	### arguments ###
	- selector `String` is a CSS selector that will query for elements.
	- context `HTMLElement` is the parent element to search from _(optional)_.
 
	### example ###
	Given the following markup:
		<ul id="first">
		    <li id="one">1</li>
		    <li id="two">2</li>
		</ul>
		<ul id="second">
		    <li id="three">3</li>
		    <li id="four">4</li>
		</ul>
	We can select list items using `find`:
		x$('li');                 // returns all four list item elements.
		x$('#second').find('li'); // returns list items "three" and "four"
*/
    find: function(q, context) {
        var ele = [], tempNode;
            
        if (!q) {
            return this;
        } else if (context == undefined && this.length) {
            ele = this.each(function(el) {
                ele = ele.concat(slice(xui(q, el)));
            }).reduce(ele);
        } else {
            context = context || document;
            // fast matching for pure ID selectors and simple element based selectors
            if (typeof q == string) {
              if (simpleExpr.test(q) && context.getElementById && context.getElementsByTagName) {
                  ele = idExpr.test(q) ? [context.getElementById(q.substr(1))] : context.getElementsByTagName(q);
                  // nuke failed selectors
                  if (ele[0] == null) { 
                    ele = [];
                  }
              // match for full html tags to create elements on the go
              } else if (tagExpr.test(q)) {
                  tempNode = document.createElement('i');
                  tempNode.innerHTML = q;
                  slice(tempNode.childNodes).forEach(function (el) {
                    ele.push(el);
                  });
              } else {
                  // one selector, check if Sizzle is available and use it instead of querySelectorAll.
                  if (window.Sizzle !== undefined) {
                    ele = Sizzle(q, context);
                  } else {
                    ele = context.querySelectorAll(q);
                  }
              }
              // blanket slice
              ele = slice(ele);
            } else if (q instanceof Array) {
                ele = q;
            } else if (q.nodeName || q === window) { // only allows nodes in
                // an element was passed in
                ele = [q];
            } else if (q.toString() == '[object NodeList]' ||
q.toString() == '[object HTMLCollection]' || typeof q.length == 'number') {
                ele = slice(q);
            }
        }
        // disabling the append style, could be a plugin (found in more/base):
        // xui.fn.add = function (q) { this.elements = this.elements.concat(this.reduce(xui(q).elements)); return this; }
        return this.set(ele);
    },
/**
	set
	---
	Sets the objects in the xui collection.
	### syntax ###
		x$( window ).set( array );
*/
    set: function(elements) {
        var ret = xui();
        ret.cache = slice(this.length ? this : []);
        ret.length = 0;
        [].push.apply(ret, elements);
        return ret;
    },
/**
	reduce
	------
	Reduces the set of elements in the xui object to a unique set.
	### syntax ###
		x$( window ).reduce( elements, index );
	### arguments ###
	- elements `Array` is an array of elements to reduce _(optional)_.
	- index `Number` is the last array index to include in the reduction. If unspecified, it will reduce all elements _(optional)_.
*/
    reduce: function(elements, b) {
        var a = [],
        elements = elements || slice(this);
        elements.forEach(function(el) {
            // question the support of [].indexOf in older mobiles (RS will bring up 5800 to test)
            if (a.indexOf(el, 0, b) < 0)
            a.push(el);
        });
        return a;
    },
/**
	has
	---
	Returns the elements that match a given CSS selector.
	### syntax ###
		x$( window ).has( selector );
	### arguments ###
	- selector `String` is a CSS selector that will match all children of the xui collection.
	### example ###
	Given:
		<div>
		    <div class="round">Item one</div>
		    <div class="round">Item two</div>
		</div>
	
	We can use `has` to select specific objects:
		var divs    = x$('div');          // got all three divs.
		var rounded = divs.has('.round'); // got two divs with the class .round
*/
     has: function(q) {
         var list = xui(q);
         return this.filter(function () {
             var that = this;
             var found = null;
             list.each(function (el) {
                 found = (found || el == that);
             });
             return found;
         });
     },
/**
	filter
	------
	Extend XUI with custom filters. This is an interal utility function, but is also useful to developers.
	### syntax ###
		x$( window ).filter( fn );
	### arguments ###
	- fn `Function` is called for each element in the XUI collection.
	        // `index` is the array index of the current element
	        function( index ) {
	            // `this` is the element iterated on
	            // return true to add element to new XUI collection
	        }
	### example ###
	Filter all the `<input />` elements that are disabled:
		x$('input').filter(function(index) {
		    return this.checked;
		});
*/
    filter: function(fn) {
        var elements = [];
        return this.each(function(el, i) {
            if (fn.call(el, i)) elements.push(el);
        }).set(elements);
    },
/**
	not
	---
	The opposite of `has`. It modifies the elements and returns all of the elements that do __not__ match a CSS query.
	### syntax ###
		x$( window ).not( selector );
	### arguments ###
	- selector `String` a CSS selector for the elements that should __not__ be matched.
	### example ###
	Given:
		<div>
		    <div class="round">Item one</div>
		    <div class="round">Item two</div>
		    <div class="square">Item three</div>
		    <div class="shadow">Item four</div>
		</div>
	We can use `not` to select objects:
		var divs     = x$('div');          // got all four divs.
		var notRound = divs.not('.round'); // got two divs with classes .square and .shadow
*/
    not: function(q) {
        var list = slice(this),
            omittedNodes = xui(q);
        if (!omittedNodes.length) {
            return this;
        }
        return this.filter(function(i) {
            var found;
            omittedNodes.each(function(el) {
                return found = list[i] != el;
            });
            return found;
        });
    },
/**
	each
	----
	Element iterator for an XUI collection.
	### syntax ###
		x$( window ).each( fn )
	### arguments ###
	- fn `Function` callback that is called once for each element.
		    // `element` is the current element
		    // `index` is the element index in the XUI collection
		    // `xui` is the XUI collection.
		    function( element, index, xui ) {
		        // `this` is the current element
		    }
	### example ###
		x$('div').each(function(element, index, xui) {
		    alert("Here's the " + index + " element: " + element);
		});
*/
    each: function(fn) {
        // we could compress this by using [].forEach.call - but we wouldn't be able to support
        // fn return false breaking the loop, a feature I quite like.
        for (var i = 0, len = this.length; i < len; ++i) {
            if (fn.call(this[i], this[i], i, this) === false)
            break;
        }
        return this;
    }
};
xui.fn.find.prototype = xui.fn;
xui.extend = xui.fn.extend;
/**
	DOM
	===
	Set of methods for manipulating the Document Object Model (DOM).
*/
xui.extend({
/**
	html
	----
	Manipulates HTML in the DOM. Also just returns the inner HTML of elements in the collection if called with no arguments.
	### syntax ###
		x$( window ).html( location, html );
	or this method will accept just a HTML fragment with a default behavior of inner:
		x$( window ).html( html );
	or you can use shorthand syntax by using the location name argument as the function name:
		x$( window ).outer( html );
		x$( window ).before( html );
	
	or you can just retrieve the inner HTML of elements in the collection with:
	
	    x$( document.body ).html();
	### arguments ###
	- location `String` can be one of: _inner_, _outer_, _top_, _bottom_, _remove_, _before_ or _after_.
	- html `String` is a string of HTML markup or a `HTMLElement`.
	### example ###
		x$('#foo').html('inner', '<strong>rock and roll</strong>');
		x$('#foo').html('outer', '<p>lock and load</p>');
		x$('#foo').html('top',   '<div>bangers and mash</div>');
		x$('#foo').html('bottom','<em>mean and clean</em>');
		x$('#foo').html('remove');
		x$('#foo').html('before', '<p>some warmup html</p>');
		x$('#foo').html('after',  '<p>more html!</p>');
	or
		x$('#foo').html('<p>sweet as honey</p>');
		x$('#foo').outer('<p>free as a bird</p>');
		x$('#foo').top('<b>top of the pops</b>');
		x$('#foo').bottom('<span>bottom of the barrel</span>');
		x$('#foo').before('<pre>first in line</pre>');
		x$('#foo').after('<marquee>better late than never</marquee>');
*/
    html: function(location, html) {
        clean(this);
        if (arguments.length == 0) {
            var i = [];
            this.each(function(el) {
                i.push(el.innerHTML);
            });
            return i;
        }
        if (arguments.length == 1 && arguments[0] != 'remove') {
            html = location;
            location = 'inner';
        }
        if (location != 'remove' && html && html.each !== undefined) {
            if (location == 'inner') {
                var d = document.createElement('p');
                html.each(function(el) {
                    d.appendChild(el);
                });
                this.each(function(el) {
                    el.innerHTML = d.innerHTML;
                });
            } else {
                var that = this;
                html.each(function(el){
                    that.html(location, el);
                });
            }
            return this;
        }
        return this.each(function(el) {
            var parent, 
                list, 
                len, 
                i = 0;
            if (location == "inner") { // .html
                if (typeof html == string || typeof html == "number") {
                    el.innerHTML = html;
                    list = el.getElementsByTagName('SCRIPT');
                    len = list.length;
                    for (; i < len; i++) {
                        eval(list[i].text);
                    }
                } else {
                    el.innerHTML = '';
                    el.appendChild(html);
                }
            } else {
              if (location == 'remove') {
                el.parentNode.removeChild(el);
              } else {
                var elArray = ['outer', 'top', 'bottom'],
                    wrappedE = wrapHelper(html, (elArray.indexOf(location) > -1 ? el : el.parentNode )),
                    children = wrappedE.childNodes;
                if (location == "outer") { // .replaceWith
                  el.parentNode.replaceChild(wrappedE, el);
                } else if (location == "top") { // .prependTo
                    el.insertBefore(wrappedE, el.firstChild);
                } else if (location == "bottom") { // .appendTo
                    el.insertBefore(wrappedE, null);
                } else if (location == "before") { // .insertBefore
                    el.parentNode.insertBefore(wrappedE, el);
                } else if (location == "after") { // .insertAfter
                    el.parentNode.insertBefore(wrappedE, el.nextSibling);
                }
                var parent = wrappedE.parentNode;
                while(children.length) {
                  parent.insertBefore(children[0], wrappedE);
                }
                parent.removeChild(wrappedE);
              }
            }
        });
    },
/**
	attr
	----
	Gets or sets attributes on elements. If getting, returns an array of attributes matching the xui element collection's indices.
	### syntax ###
		x$( window ).attr( attribute, value );
	### arguments ###
	- attribute `String` is the name of HTML attribute to get or set.
	- value `Varies` is the value to set the attribute to. Do not use to get the value of attribute _(optional)_.
	### example ###
	To get an attribute value, simply don't provide the optional second parameter:
		x$('.someClass').attr('class');
	To set an attribute, use both parameters:
		x$('.someClass').attr('disabled', 'disabled');
*/
    attr: function(attribute, val) {
        if (arguments.length == 2) {
            return this.each(function(el) {
                if (el.tagName && el.tagName.toLowerCase() == 'input' && attribute == 'value') el.value = val;
                else if (el.setAttribute) {
                  if (attribute == 'checked' && (val == '' || val == false || typeof val == "undefined")) el.removeAttribute(attribute);
                  else el.setAttribute(attribute, val);
                }
            });
        } else {
            var attrs = [];
            this.each(function(el) {
                if (el.tagName && el.tagName.toLowerCase() == 'input' && attribute == 'value') attrs.push(el.value);
                else if (el.getAttribute && el.getAttribute(attribute)) {
                    attrs.push(el.getAttribute(attribute));
                }
            });
            return attrs;
        }
    }
});
"inner outer top bottom remove before after".split(' ').forEach(function (method) {
  xui.fn[method] = function(where) { return function (html) { return this.html(where, html); }; }(method);
});
// private method for finding a dom element
function getTag(el) {
    return (el.firstChild === null) ? {'UL':'LI','DL':'DT','TR':'TD'}[el.tagName] || el.tagName : el.firstChild.tagName;
}
function wrapHelper(html, el) {
  if (typeof html == string) return wrap(html, getTag(el));
  else { var e = document.createElement('div'); e.appendChild(html); return e; }
}
// private method
// Wraps the HTML in a TAG, Tag is optional
// If the html starts with a Tag, it will wrap the context in that tag.
function wrap(xhtml, tag) {
  var e = document.createElement('div');
  e.innerHTML = xhtml;
  return e;
}
/*
* Removes all erronious nodes from the DOM.
* 
*/
function clean(collection) {
    var ns = /\S/;
    collection.each(function(el) {
        var d = el,
            n = d.firstChild,
            ni = -1,
            nx;
        while (n) {
            nx = n.nextSibling;
            if (n.nodeType == 3 && !ns.test(n.nodeValue)) {
                d.removeChild(n);
            } else {
                n.nodeIndex = ++ni; // FIXME not sure what this is for, and causes IE to bomb (the setter) - @rem
            }
            n = nx;
        }
    });
}
/**
	Event
	=====
	A good old fashioned events with new skool handling. Shortcuts exist for:
	- click
	- load
	- touchstart
	- touchmove
	- touchend
	- touchcancel
	- gesturestart
	- gesturechange
	- gestureend
	- orientationchange
	
*/
xui.events = {}; var cache = {};
xui.extend({
/**
	on
	--
	Registers a callback function to a DOM event on the element collection.
	### syntax ###
		x$( 'button' ).on( type, fn );
	or
		x$( 'button' ).click( fn );
	### arguments ###
	- type `String` is the event to subscribe (e.g. _load_, _click_, _touchstart_, etc).
	- fn `Function` is a callback function to execute when the event is fired.
	### example ###
		x$( 'button' ).on( 'click', function(e) {
		    alert('hey that tickles!');
		});
	or
		x$(window).load(function(e) {
		  x$('.save').touchstart( function(evt) { alert('tee hee!'); }).css(background:'grey');
		});
*/
    on: function(type, fn, details) {
        return this.each(function (el) {
            if (xui.events[type]) {
                var id = _getEventID(el), 
                    responders = _getRespondersForEvent(id, type);
                
                details = details || {};
                details.handler = function (event, data) {
                    xui.fn.fire.call(xui(this), type, data);
                };
                
                // trigger the initialiser - only happens the first time around
                if (!responders.length) {
                    xui.events[type].call(el, details);
                }
            } 
            el.addEventListener(type, _createResponder(el, type, fn), false);
        });
    },
/**
	un
	--
	Unregisters a specific callback, or if no specific callback is passed in, 
	unregisters all event callbacks of a specific type.
	### syntax ###
	Unregister the given function, for the given type, on all button elements:
		x$( 'button' ).un( type, fn );
	Unregisters all callbacks of the given type, on all button elements:
		x$( 'button' ).un( type );
	### arguments ###
	- type `String` is the event to unsubscribe (e.g. _load_, _click_, _touchstart_, etc).
	- fn `Function` is the callback function to unsubscribe _(optional)_.
	### example ###
		// First, create a click event that display an alert message
		x$('button').on('click', function() {
		    alert('hi!');
		});
		
		// Now unsubscribe all functions that response to click on all button elements
		x$('button').un('click');
	or
		var greeting = function() { alert('yo!'); };
		
		x$('button').on('click', greeting);
		x$('button').on('click', function() {
		    alert('hi!');
		});
		
		// When any button is clicked, the 'hi!' message will fire, but not the 'yo!' message.
		x$('button').un('click', greeting);
*/
    un: function(type, fn) {
        return this.each(function (el) {
            var id = _getEventID(el), responders = _getRespondersForEvent(id, type), i = responders.length;
            while (i--) {
                if (fn === undefined || fn.guid === responders[i].guid) {
                    el.removeEventListener(type, responders[i], false);
                    removex(cache[id][type], i, 1);
                }
            }
            if (cache[id][type].length === 0) delete cache[id][type];
            for (var t in cache[id]) {
                return;
            }
            delete cache[id];
        });
    },
/**
	fire
	----
	Triggers a specific event on the xui collection.
	### syntax ###
		x$( selector ).fire( type, data );
	### arguments ###
	- type `String` is the event to fire (e.g. _load_, _click_, _touchstart_, etc).
	- data `Object` is a JSON object to use as the event's `data` property.
	### example ###
		x$('button#reset').fire('click', { died:true });
		
		x$('.target').fire('touchstart');
*/
    fire: function (type, data) {
        return this.each(function (el) {
            if (el == document && !el.dispatchEvent)
                el = document.documentElement;
            var event = document.createEvent('HTMLEvents');
            event.initEvent(type, true, true);
            event.data = data || {};
            event.eventName = type;
          
            el.dispatchEvent(event);
  	    });
  	}
});
"click load submit touchstart touchmove touchend touchcancel gesturestart gesturechange gestureend orientationchange".split(' ').forEach(function (event) {
  xui.fn[event] = function(action) { return function (fn) { return fn ? this.on(action, fn) : this.fire(action); }; }(event);
});
// patched orientation support - Andriod 1 doesn't have native onorientationchange events
xui(window).on('load', function() {
    if (!('onorientationchange' in document.body)) {
      (function (w, h) {
        xui(window).on('resize', function () {
          var portraitSwitch = (window.innerWidth < w && window.innerHeight > h) && (window.innerWidth < window.innerHeight),
              landscapeSwitch = (window.innerWidth > w && window.innerHeight < h) && (window.innerWidth > window.innerHeight);
          if (portraitSwitch || landscapeSwitch) {
            window.orientation = portraitSwitch ? 0 : 90; // what about -90? Some support is better than none
            xui('body').fire('orientationchange'); // will this bubble up?
            w = window.innerWidth;
            h = window.innerHeight;
          }
        });
      })(window.innerWidth, window.innerHeight);
    }
});
// this doesn't belong on the prototype, it belongs as a property on the xui object
xui.touch = (function () {
  try{
    return !!(document.createEvent("TouchEvent").initTouchEvent)
  } catch(e) {
    return false;
  };
})();
/**
	ready
	----
  Event handler for when the DOM is ready. Thank you [domready](http://www.github.com/ded/domready)!
	### syntax ###
		x$.ready(handler);
	### arguments ###
	- handler `Function` event handler to be attached to the "dom is ready" event.
	### example ###
    x$.ready(function() {
      alert('mah doms are ready');
    });
    xui.ready(function() {
      console.log('ready, set, go!');
    });
*/
xui.ready = function(handler) {
  domReady(handler);
}
// lifted from Prototype's (big P) event model
function _getEventID(element) {
    if (element._xuiEventID) return element._xuiEventID;
    return element._xuiEventID = ++_getEventID.id;
}
_getEventID.id = 1;
function _getRespondersForEvent(id, eventName) {
    var c = cache[id] = cache[id] || {};
    return c[eventName] = c[eventName] || [];
}
function _createResponder(element, eventName, handler) {
    var id = _getEventID(element), r = _getRespondersForEvent(id, eventName);
    var responder = function(event) {
        if (handler.call(element, event) === false) {
            event.preventDefault();
            event.stopPropagation();
        }
    };
    
    responder.guid = handler.guid = handler.guid || ++_getEventID.id;
    responder.handler = handler;
    r.push(responder);
    return responder;
}
/**
	Fx
	==
	Animations, transforms, and transitions for getting the most out of hardware accelerated CSS.
*/
xui.extend({
/**
	Tween
	-----
	Transforms a CSS property's value.
	### syntax ###
		x$( selector ).tween( properties, callback );
	### arguments ###
	- properties `Object` or `Array` of CSS properties to tween.
	    - `Object` is a JSON object that defines the CSS properties.
	    - `Array` is a `Object` set that is tweened sequentially.
	- callback `Function` to be called when the animation is complete. _(optional)_.
	### properties ###
	A property can be any CSS style, referenced by the JavaScript notation.
	A property can also be an option from [emile.js](https://github.com/madrobby/emile):
	- duration `Number` of the animation in milliseconds.
	- after `Function` is called after the animation is finished.
	- easing `Function` allows for the overriding of the built-in animation function.
			// Receives one argument `pos` that indicates position
			// in time between animation's start and end.
			function(pos) {
			    // return the new position
			    return (-Math.cos(pos * Math.PI) / 2) + 0.5;
			}
	### example ###
		// one JSON object
		x$('#box').tween({ left:'100px', backgroundColor:'blue' });
		x$('#box').tween({ left:'100px', backgroundColor:'blue' }, function() {
		    alert('done!');
		});
		
		// array of two JSON objects
		x$('#box').tween([{left:'100px', backgroundColor:'green', duration:.2 }, { right:'100px' }]); 
*/
	tween: function( props, callback ) {
    // creates an options obj for emile
    var emileOpts = function(o) {
      var options = {};
      "duration after easing".split(' ').forEach( function(p) {
        if (props[p]) {
            options[p] = props[p];
            delete props[p];
        }
      });
      return options;
    }
    // serialize the properties into a string for emile
    var serialize = function(props) {
      var serialisedProps = [], key;
      if (typeof props != string) {
        for (key in props) {
          serialisedProps.push(cssstyle(key) + ':' + props[key]);
        }
        serialisedProps = serialisedProps.join(';');
      } else {
        serialisedProps = props;
      }
      return serialisedProps;
    };
    // queued animations
    /* wtf is this?
		if (props instanceof Array) {
		    // animate each passing the next to the last callback to enqueue
		    props.forEach(function(a){
		      
		    });
		}
    */
    // this branch means we're dealing with a single tween
    var opts = emileOpts(props);
    var prop = serialize(props);
		
		return this.each(function(e){
			emile(e, prop, opts, callback);
		});
	}
});
/**
	Style
	=====
	Everything related to appearance. Usually, this is CSS.
*/
function hasClass(el, className) {
    return getClassRegEx(className).test(el.className);
}
// Via jQuery - used to avoid el.className = ' foo';
// Used for trimming whitespace
var rtrim = /^(\s|\u00A0)+|(\s|\u00A0)+$/g;
function trim(text) {
  return (text || "").replace( rtrim, "" );
}
xui.extend({
/**
	setStyle
	--------
	Sets the value of a single CSS property.
	### syntax ###
		x$( selector ).setStyle( property, value );
	### arguments ###
	- property `String` is the name of the property to modify.
	- value `String` is the new value of the property.
	### example ###
		x$('.flash').setStyle('color', '#000');
		x$('.button').setStyle('backgroundColor', '#EFEFEF');
*/
    setStyle: function(prop, val) {
        prop = domstyle(prop);
        return this.each(function(el) {
            el.style[prop] = val;
        });
    },
/**
	getStyle
	--------
	Returns the value of a single CSS property. Can also invoke a callback to perform more specific processing tasks related to the property value.
	Please note that the return type is always an Array of strings. Each string corresponds to the CSS property value for the element with the same index in the xui collection.
	### syntax ###
		x$( selector ).getStyle( property, callback );
	### arguments ###
	- property `String` is the name of the CSS property to get.
	- callback `Function` is called on each element in the collection and passed the property _(optional)_.
	### example ###
        <ul id="nav">
            <li class="trunk" style="font-size:12px;background-color:blue;">hi</li>
            <li style="font-size:14px;">there</li>
        </ul>
        
		x$('ul#nav li.trunk').getStyle('font-size'); // returns ['12px']
		x$('ul#nav li.trunk').getStyle('fontSize'); // returns ['12px']
		x$('ul#nav li').getStyle('font-size'); // returns ['12px', '14px']
		
		x$('ul#nav li.trunk').getStyle('backgroundColor', function(prop) {
		    alert(prop); // alerts 'blue' 
		});
*/
    getStyle: function(prop, callback) {
        // shortcut getComputedStyle function
        var s = function(el, p) {
            // this *can* be written to be smaller - see below, but in fact it doesn't compress in gzip as well, the commented
            // out version actually *adds* 2 bytes.
            // return document.defaultView.getComputedStyle(el, "").getPropertyValue(p.replace(/([A-Z])/g, "-$1").toLowerCase());
            return document.defaultView.getComputedStyle(el, "").getPropertyValue(cssstyle(p));
        }
        if (callback === undefined) {
        	var styles = [];
          this.each(function(el) {styles.push(s(el, prop))});
          return styles;
        } else return this.each(function(el) { callback(s(el, prop)); });
    },
/**
	addClass
	--------
	Adds a class to all of the elements in the collection.
	### syntax ###
		x$( selector ).addClass( className );
	### arguments ###
	- className `String` is the name of the CSS class to add.
	### example ###
		x$('.foo').addClass('awesome');
*/
    addClass: function(className) {
        var cs = className.split(' ');
        return this.each(function(el) {
            cs.forEach(function(clazz) {
              if (hasClass(el, clazz) === false) {
                el.className = trim(el.className + ' ' + clazz);
              }
            });
        });
    },
/**
	hasClass
	--------
	Checks if the class is on _all_ elements in the xui collection.
	### syntax ###
		x$( selector ).hasClass( className, fn );
	### arguments ###
	- className `String` is the name of the CSS class to find.
	- fn `Function` is a called for each element found and passed the element _(optional)_.
			// `element` is the HTMLElement that has the class
			function(element) {
			    console.log(element);
			}
	### example ###
        <div id="foo" class="foo awesome"></div>
        <div class="foo awesome"></div>
        <div class="foo"></div>
        
		// returns true
		x$('#foo').hasClass('awesome');
		
		// returns false (not all elements with class 'foo' have class 'awesome'),
		// but the callback gets invoked with the elements that did match the 'awesome' class
		x$('.foo').hasClass('awesome', function(element) {
		    console.log('Hey, I found: ' + element + ' with class "awesome"');
		});
		
		// returns true (all DIV elements have the 'foo' class)
		x$('div').hasClass('foo');
*/
    hasClass: function(className, callback) {
        var self = this,
            cs = className.split(' ');
        return this.length && (function() {
                var hasIt = true;
                self.each(function(el) {
                  cs.forEach(function(clazz) {
                    if (hasClass(el, clazz)) {
                        if (callback) callback(el);
                    } else hasIt = false;
                  });
                });
                return hasIt;
            })();
    },
/**
	removeClass
	-----------
	Removes the specified class from all elements in the collection. If no class is specified, removes all classes from the collection.
	### syntax ###
		x$( selector ).removeClass( className );
	### arguments ###
	- className `String` is the name of the CSS class to remove. If not specified, then removes all classes from the matched elements. _(optional)_
	### example ###
		x$('.foo').removeClass('awesome');
*/
    removeClass: function(className) {
        if (className === undefined) this.each(function(el) { el.className = ''; });
        else {
          var cs = className.split(' ');
          this.each(function(el) {
            cs.forEach(function(clazz) {
              el.className = trim(el.className.replace(getClassRegEx(clazz), '$1'));
            });
          });
        }
        return this;
    },
/**
	toggleClass
	-----------
	Removes the specified class if it exists on the elements in the xui collection, otherwise adds it. 
	### syntax ###
		x$( selector ).toggleClass( className );
	### arguments ###
	- className `String` is the name of the CSS class to toggle.
	### example ###
        <div class="foo awesome"></div>
        
		x$('.foo').toggleClass('awesome'); // div above loses its awesome class.
*/
    toggleClass: function(className) {
        var cs = className.split(' ');
        return this.each(function(el) {
            cs.forEach(function(clazz) {
              if (hasClass(el, clazz)) el.className = trim(el.className.replace(getClassRegEx(clazz), '$1'));
              else el.className = trim(el.className + ' ' + clazz);
            });
        });
    },
    
/**
	css
	---
	Set multiple CSS properties at once.
	### syntax ###
		x$( selector ).css( properties );
	### arguments ###
	- properties `Object` is a JSON object that defines the property name/value pairs to set.
	### example ###
		x$('.foo').css({ backgroundColor:'blue', color:'white', border:'2px solid red' });
*/
    css: function(o) {
        for (var prop in o) {
            this.setStyle(prop, o[prop]);
        }
        return this;
    }
});
// RS: now that I've moved these out, they'll compress better, however, do these variables
// need to be instance based - if it's regarding the DOM, I'm guessing it's better they're
// global within the scope of xui
// -- private methods -- //
var reClassNameCache = {},
    getClassRegEx = function(className) {
        var re = reClassNameCache[className];
        if (!re) {
            // Preserve any leading whitespace in the match, to be used when removing a class
            re = new RegExp('(^|\\s+)' + className + '(?:\\s+|$)');
            reClassNameCache[className] = re;
        }
        return re;
    };
/**
	XHR
	===
	Everything related to remote network connections.
 */
xui.extend({	
/**
	xhr
	---
	The classic `XMLHttpRequest` sometimes also known as the Greek hero: _Ajax_. Not to be confused with _AJAX_ the cleaning agent.
	### detail ###
	This method has a few new tricks.
	It is always invoked on an element collection and uses the behaviour of `html`.
	If there is no callback, then the `responseText` will be inserted into the elements in the collection.
	### syntax ###
		x$( selector ).xhr( location, url, options )
	or accept a url with a default behavior of inner:
		x$( selector ).xhr( url, options );
	or accept a url with a callback:
	
		x$( selector ).xhr( url, fn );
	### arguments ###
	- location `String` is the location to insert the `responseText`. See `html` for values.
	- url `String` is where to send the request.
	- fn `Function` is called on status 200 (i.e. success callback).
	- options `Object` is a JSON object with one or more of the following:
		- method `String` can be _get_, _put_, _delete_, _post_. Default is _get_.
		- async `Boolean` enables an asynchronous request. Defaults to _false_.
		- data `String` is a url encoded string of parameters to send.
                - error `Function` is called on error or status that is not 200. (i.e. failure callback).
		- callback `Function` is called on status 200 (i.e. success callback).
    - headers `Object` is a JSON object with key:value pairs that get set in the request's header set.
	### response ###
	- The response is available to the callback function as `this`.
	- The response is not passed into the callback.
	- `this.reponseText` will have the resulting data from the file.
	### example ###
		x$('#status').xhr('inner', '/status.html');
		x$('#status').xhr('outer', '/status.html');
		x$('#status').xhr('top',   '/status.html');
		x$('#status').xhr('bottom','/status.html');
		x$('#status').xhr('before','/status.html');
		x$('#status').xhr('after', '/status.html');
	or
		// same as using 'inner'
		x$('#status').xhr('/status.html');
		// define a callback, enable async execution and add a request header
		x$('#left-panel').xhr('/panel', {
		    async: true,
		    callback: function() {
		        alert("The response is " + this.responseText);
		    },
        headers:{
            'Mobile':'true'
        }
		});
		// define a callback with the shorthand syntax
		x$('#left-panel').xhr('/panel', function() {
		    alert("The response is " + this.responseText);
		});
*/
    xhr:function(location, url, options) {
      // this is to keep support for the old syntax (easy as that)
		if (!/^(inner|outer|top|bottom|before|after)$/.test(location)) {
            options = url;
            url = location;
            location = 'inner';
        }
        var o = options ? options : {};
        
        if (typeof options == "function") {
            // FIXME kill the console logging
            // console.log('we been passed a func ' + options);
            // console.log(this);
            o = {};
            o.callback = options;
        };
        
        var that   = this,
            req    = new XMLHttpRequest(),
            method = o.method || 'get',
            async  = (typeof o.async != 'undefined'?o.async:true),
            params = o.data || null,
            key;
        req.queryString = params;
        req.open(method, url, async);
        // Set "X-Requested-With" header
        req.setRequestHeader('X-Requested-With','XMLHttpRequest');
        if (method.toLowerCase() == 'post') req.setRequestHeader('Content-Type','application/x-www-form-urlencoded');
        for (key in o.headers) {
            if (o.headers.hasOwnProperty(key)) {
              req.setRequestHeader(key, o.headers[key]);
            }
        }
        req.handleResp = (o.callback != null) ? o.callback : function() { that.html(location, req.responseText); };
        req.handleError = (o.error && typeof o.error == 'function') ? o.error : function () {};
        function hdl(){
            if(req.readyState==4) {
                delete(that.xmlHttpRequest);
                if(req.status===0 || req.status==200) req.handleResp(); 
                if((/^[45]/).test(req.status)) req.handleError();
            }
        }
        if(async) {
            req.onreadystatechange = hdl;
            this.xmlHttpRequest = req;
        }
        req.send(params);
        if(!async) hdl();
        return this;
    }
});
// emile.js (c) 2009 Thomas Fuchs
// Licensed under the terms of the MIT license.
(function(emile, container){
  var parseEl = document.createElement('div'),
    props = ('backgroundColor borderBottomColor borderBottomWidth borderLeftColor borderLeftWidth '+
    'borderRightColor borderRightWidth borderSpacing borderTopColor borderTopWidth bottom color fontSize '+
    'fontWeight height left letterSpacing lineHeight marginBottom marginLeft marginRight marginTop maxHeight '+
    'maxWidth minHeight minWidth opacity outlineColor outlineOffset outlineWidth paddingBottom paddingLeft '+
    'paddingRight paddingTop right textIndent top width wordSpacing zIndex').split(' ');
  function interpolate(source,target,pos){ return (source+(target-source)*pos).toFixed(3); }
  function s(str, p, c){ return str.substr(p,c||1); }
  function color(source,target,pos){
    var i = 2, j, c, tmp, v = [], r = [];
    while(j=3,c=arguments[i-1],i--)
      if(s(c,0)=='r') { c = c.match(/\d+/g); while(j--) v.push(~~c[j]); } else {
        if(c.length==4) c='#'+s(c,1)+s(c,1)+s(c,2)+s(c,2)+s(c,3)+s(c,3);
        while(j--) v.push(parseInt(s(c,1+j*2,2), 16)); }
    while(j--) { tmp = ~~(v[j+3]+(v[j]-v[j+3])*pos); r.push(tmp<0?0:tmp>255?255:tmp); }
    return 'rgb('+r.join(',')+')';
  }
  
  function parse(prop){
    var p = parseFloat(prop), q = prop.replace(/^[\-\d\.]+/,'');
    return isNaN(p) ? { v: q, f: color, u: ''} : { v: p, f: interpolate, u: q };
  }
  
  function normalize(style){
    var css, rules = {}, i = props.length, v;
    parseEl.innerHTML = '<div style="'+style+'"></div>';
    css = parseEl.childNodes[0].style;
    while(i--) if(v = css[props[i]]) rules[props[i]] = parse(v);
    return rules;
  }  
  
  container[emile] = function(el, style, opts, after){
    el = typeof el == 'string' ? document.getElementById(el) : el;
    opts = opts || {};
    var target = normalize(style), comp = el.currentStyle ? el.currentStyle : getComputedStyle(el, null),
      prop, current = {}, start = +new Date, dur = opts.duration||200, finish = start+dur, interval,
      easing = opts.easing || function(pos){ return (-Math.cos(pos*Math.PI)/2) + 0.5; };
    for(prop in target) current[prop] = parse(comp[prop]);
    interval = setInterval(function(){
      var time = +new Date, pos = time>finish ? 1 : (time-start)/dur;
      for(prop in target)
        el.style[prop] = target[prop].f(current[prop].v,target[prop].v,easing(pos)) + target[prop].u;
      if(time>finish) { clearInterval(interval); opts.after && opts.after(); after && setTimeout(after,1); }
    },10);
  }
})('emile', this);
!function (context, doc) {
  var fns = [], ol, fn, f = false,
      testEl = doc.documentElement,
      hack = testEl.doScroll,
      domContentLoaded = 'DOMContentLoaded',
      addEventListener = 'addEventListener',
      onreadystatechange = 'onreadystatechange',
      loaded = /^loade|c/.test(doc.readyState);
  function flush(i) {
    loaded = 1;
    while (i = fns.shift()) { i() }
  }
  doc[addEventListener] && doc[addEventListener](domContentLoaded, fn = function () {
    doc.removeEventListener(domContentLoaded, fn, f);
    flush();
  }, f);
  hack && doc.attachEvent(onreadystatechange, (ol = function () {
    if (/^c/.test(doc.readyState)) {
      doc.detachEvent(onreadystatechange, ol);
      flush();
    }
  }));
  context['domReady'] = hack ?
    function (fn) {
      self != top ?
        loaded ? fn() : fns.push(fn) :
        function () {
          try {
            testEl.doScroll('left');
          } catch (e) {
            return setTimeout(function() { context['domReady'](fn) }, 50);
          }
          fn();
        }()
    } :
    function (fn) {
      loaded ? fn() : fns.push(fn);
    };
}(this, document);
})();
return window.x$; };
    }
  };
});
telobike.module(3, function(/* parent */){
  return {
    'id': 'lib/xui',
    'pkg': arguments[0],
    'wrapper': function(module, exports, global, Buffer,process, require, undefined){
      module.exports = require('./xui-2.3.2.js')();
    }
  };
});
telobike.module(3, function(/* parent */){
  return {
    'id': 'lib/xui',
    'pkg': arguments[0],
    'wrapper': function(module, exports, global, Buffer,process, require, undefined){
      module.exports = require('./xui-2.3.2.js')();
    }
  };
});
if(typeof module != 'undefined' && module.exports ){
  module.exports = telobike;
  if( !module.parent ){
    telobike.main();
  }
};
window.require = telobike.require;
window.app = telobike.require('telobike');
