import playerChannel from "channels/player_channel";

function toMMSS(sec_num) {
  let minutes = Math.floor(sec_num / 60);
  let seconds = Math.floor(sec_num - (minutes * 60));

  if (minutes < 10) minutes = "0"+minutes;
  if (seconds < 10) seconds = "0"+seconds;

  return `${minutes}:${seconds}`;
}

class AudioPlayer {
  constructor(playerEl) {
    this.playerEl = playerEl;

    this.duration = playerEl.getAttribute("data-duration") | 0;
    this.startTime = playerEl.getAttribute("data-start-time") | 0;

    const targetId = playerEl.getAttribute("data-target");
    this.audio = document.getElementById(targetId);
    this.audio.currentTime = this.startTime;
    this.loaded = false;

    this.playPause = playerEl.querySelector(".js-play-pause");
    this.range = playerEl.querySelector(".js-range");
    this.progress = playerEl.querySelector(".js-progress");
    this.volume = playerEl.querySelector(".js-volume");

    const update = () => this.update();

    this.playPause.addEventListener("mouseenter", () => {
      this.ensureLoaded();
    });
    this.playPause.addEventListener("mousedown", () => {
      if (this.isPlaying()) {
        this.push("pause");
        this.audio.pause();
      } else {
        this.push("play", this.audio.currentTime || this.startTime);
        this.audio.play();
      }
      this.update();
    });

    this.range.addEventListener("input", update);
    this.range.addEventListener("mousedown", () => {
      this.ensureLoaded();
      this.scrubbing = true;
    });
    this.range.addEventListener("mouseup", () => {
      this.scrubbing = false;
      this.audio.currentTime = this.rangePosition();
      this.push("seek", this.rangePosition());
    });
    this.volume.addEventListener("input", () => {
      this.audio.volume = this.volume.value;
    });

    this.audio.addEventListener("play", update);
    this.audio.addEventListener("pause", update);
    this.audio.addEventListener("ended", update);
    this.audio.addEventListener("seeked", update);
    this.audio.addEventListener("timeupdate", update);
    this.audio.addEventListener("durationchange", update);
    this.audio.addEventListener("volumechange", update);

    update();
  }

  push(state, value) {
    playerChannel.update(this.audio.id, state, value)
  }

  ensureLoaded() {
    if (!this.loaded) {
      this.loaded = true;
      this.push("load");

      if (this.audio.readyState == 0 && this.audio.paused && this.audio.networkState <= 1) {
        this.audio.load();
      }
    }
  }

  isPlaying() {
    return !this.audio.paused;
  }

  rangePosition() {
    return this.range.value * (this.audio.duration || 0) / this.range.max;
  }

  update() {
    if (this.isPlaying()) {
      this.playPause.innerHTML = `<i class="bi bi-pause-fill"></i>`;
    } else {
      this.playPause.innerHTML = `<i class="bi bi-play-fill"></i>`;
    }

    let duration = this.audio.duration || this.duration;

    if (this.scrubbing) {
      let currentTime = this.rangePosition();

      this.progress.innerText = `${toMMSS(currentTime)} / ${toMMSS(duration)}`;
    } else {
      let currentTime = this.audio.currentTime || this.startTime;
      if (currentTime == 0 || duration == 0) {
        this.range.value = 0;
      } else {
        this.range.value = currentTime * this.range.max / duration;
      }
      this.progress.innerText = `${toMMSS(currentTime)} / ${toMMSS(duration)}`;
    }

    this.volume.value = this.audio.volume;
  }

  static start() {
    if (document.readyState != 'loading'){
      this.onReady();
    } else {
      document.addEventListener('DOMContentLoaded', () => this.onReady());
    }
  }

  static onReady() {
    document.querySelectorAll(".js-audio-player").forEach((playerEl) => {
      new AudioPlayer(playerEl);
    });
  }
};

export default AudioPlayer;
