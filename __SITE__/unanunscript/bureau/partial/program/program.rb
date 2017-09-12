# encoding: utf-8
class Unan
  class UUProgram


    def current_pday_d
      @current_pday_d ||= begin
                            data[:current_pday]
                          end
    end

    def count_points
      @count_points ||= data[:points] 
    end

    def start_time_d
      @start_time_d ||= begin
                          Time.at(data[:created_at]).strftime('%d %m %Y')
                        end
    end
    def end_time_d
      @end_time_d ||= '--- non calculée pour le moment ---'
    end

  end #/UUProgram
end#Unan
