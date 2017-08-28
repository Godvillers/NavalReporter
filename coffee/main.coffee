host = "http://localhost:8000"
winName = "naval-reporter-win"

doc = document
body = doc.body
form = null


every = (ms, action) ->
    setInterval action, ms


getLastSegment = (url) ->
    url.match(/\/([^\/])*?(?:#.*)?$/)[1]


getTurn = ->
    try +doc.querySelector("#m_fight_log .block_h .block_title").innerText.match(/\d+/)[0]
    catch then 0


getHTML = (id) ->
    try doc.getElementById(id).outerHTML
    catch then ""


collectData = ->
    turn: getTurn()
    allies: getHTML "alls"
    map: getHTML "s_map"
    log: getHTML "m_fight_log"


sendData = (data) ->
    input.value = value for input in form.children when (value = data[input.name])?

    open "about:blank", winName,
        "toolbar=no,scrollbars=no,location=no,status=no,menubar=no,resizable=no,height=150,width=243"
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
    local = "#{location.protocol}//#{location.host}"
    local += doc.getElementById("fbclink").href.replace /^(?:\w*:\/\/)?[^\/]*/, ""
    form.innerHTML = "<input type='hidden' name='link' value='#{local}' />" + (
        "<input type='hidden' name='#{name}' />" for name in ["turn", "allies", "map", "log"]
    ).join("")

    heroBlock = doc.getElementById "hero_block"
    heroBlock.insertAdjacentHTML "afterbegin",
        '<div style="text-align: center;"><a href="#" target="_blank">Транслировать</a></div>'
    streamingLink = heroBlock.firstChild.firstChild
    streamingLink.onclick = ->
        streamingLink.text = "Идёт трансляция"
        streamingLink.href = "#{host}/duels/log/#{getLastSegment local}"
        streamingLink.onclick = null

        data = collectData()
        lastTurn = data.turn
        sendData data
        every 500, ->
            turn = getTurn()
            return if turn <= lastTurn
            lastTurn = turn
            sendData collectData()

        false
