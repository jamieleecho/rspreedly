module RSpreedly

  class Invoice < Base

    attr_accessor :subscription_plan_id, 
                  :subscriber,
                  :closed,
                  :created_at,
                  :token,
                  :updated_at,
                  :price,
                  :amount,
                  :currency_code,
                  :line_items

    # Create an Invoice (more)
    # POST /api/v4/[short site name]/invoices.xml
    def create
      begin
        create!
      rescue RSpreedly::Error::Base
        nil
      end      
    end

    def create!
      result = api_request(:post, "/invoices.xml", :body => self.to_xml)
      self.attributes = result["invoice"]
      true      
    end

    alias_method :save,   :create
    alias_method :save!,  :create!

    def subscriber=(data)
      if data.is_a? Hash
        data = RSpreedly::Subscriber.new(data)
      end
      @subscriber = data
    end
    
    def line_items=(data)
      @line_items = []
      data.each do |item|
        if item.is_a? Hash
          item = RSpreedly::LineItem.new(item)
        end
        @line_items << item
      end
    end

    # Pay an Invoice (more)
    # PUT /api/v4/[short site name]/invoices/[invoice token]/pay.xml
    def pay(payment)
      begin
        pay!(payment)
      rescue RSpreedly::Error::Base
        nil
      end
    end
    
    def pay!(payment)
      result = api_request(:put, "/invoices/#{self.token}/pay.xml", :body => payment.to_xml(:outer => 'payment'), :format => nil)
      begin
        result = MultiXml.parse result
        self.attributes = result["invoice"]
        true      
      rescue MultiXml::ParseError
        nil
      end

    end
    
  end
end
