// Generated by LiveScript 1.5.0
"use strict";
var agent, host, winName, form, every, timeIt, getLastSegment, getTurn, getCargo, getHTML, collectData, sendData, timer;
agent = "GVReporter/0.1.0";
host = "http://localhost:8000";
winName = 'gv-reporter-win';
form = null;
every = function(ms, action){
  return setInterval(action, ms);
};
timeIt = function(title, action){
  console.time(title);
  try {
    return action();
  } finally {
    console.timeEnd(title);
  }
};
getLastSegment = function(url){
  return /\/([^\/]*?)(?:\#.*)?$/.exec(url)[1];
};
getTurn = function(){
  var e;
  try {
    return +/\d+/.exec(document.querySelector('#m_fight_log .block_h .block_title').textContent)[0];
  } catch (e$) {
    e = e$;
    return 0;
  }
};
getCargo = function(){
  var e;
  try {
    return document.querySelector('#hk_cargo .l_val').textContent;
  } catch (e$) {
    e = e$;
    return "";
  }
};
getHTML = function(id){
  var e;
  try {
    return document.getElementById(id).outerHTML;
  } catch (e$) {
    e = e$;
    return "";
  }
};
collectData = function(){
  return timeIt("Collected", function(){
    return {
      turn: getTurn(),
      cargo: getCargo(),
      data: base64js.fromByteArray(pako.deflate(['alls', 's_map', 'm_fight_log'].map(getHTML).join("<&>")))
    };
  });
};
sendData = function(data){
  var i$, x$, ref$, len$, that;
  for (i$ = 0, len$ = (ref$ = form.children).length; i$ < len$; ++i$) {
    x$ = ref$[i$];
    if ((that = data[x$.name]) != null) {
      x$.value = that;
    }
  }
  open("about:blank", winName, "toolbar=no,scrollbars=no,location=no,status=no,menubar=no,resizable=no,height=150,width=243");
  document.body.appendChild(form);
  timeIt("Transferred", function(){
    form.submit();
  });
  document.body.removeChild(form);
};
timer = every(300, function(){
  var localLink, heroBlock, streamingLink;
  if (!(document.getElementById('hero_columns') != null && window.pako != null && window.base64js != null)) {
    return;
  }
  clearInterval(timer);
  if (document.getElementById('s_map') == null) {
    return;
  }
  form = document.createElement('form');
  form.method = 'POST';
  form.action = host + "/send";
  form.enctype = "multipart/form-data";
  form.acceptCharset = 'utf-8';
  form.target = winName;
  form.style.display = 'none';
  localLink = "" + location.protocol + "//" + location.host + "" + document.getElementById('fbclink').href.replace(/^(?:\w*:\/\/)?[^\/]*/, "") + "";
  form.innerHTML = "<input type='hidden' name='agent' value='" + agent + "' /><input type='hidden' name='link' value='" + localLink + "' /><input type='hidden' name='turn' /><input type='hidden' name='cargo' /><input type='hidden' name='data' />";
  heroBlock = document.getElementById('hero_block');
  heroBlock.insertAdjacentHTML('afterbegin', "<div style='text-align: center;'><a href='#' target='_blank'>Транслировать</a></div>");
  streamingLink = heroBlock.firstChild.firstChild;
  streamingLink.onclick = function(){
    var data, lastTurn;
    streamingLink.textContent = "Идёт трансляция";
    streamingLink.href = host + "/duels/log/" + getLastSegment(localLink);
    streamingLink.onclick = null;
    data = collectData();
    lastTurn = data.turn;
    sendData(data);
    every(500, function(){
      var turn;
      if ((turn = getTurn()) > lastTurn) {
        lastTurn = turn;
        sendData(collectData());
      }
    });
    return false;
  };
});