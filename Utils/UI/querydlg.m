function varargout = querydlg(varargin)
% QUERYDLG M-file for querydlg.fig
%      QUERYDLG, by itself, creates a new QUERYDLG or raises the existing
%      singleton*.
%
%      H = QUERYDLG returns the handle to a new QUERYDLG or the handle to
%      the existing singleton*.
%
%      QUERYDLG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in QUERYDLG.M with the given input arguments.
%
%      QUERYDLG('Property','Value',...) creates a new QUERYDLG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before querydlg_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to querydlg_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help querydlg

% Last Modified by GUIDE v2.5 10-Jun-2009 10:36:45

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @querydlg_OpeningFcn, ...
                   'gui_OutputFcn',  @querydlg_OutputFcn, ...
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


% --- Executes just before querydlg is made visible.
function querydlg_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to querydlg (see VARARGIN)

% Choose default command line output for querydlg
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Insert custom title, prompt string and initial text.
buttons = 3;
if(nargin > 3)
    for index = 1:2:(nargin-3)
        if nargin-3==index, break, end
        switch lower(varargin{index})
            case 'title'
                title = varargin{index+1};
            case 'querytext'
                set(handles.querytext, 'String', varargin{index+1});
            case 'buttons'
                 buttons = varargin{index+1};
        end
    end
end
[handles,numbuttons] = setbuttons( handles, buttons );
if isempty(title)
    if numbuttons==1
        title = 'Alert';
    elseif numbuttons==2
        title = 'Confirm';
    else
        title = 'Query';
    end
end
set(hObject, 'Name', title);
set( handles.output, 'KeyPressFcn', @queryTerminationKey );
set( handles.button1, 'Callback', @endQueryDialog );
set( handles.button2, 'Callback', @endQueryDialog );
set( handles.button3, 'Callback', @endQueryDialog );
reformatdlg( handles );
movegui(handles.output);
guidata( hObject, handles );

setGFtboxColourScheme( handles.output, getGFtboxHandles() );
% UIWAIT makes querydlg wait for user response (see UIRESUME)
uiwait(handles.figure1);
end

function [handles,numbuttons] = setbuttons( handles, buttons )
    if isnumeric(buttons)
        if buttons==1
            buttons = { 'OK' };
        elseif buttons==2
            buttons = { 'OK', 'Cancel' };
        else
            buttons = { 'Yes', 'No', 'Cancel' };
        end
    end
    numbuttons = trimnumber( 1, length(buttons), 3 );
    for i=1:numbuttons
        set( handles.(['button', char('0'+i)]), 'String', buttons{i} );
    end
    for i=1:3
        set( handles.(['button', char('0'+i)]), ...
             'Visible', boolchar( i<=numbuttons, 'on', 'off' ) );
    end
    handles.buttonlast = handles.(['button', char('0'+numbuttons)]);
end

function reformatdlg( handles )
    string = get( handles.querytext, 'String' );
    [outstring,newpos] = textwrap( handles.querytext, {string} );
    newpos(4) = newpos(4) + 12;  % Kludge because textwrap fails on long words.
    pos = get( handles.querytext, 'Position' );
    dh = pos(4) - newpos(4);
    pos(4) = newpos(4);
    set(handles.querytext,'String',outstring,'Position',pos);

    pos = get( handles.output, 'Position' );
    pos(4) = pos(4) - dh;
    set( handles.output, 'Position', pos );
end

function shiftguielement( h, dh )
    pos = get( h, 'Position' );
    pos(2) = pos(2) + dh;
    set( h, 'Position', pos );
end

% --- Outputs from this function are returned to the command line.
function varargout = querydlg_OutputFcn(hObject, eventdata, handles) 
% Get default command line output from handles structure
%if ishandle( handles.output )
%    varargout{1} = 0;
%else
    varargout{1} = handles.output;
%end
delete(hObject);
end

function queryTerminationKey( hObject, eventdata )
    dlg = getRootHandle(hObject);
    key = get(dlg,'CurrentKey');
    handles = guidata( hObject );
    if isequal(key,'escape')
        % User said no by hitting escape
        endQueryDialog(handles.buttonlast,[]);
    elseif isequal(key,'return')
        % User said yes by hitting return
        endQueryDialog(handles.button1,[]);
    end
    % Ignore all other keystrokes.
end

function endQueryDialog( uiitem, eventdata )
    handles = guidata( uiitem );
    tag = get( uiitem, 'Tag' );
    if ~isempty( handles )
        handles.output = tag(end) - '0';
        guidata(uiitem, handles);
        uiresume(ancestor(uiitem,'figure'));
    else isempty(handles)
        delete(getRootHandle(uiitem));
    end
end
