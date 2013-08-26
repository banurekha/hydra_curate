module CurationConcern
  class GenericWorkActor < CurationConcern::BaseActor

    def create!
      super
      create_attached_file
      create_linked_resource
    end

    def update!
      super
      update_contained_generic_file_visibility
    end

    protected
    def attached_file
      @attached_file ||= attributes.delete(:thesis_file)
    end
    def linked_resource
      @linked_resource ||= attributes.delete(:linked_resource_url)
    end

    def create_linked_resource
      if linked_resource.present?
        resouce = LinkedResource.new.tap do |link|
          link.url = linked_resource
          link.batch = curation_concern
          link.label = curation_concern.human_readable_type
        end
        Sufia::GenericFile::Actions.create_metadata( resouce, user, curation_concern.pid)
      end
    end

    def create_attached_file
      if attached_file
        generic_file = GenericFile.new
        generic_file.file = attached_file
        generic_file.batch = curation_concern
        generic_file.label = curation_concern.human_readable_type
        Sufia::GenericFile::Actions.create_metadata(
          generic_file, user, curation_concern.pid
        )
        generic_file.set_visibility(visibility)
        CurationConcern.attach_file(generic_file, user, attached_file)
      end
    end

    def update_contained_generic_file_visibility
      if visibility_may_have_changed?
        curation_concern.generic_files.each do |f|
          f.set_visibility(visibility)
          f.save!
        end
      end
    end

  end
end