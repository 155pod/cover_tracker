import Rails from "@rails/ujs"
import "channels"
import AudioPlayer from "audio_player"

import {Sortable, MultiDrag} from 'sortablejs';

import queryString from 'query-string';

Rails.start()
AudioPlayer.start()

function renumber(list) {
  let idx = 1;
  for (const node of list.children) {
    node.querySelector(".submission-index").innerText = idx;
    idx += 1;
  }
}

function saveOrder(list) {
  const ids = getIds(list.children);
  const token = document.getElementsByName("csrf-token")[0].content;
  const password = queryString.parse(location.search)["password"];
  const url = "/submissions/update_order";

  fetch(url, {
    method: 'POST',
    headers: {
      'X-CSRF-Token': token,
      'Content-Type': 'application/json'
      // 'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: JSON.stringify({ids: ids, password: password})
  });
}

function archiveSelected(ids, bSides=false) {
  const token = document.getElementsByName("csrf-token")[0].content;
  const password = queryString.parse(location.search)["password"];
  const url = "/submissions/archive_all";

  fetch(url, {
    method: 'POST',
    headers: {
      'X-CSRF-Token': token,
      'Content-Type': 'application/json'
      // 'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: JSON.stringify({ids: ids, password: password, b_sides: bSides})
  }).then(response => location.reload());
}

function handleSelection(event) {
  const selectedSubmissions = document.querySelectorAll(".submission.selected:not(.b-side)");
  const selectedBSides = document.querySelectorAll(".submission.selected.b-side");

  if (!!selectedSubmissions || !!selectedBSides) {
    const archiveSubmissionsButton = document.querySelector(".js-archive-submissions");
    const archiveBSidesButton = document.querySelector(".js-archive-b-sides");

    archiveSubmissionsButton.setAttribute("data-count", selectedSubmissions.length);
    archiveSubmissionsButton.setAttribute("data-ids", getIds(selectedSubmissions));
    archiveBSidesButton.setAttribute("data-count", selectedBSides.length);
    archiveBSidesButton.setAttribute("data-ids", getIds(selectedBSides));

    updateArchiveButtonText(archiveSubmissionsButton, selectedSubmissions.length);
    updateArchiveButtonText(archiveBSidesButton, selectedBSides.length);
  }
}

function getIds(list) {
  let ids = [];
  for (const node of list) {
    const id = parseInt(node.id.replace("submission_", ""));
    ids.push(id);
  }
  return ids;
}

function updateArchiveButtonText(element, count) {
  if (count > 0) {
    element.innerHTML = element.innerHTML.replace("All", "Selected");
  }
  else {
    element.innerHTML = element.innerHTML.replace("Selected", "All");
  }
}

window.addEventListener("load", () => {
  document.querySelectorAll(".js-remove-submission").forEach((button) => {
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

  const archiveSubmissionsButton = document.querySelector("#archive_submissions");
  archiveSubmissionsButton.addEventListener("click", () => {
    archiveSelected(archiveSubmissionsButton.getAttribute("data-ids"));
  });

  const archiveBSidesButton = document.querySelector("#archive_b_sides");
  archiveBSidesButton.addEventListener("click", () => {
    archiveSelected(archiveBSidesButton.getAttribute("data-ids"), true);
  });

  const submission_list = document.getElementById("submission_list");
  const b_side_list = document.getElementById("b_side_list");

  Sortable.mount(new MultiDrag);

  for (const list of [submission_list, b_side_list]) {
    new Sortable(list, {
      animation: 150,
      handle: '.submission-title',
      onChange: function (evt) {
        const list = evt.to;
        renumber(list);
      },
      onDeselect: function (evt) {
        setTimeout(() => {
          handleSelection(evt)
        }, 1200);
      },
      onEnd: function (evt) {
        const list = evt.to;
        renumber(list);
        saveOrder(list)
      },
      onSelect: function (evt) {
        handleSelection(evt)
      },
      multiDrag: true,
      multiDragKey: "SHIFT",
      selectedClass: "selected",
    });
  };

  document.querySelectorAll(".js-toggle-b-side").forEach((button) => {
    const form = button.form;
    const container = document.getElementById(button.getAttribute("data-target"));
    form.addEventListener("ajax:before", (event) => {
      container.classList.add("deleting");
      container.classList.add("pe-none");
    });

    form.addEventListener("ajax:success", (event) => {
      const submissionListNode = document.getElementById("submission_list");
      const bSideListNode = document.getElementById("b_side_list");

      if (container.parentNode === bSideListNode) {
        submissionListNode.appendChild(container);
        bSideListNode.removeChild(container);
      } else {
        bSideListNode.appendChild(container);
        submissionListNode.removeChild(container);
      };

      container.classList.remove("deleting");
      container.classList.remove("pe-none");
    });
  });
});
