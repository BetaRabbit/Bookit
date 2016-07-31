class Amazon
  require 'time'
  require 'openssl'
  require 'base64'
  require 'net/http'
  require 'stringio'
  require 'zlib'
  require 'nokogiri'

  API = ''
  ACCESS_KEY_ID = 'AKIAI645PWZBCVEROBCA'
  SECRET_ACCESS_KEY = '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'
  ASSOCIATE_TAG = 'citrite-23'
  ENDPOINT = 'webservices.amazon.cn'
  REQUEST_URI = '/onca/xml'

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
    # try api request first
    uri = URI(prepare_api_uri(item_id))
    res = Net::HTTP.get(uri)
    book = extract_data_from_xml(item_id, origin_url, res)

    return book unless book.nil?

    # fallback to html request
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
  def self.prepare_api_uri(item_id)
    params = {
      'Service': 'AWSECommerceService',
      'Operation': 'ItemLookup',
      'AWSAccessKeyId': ACCESS_KEY_ID,
      'AssociateTag': ASSOCIATE_TAG,
      'IdType': 'ASIN',
      'ItemId': item_id,
      'ResponseGroup': 'Images,ItemAttributes,Offers',
      'Version': '2011-08-01',
      'Timestamp': Time.now.gmtime.iso8601
    }

    # Generate the canonical query
    canonical_query_string = params.sort.collect do |key, value|
      [
        URI.escape(key.to_s, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]")),
        URI.escape(value.to_s, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
      ].join('=')
    end.join('&')

    # Generate the string to be signed
    string_to_sign = "GET\n#{ENDPOINT}\n#{REQUEST_URI}\n#{canonical_query_string}"

    # Generate the signature required by the Product Advertising API
    signature = Base64.encode64(
      OpenSSL::HMAC.digest(
        OpenSSL::Digest.new('sha256'), SECRET_ACCESS_KEY,
        string_to_sign)).strip()

    # Generate the signed URL
    "http://#{ENDPOINT}#{REQUEST_URI}?#{canonical_query_string}&Signature=#{URI.escape(signature, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))}"
  end

  def self.prepare_html_uri(item_id)
    uri = "https://www.amazon.cn/dp/#{item_id}"
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
      title = doc.css('#productTitle').first.try(:content)
      author = doc.css('#byline').first
                   .try(:content)
                   .try(:gsub, /^\s+/, '')
                   .try(:gsub, /[\n\t]/, '')
                   .try(:gsub, /&.+$/, '')
      price = doc.css('#tmmSwatches li.swatchElement.selected span.a-color-price').first
                  .try(:content)
                  .try(:gsub, /[^\d.]/, '')
      publisher = doc.css('#detail_bullets_id table tr td div ul li').first
                      .try(:content)
                      .try(:gsub, /.+:\s+/, '')
      image = /(http[^\\]+?)":/.match(doc.css('#img-canvas img').first.try(:attr, 'data-a-dynamic-image'))
                  .try(:captures)
                  .try(:at, 0)
      {
          title: title,
          asin: item_id,
          author: author,
          price: price,
          publisher: publisher,
          image: image,
          origin_url: origin_url,
          purchase_url: "https://www.amazon.cn/dp/#{item_id}"
      }
    rescue
      nil
    end
  end

  def self.extract_data_from_xml(item_id, origin_url, xml)
    # TODO
  end
end