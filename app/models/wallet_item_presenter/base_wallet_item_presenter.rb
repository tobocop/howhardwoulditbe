module WalletItemPresenter
  class BaseWalletItemPresenter
    def as_json(options={})
      {
          description: description,
          icon_description: icon_description,
          icon_url: icon_url,
          template_name: template_name,
          title: title
      }
    end

    def initialize
      raise NotImplementedError, 'You should implement this in your subclass'
    end

    def partial
      raise NotImplementedError, 'You should implement this in your subclass'
    end

    def icon_url
      raise NotImplementedError, 'You should implement this in your subclass'
    end

    def icon_description
      raise NotImplementedError, 'You should implement this in your subclass'
    end

    def title
      nil
    end

    def description
      nil
    end

    def template_name
      raise NotImplementedError, 'You should implement this in your subclass'
    end
  end
end