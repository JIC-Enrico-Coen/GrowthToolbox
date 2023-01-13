function [m,ok,img,imgfilename] = leaf_snapshot( m, varargin )
%[m,ok] = leaf_snapshot( m, filename, ... )
%[m,ok,img,imgname] = leaf_snapshot( m, filename, ... )
% Take a snapshot of the current view of the leaf.
% The image will be saved to the specified filename, and if the IMG output
% argument is requested, it will be returned as an M*N*3 array of RGB
% values.  If the filename is the empty string, then a name for the image
% file will be automatically generated.  If the filename is '-' then no
% file is generated.  The name is returned in the imgname output.
%
% If the snapshot cannot be taken or the arguments are invalid then
% ok will be returned as false.
%
%   Arguments:
%       1: The name of the file to write.  The extension of
%          the filename specifies the image format.  Acceptable formats
%          include 'png', 'jpg', 'tif'.  Others may be accepted depending
%          on the version of Matlab and whether a hi-res image is being
%          made.  If you want to let the filename be chosen automatically,
%          pass the empty string.  In this case, if there are no following
%          options, the filename can be omitted.  The image will be
%          saved in the 'snapshots' folder of the current project folder,
%          if any, otherwise the current folder.  You can override this by
%          specifying an absolute path.  If no file is to be saved, pass
%          '-' as the file name.
%
%   Options:
%       'newfile': if true (the default), the file name given will be
%           modified so as to guarantee that it will not overwrite any
%           existing file. If false, the filename will be used as given and
%           any existing file will be overwritten without warning.
%       'thumbnail': if true (the default is false), the other arguments
%           and options will be ignored (the filename must be given as the
%           empty string), and a snapshot will be saved to the file
%           thumbnail.png in the project directory.
%       'hires': If true, make a hi-res image.  If false, don't. If
%           unspecified use the value of m.plotdefaults.hiressnaps.
%       'magnification': Make a hi-res image using this magnification
%           value.
%       'antialias': If true, make a hi-res image using this
%           antialiasing value.
%       'includeIF': If true (the default) a copy of the interaction
%           function will be saved alongside the snapshot, with the same
%           name and .txt extension.
%
%   For hi-res pictures, these are the only relevant options.  For
%   screen-image pictures, further options may be given and will be passed
%   to IMWRITE, the Matlab function that will create the image file.  If
%   any options are provided, the filename must be present
%
% Whether a hi-res image is to be produced is determined by the following rules:
% * Thumbnails are never hi-res, regardless of all other options.
% * Otherwise, if the 'hires' option is present, whether true or false,
%       that determines whether the snapshot is to be hires.
% * Otherwise, if either of the 'magnification' or 'antialias' options is
%       present, the snapshot will be hires.
% * Otherwise, m.plotdefaults.hiressnaps determines whether it is hires.

