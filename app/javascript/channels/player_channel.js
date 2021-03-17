import { v4 as uuidv4 } from 'uuid'

import consumer from "./consumer"

export default consumer.subscriptions.create("PlayerChannel", {
  connected() {
    this.uuid = uuidv4();
  },

  disconnected() {
  },

  seek(el, value) {
    if (Math.abs(el.currentTime - value) > 2) {
      el.currentTime = value;
    }
  },

  received(data) {
    const { state, target, source, value } = data;

    if (source == this.uuid) return;
    if (!this.isEnabled()) return;

    const el = document.getElementById(target);
    if (state == "play") {
      if (el.parentNode.scrollIntoViewIfNeeded) {
        el.parentNode.scrollIntoViewIfNeeded(true)
      } else if (el.parentNode.scrollIntoView) {
        el.parentNode.scrollIntoView({ behavior: "smooth", block: "center", inline: "nearest" });
      }

      this.seek(el, value);
      el.play();
    } else if (state == "pause") {
      el.pause();
    } else if (state == "seek") {
      this.seek(el, value);
    } else if (state == "load") {
      if (el.readyState == 0 && el.paused && el.networkState <= 1) {
        el.load();
      }
    }
  },

  update(id, state, value) {
    if (!this.isEnabled()) return;
    this.send({ state: state, target: id, source: this.uuid, value: value });
  },

  isEnabled() {
    const checkbox = document.querySelector("#watch_together_enabled").checked;
    return checkbox && checkbox.enabled;
  }
});
