module APIError
  class Base < Grape::Exceptions::Base
    def initialize *args
      if args.length == 0
        t_key = self.class.name.underscore.gsub(%r{\/}, ".")
        super message: t_key
      else
        super(*args)
      end
    end
  end

  class Unauthenticated < APIError::Base
  end

  class Unauthorized < APIError::Base
  end

  class TokenExpired < APIError::Base
  end

  class PwdNotCorrect < APIError::Base
  end

end