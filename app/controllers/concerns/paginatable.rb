# Centralises pagination parameter clamping, which three controllers each
# hand-rolled with slightly different maximums.
#
# The clamps are not cosmetic: an unbounded per_page lets one request ask the
# database and the renderer for the entire table, so every caller must pass a
# maximum rather than inheriting a permissive default.
module Paginatable
  extend ActiveSupport::Concern

  private

  def page_param
    [1, params.fetch(:page, 1).to_i].max
  end

  def per_page_param(default:, max:)
    params.fetch(:per_page, default).to_i.clamp(1, max)
  end
end
