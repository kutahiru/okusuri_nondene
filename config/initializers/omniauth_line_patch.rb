# frozen_string_literal: true

# Patch for omniauth-line to support bot_prompt parameter
require 'omniauth/strategies/line'

module OmniAuth
  module Strategies
    class Line < OmniAuth::Strategies::OAuth2
      def authorize_params
        super.tap do |params|
          # Add bot_prompt parameter if specified in options
          params[:bot_prompt] = options[:bot_prompt] if options[:bot_prompt]
        end
      end
    end
  end
end