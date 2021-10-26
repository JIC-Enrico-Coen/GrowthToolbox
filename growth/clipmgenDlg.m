function varargout = clipmgenDlg(varargin)
% clipmgenDlg M-file for clipmgenDlg.fig
%      clipmgenDlg, by itself, creates a new clipmgenDlg or raises the existing
%      singleton*.
%
%      H = clipmgenDlg returns the handle to a new clipmgenDlg or the handle to
%      the existing singleton*.
%
%      clipmgenDlg('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in clipmgenDlg.M with the given input arguments.
%
%      clipmgenDlg('Property','Value',...) creates a new clipmgenDlg or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before clipmgenDlg_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to clipmgenDlg_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help clipmgenDlg

% Last Modified by GUIDE v2.5 19-Feb-2009 17:46:43

% Begin initialization code - DO NOT EDIT

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @clipmgenDlg_OpeningFcn, ...
                   'gui_OutputFcn',  @clipmgenDlg_OutputFcn, ...
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


% --- Executes just before clipmgenDlg is made visible.
function clipmgenDlg_OpeningFcn(hObject, eventdata, handles, varargin)
    foreColor = [0.9 1 0.9];
    backColor = [0.4 0.8 0.4];
    setGUIColors( hObject, backColor, foreColor )

    if (length(varargin) >= 2) && strcmp(varargin{1},'INITPARAMS')
        initparams = varargin{2};
        set( handles.mgenListbox, 'String', initparams.allmgens );
        set( handles.mgenListbox, 'Value', initparams.clipmgens );
        setDoubleInTextItem( handles.thresholdText, initparams.threshold );
        set( handles.abovethresholdButton, 'Value', initparams.above );
        set( handles.belowthresholdButton, 'Value', ~initparams.above );
        set( handles.allmgensButton, 'Value', initparams.all );
        set( handles.anymgensButton, 'Value', ~initparams.all );
    end
    handles.output = -1;
    guidata(hObject, handles);
    centreDialog(hObject);
    set(handles.figure1,'WindowStyle','modal');
    uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = clipmgenDlg_OutputFcn(hObject, eventdata, handles) 
    if isstruct(handles.output)
        handles.output.above = get( handles.abovethresholdButton, 'Value' );
        handles.output.all = get( handles.allmgensButton, 'Value' );
        handles.output.mgens = get( handles.mgenListbox, 'Value' );
        [handles.output.threshold,ok] = getDoubleFromDialog( handles.thresholdText );
        if isnan(handles.output.threshold)
            handles.output.threshold = 0;
        end
    end
    varargout{1} = handles.output;
    delete(hObject);


function mgenListbox_Callback(hObject, eventdata, handles)

function mgenListbox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function okButton_Callback(hObject, eventdata, handles)


function cancelButton_Callback(hObject, eventdata, handles)


function allmgensButton_Callback(hObject, eventdata, handles)
    set( hObject, 'Value', 1 );
    set( handles.anymgensButton, 'Value', 0 );

function anymgensButton_Callback(hObject, eventdata, handles)
    set( hObject, 'Value', 1 );
    set( handles.allmgensButton, 'Value', 0 );

function abovethresholdButton_Callback(hObject, eventdata, handles)
    set( hObject, 'Value', 1 );
    set( handles.belowthresholdButton, 'Value', 0 );

function belowthresholdButton_Callback(hObject, eventdata, handles)
    set( hObject, 'Value', 1 );
    set( handles.abovethresholdButton, 'Value', 0 );

function thresholdText_Callback(hObject, eventdata, handles)
    [threshold,ok] = getDoubleFromDialog( hObject );
    if ~ok
        set( hObject, 'String', '0' );
    end

function thresholdText_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


