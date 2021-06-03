import Rails from "@rails/ujs"
import "channels"
import AudioPlayer from "audio_player"

import Sortable from 'sortablejs';

import queryString from 'query-string';


Rails.start()
AudioPlayer.start()

function renumber(list) {
  let idx = 1;
  for (const node of list.children) {
    node.querySelector(".cover-index").innerText = idx;
    idx += 1;
  }
}

function saveOrder(list) {
  let ids = [];
  for (const node of list.children) {
    const id = parseInt(node.id.replace("cover_", ""));
    ids.push(id);
  }
  const token = document.getElementsByName("csrf-token")[0].content;
  const password = queryString.parse(location.search)["password"];
  const url = "/covers/update_order";

  fetch(url, {
    method: 'POST',
    headers: {
      'X-CSRF-Token': token,
      'Content-Type': 'application/json'
      // 'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: JSON.stringify({ids: ids, password: password })
  });
}

window.addEventListener("load", () => {
  document.querySelectorAll(".js-remove-cover").forEach((button) => {
    const form = button.form;
    const container = document.getElementById(button.getAttribute("data-target"))
    form.addEventListener("ajax:before", (event) => {
      container.classList.add("deleting");
      container.classList.add("pe-none");
    });
    form.addEventListener("ajax:success", (event) => {
      container.parentNode.removeChild(container);
    });
  });

  const cover_list = document.getElementById("cover_list");
  new Sortable(cover_list, {
    animation: 150,
    handle: '.cover-title',
    onChange: function (evt) {
      const list = evt.to;
      renumber(list);
    },
    onEnd: function (evt) {
      const list = evt.to;
      renumber(list);
      saveOrder(list)
    }
  });
});
