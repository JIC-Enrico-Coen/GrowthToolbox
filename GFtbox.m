function varargout = GFtbox(varargin)
% GFTBOX M-file for GFtbox.fig
%      GFTBOX() creates a new GFTBOX or brings the existing
%      GFtbox window to the front.
%
%      H = GFTBOX() returns the handle to the resulting window.
%
%      GFTBOX('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GFTBOX.M with the given input arguments.
%
%      GFTBOX('Property','Value',...) creates a new GFTBOX or raises the
%      existing singleton.  Starting from the left, property value pairs are
%      applied to the GUI before GFtbox_OpeningFunction is called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GFtbox_OpeningFcn.
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Last Modified by GUIDE v2.5 10-May-2022 14:12:07

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GFtbox_OpeningFcn, ...
                   'gui_OutputFcn',  @GFtbox_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);

if nargin==1
    % The single argument is expected to be a file name.
    % The following will have the effect of inserting it into the UserData
    % field of the GUI window, from where it will be retrieved by
    % GFtbox_OpeningFcn, which will then load a mesh from the file.
    varargin = { 'UserData', varargin{1} };
end

if (nargin > 0) && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
%     gui_State.gui_Callback
end

% varargin{:}

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


function InitialiseCommandPath()
    whereami = fileparts(mfilename('fullpath'));
    olddir = pwd;
    try
        cd(whereami);
        didcd = true;
    catch
        didcd = false;
    end
    InitGFtboxPath();
    if didcd
        try
            cd(olddir);
        catch
        end
    end


% --- Executes just before GFtbox is made visible.
function GFtbox_OpeningFcn(hObject, ~, handles, ~)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GFtbox (see VARARGIN)

    seednumber = sum(10000*clock());
    rng(seednumber,'twister');
    rngstate = rng();
    fprintf( 2, 'Random seed = %d\n', rngstate.Seed );
    
% Test to see if GFtbox has already been initialised, by looking for one of
% the dynamically created Help menus.
pc = get( handles.projectsMenu, 'Children' );
if strcmp( get( pc(1), 'Label' ), 'Help' )
    % Already made the help menus.
    return;
end

% Set the GFtbox command path.
    InitialiseCommandPath();

global EXTERNMESH GFtboxFigure GFTboxConfig
global gGlobalProps gDefaultPlotOptions
GFtboxFigure = hObject;

EXTERNMESH = [];

initialiseGFtboxGuiTypes( handles );

useAllProcessors( mfilename() );  % Obsolete?

deleteUntitledProject();

resetGlobals();

% Choose default command line output for GFtbox
handles.output = hObject;
set( handles.output, 'InvertHardcopy', 'off' )

GFTboxConfig = readGFtboxConfig();
handles = updateGUIfromConfig( handles );
loadUIControlImages( handles.mouseClickIconButton, handles.codedirectory, 'clickicon' );
loadUIControlImages( handles.mouseBoxIconButton, handles.codedirectory, 'boxicon' );
loadUIControlImages( handles.mouseBrushIconButton, handles.codedirectory, 'brushicon' );
loadUIControlImages( handles.mouseClickVertexButton, handles.codedirectory, 'vertexicon' );
loadUIControlImages( handles.mouseClickEdgeButton, handles.codedirectory, 'edgeicon' );
loadUIControlImages( handles.mouseClickFaceButton, handles.codedirectory, 'faceicon' );
handles.dlgchanges = struct([]);
handles.processdlgqueue = @processDlgQueue;
handles.mesh = [];
handles.boingNeeded = 0;
handles = clearImageData( handles );

stdmargin = 6;
mainpanelpos = get( handles.mainpanel, 'Position' );
handles.interfacestate.initmainpanelposition = mainpanelpos;
handles.interfacestate.margin = handles.interfacestate.initmainpanelposition(1);
handles = setFixedMode( handles );

toolSelectPos = get( handles.toolSelect, 'Position' );
set( handles.toolSelect, 'SelectionChangeFcn', @toolSelect_SelectionChangeFcn );
set( handles.splitMgenButtonGroup, 'SelectionChangeFcn', @splitMgenButtonGroup_SelectionChangeFcn );
set( handles.bioAsplitTypeSelect, 'SelectionChangeFcn', @bioAsplitTypeSelect_SelectionChangeFcn );
% set( handles.output, 'KeyPressFcn', @GFTwindow_KeyPressFcn );
set( handles.singlestep, 'ButtonDownFcn', @singlestep_Callback );
set( handles.thicknessRadioGroup, 'SelectionChangeFcn', @thicknessRB_Callback );
axis( handles.picture, 'equal' );
set( handles.picture, 'CameraViewAngle', 9 );
set( handles.picture, 'CameraViewAngleMode', 'manual' );
resetView( handles.picture );
setCamlight( handles.picture, [], [], ...
    strcmp( get( handles.lightMenuItem, 'Label' ), 'Turn Light Off' ) );
drawThumbnail( handles );
set( handles.picture, 'ButtonDownFcn', @GFtboxGraphicClickHandler, 'Visible', 'off' );
setPictureColorContrast( handles, gDefaultPlotOptions.bgcolor );
set( handles.pictureBackground, 'XTick', [], 'XTickMode', 'manual', ...
                                'XTickLabel', [], 'XTickLabelMode', 'manual' );
set( handles.pictureBackground, 'YTick', [], 'YTickMode', 'manual', ...
                                'YTickLabel', [], 'YTickLabelMode', 'manual' );
set( handles.pictureBackground, 'ZTick', [], 'ZTickMode', 'manual', ...
                                'ZTickLabel', [], 'ZTickLabelMode', 'manual' );
set( handles.pictureBackground, 'Visible', 'on' );
uistack( handles.pictureBackground, 'bottom' );
set( get( handles.picture, 'XLabel' ), 'FontSize', handles.fontdetails.FontSize );
set( get( handles.picture, 'YLabel' ), 'FontSize', handles.fontdetails.FontSize );
set( get( handles.picture, 'ZLabel' ), 'FontSize', handles.fontdetails.FontSize );
addUserData( handles.opacityItem, 'currentvalue', gDefaultPlotOptions.alpha );
addUserData( handles.lineSmoothingItem, 'currentvalue', gDefaultPlotOptions.linesmoothing );
addUserData( handles.ambientItem, 'currentvalue', gDefaultPlotOptions.ambientstrength );
% set( handles.opacityItem, ...
%      'UserData', struct( 'currentvalue', gDefaultPlotOptions.alpha )  );
% set( handles.lineSmoothingItem, ...
%      'UserData', struct( 'currentvalue', gDefaultPlotOptions.linesmoothing )  );
% set( handles.ambientItem, ...
%      'UserData', struct( 'currentvalue', gDefaultPlotOptions.ambientstrength )  );
manageMutantControls( handles );
set( handles.colortexthi, 'String', '', 'Visible', 'on' );
set( handles.colortextlo, 'String', '', 'Visible', 'on' );
set( handles.colortitle, 'String', '', 'Visible', 'on' );

addUserData( handles.output, 'floatingpanels', struct() );
% set( handles.output, 'Userdata', struct( 'floatingpanels', struct() ) );

handles.panels.editor = 1;
handles.panels.morphdist = 1;
handles.panels.growthtensors = 1;
handles.panels.runsim = 1;
handles.panels.bio1 = 1;
handles.panels.vvlayer = 1;
panelnames = fieldnames(handles.panels);
for i=1:length(panelnames)
    pname = strcat( panelnames{i}, 'panel' );
    set( handles.(pname), 'Parent', handles.mainpanel );
    pos = get( handles.(pname), 'Position' );
    newpos = [ stdmargin, toolSelectPos(2) - pos(4) - stdmargin, pos(3:4) ];
    set( handles.(pname), 'Position', newpos );
end
set( handles.picturepanel, 'BorderWidth', 0, 'BorderType', 'none' );
set( handles.scalebar, 'Parent', handles.picturepanel );
makeDraggable( handles.scalebar, 1, 0 );
makeDraggable( handles.legend, 1, 0 );
handles.guicolors.greenBack = [0.4 0.8 0.4];
handles.guicolors.greenFore = [0.9 1 0.9];
handles.guicolors.yellowBack = [0.8 0.8 0.2];
handles.guicolors.yellowFore = handles.guicolors.greenFore;
setGFtboxColourScheme( handles.output, handles );
handles.guicolors.mainokcolor = get( handles.mainpanel, 'BackgroundColor' );
handles.guicolors.mainbadcolor = [0.65 0.65 0.2];

% The following setting of panel properties should be done in GUIDE, but
% GUIDE is running really slowly on Mac OS.
set( handles.cellColorIndicator1, 'BorderType', 'line','BackgroundColor',[0.1 1 0.1], 'HighlightColor', [0 0 0]);
set( handles.cellColorIndicator2, 'BorderType', 'line','BackgroundColor',[1 0.1 0.1], 'HighlightColor', [0 0 0]);
set( handles.mgenColorChooser, 'BorderType', 'line','BackgroundColor',[1 0 0], 'HighlightColor', [0 0 0], ...
    'ButtonDownFcn', 'mgenColorPick( gcbo, ''Cell color'', true )' );
set( handles.mgenNegColorChooser, 'BorderType', 'line','BackgroundColor',[0 0 1], 'HighlightColor', [0 0 0], ...
    'ButtonDownFcn', 'mgenColorPick( gcbo, ''Negative cell color'', false )' );
set( handles.mgenNegColorChooser, 'BorderType', 'line','BackgroundColor',[1 0 0], 'HighlightColor', [0 0 0]);
set( handles.rollzeroControl, 'BorderType', 'line','BackgroundColor',[1 1 1], 'HighlightColor', [0 0 0]);
set( handles.resetViewControl, 'BorderType', 'line','BackgroundColor',[1 1 1], 'HighlightColor', [0 0 0]);

setPlotBackground( handles, [1 1 1] );

ic = get( handles.interactionPanel, 'Children' );
for i=1:length(ic)
    saveColor( ic(i) );
end
enableInteractionFunction( handles, ischeckedMenuItem( handles.enabledisableIFitem ) )

rc = get( handles.runPanel, 'BackgroundColor' );
handles.runColors.okColor = rc;
wc = [ (rc(1)+rc(2))/2*ones(1,2), rc(3) ];
wch = rgb2hsv(wc);
moresat = 1.5;
moreval = 1.5;
wc = hsv2rgb( [wch(1), (moresat-1+wch(2))/moresat, (moreval-1+wch(3))/moreval] );
handles.runColors.warningColor = wc;
r = rc(1);
r = (1+r)/2;
handles.runColors.runningColor = [ r, rc( [3 1] )*0.7 ];
handles.runColors.readyColor = handles.runColors.okColor;

setGFtboxBusy( handles, false );
set( handles.busyPanel, 'BackgroundColor', handles.runColors.runningColor );
c = get( handles.busyPanel, 'Children' );
set(c,'BackgroundColor',handles.runColors.runningColor);
set(c,'ForegroundColor',[1 1 1]);

selectCurrentTool( handles );
movegui(hObject, 'center');
windowPos = get(hObject,'Position');
ss = get(0,'screensize');
preferredSize = floor(max( ss([3 4])*0.7, [1024,768] - [10,20] ));
d1 = round( (windowPos([3 4]) - preferredSize)/2 );
windowpos = [(windowPos([1 2]) + d1), preferredSize ];
set(hObject,'Position',windowpos);
movegui(hObject, 'onscreen');

set( handles.commandFlag, 'UserData', struct([]) );
set( handles.numsaddle, 'UserData', 'Saddle Z' );
set( handles.geomparam12, 'UserData', 'Rings' );
set( handles.geomparam21, 'UserData', 'X width' );
set( handles.geomparam31, 'UserData', 'Y width' );
set( handles.poissonsRatio, 'UserData', 'Poisson''s ratio' );

connectTextAndSlider( ...
    handles.rotatetext, handles.rotateslider, 'rotate', @emptyCallback, false );
connectTextAndSlider( ...
    handles.freezetext, handles.freezeslider, 'freezing', @meshTextSliderCallback, false );
connectTextAndSlider( ...
    handles.mutanttext, handles.mutantslider, 'mutant', @mutantValueCallback, true );
connectTextAndSlider( ...
    handles.paintamount, handles.paintslider, '', [], true );
connectTextAndSlider( ...
    handles.shockAtext, handles.shockAslider, '', [], false );
connectTextAndSlider( ...
    handles.vvmgenamount, handles.vvmgenslider, '', '', false );
global MESH_MENUNAMES;
set( handles.generatetype, 'String', MESH_MENUNAMES );
generatetype_Callback(handles.generatetype, [], handles);
mouseeditmodeMenu_Callback(handles.mouseeditmodeMenu, [], handles);
normTolMethod = strcmp( gGlobalProps.solvertolerancemethod, 'norm' );
checkErrorItems( handles, normTolMethod )

set( handles.colorbar, 'Visible', 'on' );
axis( handles.colorbar, 'off' );
fillAxes( handles.colorbar, [1 1 1] );

addUserData( handles.picture, 'mousemode', 'off' );
handles = setViewControlMode( handles, 'rotupright', 1 );

makeHelpMenu( handles ); % Must precede installTooltips().
handles = makeStageMenu( handles );
guidata( handles.output, handles );
installTooltips( handles );
addHelpMenuHelp( handles );
getHelpText( handles.help );

GFTwindow_ResizeFcn(handles.output, [], handles);
handles = guidata( handles.output );

handles.dragViewEnd_Callback = @dragViewEnd_Callback;
handles.fps = 10;
% set( handles.fpsText, 'String', sprintf( '%d', handles.fps ) );
handles.quality = 75;
set( hObject, 'CloseRequestFcn', 'GFtboxCloseRequestFcn' );
guidata(hObject, handles);

% GFtboxUserData = get( hObject, 'UserData' );


function img = getUIControlImage( imgpath )
    try
        img = imread( imgpath );
        if size(img,3)==1
            img = repmat( img, 1, 1, 3 );
        end
        if isa( img,'uint8' )
            img = double(img)/255.0;
        end
    catch e %#ok<NASGU>
        fprintf( 1, 'Icon file %s not found.\n', imgpath );
        img = [];
    end


function loadUIControlImages( h, maindir, imfile )
%     ud = get( h, 'Userdata' );
%     ud.img_on = getUIControlImage( fullfile( maindir, 'Icons', [imfile, '-on.png'] ) );
%     ud.img_off = getUIControlImage( fullfile( maindir, 'Icons', [imfile, '-off.png'] ) );
%     set( h, 'Userdata', ud );
    addUserData( h, ...
        'img_on', getUIControlImage( fullfile( maindir, 'Icons', [imfile, '-on.png'] ) ), ...
        'img_off', getUIControlImage( fullfile( maindir, 'Icons', [imfile, '-off.png'] ) ) );
    setImageBackgroundOnUIControl( h );
    

function setImageBackgroundOnUIControl( h )
    ud = get( h, 'Userdata' );
    if isempty( ud ) || ~isfield( ud, 'img_on' )
        return;
    end
    value = getUIFlag( h );
    if value
        set( h, 'CData', ud.img_on );
    else
        set( h, 'CData', ud.img_off );
    end

function handles = makeStageMenu( handles )
    handles.recomputeStagesItem = uimenu( handles.stagesMenu, ...
        'Tag', 'recomputeStagesItem', ...
        'Label', 'Recompute Stages', ...
        'Callback', @recomputeStagesItem_Callback );
    handles.moreStagesItem = uimenu( handles.stagesMenu, ...
        'Tag', 'moreStagesItem', ...
        'Label', 'Compute More Stages...', ...
        'Callback', @moreStagesItem_Callback );
    handles.requestStagesItem = uimenu( handles.stagesMenu, ...
        'Tag', 'requestStagesItem', ...
        'Label', 'Request More Stages...', ...
        'Callback', @requestStagesItem_Callback );
    handles.importRemoteStagesItem = uimenu( handles.stagesMenu, ...
        'Tag', 'importRemoteStagesItem', ...
        'Label', 'Import Experiment Stages...', ...
        'Callback', @importRemoteStagesItem_Callback );
    handles.saveExperimentStagesItem = uimenu( handles.stagesMenu, ...
        'Tag', 'saveExperimentStagesItem', ...
        'Label', 'Save Experiment Stages...', ...
        'Callback', @saveExperimentStagesItem_Callback );
    handles.recordAllStagesItem = uimenu( handles.stagesMenu, ...
        'Tag', 'recordAllStagesItem', ...
        'Label', 'Record All Stages', ...
        'Callback', @recordAllStagesItem_Callback );
    handles.deleteUnusedStagesItem = uimenu( handles.stagesMenu, ...
        'Tag', 'deleteUnusedStagesItem', ...
        'Label', 'Delete Unused Stage Times', ...
        'Separator', 'on', ...
        'Callback', @deleteUnusedStagesItem_Callback );
    handles.deleteAllStagesItem = uimenu( handles.stagesMenu, ...
        'Tag', 'deleteAllStagesItem', ...
        'Label', 'Delete All Stages...', ...
        'Callback', @deleteAllStagesItem_Callback );
    handles.deleteLaterStagesItem = uimenu( handles.stagesMenu, ...
        'Tag', 'deleteLaterStagesItem', ...
        'Label', 'Delete Later Stages...', ...
        'Callback', @deleteAllStagesItem_Callback );
    handles.deleteStagesAndTimesItem = uimenu( handles.stagesMenu, ...
        'Tag', 'deleteStagesAndTimesItem', ...
        'Label', 'Delete All Stages and Times...', ...
        'Callback', @deleteAllStagesItem_Callback );


function checkErrorItems( handles, isnorm )
    checkMenuItem( handles.normErrorItem, isnorm );
    checkMenuItem( handles.maxabsErrorItem, ~isnorm );


function dragViewEnd_Callback( hObject )
% Called when a click-drag to change the view ends.

%     fprintf( 1, 'dragViewEnd_Callback\n' );
    handles = guidata( hObject );
    if isfield( handles, 'mesh' ) && ~isempty( handles.mesh )
        handles.mesh = getDraggedView( handles.mesh );
        guidata( hObject, handles );
    end

function addHelpMenuHelp( handles )
    c = get( handles.output, 'Children' );
    % Find all the top-level menus in order from left to right.
    topmenus = zeros(0,0);
    for i=1:length(c)
        if strcmp( get( c(i), 'Type' ), 'uimenu' )
            topmenus( get(c(i),'Position') ) = c(i);
        end
    end
    % Add help submenus for all of the top level menus to the help menu.
    for i=1:length(topmenus)
        m = topmenus(i);
        copyMenuToHelpMenu( m, m, true );
    end

function copyMenuToHelpMenu( hm, m, first )
    if ~ishandle(m), return; end
	mud = get( m, 'UserData' );
    mtag = get( m, 'Tag' );
    if isempty(mud) || ~isfield( mud, 'helptext' )
        % Do not add a help menu item for this or its children.
        return;
    end
    c = get( m, 'Children' );
    if isempty(c)
        tag = [ 'help_' mtag ];
        label = get( m, 'Label' );
        label = regexprep( label, '^Show ', 'Show/Hide ' );
        label = regexprep( label, '^Hide ', 'Show/Hide ' );
    else
        tag = [ 'helpmenu_' mtag ];
        if hm==m
            label = 'Help';
        else
            label = [ get( m, 'Label' ), ' Menu' ];
        end
    end
    haveSeparator = first || strcmp( get( m, 'Separator' ), 'on' );
    newmenu = uimenu( 'Parent', hm, ...
                      'Tag', tag, ...
                      'Label', label );
    if isempty(c)
