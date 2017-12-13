"use strict"

const agent = "GVReporter/1.0.0"
const host = "https://gv.erinome.net/reporter"
const winName = \gv-reporter-win

form = null


$id = -> document.getElementById it
$q  = -> document.querySelector  it


every = (ms, action) ->
    setInterval action, ms


timeIt = (title, action) ->
    console.time title
    try
        action!
    finally
        console.timeEnd title


getLastSegment = (url) ->
    // / ([^/]*?) (?:\# .*)? $ //.exec(url).1


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


sendData = (data) !->
    [..value = that if data[..name]? for form.children]

    open "about:blank", winName,
        "toolbar=no,scrollbars=no,location=no,status=no,menubar=no,
        resizable=no,height=150,width=243"
    document.body.appendChild form
    form.submit!
    document.body.removeChild form


timer = every 300, !->
    # Wait until the page is loaded.
    return unless $id(\hero_columns)? && window.pako? && window.base64js?
    clearInterval timer

    return unless $id(\s_map)? # Test whether we are sailing.

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
        #{$id \fbclink .href.replace // ^ (?:\w* :\//)? [^/]* //, ""}
        "
    form.innerHTML =
        "
        <input type='hidden' name='protocolVersion' value='1' />
        <input type='hidden' name='agent' value='#{agent}' />
        <input type='hidden' name='link' value='#{localLink}' />
        <input type='hidden' name='stepDuration' value='20' />
        <input type='hidden' name='scale' value='11' />
        <input type='hidden' name='step' />
        <input type='hidden' name='playerIndex' value='0' />
        <input type='hidden' name='cargo' />
        <input type='hidden' name='data' />
        "

    heroBlock = $id \hero_block
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

        data = collectData!
        lastStep = data.step
        sendData data
        every 500, !->
            if (step = getStep!) > lastStep
                lastStep := step
                sendData collectData!

        false
