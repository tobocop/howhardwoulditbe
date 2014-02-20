require 'delayed_job'

class DJExceptionalPlugin < Delayed::Plugin
  callbacks do |lifecycle|
    lifecycle.around(:invoke_job) do |job, *args, &block|
      begin
        block.call(job, *args)
      rescue Exception => error
        ::Exceptional::Catcher.handle(error)
        raise error
      end
    end
  end
end