%         addUserData( newmenu, 
        set( newmenu, ...
             'Callback', @menuTooltipCallback, ...
             'UserData', mud );
    else
        haveMenuHelp = ~strcmp( mud.helptext, '*' );
        if haveMenuHelp
%             fprintf( 1, 'Adding menu help text for item %s ("%s"):\n    %s\n    %s\n\n', ...
%                 mtag, get( m, 'Label' ), mud.helptitle, mud.helptext );
            uimenu( 'Parent', newmenu, ...
                    'Label', get( m, 'Label' ), ...
                    'Tag', [ 'help_' mtag ], ...
                    'UserData', mud, ...
                    'Callback', @menuTooltipCallback );
        end
        for i=length(c):-1:1
            copyMenuToHelpMenu( newmenu, c(i), haveMenuHelp && (i==length(c)) );
        end
    end
    % Due to a Matlab R2011a bug in Mac OS, setting the separator property
    % must be done after the children of newmenu have been added, not when
    % newmenu is created.
    if haveSeparator
        forceMenuSeparator( newmenu );
    end
    removeUserDataFields( m, 'helptext', 'helptitle' );

function menuTooltipCallback( hObject, eventData )
    s = get( hObject, 'UserData' );
    if isfield( s, 'helpfig' ) && ishandle( s.helpfig )
        figure(s.helpfig);
    elseif isfield( s, 'helptext' ) && ~isempty( s.helptext )
        s.helpfig = displayTextInDlg( s.helptitle, s.helptext );
        set( hObject, 'UserData', s );
    end

function installTooltips( handles )
    tooltipbasename = [ mfilename(), '_tooltips.txt' ];
    tooltipfilename = fullfile( handles.codedirectory, tooltipbasename );
    fid = fopen( tooltipfilename, 'r' );
    if fid==-1
        fprintf( 1, 'Cannot find tooltips file %s in\n  %s\n', ...
            tooltipbasename, handles.codedirectory );
        return;
    end
    currentName = '';
    currentTip = '';
    havetooltip = struct();
    while true
        s = fgets( fid );
        if (length(s)==1) && (s == -1)
            setTooltip( handles, currentName, currentTip );
            break;
        end
        if (~isempty(s)) && (s(1)=='#')
            setTooltip( handles, currentName, currentTip );
            currentName = regexprep( s(2:end), '^\s*', '' );
            currentName = regexprep( currentName, '\s.*$', '' );
            currentTip = '';
            havetooltip.(currentName) = true;
        else
            currentTip = [currentTip, s]; %#ok<AGROW>
        end
    end
    fclose( fid );
    REGENERATE_TOOLTIPS = false;
    if REGENERATE_TOOLTIPS
        % Print the names of all handles that may have tooltips, and warn
        % of those which may but don't have them.
        newttfile = regexprep( tooltipfilename, '\.txt$', 'REGEN.txt' ); %#ok<UNRCH>
        newttfid = fopen( newttfile, 'w' );
        if newttfile == -1
            fprintf( 1, 'Cannot regenerate tooltip file %s.\n', newttfile );
        else
            tooltipitems = fieldnames(havetooltip);
            for i=1:length(tooltipitems)
                if ~isfield( handles, tooltipitems{i} )
                    fprintf( 1, 'Tooltip provided for missing item %s.\n', ...
                        tooltipitems{i} );
                end
            end
            fn = fieldnames(handles);
            for i=1:length(fn)
                try
                    h = handles.(fn{i});
                    if ishandle( h )
                        n = get( h, 'Tag' );
                        if strcmp( get( h, 'Type' ), 'uimenu' )
                            % THIS CODE MAY BE OUT oF DATE.
                            ud = get( h, 'UserData' );
                            label = get( h, 'Label' );
                            if isempty(ud)
                                % TO APPEAR
                            else
                                % TO APPEAR
                            end
                        elseif isempty( regexp( n, '^text[0-9][0-9]*$', 'once' ) )
                            try
                                s = get( h, 'TooltipString' );
                                sawitem = isfield( havetooltip, n );
                                label = tryget( h, 'String' );
                                if isempty(label)
                                    label = tryget( h, 'Label' );
                                end
                                if ~sawitem
                                    fprintf( 1, 'Item %s (%s, %s, %s) has no tooltip string.\n', ...
                                        fn{i}, get(h,'Type'),get(h,'Tag'),label );
                                end
                                if isempty(label)
                                    fprintf( newttfid, '#%s\n%s\n\n', fn{i}, s );
                                else
                                    fprintf( newttfid, '#%s %s\n%s\n\n', fn{i}, label, s );
                                end
                            catch
                                % Ignore items without the TooltipString
                                % attribute.
                            end
                        end
                    end
                catch
                    % Ignore exceptions.
                end
            end
            fclose( newttfid );
        end
    end

function setTooltip( handles, name, s )
    if isempty(name)
        return;
    end
    if ~isfield( handles, name )
        fprintf( 1, 'Tooltip provided for non-existent item "%s".\n', name );
        return;
    end
    itemHandle = handles.(name);
    if ishandle(itemHandle)
        s = regexprep( s, [ newline, '*$' ], '' );
        if ~isempty(s)
            if strcmp( get( itemHandle, 'Type' ), 'uimenu' )
                % Install the tooltip as the helptext in the userdata.
                addUserData( itemHandle, ...
                    'helptext', reformatText( s ), ...
                    'helptitle', menuPath( itemHandle ) );
            else
                try
                    set( itemHandle, 'TooltipString', s );
                catch me
                    fprintf( 1, 'Could not set tooltip for item %s: %s.\n', ...
                        name, me.message );
                end
            end
        end
    end

function processDlgQueue( h )
    handles = guidata( h );
    while ~isempty( handles.dlgchanges )
        dlgchange = handles.dlgchanges(1);
        fprintf( 1, 'processDlgQueue: dialog %f, tag %s, value:', ...
            dlgchange.Dialog, dlgchange.Tag );
        handles.dlgchanges = handles.dlgchanges(2:end);
    end

function meshTextSliderCallback( hObject, name, val )
    meshSetProperty( guidata(hObject), name, val );

    
function handles = getGFtboxVersion( handles )
    [handles.GFtboxRevision,handles.GFtboxRevisionDate] = GFtboxRevision();
    if handles.GFtboxRevision==0
        aboutstring = 'About';
    else
        aboutstring = sprintf( 'About rev. %d', handles.GFtboxRevision );
    end
    set( handles.aboutMenu, 'Label', aboutstring );
    if isempty(handles.GFtboxRevisionDate)
        revdatestring = 'Unknown Date';
    else
        revdatestring = regexprep( handles.GFtboxRevisionDate, 'T', ' ' );
        revdatestring = regexprep( revdatestring, '\.[0-9]*Z', '' );
    end
    set( handles.dateItem, 'Label', revdatestring );

    
function handles = updateGUIfromConfig( handles )
    global GFTboxConfig GFtboxFigure CANUSEGPUARRAY
    
    handles.userConfigFilename = GFTboxConfig.userConfigFilename;
    handles.codedirectory = GFtboxDir();
    handles.systemProjectsDir = fullfile( handles.codedirectory, 'Models' );
    handles = getGFtboxVersion( handles );

    setNamedCompressor( handles.codecMenu, GFTboxConfig.compressor );
    handles.fontdetails.FontName = GFTboxConfig.FontName;
    handles.fontdetails.FontUnits = GFTboxConfig.FontUnits;
    handles.fontdetails.FontSize = GFTboxConfig.FontSize;
    handles.fontdetails.FontWeight = GFTboxConfig.FontWeight;
    handles.fontdetails.FontAngle = GFTboxConfig.FontAngle;
    setDoubleInTextItem( handles.bioAlinesizeText, GFTboxConfig.bioedgethickness );
    setDoubleInTextItem( handles.bioApointsizeText, GFTboxConfig.biovertexsize );
    handles.userProjectsDirs = GFTboxConfig.projectsdir;
    handles.userProjectsDir = GFTboxConfig.defaultprojectdir;
    handles.Renderer = GFTboxConfig.Renderer;
    CANUSEGPUARRAY = strcmp( GFTboxConfig.usegraphicscard, 'true' ) && canUseGPUArray();
    handles.usegraphicscard = GFTboxConfig.usegraphicscard;
    checkMenuItem( handles.useGraphicsCardItem, CANUSEGPUARRAY );
    handles.catchIFExceptions = strcmp( GFTboxConfig.catchIFExceptions, 'true' );
    checkMenuItem( handles.catchIFExceptionsItem, handles.catchIFExceptions );
    setappdata( handles.GFTwindow, 'catchIFExceptions', handles.catchIFExceptions );
    
    % Set the rendering method.
    set( GFtboxFigure, 'Renderer', handles.Renderer );
    checkRendererItemFromName( handles );
    % fprintf( 1, 'Rendering method is "%s".\n', get( GFtboxFigure, 'Renderer' ) );
    
    % Create the Recent Items item on the Projects menu.
    recentHpos = get( handles.refreshProjectsMenu, 'Position' ) + 1;
    handles.recentprojectsMenu = uimenu( handles.projectsMenu, ...
            'Label', 'Recent Projects', ...
            'Tag', 'recentprojectsMenu', ...
            'Position', recentHpos );

        % Add all recent items to the Recent Items menu.  If one of those is the
    % default, add a checkmark.  Disable those that don't exist.
    if isempty( GFTboxConfig.recentproject )
        uimenu( handles.recentprojectsMenu, 'Label', 'None', 'Enable', 'off' );
    else
        if ischar( GFTboxConfig.recentproject )
            GFTboxConfig.recentproject = { GFTboxConfig.recentproject };
        end
        for i=1:length(GFTboxConfig.recentproject)
            fullname = GFTboxConfig.recentproject{i};
            [path,base,ext] = fileparts( fullname ); %#ok<ASGLU>
            if isGFtboxProjectDir( fullname )
                uimenu( handles.recentprojectsMenu, ...
                    'Label', [base ext], ...
                    'Enable', boolchar( isGFtboxProjectDir( fullname ), 'on', 'off' ), ...
                    'UserData', struct( 'modeldir', fullname, 'readonly', false ), ...
                    'Callback', @recentprojectsMenuItemCallback );
            end
        end
    end
    
    uimenu( handles.recentprojectsMenu, ...
        'Label', 'Clear Recent Projects', ...
        'Enable', 'on', ...
        'Separator', 'on', ...
        'Callback', @clearRecentProjectsMenu );
	forceMenuSeparator( handles.recentprojectsMenu );
    
    % Add all project dirs to the Projects menu and select the default one.
    for i=1:length( handles.userProjectsDirs )
        handles = addProjectsMenu( handles, handles.userProjectsDirs{i}, false, @projectMenuItemCallback );
    end
    handles = addProjectsMenu( handles, handles.systemProjectsDir, true, @projectMenuItemCallback );
    if isempty( handles.userProjectsDir )
        handles.userProjectsDir = handles.systemProjectsDir;
    end
    handles = selectDefaultProjectsMenu( handles );

    % Set missing font properties in GFTboxConfig from the GUI, then update
    % the font properties in the GUI if they differ from those in
    % GFTboxConfig.
    typicalHandle = handles.restartButton;
    defaultFontConfig = getFontDetails( typicalHandle );
    if isempty(GFTboxConfig.FontName)
        GFTboxConfig.FontName = defaultFontConfig.FontName;
    end
    if isempty(GFTboxConfig.FontUnits)
        GFTboxConfig.FontUnits = defaultFontConfig.FontUnits;
    end
    if GFTboxConfig.FontSize==0
        GFTboxConfig.FontSize = defaultFontConfig.FontSize;
    end
    if isempty(GFTboxConfig.FontWeight)
        GFTboxConfig.FontWeight = defaultFontConfig.FontWeight;
    end
    if isempty(GFTboxConfig.FontAngle)
        GFTboxConfig.FontAngle = defaultFontConfig.FontAngle;
    end
    
    fontdetailschanged = ...
           ~strcmp(GFTboxConfig.FontName,defaultFontConfig.FontName) ...
        || ~strcmp(GFTboxConfig.FontUnits,defaultFontConfig.FontUnits) ...
        || (GFTboxConfig.FontSize ~= defaultFontConfig.FontSize) ...
        || ~strcmp(GFTboxConfig.FontWeight,defaultFontConfig.FontWeight) ...
        || ~strcmp(GFTboxConfig.FontAngle,defaultFontConfig.FontAngle);
    
    if fontdetailschanged
        GFtboxUpdateFonts( handles.fontdetails, handles.GFTwindow, ...
            getFontDetails( handles.restartButton ) );
    end

function clearRecentProjectsMenu(hObject, eventdata)
    recentprojectsMenu = get( hObject, 'Parent' );
    set( recentprojectsMenu, 'Separator', 'off' );
    handles = guidata( recentprojectsMenu );
    delete( get( recentprojectsMenu, 'Children' ) );
    modeldir = getModelDir( handles.mesh );
    if ~isempty( modeldir )
        [~,base] = dirparts( modeldir ); % Unused: path
        uimenu( recentprojectsMenu, ...
            'Label', base, ...
            'Enable', boolchar( isGFtboxProjectDir( modeldir ), 'on', 'off' ), ...
            'UserData', struct( 'modeldir', modeldir, 'readonly', false ), ...
            'Callback', @recentprojectsMenuItemCallback );
    end
    uimenu( recentprojectsMenu, ...
        'Label', 'Clear Recent Projects', ...
        'Enable', 'on', ...
        'Separator', 'on', ...
        'Tag', 'clearrecentprojects', ...
        'Callback', @clearRecentProjectsMenu );
    drawnow;  % Workaround for Matlab bug on Mac OS.
    set( recentprojectsMenu, 'Separator', 'on' );

% --- Outputs from this function are returned to the command line.
function varargout = GFtbox_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function toolSelect_SelectionChangeFcn( hObject, eventdata )
    selectCurrentTool( guidata(hObject) );


% --- Executes on button press in clearButton.
function closeProjectItem_Callback(hObject, eventdata, handles)
% Close the current project and delete the current mesh.
    setVisualRunMode( handles, 'idle' );
    makeDefaultThumbnail( handles.mesh );
    handles.mesh = [];
    handles.runColors.readyColor = handles.runColors.okColor;
    resetButton_Callback(hObject, eventdata, handles);
    enableMenus( handles );
    handles = remakeStageMenu( handles );
    enableMutations( handles );
    setToolboxName( handles );
    updateGUIFromMesh( handles );
    set( handles.siminfoText, 'String', '' );
    handles.autoScale.UserData = [];
  %  setMorphogenPanelLabel( handles )
    cla( handles.picture );
    resetView( handles.picture );
    axis( handles.picture, 'off' );
    drawThumbnail( handles );
    guidata( hObject, handles );


% --- Executes on button press in resetButton.
function resetButton_Callback(hObject, eventdata, handles)
% Click this button if GFtbox gets confused and thinks the simulation is running
% when it isn't.  Do not click it if the simulation really is running.
    resetGlobals();
    setVisualRunMode( handles, 'idle' );
    setRunning( handles, 0 );
    clearstopbutton( handles );
    clearFlag( handles, 'plotFlag' );
    set( handles.plotFlag, 'UserData', [] );
    clearFlag( handles, 'commandFlag' );
    handles = indicateInteractionValidity( handles, true );
    if isfield( handles, 'trackballData' )
        handles = rmfield( 'trackballData' );
    end
    set(handles.output,'WindowButtonMotionFcn','','WindowButtonUpFcn','')
    handles = getGFtboxVersion( handles );
    if ~isempty(handles.mesh)
        handles.mesh.stop = false;
    end
    guidata( hObject, handles );
    set( handles.commandFlag, 'UserData', [] );
    enableMenus( handles );
    set(gcbf,'Pointer','arrow');
    set( handles.picture, ...
        'ButtonDownFcn', @GFtboxGraphicClickHandler, ...
        'CameraPositionMode', 'manual', ...
        'CameraTargetMode', 'manual', ...
        'CameraUpVectorMode', 'manual', ...
        'CameraViewAngleMode', 'manual', ...
        'DataAspectRatio', [1 1 1], ...
        'DataAspectRatioMode', 'manual', ...
        'PlotBoxAspectRatio',[1 1 1], ...
        'PlotBoxAspectRatioMode', 'manual' );
    setRunning( handles, false );
    setGFtboxBusy( handles, false );


function y = askAllowUnflat( handles )
    if handles.mesh.globalProps.alwaysFlat
        answer = queryDialog( 2, '', 'Remove flatness constraint?' );
        if answer==1  % "Yes"
            set( handles.alwaysFlat, 'Value', false );
            set( handles.twoD, 'Value', false );
        end
    else
        y = true;
    end

    
% --- Executes on button press in perturbz.
function perturbz_Callback(hObject, eventdata, handles, mustExecute)
% hObject    handle to perturbz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    if isempty( handles.mesh )
        fprintf( 1, 'leaf_perturbz: No mesh.\n' );
    elseif askAllowUnflat( handles )
        [perturbzamt,ok1] = getDoubleFromDialog( handles.zamount );
        if ok1 && (perturbzamt ~= 0)
            attemptCommand( handles, false, true, ...
                'perturbz', perturbzamt, 'smoothing', 0 );
        end
    end


% --- Executes on button press in zeroz.
function zeroz_Callback(hObject, eventdata, handles)
% hObject    handle to zeroz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    if isempty( handles.mesh )
        fprintf( 1, 'leaf_setzeroz: No mesh.\n' );
    else
        attemptCommand( handles, false, true, ...
            'setzeroz' );
    end

    
% --------------------------------------------------------------------
function saveProjectAsItem_Callback(hObject, eventdata, handles)
    if isempty( handles.mesh )
        return;
    end
    if getUIFlag( handles.runFlag )
        simRunningDialog( 'Cannot save model while simulation is in progress.' );
        return;
    end
    wasBusy = setGFtboxBusy( handles, true );
    startTic = startTimingGFT( handles );
    if isempty( handles.mesh.globalProps.modelname )
        [handles.mesh,ok] = leaf_savenewproject( handles.mesh ); % , 'strip', ischeckedMenuItem( h.stripsaveItem ) );
        stopTimingGFT('leaf_savenewproject',startTic);
    else
        [handles.mesh,ok] = leaf_copyproject( handles.mesh ); % , 'strip', ischeckedMenuItem( h.stripsaveItem ) );
        stopTimingGFT('leaf_copyproject',startTic);
    end
    if ok
        guidata( handles.output, handles );
        handles = installNewMesh( handles, handles.mesh );
        handles = updateGUIForNewProject( handles );
        guidata(handles.output, handles);
    end
    setGFtboxBusy( handles, wasBusy );
    
    
% --- Executes on button press in savemodelover. (The "Save Stage" button.)
function savemodelover_Callback(hObject, eventdata, handles)
    savemodelover( handles );

function savemodelover_KeyCallback( handles, keystroke, modbits )
    savemodelover( handles );


function savemodelover( handles )
    if isempty( handles.mesh )
        return;
    end
    if getUIFlag( handles.runFlag )
        complain( 'Cannot save the mesh while the simulation is running.' );
        return;
    end
    wasBusy = setGFtboxBusy( handles, true );
    projectdir = handles.mesh.globalProps.projectdir;
    if isempty(projectdir)
        projectdir = handles.userProjectsDir;
    end
    modelname = handles.mesh.globalProps.modelname;
    if isempty( modelname ) || isempty( projectdir )
        % Save as a new project
        startTic = startTimingGFT( handles );
        [handles.mesh,ok] = leaf_savenewproject( handles.mesh, '', projectdir, 'ask', true, 'strip', ischeckedMenuItem( handles.stripsaveItem ) );
        stopTimingGFT('leaf_savenewproject',startTic);
        if ok
            updateGUIForNewProject( handles );
        end
    else
        % Save as a stage file.
        startTic = startTimingGFT( handles );
        if isempty( handles.mesh.globalProps.currentrun )
            meshdir = fullfile( projectdir, modelname );
        else
            meshdir = fullfile( handles.mesh.globalProps.currentrun, 'meshes' );
        end
        [handles.mesh,ok] = leaf_savestage( handles.mesh, meshdir );
        stopTimingGFT('leaf_savestage',startTic);
        if ok
            handles = remakeStageMenu( handles );
        end
    end
    guidata( handles.mesh.pictures(1), handles );
    setGFtboxBusy( handles, wasBusy );

    
    
    
%     if isempty(modelname)
%         % We made a new project.
%         handles = refreshProjectsMenu( handles );
%         % Would be faster to just insert the new project dir into the
%         % Projects menu.  That would also cope with the situation where the
%         % new project is not stored in any of the user project directories.
%         handles = remakeStageMenu( handles );
%         handles = updateRecentProjects( handles );
%         setMeshFigureTitle( handles.output, handles.mesh );
%         if handles.mesh.globalProps.mgen_interactionName
%             set( handles.mgenInteractionName, 'String', handles.mesh.globalProps.mgen_interactionName );
%         else
%             set( handles.mgenInteractionName, 'String', '(none)' );
%         end
%     end


% --------------------------------------------------------------------
function openProjectItem_Callback(hObject, eventdata, handles)
    if getUIFlag( handles.runFlag )
        complain( 'Cannot load a new mesh while the simulation is busy.' );
        return;
    end
    wasBusy = setGFtboxBusy( handles, true );
    if isempty( handles.mesh ) || isempty( handles.mesh.globalProps.projectdir )
        projectdir = handles.userProjectsDir;
    else
        projectdir = handles.mesh.globalProps.projectdir;
    end
    startTic = startTimingGFT( handles );
    [m,ok] = leaf_loadmodel( handles.mesh, '', projectdir, 'interactive', true, 'soleaccess', true );
    stopTimingGFT('leaf_loadmodel',startTic);
    if ok && ~isempty(m)
        % Unselect old project menu item.
        % unselectProjectMenu( handles );
        handles = installNewMesh( handles, m );
        handles = selectDefaultProjectsMenu( handles, getModelDir( m ) );
        guidata(handles.output, handles);
    end
	setGFtboxBusy( handles, wasBusy );

% --- Executes on button press in restartButton.
function restartButton_Callback(hObject, eventdata, handles)
    if isempty( handles.mesh )
        fprintf( 1, 'No mesh.\n' );
        return;
    end
    if getUIFlag( handles.runFlag )
        complain( 'Cannot reload the initial mesh while the simulation is busy.' );
        return;
    end
    reloadMesh( handles, 'restart' )


% --- Executes on button press in reloadmodel.
function reloadmodel_Callback(hObject, eventdata, handles)
    if isempty( handles.mesh )
        fprintf( 1, 'No mesh.\n' );
        return;
    end
    if getUIFlag( handles.runFlag )
        complain( 'Cannot reload the mesh while the simulation is busy.' );
        return;
    end
    reloadMesh( handles, 'reload', 'soleaccess', true );


% --- Executes on button press in nextStageButton.
function nextStageButton_Callback(hObject, eventdata, handles)
    if isempty( handles.mesh )
        fprintf( 1, 'No mesh.\n' );
        return;
    end
    if getUIFlag( handles.runFlag )
        complain( 'Cannot reload a new stage while the simulation is busy.' );
        return;
    end


% --- Executes on button press in prevStageButton.
function prevStageButton_Callback(hObject, eventdata, handles)
    if isempty( handles.mesh )
        fprintf( 1, 'No mesh.\n' );
        return;
    end
    if getUIFlag( handles.runFlag )
        complain( 'Cannot reload a new stage while the simulation is busy.' );
        return;
    end


function cmdname = makeCommandName( username )
    cmdname = lower( regexprep( username, ' ', '' ) );

function ps = paramSpec( username, paramname, default, type )
    if nargin==3
        type = default;
        default = paramname;
        paramname = makeCommandName( username );
    end
    ps = struct( 'username', username, ...
                 'paramname', paramname, ...
                 'default', default, ...
                 'lastvalue', default, ...
                 'type', type );


function mgs = makeMeshGenSpec( GUIcommand, varargin )
    mgs.GUIcommand = GUIcommand;
    mgs.scriptcommand = makeCommandName( GUIcommand );
    for i=1:length(varargin)
        mgs.paramSpec(i) = paramSpec( varargin{i}{:} );
    end


% --- Executes on button press in replacemeshbutton.
function replacemeshbutton_Callback(hObject, eventdata, handles)
    newmesh( handles, true );


% --- Executes on button press in replacemeshbutton.
function generatemesh_Callback(hObject, eventdata, handles)
    newmesh( handles, false );


