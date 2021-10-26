function varargout = canvasColorsDlg(varargin)
% CANVASCOLORSDLG M-file for canvasColorsDlg.fig
%      CANVASCOLORSDLG by itself, creates a new CANVASCOLORSDLG or raises the
%      existing singleton*.
%
%      H = CANVASCOLORSDLG returns the handle to a new CANVASCOLORSDLG or the handle to
%      the existing singleton*.
%
%      CANVASCOLORSDLG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CANVASCOLORSDLG.M with the given input arguments.
%
%      CANVASCOLORSDLG('Property','Value',...) creates a new CANVASCOLORSDLG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before canvasColorsDlg_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to canvasColorsDlg_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help canvasColorsDlg

% Last Modified by GUIDE v2.5 22-Jun-2009 12:25:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @canvasColorsDlg_OpeningFcn, ...
                   'gui_OutputFcn',  @canvasColorsDlg_OutputFcn, ...
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

% --- Executes just before canvasColorsDlg is made visible.
function canvasColorsDlg_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to canvasColorsDlg (see VARARGIN)

    foreColor = [0.9 1 0.9];
    backColor = [0.4 0.8 0.4];
    setGUIColors( hObject, backColor, foreColor )
% Choose default command line output for canvasColorsDlg
handles.output = -1;

% Update handles structure
guidata(hObject, handles);

    % Insert default values.
    if ~isempty(varargin)
        for index = 1:2:(length(varargin)-1),
            if nargin-3==index, break, end
            switch lower(varargin{index})
              case 'facecolor'
                setButtonColor( handles.facesButton, varargin{index+1} );
              case 'edgecolor'
                setButtonColor( handles.edgesButton, varargin{index+1} );
            end
        end
    end

% Determine the position of the dialog - centered on the callback figure
% if available, else, centered on the screen
FigPos=get(0,'DefaultFigurePosition');
OldUnits = get(hObject, 'Units');
set(hObject, 'Units', 'pixels');
OldPos = get(hObject,'Position');
FigWidth = OldPos(3);
FigHeight = OldPos(4);
if isempty(gcbf)
    ScreenUnits=get(0,'Units');
    set(0,'Units','pixels');
    ScreenSize=get(0,'ScreenSize');
    set(0,'Units',ScreenUnits);

    FigPos(1)=1/2*(ScreenSize(3)-FigWidth);
    FigPos(2)=2/3*(ScreenSize(4)-FigHeight);
else
    GCBFOldUnits = get(gcbf,'Units');
    set(gcbf,'Units','pixels');
    GCBFPos = get(gcbf,'Position');
    set(gcbf,'Units',GCBFOldUnits);
    FigPos(1:2) = [(GCBFPos(1) + GCBFPos(3) / 2) - FigWidth / 2, ...
                   (GCBFPos(2) + GCBFPos(4) / 2) - FigHeight / 2];
end
FigPos(3:4)=[FigWidth FigHeight];
set(hObject, 'Position', FigPos);
set(hObject, 'Units', OldUnits);

set( handles.okButton, 'Callback', @okButtonCallback );
set( handles.figure1, 'KeyPressFcn', @checkCanvasColorsTerminationKey );

% Make the GUI modal
set(handles.figure1,'WindowStyle','modal')

% UIWAIT makes canvasColorsDlg wait for user response (see UIRESUME)
uiwait(handles.figure1);

function setButtonColor( h, c )
    set( h, 'BackgroundColor', c, 'ForegroundColor', contrastColor( c ) );


% --- Outputs from this function are returned to the command line.
function varargout = canvasColorsDlg_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% The figure can be deleted now
delete(handles.figure1);


% --- Executes on button press in facesButton.
function facesButton_Callback(hObject, eventdata, handles)
    colorPickerButtonCallback( hObject, 'Face color' );
    
% --- Executes on button press in edgesButton.
function edgesButton_Callback(hObject, eventdata, handles)
    colorPickerButtonCallback( hObject, 'Edge color' );

function colorPickerButtonCallback( hObject, title )
    bgColor = get( hObject, 'BackgroundColor' );
    fgColor = get( hObject, 'ForegroundColor' );
    if nargin < 2
        c = uisetcolor( bgColor );
    else
        c = uisetcolor( bgColor, title );
    end
    if (length(c)==3) && any( c ~= bgColor )
        setButtonColor( hObject, c );
    end

function cc = contrastColor( c )
    if sum(c) > 1.5
        cc = [0 0 0];
    else
        cc = [1 1 1];
    end


function checkCanvasColorsTerminationKey( hObject, eventdata )
    dlg = getRootHandle(hObject);
    key = get(dlg,'CurrentKey');
    if isequal(key,'escape')
        % User said no by hitting escape
        exitCanvasColorsDialog(hObject,false);
    elseif isequal(key,'return')
        % User said yes by hitting return
        exitCanvasColorsDialog(hObject,true);
    end
    % Ignore all other keystrokes.

function okButtonCallback( uiitem, eventdata )
    getColorsResult( uiitem );
    uiresume(ancestor(uiitem,'figure'));

function getColorsResult( uiitem )
    handles = guidata( uiitem );
    handles.output = struct( ...
        'facecolor', get( handles.facesButton, 'BackgroundColor' ), ...
        'edgecolor', get( handles.edgesButton, 'BackgroundColor' ) );
    guidata(gcbo, handles);
       
function exitCanvasColorsDialog( uiitem, success )
    if success
        getColorsResult( uiitem );
    end
    uiresume(ancestor(uiitem,'figure'));

