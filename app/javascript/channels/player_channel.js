import { v4 as uuidv4 } from 'uuid'

import consumer from "./consumer"

export default consumer.subscriptions.create("PlayerChannel", {
  connected() {
    this.uuid = uuidv4();
  },

  disconnected() {
  },

  received(data) {
    const { state, target, source, value } = data;

    if (source == this.uuid) return;
    if (!this.isEnabled()) return;

    const el = document.getElementById(target);
    if (state == "play") {
      el.play();
    } else if (state == "pause") {
      el.pause();
    } else if (state == "seek") {
      if (Math.abs(el.currentTime - value) > 2) {
        el.currentTime = value;
      }
    } else if (state == "load") {
      if (el.readyState == 0) {
        el.load();
      }
    }
  },

  update(id, state, value) {
    if (!this.isEnabled()) return;
    this.send({ state: state, target: id, source: this.uuid, value: value });
  },

  isEnabled() {
    return document.querySelector("#watch_together_enabled").checked;
  }
});