% --- Executes on button press in generatemesh.
function newmesh(handles,replaceGeometry)
    if getUIFlag( handles.runFlag )
        complain( 'Cannot create a new mesh while the simulation is busy.' );
        return;
    end
    wasBusy = setGFtboxBusy( handles, true );

    resetGlobals();
    setVisualRunMode( handles, 'idle' );
    [mp,ok] = getMeshParams( handles );
    if ~ok
        setGFtboxBusy( handles, wasBusy );
        return;
    end
    constructor = mp.constructor;
    mp = rmfield( mp, 'constructor' );
    if isfield( mp, 'otherparams' )
        otherparams = struct2args( mp.otherparams );
        mp = rmfield( mp, 'otherparams' );
    else
        otherparams = {};
    end
    mpa = struct2args( mp );
    if replaceGeometry
        makeDefaultThumbnail( handles.mesh );
    end
    [handles,okmesh] = attemptNewMeshCommand( handles, replaceGeometry, ...
        constructor, ...
        mpa{:}, otherparams{:} );
    if okmesh
        % We know the simulation is not running at this point, so we can
        % safely modify handles.
        guidata(handles.output, handles);
        announceSimStatus( handles );
    end
    setGFtboxBusy( handles, wasBusy );
    
    
function showGrowthMenu( menu )  % NOT NEEDED?
    s = get( menu, 'String' );
    v = get( menu, 'Value' );
    fprintf( 1, 'Menu value %d, strings', v );
    for i=1:length(s)
        fprintf( 1, ' "%s"', s{i} );
    end
    fprintf( 1, '\n' );

    
function menu = setGrowthMenu( menu, length, current )  % NOT NEEDED?
    s = cell( 1, length );
    for i=1:length
        s{i} = num2str(i);
    end
    set( menu, 'String', s );
    set( menu, 'Value', current );

    
% --- Executes during object deletion, before destroying properties.
function deadcanary_DeleteFcn(hObject, eventdata, handles)

% --- Executes on button press in bowlz.
function bowlz_Callback(hObject, eventdata, handles)
% hObject    handle to bowlz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    if isempty( handles.mesh )
        fprintf( 1, 'No mesh.\n' );
    else
        [zamount,ok1] = getDoubleFromDialog( handles.zamount );
        if ok1 && (zamount ~= 0) && askAllowUnflat( handles )
            attemptCommand( handles, false, true, ...
                'bowlz', 'amount', zamount );
        end
    end


