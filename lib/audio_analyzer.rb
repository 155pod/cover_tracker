class AudioAnalyzer < ActiveStorage::Analyzer
  def self.accept?(blob)
    blob.audio?
  end

  def metadata
    {
      duration: duration,
      sample_rate: audio_stream["sample_rate"]&.to_i,
      channels: audio_stream["channels"]&.to_i,
      bit_rate: audio_stream["bit_rate"]&.to_i,
      bits_per_sample: audio_stream["bits_per_sample"]&.to_i,
      format_mame: container["format_name"]
    }
  end

  def bit_rate
    bit_rate = audio_stream["bit_rate"] || container["bit_rate"]
    Integer(bit_rate) if bit_rate
  end

  def duration
    duration = audio_stream["duration"] || container["duration"]
    Float(duration) if duration
  end

  def audio_stream
    @audio_stream ||= streams.detect { |stream| stream["codec_type"] == "audio" } || {}
  end

  def streams
    probe["streams"] || []
  end

  def container
    probe["format"] || {}
  end

  def probe
    @probe ||= download_blob_to_tempfile { |file| probe_from(file) }
  end

  def probe_from(file)
    IO.popen([ ffprobe_path,
               "-print_format", "json",
               "-show_streams",
               "-show_format",
               "-v", "error",
               file.path
    ]) do |output|
      JSON.parse(output.read)
    end
  rescue Errno::ENOENT
    logger.info "Skipping analysis because FFmpeg isn't installed"
    {}
  end

  def ffprobe_path
    ActiveStorage.paths[:ffprobe] || "ffprobe"
  end
end
