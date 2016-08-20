class Jd
  require 'net/http'
  require 'stringio'
  require 'zlib'
  require 'nokogiri'
  require 'json'

  PRODUCT_URL = /^http[s]?:\/\/item\.jd\.com/
  PRODUCT_URL_PATTERN = /item\.jd\.com\/(\d+)\.html/

  def self.validate_url(url)
    url =~ PRODUCT_URL
  end

  def self.get_item_id(url)
    match = PRODUCT_URL_PATTERN.match(url)

    match ? match[1] : nil
  end

  def self.search(item_id, origin_url)
    uri = URI(prepare_html_uri(item_id))
    req = prepare_html_request(uri)

    res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => uri.scheme == 'https') do |http|
      http.request(req)
    end

    # unzip gzipped response body
    extract_data_from_html(item_id, origin_url,
                           Zlib::GzipReader.new(StringIO.new(res.body)).read)
  end

  private
  def self.prepare_html_uri(item_id)
    "http://item.jd.com/#{item_id}.html"
  end

  def self.prepare_html_request(uri)
    req = Net::HTTP::Get.new(uri)
    req['Connection'] = 'keep-alive'
    req['Cache-Control'] = 'no-cache'
    req['Upgrade-Insecure-Requests'] = '1'
    req['User-Agent'] = 'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.103 Safari/537.36'
    req['Accept'] = 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8'
    req['Accept-Encoding'] = 'gzip, deflate, sdch'
    req['Accept-Language'] = 'zh-CN,zh;q=0.8'

    req
  end

  def self.extract_data_from_html(item_id, origin_url, html)
    begin
      html.force_encoding('gbk')
      html.encode!('utf-8', :undef => :replace, :invalid => :replace, :replace => '?')
      doc = Nokogiri::HTML(html)
      title = doc.css('#name h1').first
                .content
                .strip

      author = doc.css('#p-author').first
                 .content
                 .strip
                 .gsub(/[\n\t]/, '')
                 .gsub(/&.+$/, '')

      price = doc.css('#jd-price').first
                .content
                .strip
                .gsub(/[^\d.]/, '')

      publisher = doc.css('#parameter2 li').find { |item| /出版社/ =~ item.content }
                    .css('a').first.content

      image = 'http:' + doc.css('#spec-n1 img').first.attr('src')

      price = price.blank? ? get_price(item_id) : price

      {
          title: title,
          jd_id: item_id,
          author: author,
          price: price,
          publisher: publisher,
          image: image,
          origin_url: origin_url,
          purchase_url: "http://item.jd.com/#{item_id}.html"
      }
    rescue => e
      puts e.message
      nil
    end
  end

  def self.get_price(item_id)
    uri = URI("http://p.3.cn/prices/get?type=1&area=12_904_905&pdtk=&pduid=818879776&pdpin=&pdbp=0&skuid=J_#{item_id}&callback=cnp")
    req = prepare_html_request(uri)

    res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => uri.scheme == 'https') do |http|
      http.request(req)
    end

    json = JSON.parse(Zlib::GzipReader.new(StringIO.new(res.body)).read.gsub(/^cnp\(/, '').gsub(/\);/, ''))

    json.first['p']
  end
end
