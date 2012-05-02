class ReUseCaseController < RedmineReController
  unloadable
  menu_item :re

  # The new and edit functions will be called via the RedmineReController.
  # Both methods are pretty much equal for every artifact type (goal, scenario
  # etc. ).
  #
  # If your artifact type needs special treatment uncommenct the following
  # hook method(s).
  # You find an example of how to use these hooks in the ReTaskController
  
  def new_hook(params)
    @artifact.goal_level=3
    # Initialize user_profiles for use_case artifact
    @user_profiles = []
    @user_profiles = "re_user_profile".camelcase.constantize.all
    @user_profiles.each { |user_profile| user_profile.re_artifact_properties }
  end

  def edit_hook_after_artifact_initialized(params)
    
    # Initialize user_profiles for use_case artifact
    @user_profiles = []
    @user_profiles = "re_user_profile".camelcase.constantize.all
    @user_profiles.each { |user_profile| user_profile.re_artifact_properties }
  
  end

  #def edit_hook_validate_before_save(params, artifact_valid)
    # must return true, if the validation passed or false if invalid 
    # you should also attach your errors to the @artifact variable

  #  return true
  #end

  def edit_hook_valid_artifact_after_save params
    unless @artifact.re_use_case_steps.empty?
      @artifact.reload.re_use_case_steps
      flash.now[:notice] = t(:re_use_case_and_steps_saved)
    end

      current_relation = ReArtifactRelationship.find_by_source_id_and_relation_type(@artifact.artifact_properties.id, ReArtifactRelationship::RELATION_TYPES[:pof])
      
    if current_relation.blank?
      if ( !params[:primary_user_profile].blank? )
        @new_relation = ReArtifactRelationship.new(:source_id => @artifact.artifact_properties.id, :sink_id => params[:primary_user_profile], :relation_type => ReArtifactRelationship::RELATION_TYPES[:pof])
        @new_relation.save
      end
    else
      current_relation.sink_id = params[:primary_user_profile]
      current_relation.save
    end

    
    unless params[:secondary_user_profile_id].blank?
      logger.debug("///////////////////////////////////////:)")
      logger.debug(params.to_yaml)
      params[:secondary_user_profile_id].each do |iid|
        #tmp = ReArtifactProperties.find(iid)
        @new_relation = ReArtifactRelationship.new(:source_id => @artifact.artifact_properties.id, :sink_id => iid, :relation_type => ReArtifactRelationship::RELATION_TYPES[:dep])
        @new_relation.save
        #@artifact_properties.user_profiles << ReUserProfile.find(tmp.artifact_id)
      end
    end
    @current_primary_user = ReArtifactRelationship.find_by_source_id_and_relation_type(@artifact.artifact_properties.id, ReArtifactRelationship::RELATION_TYPES[:pof])
    
  end

  #def edit_hook_invalid_artifact_cleanup(params)
  #end
  
  def prepare_secondary_actor params
    logger.debug("/////////// SECONDARY USER PREPARED ///////////")
    logger.debug(params.to_yaml)
  end

  def autocomplete_sink
    
    @artifact = ReArtifactProperties.find(params[:id]) unless params[:id].blank?

    query = '%' + params[:user_profile_subject].gsub('%', '\%').gsub('_', '\_').downcase + '%'
    @sinks = ReArtifactProperties.find(:all, :conditions => ['lower(name) like ? AND project_id = ? AND artifact_type = ?', query.downcase, @project.id, "ReUserProfile"])

    if @artifact
      @sinks.delete_if{ |p| p == @artifact }
    end

    list = '<ul>'
    for sink in @sinks
      list << render_autocomplete_artifact_list_entry(sink)
    end
    list << '</ul>'
    render :text => list
  end

end