% For hi-res snapshots, 'magnification' sets the magnification,
% which if absent defaults to m.plotdefaults.hiresmagnification.
% Similarly for antialias, which defaults to
% m.plotdefaults.hiresantialias.
%
%   Examples:
%       m = leaf_snapshot( m, 'foo.png' );
%       m = leaf_snapshot( m, 'foo.png', 'magnification', 3, 'antialias', true );
%       m = leaf_snapshot( m, 'foo.png', 'magnification', 1, 'antialias', false );
%   The first will give a hi-res snapshot if m.plotdefaults.hiressnaps is
%   true.  The second always gives a hi-res snapshot, with a magnification
%   of 3 and antialiasing.  The third gives a hi-res snapshot with
%   magnification 1 and no antialiasing.  This is likely to be identical to
%   a low-res snapshot, but as hi-res and low-res snapshots are created by
%   different Matlab functions, it is possible that the images they create
%   may also be different in one way or another.
%
%   Equivalent GUI operation: clicking the "Take snapshot" button.  This
%   saves an image in PNG format into a file with an automatically
%   generated name.  A report is written to the Matlab command window.
%   The 'thumbnail' option is equivalent to the "Make Thumbnail" menu
%   command.
%
%   If stereo mode is turned on, snapshots will be stereo, with the two
%   images arranged according to the stereo parameters.
%
%   See also:
%       IMWRITE, PRINT
%
%   Topics: Movies/Images.

    img = [];
    imgfilename = [];

    [ok,handles,m,savedstate] = prepareForGUIInteraction( m, true );
    if ~ok, return; end
    [ok, imgfilename, args] = getTypedArg( mfilename(), 'char', varargin, '' );
    if ~ok, return; end
    [s,ok] = safemakestruct( mfilename(), args );
    if ~ok, return; end
    includeIF = isfield( s, 'includeIF' ) && s.includeIF;
    
    if isempty( m.pictures )
        complain( '%s: There is no picture to take a snapshot of.', mfilename() );
        ok = false;
        return;
    end
    
    thumbnail = isfield(s,'thumbnail') && s.thumbnail;
    wantfile = thumbnail || ~strcmp( imgfilename, '-' );
    newfile = wantfile && ~thumbnail && ((~isfield(s,'newfile')) || s.newfile);
    s = safermfield( s, 'newfile', 'thumbnail' );
    
    
    turnplottingon = (~m.plotdefaults.enableplot) && m.plotdefaults.allowsnaps;
    if turnplottingon
        m = leaf_plot( m, 'enableplot', true );
    end
    
    % Determine whether we are to take a hi-res snapshot.
    hires = [];
    if thumbnail
        hires = false;
    else
        if isfield( s, 'magnification' ) && ~isempty(s.magnification)
            magnification = s.magnification;
            hires = true;
        elseif isfield( s, 'resolution' ) && ~isempty(s.resolution)
            magnification = s.resolution/72;
            hires = true;
        else
            magnification = m.plotdefaults.hiresmagnification;
        end
        if isfield( s, 'antialias' ) && ~isempty(s.antialias)
            antialias = s.antialias;
            hires = true;
        else
            antialias = m.plotdefaults.hiresantialias;
        end
        % If 'hires' is explicitly specified, whether true or false, that
        % trumps magnification and alias.
        if isfield( s, 'hires' ) && ~isempty(s.hires)
            hires = s.hires;
        elseif isempty(hires)
            hires = m.plotdefaults.hiressnaps;
        end
    end
        
    framecount = m.globalDynamicProps.currentIter;
    if wantfile
        if isempty(imgfilename)
