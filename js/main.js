// Generated by CoffeeScript 1.12.2
"use strict";
var agent, body, collectData, doc, every, form, getCargo, getHTML, getLastSegment, getTurn, host, sendData, timer, winName;

agent = "GVReporter/0.1.0";

host = "http://localhost:8000";

winName = "gv-reporter-win";

doc = document;

body = doc.body;

form = null;

every = function(ms, action) {
  return setInterval(action, ms);
};

getLastSegment = function(url) {
  return url.match(/\/([^\/]*?)(?:\#.*)?$/)[1];
};

getTurn = function() {
  try {
    return +doc.querySelector("#m_fight_log .block_h .block_title").innerText.match(/\d+/)[0];
  } catch (error) {
    return 0;
  }
};

getCargo = function() {
  try {
    return doc.querySelector("#hk_cargo .l_val").text;
  } catch (error) {
    return "";
  }
};

getHTML = function(id) {
  try {
    return doc.getElementById(id).outerHTML;
  } catch (error) {
    return "";
  }
};

collectData = function() {
  return {
    turn: getTurn(),
    cargo: getCargo(),
    allies: getHTML("alls"),
    map: getHTML("s_map"),
    log: getHTML("m_fight_log")
  };
};

sendData = function(data) {
  var i, input, len, ref, value;
  ref = form.children;
  for (i = 0, len = ref.length; i < len; i++) {
    input = ref[i];
    if ((value = data[input.name]) != null) {
      input.value = value;
    }
  }
  open("about:blank", winName, "toolbar=no,scrollbars=no,location=no,status=no,menubar=no,resizable=no,height=150,width=243");
  body.appendChild(form);
  form.submit();
  return body.removeChild(form);
};

timer = every(300, function() {
  var heroBlock, localLink, streamingLink;
  if (doc.getElementById("hero_columns") == null) {
    return;
  }
  clearInterval(timer);
  if (doc.getElementById("s_map") == null) {
    return;
  }
  form = doc.createElement("form");
  form.method = "POST";
  form.action = host + "/send";
  form.enctype = "multipart/form-data";
  form.acceptCharset = "utf-8";
  form.target = winName;
  localLink = location.protocol + "//" + location.host + (doc.getElementById("fbclink").href.replace(/^(?:\w*:\/\/)?[^\/]*/, ""));
  form.innerHTML = "<input type=\"hidden\" name=\"agent\" value=\"" + agent + "\" /><input type=\"hidden\" name=\"link\" value=\"" + localLink + "\" /><input type=\"hidden\" name=\"turn\" /><input type=\"hidden\" name=\"cargo\" /><input type=\"hidden\" name=\"allies\" /><input type=\"hidden\" name=\"map\" /><input type=\"hidden\" name=\"log\" />";
  heroBlock = doc.getElementById("hero_block");
  heroBlock.insertAdjacentHTML("afterbegin", '<div style="text-align: center;"><a href="#" target="_blank">Транслировать</a></div>');
  streamingLink = heroBlock.firstChild.firstChild;
  return streamingLink.onclick = function() {
    var data, lastTurn;
    streamingLink.text = "Идёт трансляция";
    streamingLink.href = host + "/duels/log/" + (getLastSegment(localLink));
    streamingLink.onclick = null;
    data = collectData();
    lastTurn = data.turn;
    sendData(data);
    every(500, function() {
      var turn;
      if ((turn = getTurn()) > lastTurn) {
        lastTurn = turn;
        return sendData(collectData());
      }
    });
    return false;
  };
});
