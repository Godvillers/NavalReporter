"use strict"

const host = \https://gv.erinome.net/reporter
# https://github.com/Godvillers/ReporterServer/blob/master/docs/api.md
const apiURL = "#{host}/send"
# We make requests via an HTML <form>. Another option is sending XHRs from a *background* script.
const method = \POST
const encodingType = \multipart/form-data
const charset = \utf-8
const winName = \gv-reporter-win
const requestTemplate =
    protocolVersion: 1
    agent:           "GVReporter/1.1.0"
    link:            null
    stepDuration:    if location.hostname == \godvillegame.com then 23 else 20
    scale:           11
    step:            null
    playerIndex:     0 # A smarter client should by some means detect that.
    cargo:           null
    data:            null


$id = -> document.getElementById it
$q  = -> document.querySelector  it


getLocalLink = ->
    "
    #{location.protocol}//#{location.host}
    #{$id \fbclink .href.replace // ^ (?:\w* :\//)? [^/]* //, ""}
    "


getLastSegment = (url) ->
    // / ([^/]*?) (?:\# .*)? $ //.exec url .1


getStreamURL = (localLink) ->
    "#{host}/duels/log/#{getLastSegment localLink}"


createForm = ->
    form = document.createElement \form
        ..method = method
        ..action = apiURL
        ..enctype = encodingType
        ..acceptCharset = charset
        ..target = winName
        ..style.display = \none

    for key, value of requestTemplate
        document.createElement \input
            ..type = \hidden
            ..name = key
            ..value = value if value?
            form.appendChild ..
    form


timeIt = (title, action) ->
    console.time title
    try
        action!
    finally
        console.timeEnd title


getStep = ->
    try +/\d+/.exec($q '#m_fight_log .block_h .block_title' .textContent).0
    catch => 0


getCargo = ->
    try $q '#hk_cargo .l_val' .textContent
    catch => ""


getHTML = (id) ->
    try $id id .outerHTML
    catch => ""


collectData = ->
    <- timeIt "Collected"
    step:  getStep!
    cargo: getCargo!
    data:  base64js.fromByteArray pako.deflate [\alls \s_map \m_fight_log].map(getHTML).join "<&>"


sendData = (form, data) !->
    [..value = that if data[..name]? for form.children]

    open "about:blank", winName,
        "toolbar=no,scrollbars=no,location=no,status=no,menubar=no,
        resizable=no,height=150,width=243"
    document.body.appendChild form
    form.submit!
    document.body.removeChild form


every = (ms, action) ->
    setInterval action, ms


timer = every 300ms, !->
    # Wait until the page is loaded.
    return unless $id(\hero_columns)? && window.pako? && window.base64js?
    clearInterval timer

    return unless $id(\s_map)? # Test whether we are sailing.

    # Inject the form and streaming link.
    requestTemplate.link = localLink = getLocalLink!
    form = createForm!
    heroBlock = $id \hero_block
    heroBlock.insertAdjacentHTML \afterbegin,
        "
        <div style='text-align: center;'>
            <a href='#' target='_blank'>Транслировать</a>
        </div>
        "
    streamingLink = heroBlock.firstChild.firstChild
    streamingLink.onclick = ->
        streamingLink
            ..textContent = "Идёт трансляция"
            ..href = getStreamURL localLink
            ..onclick = null

        data = collectData!
        lastStep = data.step
        sendData form, data
        every 500ms, !->
            if (step = getStep!) > lastStep
                lastStep := step
                sendData form, collectData!
        false
