
namespace :serials_db do
  desc "Updates List of existing serials on Lostfilm.tv"
  task update: :environment do
    require "net/http"
    require "selenium-webdriver"
    Selenium::WebDriver::Chrome.driver_path=File.join(Rails.root, 'vendor', "chromedriver")
    page="http://www.lostfilm.tv/series/"
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument('--ignore-certificate-errors')
    options.add_argument('--disable-popup-blocking')
    options.add_argument('--disable-translate')
    options.add_argument('--headless')
    browser = Selenium::WebDriver.for :chrome, options: options
    browser.navigate.to page
    wait = Selenium::WebDriver::Wait.new(:timeout => 15)
    begin
      wait.until {
        browser.execute_script("window.scrollBy(0,900000)", "")
      }
    rescue
      puts "Reached timeout loading dinamyc page as it was expected"
    end
    browser.find_elements(:class, "name-en").each{|serial|
      about=serial.find_element(:xpath, "..").find_element(:xpath, "..").attribute("textContent")
      link=serial.find_element(:xpath, "../..").attribute("href")
      image=serial.find_element(:xpath, "../..").find_element(:class, "picture-box").find_element(:tag_name,'img').attribute("src")
      Serial.find_or_initialize_by(:name => serial.attribute("textContent")).update_attributes!(:name => serial.attribute("textContent"),:image => image, :serial_link =>link, :about_short => about, :about_full => "")
    }

  end

end
