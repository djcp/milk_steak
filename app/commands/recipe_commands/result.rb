module RecipeCommands
  Result = Data.define(:success, :message) do
    def flash_type = success ? :notice : :alert
  end
end
