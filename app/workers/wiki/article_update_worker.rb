require 'fileutils'

class Wiki::ArticleUpdateWorker
  include Sidekiq::Worker

  def perform(file, wiki_id, stripped_file, delete = false)
    file_data = File.read(file) unless delete
    wiki = Wiki::Wiki.find(wiki_id)

    base_file = stripped_file.reverse.split('/')[0].reverse
    folders = stripped_file.sub(base_file, '').sub('/','').split('/')

    title = base_file
    base_file.scan(/(\.\w*)/).each do |match|
      title.sub!(match[0], '')
    end

    if folders[0].nil?
      sliced_folder = ''
    else
      sliced_folder = folders[0].dup || ''
      sliced_folder.slice!(0)
    end

    if !folders[0].nil? && folders[0].match(/^(v|b).*/)
      cat_folders = folders.drop(1)
    else
      cat_folders = folders
    end

    category ||= nil
    cat_folders.each do |folder|
      if category then cat_id = category.id else cat_id = nil end
      category = Wiki::Category.find_or_initialize_by(:parent_id => cat_id,
        :title => folder, :wiki_id => wiki.id)
      category.save
    end

    if category then cat_id = category.id else cat_id = nil end

    case folders[0]
    when /^v.*/
      version = wiki.project.versions.find_by_version(sliced_folder)

      return if version.nil?
      if delete
        wiki.articles.find_by_version_id_and_title(version.id, title).destroy
      else
        article = wiki.articles.find_or_initialize_by(:version => version,
          :title => title, :category_id => cat_id)

        article.update_attributes(:body => file_data.to_s)
        article.save
      end
    when /^b.*/
      build = wiki.project.builds.find_by_build_number(sliced_folder)

      return if build.nil?
      if delete
        wiki.articles.find_by_build_id_and_title(build.id, title).destroy
      else
        article = wiki.articles.find_or_initialize_by(:build => build,
          :title => title, :category_id => cat_id)
        article.update_attributes(:body => file_data.to_s)
        article.save
      end
    else
      if delete
        wiki.articles
          .find_by_title_and_build_id_and_version_id(title, nil, nil).destroy
      else
        article = wiki.articles.find_or_initialize_by(:title => title,
          :build_id => nil, :version_id => nil, :category_id => cat_id)
        article.update_attributes(:body => file_data.to_s)
        article.save
      end
    end
  end
end
