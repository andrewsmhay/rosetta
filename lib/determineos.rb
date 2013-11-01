require 'rbconfig'

# Detects the operating system that the script is being run on
class Determineos
  def os 
    @os ||= (
      host_os = RbConfig::CONFIG['host_os']
      case host_os
      when /mswin|msys|mingw|bccwin|wince/
        :windows
      when /darwin|mac os|linux|solaris|bsd/
        :nix
      else
        raise Error::WebDriverError, "unknown os: #{host_os.inspect}"
     end
  )  
  end
end
