require 'rubocop/rake_task'

describe "rubocop --format json", type: :task do

  it "runs rubocop" do
    # Print rubocop result to result.json (reason stated below)
    unless  ENV['APIPIE_RECORDS'].present?
      RuboCop::RakeTask.new(:rubocop) do |t|
        t.options = ['--format', 'json', '--out', 'result.json']
      end
      begin
        Rake::Task[:rubocop].invoke
      ensure
        # We need to ensure that parsing and asserting continues
        # When rubocop has violations it stops code execution on rake invoke
        result_parser
      end
    end
  end

  def result_parser
    result_file = File.open('result.json', "r")
    result = result_file.read
    result_file.close

    result = YAML.load(result)

    with_offense = false
    result['files'].each do |file|
      unless file['offenses'].empty?
        with_offense = true
        break
      end
    end

    expect(with_offense).not_to eq(true)

    File.delete('result.json')
  end
end
