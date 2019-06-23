def money_animation

    10.times do
        i =1
        while i < 9
            print "\033[2J"
            File.foreach("animation/#{i}.rb") { |f| puts f }
            sleep(0.05)
            i += 1
        end

    end
end