% --- Executes on button press in saddlez.
function saddlez_Callback(hObject, eventdata, handles)
% hObject    handle to saddlez (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    if isempty( handles.mesh )
        fprintf( 1, 'No mesh.\n' );
    else
        [zamount,ok1] = getDoubleFromDialog( handles.zamount );
        [numsaddle,ok2] = getIntFromDialog( handles.numsaddle, 2 );
        if ok1 && ok2 && askAllowUnflat( handles )
            attemptCommand( handles, false, true, ...
                'saddlez', 'amount', zamount, 'lobes', numsaddle );
        end
    end


function diffusionEnabled_CreateFcn(hObject, eventdata, handles)
    % Nothing.

% --- Executes on button press in diffusionEnabled.
function diffusionEnabled_Callback(hObject, eventdata, handles)
    meshSetBoolean( handles, 'do_diffusion', hObject );


function growthEnabled_CreateFcn(hObject, eventdata, handles)
    % Nothing.

% --- Executes on button press in growthenabled.
function growthEnabled_Callback(hObject, eventdata, handles)
    setGrowthType(hObject,handles);


function setGrowthType(hObject, handles)
    if isempty( handles.mesh ), return; end
    
    elastic = get(handles.growthEnabled,'Value') ~= 0;
    plastic = get(handles.plasticGrowthEnabled,'Value') ~= 0;
    springy = get(handles.springyGrowthEnabled,'Value') ~= 0;
    
    switch hObject.Tag
        case 'growthEnabled'
            if elastic
                plastic = false;
                springy = false;
            end
        case 'plasticGrowthEnabled'
            if plastic
                elastic = false;
                springy = false;
            end
        case 'springyGrowthEnabled'
            if springy
                elastic = false;
                plastic = false;
            end
        otherwise
            return;
    end
    dogrowth = elastic || plastic || springy;
    
    [~,handles] = meshSetProperty( handles, 'do_growth', dogrowth, 'plastic', plastic, 'springy', springy );
    
    set(handles.growthEnabled,'Value',elastic);
    set(handles.plasticGrowthEnabled,'Value',plastic);
    set(handles.springyGrowthEnabled,'Value',springy);



function springyGrowthEnabled_Callback(hObject, eventdata, handles)
    setGrowthType(hObject,handles);


function plasticGrowthEnabled_Callback(hObject, eventdata, handles)
    setGrowthType(hObject,handles);


function conductivityText_Callback(hObject, eventdata, handles)
    if isempty( handles.mesh ), return; end
    [ conductivity, ok1 ] = ...
        getDoubleFromDialog( handles.conductivityText, 0 );
    if ok1
        attemptCommand( handles, false, false, ...
            'mgen_conductivity', ...
            getDisplayedMgenIndex( handles ), ...
            conductivity );
    end


function absorptionText_Callback(hObject, eventdata, handles)
    if isempty( handles.mesh ), return; end
    [ absorption, ok1 ] = ...
        getDoubleFromDialog( handles.absorptionText, 0 );
    if ok1
        attemptCommand( handles, false, false, ...
            'mgen_absorption', ...
            getDisplayedMgenIndex( handles ), ...
            absorption );
    end


function absorptionText_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function enabledisableIFitem_Callback(hObject, eventdata, handles)
    enable = toggleCheckedMenuItem( hObject );
    enableInteractionFunction( handles, enable );


function morpheditmodemenu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in zeroall.
function zeroall_Callback(hObject, eventdata, handles)
    if isempty( handles.mesh )
        fprintf( 1, 'No mesh.\n' );
    else
        needReplot = plottingMorphogen( handles.mesh );
        attemptCommand( handles, false, needReplot, ...
            'mgen_reset' );
    end


% --- Executes on button press in zerogf.
function zerogf_Callback(hObject, eventdata, handles)
    if isempty( handles.mesh )
        fprintf( 1, 'No mesh.\n' );
    else
        needReplot = plottingMorphogen( handles.mesh );
        highlightedpts = getHighlightedPoints( handles.picture, true );
        attemptCommand( handles, false, needReplot, ...
            'mgen_zero', ...
            getDisplayedMgenIndex( handles ), ...
            'nodes', highlightedpts );
    end

function pm = plottingMorphogen( m )
    pm = ~(isempty( m.plotdefaults.morphogen ) ...
           && isempty( m.plotdefaults.morphogenA ) ...
           && isempty( m.plotdefaults.morphogenB ) ...
          );
    
% --- Executes on button press in gfradial.
function gfradial_Callback(hObject, eventdata, handles)
    if isempty( handles.mesh )
        fprintf( 1, 'No mesh.\n' );
    else
        [maxgf,ok1] = getDoubleFromDialog( handles.paintamount );
        [radialx,ok2] = getDoubleFromDialog( handles.radialx );
        [radialy,ok3] = getDoubleFromDialog( handles.radialy );
        [radialz,ok4] = getDoubleFromDialog( handles.radialz );
        if ok1 && ok2 && ok3 && ok4
            needReplot = plottingMorphogen( handles.mesh );
            highlightedpts = getHighlightedPoints( handles.picture, true );
            attemptCommand( handles, false, needReplot, ...
                'mgen_radial', ...
                getDisplayedMgenIndex( handles ), ...
                maxgf, ...
                'x', radialx, ...
                'y', radialy, ...
                'z', radialz, ...
                'power', 1, ...
                'nodes', highlightedpts );
        end
    end

    
% --- Executes on button press in invertGrowth.
function invertGrowth_Callback(hObject, eventdata, handles)
    if isempty( handles.mesh )
        fprintf( 1, 'No mesh.\n' );
    else
        needReplot = plottingMorphogen( handles.mesh );
        highlightedpts = getHighlightedPoints( handles.picture, true );
        attemptCommand( handles, false, needReplot, ...
            'mgen_scale', ...
            getDisplayedMgenIndex( handles ), ...
            -1, ...
            'nodes', highlightedpts );
    end
    

% --- Executes on button press in linearGrowth.
function linearGrowth_Callback(hObject, eventdata, handles)
% hObject    handle to linearGrowth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    if isempty( handles.mesh )
        fprintf( 1, 'No mesh.\n' );
    else
        [maxgf,ok1] = getDoubleFromDialog( handles.paintamount );
        [lindir,ok2] = getDoubleFromDialog( handles.linearDirection );
        if ok1 && ok2
            needReplot = plottingMorphogen( handles.mesh );
            highlightedpts = getHighlightedPoints( handles.picture, true );
            attemptCommand( handles, false, needReplot, ...
                'mgen_linear', ...
                getDisplayedMgenIndex( handles ), ...
                maxgf, ...
                'direction', lindir, ...
                'nodes', highlightedpts, ...
                'add', true );
        end
    end


function linearDirection_Callback(hObject, eventdata, handles)

function linearDirection_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in edgeGrowth.
function edgeGrowth_Callback(hObject, eventdata, handles)
    if isempty( handles.mesh )
        fprintf( 1, 'No mesh.\n' );
    else
        [maxgf,ok1] = getDoubleFromDialog( handles.paintamount );
        if ok1
            needReplot = plottingMorphogen( handles.mesh );
            highlightedpts = getHighlightedPoints( handles.picture, true );
            attemptCommand( handles, false, needReplot, ...
                'mgen_edge', ...
                getDisplayedMgenIndex( handles ), ...
                maxgf, ...
                'nodes', highlightedpts, ...
                'add', true );
        end
    end


% --- Executes on button press in constantGrowth.
function constantGrowth_Callback(hObject, eventdata, handles)
    if isempty( handles.mesh )
        fprintf( 1, 'No mesh.\n' );
    else
        [maxgf,ok1] = getDoubleFromDialog( handles.paintamount );
        if ok1
            needReplot = plottingMorphogen( handles.mesh );
            highlightedpts = getHighlightedPoints( handles.picture, true );
            attemptCommand( handles, false, needReplot, ...
                'mgen_const', ...
                getDisplayedMgenIndex( handles ), ...
                maxgf, ...
                'nodes', highlightedpts, ...
                'add', true );
          % handles = guidata( hObject );
          % newmgen = handles.mesh.morphogens( :, getDisplayedMgenIndex( handles ) )'
        end
    end


% --- Executes on button press in randomGrowth.
function randomGrowth_Callback(hObject, eventdata, handles)
    if isempty( handles.mesh )
        fprintf( 1, 'No mesh.\n' );
    else
        [maxgf,ok1] = getDoubleFromDialog( handles.paintamount );
        if ok1
            needReplot = plottingMorphogen( handles.mesh );
            highlightedpts = getHighlightedPoints( handles.picture, true );
            attemptCommand( handles, false, needReplot, ...
                'mgen_random', ...
                getDisplayedMgenIndex( handles ), ...
                maxgf, ...
                'nodes', highlightedpts, ...
                'add', true );
        end
    end


function GFTwindow_CreateFcn(hObject, eventdata, handles)


% --- Executes during object deletion, before destroying properties.
function GFTwindow_DeleteFcn(hObject, eventdata, handles)
    deleteUntitledProject();


% --- Executes on mouse press over axes background.
function picture_ButtonDownFcn(hObject, eventdata, handles)


% --- Executes on mouse press over axes background.
function pictureOLD_ButtonDownFcn(hObject, eventdata, handles)


function poissonsRatio_Callback(hObject, eventdata, handles)
    [ poissonsRatio, ok1 ] = ...
        getDoubleFromDialog( handles.poissonsRatio, -1 );
    if ok1 && ~isempty( handles.mesh )
        meshSetProperty( handles, 'poisson', poissonsRatio );
    end


function poissonsRatio_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    

function timestep_Callback(hObject, eventdata, handles)
    if isempty( handles.mesh )
        return;
    end
    [ ts, ok1 ] = getDoubleFromDialog( hObject, 0 );
    if ok1 && (ts > 0)
        meshSetProperty( handles, 'timestep', ts );
    end

function timestep_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in movieButton.
function movieButton_Callback(hObject, eventdata, handles)
    if ~isempty( handles.mesh )
        wasBusy = setGFtboxBusy( handles, true );
        if movieInProgress( handles.mesh )
            attemptCommand( handles, false, false, ...
                'movie', 0 );
        else
            attemptCommand( handles, false, false, ...
                'movie', ...
                'fps', handles.fps, ...
                'quality', handles.quality, ...
                'compression', getSelectedCompressor( handles.codecMenu ) );
        end
        handles = guidata( hObject );
        mip = movieInProgress( handles.mesh );
        if mip
            set( handles.movieButton, 'String', 'Stop movie' );
        else
            set( handles.movieButton, 'String', 'Record movie...' );
        end
        enableHandle( handles.addFrameItem, mip );
        setGFtboxBusy( handles, wasBusy );
    end


function paintslider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function paintamount_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function newplotQuantityMenu_Callback(hObject, eventdata, handles)
    notifyPlotChange( handles, ...
        'outputquantity', plottedOutputQuantity( handles ) );
    handles = guidata( hObject );
    set( handles.inputSelectButton, 'Value', 0 );
    set( handles.outputSelectButton, 'Value', 1 );
    setMyLegend( handles.mesh );

function oq = plottedOutputQuantity( handles )
    oq = lower(unspace(getMenuSelectedLabel( handles.newplotQuantityMenu )));

function newplotQuantityMenu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function notifyPlotChangeShowHide( handles, fn, hObject )
    toggleShowHideMenuItem( hObject );
    notifyPlotChange( handles, fn, valueShowHideMenuItem( hObject ) );

function notifyPlotChangeCheckedMenuItem( handles, fn, hObject )
    toggleCheckedMenuItem( hObject );
    notifyPlotChange( handles, fn, ischeckedMenuItem( hObject ) );

function enablePlotCheckbox_Callback(hObject, eventdata, handles)
% Plot panel.
    notifyPlotChangeFromGUIBool( handles, 'enableplot', hObject );

function allowSnapsCheckbox_Callback(hObject, eventdata, handles)
% Plot panel.
    attemptCommand( handles, false, false, ...
        'plotoptions', ...
        'allowsnaps', get(hObject,'Value') ~= 0 );

function showNoEdgesRadioButton_Callback(hObject, eventdata, handles)
    set( handles.showNoEdgesRadioButton, 'Value', 1 );
    set( handles.showSomeEdgesRadioButton, 'Value', 0 );
    set( handles.showAllEdgesRadioButton, 'Value', 0 );
    notifyPlotChange( handles, 'drawedges', 0 );

function showSomeEdgesRadioButton_Callback(hObject, eventdata, handles)
    set( handles.showNoEdgesRadioButton, 'Value', 0 );
    set( handles.showSomeEdgesRadioButton, 'Value', 1 );
    set( handles.showAllEdgesRadioButton, 'Value', 0 );
    notifyPlotChange( handles, 'drawedges', 1 );

function showAllEdgesRadioButton_Callback(hObject, eventdata, handles)
    set( handles.showNoEdgesRadioButton, 'Value', 0 );
    set( handles.showSomeEdgesRadioButton, 'Value', 0 );
    set( handles.showAllEdgesRadioButton, 'Value', 1 );
    notifyPlotChange( handles, 'drawedges', 2 );

    
function showPolariser_Callback(hObject, eventdata, handles)
% Plot panel.
    notifyPlotChangeFromGUIBool( handles, 'drawgradients', hObject );
    
function showPolariser2_Callback(hObject, eventdata, handles)
% Plot panel.
    notifyPlotChangeFromGUIBool( handles, 'drawgradients2', hObject );

function showPolariser3_Callback(hObject, eventdata, handles)
% Plot panel.
    notifyPlotChangeFromGUIBool( handles, 'drawgradients3', hObject );

function showSecondLayer_Callback(hObject, eventdata, handles)
% Plot panel.
    notifyPlotChangeFromGUIBool( handles, 'drawsecondlayer', hObject );

function showTensorAxes_Callback(hObject, eventdata, handles)
% Not in plot panel.
    notifyPlotChangeFromGUIBool( handles, 'drawtensoraxes', hObject );

function drawmulticolor_Callback(hObject, eventdata, handles)
% Plot panel.
    plotMgensFromGUI( handles );

function axisRangeFromPictureButton_Callback(hObject, eventdata, handles)
% Plot panel.
    if isempty(handles.mesh) || isempty(handles.mesh.pictures)
        return;
    end
    axisRange = axisBoundsDialog(handles);
    if isempty(axisRange)
        return;
    end
    badValues = isnan(axisRange);
    if any(badValues)
        currentRange = [ get( handles.mesh.pictures(1), 'XLim' ), ...
                         get( handles.mesh.pictures(1), 'YLim' ), ...
                         get( handles.mesh.pictures(1), 'ZLim' ) ];
        axisRange(badValues) = currentRange(badValues);
    end

    attemptCommand( handles, false, false, ...
        'plotoptions', ...
        'axisRange', axisRange );  % autorange and autoscale also?


% --- Executes on button press in autoScale.
function autoScale_Callback(hObject, eventdata, handles)
% Plot panel.
    autoAxisRange = getUIFlag( hObject );
    haveStoredAxisBounds = ~isempty( hObject.UserData ) && isfield( hObject.UserData, 'bounds' ) && ~isempty( hObject.UserData.bounds );
    if haveStoredAxisBounds
        storedAxisBounds = hObject.UserData.bounds;
    else
        storedAxisBounds = [];
    end
    currentAxisBounds = [ get( handles.picture, 'XLim' ), ...
                          get( handles.picture, 'YLim' ), ...
                          get( handles.picture, 'ZLim' ) ];
    if autoAxisRange
        if isempty( handles.mesh )
            axisRange = [];
        else
            axisRange = meshbbox( handles.mesh, true, 0.05 );
            hObject.UserData.bounds = currentAxisBounds;
        end
    else
        axisRange = storedAxisBounds;
    end
    attemptCommand( handles, false, false, ...
        'plotoptions', ...
        'axisRange', axisRange, ...
        'autoScale', autoAxisRange, ...
        'autocentre', autoAxisRange );


% --- Executes on button press in autoColorRange.
function autoColorRange_Callback(hObject, eventdata, handles)
% Plot panel.
%     notifyPlotChangeFromGUIBool( handles, 'autoColorRange', hObject );
    if get(hObject,'Value') == 0
        crange = getCrangeFromGUI( handles );
    else
        crange = [];
    end
    if isempty(crange)
        notifyPlotChange( handles, 'autoColorRange', get(hObject,'Value') ~= 0 );
    else
        notifyPlotChange( handles, 'autoColorRange', get(hObject,'Value') ~= 0, 'crange', crange );
    end
    
    
function crange = getCrangeFromGUI( handles )
    crange = [];
    [minr,ok1] = getDoubleFromDialog( handles.autoColorRangeMintext );
    [maxr,ok2] = getDoubleFromDialog( handles.autoColorRangeMaxtext );
    if ok1 && ok2
        midstring = get( handles.autoColorRangeMidtext, 'String' );
        if isempty(midstring)
            crange = [ minr, maxr ];
        else
            [midr,ok3] = getDoubleFromDialog( handles.autoColorRangeMidtext );
            if ok3
                crange = [ minr, maxr, midr ];
            end
        end
    end

    
function updateColorRange( handles )
    [minr,ok1] = getDoubleFromDialog( handles.autoColorRangeMintext );
    [maxr,ok2] = getDoubleFromDialog( handles.autoColorRangeMaxtext );
    if ok1 && ok2
        midstring = get( handles.autoColorRangeMidtext, 'String' );
        if isempty(midstring)
            notifyPlotChange( handles, 'crange', [ minr, maxr ] );
        else
            [midr,ok3] = getDoubleFromDialog( handles.autoColorRangeMidtext );
            if ok3
                notifyPlotChange( handles, 'crange', [ minr, maxr, midr ] );
            end
        end
    end


function autoColorRangeMintext_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function autoColorRangeMintext_Callback(hObject, eventdata, handles)
% Plot panel.
    updateColorRange( handles );


function autoColorRangeMaxtext_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function autoColorRangeMaxtext_Callback(hObject, eventdata, handles)
% Plot panel.
    updateColorRange( handles );
    
    
function autoColorRangeMidtext_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function autoColorRangeMidtext_Callback(hObject, eventdata, handles)
    updateColorRange( handles );


% --- Executes on slider movement.
function azimuth_Callback(hObject, eventdata, handles)
    viewScroll_Callback(hObject, eventdata)


function azimuth_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function elevation_Callback(hObject, eventdata, handles)
    viewScroll_Callback(hObject, eventdata)


function elevation_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function roll_Callback(hObject, eventdata, handles)
    viewScroll_Callback(hObject, eventdata)

function roll_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in refinemesh.
function refinemesh_Callback(hObject, eventdata, handles)
    if isempty( handles.mesh )
        fprintf( 1, 'No mesh.\n' );
    else
        refineProportion = get( handles.refinepropslider, 'Value' );
        attemptCommand( handles, false, true, ...
            'refineFEM', 'parameter', refineProportion, 'mode', 'longest' );
    end


% --- Executes on slider movement.
function refinepropslider_Callback(hObject, eventdata, handles)
    handleSliderToText( ...
        handles.refineproptext, ...
        handles.refinepropslider );
    guidata(hObject, handles);


function refinepropslider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function refineproptext_Callback(hObject, eventdata, handles)
    ud = get(handles.refineproptext, 'UserData' );
    handleTextToSlider( ...
        handles.refineproptext, ...
        handles.refinepropslider, ...
        ud);
    guidata(hObject, handles);


function refineproptext_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when mainpanel is resized.
function mainpanel_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to mainpanel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes when GFTwindow is resized.
function GFTwindow_ResizeFcn(hObject, eventdata, handles)
if ~isfield( handles, 'interfacestate' )
    fprintf( 1, 'GFtbox warning: GFTwindow_ResizeFcn called prematurely during startup.\n' );
    return;
end
    standardResize(hObject, handles);
    set( handles.deadcanary, 'Position', [ -10, -10, 1, 1 ] );


% --- Executes on button press in rotateXYZ.
function rotateXYZ_Callback(hObject, eventdata, handles)
    attemptCommand( handles, true, true, ...
        'rotatexyz' );


% --- Executes on button press in allowSplitLongFEM.
function allowSplitLongFEM_Callback(hObject, eventdata, handles)
    meshSetBoolean( handles, 'do_splitlongfem', hObject );


% --- Executes on button press in allowSplitLongFEM.
function allowSplitBentFEM_Callback(hObject, eventdata, handles)
    meshSetBoolean( handles, 'do_splitbentfem', hObject );


% --- Executes on button press in allowSplitBio.
function allowSplitBio_Callback(hObject, eventdata, handles)
    meshSetBoolean( handles, 'do_splitbio', hObject );


% --- Executes on button press in useTensors.
function useGrowthTensors_Callback(hObject, eventdata, handles)
    meshSetBoolean( handles, 'usetensors', hObject );

    
function allowRetriangulate_Callback(hObject, eventdata, handles)
    meshSetBoolean( handles, 'allowElideEdges', hObject );


% --- Executes on button press in allowFlipEdges.
function allowFlipEdges_Callback(hObject, eventdata, handles)
    meshSetBoolean( handles, 'do_flip', hObject );


% --- Executes on button press in snapshot.
function snapshot_Callback(hObject, eventdata, handles)
    if isempty( handles.mesh )
        fprintf( 1, 'No mesh.\n' );
        return;
    end
    attemptCommand( handles, false, false, 'snapshot', '', 'hires', handles.mesh.plotdefaults.hiressnaps );
    handles = guidata( hObject );
    if movieInProgress( handles.mesh )
        % Add frame to movie
        handles.mesh = recordframe( handles.mesh );
        guidata( hObject, handles );
    end


% --------------------------------------------------------------------
function hiresOptionsItem_Callback(hObject, eventdata, handles)
    if ~isempty( handles.mesh )
        handles.mesh = getMovieParams( handles.mesh );
        guidata( hObject, handles );
    end

    
function displayedGrowthMenu_Callback(hObject, eventdata, handles)
    whichMgen = getDisplayedMgenIndex( handles );
    attemptCommand( handles, false, false, ...
        'setproperty', ...
        'displayedGrowth', whichMgen );
    handles = guidata( hObject );
    notifyPlotChange( handles, 'morphogen', whichMgen );
    handles = guidata( hObject );
    setGUIMgenInfo( handles );
    
    set( handles.drawmulticolor, 'Value', false );
    set( handles.inputSelectButton, 'Value', true );
    set( handles.outputSelectButton, 'Value', false );

function generatetype_Callback(hObject, eventdata, handles)
  % fprintf( 1, 'generatetype_Callback\n' );
    global MESH_MENUNAMES;
    meshTypes = MESH_MENUNAMES;
    meshType = meshTypes{get(hObject, 'Value')};
    c = get( handles.newMeshPanel, 'Children' );
    allwidgets = struct();
    for i=1:length(c)
        if strcmp( get(c(i),'Style'), 'edit' )
            t = get( c(i), 'Tag' );
            if regexp( t, '^geomparam' )
                allwidgets.(t) = false;
            end
        end
    end
    setMeshParams( handles, meshType );
    
function setVisWidgets( handles, vis, names, values, allwidgets )
    for i=1:length(vis)
        set( handles.(vis{i}), 'Visible', 'on', 'String', values{i} );
        set( handles.([ vis{i}, 'Text' ]), 'Visible', 'on', 'String', names{i} );
        allwidgets.(vis{i}) = true;
    end
    allnames = fieldnames(allwidgets);
    for i=1:length(allnames)
        if ~allwidgets.(allnames{i})
            set( handles.(allnames{i}), 'Visible', 'off', 'String', '0' );
            set( handles.([ allnames{i}, 'Text' ]), 'Visible', 'off' );
        end
    end


function displayedGrowthMenu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function setDisplayedGrowthMenu( h, g )
%setDisplayedGrowthMenu( h, g )
%   H is the figure handles structure.
%   G is a morphogen name or index, or something else.
%   This routine sets the contents of the displayedGrowthMenu to hold the
%   names of all the morphogens of M, with the one indicated by G selected.
%   If G is not a morphogen name or index, the first morphogen is
%   selected.
    setDisplayedGrowthMenuStrings( h );
    if nargin < 2
        g = 1;
    end
    selectMgenInMenu( h, g );
    setGUIMgenInfo( h );


% --- Executes on button press in allowDilution.
function allowDilution_Callback(hObject, eventdata, handles)
    if isempty( handles.mesh ), return; end
    attemptCommand( handles, false, false, ...
        'mgen_dilution', ...
        getDisplayedMgenIndex( handles ), ...
        get(hObject,'Value') ~= 0 );

    
function radialx_Callback(hObject, eventdata, handles)
% No action.


function radialx_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function radialy_Callback(hObject, eventdata, handles)
% No action.


function radialy_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function radialz_Callback(hObject, eventdata, handles)
% No action.


function radialz_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on mouse press over figure background.
function GFTwindow_ButtonDownFcn(hObject, eventdata, handles)


function maxFEtext_Callback(hObject, eventdata, handles)
    if ~isempty( handles.mesh )
        [maxFEcells,ok] = getIntFromDialog( hObject, 0 );
        if ok
            meshSetProperty( handles, 'maxFEcells', maxFEcells );
        end
    end


function maxFEtext_CreateFcn(hObject, eventdata, handles) %#ok<*INUSD>
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function maxBendtext_Callback(hObject, eventdata, handles)
    if ~isempty( handles.mesh )
        [bendsplit,ok] = getDoubleFromDialog( hObject, 0 );
        if ok
            meshSetProperty( handles, 'bendsplit', bendsplit );
        end
    end


function maxBendtext_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edgesplitscaletext_Callback(hObject, eventdata, handles)
    if ~isempty( handles.mesh )
        [lstp,ok] = getDoubleFromDialog( hObject, 0 );
        if ok
            meshSetProperty( handles, 'longSplitThresholdPower', lstp );
        end
    end


function edgesplitscaletext_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function splitmargintext_Callback(hObject, eventdata, handles)
    if ~isempty( handles.mesh )
        [splitmargin,ok] = getDoubleFromDialog( hObject, 0 );
        if ok
            meshSetProperty( handles, 'splitmargin', splitmargin );
        end
    end

function splitmargintext_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function minpolgradText_Callback(hObject, eventdata, handles)
    if ~isempty( handles.mesh )
        [mpg,ok] = getDoubleFromDialog( hObject, 0 );
        if ok
            needReplot = handles.mesh.plotdefaults.drawgradients;
            attemptCommand( handles, false, needReplot, ...
                'setproperty', 'mingradient', mpg );
        end
    end


function minpolgradText_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function relativepolgrad_Callback(hObject, eventdata, handles)
    meshSetBoolean( handles, 'relativepolgrad', hObject );


function solvertolerance_Callback(hObject, eventdata, handles)
    if ~isempty( handles.mesh )
        [val,ok] = getDoubleFromDialog( hObject, 0 );
        if ok
            meshSetProperty( handles, 'solvertolerance', val );
        end
    end

function solvertolerance_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function diffusionToleranceText_Callback(hObject, eventdata, handles)
    if ~isempty( handles.mesh )
        [val,ok] = getDoubleFromDialog( hObject, 0 );
        if ok
            meshSetProperty( handles, 'diffusiontolerance', val );
        end
    end

function diffusionToleranceText_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function maxsolvetime_Callback(hObject, eventdata, handles)
    if ~isempty( handles.mesh )
        [val,ok] = getDoubleFromDialog( hObject, 0 );
        if ok
            meshSetProperty( handles, 'maxsolvetime', val );
        end
    end

function maxsolvetime_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function maxBioAtext_Callback(hObject, eventdata, handles)
    if ~isempty( handles.mesh )
        [maxBioAcells,ok] = getIntFromDialog( handles.maxBioAtext, 0 );
        if ok
            meshSetProperty( handles, 'maxBioAcells', maxBioAcells );
        end
    end


function maxBioAtext_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function freezeSlider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function freezetext_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function thicknessRB_Callback(hObject, eventdata)
    handles = guidata(hObject);
    if isempty( handles.mesh ), return; end
    selectedButton = get( hObject, 'SelectedObject' );
    buttonName = get( selectedButton, 'String' );
    attemptCommand( handles, false, false, 'setproperty', ...
        'thicknessMode', lower( buttonName ) );

function thicknessButton_Callback(hObject, eventdata, handles)
    if isempty( handles.mesh ), return; end
    [th,ok1] = getDoubleFromDialog( handles.thicknessText );
    [offset,ok2] = getDoubleFromDialog( handles.offsetText );
    if ok1 && ok2 && (th > 0)
        attemptCommand( handles, false, true, 'setthickness', 'thickness', th, 'offset', offset );
    end


function thicknessText_Callback(hObject, eventdata, handles)
    % Nothing to do

function thicknessText_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function offsetText_Callback(hObject, eventdata, handles)
    % Nothing to do

function offsetText_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function mutantslider_Callback(hObject, eventdata, handles)

function mutantslider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function mutanttext_Callback(hObject, eventdata, handles)

function mutanttext_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function revertMutantButton_Callback(hObject, eventdata, handles)
    % Set current mgen mutant level to 1.
    setSliderAndText( handles.mutantslider, 1 );
    if ~isempty( handles.mesh )
        needReplot = plottingMorphogen( handles.mesh );
        attemptCommand( handles, false, needReplot, ...
            'mgen_modulate', ...
            'morphogen', mgenNameFromMgenMenu( handles ), ...
            'mutant', 1 );
    end


function mutantValueCallback( hObject, name, val )
    handles = guidata( hObject );
    if ~isempty( handles.mesh )
        needReplot = plottingMorphogen( handles.mesh );
        attemptCommand( handles, false, needReplot, ...
            'mgen_modulate', ...
            'morphogen', mgenNameFromMgenMenu( handles ), ...
            'mutant', val );
    end

    
% --- Executes on button press in allWildcheckbox.
function allWildcheckbox_Callback(hObject, eventdata, h)
    if ~isempty( h.mesh )
        allWild = getUIFlag( hObject );
        needReplot = plottingMorphogen( h.mesh );
        attemptCommand( h, false, needReplot, 'allowmutant', ~allWild );
        manageMutantControls( h );
    end


% --- Executes on button press in destrain.
function destrain_Callback(hObject, eventdata, handles)
    if ~isempty( handles.mesh )
        plotLabel = getMenuSelectedLabel( handles.newplotQuantityMenu );
        needReplot = strcmp( plotLabel, 'Strain' ) || strcmp( plotLabel, 'Stress' );
        attemptCommand( handles, false, needReplot, 'destrain' );
    end


% --- Executes on button press in flatstrain.
function flatstrain_Callback(hObject, eventdata, handles)
    if ~isempty( handles.mesh )
        plotLabel = getMenuSelectedLabel( handles.newplotQuantityMenu );
        needReplot = strcmp( plotLabel, 'Strain' ) || strcmp( plotLabel, 'Stress' );
        attemptCommand( handles, false, needReplot, 'flatstrain' );
    end
    

function boing()
    volume = 0.5;
    whereami = which('GFtbox');
    homedir = fileparts(whereami);
    if strlexcmp(version('-release'), '2015b') >= 0
        [x,rate] = audioread(fullfile( homedir, 'Boings', 'BONGS_2.wav' ));
    else
        % WAVREAD was removed in version 2015b.
        [x,rate] = wavread(fullfile( homedir, 'Boings', 'BONGS_2.wav' )); %#ok<DWVRD>
    end
    sound(x*volume,rate);
   
function handles = setViewControlMode( handles, mode, on )
    % fprintf( 1, 'setViewControlMode %s %d\n', mode, on );
    ud = get( handles.picture, 'UserData' );
    if on
        ud.dragmode = mode;
    else
        ud.dragmode = 'off';
    end
    set( handles.picture, 'UserData', ud );
    setMouseModeInGUI( handles, mode );
    pan( handles.picture, 'off' );
    rotate3d( handles.picture, 'off' );
    zoom( handles.picture, 'off' );
    
% --- Executes on button press in rotateToggle.
function rotateToggle_Callback(hObject, eventdata, handles)
% Note that we do not use these buttons as toggles, but as radio buttons.
% A click always turns the clicked button on and the others off.
    handles = setViewControlMode( handles, 'rotate', 1 );
    guidata(hObject, handles);

    
function rotuprightToggle_Callback(hObject, eventdata, handles)
% Note that we do not use these buttons as toggles, but as radio buttons.
% A click always turns the clicked button on and the others off.
    handles = setViewControlMode( handles, 'rotupright', 1 );
    guidata(hObject, handles);


% --- Executes on button press in zoomToggle.
function zoomToggle_Callback(hObject, eventdata, handles)
% Note that we do not use these buttons as toggles, but as radio buttons.
% A click always turns the clicked button on and the others off.
    handles = setViewControlMode( handles, 'zoom', 1 );
    guidata(hObject, handles);


% --- Executes on button press in panToggle.
function panToggle_Callback(hObject, eventdata, handles)
% Note that we do not use these buttons as toggles, but as radio buttons.
% A click always turns the clicked button on and the others off.
    handles = setViewControlMode( handles, 'pan', 1 );
    guidata(hObject, handles);

    
function splitMgenButtonGroup_SelectionChangeFcn(hObject, eventdata)
    handles = guidata(hObject);
    if isempty( handles.mesh ), return; end
    
    selectedButton = get( hObject, 'SelectedObject' );
    buttonValue = getGuiItemValue( selectedButton );
    % Find current morphogen.
    % Set the radiobuttons from its interpolation behaviour.
    attemptCommand( handles, false, false, 'mgeninterpolation', ...
        'morphogen', mgenNameFromMgenMenu( handles ), ...
        'interpolation', buttonValue );

    

% --- Executes on button press in splitBioAbutton.
function splitBioAbutton_Callback(hObject, eventdata, handles)
    if ~isempty( handles.mesh ) && hasNonemptySecondLayer( handles.mesh )
        needReplot = handles.mesh.plotdefaults.drawsecondlayer;
        attemptCommand( handles, false, needReplot, 'splitsecondlayer' );
    end


function bioAsplitTypeSelect_SelectionChangeFcn( hObject, eventdata )
    handles = guidata(hObject);
    if isempty( handles.mesh ), return; end
    
    selectedButton = get( hObject, 'SelectedObject' );
    buttonName = get( selectedButton, 'Tag' );
    splitcells = strcmp( buttonName, 'bioAsplitCellsButton' );
    meshSetProperty( handles, 'bioAsplitcells', splitcells );


function allowbiooverlapCheckbox_Callback(hObject, eventdata, handles)
    % Nothing

% --- Executes on button press in allowbiooveredgeCheckbox.
function allowbiooveredgeCheckbox_Callback(hObject, eventdata, handles)
    % Nothing

% --- Executes on button press in bioAfillbutton.
function bioAfillbutton_Callback(hObject, eventdata, handles)
    if isempty( handles.mesh )
        fprintf( 1, 'No mesh.\n' );
        return;
    end
    [numcells,ok1] = getIntFromDialog( handles.actualBioACellstext, 0 );
    [refinement,ok2] = getDoubleFromDialog( handles.bioArefinement );
    if ok1 && ok2
        if numcells < 5
            numcells = 5;
            set( handles.actualBioACellstext, 'String', '5' );
        end
        getBioAColorParams( handles );
        handles = guidata( hObject );
        wasBusy = setGFtboxBusy( handles, true );
        needReplot = handles.mesh.plotdefaults.drawsecondlayer;
        attemptCommand( handles, false, needReplot, ...
            'makesecondlayer', ...
            'mode', 'voronoi', ...
            'numcells', numcells, ...
            'refinement', refinement );
        setGFtboxBusy( handles, wasBusy );
    end


function bioAuniversalbutton_Callback(hObject, eventdata, handles)
    if isempty( handles.mesh )
        fprintf( 1, 'No mesh.\n' );
        return;
    end
    [relarea,ok1] = getDoubleFromDialog( handles.bioArelsizetext );
    [refinement,ok2] = getDoubleFromDialog( handles.bioArefinement );
    if ok1 && ok2
        if relarea <= 0
            relarea = 0.02;
            set( handles.bioArelsizetext, 'String', sprintf('%g',relarea) );
        end
        getBioAColorParams( handles );
        handles = guidata( hObject );
        wasBusy = setGFtboxBusy( handles, true );
        needReplot = handles.mesh.plotdefaults.drawsecondlayer;
        attemptCommand( handles, false, needReplot, ...
            'makesecondlayer', ...
            'mode', 'universal', ...
            'relarea', relarea, ...
            'refinement', refinement );
        setGFtboxBusy( handles, wasBusy );
    end



function [c1,c2,cv] = getBioAColorParams( handles )
    [c1,c2,cv] = bioAColorParams( handles );
    attemptCommand( handles, false, false, ...
        'setsecondlayerparams', ...
        'colors', [c1;c2], 'colorvariation', cv );


function actualBioACellstext_Callback(hObject, eventdata, handles)


function actualBioACellstext_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in bioAscatterbutton.
function bioAscatterbutton_Callback(hObject, eventdata, handles)
    if isempty( handles.mesh )
        fprintf( 1, 'No mesh.\n' );
        return;
    end
    [sides,ok1] = getIntFromDialog( handles.cellSidesText );
    [relsize,ok2] = getDoubleFromDialog( handles.bioArelsizetext );
    [axisratio,ok3] = getDoubleFromDialog( handles.bioAaxisratiotext );
    [numcells,ok4] = getDoubleFromDialog( handles.actualBioACellstext );
    [refinement,ok5] = getDoubleFromDialog( handles.bioArefinement );
    if ok1 && ok2 && ok3 && ok4 && ok5
        [c1,c2,cv] = bioAColorParams( handles );
        wasBusy = setGFtboxBusy( handles, true );
        needReplot = handles.mesh.plotdefaults.drawsecondlayer;
        attemptCommand( handles, false, needReplot, ...
            'makesecondlayer', ...
            'mode', 'each', ...
            'relarea', relsize, ...
            'axisratio', axisratio, ...
            'numcells', numcells, ...
            'sides', sides, ...
            'refinement', refinement, ...
            'allowoverlap', getUIFlag( handles.allowbiooverlapCheckbox ), ...
            'allowoveredge', getUIFlag( handles.allowbiooveredgeCheckbox ), ...
            'colors', [c1;c2], ...
            'colorvariation', cv );
    	setGFtboxBusy( handles, wasBusy );
    end


function bioAGridButton_Callback(hObject, eventdata, handles)


function bioAgridbutton_Callback(hObject, eventdata, handles)
    if isempty( handles.mesh )
        fprintf( 1, 'No mesh.\n' );
        return;
    end
    [relsize,ok1] = getDoubleFromDialog( handles.bioArelsizetext );
    [refinement,ok2] = getDoubleFromDialog( handles.bioArefinement );
    if ok1 && ok2
        [c1,c2,cv] = bioAColorParams( handles );
        wasBusy = setGFtboxBusy( handles, true );
        needReplot = handles.mesh.plotdefaults.drawsecondlayer;
        attemptCommand( handles, false, needReplot, ...
            'makesecondlayer', ...
            'mode', 'grid', ...
            'refinement', refinement, ...
            'relarea', relsize, ...
            'allowoveredge', getUIFlag( handles.allowbiooveredgeCheckbox ), ...
            'colors', [c1;c2], 'colorvariation', cv );
    	setGFtboxBusy( handles, wasBusy );
    end


function cellSidesText_Callback(hObject, eventdata, handles)


function cellSidesText_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function bioArelsizetext_Callback(hObject, eventdata, handles)


function bioArelsizetext_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function bioAaxisratiotext_Callback(hObject, eventdata, handles)


function bioAaxisratiotext_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in bioAsinglebutton.
function bioAsinglebutton_Callback(hObject, eventdata, handles)
    if isempty( handles.mesh )
        fprintf( 1, 'No mesh.\n' );
        return;
    end
    [sides,ok1] = getIntFromDialog( handles.cellSidesText );
    [relsize,ok2] = getDoubleFromDialog( handles.bioArelsizetext );
    [axisratio,ok3] = getDoubleFromDialog( handles.bioAaxisratiotext );
    [refinement,ok4] = getDoubleFromDialog( handles.bioArefinement );
    if ok1 && ok2 && ok3 && ok4
        [c1,c2,cv] = bioAColorParams( handles );
        needReplot = handles.mesh.plotdefaults.drawsecondlayer;
        attemptCommand( handles, false, needReplot, ...
            'makesecondlayer', ...
            'mode', 'single', ...
            'relarea', relsize, ...
            'axisratio', axisratio, ...
            'sides', sides, ...
            'refinement', refinement, ...
            'allowoverlap', getUIFlag( handles.allowbiooverlapCheckbox ), ...
            'allowoveredge', getUIFlag( handles.allowbiooveredgeCheckbox ), ...
            'colors', [c1;c2], 'colorvariation', cv );
    end


function bioArefinement_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function bioArefinement_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in bioArefine.
function bioArefine_Callback(hObject, eventdata, handles)
    if isempty( handles.mesh )
        fprintf( 1, 'No mesh.\n' );
        return;
    end
    [refinement,ok] = getDoubleFromDialog( handles.bioArefinement );
    if ok
        handles = guidata( hObject );
        wasBusy = setGFtboxBusy( handles, true );
        needReplot = handles.mesh.plotdefaults.drawsecondlayer;
        attemptCommand( handles, false, needReplot, ...
            'refinebioedges', ...
            'refinement', refinement );
        setGFtboxBusy( handles, wasBusy );
    end


% --- Executes on button press in bioAdeletebutton.
function bioAdeletebutton_Callback(hObject, eventdata, handles)
    if ~isempty( handles.mesh ) && hasNonemptySecondLayer( handles.mesh )
        needReplot = handles.mesh.plotdefaults.drawsecondlayer;
        attemptCommand( handles, false, needReplot, 'deletesecondlayer' );
    end


% --- Executes on button press in bioAshockbutton.
function bioAshockbutton_Callback(hObject, eventdata, handles)
    if ~isempty( handles.mesh ) && hasNonemptySecondLayer( handles.mesh )
    	shockProportion = get( handles.shockAslider, 'Value' );
        needReplot = handles.mesh.plotdefaults.drawsecondlayer;
        attemptCommand( handles, false, needReplot, ...
            'shockA', shockProportion );
    end

% --- Executes on button press in unshockBioA.
function unshockBioA_Callback(hObject, eventdata, handles)
    if ~isempty( handles.mesh ) && hasNonemptySecondLayer( handles.mesh )
        needReplot = handles.mesh.plotdefaults.drawsecondlayer;
        attemptCommand( handles, false, needReplot, ...
            'unshockA' );
    end

% --- Executes on button press in bioAcolorsButton.
function bioAcolorsButton_Callback(hObject, eventdata, handles)
    if ~isempty( handles.mesh )
        [c1,c2,cv] = getBioAColorParams( handles );
        handles = guidata( hObject );
        needReplot = handles.mesh.plotdefaults.drawsecondlayer && hasNonemptySecondLayer( handles.mesh );
        attemptCommand( handles, false, needReplot, ...
            'colourA', ...
            'colors', [c1;c2], 'colorvariation', cv );
    end

% --- Executes on button press in bioAuniformButton.
function bioAuniformButton_Callback(hObject, eventdata, handles)
    if ~isempty( handles.mesh )
        [c1,c2,~] = getBioAColorParams( handles );
        handles = guidata( hObject );
        needReplot = handles.mesh.plotdefaults.drawsecondlayer && hasNonemptySecondLayer( handles.mesh );
        attemptCommand( handles, false, needReplot, ...
            'colourA', ...
            'colors', [c1;c2], 'colorvariation', 0 );
    end


function bioAlinesizeText_Callback(hObject, eventdata, handles)
%    saveGFtboxConfig( handles );
    [x,ok] = getDoubleFromDialog( hObject );
    if ok && (x >= 0)
        notifyPlotChange( handles, 'bioAlinesize', x );
    end


function bioAlinesizeText_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function bioApointsizeText_Callback(hObject, eventdata, handles)
%    saveGFtboxConfig( handles );
    [x,ok] = getDoubleFromDialog( hObject );
    if ok && (x >= 0)
        notifyPlotChange( handles, 'bioApointsize', x );
    end


function bioApointsizeText_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function GUIformat_Callback(hObject, eventdata, handles)
    % We make the arbitrary choice of the Restart button to communicate to
    % uisetfont the current font settings.
    OldFontDetails = getFontDetails( handles.restartButton );
    FontDetails = uisetfont( OldFontDetails, 'Choose GFtbox Font' );
    if isstruct( FontDetails )
        GFtboxUpdateFonts( FontDetails, handles.GFTwindow, ...
            OldFontDetails );
        handles.fontdetails = FontDetails;
        saveGFtboxConfig( handles );
    end

% --------------------------------------------------------------------
function projectMenu_Callback(hObject, eventdata, handles)
    % Nothing.
    
    
function showProjectFolderItem_Callback(hObject, eventdata, handles)
    if isempty(handles.mesh)
        return;
    end
	if isempty(handles.mesh.globalProps.projectdir)
        complain( 'The mesh has not been saved as a project.\n' );
        return;
	end
    mdir = getModelDir( handles.mesh );
    [s,d] = opendir( mdir );
    if (s ~= 0) && ~isempty(d)
        complain( 'Error %d: %s\n', s, d );
    end


% --- Executes on button press in loadGrowthButton.
function loadGrowthButton_Callback(hObject, eventdata, handles)
    if isempty( handles.mesh )
        errordlg( 'There is no current mesh.', 'Load Growth' )
        return;
    end
    if getUIFlag( handles.runFlag )
        simRunningDialog( 'Cannot load new growth tensors while simulation is in progress.' );
        return;
    end
    startTic = startTimingGFT( handles );
    handles.mesh = leaf_loadgrowth( handles.mesh );
    stopTimingGFT('leaf_loadgrowth',startTic);
%     if handles.mesh.globalProps.targetRelArea > 0
%         setDoubleInTextItem( handles.areaTargetText, handles.mesh.globalProps.targetRelArea );
%     end
    handles = GUIPlotMesh( handles );
    guidata(handles.output, handles);
    

% --- Executes on button press in alwaysFlat.
function alwaysFlat_Callback(hObject, eventdata, handles)
    if ~isempty( handles.mesh )
        val = getUIFlag( handles.twoD );
        attemptCommand( handles, false, val, ...
            'alwaysflat', val );
    end


% --- Executes on button press in twoD.
function twoD_Callback(hObject, eventdata, handles)
    if ~isempty( handles.mesh )
        val = getUIFlag( handles.twoD );
        attemptCommand( handles, false, val, ...
            'twoD', val );
    end

    
function handles = frob5reset( handles )
    handles = safermfield( handles, 'initnodes' );
    handles = safermfield( handles, 'xrectwidth' );
    handles = safermfield( handles, 'yrectwidth' );

    
% --- Executes on button press in frob5button.
function frob5button_Callback(hObject, eventdata, handles)
% Warp the Mona Lisa.
    if isempty( handles.mesh ), return; end
    if 1 || (~isfield(handles, 'mona')) || isempty(handles.mona)
        fprintf( 1, 'Loading Mona Lisa.\n' );
        handles.mona = imread( 'MonaLisa.bmp' );
      % handles.mona( 1:50,1:100,2:3) = 0;  % To show which axis is which
                                            % and what direction it runs.
    end
    if (~isfield(handles,'initnodes')) || isempty(handles.initnodes)
        fprintf( 1, 'Determining size of mesh.\n' );
        handles.initnodes = handles.mesh.nodes;
        for i=1:size(handles.initnodes,1)-1
            if handles.initnodes(i+1,1) < handles.initnodes(i,1)
                handles.xrectwidth = i;
                break;
            end
        end
        handles.yrectwidth = size(handles.initnodes,1)/handles.xrectwidth;
        fprintf( 1, 'xrectwidth %d yrectwidth %d\n', handles.xrectwidth, handles.yrectwidth );
    else
        fprintf( 1, 'xrectwidth %d yrectwidth %d already exist\n', handles.xrectwidth, handles.yrectwidth );
    end
    newnodes = handles.mesh.nodes( 1:size(handles.initnodes,1),: );
    hold on;
    warp( reshape( newnodes(:,1), handles.xrectwidth, handles.yrectwidth )', ...
          reshape( newnodes(:,2), handles.xrectwidth, handles.yrectwidth )', ...
          reshape( newnodes(:,3)+1, handles.xrectwidth, handles.yrectwidth )', ...
          handles.mona );
    hold off;
    guidata(hObject, handles);

    
% --- Executes on button press in plotFlag.
function plotFlag_Callback(hObject, eventdata, handles)

% --- Executes on button press in stopFlag.
function stopFlag_Callback(hObject, eventdata, handles)

% --- Executes on button press in commandFlag.
function commandFlag_Callback(hObject, eventdata, handles)

% --- Executes on button press in runFlag.
function runFlag_Callback(hObject, eventdata, handles)

function meshSetBoolean( handles, name, h )
    if ~isempty(handles.mesh)
        attemptCommand( handles, false, false, ...
            'setproperty', name, get(h,'Value') ~= 0 );
    end
    
function enableInteractionFunction( handles, enable )
    setVisibility( handles.enableIFtext, ~enable );
    if ~isempty(handles.mesh)
        attemptCommand( handles, false, false, ...
            'setproperty', 'allowInteraction', logical(enable) );
    end
    
    
% --------------------------------------------------------------------
function help_Callback(hObject, eventdata, handles)
    % Nothing.

% --------------------------------------------------------------------
function version_Callback(hObject, eventdata, handles)
    % Nothing.

% --- Executes on button press in newMgenButton.
function newMgenButton_Callback(hObject, eventdata, handles)
    if isempty( handles.mesh )
        fprintf( 1, 'No mesh.\n' );
    elseif getUIFlag( handles.runFlag )
        % WARNING: Should ask user.
        complain( 'Cannot create new morphogens while simulation is running.' );
    else
        xx = performRSSSdialogFromFile('newmorphogenslayout.txt', ...
            [], [], @(h)setGFtboxColourScheme( h, handles ) );
        if isempty(xx)
            return;
        end
        mgennames = xx.lb.strings;
        if isempty(mgennames)
            return;
        end
        startTic = startTimingGFT( handles );
        handles.mesh = leaf_add_mgen( handles.mesh, mgennames{:} );
        stopTimingGFT('leaf_add_mgen',startTic);
        setDisplayedGrowthMenu( handles, ...
            handles.mesh.plotdefaults.morphogen );
        handles = GUIPlotMesh( handles );
        guidata(hObject, handles);
    end


% --- Executes on button press in deleteMgenButton.
function deleteMgenButton_Callback(hObject, eventdata, handles)
    if isempty( handles.mesh )
        fprintf( 1, 'No mesh.\n' );
        return;
    end
    
    if getUIFlag( handles.runFlag )
        complain( 'Cannot delete a morphogen while simulation is running.' );
        return;
    end
    
    mgenIndex = getDisplayedMgenIndex( handles );
    if isempty(mgenIndex) || (mgenIndex==0)
        complain( 'No currently selected morphogen.' );
        return;
    end
    
    mgenName = handles.mesh.mgenIndexToName{mgenIndex};
    NUMRESERVEDMGENS = length(handles.mesh.roleNameToMgenIndex);
    
    if mgenIndex <= NUMRESERVEDMGENS
        errordlg( ...
            { [ 'Morphogen ', mgenName, ' is reserved and cannot be deleted.' ] }, ...
            'Delete morphogen' );
        return;
    end
    
    answer = queryDialog( 2, 'Delete morphogen', [ 'Delete morphogen ''', mgenName, '''?' ] );
    if answer ~= 1  % "No"
        return;
    end
    
    oldNumMgens = length( handles.mesh.mgenIndexToName );
    attemptCommand( handles, true, false, 'delete_mgen', mgenName );
    handles = guidata( hObject );
    newNumMgens = length( handles.mesh.mgenIndexToName );
    if newNumMgens < oldNumMgens
        setDisplayedGrowthMenu( handles, ...
            handles.mesh.globalProps.displayedGrowth );
        handles = GUIPlotMesh( handles );
    end
    guidata(hObject, handles);

% --- Executes on button press in renameMgenButton.
function renameMgenButton_Callback(hObject, eventdata, handles)
    if isempty( handles.mesh )
        fprintf( 1, 'No mesh.\n' );
        return;
    end
    if getUIFlag( handles.runFlag )
        % WARNING: Should ask user.
        complain( 'Cannot rename a morphogen while simulation is running.' );
    end
    
    % Find the current morphogen name, and ask for a new one.
    mgenIndex = getDisplayedMgenIndex( handles );
    oldMgenName = handles.mesh.mgenIndexToName{mgenIndex};
    if mgenIndex <= length(handles.mesh.roleNameToMgenIndex)
        errordlg( ...
            { [ 'Morphogen ', oldMgenName, ' is reserved and cannot be renamed.' ] }, ...
            'Rename morphogen' );
        return;
    end
    queryString = sprintf( 'Rename "%s" to:', oldMgenName );
    newMgenName = askForString( 'Rename morphogen', queryString, oldMgenName );

    % Check the response for validity and rename the current morphogen to
    % the new name.
    if ~isempty(newMgenName) && ~strcmp( newMgenName, oldMgenName )
        if isValidMgenName( newMgenName )
            startTic = startTimingGFT( handles );
            handles.mesh = leaf_rename_mgen( handles.mesh, oldMgenName, newMgenName );
            stopTimingGFT('leaf_rename_mgen',startTic);
            setDisplayedGrowthMenuStrings( handles );
            guidata(hObject, handles);
        else
            complain( ...
                '"%s" is not a valid morphogen name. Use letters, digits, and\nunderscore only, beginning with a letter.', ...
                newMgenName );
        end
    end

function simsteps_Callback(hObject, eventdata, handles)
    % No action.

function simsteps_KeyPressFcn(hObject, eventdata, handles)
    if strcmp( eventdata.Key, 'return' )
        drawnow; % Necessary to ensure that we get the current value from hObject, not the previous value.
        run_Callback(hObject, eventdata, handles);
    end

function simtimeText_Callback(hObject, eventdata, handles)
    % No action.

function simtimeText_KeyPressFcn(hObject, eventdata, handles)
    if strcmp( eventdata.Key, 'return' )
        fprintf( 1, '%s: Detected return in simtimeText\n', mfilename() );
        drawnow; % Necessary to ensure that we get the current value from hObject, not the previous value.
        runUntilButton_Callback(hObject, eventdata, handles)
    end

function areaTargetText_Callback(hObject, eventdata, handles)
    % No action.

function areaTargetText_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function areaTargetText_KeyPressFcn(hObject, eventdata, handles)
    if strcmp( eventdata.Key, 'return' )
        fprintf( 1, '%s: Detected return in areaTargetText\n', mfilename() );
        drawnow; % Necessary to ensure that we get the current value from hObject, not the previous value.
        runToButton_Callback(hObject, eventdata, handles);
    end


function announceInteraction( handles )
    if isempty( handles.mesh.globalProps.mgen_interaction )
        set( handles.mgenInteractionName, ...
            'String', '(none)', ...
            'TooltipString', '' );
    else
        set( handles.mgenInteractionName, ...
            'String', handles.mesh.globalProps.mgen_interactionName, ...
            'TooltipString', ...
            fullfile( getModelDir( handles.mesh ), ...
                [ handles.mesh.globalProps.mgen_interactionName, '.m' ] ) );
    end


% --- Executes on button press in editMgenInitfnButton.
function editMgenInitfnButton_Callback(hObject, eventdata, handles)
    fprintf( 1, 'Initialisation function not implemented.\n' );


function rewriteIFButton_Callback(hObject, eventdata, handles)
    if isempty( handles.mesh )
        fprintf( 1, 'No mesh.\n' );
        return;
    end
    if getUIFlag( handles.runFlag )
        complain( 'Cannot rewrite interaction function while the simulation is running.' );
        return;
    end
    wasBusy = setGFtboxBusy( handles, true );
    attemptCommand( handles, false, false, 'rewriteIF', 'force', true );
	setGFtboxBusy( handles, wasBusy );


% --- Executes on button press in editMgenInteractionButton.
function editMgenInteractionButton_Callback(hObject, eventdata, handles)
    if isempty( handles.mesh )
        fprintf( 1, 'No mesh.\n' );
        return;
    end
    if getUIFlag( handles.runFlag )
        complain( 'Cannot edit interaction function while the simulation is running.' );
        return;
    end
    % Note that we do not record this command in the script.
    hadIF = ~isempty( handles.mesh.globalProps.mgen_interaction );
    if ~hadIF && isempty( getModelDir( handles.mesh ) )
        saveProjectAsItem_Callback(hObject, eventdata, handles);
        handles = guidata(hObject);
    end
    startTic = startTimingGFT( handles );
    handles.mesh = leaf_edit_interaction( handles.mesh );
    stopTimingGFT('leaf_edit_interaction',startTic);
    if ~handles.mesh.globalProps.interactionValid
        meshSetProperty( handles, 'do_interaction', 1 )
        handles = guidata(hObject);
    end
    handles = indicateInteractionValidity( handles, true );
    haveIF = ~isempty( handles.mesh.globalProps.mgen_interaction );
    if hadIF ~= haveIF
        announceInteraction( handles );
    end
    guidata(hObject, handles);

function handles = initialiseIF( handles )
    if ~isempty(handles.mesh) ...
           && handles.mesh.globalProps.allowInteraction ...
           && isa(handles.mesh.globalProps.mgen_interaction,'function_handle')
        wasBusy = setGFtboxBusy( handles, true );
        setVisualRunMode( handles, 'running', 'initialiseIFButton' );
        attemptCommand( handles, false, true, 'dointeraction', 1 );
        handles = guidata( handles.output );
        updateGUIFromMesh( handles );
        [handles,ok] = indicateInteractionValidity( handles );
        if ok
            setVisualRunMode( handles, 'completed', 'initialiseIFButton' );
        end
        setGFtboxBusy( handles, wasBusy );
    end

% --- Executes on button press in initialiseIFButton.
function initialiseIFButton_Callback(hObject, eventdata, handles)
    if isempty( handles.mesh )
        fprintf( 1, 'No mesh.\n' );
        return;
    end
    if getUIFlag( handles.runFlag )
        complain( 'Cannot initialise interaction function while the simulation is running.' );
        return;
    end
    handles = initialiseIF( handles );
    guidata( hObject, handles );


function notesButton_Callback(hObject, eventdata, handles)
% Edit the notes file for the project.
    if isempty( handles.mesh )
        fprintf( 1, 'No mesh.\n' );
        return;
    end
    notesname = makeNotesName( handles.mesh );
    if isempty( notesname )
        complain( 'Must save project before creating a notes file.\n' );
        return;
    end
    ok = true;
    if ~exist( notesname, 'file' )
        try
            fid = fopen( notesname, 'w' );
            fclose( fid );
        catch
            complain( 'Cannot create notes file %s.', ...
                notesname );
            ok = false;
        end
    end
    if ok
        try
            edit( notesname );
        catch
            complain( 'Cannot open notes file %s in editor.', ...
                notesname );
        end
    end


% --- Executes on slider movement.
function shockAslider_Callback(hObject, eventdata, handles)


function shockAslider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function shockAtext_Callback(hObject, eventdata, handles)


function shockAtext_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function mouseeditmodeMenu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in fixXbox.
function fixXbox_Callback(hObject, eventdata, handles)
    setFixedMode( handles );


% --- Executes on button press in fixYbox.
function fixYbox_Callback(hObject, eventdata, handles)
    setFixedMode( handles );


% --- Executes on button press in fixZbox.
function fixZbox_Callback(hObject, eventdata, handles)
    setFixedMode( handles );


function handles = setFixedMode( handles )
    handles = establishInteractionMode( handles );
    handles = GUIPlotMesh( handles );
    guidata( handles.output, handles );


% --- Executes on button press in unfixallButton.
function unfixallButton_Callback(hObject, eventdata, handles)
    if ~isempty( handles.mesh )
        handles = ...
            updateSelection( handles, [], [], [], 'replace' );
        guidata( handles.output, handles );
        mousemode = getMouseModeFromGUI( handles );
        if strcmp(mousemode,'mouseeditmodeMenu:Fix nodes')
            attemptCommand( handles, false, true, ...
                'fix_vertex', ...
                'vertex', [], 'dfs', '' );
        else
            attemptCommand( handles, false, true, ...
                'locate_vertex', ...
                'vertex', [], 'dfs', '' );
        end
    end



% --------------------------------------------------------------------
function meshMenu_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function loadMeshFromFile(handles, fileext)
    ok = attemptCommand( handles, true, false, 'load', ['.' fileext] );
    if ok
        finishLoadMesh( handles );
    end

% --------------------------------------------------------------------
function loadmatItem_Callback(hObject, eventdata, handles)
    loadMeshFromFile(handles, 'mat');
%     ok = attemptCommand( handles, true, false, 'load', '.mat', 'interactive', true );
%     if ok
%         finishLoadMesh( handles );
%     end

% --------------------------------------------------------------------
function loadscriptItem_Callback(hObject, eventdata, handles)
    loadMeshFromFile(handles, 'm');
%     ok = attemptCommand( handles, true, false, 'load', '.m', 'interactive', true );
%     if ok
%         finishLoadMesh( handles );
%     end


% --------------------------------------------------------------------
function loadobjItem_Callback(hObject, eventdata, handles)
    loadMeshFromFile(handles, 'obj');
%     ok = attemptCommand( handles, true, false, 'load', '.obj', 'interactive', true );
%     if ok
%         finishLoadMesh( handles );
%     end

% --------------------------------------------------------------------
function loadMSRItem_Callback(hObject, eventdata, handles)
    loadMeshFromFile(handles, 'msr');
%     ok = attemptCommand( handles, true, false, 'load', '.msr', 'interactive', true );
%     if ok
%         finishLoadMesh( handles );
%     end

function finishLoadMesh( handles )
    handles = guidata( handles.output );
    if ~isempty( handles.mesh )
        handles.mesh.pictures = handles.picture;
        updateGUIFromMesh( handles );
        handles = GUIPlotMesh( handles );
        announceSimStatus( handles );
        guidata( handles.output, handles );
    end



% --------------------------------------------------------------------
function savematItem_Callback(hObject, eventdata, handles)
    attemptCommand( handles, true, false, 'saveas', '.mat' );


% --------------------------------------------------------------------
function savescriptItem_Callback(hObject, eventdata, handles)
    attemptCommand( handles, true, false, 'saveas', '.m' );


% --------------------------------------------------------------------
function saveobjItem_Callback(hObject, eventdata, handles)
    attemptCommand( handles, true, false, 'saveas', '.obj' );


% --------------------------------------------------------------------
function savedaeItem_Callback(hObject, eventdata, handles)
    attemptCommand( handles, true, false, 'saveas', '.dae' );


% --------------------------------------------------------------------
function saveMSRItem_Callback(hObject, eventdata, handles)
    attemptCommand( handles, true, false, 'saveas', '.msr' );


function savevrmlItem_Callback(hObject, eventdata, handles)
    attemptCommand( handles, true, false, 'saveas', '.wrl' );


function savestlitem_Callback(hObject, eventdata, handles)
    attemptCommand( handles, true, false, 'saveas', '.stl' );


% --------------------------------------------------------------------
function savefigItem_Callback(hObject, eventdata, handles)
    attemptCommand( handles, true, false, 'saveas', '.fig' );


% --------------------------------------------------------------------
function exportMeshItem_Callback(hObject, eventdata, handles)
    global EXTERNMESH;
    EXTERNMESH = handles.mesh;
    fprintf( 1, 'global EXTERNMESH exported.\n' );


% --------------------------------------------------------------------
function importMeshItem_Callback(hObject, eventdata, handles)
    global EXTERNMESH;
    if isempty( EXTERNMESH ), return; end
    if ~validmesh( EXTERNMESH )
        complain( 'EXTERNMESH is invalid and cannot be imported.' );
        return;
    end
    handles.mesh = EXTERNMESH;
    fprintf( 1, 'EXTERNMESH imported.\n' );
    handles.mesh.pictures = handles.picture;
    handles.mesh = resetInteractionHandle( handles.mesh, 'Reloading interaction function' );
    if ~isfield( handles.mesh, 'meshparams' ) || isempty( handles.mesh.meshparams )
        handles.mesh.meshparams = struct( 'type', 'unknown' );
    end
    updateGUIFromMesh( handles );
    handles = GUIPlotMesh( handles );
    announceSimStatus( handles );
    guidata( handles.output, handles );


% --------------------------------------------------------------------
function meshToVV_Callback(hObject, eventdata, handles)
    if isempty(handles.mesh), return; end
    s = performRSSSdialogFromFile( 'vvparams.txt', ...
            struct( 'numcells', 20, ...
                    'edgedivisions', 4 ), ...
            [], @(h)setGFtboxColourScheme( h, handles ) );

    if ~isempty(s)
      [numcells,ok1] = getDoubleFromString( 'Number of cells', s.numcells, 0 );
      [edgedivisions,ok2] = getDoubleFromString( 'Segments per edge', s.edgedivisions, 0 );
      if ok1 && ok2
          attemptCommand( handles, false, true, ...
                'makeVVlayer', ...
                'numcells', numcells, ...
                'edgedivisions', edgedivisions );
      end
    end

% --------------------------------------------------------------------
function multiplyLayersItem_Callback(hObject, eventdata, handles)
    if ~isempty( handles.mesh )
        % Get an integer.
        [nn,ok] = askForInt( 'Multiply mesh layers', 'Number of layers', 2 );
        if ~ok, return; end
        if nn < 2, return; end
        attemptCommand( handles, true, true, ...
            'multiplylayers', ...
            'layers', nn );
        % [handles.mesh,ok] = leaf_multiplylayers( handles.mesh, 'layers', nn );
    %     if ok
    %         guidata( hObject, handles );
    %     end
    end



% --------------------------------------------------------------------
function rectifyVerticalsNowItem_Callback(hObject, eventdata, handles)
    if ~isempty( handles.mesh )
        attemptCommand( handles, true, true, ...
            'rectifyverticals' );
    end



% --------------------------------------------------------------------
function paramsMenu_Callback(hObject, eventdata, handles)
    % Enable or disable menu items here.

% --------------------------------------------------------------------
function timeunitItem_Callback(hObject, eventdata, handles)
    global gGlobalProps
    if isempty(handles.mesh)
        setGlobals();
        starttime = gGlobalProps.starttime;
        timeunitname = gGlobalProps.timeunitname;
    else
        starttime = handles.mesh.globalProps.starttime;
        timeunitname = handles.mesh.globalProps.timeunitname;
    end
    x = timeunitDlg( ...
        'starttime', starttime, ...
        'timeunitname', timeunitname );
    if isstruct(x)
        [newstarttime,n] = sscanf( x.starttimeText, '%f' );
        if n==0
            complain( 'Invalid time ''%s''. Number expected.', ...
                x.starttimeText );
            return;
        elseif isempty(handles.mesh)
            gGlobalProps.starttime = newstarttime;
            gGlobalProps.timeunitname = x.timeunitText;
        else
            timechange = newstarttime - handles.mesh.globalProps.starttime;
            if (timechange ~= 0) || ~strcmp( x.timeunitText, handles.mesh.globalProps.timeunitname )
                attemptCommand( handles, true, false, ...
                    'setproperty', ...
                    'starttime', newstarttime, ...
                    'currenttime', timechange + handles.mesh.globalDynamicProps.currenttime, ...
                    'timeunitname', x.timeunitText );
            end
        end
    end


% --------------------------------------------------------------------
function distunititem_Callback(hObject, eventdata, handles)
    global gGlobalProps
    if isempty(handles.mesh)
        setGlobals();
        distunitname = gGlobalProps.distunitname;
        scaleunit = gGlobalProps.scalebarvalue;
    else
        distunitname = handles.mesh.globalProps.distunitname;
        scaleunit = handles.mesh.globalProps.scalebarvalue;
    end
    x = distunitDlg( 'distunitname', distunitname, 'scaleunit', scaleunit );
    if isstruct(x)
        [newscaleunit,newscaleunitok] = string2num( x.scaleunitText );
        if isempty(handles.mesh)
            gGlobalProps.distunitname = x.distunitText;
        elseif newscaleunitok
            attemptCommand( handles, true, false, ...
                'setproperty', ...
                'distunitname', x.distunitText, ...
                'scalebarvalue', max(0,newscaleunit) );
            handles = guidata( hObject );
            setscalebarsize( handles );
        else
            attemptCommand( handles, true, false, ...
                'setproperty', ...
                'distunitname', x.distunitText );
            handles = guidata( hObject );
            setscalebarsize( handles );
        end
    end


% --------------------------------------------------------------------
function rescaleItem_Callback(hObject, eventdata, handles)
    global gGlobalProps
    if isempty(handles.mesh)
        setGlobals();
        spaceunitname = gGlobalProps.distunitname;
        timeunitname = gGlobalProps.timeunitname;
    else
        spaceunitname = handles.mesh.globalProps.distunitname;
        timeunitname = handles.mesh.globalProps.timeunitname;
    end
    x = unitsfig( 'spaceunitname', spaceunitname, ...
                  'timeunitname', timeunitname );
    if isstruct(x)
        [timescale,ok1] = getDoubleFromString( 'Time scale', x.timescaleText, 0 );
        [spacescale,ok2] = getDoubleFromString( 'Space scale', x.spacescaleText, 0 );
        if ok1 && ok2
            if isempty(handles.mesh)
                gGlobalProps.distunitname = x.newspaceunitText;
                gGlobalProps.timeunitname = x.newtimeunitText;
            else
                attemptCommand( handles, true, true, ...
                    'rescale', ...
                    'spaceunitname', x.newspaceunitText, ...
                    'spaceunitvalue', spacescale, ...
                    'timeunitname', x.newtimeunitText, ...
                    'timeunitvalue', timescale );
            end
        end
    end


function defaultViewFromCurrentItem_Callback(hObject, eventdata, handles)
    if ~isempty( handles.mesh )
        cp = getCameraParams( handles.picture );
            attemptCommand( handles, true, false, 'setproperty', ...
                'defaultViewParams', cp );
    end

function setDefaultViewItem_Callback(hObject, eventdata, handles)
    if isempty(handles.mesh)
        fprintf( 1, 'No mesh.\n' );
        return;
    end
    az = handles.mesh.globalProps.defaultazimuth;
    el = handles.mesh.globalProps.defaultelevation;
    x = azelDlg( 'azimuth', az, 'elevation', el );
    if isstruct(x)
        [newaz,n1] = sscanf( x.azimuthText, '%f' );
        [newel,n2] = sscanf( x.elevationText, '%f' );
        if n1==0
            complain( 'Invalid azimuth ''%s''. Number expected.', ...
                x.azimuthText );
            return;
        elseif n2==0
            complain( 'Invalid elevation ''%s''. Number expected.', ...
                x.elevationText );
            return;
        elseif (newaz ~= az) || (newel ~= el)
            attemptCommand( handles, true, false, ...
                'setproperty', ...
                'defaultazimuth', newaz, ...
                'defaultelevation', newel );
        end
    end


% --------------------------------------------------------------------
function resetZoomCentreItem_Callback(hObject, eventdata, handles)
    attemptCommand( handles, false, false, ...
                    'resetview' );


% --------------------------------------------------------------------
function autozoomcentreItem_Callback(hObject, eventdata, handles) %#ok<*INUSL>
    newstate = toggleCheckedMenuItem( hObject );
    checkMenuItem( handles.autozoomItem, newstate );
    checkMenuItem( handles.autocentreItem, newstate );
    attemptCommand( handles, false, false, ...
                    'plotoptions', ...
                    'autozoom', newstate, ...
                    'autocentre', newstate );


% --------------------------------------------------------------------
function autozoomItem_Callback(hObject, eventdata, handles)
    newstate = toggleCheckedMenuItem( hObject );
    otherstate = ischeckedMenuItem( handles.autocentreItem );
    checkMenuItem( handles.autozoomcentreItem, newstate && otherstate );
    attemptCommand( handles, false, false, ...
                    'plotoptions', ...
                    'autozoom', newstate );

% --------------------------------------------------------------------
function autocentreItem_Callback(hObject, eventdata, handles)
    newstate = toggleCheckedMenuItem( hObject );
    otherstate = ischeckedMenuItem( handles.autozoomItem );
    checkMenuItem( handles.autozoomcentreItem, newstate && otherstate );
    attemptCommand( handles, false, false, ...
                    'plotoptions', ...
                    'autocentre', newstate );

function unimplementedItem(hObject, eventdata, handles)
    queryDialog( 1, 'Unimplemented', ...
        '"%s" is not yet implemented.', get( hObject, 'Label' ) );

function viewpointdirname = findViewpointDir( handles )
    viewpointdirname = fullfile( handles.userProjectsDir, 'viewpoints' );

% function [olddir,viewpointdirname] = goToViewpointDir( handles )
%     olddir = [];
%     viewpointdirname = findViewpointDir( handles );
%     ok = true;
%     if ~exist( viewpointdirname, 'file' )
%         [ok,msg,msgid] = mkdir( viewpointdirname );
%     end
%     if ok
%         olddir = trycd( viewpointdirname );
%     end
%     if ~ok
%         fprintf( 1, 'Cannot create viewpoints directory %s.\n', viewpointdirname );
%         warning( msgid, msg );
%     elseif isempty( olddir )
%         fprintf( 1, 'Cannot find or create folder %s.\n', ...
%             viewpointdirname );
%         return;
%     end

% --------------------------------------------------------------------
function setViewAngles(handles, azimuth, elevation, roll)
    if isempty( handles.mesh )
        theaxes = handles.picture;
        if ishandle( theaxes )
            ourViewParams = getview( theaxes );
        else
            return;
        end
    else
        ourViewParams = getOurViewParams( handles.mesh );
    end
    
    ourViewParams.azimuth = azimuth;
    ourViewParams.elevation = elevation;
    ourViewParams.roll = roll;
    
    if isempty( handles.mesh )
        setview( theaxes, ourViewParams );
    else
        attemptCommand( handles, false, false, ...
            'plotview', 'ourViewParams', ourViewParams );
        announceview( handles, ...
            ourViewParams.azimuth, ourViewParams.elevation, ourViewParams.roll );
    end


% --------------------------------------------------------------------
function setviewItem_Callback(hObject, eventdata, handles)
    % Get current view angles.
    if isempty( handles.mesh )
        theaxes = handles.picture;
        if ishandle( theaxes )
            [azimuth,elevation,roll] = getview( theaxes );
        else
            return;
        end
    else
        ourViewParams = getOurViewParams( handles.mesh );
        azimuth = ourViewParams.azimuth;
        elevation = ourViewParams.elevation;
        roll = ourViewParams.roll;
    end
    
    % Get new view angles from user.
    s = performRSSSdialogFromFile( 'setview.txt', ...
            struct( 'azimuth', azimuth, ...
                    'elevation', elevation, ...
                    'roll', roll ), ...
            [], @(h)setGFtboxColourScheme( h, handles ) );

    % Install new view angles.
    if ~isempty(s)
        azimuth = sscanf( s.azimuth, '%f' );
        elevation = sscanf( s.elevation, '%f' );
        roll = sscanf( s.roll, '%f' );
        if (numel(azimuth)==1) && (numel(elevation)==1) && (numel(roll)==1)
            setViewAngles(handles, azimuth, elevation, roll);
        end
    end

% --------------------------------------------------------------------
function viewFromPlusZItem_Callback(hObject, eventdata, handles)
    setViewAngles(handles, 0, 90, 0);


function viewFromPlusXItem_Callback(hObject, eventdata, handles)
    setViewAngles(handles, 90, 0, 0);


function viewFromMinusXItem_Callback(hObject, eventdata, handles)
    setViewAngles(handles, -90, 0, 0);


function viewFromPlusYItem_Callback(hObject, eventdata, handles)
    setViewAngles(handles, 180, 0, 0);


function viewFromMinusYItem_Callback(hObject, eventdata, handles)
    setViewAngles(handles, 0, 0, 0);


function viewFromMinusZItem_Callback(hObject, eventdata, handles)
    setViewAngles(handles, 0, -90, 0);


function viewObliqueLeftItem_Callback(hObject, eventdata, handles)
    setViewAngles(handles, -22.5, 25, 0);

function viewObliqueRightItem_Callback(hObject, eventdata, handles)
    setViewAngles(handles, 22.5, 25, 0);

function viewIsometricLeftItem_Callback(hObject, eventdata, handles)
    setViewAngles(handles, -45, atan2(1,sqrt(2))*180/pi, 0);

function viewIsometricRightItem_Callback(hObject, eventdata, handles)
    setViewAngles(handles, 45, atan2(1,sqrt(2))*180/pi, 0);


function saveviewItem_Callback(hObject, eventdata, handles)
    if isempty( handles.mesh )
        return;
    end
    viewpointdirname = findViewpointDir( handles );
    [viewfilename, viewpathname, filterindex] = uiputfile( fullfile(viewpointdirname,'*.mat'), 'Viewpoint file' );
    if ~filterindex
        % User cancelled or viewpoint directory not found.
        return;
    end
    ourViewParams = handles.mesh.plotdefaults.ourViewParams;
    matlabViewParams = handles.mesh.plotdefaults.matlabViewParams;
    save( fullfile( viewpathname, viewfilename ), 'ourViewParams', 'matlabViewParams' );
    fprintf( 1, 'Saved viewpoint as %s in %s.\n', viewfilename, viewpathname );

function loadView( handles, viewfilename )
    x = load( viewfilename );
    haveOurViewParams = isfield( x, 'ourViewParams' );
    haveMatlabViewParams = isfield( x, 'matlabViewParams' );
    if (~haveOurViewParams) && (~haveMatlabViewParams)
        queryDialog( 1, 'File %s does not contain any viewpoints.', viewfilename );
        return;
    end
    plotparams = {};
    if haveOurViewParams
        plotparams = [ plotparams, 'ourViewParams', x.ourViewParams ];
        if ~haveMatlabViewParams
            plotparams = [ plotparams, 'matlabViewParams', cameraParamsFromOurViewParams( x.ourViewParams ) ];
        end
    end
    if haveMatlabViewParams
        plotparams = [ plotparams, 'matlabViewParams', x.matlabViewParams ];
        if ~haveOurViewParams
            plotparams = [ plotparams, 'ourViewParams', ourViewParamsFromCameraParams( x.matlabViewParams ) ];
        end
    end
    attemptCommand( handles, false, false, 'plotview', plotparams{:} );


% --------------------------------------------------------------------
function loadviewItem_Callback(hObject, eventdata, handles)
    if isempty( handles.mesh )
        return;
    end
    
    viewpointdirname = findViewpointDir( handles );
    [viewfilename, viewpathname, filterindex] = uigetfile(fullfile(viewpointdirname,'*.mat'),'Choose a viewpoint file');
    if ~filterindex
        % User cancelled or viewpoint directory not found.
        return;
    end

    loadView( handles, fullfile( viewpathname, viewfilename ) )


% --------------------------------------------------------------------
function useviewItem_Callback(hObject, eventdata, handles)
    

% --------------------------------------------------------------------
function stagesMenu_Callback(hObject, eventdata, handles)

    
% --------------------------------------------------------------------
function movieMenu_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function addFrameItem_Callback(hObject, eventdata, handles)
    if ~isempty( handles.mesh ) && movieInProgress( handles.mesh )
        handles.mesh = recordframe( handles.mesh );
        guidata( hObject, handles );
    end


% --------------------------------------------------------------------
function addMovieFrames(hObject, handles, msg, varargin)
    if ~isempty( handles.mesh )
        frames = getUserdataField( hObject, 'frames', 60 );
        [frames, ok] = askForInt( msg, 'How many frames?', frames );
        if ok
            setUserdataFields( hObject, 'frames', frames );
            attemptCommand( handles, true, false, 'gyrate', ...
                'frames', frames, varargin{:} );
        end
    end

% --------------------------------------------------------------------
function spinItem_Callback(hObject, eventdata, handles)
    if ~isempty( handles.mesh )
        hObject.UserData = defaultFromStruct( ...
            hObject.UserData, ...
            struct( 'frames', 60, ...
                    'cycles', 1, ...
                    'waveangle', 100, ...
                    'tiltangle', 0, ...
                    'rotaxis', 3 ) );
        [ok,result,~] = modalspindialog( hObject.UserData );
        if ok
            if result.dospin
                waveangle = NaN;
                % This is how it is indicated to leaf_gyrate that spinning
                % is required, not oscillation. However, we do not want to
                % replace the oscillation setting in the dialog by NaN.
            else
                waveangle = result.waveangle;
            end
            setUserdataFields( hObject, result );
            attemptCommand( handles, true, false, 'gyrate', ...
                'frames', result.frames, ...
                'spin', result.cycles, ...
                'waveangle', waveangle, ...
                'tilt', result.cycles, ...
                'tiltangle', result.tiltangle, ...
                'rotaxis', result.whichaxis );
        end
    end
%     addMovieFrames( hObject, handles, ...
%         'Spin movie', 'spin', 1, 'waveangle', 100, 'tilt', 0 );

% --------------------------------------------------------------------
function tiltItem_Callback(hObject, eventdata, handles)
    addMovieFrames( hObject, handles, ...
        'Tilt movie', 'spin', 0, 'tilt', 1, 'tiltangle', 89.99 );

% --------------------------------------------------------------------
function gyrateItem_Callback(hObject, eventdata, handles)
    addMovieFrames( hObject, handles, ...
        'Gyrate movie', 'spin', 1, 'tilt', 1, 'tiltangle', 45 );

% --------------------------------------------------------------------
function compressionQualityItem_Callback(hObject, eventdata, handles)
    [quality, ok] = askForInt( 'Set compression quality (0-100)', '', handles.quality );
    if ok
        handles.quality = quality;
        guidata( hObject, handles );
    end


% --------------------------------------------------------------------
function frameRateItem_Callback(hObject, eventdata, handles)
    [fps, ok] = askForInt( 'Set frames per second', '', handles.fps );
    if ok
        handles.fps = fps;
        % set( handles.fpsText, 'String', sprintf( '%d', handles.fps ) );
        guidata( hObject, handles );
    end


% --- Executes on button press in autonamemovie.
% function autonamemovie_Callback(hObject, eventdata, handles)
%     meshSetBoolean( handles, 'autonamemovie', hObject );


% --------------------------------------------------------------------
function thumbnailItem_Callback(hObject, eventdata, handles)
	if ~isempty(handles.mesh) && ~isempty(handles.mesh.globalProps.projectdir)
        attemptCommand( handles, false, false, 'snapshot', '', 'thumbnail', 1 );
        drawThumbnail( handles );
    else
        complain( 'No project.' );
	end


% --------------------------------------------------------------------
function miscMenu_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function aboutMenu_Callback(hObject, eventdata, handles)

function dateItem_Callback(hObject, eventdata, handles)

% % --- Executes on button press in archiveButton.
% function archiveButton_Callback(hObject, eventdata, handles)
% The leaf_archive function is incomplete. DO NOT USE.
%     if ~isempty( handles.mesh )
%         attemptCommand( handles, true, false, 'archive' );
%     end



% --- Executes on button press in asideRButton.
function asideRButton_Callback(hObject, eventdata, handles)
% Plot panel.
    aval = getUIFlag( handles.asideRButton );
    if aval==0
        set( handles.asideRButton, 'Value', 1 );
    else
        set( handles.bsideRButton, 'Value', 0 );
        notifyPlotChange( handles, 'decorateAside', true );
    end

% --- Executes on button press in bsideRButton.
function bsideRButton_Callback(hObject, eventdata, handles)
% Plot panel.
    bval = getUIFlag( handles.bsideRButton );
    if bval==0
        set( handles.bsideRButton, 'Value', 1 );
    else
        set( handles.asideRButton, 'Value', 0 );
        notifyPlotChange( handles, 'decorateAside', false );
    end

function sparsityText_Callback(hObject, eventdata, handles)
% Plot panel.
    [ v, ok1 ] = getDoubleFromDialog( hObject );
    if ok1
        notifyPlotChange( handles, 'sparsedistance', max(v,0) );
    end

function sparsityText_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function multiBrightenText_Callback(hObject, eventdata, handles)
% Plot panel.
    [ v, ok1 ] = getDoubleFromDialog( hObject );
    if ok1
        notifyPlotChange( handles, 'multibrighten', min(max(v,0),1) );
    end

function multiBrightenText_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function totalCellsText_Callback(hObject, eventdata, handles)
    if ~isempty( handles.mesh )
        [totalcells,ok] = getIntFromDialog( handles.totalCellsText, 0 );
        if ok
            attemptCommand( handles, false, false, ...
                'setproperty', 'inittotalcells', totalcells );
        end
    end

function totalCellsText_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in simplifySecondLayerButton.
function simplifySecondLayerButton_Callback(hObject, eventdata, handles)
    if isempty( handles.mesh ), return; end
    if ~hasNonemptySecondLayer( handles.mesh ), return; end
    if getUIFlag( handles.runFlag )
        complain( 'Cannot simplify bio layer while simulation in progress.' );
    end
%     fprintf( 1, 'simplifySecondLayerButton_Callback\n' );
    handles.mesh.secondlayer = deleteBoringCells( handles.mesh.secondlayer, handles.mesh.globalDynamicProps.currenttime );
    handles = GUIPlotMesh( handles );
    announceSimStatus( handles );
    guidata( hObject, handles );


% --- Executes on button press in flipOrientationButton.
function flipOrientationButton_Callback(hObject, eventdata, handles)
    if ~isempty( handles.mesh )
        attemptCommand( handles, false, true, ...
            'fliporientation' );
    end


function setLegendItem_Callback(hObject, eventdata, handles)
    % Bring up a dialog to get a string from the user.
    % Check the string for validity and use it as the format for
    % the legend.
    % Allow a string of the form @asdasd to mean "invoke function asdasd(m)
    % to generate the legend string on each iteration.
    % Or maybe not.  Just have special @ formats to access various
    % properties of the mesh: iterations, morphogen.
    % Can the interaction function invoke GUI commands?  E.g. to display
    % different mesh properties at different times?
    % Maybe this function should just set a static string to be inserted
    % into the legend?
    if ~isempty(handles.mesh)
        x = askForLegendDlg( 'initialvalue', handles.mesh.globalProps.legendTemplate );
        if (~isempty(x)) && isfield( x, 'editableText' )
            attemptCommand( handles, false, false, ...
                'setproperty', 'legendTemplate', x.editableText );
        end
    end

function nodeNumbersItem_Callback(hObject, eventdata, handles)
    notifyPlotChangeShowHide( handles, 'nodenumbering', hObject );

function edgeNumbersItem_Callback(hObject, eventdata, handles)
    notifyPlotChangeShowHide( handles, 'edgenumbering', hObject );

function FENumbersItem_Callback(hObject, eventdata, handles)
    notifyPlotChangeShowHide( handles, 'FEnumbering', hObject );

function staticDecorItem_Callback(hObject, eventdata, handles)
    notifyPlotChangeCheckedMenuItem( handles, 'staticdecor', hObject );
    
% --------------------------------------------------------------------
function canvasColorsItem_Callback(hObject, eventdata, handles)
    % Bring up dialog to select canvas colors.
    if isempty( handles.mesh )
        return;
    end
    facecolor = handles.mesh.plotdefaults.canvascolor;
    edgecolor = handles.mesh.plotdefaults.FElinecolor;
    x = canvasColorsDlg( 'facecolor', facecolor, 'edgecolor', edgecolor );
    if ~isstruct(x)
        return;
    end
    if any( x.facecolor ~= handles.mesh.plotdefaults.canvascolor ) ...
            || any( x.edgecolor ~= handles.mesh.plotdefaults.FElinecolor )
        notifyPlotChange( handles, 'canvascolor', x.facecolor, 'FElinecolor', x.edgecolor );
    end

function replotItem_Callback(hObject, eventdata, handles)
    if ~isempty( handles.mesh )
        % Force a replot from scratch, by deleting all of the graphics
        % handles.
        wasBusy = setGFtboxBusy( handles, true );
        handles.mesh = clearPlotHandles( handles.mesh );
        startTic = startTimingGFT( handles );
        handles.mesh = leaf_plot( handles.mesh );
        stopTimingGFT('leaf_plot',startTic);
        guidata( hObject, handles );
        setGFtboxBusy( handles, wasBusy );
    end

function setSelectedCompressor( codecMenu, codecItem )
    menuItems = get(codecMenu,'Children');
    for i=1:length(menuItems)
        if menuItems(i)==codecItem
            set( menuItems(i), 'Checked', 'on' );
        else
            set( menuItems(i), 'Checked', 'off' );
        end
    end
    
function setNamedCompressor( codecMenu, codecName )
    codecItems = get( codecMenu, 'Children' );
    foundit = false;
    for i=1:length(codecItems)
        if strcmp( codecName, get( codecItems(i), 'Label' ) )
            foundit = true;
            setSelectedCompressor( codecMenu, codecItems(i) );
            break;
        end
    end
    if ~foundit
        fprintf( 1, 'Unknown compressor %s requested.\n', ...
            codecName );
    end
    
function compressorItem_Callback(hObject, eventdata, handles) %#ok<*DEFNU>
    setSelectedCompressor( handles.codecMenu, hObject )
    if isempty( handles.mesh )
        saveGFtboxConfig( handles );
    end

function codecMenu_Callback(hObject, eventdata, handles)
    % Nothing.


function colorVariationText_Callback(hObject, eventdata, handles)
    [colorvariation,ok] = getDoubleFromDialog( hObject );
    if ok
        meshSetProperty( handles, 'colorvariation', colorvariation );
    end

function colorVariationText_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function multiplotItem_Callback(hObject, eventdata, handles)
    if ~isempty(handles.mesh)
        menuindexes = get( handles.displayedGrowthMenu, 'UserData' );
        nummgens = length(handles.mesh.mgenIndexToName);
        menutomesh = zeros( 1, nummgens );
        mgenNames = cell( 1, nummgens );
        for i=1:nummgens
            mname = handles.mesh.mgenIndexToName{i};
            menupos = menuindexes.(mname);
            mgenNames{menupos} = mname;
            menutomesh( menupos ) = i;
        end
        currentmgens = FindMorphogenName( handles.mesh, ...
                            handles.mesh.plotdefaults.defaultmultiplottissue );
        
        x = multiplotDlg( 'morphogens', mgenNames, ...
                          'selected', currentmgens );
        if isstruct(x)
            selectedmgens = FindMorphogenName( handles.mesh, menutomesh( x.mgenListbox.values ) );
            attemptCommand( handles, false, false, ...
                'plotoptions', ...
                'morphogen', selectedmgens, ...
                'defaultmultiplottissue', selectedmgens );
%             set( handles.drawmulticolor, ...
%                 'Value', true, ...
%                 'Userdata', struct( 'morphogens', selectedmgens ) );
            handles = guidata( hObject );
            set( handles.inputSelectButton, 'Value', true );
            set( handles.drawmulticolor, 'Value', true );
            plotMgensFromGUI( handles );
        end
    end


function multiplotcellsItem_Callback(hObject, eventdata, handles)
    if ~isempty(handles.mesh) && ~isempty( handles.mesh.secondlayer.cellvalues )
%         menuindexes = get( handles.displayedCellMgenMenu, 'UserData' );
%         numcfs = length(handles.mesh.secondlayer.valuedict.index2NameMap);
%         menutomesh = zeros( 1, numcfs );
        cfnames = get( handles.displayedCellMgenMenu, 'String' );
        if ischar(cfnames)
            cfnames = {cfnames};
        end
%         for i=1:numcfs
%             mname = handles.mesh.secondlayer.valuedict.index2NameMap{i};
%             menupos = menuindexes.(mname);
%             cfnames{menupos} = mname;
%             menutomesh( menupos ) = i;
%         end
        currentmgens = FindCellFactorName( handles.mesh, ...
                            handles.mesh.plotdefaults.defaultmultiplotcells );
        
        x = multiplotDlg( 'morphogens', cfnames, ...
                          'selected', currentmgens );
        if isstruct(x)
            selectedcfs = cfnames( x.mgenListbox.values );
            attemptCommand( handles, false, false, ...
                'plotoptions', ...
                'cellbodyvalue', selectedcfs, ...
                'defaultmultiplotcells', selectedcfs );
            handles = guidata( hObject );
            set( handles.cellMgenSelectButton, 'Value', true );
            plotCellFactorsFromGUI( handles );
        end
    end



function stripsaveItem_Callback(hObject, eventdata, handles)
    toggleCheckedMenuItem( hObject );

function validateMeshItem_Callback(hObject, eventdata, handles)
    if ~isempty(handles.mesh)
        [result,handles.mesh] = validmesh( handles.mesh, true );
        guidata( hObject, handles );
        if result
            fprintf( 1, 'Mesh is ok.\n' );
            queryDialog( 1, 'Note', 'Mesh is ok.' );
        else
            fprintf( 1, 'Mesh has problems.\n' );
            beep;
            queryDialog( 1, 'Warning', 'Mesh is in an invalid state. See command window for details.' );
        end
    end

function useprevdispItem_Callback(hObject, eventdata, handles)
    toggleCheckedMenuItem( hObject );
    usePrevDispAsEstimate = ischeckedMenuItem(hObject);
    meshSetProperty( handles, ...
        'usePrevDispAsEstimate', usePrevDispAsEstimate );

function tensorPropertyMenu_Callback(hObject, eventdata, handles)
    notifyPlotChange( handles, ...
        'outputaxes', lower(unspace(getMenuSelectedLabel( handles.tensorPropertyMenu ))) );
    handles = guidata( hObject );
    setMyLegend( handles.mesh );

function tensorPropertyMenu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function rotateMeshButton_Callback(hObject, eventdata, handles)
    if ~isempty(handles.mesh)
        angle = get( handles.rotateslider, 'Value' );
        if hObject==handles.rotateNegMeshButton
            angle = -angle;
        end
        if getUIFlag( handles.rotateXButton )
            ax = 'X';
        elseif getUIFlag( handles.rotateYButton )
            ax = 'Y';
        elseif getUIFlag( handles.rotateZButton )
            ax = 'Z';
        else
            return;
        end
        attemptCommand( handles, true, true, ...
            'rotate', ax, angle );
    end

function rotateXButton_Callback(hObject, eventdata, handles)
    set( handles.rotateYButton, 'Value', 0 );
    set( handles.rotateZButton, 'Value', 0 );


function rotateYButton_Callback(hObject, eventdata, handles)
    set( handles.rotateXButton, 'Value', 0 );
    set( handles.rotateZButton, 'Value', 0 );


function rotateZButton_Callback(hObject, eventdata, handles)
    set( handles.rotateXButton, 'Value', 0 );
    set( handles.rotateYButton, 'Value', 0 );


function XrotateSlider_Callback(hObject, eventdata, handles)
    fprintf( 1, 'XrotateSlider_Callback h %f\n', hObject );
    get( hObject )


function rotateslider_Callback(hObject, eventdata, handles)


function rotateslider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function rotatetext_Callback(hObject, eventdata, handles)


function rotatetext_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function emptyCallback(hObject, eventdata, handles)

function dissectButton_Callback(hObject, eventdata, handles)
    if ~isempty(handles.mesh)
        wasBusy = setGFtboxBusy( handles, true );
        attemptCommand( handles, true, true, ...
            'dissect' );
        setGFtboxBusy( handles, wasBusy );
    end


function explodeButton_Callback(hObject, eventdata, handles)
    if ~isempty(handles.mesh)
        attemptCommand( handles, true, true, ...
            'explode', 1 );
    end


function flattenButton_Callback(hObject, eventdata, handles)
    if ~isempty(handles.mesh)
        attemptCommand( handles, true, true, ...
            'flatten', 'interactive', true );
    end


% --------------------------------------------------------------------
function RecordMeshes_Callback(hObject, eventdata, handles)
% hObject    handle to RecordMeshes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    if strcmp(get(hObject,'Checked'),'off')
        set(hObject,'Checked','on');
        if ~isempty(handles.mesh)
            handles.mesh.globalProps.RecordMeshes.flag=true;
            handles.mesh.globalProps.RecordMeshes.saveframe=false;
        end
    else
        set(hObject,'Checked','off');
        if ~isempty(handles.mesh)
            handles.mesh.globalProps.RecordMeshes.flag=false;
            handles.mesh.globalProps.RecordMeshes.saveframe=false;
        end
    end
    guidata( handles.output, handles );


function allowNegativeGrowth_Callback(hObject, eventdata, handles)
    allowNeg = get(hObject,'Value')==1;
    meshSetProperty( handles, ...
        'allowNegativeGrowth', allowNeg );
    if ~isempty(handles.mesh)
        handles = guidata( hObject );
        handles.mesh = disallowNegativeGrowth( handles.mesh );
        handles = GUIPlotMesh( handles );
        guidata( hObject, handles );
    end

function usefrozengradient_Callback(hObject, eventdata, handles)
    meshSetProperty( handles, ...
        'usefrozengradient', get(hObject,'Value')==1 );
    handles = guidata( hObject );
    if handles.mesh.plotdefaults.drawgradients
        notifyPlotChange( handles );  % Need to revisit this.  This doesn't change any plot options, but
                                      % still needs a replot.
    end


function addProjectsFolderItem_Callback(hObject, eventdata, handles)
    projectsdir = uigetdir( handles.userProjectsDir, 'Select or create a projects folder:' );
    if projectsdir ~= 0
        wasBusy = setGFtboxBusy( handles, true );
        % Search for the new directory in the list of projects directories.
        dirindex = 0;
        for i=1:length( handles.userProjectsDirs )
            if strcmp( handles.userProjectsDirs{i}, projectsdir )
                dirindex = i;
                break;
            end
        end
        % Add the new directory to the list of projects directories if it
        % is not already there.
        if dirindex==0
            handles.userProjectsDirs{ end+1 } = projectsdir;
            handles = addProjectsMenu( handles, projectsdir, false, @projectMenuItemCallback );
        end
        % Add the new menu.
        handles = addProjectsMenu( handles, projectsdir, false, @projectMenuItemCallback );
        handles = selectDefaultProjectsMenu( handles, projectsdir );
        % Clean up.
        saveGFtboxConfig( handles );
        guidata( hObject, handles );
        setGFtboxBusy( handles, wasBusy );
    end


% --------------------------------------------------------------------
function Font_Size_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function plotMenu_Callback(hObject, eventdata, handles)
%     % Find viewpoint files in the viewpoints directory.
%     % Enter them in the submenu of useviewItem.
%     % Give each a callback.
% 
%     % Get dir listing of viewpoints directory.
%     viewpointdirname = findViewpointDir( handles );
%     x = dirnames( fullfile( viewpointdirname, '*.mat' ) );
%     uh = handles.useviewItem;
%     delete( get( uh, 'Children' ) );
%     if isempty(x)
%             uimenu( 'Parent', uh, ...
%                     'Label', 'None', ...
%                     'Callback', [], ...
%                     'Enable', 'off' );
%     else
%         for i=1:length(x)
%             label = regexprep( x{i}, '\.mat$', '' );
%             uimenu( 'Parent', uh, ...
%                     'Label', label, ...
%                     'Callback', @loadoneviewItem_Callback );
%         end
%     end

function loadoneviewItem_Callback(hObject, eventdata)
    handles = guidata( hObject );
    fprintf( 1, 'loadoneviewItem_Callback: %s\n', get( hObject, 'Label' ) );
    viewpointdirname = findViewpointDir( handles );
    loadView( handles, fullfile( viewpointdirname, [ get( hObject, 'Label' ), '.mat' ] ) );

% --------------------------------------------------------------------
function makefigItem_Callback(hObject, eventdata, handles)
    if isempty( handles.mesh ) || isempty( handles.mesh.globalProps.projectdir )
        complain( 'No project.' );
    else
        modeldir = fullfile( handles.mesh.globalProps.projectdir, ...
                             handles.mesh.globalProps.modelname );
        try
            makefig( modeldir );
        catch me
            s = sprintf( 'makefig failed:\n%s', me.message );
            msgbox( s );
        end
    end


% --------------------------------------------------------------------
function blackMenuItem_Callback(hObject, eventdata, handles)
    if ~ischeckedMenuItem( hObject )
        setPlotBackground( handles, [0 0 0] );
        checkMenuItem( handles.blackMenuItem, true );
        checkMenuItem( handles.whiteMenuItem, false );
    end

% --------------------------------------------------------------------
function whiteMenuItem_Callback(hObject, eventdata, handles)
    if ~ischeckedMenuItem( hObject )
        setPlotBackground( handles, [1 1 1] );
        checkMenuItem( handles.blackMenuItem, false );
        checkMenuItem( handles.whiteMenuItem, true );
    end

% --------------------------------------------------------------------
function legendMenuItem_Callback(hObject, eventdata, handles)
    visible = toggleShowHideMenuItem( hObject );
    set( handles.legend, 'Visible', boolchar( visible, 'on', 'off' ) );
    attemptCommand( handles, false, false, ...
        'plotoptions', 'drawlegend', visible );

function scalebarMenuItem_Callback(hObject, eventdata, handles)
    visible = toggleShowHideMenuItem( hObject );
    attemptCommand( handles, false, false, ...
        'plotoptions', ...
        'drawscalebar', visible );
%     set( handles.scalebar, 'Visible', boolchar( visible, 'on', 'off' ) );

function scalebarscaleItem_Callback(hObject, eventdata, handles)
    % Get a scaling factor from the user.
    % Set the corresponding property in plotdefaults.scalebarscaling.
    
    % NOT IMPLEMENTED?


% --------------------------------------------------------------------
% --------------------------------------------------------------------
function showmeshMenuItem_Callback(hObject, eventdata, handles)
    notifyPlotChangeShowHide( handles, 'drawleaf', hObject );

function thicknessMenuItem_Callback(hObject, eventdata, handles)
    notifyPlotChangeShowHide( handles, 'thick', hObject );

function seamsMenuItem_Callback(hObject, eventdata, handles)
    notifyPlotChangeShowHide( handles, 'drawseams', hObject );

function vvMenuItem_Callback(hObject, eventdata, handles)
    notifyPlotChangeShowHide( handles, 'drawvvlayer', hObject );

function cellsonbothsidesItem_Callback(hObject, eventdata, handles)
    notifyPlotChangeCheckedMenuItem( handles, 'cellsonbothsides', hObject );

function alwaysRectifyVerticalsItem_Callback(hObject, eventdata, handles)
    toggleCheckedMenuItem( hObject );
    meshSetProperty( handles, 'rectifyverticals', ischeckedMenuItem( hObject ) );

function staticReadOnlyItem_Callback(hObject, eventdata, handles)
    toggleCheckedMenuItem( hObject );
    meshSetProperty( handles, 'staticreadonly', ischeckedMenuItem( hObject ) );

function allowSparseItem_Callback(hObject, eventdata, handles)
    toggleCheckedMenuItem( hObject );
    meshSetProperty( handles, 'allowsparse', ischeckedMenuItem( hObject ) );


function inputSelectButton_Callback(hObject, eventdata, handles)
    selectButton( handles.inputSelectButton, handles.outputSelectButton );
    plotMgensFromGUI( handles );


% --- Executes on button press in outputSelectButton.
function outputSelectButton_Callback(hObject, eventdata, handles)
    selectButton( handles.outputSelectButton, handles.inputSelectButton );
    if getUIFlag( hObject )
        oq = plottedOutputQuantity( handles );
        notifyPlotChange( handles, 'outputquantity', oq );
    else
        notifyPlotChange( handles, 'blank', true );
    end
    handles = guidata( hObject );
    setMyLegend( handles.mesh );

% --------------------------------------------------------------------
function axesMenuItem_Callback(hObject, eventdata, handles)
    axeson = toggleShowHideMenuItem( hObject );
    if isempty( handles.mesh )
        if axeson
            axis( handles.picture, 'on' );
        else
            axis( handles.picture, 'off' );
        end
    else
        attemptCommand( handles, false, false, ...
            'showaxes', axeson );
    end

% --------------------------------------------------------------------
function colorbarMenuItem_Callback(hObject, eventdata, handles)
    colorbaron = toggleShowHideMenuItem( hObject );
    attemptCommand( handles, false, false, ...
        'plotoptions', ...
        'drawcolorbar', colorbaron );

% --------------------------------------------------------------------
function displacementsMenuItem_Callback(hObject, eventdata, handles)
    notifyPlotChangeShowHide( handles, 'drawdisplacements', hObject );

% --------------------------------------------------------------------
function normalsMenuItem_Callback(hObject, eventdata, handles)
    notifyPlotChangeShowHide( handles, 'drawnormals', hObject );

function lightMenuItem_Callback(hObject, eventdata, handles)
    label = get( hObject, 'Label' );
    turnLightOn = strcmp( label, 'Turn Light On' );
    if turnLightOn
        set( hObject, 'Label', 'Turn Light Off' );
    else
        set( hObject, 'Label', 'Turn Light On' );
    end
    attemptCommand( handles, false, false, ...
        'light', ...
        turnLightOn );

function opacityItem_Callback(hObject, eventdata, handles)
    getplotparamfloat( hObject, handles, ...
                       'Set opacity of mesh', ...
                       'Allowed range 0 (transparent) to 1 (opaque)', ...
                       [0 1], ...
                       'FaceAlpha', ...
                       'alpha' );
    
function ambientItem_Callback(hObject, eventdata, handles)
    getplotparamfloat( hObject, handles, ...
                       'Set ambient light level', ...
                       'Allowed range 0 to 1', ...
                       [0 1], ...
                       'AmbientStrength', ...
                       'ambientstrength' );

function [x,ok] = getplotparamfloat( hObject, handles, ...
                                     dlgtitle, dlgprompt, bounds,  ...
                                     plotattribute, ...
                                     meshparamname )
    ud = get( hObject, 'UserData' );
    [x,ok] = askForFloat( dlgtitle, dlgprompt, ud.currentvalue, bounds );
    if ~ok
        return;
    end
    if ud.currentvalue == x
        return;
    end
    ud.currentvalue = x;
    set( hObject, 'UserData', ud );
    if ~ok
        return;
    end
    if getUIFlag( handles.runFlag )
        setPatchProperty( handles.picture, plotattribute, x );
        if ~isempty( handles.mesh )
            handles.mesh.plotdefaults.(meshparamname) = x;
            guidata( hObject, handles );
            saveStaticPart( handles.mesh );
        end
    else
        notifyPlotChange( handles, meshparamname, ud.currentvalue );
    end

function setPatchProperty( ax, propname, propval )
    c = get( ax, 'Children' );
    pc = strcmp( get(c,'Type'), 'patch');
    try
        set( c(pc), propname, propval );
    catch
        x = 1; %#ok<NASGU>
    end

function stereoItem_Callback(hObject, eventdata, handles)
    queryDialog( 1, 'Note', 'Stereo is not yet supported.' );
    return;
    if ~isfield( handles, 'stereoparams' ) %#ok<UNRCH>
      % handles.stereoparams = struct( 'offset');
    end
  % x = stereoParamsDlg( handles.stereoparams )
    x = stereoParamsDlg()
    if (~isstruct(x)) && (x == -1)
        % User cancelled.
        return;
    end
    x = safermfield( x, 'cancelButton', 'okButton' )
    %{
x has these fields:
    enableStereoCheckbox: 1
        screensizeToggle: 0
        imageSpacingText: '1024'
            vergenceText: '2.5'
               direction: '+h'
    %}
    if x.enableStereoCheckbox
        if ~isfield( handles, 'secondfigure' )
        else
        end
        % if second figure not present
        %   Create it.
        %   Copy main plot to second.
        % 	Adjust view directions.
        % else
        %   if vergence was changed then adjust view directions.
    else
        % if second figure present
        %   Destroy it.
        if isfield( handles, 'secondfigure' )
            if ishandle( handles.secondfigure )
                delete( handles.secondfigure );
            end
            handles = rmfield( handles, 'secondfigure' );
        end
    end
    handles.stereoparams = x;
    guidata( hObject, handles );


function azclipText_Callback(hObject, eventdata, handles)
% Plot panel.
    [ v, ok1 ] = getDoubleFromDialog( hObject );
    if ok1
        notifyPlotChange( handles, 'clippingAzimuth', v );
    end

function azclipText_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function elclipText_Callback(hObject, eventdata, handles)
% Plot panel.
    [ v, ok1 ] = getDoubleFromDialog( hObject );
    if ok1
        notifyPlotChange( handles, 'clippingElevation', v );
    end

function elclipText_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function dclipText_Callback(hObject, eventdata, handles)
% Plot panel.
    [ v, ok1 ] = getDoubleFromDialog( hObject );
    if ok1
        notifyPlotChange( handles, 'clippingDistance', v );
    end

function sclipText_Callback(hObject, eventdata, handles)

function dclipText_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function tclipText_Callback(hObject, eventdata, handles)
% Plot panel.
    [ v, ok1 ] = getDoubleFromDialog( hObject );
    if ok1
        notifyPlotChange( handles, 'clippingThickness', v );
    end

function tclipText_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function clipCheckbox_Callback(hObject, eventdata, handles)
% Plot panel.
    notifyPlotChangeFromGUIBool( handles, 'doclip', hObject )

function clipbymgenCheckbox_Callback(hObject, eventdata, handles)
% Plot panel.
    notifyPlotChangeFromGUIBool( handles, 'clipbymgen', hObject )

function clipmgenButton_Callback(hObject, eventdata, handles)
% Plot panel.
    if ~isempty(handles.mesh)
        handles.mesh.plotdefaults.clipmgens = intersect( handles.mesh.plotdefaults.clipmgens, handles.mesh.mgenIndexToName );
        clipmgens = zeros(1,length(handles.mesh.plotdefaults.clipmgens));
        for i=1:length(handles.mesh.plotdefaults.clipmgens)
            clipmgens(i) = handles.mesh.mgenNameToIndex.(handles.mesh.plotdefaults.clipmgens{i});
        end
        clipmgens = unique(clipmgens);
        [sortedMgenNames,ia,ic] = unique( handles.mesh.mgenIndexToName );
        clipmgensSorted = ic( clipmgens );
        
        initparams = safemakestruct( '', ...
            { 'clipmgens', clipmgensSorted, ...
            'above', handles.mesh.plotdefaults.clipmgenabove, ...
            'all', handles.mesh.plotdefaults.clipmgenall, ...
            'threshold', handles.mesh.plotdefaults.clipmgenthreshold, ...
            'allmgens', upper( sortedMgenNames ) } );
        result = clipmgenDlg( 'INITPARAMS', initparams );
        if isstruct(result)
            replot = handles.mesh.plotdefaults.clipbymgen;
            attemptCommand( handles, false, replot, ...
                'plotoptions', ...
                'clipmgens', handles.mesh.mgenIndexToName( ia(result.mgens) ), ...
                'clipmgenthreshold', result.threshold, ...
                'clipmgenabove', result.above, ...
                'clipmgenall', result.all );
        end
    end
    
function projectsMenu_Callback(hObject, eventdata, handles)
    % Nothing.

function refreshProjectsMenu_Callback(hObject, eventdata, handles)
    handles = refreshProjectsMenu( guidata(hObject) );
    guidata( hObject, handles );

function flatlightMenuItem_Callback(hObject, eventdata, handles)
    setLightMode(hObject, handles);

function gouraudMenuItem_Callback(hObject, eventdata, handles)
    setLightMode(hObject, handles);

function phongMenuItem_Callback(hObject, eventdata, handles)
    setLightMode(hObject, handles);

function setLightMode(hObject, handles)
    % Light mode does not work.
    %{
    c = get( handles.lightmodeMenu, 'Children' );
    for i=1:length(c)
        if c(i)==hObject
            set( c(i), 'Checked', 'on' );
        else
            set( c(i), 'Checked', 'off' );
        end
    end
    notifyPlotChange( handles, 'lightmode', lower( get( c(i), 'Label' ) ) );
    %}

% --------------------------------------------------------------------
function precisionItem_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function singlePrecisionItem_Callback(hObject, eventdata, handles)
    selectMenuChoice( hObject );
    meshSetProperty( handles, 'solverprecision', 'single' );


% --------------------------------------------------------------------
function doublePrecisionItem_Callback(hObject, eventdata, handles)
    selectMenuChoice( hObject );
    meshSetProperty( handles, 'solverprecision', 'double' );


% --------------------------------------------------------------------
function solverItem_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function cgsSolverItem_Callback(hObject, eventdata, handles)
    selectMenuChoice( hObject );
    meshSetProperty( handles, 'solver', 'cgs' );


% --------------------------------------------------------------------
function lsqrSolverItem_Callback(hObject, eventdata, handles)
    selectMenuChoice( hObject );
    meshSetProperty( handles, 'solver', 'lsqr' );


% --------------------------------------------------------------------
function culaSgesvSolverItem_Callback(hObject, eventdata, handles)
    selectMenuChoice( hObject );
    meshSetProperty( handles, 'solver', 'culaSgesv' );



% --------------------------------------------------------------------
function errorTypeMenu_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function normErrorItem_Callback(hObject, eventdata, handles)
    checkErrorItems( handles, true );
    meshSetProperty( handles, 'solvertolerancemethod', 'norm' );

% --------------------------------------------------------------------
function maxabsErrorItem_Callback(hObject, eventdata, handles)
    checkErrorItems( handles, false );
    meshSetProperty( handles, 'solvertolerancemethod', 'max' );


function makecaptionItem_Callback(hObject, eventdata, handles)
    queryDialog( 1, 'Caption', 'Caption generation has not been implemented yet.' );
    if ~isempty( handles.mesh )
        
    end

function purgeProjectItem_Callback(hObject, eventdata, handles)
    attemptCommand( handles, true, false, ...
                    'purgeproject', ...
                    'recycle', true, ...
                    'confirm', true );

            

    
% function mh = findSelectedProjectMenuItem( menus, dir, mh )
%     if isempty(dir)
%         return;
%     end
%     if nargin < 3
%         mh = [];
%     end
%     for i=1:length(menus)
%         ud = get( menus(i), 'UserData' );
%         if isempty( ud ), continue; end
%         if ~isfield( ud, 'modeldir' ), continue; end
%         if ~isAncestorDirOf( ud.modeldir, dir ), continue; end
%         % Checkmarks don't work for submenus, only menu items.
%         mh = menus(i);
%         mh1 = findSelectedProjectMenuItem( get( menus(i), 'Children' ), dir );
%         if ~isempty( mh1 )
%             mh = mh1;
%             return;
%         end
%     end


    
% --------------------------------------------------------------------
function movieAllStagesItem_Callback(hObject, eventdata, handles)
    movieSomeStagesItem(false, handles);


% --------------------------------------------------------------------
function movieStagesItem_Callback(hObject, eventdata, handles)
    movieSomeStagesItem(true, handles);



% --------------------------------------------------------------------
function movieSomeStagesItem(askForStages, handles)
    if askForStages
        result = performRSSSdialogFromFile( 'moviefromstages.txt', [], [], @(h)setGFtboxColourScheme( h, handles ) );
        if isempty(result)
            % User cancelled.
            return;
        end
        if isempty(result.starttime)
            starttime = -Inf;
        else
            [starttime,~,errmsg,~] = sscanf( result.starttime, '%f' );
            if ~isempty(errmsg)
                complain( 'Bad format for start time, number expected, found "%s".\n', result.starttime );
                return;
            end
        end
        if isempty(result.endtime)
            endtime = -Inf;
        else
            [endtime,~,errmsg,~] = sscanf( result.endtime, '%f' );
            if ~isempty(errmsg)
                complain( 'Bad format for end time, number expected, found "%s".\n', result.endtime );
                return;
            end
        end
    else
        starttime = -Inf;
        endtime = Inf;
    end
    
    attemptCommand( handles, true, false, ...
        'stagesmovie', ...
        'start', starttime, ...
        'end', endtime, ...
        'fps', handles.fps, ...
        'quality', handles.quality, ...
        'compression', getSelectedCompressor( handles.codecMenu ) );



% --------------------------------------------------------------------
function editMovieScriptsItem_Callback(hObject, eventdata, handles)
    queryDialog( 1, 'Not Implemented', 'Movie scripts are not yet implemented.' );


% --------------------------------------------------------------------
function newWaypointItem_Callback(hObject, eventdata, handles)
    queryDialog( 1, 'Not Implemented', 'Movie scripts are not yet implemented.' );




% --------------------------------------------------------------------
function rendererMenu_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function checkRendererItemFromName( handles )
    renderers = get( handles.rendererMenu, 'Children' );
    for i=1:length(renderers)
        checkMenuItem( renderers(i), ...
            strcmp( get( renderers(i), 'Label' ), handles.Renderer ) );
    end


% --------------------------------------------------------------------
function setRendererItem(hObject, handles)
    global GFtboxFigure
    handles.Renderer = get( hObject, 'Label' );
    set( GFtboxFigure, 'Renderer', handles.Renderer );
    fprintf( 1, 'Rendering method is "%s".\n', get( GFtboxFigure, 'Renderer' ) );
    renderers = get( get( hObject, 'Parent' ), 'Children' );
    for i=1:length(renderers)
        checkMenuItem( renderers(i), renderers(i)==hObject );
    end
    guidata( hObject, handles );


% --------------------------------------------------------------------
function openGLRendererItem_Callback(hObject, eventdata, handles)
% hObject    handle to openGLRendererItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    setRendererItem(hObject, handles);


% --------------------------------------------------------------------
function zbuggerRendererItem_Callback(hObject, eventdata, handles)
    setRendererItem(hObject, handles);


% --------------------------------------------------------------------
function paintersRendererItem_Callback(hObject, eventdata, handles)
    setRendererItem(hObject, handles);


% --------------------------------------------------------------------
function noneRendererItem_Callback(hObject, eventdata, handles)
    setRendererItem(hObject, handles);


% --------------------------------------------------------------------
function useGraphicsCardItem_Callback(hObject, eventdata, handles)
    wasChecked = ischeckedMenuItem( hObject );
    if wasChecked
        CANUSEGPUARRAY = false;
    else
        CANUSEGPUARRAY = canUseGPUArray();
        if ~canUseGPUArray()
            queryDialog( 1, 'Graphic acceleration not available', ...
                'Your graphics card is not powerful enough for GFtbox to use it.' );
        end
    end
    checkMenuItem( hObject, CANUSEGPUARRAY );



function lineSmoothingItem_Callback(hObject, eventdata, handles)
    doLineSmoothing = toggleCheckedMenuItem( hObject );
    attemptCommand( handles, false, true, ...
        'plotoptions', ...
        'linesmoothing', boolchar( doLineSmoothing, 'on', 'off' ) );



% --- Executes on button press in makevvbutton.
function makevvbutton_Callback(hObject, eventdata, handles)
    if ~isempty( handles.mesh )
        [ v1, ok1 ] = getIntFromDialog( handles.numvvcellstext );
        [ v2, ok2 ] = getIntFromDialog( handles.vvsegsperedgetext );
        if ok1 && ok2
            attemptCommand( handles, false, true, ...
                'VV_makelayer', ...
                'numcells', v1, ...
                'edgedivisions', v2 );
        end
    end



function numvvcellstext_Callback(hObject, eventdata, handles)
% Nothing

% --- Executes during object creation, after setting all properties.
function numvvcellstext_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function vvsegsperedgetext_Callback(hObject, eventdata, handles)
% Nothing

function vvsegsperedgetext_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in newVVmgenbutton.
function newVVmgenbutton_Callback(hObject, eventdata, handles)
    queryDialog( 1, 'Not Implemented', 'New VV mgen not yet implemented.' );



% --- Executes on button press in deleteVVmgenbutton.
function deleteVVmgenbutton_Callback(hObject, eventdata, handles)
    queryDialog( 1, 'Not Implemented', 'Delete VV mgen not yet implemented.' );


% --- Executes on button press in renameVVmgenbutton.
function renameVVmgenbutton_Callback(hObject, eventdata, handles)
    queryDialog( 1, 'Not Implemented', 'Rename VV mgen not yet implemented.' );


% --- Executes on button press in setzeroVVmgenbutton.
function setzeroVVmgenbutton_Callback(hObject, eventdata, handles)
    queryDialog( 1, 'Not Implemented', 'Set VV mgen to zero not yet implemented.' );


% --- Executes on button press in addconstVVmgenbutton.
function addconstVVmgenbutton_Callback(hObject, eventdata, handles)
    queryDialog( 1, 'Not Implemented', 'Add to VV mgen not yet implemented.' );


% --- Executes on button press in addrandomVVmgenbutton.
function addrandomVVmgenbutton_Callback(hObject, eventdata, handles)
    queryDialog( 1, 'Not Implemented', 'Add randomly to VV mgen not yet implemented.' );


% --- Executes on selection change in selectedVVmgenmenu.
function selectedVVmgenmenu_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function selectedVVmgenmenu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function vvmgenslider_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function vvmgenslider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function vvmgenamount_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function vvmgenamount_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function VVmgenNegColorChooser_ButtonDownFcn(hObject, eventdata, handles)
    VVmgenColorPick( hObject, 'Positive color', true );

% --------------------------------------------------------------------
function VVmgenColorChooser_ButtonDownFcn(hObject, eventdata, handles)
    VVmgenColorPick( hObject, 'Negative color', false );




% --- Executes on button press in cellMgenSelectButton.
function cellMgenSelectButton_Callback(hObject, eventdata, handles)
    % Turn on or off plotting the current cellular morphogen.
    % This needs a call of notifyPlotChange with the appropriate plot
    % options.
    plotMgensFromGUI( handles );


% --- Executes on selection change in displayedCellMgenMenu.
function displayedCellMgenMenu_Callback(hObject, eventdata, handles)
    relayPeeredAttributes( hObject, 'Value' );
    [~,~,~,h] = getGFtboxFigFromGuiObject(); % clickedItem,tag,fig
    if isfield( h, 'mesh' ) && ~isempty( h.mesh )
        cellmgenName = getMenuSelectedLabel(hObject);
        cellmgen = name2Index( h.mesh.secondlayer.valuedict, cellmgenName );
        if ~isempty(cellmgen) && (cellmgen ~= 0)
            notifyPlotChange( h, 'cellbodyvalue', cellmgen );
            cellfactorUpdater( hObject );
        end
    end


% --- Executes during object creation, after setting all properties.
function displayedCellMgenMenu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
    % Make peer-aware.
    set( hObject, 'DeleteFcn', 'peeredItem_DeleteFcn' );


% --- Executes on button press in cellmgens_panel.
function cellmgens_panel_Callback(hObject, eventdata, handles)
    s = get( hObject, 'tag' );
    floatername = regexp( s, '^(.*)_panel$', 'tokens' );
    if ~isempty( floatername )
        % Floating panel.
        floatername = floatername{1}{1};
        ph = openGFtboxPanel( handles.output, floatername );
        hph = guidata( ph );
        mainhandles = guidata( hObject );
        addPeeredItem( hph.cellmgenmenu, mainhandles.displayedCellMgenMenu, 'String', 'Value' );
        phandles = guidata(ph);
        connectTextAndSlider( phandles.editamount, phandles.slideramount, '', [], true );
        if isfield( phandles, 'editmutate' )
            connectTextAndSlider( phandles.editmutate, phandles.slidermutate, '', [], true );
        end
        cellfactorUpdater( ph );
    end

function brushsizeText_Callback(hObject, eventdata, handles)
    % Nothing.  The contents of this text box will be read and used at the
    % point where the user does a mouse-down in Brush mode.

% --- Executes during object creation, after setting all properties.
function brushsizeText_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in clearSelectionButton.
function clearSelectionButton_Callback(hObject, eventdata, handles)
    gd = guidata( hObject );
    if ~isempty( gd.mesh )
        gd.mesh.selection.highlightedVxList = [];
        if ~isempty( gd.mesh.plothandles.HLvertexes ) && ishandle( gd.mesh.plothandles.HLvertexes )
            delete( gd.mesh.plothandles.HLvertexes );
        end
        gd.mesh.plothandles.HLvertexes = [];
        guidata( hObject, gd );
    end

    


% --- Executes during object creation, after setting all properties.
function simulationMouseModeMenu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on selection change in colorScalePopupMenu.
function colorScalePopupMenu_Callback(hObject, eventdata, handles)
    label = getMenuSelectedLabel( hObject );
    switch label
        case 'Rainbow'
            notifyPlotChange( handles, 'cmaptype', 'rainbow', 'zerowhite', false );
        case 'Split Rainbow'
            notifyPlotChange( handles, 'cmaptype', 'rainbow', 'zerowhite', true );
        case 'Monochrome'
            notifyPlotChange( handles, 'cmaptype', 'monochrome', 'zerowhite', false );
        case 'Split Mono'
            notifyPlotChange( handles, 'cmaptype', 'monochrome', 'zerowhite', true );
        otherwise
    end


% --- Executes during object creation, after setting all properties.
function colorScalePopupMenu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in mouseCellModeMenu.
function mouseCellModeMenu_Callback(hObject, eventdata, handles)
    label = getMenuSelectedLabel( hObject );
    fprintf( 1, 'mouseCellModeMenu_Callback %s\n', label );
    handles = establishInteractionMode( handles );
    turnOffViewControl( handles );
%    setMenuSelectedLabel( handles.mouseeditmodeMenu, '----' );
    guidata( handles.output, handles );


% --- Executes during object creation, after setting all properties.
function mouseCellModeMenu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function mouseSelectMenu_Callback(hObject, eventdata, handles)
    % Nothing.
%     getMenuSelectedLabel


% --------------------------------------------------------------------
function autonameItem_Callback(hObject, eventdata, handles)
    newstate = toggleCheckedMenuItem( hObject );
    if ~isempty(handles.mesh)
        attemptCommand( handles, false, false, ...
            'setproperty', 'autonamemovie', newstate );
    end
%     meshSetBoolean( handles, 'autonamemovie', hObject );


% --- Executes on button press in mouseClickIconButton.
function mouseClickIconButton_Callback(hObject, eventdata, handles)
    selectToggleButton( hObject, ...
        [ handles.mouseClickIconButton, ...
          handles.mouseBoxIconButton, ...
          handles.mouseBrushIconButton ] );


% --- Executes on button press in mouseBoxIconButton.
function mouseBoxIconButton_Callback(hObject, eventdata, handles)
    selectToggleButton( hObject, ...
        [ handles.mouseClickIconButton, ...
          handles.mouseBoxIconButton, ...
          handles.mouseBrushIconButton ] );


% --- Executes on button press in mouseBrushIconButton.
function mouseBrushIconButton_Callback(hObject, eventdata, handles)
    selectToggleButton( hObject, ...
        [ handles.mouseClickIconButton, ...
          handles.mouseBoxIconButton, ...
          handles.mouseBrushIconButton ] );

function selectToggleButton( h, hs )
    for h1=hs
        v = h1==h;
        set( h1, 'Value', v );
        setImageBackgroundOnUIControl( h1 );
        % fprintf( 1, 'Setting %s to %d.\n', get(h1,'tag'), v );
    end


% --- Executes on button press in mouseClickVertexButton.
function mouseClickVertexButton_Callback(hObject, eventdata, handles)
    selectToggleButton( hObject, ...
        [ handles.mouseClickVertexButton, ...
          handles.mouseClickEdgeButton, ...
          handles.mouseClickFaceButton ] );


% --- Executes on button press in mouseClickEdgeButton.
function mouseClickEdgeButton_Callback(hObject, eventdata, handles)
    selectToggleButton( handles.mouseClickVertexButton, ...
        [ handles.mouseClickVertexButton, ...
          handles.mouseClickEdgeButton, ...
          handles.mouseClickFaceButton ] );


% --- Executes on button press in mouseClickFaceButton.
function mouseClickFaceButton_Callback(hObject, eventdata, handles)
    selectToggleButton( handles.mouseClickVertexButton, ...
        [ handles.mouseClickVertexButton, ...
          handles.mouseClickEdgeButton, ...
          handles.mouseClickFaceButton ] );



% --------------------------------------------------------------------
function catchIFExceptionsItem_Callback(hObject, eventdata, handles)
% This toggleable menu item determines how GFtbox handles errors in the interaction function.
% 
% When on, (the default), the error is detected, the simulation is stopped,
% the interaction function is disabled, and the elements in the GUI
% relating to the i.f. turn red.
% 
% When off, Matlab will stop execution of the interaction function immediately.  If
% "Breakpoints > Stop on Errors" is turned on in the Matlab editor, Matlab will then
% enter the debugger at the place where the error occurred.
% 
% End users should mostly leave this turned on.  Those who want to use the debugger
% to determine what went wrong should turn this off.  The setting persists across
% invocations of Matlab and is stored (if changed from the default) in the user's
% config file in the setting "catchIFExceptions".

    toggleCheckedMenuItem( hObject );
    catchIFExceptions = ischeckedMenuItem(hObject);
    setappdata( handles.GFTwindow, 'catchIFExceptions', catchIFExceptions );
    handles.catchIFExceptions = catchIFExceptions;
    saveGFtboxConfig( handles );



function timeCommandsItem_Callback(hObject, eventdata, handles)
    toggleCheckedMenuItem( hObject );

