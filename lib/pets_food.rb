class PetsFood

  def initialize(link, file)
    @page_link = link
    @file = file
  end

  def self.perform(link, file)
    new(link, file).perform
  end

  def perform
    array_with_products = Scraper.new(@page_link).perform
    array_with_products.uniq! { |item| item[:Name] }
    HashToCsv.perform(array_with_products, @file)
  end
end
