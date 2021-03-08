import Rails from "@rails/ujs"
import "channels"
import AudioPlayer from "audio_player"

Rails.start()
AudioPlayer.start()

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
});
