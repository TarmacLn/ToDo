namespace :docs do
  desc "Generate swagger/v1/swagger.yaml from the specs in spec/integration"
  task :generate do
    # Run the doc specs for real (not a dry run) so the docs get real response
    # examples, in this order so the endpoints appear in a logical order
    specs = %w[authentication todos items].map { |name| "spec/integration/#{name}_spec.rb" }
    sh "bundle exec rspec #{specs.join(' ')} --order defined " \
       "--format Rswag::Specs::SwaggerFormatter --format progress"
  end
end
