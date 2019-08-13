class Scraper
  attr_reader :array
  ITEMS_PER_PAGE = 25

  def initialize(link)
    @page_link = link
    @array = []
  end

  def perform
    page_info
    array
  end

  def open_page(link, page_number = 1)
    http = if page_number == 1
             Curl.get(link)
           else
             Curl.get("#{link}/?p=#{page_number}".gsub!('//?p', '/?p'))
           end
    Nokogiri::HTML(http.body_str)
  rescue
    raise 'open page error'
  end

  def page_info
    doc = open_page(@page_link)

    number_page = number_pages(doc)
    return if number_page.nil?

    links = fetch_from_page(doc)
    2.upto(number_page) do |page_number|
      doc = open_page(@page_link, page_number)
      links += fetch_from_page(doc)
    end
    collect_product_info(links)
  end

  def collect_product_info(links)
    links.each do |link|
      doc = open_page(link[:href])
      @array += product_info(doc)
    end
  end

  def fetch_from_page(doc)
    links = doc.xpath("//a[@class='product-name']").to_a
    puts links
    links
  end

  def number_pages(page)
    str = page.xpath("//span[@class='heading-counter']")&.text
    return if str.nil?

    match_res = str.match(/\d+/)
    return if match_res.nil?

    (match_res[0].to_f / ITEMS_PER_PAGE).ceil
  end

  def product_info(doc)
    all_items = []
    size, price = price_and_size(doc)
    name = product_name(doc)
    image = image_link(doc)
    size.each_index do |index|
      item = {}
      item[:Name] = "#{name} - #{size[index].text}"
      item[:Price] = price[index].text.gsub(/[^\d,\.]/, '')
      item[:Image] = image
      puts item
      all_items << item
    end
    all_items
  end

  def price_and_size(doc)
    price_and_size = doc.xpath("//div[@class='attribute_list']//label")
    price  = get_value(price_and_size, "//span[@class='price_comb']", :to_a)
    size = get_value(price_and_size, "//span[@class='radio_label']", :to_a)
    [size, price]
  end

  def product_name(doc)
    doc.xpath("//h1[@class = 'product_main_name']").text
  end

  def image_link(doc)
    doc.xpath("//div[@class='clearfix']//img//@src")
  end

  def get_value(node, path, method)
    node.xpath(path).send(method)
  end
end
