ActionMailer::Base.register_interceptor(PreventMailInterceptor) unless Rails.env.production?
