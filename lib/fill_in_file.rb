class HashToCsv

  def self.perform(array_with_product, file)
    header = array_with_product.first.keys
    csv = CSV.generate do |csv|
      csv << header
      array_with_product.each do |item|
        csv << item.values
      end
    end
    File.write(file, csv)
  end
end
