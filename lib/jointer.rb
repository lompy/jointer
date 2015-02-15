require 'csv'
require_relative 'utils'
require_relative 'frame_jointer'

class Jointer
  def initialize(db)
    @db = db
    @max_id = 0
    utils.create_or_clear_tmp_dir
    initialize_jointees
  end

  def join(id_1, id_2)
    jointee_1 = jointee(id_1)
    jointee_2 = jointee(id_2)
    joined_range = FrameJointer.new(jointee_1, jointee_2).join
    create_new_jointee(jointee_1, jointee_2, joined_range)
  end

  private

  def db; @db; end
  def files; @files; end
  def jointees; @jointees; end
  def max_id; @max_id; end
  def jointee(id); jointees.fetch(id); end
  def utils; Utils.instance; end

  def initialize_jointees
    @jointees = {}
    CSV.parse(db, {headers: true}) do |row|
      id = row["id"].to_i
      @max_id = id if id > @max_id
      @jointees[id] = {
        file: row["file"],
        dir: row["dir"],
        still_before_in: "#{row["dir"]}/#{row["still_before_in"]}",
        just_in: "#{row["dir"]}/#{row["just_in"]}",
        middle_in: "#{row["dir"]}/#{utils.middle_frame(row["just_in"], row["hole_in"])}",
        hole_in: "#{row["dir"]}/#{row["hole_in"]}",
        center_in: "#{row["dir"]}/#{row["center_in"]}",
        center_out: "#{row["dir"]}/#{row["center_out"]}",
        just_out: "#{row["dir"]}/#{row["just_out"]}",
        middle_out: "#{row["dir"]}/#{utils.middle_frame(row["just_out"], row["hole_out"])}",
        hole_out: "#{row["dir"]}/#{row["hole_out"]}",
        still_after_out: "#{row["dir"]}/#{row["still_after_out"]}"
      }
      @jointees[id][:first_frame] = utils.first_frame(@jointees[id])
      @jointees[id][:last_frame] = utils.last_frame(@jointees[id])
    end
  end

  def create_new_jointee(jointee_1, jointee_2, jointed_range)
    id = (@max_id += 1)
    file = id.to_s.rjust(5, '0') + '.mp4'
    dir = file + '-dir'
    utils.create_or_clear_jointee_dir(dir)

    frame_counter = 0
    utils.frame_range(jointee_1[:first_frame], jointee_1[:center_out])[0...-1].each do |frame|
      frame_counter += 1
      utils.cp(frame, utils.new_frame(dir, frame_counter))
    end
    jointed_range.each do |frame|
      frame_counter += 1
      utils.cp(frame, utils.new_frame(dir, frame_counter))
    end
    utils.frame_range(jointee_2[:center_in], jointee_2[:last_frame])[1..-1].each do |frame|
      frame_counter += 1
      utils.cp(frame, utils.new_frame(dir, frame_counter))
    end
    command = "avconv -start_number 1 -r 25 -f image2 -i \"#{dir}/%5d.png\" -vcodec h264 #{file}"
    system command
  end
end
