class ImagesController < ApplicationController

  before_filter :signed_in_user, only: [:display, :new, :create, :update, :destroy]

  def display
  end

  def new
  end

  def index
    @config = params
    @config.each {|k, v| @config[k] = v.to_i}
    @config[:cols] ||= 2
    @config[:rows] ||= 2
    @config[:order] ||= 0
    @config[:sort] ||= 0
    @config[:page] ||= 1
    images_per_page = @config[:rows] * @config[:cols]
    @config[:total] = (Image.count + images_per_page - 1) / images_per_page
    @sorts = [['File size', 'size', 0],['Name', 'name', 1],['Upload time', 'created_at', 2]]
    @orders = [['Ascending', 'ASC', 0],['Descending', 'DESC', 1]]
    @images = Image.where("pending = ?", false)
      .order("#{@sorts[@config[:sort]][1]} #{@orders[@config[:order]][1]}")
      .offset(images_per_page*(@config[:page]-1))
      .limit(images_per_page)
  end

  def create
    info = Image.save(params[:upload])
    if info[:status] == 'fail'
      flash[:error] = info[:msg]
      redirect_to new_image_path
    end
    @image = Image.new(
      name: info[:name],
      path: info[:path],
      thumbnail: info[:thumbnail],
      description: params[:description],
      size: info[:size],
    )
    if info[:status] == 'pending'
      @image.pending = true
      if @image.save
        render 'duplicate'
      else
        redirect_to new_image_path
      end
    end
    if info[:status] == 'OK'
      @image.pending = false
      if @image.save
        redirect_to display_path
      else
        redirect_to new_image_path
      end
    end
  end

  def update
    @choice = params[:options].to_i
    image = Image.find(params[:id])
    if @choice == 0
      image.upload_finalize(image.name)
      image.pending = false
      image.save
      redirect_to images_path(@config)
    elsif @choice == 1
      image.upload_finalize(params[:new_name])
      image.pending = false
      image.save
      redirect_to images_path(@config)
    else
      File.delete('public/'+image.path)
      File.delete('public/'+image.thumbnail)
      image.destroy
      redirect_to images_path(@config)
    end
  end

  def destroy
    @config = {}
    @config[:cols] = params[:cols]
    @config[:rows] = params[:rows]
    @config[:order] = params[:order]
    @config[:sort] = params[:sort]
    @config[:page] = 1
    @deleting_images = params[:images]
    if !@deleting_images.nil?
      @deleting_images.each do |i|
        image = Image.find(i[0])
        if image
          File.delete('public/'+image.path)
          File.delete('public/'+image.thumbnail)
          image.destroy
        end
      end
    end
    redirect_to images_path(@config)
  end
end
