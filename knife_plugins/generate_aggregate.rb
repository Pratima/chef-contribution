module KnifePlugins

  class HcahGenerateAggregate < Chef::Knife

    EXAMPLE_COMMAND = 'JENKINS_HOST=http://jenkins_url/ WORK_ROOT=/tmp knife generate aggregate --app1-build-no 70 --app2-build-no 52 --api-build-no 56'
    banner "knife generate aggregate"

    option :app1_build_no,
      :long => '--zpp1-build-no BUILD_NO',
      :description => 'App1 build number',
      :default => ""

    option :app2_build_no,
      :long => '--app2-no BUILD_NO',
      :description => 'App2 build number',
      :default => ""

    option :api_build_no,
      :long => '--api-build-no BUILD_NO',
      :description => 'Api build number',
      :default => ""

    APPS = [:app1, :app2, :api]
    AGGREGATE_NAME = 'aggregate'

    def run
      if valid_options and valid_env
        @jenkins_host = ENV['JENKINS_HOST']
        @work_root = ENV['WORK_ROOT']
        @work_dir = "#{@work_root}/#{AGGREGATE_NAME}"
        generate_aggregate
      else
        ui.fatal "Please provide application build numbers e.g. #{EXAMPLE_COMMAND}"
        exit 1
      end
    end

    private

    def generate_aggregate
      setup_aggregate_dir

      Dir.chdir(@work_dir) do
        create_manifest
        download_app_builds
        tar_aggregate
      end

      cleanup
    end

    def valid_options
      true if option_present(:app1_build_no) && option_present(:app2_build_no) && option_present(:api_build_no)
    end

    def option_present option
      !config[option].nil? && !config[option].strip.empty?
    end

    def valid_env
      true if (env_present('JENKINS_HOST') && env_present('WORK_ROOT'))
    end

    def env_present variable
      !ENV[variable].nil? && !ENV[variable].strip.empty?
    end

    def setup_aggregate_dir
      system "rm -f #{@work_root}/aggregate.tar.gz; rm -fr #{@work_dir}; mkdir #{@work_dir};"
    end

    def cleanup
      system "rm -fr #{@work_dir}"
    end

    def create_manifest
      manifest = <<-BUILD_MANIFEST
        App1 Build:   #{config[:app1_build_no]}
        App2 Build: #{config[:app2_build_no]}
        Api Build:  #{config[:api_build_no]}
      BUILD_MANIFEST

      cmd = "echo '#{manifest}' >> manifest.txt"
      system cmd
    end

    def download_app_builds
      APPS.each do |app_name|
        wget_artifact(app_name, "#{app_name}_generate_artifact", config["#{app_name}_build_no".to_sym])
        extract_artifact(app_name)
      end
    end

    def wget_artifact app_name, artifact_job_name, build_number
      system "wget #{@jenkins_host}/job/#{artifact_job_name}/#{build_number}/artifact/#{app_name}.tar.gz -O #{app_name}.tar.gz"
    end

    def extract_artifact app_name
      system "mkdir #{app_name}; tar -zxvf #{app_name}.tar.gz -C #{app_name}/; rm -fr #{app_name}.tar.gz;"
    end

    def tar_aggregate
      system "tar -czv -f #{@work_root}/aggregate.tar.gz ."
    end
  end
end

