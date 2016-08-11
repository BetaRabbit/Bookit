class Amazon
  require 'net/http'
  require 'stringio'
  require 'zlib'
  require 'nokogiri'

  PRODUCT_URL = /^http[s]?:\/\/www\.amazon\.cn/
  PRODUCT_URL_PATTERN_1 = /dp\/(\w+)/
  PRODUCT_URL_PATTERN_2 = /gp\/product\/(\w+)/

  def self.validate_url(url)
    url =~ PRODUCT_URL
  end

  def self.get_item_id(url)
    match = PRODUCT_URL_PATTERN_1.match(url)

    if match
      match[1]
    else
      match = PRODUCT_URL_PATTERN_2.match(url)
      match.nil? ? nil : match[1]
    end
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
    "https://www.amazon.cn/dp/#{item_id}"
  end

  def self.prepare_html_request(uri)
    req = Net::HTTP::Get.new(uri)
    req['Connection'] = 'keep-alive'
    req['Cache-Control'] = 'max-age=0'
    req['Upgrade-Insecure-Requests'] = '1'
    req['User-Agent'] = 'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.103 Safari/537.36'
    req['Accept'] = 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8'
    req['Accept-Encoding'] = 'gzip, deflate, sdch, br'
    req['Accept-Language'] = 'zh-CN,zh;q=0.8'

    req
  end

  def self.extract_data_from_html(item_id, origin_url, html)
    begin
      doc = Nokogiri::HTML(html)
      title = doc.css('#productTitle').first.content

      author = doc.css('#byline').first
                 .content
                 .strip
                 .gsub(/\s+\(/, ' (')
                 .gsub(/[\n\t]/, '')
                 .gsub(/&.+$/, '')

      price = doc.css('#tmmSwatches li.swatchElement.selected span.a-color-price').first
                .content
                .strip
                .gsub(/[^\d.]/, '')

      publisher = doc.css('#detail_bullets_id table tr td div ul li').first
                    .content
                    .strip
                    .gsub(/.+:\s+/, '')

      image = /(http[^\\]+?)":/.match(doc.css('#img-canvas img').first.attr('data-a-dynamic-image'))[0]

      {
          title: title,
          item_id: item_id,
          author: author,
          price: price.to_f,
          publisher: publisher,
          image: image,
          origin_url: origin_url,
          purchase_url: "https://www.amazon.cn/dp/#{item_id}"
      }
    rescue
      nil
    end
  end
end
