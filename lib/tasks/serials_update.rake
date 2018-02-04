namespace :serials_update do
  desc "Updates one serial"
  task :update_serial, [:serial_id]  => :environment do |t, args|
    require 'net/http'
    require 'rss'
    @serial_id=args.serial_id.to_i
    @serials=Serial.all
    puts "Checking serial: #{@serials[@serial_id].name}"
    url=ENV['LOSTFILM_RSS_URL']
    type=ENV['MEDIA_TYPE']
    uid=ENV['LOSTFILM_UID']
    pass=ENV['LOSTFILM_PASS']
    usess=ENV['LOSTFILM_USESS']
    
    open(url) do |rss|
      feed = RSS::Parser.parse(rss)
      puts "Проверяю наличие новых серий для:"
      puts @serials[@serial_id].name
      serial=@serials[@serial_id]
      real_serail_id=@serial_id +1
      series=Series.where(:serial_id => real_serail_id)
      feed.items.each do |item|
        if item.title.to_s.include?(@serials[@serial_id].name) and item.link.to_s.include?(type) 
          puts "Saving #{item.title} magnet link to db:"
          puts item.link.to_s.delete("\n").gsub("www","old")
          magnet_link=%x(wget --content-disposition -q --header "Cookie: uid=#{uid}; pass=#{pass}; usess=#{usess}" "#{item.link.to_s.delete("\n").gsub("www","old")}" -O tmp.torrent; transmission-show -m tmp.torrent)
          puts magnet_link
          filename=%x(wget --content-disposition -q --header "Cookie: uid=#{uid}; pass=#{pass}; usess=#{usess}" "#{item.link.to_s.delete("\n").gsub("www","old")}" -O tmp.torrent; transmission-show tmp.torrent |grep FILES -A2|awk 'NR == 3{print$1}'&& rm tmp.torrent)
          season_serie=/S\d\dE\d\d/.match(item.title.to_s).to_s
          season=/S\d\d/.match(season_serie).to_s.delete("S").to_i
          serie=/E\d\d/.match(season_serie).to_s.delete("E").to_i
          series.find_or_initialize_by(:serie_name =>  item.title.to_s).update_attributes!(:serie_name =>  item.title.to_s,:serial_name => serial.name,:magnet => magnet_link,:serie =>serie,:season =>season,:filename =>filename)
        end
      end   
    end
  end

  desc "Updating all serials from tracked list"
  task update_all: :environment do
    require 'net/http'
    require 'rss'
    @serials=Serial.all.where(:tracked => true)
    @serials.each{|serial|
    url=ENV['LOSTFILM_RSS_URL']
    type=ENV['MEDIA_TYPE']
    uid=ENV['LOSTFILM_UID']
    pass=ENV['LOSTFILM_PASS']
    usess=ENV['LOSTFILM_USESS']
    
      open(url) do |rss|
        feed = RSS::Parser.parse(rss)
        puts "Проверяю наличие новых серий для:"
        puts serial.name
        series=Series.where(:serial_id => serial.id)
        feed.items.each do |item|
          if item.title.to_s.include?(serial.name) and item.link.to_s.include?(type) 
            puts "Saving #{item.title} magnet link to db:"
            puts item.link.to_s.delete("\n").gsub("www","old")
            magnet_link=%x(wget --content-disposition -q --header "Cookie: uid=#{uid}; pass=#{pass}; usess=#{usess}" "#{item.link.to_s.delete("\n").gsub("www","old")}" -O tmp.torrent; transmission-show -m tmp.torrent && rm tmp.torrent)
            filename=%x(wget --content-disposition -q --header "Cookie: uid=#{uid}; pass=#{pass}; usess=#{usess}" "#{item.link.to_s.delete("\n").gsub("www","old")}" -O tmp.torrent; transmission-show tmp.torrent |grep FILES -A2|awk 'NR == 3{print$1}'&& rm tmp.torrent)
            puts magnet_link
            season_serie=/S\d\dE\d\d/.match(item.title.to_s).to_s
            season=/S\d\d/.match(season_serie).to_s.delete("S").to_i
            serie=/E\d\d/.match(season_serie).to_s.delete("E").to_i
            series.find_or_initialize_by(:serie_name =>  item.title.to_s).update_attributes!(:serie_name =>  item.title.to_s,:serial_name => serial.name,:magnet => magnet_link,:serie =>serie,:season =>season,:filename =>filename)
          end
        end   
      end
    }
  end

desc "This will download all torrents from list"
  task download_all: :environment do
    require 'fileutils'
    require 'shellwords'
    require 'transmission'

    sms_api_id=ENV['SMS_API_ID']
    phone=ENV['PHONE_NUMBER']
    @episodes=Series.all.where(:downloaded => nil,:torrent_status => nil)
    previous_magnet="nema"
    @episodes.each{|episode|
      data_dir=Rails.root.join("public", "videos")
      download_dir=Shellwords.escape("#{data_dir.to_s}/#{episode.serial_name.to_s.delete("\'!:").gsub(" ","_")}")
      puts download_dir
      unless File.directory?(download_dir)
        FileUtils.mkdir_p(download_dir)
      end
      begin
      %x(chmod a+rw #{download_dir})
      hostname=ENV['TRANSMISSION_IP']
      sessionid="IWoy2MCM9sDmq7Jaam0wfyGUuKHi54b75RcnqfbM4r9WVuSX"
      
      rpc = Transmission::RPC.new host: hostname, port: 9091, ssl: false, session_id: sessionid
      torrent = Transmission::Model::Torrent.add arguments: {filename: "#{episode.magnet}"}, fields: ['id'], connector: rpc
      torrent_id = torrent.attributes['id']
      previous_t_id=torrent_id
      torrent.set_location download_dir
      torrent = nil
      episode.update_attributes!(:torrnetid => torrent_id, :torrent_status => "downloading")
      %x(curl -d "text=Quered: #{episode.serial_name}-S#{episode.season}E#{episode.serie}" "http://sms.ru/sms/send?api_id=#{sms_api_id}&to=#{phone}")
      rescue
      test=Series.all.where(:magnet => episode.magnet)
      test.each{|z|
          if z.torrnetid != nil then
            episode.update_attributes!(:torrnetid => z.torrnetid, :torrent_status => "downloading")
          end
      }  
          
      end
    }
  end 
  
  desc "This will download all torrents from list"
  task check_for_status: :environment do
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
  
end#last end

  
   
