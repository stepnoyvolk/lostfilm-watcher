class SeriesController < ApplicationController
  before_action :set_series, only: [:show, :edit, :update, :destroy]

  # GET /series
  # GET /series.json
  def index
    @series = Series.all.order('updated_at DESC')
  end

  # GET /series/1
  # GET /series/1.json
  # GET /series/new
  def download
  end
  def new
    @series = Series.new
  end
  def lastweek
    require 'fileutils'
    require 'shellwords'
    require 'transmission'

    sms_api_id=ENV['SMS_API_ID']
    phone=ENV['PHONE_NUMBER']
    @episodes=Series.all.where(:torrent_status => "downloading")
    @episodes.each{|episode|
      begin
      puts episode.torrnetid
      hostname=ENV['TRANSMISSION_IP']
      sessionid="IWoy2MCM9sDmq7Jaam0wfyGUuKHi54b75RcnqfbM4r9WVuSX"
      rpc = Transmission::RPC.new host: hostname, port: 9091, ssl: false, session_id: ''
      torrent = Transmission::Model::Torrent.find episode.torrnetid.to_i, connector: rpc
      filename=torrent.attributes['name']
      puts filename
        if torrent.attributes['doneDate'] != 0 and torrent.attributes['doneDate'] != "0" and torrent.attributes['doneDate'] != nil
            episode.update_attributes!(:filename => filename, :torrent_status => "Downloaded", :downloaded => true)
            %x(curl -d "text=Downloaded: #{episode.serial_name}-S#{episode.season}E#{episode.serie}" "http://sms.ru/sms/send?api_id=#{sms_api_id}&to=#{phone}")
        end
      rescue
        next
      end
    }
  end
  # GET /series/1/edit
  def edit
  end
  def download
    @id=params[:id].to_i 
    if @id<0 then 
      system "rake serials_update:download_all"
    else
      system "rake serials_update:download_episode[#{@id}]"
    end
  end
  def add_full_serial
    @serials=Serial.all
  end
  def download_full_serial
  serials=Serial.all
  serial=Serial.find_by name: params[:serial]
  @serial_name=params[:serial]
  @serial=serial.id
  @torrent=params[:torrent]
  @serial_to_download_name=@serial
#  @debug= %x(rake serials_update:download_full_serial["#{@serial}","#{@serial_name}","#{@torrent}"])
    %x(wget -O /tmp/serail_full.torrent #{params[:torrent]})
    magnet= %x(transmission-show -m /tmp/serail_full.torrent)
    files = %x(transmission-show /tmp/serail_full.torrent |sed -n -e '/FILES/,$p'|egrep -i '.AVI \|.MP4\|.MKV'|egrep -oe "/.*"|awk '{print $1}').to_s.delete("/").split.to_a
    serials=Serial.all
    serial=serials[@serial]
    files.each {|file|
          season_serie=/[S|s]\d\d[E|e]\d\d/.match(file.to_s).to_s
          season=/[S|s]\d\d/.match(season_serie).to_s.delete("Ss").to_i || 0 
          serie=/[E|e]\d\d/.match(season_serie).to_s.delete("Ee").to_i || 0
          puts "Season:#{season} Episode:#{serie}"
	  puts file
          series=Series.where(:serial_id => @serial)
          series.find_or_initialize_by(:serie_name =>  file).update_attributes!(:serie_name =>  file,:serial_name => params[:serial],:magnet => magnet,:serie =>serie,:season =>season,:filename => file)
      }
  end
  def add_full_season
  end
  def play
    require 'shellwords'
    serial=params[:serial].to_s.delete("\'!:").gsub(" ","_")
    episode=params[:episode].to_s.gsub(" ","_")
    @filename="#{serial}/#{episode}"
  end
  # POST /series
  # POST /series.json
  def create
    @series = Series.new(series_params)

    respond_to do |format|
      if @series.save
        format.html { redirect_to @series, notice: 'Series was successfully created.' }
        format.json { render :show, status: :created, location: @series }
      else
        format.html { render :new }
        format.json { render json: @series.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /series/1
  # PATCH/PUT /series/1.json
  def update
    respond_to do |format|
      if @series.update(series_params)
        format.html { redirect_to @series, notice: 'Series was successfully updated.' }
        format.json { render :show, status: :ok, location: @series }
      else
        format.html { render :edit }
        format.json { render json: @series.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /series/1
  # DELETE /series/1.json
  def destroy
    seria=Series.find_by id: @series.id 
    file = seria.filename
    data_dir=Rails.root.join("public", "videos")
    %x(find #{data_dir} -type f -name "#{seria.filename}" -delete )
    @series.destroy
      respond_to do |format|
      format.html { redirect_to series_index_url, notice: "Episode was removed from db. Next files were removed:#{seria.filename}"}
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_series
      @series = Series.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def series_params
      params.require(:series).permit(:serial_id, :serial_name, :serie_name, :magnet, :season, :serie)
    end
end
