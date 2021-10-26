function varargout = VRMLparams(varargin)
% VRMLPARAMS M-file for VRMLparams.fig
%      VRMLPARAMS, by itself, creates a new VRMLPARAMS or raises the existing
%      singleton*.
%
%      H = VRMLPARAMS returns the handle to a new VRMLPARAMS or the handle to
%      the existing singleton*.
%
%      VRMLPARAMS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VRMLPARAMS.M with the given input arguments.
%
%      VRMLPARAMS('Property','Value',...) creates a new VRMLPARAMS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before VRMLparams_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to VRMLparams_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help VRMLparams

% Last Modified by GUIDE v2.5 21-Dec-2009 17:44:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @VRMLparams_OpeningFcn, ...
                   'gui_OutputFcn',  @VRMLparams_OutputFcn, ...
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


function VRMLparams_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = [];

% Update handles structure
guidata(hObject, handles);

groupRadioButtons( [ handles.scaleSizeByRB, handles.scaleSizeToRB ] );
groupRadioButtons( [ handles.scaleThicknessByRB, handles.scaleThicknessToRB, handles.setThicknessRB ] );
addUserData( handles.scaleSizeByRB, 'texthandle', handles.scaleSizeByET );
addUserData( handles.scaleSizeToRB, 'texthandle', handles.scaleSizeToET );
addUserData( handles.scaleThicknessByET, 'texthandle', handles.scaleThicknessByRB );
addUserData( handles.scaleThicknessToET, 'texthandle', handles.scaleThicknessToRB );
addUserData( handles.setThicknessRB, 'texthandle', handles.setThicknessET );


         
         
    % cf = get( handles.scaleSizeByET, 'CreateFcn' )

    centreDialog(hObject);
    
    % Make the GUI modal
    set(handles.figure1,'WindowStyle','modal');

    % UIWAIT makes VRMLparams wait for user response (see UIRESUME)
    uiwait(handles.figure1);


function varargout = VRMLparams_OutputFcn(hObject, eventdata, handles) 
    varargout{1} = handles.output;
    delete(hObject);



function scaleThicknessByRB_Callback(hObject, eventdata, handles)


function scaleThicknessToRB_Callback(hObject, eventdata, handles)


function setThicknessRB_Callback(hObject, eventdata, handles)


function scaleSizeByRB_Callback(hObject, eventdata, handles)

function scaleSizeToRB_Callback(hObject, eventdata, handles)


