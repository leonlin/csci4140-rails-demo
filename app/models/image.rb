class Image < ActiveRecord::Base
  attr_accessible :description, :name, :path, :size, :thumbnail

  validates_length_of :description, maximum: 50, allow_blank: true

  def self.save(upload)
    if upload.nil? then return {status: 'fail', msg: 'no selected file' } end
    size = upload.size
    if size > 1000000 then return {status: 'fail', msg: 'size too large'} end
    extname = File.extname(name)
    #if !['jpg', 'png', 'gif'].include? extname
    #  return {status: 'fail', msg: 'wrong extension'}
    #end
    name = upload.original_filename
    directory = 'public/image'
    path = File.join(directory, name)
    if File.exists? path
      ts = Time.new.to_i.to_s
      thumbnail = path+'.tn-pending'+ts
      path += '-pending'+ts
      File.open(path, 'wb') { |f| f.write(upload.read)}
      if !['JPEG', 'PNG', 'GIF'].include?(`identify #{path}`.split[1])
        File.delete(path)
        return {status: 'fail', msg: `not a image`}
      end
      `convert -resize 100x100 #{path} #{thumbnail}`
      return {status: 'pending', name: name, size: size, extname:extname, path: path[7..-1], thumbnail: thumbnail[7..-1]}
    else
      File.open(path, 'wb') { |f| f.write(upload.read)}
      if !['JPEG', 'PNG', 'GIF'].include?(`identify #{path}`.split[1])
        File.delete(path)
        return {status: 'fail', msg: `not a image`}
      end
      thumbnail = path+'.tn'
      `convert -resize 100x100 #{path} #{thumbnail}`
      return {status: 'OK', name: name, size: size, extname:extname, path: path[7..-1], thumbnail: thumbnail[7..-1]}
    end
  end

  def upload_finalize(new_name)
    if new_name == name
      tail = path.rindex('-')
      new_path = path[0, path.size-tail]
      new_thumbnail = path[0, thumbnail.size-tail]
    else
      self.name = new_name
      new_path = File.join('image/', name)
      new_thumbnail = new_path+'tn'
    end
    File.rename('public/'+path, 'public/'+new_path)
    File.rename('public/'+thumbnail, 'public/'+new_thumbnail)
    self.path = new_path
    self.thumbnail = new_thumbnail
    return self
  end
end
