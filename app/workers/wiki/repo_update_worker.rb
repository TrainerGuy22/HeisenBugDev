class Wiki::RepoUpdateWorker
  include Sidekiq::Worker

  def perform(wiki_id)
    wiki = Wiki::Wiki.find(wiki_id)
    repo = wiki.repo
    tmp_dir = File.join(Rails.root, 'tmp', 'wikis')
    repo_tmp_dir = File.join(tmp_dir, repo)

    if File.directory?(repo_tmp_dir)
      Dir.chdir(repo_tmp_dir) do
        @old_commit = `git rev-parse HEAD`
        `git pull`
        @new_commit = `git rev-parse HEAD`
        commits = "#{@old_commit} #{@new_commit}"
        @files = `git diff --name-only #{commits}`.split("\n")
        del_file_command = "git diff --diff-filter=D --name-only #{commits}"
        @deleted_files = `#{del_file_command}`.split("\n")

        @files.delete_if do |file|
          if @deleted_files.include? file
            true
          else
            false
          end
        end
      end
    else
      FileUtils.mkpath(tmp_dir)
      Dir.chdir(tmp_dir) do
        `git clone https://github.com/#{repo}.git #{repo}`
      end
      @files = Dir["#{repo_tmp_dir}/**/*"]
    end

    start = File.join(repo_tmp_dir, 'projects', wiki.project.name)

    @files.each do |file|
      if file.start_with?(start) && File.file?(file)
        folder_search = file.sub(start, '')
        # Stuff like v12.3.0 or b233
        Wiki::ArticleUpdateWorker.perform_async(file, wiki_id, folder_search,
          false)
      end
    end
  end
end