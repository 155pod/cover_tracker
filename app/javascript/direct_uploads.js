addEventListener("direct-upload:initialize", event => {
  const { target, detail } = event
  const { id, file } = detail
  target.insertAdjacentHTML("afterend", `
    <div id="direct-upload-${id}" class="progress">
      <div id="direct-upload-progress-${id}" class="progress-bar"></div>
    </div>
  `)
})

addEventListener("direct-upload:start", event => {
  const { id } = event.detail
  const element = document.getElementById(`direct-upload-progress-${id}`)
  element.classList.add("progress-bar-striped")
  element.classList.add("progress-bar-animated")
})

addEventListener("direct-upload:progress", event => {
  const { id, progress } = event.detail
  const element = document.getElementById(`direct-upload-progress-${id}`)
  element.style.width = `${progress}%`
  element.innerText = `${Math.round(progress)}%`
})

addEventListener("direct-upload:error", event => {
  event.preventDefault()
  const { id, error } = event.detail
  const element = document.getElementById(`direct-upload-progress-${id}`)
  element.innerText = "error";
  element.classList.add("bg-danger")

  element.parentNode.insertAdjacentHTML("afterend", `
    <div class="alert alert-danger" role="alert">
      An error occurred processing your upload:<br/>
      ${error}<br/>
      If retrying doesn't work :( send your cover your fellow comp organizer or shout in the community Discord server.
    </div>
  `)

  if (typeof Bugsnag !== 'undefined') {
    Bugsnag.notify(error);
  }
})

addEventListener("direct-upload:end", event => {
  const { id } = event.detail
  const element = document.getElementById(`direct-upload-progress-${id}`)
  if (element.innerText != "error") {
    element.innerText = "done";
  }
  element.style.width = "100%";
  element.classList.remove("progress-bar-striped")
  element.classList.remove("progress-bar-animated")
})
