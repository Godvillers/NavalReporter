"use strict"

const agent = "GVReporter/0.1.0"
const host = "http://localhost:8000"
const winName = \gv-reporter-win

form = null


every = (ms, action) ->
    setInterval action, ms


timeIt = (title, action) ->
    console.time title
    try
        action()
    finally
        console.timeEnd title


getLastSegment = (url) ->
    // / ([^/]*?) (?:\# .*)? $ //.exec(url).1


getTurn = ->
    try +/\d+/.exec(document.querySelector '#m_fight_log .block_h .block_title' .textContent).0
    catch => 0


getCargo = ->
    try document.querySelector '#hk_cargo .l_val' .textContent
    catch => ""


getHTML = (id) ->
    try document.getElementById id .outerHTML
    catch => ""


collectData = ->
    <- timeIt "Collected"
    turn:  getTurn()
    cargo: getCargo()
    data:  base64js.fromByteArray pako.deflate [\alls \s_map \m_fight_log].map(getHTML).join "<&>"


sendData = (data) !->
    [..value = that if data[..name]? for form.children]

    open "about:blank", winName,
        "toolbar=no,scrollbars=no,location=no,status=no,menubar=no,
        resizable=no,height=150,width=243"
    document.body.appendChild form
    timeIt "Transferred", !->
        form.submit()
    document.body.removeChild form


timer = every 300, !->
    # Wait until the page is loaded.
    return unless document.getElementById(\hero_columns)? && window.pako? && window.base64js?
    clearInterval timer

    return unless document.getElementById(\s_map)? # Test whether we are sailing.

    # Inject the form and streaming link.
    form := document.createElement \form
    form.method = \POST
    form.action = "#{host}/send"
    form.enctype = "multipart/form-data"
    form.acceptCharset = \utf-8
    form.target = winName
    form.style.display = \none
    localLink =
        "
        #{location.protocol}//#{location.host}
        #{document.getElementById \fbclink .href.replace // ^ (?:\w* :\//)? [^/]* //, ""}
        "
    form.innerHTML =
        "
        <input type='hidden' name='agent' value='#{agent}' />
        <input type='hidden' name='link' value='#{localLink}' />
        <input type='hidden' name='turn' />
        <input type='hidden' name='cargo' />
        <input type='hidden' name='data' />
        "

    heroBlock = document.getElementById \hero_block
    heroBlock.insertAdjacentHTML \afterbegin,
        "
        <div style='text-align: center;'>
            <a href='#' target='_blank'>Транслировать</a>
        </div>
        "
    streamingLink = heroBlock.firstChild.firstChild
    streamingLink.onclick = ->
        streamingLink.textContent = "Идёт трансляция"
        streamingLink.href = "#{host}/duels/log/#{getLastSegment localLink}"
        streamingLink.onclick = null

        data = collectData()
        lastTurn = data.turn
        sendData data
        every 500, !->
            if (turn = getTurn()) > lastTurn
                lastTurn := turn
                sendData collectData()

        false
