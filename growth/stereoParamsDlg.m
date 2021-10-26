function varargout = stereoParamsDlg(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @stereoParamsDlg_OpeningFcn, ...
                   'gui_OutputFcn',  @stereoParamsDlg_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT
end


% --- Executes just before stereoParamsDlg is made visible.
function stereoParamsDlg_OpeningFcn(hObject, eventdata, handles, varargin)
    foreColor = [0.9 1 0.9];
    backColor = [0.4 0.8 0.4];
    setGUIColors( hObject, backColor, foreColor )

    % Choose default command line output for timeunitDlg
    handles.output = -1;

    % Update handles structure
    guidata(hObject, handles);

    % Insert default values.
    if ~isfield( handles, 'stereoparams' )
        handles.stereoparams = struct( ...
            'enableStereoCheckbox', 0, ...
            'screensizeToggle', 0, ...
            'imageSpacingText', '1024', ...
                'vergenceText', '2.5', ...
                   'direction', '+h' ...
            );
    end
    if ~isempty(varargin)
        if isstruct(varargin{1})
            args = varargin{1};
        else
            args = struct( varargin{:} );
        end
        args = defaultFromStruct( args, handles.stereoparams );
        set( handles.enableStereoCheckbox, 'Value', args.enableStereoCheckbox );
        set( handles.screensizeToggle, 'Value', args.screensizeToggle );
        set( handles.imageSpacingText, 'String', args.imageSpacingText );
        set( handles.vergenceText, 'String', args.vergenceText );
        switch args.direction
            case '+h'
                set( handles.layoutButtons, 'SelectedObject', handles.eastButton );
            case '-h'
                set( handles.layoutButtons, 'SelectedObject', handles.westButton );
            case '+v'
                set( handles.layoutButtons, 'SelectedObject', handles.northButton );
            case '-v'
                set( handles.layoutButtons, 'SelectedObject', handles.southButton );
        end
    end
    
    centreDialog(hObject);
    
    % Make the GUI modal
    uicontrol(handles.vergenceText);
    set(handles.figure1,'WindowStyle','modal');
    uicontrol(handles.vergenceText);

    % UIWAIT makes timeunitDlg wait for user response (see UIRESUME)
    uiwait(handles.figure1);
end

function initDlg( handles, args )
    fns = fieldnames( args );
    for i=1:length(fns)
        fn = fns{i};
        val = args.(fn);
        if ischar(val)
            set( handles.(fn), 'String', val );
        else
            set( handles.(fn), 'Value', val );
        end
    end
end

% --- Outputs from this function are returned to the command line.
function varargout = stereoParamsDlg_OutputFcn(hObject, eventdata, handles) 
    if isstruct( handles.output )
        seldir = get( handles.layoutButtons, 'SelectedObject' );
        if seldir==handles.northButton
            d = '+v';
        elseif seldir==handles.southButton
            d = '-v';
        elseif seldir==handles.eastButton
            d = '+h';
        elseif seldir==handles.westButton
            d = '-h';
        else
            d = [];
        end
        handles.output.direction = d;
    end
    varargout{1} = handles.output;

    % The figure can be deleted now.
    delete(hObject);
end

function screensizeToggle_Callback(hObject, eventdata, handles)
    useScreenSize( handles );
end

function useScreenSize( handles )
    if get( handles.screensizeToggle, 'Value' )
        screenpos = get( 0, 'ScreenSize' );
        seldir = get( handles.layoutButtons, 'SelectedObject' );
        if (seldir==handles.northButton) || (seldir==handles.southButton)
            value = screenpos(4);
        else
            value = screenpos(3);
        end
        set( handles.imageSpacingText, 'String', sprintf( '%d', value ) );
    end
end

function layoutButtonsFcn( hObject, eventdata )
    useScreenSize( guidata( hObject ) );
end


function enableStereoCheckbox_Callback(hObject, eventdata, handles)
end

