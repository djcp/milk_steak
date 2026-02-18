Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self
    policy.font_src    :self, 'https://fonts.gstatic.com', 'https://fonts.googleapis.com'
    policy.img_src     :self, :data, :https
    policy.object_src  :none
    policy.script_src  :self, :unsafe_inline, 'https://www.google-analytics.com'
    policy.style_src   :self, :unsafe_inline, 'https://fonts.googleapis.com'
    policy.connect_src :self
    policy.frame_ancestors :self
    policy.base_uri :self
  end
end
