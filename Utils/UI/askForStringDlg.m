function varargout = askForStringDlg(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @askForStringDlg_OpeningFcn, ...
                   'gui_OutputFcn',  @askForStringDlg_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
%if nargin && ischar(varargin{1})
%    gui_State.gui_Callback = str2func(varargin{1});
%end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT
end



% --- Executes just before askForStringDlg is made visible.
function askForStringDlg_OpeningFcn(hObject, eventdata, handles, varargin)
    foreColor = [0.9 1 0.9];
    backColor = [0.4 0.8 0.4];
    setGUIColors( hObject, backColor, foreColor )

% Set the default result of the dialog.
handles.output = [];

% Update handles structure
guidata(hObject, handles);

% Insert custom title, prompt string and initial text.
if(nargin > 3)
    for index = 1:2:(nargin-3)
        if nargin-3==index, break, end
        switch lower(varargin{index})
            case 'title'
                set(hObject, 'Name', varargin{index+1});
            case 'prompt'
                set(handles.staticText, 'String', varargin{index+1});
            case 'initialvalue'
                set(handles.editableText, 'String', varargin{index+1});
            case 'multiline'
                if varargin{index+1}
                    set( handles.editableText, 'Min', 0, 'Max', 2 );
                else
                    set( handles.editableText, 'Min', 0, 'Max', 1 );
                end
            otherwise
                complain( '%s: unknown option %s.\n', mfilename(), varargin{index} );
        end
    end
end

% Lay out the dialog.
% The prompt should be the width less top and side margins; height
% unchanged.
    MARGIN = 14;
    figPos = get(hObject, 'Position' );
    okPos = get( handles.okButton, 'Position' );
    okPos(1) = (figPos(3)-MARGIN)/2 - okPos(3);
    okPos(2) = MARGIN;
    set( handles.okButton, 'Position', okPos );
    cPos = get( handles.cancelButton, 'Position' );
    cPos(1) = (figPos(3)+MARGIN)/2;
    cPos(2) = okPos(2);
    set( handles.cancelButton, 'Position', cPos );
    etPos = get( handles.editableText, 'Position' );
    etPos(1) = MARGIN;
    etPos(3) = figPos(3) - MARGIN*2;
    etPos(2) = okPos(2) + okPos(4) + MARGIN;
    set( handles.editableText, 'Position', etPos );
    stPos = get( handles.staticText, 'Position' );
    stExtent = get( handles.staticText, 'Extent' );
    stPos(1) = MARGIN;
    stPos(3) = figPos(3) - MARGIN*2;
    stPos(2) = etPos(2) + etPos(4) + MARGIN;
    stPos(4) = stExtent(4);
    set( handles.staticText, 'Position', stPos );
    figPos(4) = stPos(2) + stPos(4) + MARGIN;
    set( hObject, 'Position', figPos );



% set(handles.editableText, 'KeyPressFcn', @editableTextKeyPressFcn );
% set(handles.editableText, 'Callback', @editableTextCallback );

centreDialog(hObject);

% Make the GUI modal
set(handles.figure1,'WindowStyle','modal');
uicontrol( handles.editableText );
uicontrol( handles.editableText );

% UIWAIT makes askForStringDlg wait for user response (see UIRESUME)
uiwait(handles.figure1);
end


function editableTextKeyPressFcn( hObject, eventData )
    fprintf( 1, 'editableTextKeyPressFcn\n' );
    eventData
end

function editableTextCallback( hObject, eventData )
    fprintf( 1, 'editableTextCallback\n' );
    eventData
    checkTerminationKey(gcbo);
end



% --- Outputs from this function are returned to the command line.
function varargout = askForStringDlg_OutputFcn(hObject, eventdata, handles)
% Get the result of the dialog.
varargout{1} = handles.output;

% The figure can be deleted now.
delete(hObject);
end