%             if isempty(m.globalProps.modelname)
%                 snapshotname = 'snapshot';
%             else
%                 snapshotname = m.globalProps.modelname;
%             end
%             if thumbnail
%                 imgfilename = 'GPT_thumbnail.png';
%             else
%                 imgfilename = sprintf( '%s-%s-00.png', ...
%                     snapshotname, stageTimeToText( m.globalDynamicProps.currenttime ) );
%             end
            imgfilename = snapshotName( m, [], thumbnail );
        else
            [~,~,ext] = fileparts( imgfilename );
            if isempty(ext)
                imgfilename = [ imgfilename, '.png' ];
            end
        end
    end
    h = guidata( m.pictures(1) );

    if thumbnail
        % Thumbnails are a special case.
        
        % 1.  Hide the clutter (scalebar, legend).
        % 2.  Take a standard-resolution picture, ignoring all hi-res parameters.
        % 3.  Restore the clutter.
        scalebarVis = strcmp( get( h.scalebar, 'Visible' ), 'on' );
        legendVis = strcmp( get( h.legend, 'Visible' ), 'on' );
        pictureVis = strcmp( get( h.picture, 'Visible' ), 'on' );
        if scalebarVis
            set( h.scalebar, 'Visible', 'off' );
        end
        if legendVis
            set( h.legend, 'Visible', 'off' );
        end
        if pictureVis
            set( h.picture, 'Visible', 'off' );  % WHY?
        end
        drawnow;
        
        frame = getGFtboxImage(m);
        
        if scalebarVis
            set( h.scalebar, 'Visible', 'on' );
        end
        if legendVis
            set( h.legend, 'Visible', 'on' );
        end
        if pictureVis
            set( h.picture, 'Visible', 'on' );
        end
        
        frame = trimimageborders( frame );
    end
    
    

    if ~thumbnail
        frame = getGFtboxImage( m, m.pictures(1), m.plotdefaults.drawcolorbar, hires, magnification, antialias );
        if ~isempty( frame )
            framesize = size(frame);
            for i=2:length(m.pictures)
                nextframe = getGFtboxImage( m, m.pictures(i), m.plotdefaults.drawcolorbar, hires, magnification, antialias );
                frame( :, (framesize(2)*i+1):(framesize(2)*(i+1)), : ) = ...
                    trimframe( nextframe, framesize([1 2]), m.plotdefaults.bgcolor );
            end
        end
    end
    if isempty( frame )
        % A warning has been written to the console by getGFtboxImage().
        ok = false;
        if turnplottingon
            m = leaf_plot( m, 'enableplot', false );
        end
        return;
    end
    if thumbnail
        olddir = goToProjectDir( m, '' );
        imtype = 'thumbnail';
    else
        olddir = goToProjectDir( m, 'snapshots' );
        imtype = 'snapshot';
    end
    if wantfile && newfile
        imgfilename = newfilename( imgfilename );
        timedFprintf( 1, 'Saving %s of frame %d to %s in %s.\n', ...
            imtype, framecount, imgfilename, pwd );
    end
    s = safermfield( s, 'hires', 'thumbnail', 'newfile', 'magnification', 'antialias', 'includeIF' );
    if wantfile
        imwriteargs = struct2args(s);
        imwrite( frame, imgfilename, imwriteargs{:} );
    end
    if nargout >= 3
        img = frame;
    end
    if isfield(m,'monitor_figs') %if ishandle(1)
        current_figure=gcf;
        m.monitor_figs = m.monitor_figs( ishandle( m.monitor_figs ) );
        for k=1:length(m.monitor_figs)
            figurestr=['-f',num2str(m.monitor_figs(k))];
            print(figurestr,'-dpng',[imgfilename(1:end-4),'_mon',num2str(m.monitor_figs(k)),'.png']);
            timedFprintf(1,'Saving monitor Figure %d\n',m.monitor_figs(k));
        end
        figure(current_figure);
    end

    if olddir, cd( olddir ); end

    % Copy the interaction file to a text file with associated name
    if includeIF && ~thumbnail && ~isempty( m.globalProps.projectdir )
        olddir = goToProjectDir( m, '' );
        interaction_filename = [m.globalProps.modelname,'.m'];
        % Might have to change underscores into hyphens
        if exist(interaction_filename,'file') ~= 2
            % try hyphens
            ind=strfind(interaction_filename,'_');
            interaction_filename(ind)='-';
        end
        if isabsolutepath(imgfilename)
            [imgpath,imgbasename,~] = fileparts( imgfilename );
            targetname = fullfile(imgpath,[imgbasename,'.txt']);
        else
            targetname = fullfile('snapshots',[imgfilename(1:end-4),'.txt']);
        end
        if exist(interaction_filename,'file')==2
            [success,msg,~] = copyfile(interaction_filename,targetname,'f');
            if success
                timedFprintf(1,'Copied %s to %s\n',interaction_filename,targetname);
            else
                timedFprintf(1,'Failed to copy %s to %s\n    %s\n',interaction_filename,targetname,msg);
            end
        end
        if olddir, cd( olddir ); end
    end
    
    if turnplottingon
        m = leaf_plot( m, 'enableplot', false );
    end
    
    m = concludeGUIInteraction( handles, m, savedstate );
end
