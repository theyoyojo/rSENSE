class MediaObjectsController < ApplicationController
  include ApplicationHelper

  # Allow images to be shown without authentication
  skip_before_filter :authorize, :only => [:show]

  # GET /media_objects/1
  # GET /media_objects/1.json
  def show
    @media_object = MediaObject.find(params[:id])
    
    recur = params.key?(:recur) ? params[:recur] : false
    
    respond_to do |format|
      format.html
      format.json { render json: @media_object.to_hash(recur) }
    end
  end
  
  # PUT /media_objects/1
  # PUT /media_objects/1.json
  def update
    @media_object = MediaObject.find(params[:id])
    editUpdate = params[:media_object]
    success = false
    
    if can_edit? @media_object
      success = @media_object.update_attributes(editUpdate)
    end
    
    respond_to do |format|
      if success
        format.html { redirect_to @media_object, notice: 'Media Object was successfully updated.' }
        format.json { render json:{}, status: :ok }
      else
        format.html { redirect_to @media_object, alert: 'Media Object not successfully updated.' }
        format.json { render json: @media_object.errors.full_messages(), status: :unprocessable_entity }
      end
    end
  end

  # DELETE /media_objects/1
  # DELETE /media_objects/1.json
  def destroy
    @media_object = MediaObject.find(params[:id])
    
    if can_delete?(@media_object)
      
      if !@media_object.project_id.nil? && @media_object.project.featured_media_id == @media_object.id
        @media_object.project.featured_media_id = nil
        @media_object.project.save
      end
      
      @media_object.destroy

      respond_to do |format|
        format.html { redirect_to media_objects_url }
        format.json { render json: {}, status: :ok }
      end
    else
      respond_to do |format|
        format.html { redirect_to 'public/401.html' }
        format.json { render json: {}, status: :forbidden }
      end
    end
  end
  
  #POST /media_object/saveMedia
  def saveMedia
    
    #Figure out where we are uploading data to
    data = params[:keys].split('/')
    target = data[0]
    id = data[1]
    logger.info "TARGET = #{target} and ID = #{id}"
    #Set up the link to S3
    s3ConfigFile = YAML.load_file('config/aws_config.yml')
    
    s3 = AWS::S3.new(
      :access_key_id => s3ConfigFile['access_key_id'],
      :secret_access_key => s3ConfigFile['secret_access_key'])
    
    #Get our bucket
    bucket = s3.buckets['isenseimgs']

    #Set up the file for upload
    fileType = params[:upload].content_type.split("/")[0]
    filePath = params[:upload].tempfile 
    fileName = params[:upload].original_filename
    fileKey = SecureRandom.uuid() + "." + fileName
    while MediaObject.find_by_file_key(fileKey) != nil
      fileKey = SecureRandom.uuid() + "." + fileName
    end
    
    if fileType == 'application'
      extended = params[:upload].content_type.split("/")[1]
      if extended.include? 'pdf'
        fileType = 'pdf'
      else
        fileType = 'document'
      end
    end
    
    #Generate the key for our file in the bucket
    o = bucket.objects[fileKey]

    #Build media object params based on what we are doing
    case target
    when 'project'
      @project = Project.find_by_id(id)
      if(can_edit?(@project))
        @mo = {user_id: @project.owner.id, project_id: id, src: o.public_url.to_s, name: fileName, media_type: fileType, file_key: fileKey}
      end
    when 'data_set'
      @data_set = DataSet.find_by_id(id)
      if(can_edit?(@data_set))
        @mo = {user_id: @data_set.owner.id, project_id: @data_set.project_id, data_set_id: @data_set.id, src: o.public_url.to_s, name: fileName, media_type: fileType, file_key: fileKey}
      end
    when 'user'
      @user = User.find_by_username(id)
      if(can_edit?(@user))
        @mo = {user_id: @user.id, src: o.public_url.to_s, name: fileName, media_type: fileType, file_key: fileKey}
      end
    when 'tutorial'
      @tutorial = Tutorial.find_by_id(id)
      if(can_edit?(@tutorial))
        @mo = {user_id: @tutorial.owner.id, src: o.public_url.to_s, name: fileName, media_type: fileType, tutorial_id: @tutorial.id, file_key: fileKey}
      end
    when 'visualization'
      @visualization = Visualization.find_by_id(id)
      if(can_edit?(@visualization))
        @mo = {user_id: @visualization.owner.id, src: o.public_url.to_s, name: fileName, media_type: fileType, visualization_id: @visualization.id, file_key: fileKey}
      end
    when 'news'
      @news = News.find_by_id(id)
      if(can_edit?(@news))
        @mo = {user_id: @news.owner.id, src: o.public_url.to_s, name: fileName, media_type: fileType, news_id: @news.id, file_key: fileKey}
      end
        
    end

    #If we managed to make some params build the media object and write to S3
    if(defined? @mo)      
    
      #Write the file to S3
      o.write(file: filePath, :content_disposition => "attachment;filename=#{fileName}")

      #Generate a media object with the calculated params
      mo = MediaObject.create(@mo)
      mo.add_tn
      @mo = mo
      
      if params.has_key?(:non_wys)
        respond_to do |format|
          format.html {redirect_to params[:non_wys]}
        end
      end
      
    else
      #Tell the user there is a problem with uploading their image.
      render json: {filelink: '/assets/noimage.png'}
      
    end
  end
end
