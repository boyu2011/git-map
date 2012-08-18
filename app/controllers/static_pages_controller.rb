class StaticPagesController < ApplicationController
	
	def home

		@search = params[:search]
		@empty_search_warning = 'Warning : search can not be empty!'

		if @search == nil
			return
		elsif @search == ''
			@search = @empty_search_warning
			return
		else

			#
			# collect locations of contributors of a repository
			#

			@markers = "["

			begin
				client = Octokit::Client.new
				contributors = client.contributors(@search)
			rescue StandardError => @error
				print @error
			end

			# The search string can not be found at api.github.com
			if @error.instance_of? Octokit::NotFound
				@error_msg = @search + ' can not be found! Try again.'
				return
			end

			@total_user_count = contributors.length
			@valid_user_count = 0
			
			for contributor in contributors
				# contirbutor & login exist
				if contributor!= nil and contributor.login != nil				
					user = Octokit.user(contributor.login)

					# user & location exist
					if user != nil and user.location != '' and user.location != nil and user.name != nil and user.html_url != nil

						# coordinates exist
						if (coordinates = Geocoder.coordinates(user.location)) != nil
						#if (coordinates = GeoKit::Geocoders::GoogleGeocoder.geocode(location).ll.split(','))!=nil	    

				          	if coordinates[0] != nil and coordinates[1] != nil
				          		marker_json = "{\"lng\": \"#{coordinates[1]}\", \"lat\": \"#{coordinates[0]}\", \"title\": \"#{user.name}\", \"description\": \"#{user.name}<br/><img src=#{user.avatar_url}/><br/>#{user.location}<br/><a href=#{user.html_url} target=_blank>#{user.html_url}</a><br/>\" }," 
				          		@markers += marker_json

				          		@valid_user_count += 1
				          		puts @valid_user_count.to_s + '  ' + user.location.to_s + '  ' + coordinates.to_s

				          		#break if @valid_user_count == 100
				          	end
				        end
				    end
				end
				puts '--------------------------------------------------------------------------------'
			end

			@markers += "]"

			#puts @markers
			puts 
		end
	end
end
