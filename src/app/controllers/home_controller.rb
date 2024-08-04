class HomeController < ApplicationController

  def associate_orcid

    if current_user and params[:code]
      ## change to the centralized app if any (implented with the ASAP app)
#      client_id = "APP-UIU8KR3XZNMUZ8ZY"
#      secret = "0c8e89c1-9962-4cf9-9bdd-c7888f1b141b"
      #      res = `curl -L -k -H 'Accept: application/json' --data 'client_id=#{client_id}&client_secret=#{secret}&grant_type=authorization_code&redirect_uri=https://asap.epfl.ch/associate_orcid2&code=#{params[:code]}' https://orcid.org/oauth/token`
      client_id = "APP-ZYQLKP3CVR9J5SLI"
      secret = "ea6edddf-364b-4195-9f6f-fa92b5258470"
#      cmd = "curl -L -k -H 'Accept: application/json' --data 'client_id=#{client_id}&client_secret=#{secret}&grant_type=authorization_code&redirect_uri=https://reprosci.epfl.ch/associate_orcid&code=#{params[:code]}' https://orcid.org/oauth/token"
 #     res = `#{query}`
      #      res = %x(#{cmd})
      
      # Define the URL and URI
      url = URI.parse('https://orcid.org/oauth/token')
      
      # Set up the HTTP object with SSL
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE  # Equivalent to -k in curl (not recommended for production)
      
      # Define the request
      request = Net::HTTP::Post.new(url.request_uri)
      request['Accept'] = 'application/json'
      
      # Set up the form data
   
      p = {
        'client_id' => client_id,
        'client_secret' => secret,
        'grant_type' => 'authorization_code',
        'redirect_uri' => 'https://reprosci.epfl.ch/associate_orcid',
        'code' => params[:code]
      }
      
      # Encode the form data
      request.set_form_data(p)
      
      # Make the request
      response = http.request(request)
      
      # Output the response
      puts "Response Code: #{response.code}"
      puts "Response Body: #{response.body}"
      
      @h_res = Basic.safe_parse_json(response.body, {})
      #logger.debug("query: " + cmd)
      #logger.debug("res: " + res.to_json)
#      logger.debug("name: " + @h_res['name'])
#      logger.debug("key: " + @h_res['orcid'])
      h_orcid_user = {
        :key => @h_res['orcid'],
        :name => @h_res['name']#,
      #  :user_id => current_user.id
      }
      orcid_user = OrcidUser.where(:key => h_orcid_user[:key]).first
      if !orcid_user
        orcid_user = OrcidUser.new(h_orcid_user)
        orcid_user.save
      else
        orcid_user.update_attributes(h_orcid_user)
      end
      
      if orcid_user and @h_res['orcid']
        current_user.update_attributes(:orcid_user_id => orcid_user.id)
        
        ## create wous if not exist yet
        shares = Share.where(:user_id => current_user.id).all
        shares.each do |s|
          wou = WorkspaceOrcidUser.where(:orcid_user_id => orcid_user.id, :workspace_id => s.workspace_id).first
          if !wou
            wou = WorkspaceOrcidUser.new(:workspace_id => s.workspace_id, :orcid_user_id => orcid_user.id)
            wou.save
          end
        end
        notice = helpers.image_tag("orcid.svg", :width => '25px') + " ORCID successfully associated: #{@h_res['name']} [#{@h_res['orcid']}]"
      else
        notice =  helpers.image_tag("orcid.svg", :width => '25px') + " ORCID user wasn't associated"
      end
      
    else
      notice =  helpers.image_tag("orcid.svg", :width => '25px') + ' ORCID association failed'
    end
    
    redirect_to root_path, :notice => notice

  end

  def welcome
  end

  def faq
  end

end
