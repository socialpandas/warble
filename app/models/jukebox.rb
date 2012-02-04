module Jukebox
  extend self

  # TODO: some of these need to be atomic ops

  def volume
    $redis.get('warble:volume').to_i
  end

  def volume=(value)
    $redis.set('warble:volume', value.to_i)
    publish_volume
  end

  def current_play
    Play.find_by_id($redis.get('warble:current_play'))
  end

  def current_song
    play = current_play
    play && play.song
  end

  def queue
    $redis.zrange('warble:queue', 0, -1)
      .map { |play_id| Play.find_by_id(play_id) }
      .compact
  end

  def queue_as_songs
    queue.map(&:song)
  end

  def enqueue(song, user=nil)
    priority = user ? user.number_of_plays_today : 999
    play = Play.create(user: user, song: song)

    $redis.zadd('warble:queue', priority, play.id)

    publish_queue_refresh

    skip unless current_play
  end

  def skip
    if $redis.zcard('warble:queue') == 0    # If nothing queued
      $redis.del('warble:current_play')     # ...then kill current song
      auto_queue                            # ...and auto-queue another song
    else
      results = $redis.multi do                       # Pop from queue and set as current
        $redis.zrange('warble:queue', 0, 0)
        $redis.zremrangebyrank('warble:queue', 0, 0)
      end
      $redis.set('warble:current_play', results.first.first)
    end

    publish_skip
  end

  def publish_queue_refresh
    $redis.publish(Warble::Application.config.pubsub_channel, {
      event: 'refresh',
      songs: queue_as_songs
    }.to_json)
  end

  def publish_skip
    $redis.publish(Warble::Application.config.pubsub_channel, {
      event: 'skip',
      jukebox: as_json
    }.to_json)
  end

  def publish_volume
    $redis.publish(Warble::Application.config.pubsub_channel, {
      event: 'volume',
      jukebox: as_json
    }.to_json)
  end

  def as_json(options = {})
    {
      current:      Jukebox.current_song,
      current_play: Jukebox.current_play,
      volume:  Jukebox.volume
    }
  end

 private
  def auto_queue
    enqueue Song.get_random
  end
end
