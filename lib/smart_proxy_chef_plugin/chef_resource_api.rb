module ChefPlugin
  module ChefResourceApi

    def resource(name, options = {})
      @name = name
      @options = options
      plural = get_plural_name

      show_action(name, plural) if actions.include?(:show)
      create_action(name, plural) if actions.include?(:create)
      update_action(name, plural) if actions.include?(:update)
      delete_action(name, plural) if actions.include?(:delete)
      list_action(plural) if actions.include?(:list)
    end

    def list_action(plural)
      get "/#{plural}" do
        logger.debug "Listing #{plural}"

        # to workaround chef-api issue, see https://github.com/sethvargo/chef-api/pull/34 for more details
        resources = get_connection.send(plural).all
        resources.map(&:to_hash).to_json
      end
    end

    def delete_action(name, plural)
      delete "/#{plural}/:id" do
        logger.debug "Starting deletion of #{name} #{params[:id]}"

        if (result = get_connection.send(plural).delete(params[:id]))
          logger.debug "#{name.capitalize} #{params[:id]} deleted"
          { :result => result }.to_json
        else
          log_halt 400, "#{name.capitalize} #{params[:id]} could not be deleted" unless result
        end
      end
    end

    # currently broken at least for clients - see https://github.com/sethvargo/chef-api/issues/33
    def update_action(name, plural)
      put "/#{plural}/:id" do
        logger.debug "Updating #{name} with parameters: " + params.inspect

        if (object = get_connection.send(plural).update(params[:id], params[name]))
          logger.debug "#{name.capitalize} #{params[:id]} updated"
          object.to_json
        else
          log_halt 400, {:errors => object.errors}.to_json
        end
      end
    end

    def create_action(name, plural)
      post "/#{plural}" do
        logger.debug "Creating #{name} with parameters: " + params.inspect

        object = get_connection.send(plural).new(params[name])
        if object.save
          logger.debug "#{name.capitalize} #{params[:id]} created"
          object.to_json
        else
          log_halt 400, {:errors => object.errors}.to_json
        end
      end
    end

    def show_action(name, plural)
      get "/#{plural}/:id" do
        logger.debug "Showing #{name} #{params[:id]}"

        if (object = get_connection.send(plural).fetch(params[:id]))
          object.to_json
        else
          log_halt 404, "#{name.capitalize} #{params[:id]} not found"
        end
      end
    end

    private

    def actions
      @options[:actions].nil? ? [:create, :show, :list, :update, :delete] : @options[:actions]
    end

    def get_plural_name
      @options[:plural_name].nil? ? "#{@name}s" : @options[:plural_name]
    end
  end
end
