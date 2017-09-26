"use strict"

agent = "GVReporter/0.1.0"
host = "http://localhost:8000"
winName = "gv-reporter-win"

doc = document
body = doc.body
form = null


every = (ms, action) ->
    setInterval action, ms


getLastSegment = (url) ->
    url.match(/// / ([^/]*?) (?:\# .*)? $ ///)[1]


getTurn = ->
    try +doc.querySelector("#m_fight_log .block_h .block_title").innerText.match(/\d+/)[0]
    catch then 0


getCargo = ->
    try doc.querySelector("#hk_cargo .l_val").text
    catch then ""


getHTML = (id) ->
    try doc.getElementById(id).outerHTML
    catch then ""


collectData = ->
    turn:      getTurn()
    cargo:     getCargo()
    allies:    getHTML "alls"
    map:       getHTML "s_map"
    log:       getHTML "m_fight_log"


sendData = (data) ->
    input.value = value for input in form.children when (value = data[input.name])?

    open "about:blank", winName,
        "toolbar=no,scrollbars=no,location=no,status=no,menubar=no,\
        resizable=no,height=150,width=243"
    body.appendChild form
    form.submit()
    body.removeChild form


timer = every 300, ->
    # Wait until the page is loaded.
    return unless doc.getElementById("hero_columns")?
    clearInterval timer

    return unless doc.getElementById("s_map")? # Test whether we are sailing.

    # Inject the form and streaming link.
    form = doc.createElement "form"
    form.method = "POST"
    form.action = "#{host}/send"
    form.enctype = "multipart/form-data"
    form.acceptCharset = "utf-8"
    form.target = winName
    localLink =
        """
        #{location.protocol}//#{location.host}\
        #{doc.getElementById("fbclink").href.replace /// ^ (?:\w* ://)? [^/]* ///, ""}
        """
    form.innerHTML =
        """
        <input type="hidden" name="agent" value="#{agent}" />\
        <input type="hidden" name="link" value="#{localLink}" />\
        <input type="hidden" name="turn" />\
        <input type="hidden" name="cargo" />\
        <input type="hidden" name="allies" />\
        <input type="hidden" name="map" />\
        <input type="hidden" name="log" />\
        """

    heroBlock = doc.getElementById "hero_block"
    heroBlock.insertAdjacentHTML "afterbegin",
        '<div style="text-align: center;"><a href="#" target="_blank">Транслировать</a></div>'
    streamingLink = heroBlock.firstChild.firstChild
    streamingLink.onclick = ->
        streamingLink.text = "Идёт трансляция"
        streamingLink.href = "#{host}/duels/log/#{getLastSegment localLink}"
        streamingLink.onclick = null

        data = collectData()
        lastTurn = data.turn
        sendData data
        every 500, ->
            if (turn = getTurn()) > lastTurn
                lastTurn = turn
                sendData collectData()

        false
