class Jd
  require 'net/http'
  require 'stringio'
  require 'zlib'
  require 'nokogiri'

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
    encode_options = {:invalid => :replace, :undef => :replace, :replace => '?'}
    begin
      doc = Nokogiri::HTML(html)
      title = doc.css('#name h1').first
                .try(:content)
                .try(:force_encoding, 'gbk')
                .try(:encode, 'utf-8', 'gbk', encode_options)
                .try(:strip)

      author = doc.css('#p-author').first
                 .try(:content)
                 .try(:force_encoding, 'gbk')
                 .try(:encode, 'utf-8', 'gbk', encode_options)
                 .try(:strip)
                 .try(:gsub, /[\n\t]/, '')
                 .try(:gsub, /&.+$/, '')
      price = doc.css('#jd-price').first
                .try(:content)
                .try(:force_encoding, 'gbk')
                .try(:encode, 'utf-8', 'gbk', encode_options)
                .try(:strip)
                .try(:gsub, /[^\d.]/, '')
      publisher = doc.css('#parameter2 li:first-child a').first
                    .try(:content)
                    .try(:force_encoding, 'gbk')
                    .try(:encode, 'utf-8', 'gbk', encode_options)
                    .try(:strip)
      image = 'http:' + doc.css('#spec-n1 img').first
                .try(:attr, 'src')

      {
          title: title,
          item_id: item_id,
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
end
